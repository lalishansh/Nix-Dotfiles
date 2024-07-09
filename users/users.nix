{ config, ... }:

{
  # Define the user account.
  users.users.ilal = {
    isNormalUser = true;
    description = "Ishansh Lal";
    extraGroups = [ "networkmanager" "wheel" "flatpak" ];
    #packages = with pkgs; []; # packages defined in /users/<user>/home.nix
    initialPassword = "1234";
  };
  home-manager.users.ilal = import ./ilal/home.nix;
}
