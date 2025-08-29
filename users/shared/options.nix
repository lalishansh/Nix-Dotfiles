# users/shared/options.nix
{ config, lib, ... }:

let
  inherit (lib) mkOption types;

  # User submodule that extends the existing users.users.<n> options
  userSubmodule.options = {
    path = mkOption {
      type = theBasePathOpts;
      default = {};
      description = lib.mdDoc ''
        Attribute set of paths in the user's home directory to manage files or folders.
        The attribute name represents the relative path from the user's home directory.
        Each path must use exactly one of: copy, link, or text operations.
      '';
      example = {
        ".config/kitty/kitty.conf".copy = ./kitty.conf;
        ".config/zed".link = ./zed;
        ".bashrc".text = "echo 'Hello from NixOS!'";
      };
    };
  };

  # Coerce path to string for bash scripts
  # THIS DOSEN'T WORK NOW SEE: https://github.com/NixOS/nix/issues/7327#issuecomment-3221011650
  pathType = types.coercedTo types.path (p: builtins.toString p) types.str;

  # Type definition for path operations
  theBasePathOpts = types.attrsOf (types.submodule {
    options = {
      copy = mkOption {
        type = types.nullOr pathType;
        default = null;
        description = lib.mdDoc ''
          Path to copy from. Will be automatically converted to string for bash scripts.
          Nix will automatically validate the path exists.
        '';
        example = ./kitty.conf;
      };

      link = mkOption {
        type = types.nullOr pathType;
        default = null;
        description = lib.mdDoc ''
          Path to create a symbolic link from. Will be automatically converted to string for bash scripts.
          Nix will automatically validate the path exists.
        '';
        example = ./zed;
      };

      text = mkOption {
        type = types.nullOr types.str;
        default = null;
        description = lib.mdDoc ''
          Text content to write directly to the file.
          This will forcefully create a file with the specified content at the target path,
          overwriting any existing file.
        '';
        example = ''
          # My custom configuration
          set number
          set tabstop=4
        '';
      };
    };
  });

  # Helper function to generate operation list for a user
  generateOperationList = username: userConfig:
    let
      userHome = userConfig.home or "/home/${username}";
      operations = lib.mapAttrsToList (destPath: pathConfig:
        let
          fullDestPath = "${userHome}/${destPath}";
        in
        if pathConfig.copy != null then
          [ "copy" fullDestPath pathConfig.copy ]
        else if pathConfig.link != null then
          [ "link" fullDestPath pathConfig.link ]
        else if pathConfig.text != null then
          [ "text" fullDestPath pathConfig.text ]
        else
          [ "none" fullDestPath "-" ]
      ) userConfig.path;
    in
    lib.flatten operations;

in {
  options.users.users = mkOption {
    type = types.attrsOf (types.submodule userSubmodule);
  };

  config = {
    # Simple validation: ensure exactly one operation per path
    assertions = lib.flatten (
      lib.mapAttrsToList (username: userConfig:
        lib.mapAttrsToList (destPath: pathConfig:
          let
            operations = lib.filter (op: op != null) [
              pathConfig.copy
              pathConfig.link
              pathConfig.text
            ];
            operationCount = builtins.length operations;
          in {
            assertion = operationCount == 1;
            message = ''
              users.users.${username}.path."${destPath}": Exactly one of 'copy', 'link', or 'text' must be specified.
              Currently ${toString operationCount} operations are specified.
              ${if operationCount == 0 then "No operation provided - you must specify copy, link, or text." else ""}
            '';
          }
        ) (userConfig.path or {})
      ) config.users.users
    );

    # Create activation scripts for each user's path operations
    system.activationScripts = lib.mkMerge (
      lib.mapAttrsToList (username: userConfig:
        lib.mkIf (userConfig.path != {}) {
          "manage-user-paths-${username}" = {
            text =
              let
                operationList = generateOperationList username userConfig;
                operationsArray = lib.concatStringsSep " " (map lib.escapeShellArg operationList);
              in ''
              # Managing files/folders for user: ${username}
              echo "Starting path management for user: ${username}"

              # Flat array of operations: operation destination source_or_text operation destination source_or_text ...
              operations=(${operationsArray})
              operations_len=''${#operations[@]}

              # Process each operation (3 elements per operation)
              for ((i=0; i<operations_len; )); do
                operation="''${operations[$((i++))]}"
                destination="''${operations[$((i++))]}"
                source_or_text="''${operations[$((i++))]}"

                # Create destination directory
                dest_dir="$(dirname "$destination")"
                mkdir -p "$dest_dir"

                case "$operation" in
                  "copy")
                    echo "Copying: $source_or_text -> $destination"
                    rm -rf "$destination"
                    if [ -f "$source_or_text" ]; then
                      cp -f "$source_or_text" "$destination"
                    elif [ -d "$source_or_text" ]; then
                      cp -rf "$source_or_text" "$destination"
                    fi
                    ;;

                  "link")
                    echo "Linking: $source_or_text -> $destination"
                    rm -rf "$destination"
                    ln -sf "$source_or_text" "$destination"
                    ;;

                  "text")
                    echo "Writing text to: $destination"
                    rm -f "$destination"
                    printf '%s\n' "$source_or_text" > "$destination"
                    ;;
                esac

                # Set ownership to user
                chown -R ${username}:${userConfig.group or "users"} "$destination"
              done

              echo "Completed path management for user: ${username}"
            '';
            deps = [];
          };
        }
      ) config.users.users
    );
  };
}
