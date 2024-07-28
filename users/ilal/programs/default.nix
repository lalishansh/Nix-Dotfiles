{ config, pkgs, lib, ... }:
{
  imports = [
    ./default-apps
  ];

  home.packages = with pkgs; [
    which
    tree
    fastfetch

    # Desktop
    warp-terminal

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
}
