{ config, pkgs, lib, ... }:
{
  home.username = "ilal";
  home.homeDirectory = "/home/ilal";

  imports = [
    ./desktop/setup.nix
    ./common/app-defaults.nix
  ];

  home.packages = with pkgs; [
    which
    tree
    fastfetch

    # Desktop
    foot
    warp-terminal
    (nerdfonts.override { fonts = [ "CascadiaCode" "DroidSansMono" ]; })

    # Dev
    ruby
    clang
    clang-tools
    nodePackages.npm

    # Tools
    bitwarden
    adbtuifm

    # nix related
    nix-output-monitor # for 'nom' command (more verbose than 'nix')

    # system monitoring
    btop # GPU/CPU load monitoring
    iotop # IO monitoring
    iftop # Network monitoring

    # system tools
    pciutils # lspci
    usbutils # lsusb
    playerctl
    dconf
    xdg-utils

    wl-clipboard
    wl-screenrec
    wlr-randr
  ];

  programs = {
    bash = {
      enable = true;
      enableCompletion = true;
    };
  };

  gtk = {
    enable = true;
    theme = { name = "Adwaita"; package = pkgs.gnome-themes-extra; };
  };
  qt = {
    enable = true;
    style = { name = "adwaita-dark"; package = pkgs.adwaita-qt; };
  };

  services.cliphist.enable = true;

  # Config to target compatibility of HomeManager version
  home.stateVersion = "24.05";

  # Let HomeManager install and manage itself
  programs.home-manager.enable = true;
}
