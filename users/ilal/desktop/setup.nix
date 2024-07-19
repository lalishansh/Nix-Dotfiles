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
    # TESTING
    # (import ./dwl/pkg.nix)

    (dwl.override {
      conf = builtins.readFile (pkgs.substituteAll {
        src = ./dwl/config.h;
        termcmd = "\"${lib.getExe pkgs.foot}\"";
        menucmd = "\"${lib.getExe pkgs.rofi}\", \"-show\"";
      });
      enableXWayland = true;
    })

    rofi-wayland-unwrapped
    #(writeShellScriptBin "cliphist-rofi" (builtins.readFile ./rofi/scripts/cliphist-rofi-img))

    # cliphist
    gnome-keyring
  ];

  home.file.".config/rofi/config.rasi".source = ./rofi/config.rasi;
  home.file.".config/rofi/mytheme.rasi".source = ./rofi/mytheme.rasi;
}
