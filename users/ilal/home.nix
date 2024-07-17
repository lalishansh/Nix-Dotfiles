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

    # nix related
    nix-output-monitor # for 'nom' command (more verbose than 'nix')

    # system monitoring
    btop # GPU/CPU load monitoring
    iotop # IO monitoring
    iftop # Network monitoring

    # system tools
    pciutils # lspci
    usbutils # lsusb
    brightnessctl
    playerctl
    dconf
    xdg-utils

    wl-clipboard
    wl-screenrec
    wlr-randr
    cliphist
  ];

  programs = {
    ssh = {
      enable = true;
      package = pkgs.gnome-keyring; # system-pkg
      extraConfig = "
        Host github.com
          User git
          IdentityFile ~/.ssh/github
          PreferredAuthentications publickey
      ";
    };
    git = {
      userName = "Ishansh Lal";
      userEmail = "lalishansh@gmail.com";
      lfs.enable = true;
    };

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
  services.kdeconnect.enable = true;

  # Config to target compatibility of HomeManager version
  home.stateVersion = "24.05";

  # Let HomeManager install and manage itself
  programs.home-manager.enable = true;
}
