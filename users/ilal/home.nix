{ config, pkgs, ... }:
{
  home.username = "ilal";
  home.homeDirectory = "/home/ilal";

  xdg = {
    enable = true;
    userDirs = {
      enable = true;
      createDirectories = true;
    };
  };

  home.packages = with pkgs; [
    fastfetch
    foot # Terminal
    lf # file manager
    zed-editor

    # Desktop management
    (dwl.override {
      conf = ./desktop/dwl/config.h;
      enableXWayland = true;
    })
    ulauncher

    # Internet
    aria2 # Downloader
    #floorp # broken 11.14.1

    # misc
    which
    tree

    # nix related
    nix-output-monitor # for 'nom' command (more verbose than 'nix')

    # system monitoring
    btop  # GPU/CPU load monitoring
    iotop # IO monitoring
    iftop # Network monitoring

    # system tools
    pciutils # lspci
    usbutils # lsusb
    brightnessctl
  ];

  # Source/Symlink app specific configs
  home.file.".config/foot/foot.ini".source = ./desktop/foot-terminal.ini;
  home.file.".config/zed/settings.json".source = ./desktop/zed.settings.json;

  programs.git = {
    userName = "Ishansh Lal";
    userEmail = "lalishansh@gmail.com";
    lfs.enable = true;
  };

  programs.bash = {
    enable = true;
    enableCompletion = true;
  };

  programs.firefox.enable = true;

  gtk.enable = true;

  # Config to target compatibility of HomeManager version
  home.stateVersion = "24.05";

  # Let HomeManager install and manage itself
  programs.home-manager.enable = true;
}
