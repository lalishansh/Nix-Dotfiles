{ config, lib, pkgs, ... }:
let
  inherit (lib) mkOption types mkDefault literalExpression;
  inherit (builtins) attrValues;

  # TODO add assertion
  filePath_t = types.coercedTo types.path (p: "${p}") types.str;
  fileOptionsSubmodule = { config, name, options, ... }:{
    options = {
      target = mkOption {
        defaultText = literalExpression ''"<name>"'';
        type = types.str;
        description = "Relative Path of the resulting file.";
      };

      source = mkOption {
        type = filePath_t;
        description = ''
          Source file or directory that we are linking into.
          $ ln -sfn <target_file_or_directory> <source_file_or_directory>
        '';
        example = ./hyprland.conf;
      };

      directory = mkOption {
        type = types.nullOr (types.listOf filePath_t);
        default = null;
        description = ''
          Source files and directories that we are linking inside the target directory.
          $ ln -sft <target_directory> <source_files_or_directories>...
        '';
        example = [ ./kitty.conf ./ashell ];
      };

      text = mkOption {
        default = null;
        type = types.nullOr types.lines;
        description = ''
          Text to write to the resulting file, as an alternative to `.source`.
          Uses `pkgs.writeTextFile` to create a temporary file with the provided text,
          then assigns the path to the `source` option.
        '';
        example = "Hello, World!";
      };
    };

    config = {
      target = mkDefault name;
      source = lib.mkIf (config.text != null) (
        lib.mkDerivedConfig options.text (
          t: pkgs.writeTextFile {
            name = "text-file-" + lib.replaceStrings [ "/" ] [ "-" ] name;
            text = t;
          }
        )
      );
    };
  };

  mkFileOption = { env }:mkOption {
    type = types.attrsOf (types.submodule fileOptionsSubmodule);
    description = ''
      Files to symlink relative to $ ${env}.

      You can defer some variables to be looked-up at runtime, by using bash syntax.
      For example `.source = "$HOME/path/to/foo"`.
    '';
    default = {};
    example = literalExpression ''
      {
        "foo".source = pkgs.coreutils;
        "bar".text = "Hello";
        "baz".source = "$HOME/.gitconfig";
        "set".directory = [
          "/etc" "/usr/local/etc"
        ];
      }
    '';
  };

  mkFileOptionConfig = { root, fromConfig }: (builtins.concatMap (value: [(
    if value.directory != null then
      "mkdir -p ${root}/${value.target}\nchown $USER ${root}/${value.target}\nln -sft ${root}/${value.target} ${lib.concatStringsSep " " value.directory}"
    else  # Link from path to static
      "mkdir -p $(dirname ${root}/${value.target})\nln -sfn ${value.source} ${root}/${value.target}"
  )]) (attrValues fromConfig));

  dir_vars = config:{
    home   = "${config.home}";
    config = "${config.home}/.config";
    data   = "${config.home}/.local/share";
    state  = "${config.home}/.local/state";
  };
in
{
  options = let vars = dir_vars config; in
  {
    home_dir   = mkFileOption { env = vars.home; };
    config_dir = mkFileOption { env = vars.config; };
    data_dir   = mkFileOption { env = vars.data; };
    state_dir  = mkFileOption { env = vars.state; };
  };

  config = let vars = dir_vars config; in {
    user_executeRules = lib.mkMerge [
      (mkFileOptionConfig { root = vars.home;   fromConfig = config.home_dir; })
      (mkFileOptionConfig { root = vars.config; fromConfig = config.config_dir; })
      (mkFileOptionConfig { root = vars.data;   fromConfig = config.data_dir; })
      (mkFileOptionConfig { root = vars.state;  fromConfig = config.state_dir; })
    ];
  };
}
