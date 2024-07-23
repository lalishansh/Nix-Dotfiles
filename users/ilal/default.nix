{ config, ... }:
let
  username = "${baseNameOf (toString ./.)}";
in
{
  # Define the user account.
  users.users.${username} = {
    isNormalUser = true;
    extraGroups = [ "networkmanager" "wheel" "flatpak" "login" "adbusers" ]; # `login` group for gnome-keyring
    #packages = with pkgs; []; # packages defined in /users/<user>/home.nix
    initialPassword = username;
  };

  home-manager.users.${username} = import ./home.nix;
}
