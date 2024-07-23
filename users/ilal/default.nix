{ config, pkgs, ... }:
let
  emailid  = "lalishansh@gmail.com";
  fullname = "Ishansh Lal";
  username = "${baseNameOf (toString ./.)}";
in
{
  # Define the user account.
  users.users.${username} = {
    description = "${fullname}";
    isNormalUser = true;
    extraGroups = [ "networkmanager" "wheel" "flatpak" "login" "adbusers" ]; # `login` group for gnome-keyring
    initialPassword = username;
  };

  home-manager.users.${username} = {
    home.username = username;
    home.homeDirectory = "/home/${username}";

    imports = [
      ./home.nix
      (import ../common/gitandssh.nix {
        inherit pkgs;
        sshProvider = "gnome-keyring";
        email = emailid;
        name = fullname;
      })
    ];

    # Config to target compatibility of HomeManager version
    home.stateVersion = "24.05";

    # Let HomeManager install and manage itself
    programs.home-manager.enable = true;
  };
}
