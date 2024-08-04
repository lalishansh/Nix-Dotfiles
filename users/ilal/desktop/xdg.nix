{ pkgs, portals ? [], ... } :
{
  xdg = {
    enable = true;
    portal = {
      enable = true;
      extraPortals = portals;
      config.common = {
        default = [ "gtk" ];
        "org.freedesktop.impl.portal.Secret" = [ "gnome-keyring" ];
      };
      xdgOpenUsePortal = true;
    };
    userDirs = { enable = true; createDirectories = true; };
  };

  home.packages = with pkgs; [
    gnome-keyring
  ];
}
