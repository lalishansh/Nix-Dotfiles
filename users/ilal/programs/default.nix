{ config, pkgs, lib, ... }:
{
  imports = [
    ./common
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
}
