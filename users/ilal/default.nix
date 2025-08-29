{ inputs, pkgs, lib, ... }:
{
  imports = [
    ../shared/options.nix
  ];

  # Define a user account. Don't forget to set a password with ‘passwd’.
  users.users.ilal = lib.mkMerge [
    {
      initialPassword = "ilal";
      description = "Ishansh Lal";
      isNormalUser = true;
      extraGroups = [ "networkmanager" "wheel" ];
    }
    (import ./desktop-env {inherit inputs pkgs lib;})
    (import ./development {inherit pkgs;})
  ];

  # Move some things to user level?
  xdg = {
    mime.enable = true;
    portal.config = {
      common = {
        default = [ "gtk" ];
      };
    };
  };
  qt = {
    enable = true;
    platformTheme = "kde6";
  };
  xdg.portal = {
    enable = true;
    extraPortals = with pkgs; [ xdg-desktop-portal-hyprland xdg-desktop-portal-gtk xdg-desktop-portal ];
  };
  environment.systemPackages = [
    pkgs.kdePackages.xdg-desktop-portal-kde
  ];
  services.graphical-desktop.enable = true;
  programs = {
    dconf.enable = true;
    xwayland.enable = true;
  };
  services.xserver.desktopManager.runXdgAutostartIfNone = true;
}
