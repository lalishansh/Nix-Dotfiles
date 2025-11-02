{ config, lib, pkgs, ... }:

let
  inherit (lib) mkOption types mdDoc literalExpression;

  # User submodule extension for session commands
  userSubmodule.options = {
    user_executeRules = mkOption {
      type = types.listOf types.str;
      default = [];
      description = mdDoc ''
        Configuration for systemd service to execute rules per user.
      '';
    };

    defaultSessionCmd = mkOption {
      type = types.nullOr types.str;
      default = null;
      description = mdDoc ''
        Default session command to execute when user logs in.
        This will be written to ~/.defaultSessionCmd.sh in the user's home directory.
      '';
      example = literalExpression ''"''${lib.getExe pkgs.hyprland}"'';
    };
  };

  userSubmoduleWithAlias = types.submodule {
    imports = [
      userSubmodule
      ./file.nix

      # (lib.mkAliasOptionModule [ "home_dir" ] [ "maid" "file" "home" ])
    ];
    config._module.args = { inherit pkgs; };
  };
in
{
  options = {
    users.users = mkOption {
      type = types.attrsOf userSubmoduleWithAlias;
    };

    shared.defaultSessionCmdFile = mkOption {
      type = types.str;
      default = "~/.defaultSessionCmd.sh";
      description = mdDoc ''
        Path to the default session command file relative to user home.
      '';
    };
  };

  config.system.activationScripts = lib.mkMerge (
    lib.mapAttrsToList (username: userConfig:
      lib.mkIf (userConfig.defaultSessionCmd != null) {
        "write-session-cmd-${username}" = {
          text =
            let
              userHome = userConfig.home or "/home/${username}";
              sessionFile = "${userHome}/${lib.removePrefix "~/" config.shared.defaultSessionCmdFile}";
            in ''
              # "Writing session command for user: ${username}"
              echo "${userConfig.defaultSessionCmd}" > "${sessionFile}"
              chmod a=rx "${sessionFile}"
              USER=${username}
              # Execute user-defined rules
              ${lib.concatStringsSep "\n" userConfig.user_executeRules}
            '';
          deps = [];
        };
      }
    ) config.users.users
  );
}
