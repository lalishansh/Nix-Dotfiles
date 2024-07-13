{ config, pkgs, lib, ... }:
{
  home.username = "ilal";
  home.homeDirectory = "/home/ilal";

  xdg = {
    enable = true;
    portal = {
      enable = true;
      extraPortals = with pkgs; [ xdg-desktop-portal-gtk xdg-desktop-portal-wlr ];
      config.common.default = [ "*" ];
      xdgOpenUsePortal = true;
    };
    userDirs = { enable = true; createDirectories = true; };
  };

  home.sessionVariables = {
    NIXOS_OZONE_WL = "1";
  };

  xsession = {
    windowManager.command = "${lib.getExe pkgs.dwl}";
    initExtra = "
    eval $(gnome-keyring-daemon -r -c pkcs11,secrets);
    ";
  };

  home.packages = with pkgs; [
    which
    tree
    fastfetch

    # Desktop
    (dwl.override {
      conf = ./desktop/dwl/config.h;
      enableXWayland = true;
    })
    foot
    warp-terminal
    (nerdfonts.override { fonts = [ "CascadiaCode" "DroidSansMono" ]; })

    # Dev
    ruby
    llvm_18
    typst

    # Tools
    lf
    feh
    amfora # Gemini, geminiquickst.art
    mpv
    bitwarden
    gnome-keyring
    zed-editor
    # (vscode-with-extensions.override { # zed is better
    #   vscode = vscodium;
    #   vscodeExtensions = with vscode-extensions; [
    #     pkief.material-product-icons
    #     pkief.material-icon-theme
    #     bbenoist.nix
    #     aaron-bond.better-comments
    #     esbenp.prettier-vscode
    #     yzhang.markdown-all-in-one
    #     myriad-dreamin.tinymist
    #     github.copilot
    #     github.copilot-chat
    #   ] ++ pkgs.vscode-utils.extensionsFromVscodeMarketplace [
    #   ];
    # })

    # Internet
    aria2  # Downloader
    ariang # aria2 frontend
    #floorp# broken 11.14.1

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
    playerctl
    dconf

    wl-clipboard
    wl-screenrec
    wlr-randr
  ];

  programs = {
    git = {
      userName = "Ishansh Lal";
      userEmail = "lalishansh@gmail.com";
      lfs.enable = true;
    };

    bash = {
      enable = true;
      enableCompletion = true;
    };

    rofi = {
      enable = true;
      terminal = "${lib.getExe pkgs.foot}";
      location = "center";
      cycle = true;
      configPath = "~/.config/rofi/config.rasi";
      package = pkgs.rofi-wayland;
    };

    firefox.enable = true;
  };

  gtk = {
    enable = true;
    theme = { name = "Adwaita"; package = pkgs.gnome-themes-extra; };
  };
  qt = {
    enable = true;
    style = { name = "adwaita-dark"; package = pkgs.adwaita-qt; };
  };

  # Copy app specific configs, for symlinks use `config.lib.file.mkOutOfStoreSymlink + <path>` instead of <path>
  home.file = {
    ".config/foot/foot.ini".source = ./desktop/foot-terminal.ini;
    ".config/zed/settings.json".source = ./desktop/zed.settings.json;
    ".config/rofi" = { source = ./desktop/rofi; recursive = true; };
    ".config/aria2/aria2.conf".source = ./common/aria2.conf;
  };

  services = {
    ssh-agent.enable = true;
    gnome-keyring = {
      enable = true;
      components = [ "pkcs11" "secrets" ];
    };
    # aria2 = {
    #   enable = true;
    #   conf-path = "~/.config/aria2/aria2.conf";
    #   save-session = "~/Downloads/.aria2/aria2.session";
    # };
  };
  programs.ssh = {
    enable = true;
    extraConfig = "
      Host github.com
        User git
        IdentityFile ~/.ssh/github
        PreferredAuthentications publickey
    ";
  };

  # Config to target compatibility of HomeManager version
  home.stateVersion = "24.05";

  # Let HomeManager install and manage itself
  programs.home-manager.enable = true;
}
