{ config, lib, ... }:

let
  inherit (lib) mkOption types;

  # User submodule extension for session commands
  userSubmodule.options = {
    defaultSessionCmd = mkOption {
      type = types.nullOr types.str;
      default = null;
      description = lib.mdDoc ''
        Default session command to execute when user logs in.
        This will be written to ~/.defaultSessionCmd.sh in the user's home directory.
      '';
      example = lib.literalExpression ''"''${lib.getExe pkgs.hyprland}"'';
    };
  };

in {
  options = {
    users.users = mkOption {
      type = types.attrsOf (types.submodule userSubmodule);
    };

    shared.defaultSessionCmdFile = mkOption {
      type = types.str;
      default = "~/.defaultSessionCmd.sh";
      description = lib.mdDoc ''
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
              echo "Writing session command for user: ${username}"
              echo "${userConfig.defaultSessionCmd}" > "${sessionFile}"
              chmod +x "${sessionFile}"
              chown ${username}:${userConfig.group or "users"} "${sessionFile}"
              echo "Session command written to: ${sessionFile}"
            '';
          deps = [];
        };
      }
    ) config.users.users
  );
}
