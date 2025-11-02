{ config, pkgs, lib, ... }: let
  readDirPaths = dir:
      map (name: "${dir}/${name}") (builtins.attrNames (builtins.readDir dir));
in {
  defaultSessionCmd = "${lib.getExe pkgs.cosmic-session}";
  # Src: https://github.com/NixOS/nixpkgs/blob/nixos-unstable/nixos/modules/services/desktop-managers/cosmic.nix
  packages = with pkgs; [
    # Core cosmic packages
    cosmic-applets
    cosmic-applibrary
    cosmic-bg
    cosmic-comp
    cosmic-files
    cosmic-greeter
    cosmic-idle
    cosmic-initial-setup
    cosmic-launcher
    cosmic-notifications
    cosmic-osd
    cosmic-panel
    cosmic-session
    cosmic-settings
    cosmic-settings-daemon
    cosmic-workspaces-epoch
  ] ++ [
    # XWayland dependencies
    xwayland
  ] ++ [
    # Other useful packages
    adwaita-icon-theme
    alsa-utils
    cosmic-icons
    cosmic-randr
    cosmic-screenshot
    cosmic-wallpapers
    glib
    hicolor-icon-theme
    networkmanagerapplet
    playerctl
    pop-icon-theme
    pop-launcher
    pulseaudio
    xdg-user-dirs

    kitty
  ];

  # Note:
  # * For some reason cosmic-initial-setup is not picking up these env vars,
  #   so press Super/Win+Q to kill it, then launch it from terminal
  home_dir.".profile".text = ''
    # XKB configuration for Cosmic
    export X11_BASE_RULES_XML=${config.services.xserver.xkb.dir}/rules/base.xml
    export X11_EXTRA_RULES_XML=${config.services.xserver.xkb.dir}/rules/base.extras.xml
  '';

  # Cosmic Data dir is designed by a narcissist, why not just let cosmic-settings have it all.
  data_dir."cosmic/com.system76.CosmicSettings.WindowRules".source = "${pkgs.cosmic-comp.outPath}/share/cosmic/com.system76.CosmicSettings.WindowRules";
  data_dir."cosmic/com.system76.CosmicSettings.Shortcuts/v1".directory
    =  readDirPaths "${pkgs.cosmic-settings-daemon.outPath}/share/cosmic/com.system76.CosmicSettings.Shortcuts/v1"
    ++ readDirPaths "${pkgs.cosmic-comp.outPath}/share/cosmic/com.system76.CosmicSettings.Shortcuts/v1"
  ;
  data_dir."cosmic".directory
    =  readDirPaths "${pkgs.cosmic-bg.outPath}/share/cosmic"
    ++ readDirPaths "${pkgs.cosmic-settings.outPath}/share/cosmic"
    ++ readDirPaths "${pkgs.cosmic-applets.outPath}/share/cosmic"
  ;
  data_dir."cosmic-layouts".directory =  readDirPaths "${pkgs.cosmic-initial-setup.outPath}/share/cosmic-layouts";
  data_dir."cosmic-themes".directory = readDirPaths "${pkgs.cosmic-initial-setup.outPath}/share/cosmic-themes";
  data_dir."backgrounds".directory = readDirPaths "${pkgs.cosmic-wallpapers.outPath}/share/backgrounds";

  # Notes:
  # * Needs services.graphical-desktop.enable = true;
  # * maybe programs.dconf.packages = [ pkgs.cosmic-session ]; # etc.
}
