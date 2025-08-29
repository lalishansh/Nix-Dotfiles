{ inputs, pkgs, lib, ... }:
let
  terminal = "kitty";
in
{
  defaultSessionCmd = "${lib.getExe pkgs.hyprland}";
  packages = with pkgs; [
    kitty
    hyprland

    # dependencies
    matugen

    # quickshell dependencies
    # 01.audio
    cava
    lxqt.pavucontrol-qt
    wireplumber
    libdbusmenu-gtk3
    playerctl

    # 02.backlight
    brightnessctl
    ddcutil

    # 03.basic
    axel
    bc
    # coreutils
    cliphist
    # cmake
    curl
    rsync
    wget
    ripgrep
    jq
    # meson
    xdg-user-dirs

    # 04.bibata-modern-classic-bin

    # 05.fonts-themes
    adw-gtk3
    #   breeze-plus #TODO need monaula install
    eza
    # fish
    # fontconfig
    python313Packages.kde-material-you-colors
    # kitty
    # matugen
    # starship
    # ttf-readex-pro #TODO need monaula install
    # ttf-jetbrains-mono-nerd
    # material-symbols
    # rubik
    # inputs.nur.legacyPackages."${system}".repos.skiletro.gabarito
    # # selfPkgs.illogical-impulse-oneui4-icons

    # 06.hyprland
    wl-clipboard
    # hypridle
    # hyprcursor
    # hyprland
    # hyprland-qtutils
    # hyprland-qt-support
    # hyprlang
    # hyprlock
    # hyprpicker
    # hyprsunset
    # hyprutils
    # hyprwayland-scanner
    # xdg-desktop-portal-hyprland

    # 07.kde
    kdePackages.bluedevil
    gnome-keyring
    # networkmanager # normal handel with nixos services
    kdePackages.plasma-nm
    kdePackages.polkit-kde-agent-1

    # 08.microtex-git

    # 09.oneui4-icons-git

    # 10.portal

    # 11.python
    libsoup_3
    libportal-gtk4
    gobject-introspection
    sassc
    opencv
    (python3.withPackages (python-pkgs: with python-pkgs; [
      build
      pillow
      setuptools-scm
      wheel
      pywayland
      psutil
      materialyoucolor
      libsass
      material-color-utilities
      setproctitle
    ]))

    # 12.screencapture
    hyprshot
    slurp
    swappy
    tesseract
    wf-recorder

    # 13.toolkit
    upower
    wtype
    ydotool
    kdePackages.kdialog
    kdePackages.qt5compat
    kdePackages.qtbase
    kdePackages.qtdeclarative
    kdePackages.qtdeclarative
    kdePackages.qtimageformats
    kdePackages.qtmultimedia
    kdePackages.qtpositioning
    kdePackages.qtquicktimeline
    kdePackages.qtsensors
    kdePackages.qtsvg
    kdePackages.qttools
    kdePackages.qttranslations
    kdePackages.qtvirtualkeyboard
    kdePackages.qtwayland
    kdePackages.syntax-highlighting

    # 14.widgets
    glib
    swww
    translate-shell
    wlogout
    quickshell
    #inputs.quickshell.packages.${pkgs.system}.default
  ];
  path.".config/kitty".copy = ./illogical-impulse-end4-kitty;
  path.".config/hypr".copy = ./illogical-impulse-end4-hyprland;
  path.".config/matugen".copy = ./illogical-impulse-end4-matugen;
  path.".config/quickshell".copy = ./illogical-impulse-end4-quickshell;
}
