{ config, pkgs, lib, pkgs-stable, ... }: let
  de = "hypr-ashell"; # "cosmic", "hypr-ashell", "hypr-qs-ii"

  de_root_configs = if de == "cosmic" then {
    services.geoclue2 = {
      enable = true;
      enableDemoAgent = false;
      whitelistedAgents = [ "geoclue-demo-agent" ];
    };

    hardware.bluetooth.enable = true;
    networking.networkmanager.enable = true;

    services = {
      acpid.enable = true;
      avahi.enable = true;
      gnome.gnome-keyring.enable = true;
      gvfs.enable = true;
      orca.enable = true;
      power-profiles-daemon.enable = true;
    };
    xdg.portal.extraPortals = with pkgs; [ xdg-desktop-portal-cosmic ];
  } else if de == "hypr-ashell" then {
    xdg.portal.extraPortals = with pkgs; [ xdg-desktop-portal-hyprland ];
  } else if de == "hypr-qs-ii" then {
    xdg.portal.extraPortals = with pkgs; [ xdg-desktop-portal-hyprland ];
    environment.systemPackages = [ pkgs.kdePackages.xdg-desktop-portal-kde ];
  } else {};
in {
  imports = [
    # ../shared/options.nix

    de_root_configs
  ];

  # Define a user account. Don't forget to set a password with ‘passwd’.
  users.users.ilal = lib.mkMerge [
    {
      initialPassword = "ilal";
      description = "Ishansh Lal";
      isNormalUser = true;
      extraGroups = [ "networkmanager" "wheel" ];
    }
    (if de == "hypr-ashell" then
      import ./desktop-env/hyprland-ashell {inherit config pkgs lib;}
    else if de == "hypr-qs-ii" then
      import ./desktop-env/illogical-impulse-with-hyprland {inherit pkgs lib;}
    else if de == "cosmic" then
      import ./desktop-env/cosmic {inherit config pkgs lib;}
    else { defaultSessionCmd = "bash"; })
    (import ./development {inherit pkgs pkgs-stable;})
  ];
  # services.desktopManager.cosmic.enable = true;

  services.blueman.enable = true;
  hardware.bluetooth = {
    enable = true;
    settings = {
      General.Experimental = true;
      Policy.AutoEnable = true;
    };
  };

  # Move some things to user level?
  virtualisation.waydroid.enable = true;
  xdg = {
    mime.enable = true;
    portal.config = {
      common = {
        default = [ "gtk" ];
      };
    };
  };

  xdg.portal.extraPortals = with pkgs; [ xdg-desktop-portal-gtk xdg-desktop-portal ];
  qt = {
    enable = true;
    platformTheme = "kde";
    style = "adwaita-dark";
  };
  xdg.portal.enable = true;
  services.graphical-desktop.enable = true;
  programs.xwayland.enable = true;
  services.xserver.desktopManager.runXdgAutostartIfNone = true;
}
