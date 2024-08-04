{ config, lib, pkgs, ... }:
let
  emailid  = "lalishansh@gmail.com";
  fullname = "Ishansh Lal";
  username = "${baseNameOf (toString ./.)}";
  hypruser = "h${username}";
in
{
  # Define the user account.
  users.users = let
    config = {
      isNormalUser = true;
      extraGroups = [ "networkmanager" "wheel" "flatpak" "login" "adbusers" "audio" "video" "libvirtd" ]; # `login` group for gnome-keyring
    };
  in {
    ${username} = {
      inherit (config) isNormalUser extraGroups;
      description = "${fullname}";
      initialPassword = username;
    };
  };

  home-manager.users = let
    config = { user, include ? [] }:{
      home.username = user;
      home.homeDirectory = "/home/${user}";
      imports = [
        ./programs
        (import ./desktop/gitandssh.nix {
          inherit pkgs;
          sshProvider = "gnome-keyring";
          email = emailid;
          name = fullname;
        })
      ] ++ include;

      # Config to target compatibility of HomeManager version
      home.stateVersion = "24.05";

      # Let HomeManager install and manage itself
      programs.home-manager.enable = true;
    };
  in {
    ${username} = config {
      user = username;
      include = [
        ./desktop/dwl-rofi
      ];
    };
  };
}
