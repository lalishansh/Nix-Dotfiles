{ config, pkgs, lib, ... }:
{
  xdg = {
    enable = true;
    portal = {
      enable = true;
      extraPortals = with pkgs; [ xdg-desktop-portal-gtk xdg-desktop-portal-wlr ];
      config.common = {
        default = [ "gtk" ];
        "org.freedesktop.impl.portal.Secret" = [ "gnome-keyring" ];
      };
      xdgOpenUsePortal = true;
    };
    userDirs = { enable = true; createDirectories = true; };
  };

  home.sessionVariables = {
    NIXOS_OZONE_WL = "1";
  };

  # xsession = { # this is not xsession, it's wayland session
  #   windowManager.command = "${lib.getExe pkgs.dwl}";
  #   initExtra = "";
  # };

  home.packages = with pkgs; [
    (dwl.override {
      conf = ./dwl/config.h;
      enableXWayland = true;
    })

    rofi-wayland-unwrapped
    #(writeShellScriptBin "cliphist-rofi" (builtins.readFile ./rofi/scripts/cliphist-rofi-img))

    gnome-keyring
  ];

  home.file.".config/rofi/config.rasi".source = ./rofi/config.rasi;
  home.file.".config/rofi/mytheme.rasi".source = ./rofi/mytheme.rasi;
}