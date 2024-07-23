{ config, pkgs, lib, ... }:
{
  imports =
    [
      # Include the results of the hardware scan.
      ./hardware.nix
    ];

  # Bootloader.
  boot.loader.systemd-boot.enable = true;
  boot.loader.efi.canTouchEfiVariables = true;

  # Limit the number of system generations to keep
  boot.loader.systemd-boot.configurationLimit = 10;

  networking.hostName = "NixOS-Laptop"; # Hostname, will be used by/in `nixosConfigurations.<hostName>`
  networking.networkmanager.enable = true; # Enable networkmanager

  # Set your time zone.
  time.timeZone = "Asia/Kolkata";

  # Select internationalisation properties.
  i18n.defaultLocale = "en_IN";
  i18n.extraLocaleSettings = {
    LC_ADDRESS = "en_IN";
    LC_IDENTIFICATION = "en_IN";
    LC_MEASUREMENT = "en_IN";
    LC_MONETARY = "en_IN";
    LC_NAME = "en_IN";
    LC_NUMERIC = "en_IN";
    LC_PAPER = "en_IN";
    LC_TELEPHONE = "en_IN";
    LC_TIME = "en_IN";
  };

  services = {
    # Configure keymap in X11
    xserver.xkb = { layout = "us"; variant = ""; };
    libinput.touchpad.naturalScrolling = true;
    gnome.gnome-keyring.enable = true;
    greetd = {
      enable = true;
      settings.default_session = {
        command = "${lib.getExe pkgs.greetd.tuigreet} -t -g '¯\_(⌐■ ͜-■)_/¯ ♬♪✧' -r --remember-user-session -s ${config.services.displayManager.sessionData.desktops}/share/wayland-sessions:${config.services.displayManager.sessionData.desktops}/share/xsessions --theme border=magenta;text=cyan;prompt=green;time=red;action=blue;button=yellow;container=black;input=red";
        user = "greeter";
      };
    };
    pipewire = {
      enable = true;
      alsa.enable = true;
      alsa.support32Bit = true;
      pulse.enable = true;
      wireplumber.enable = true;
      jack.enable = true;
      systemWide = false;
    };
  };

  nixpkgs.config.allowUnfree = true;
  nix = {
    settings.experimental-features = [ "nix-command" "flakes" ]; # Enable flakes support
    settings.auto-optimise-store = true; # Store is optimised during every build (This may/will slow down builds)
    settings.warn-dirty = false;
    gc = {
      # Garbage collection
      automatic = true;
      dates = "weekly";
      options = "--delete-older-than 30d";
    };
  };

  # To search, run:
  # $ nix search wget
  environment.systemPackages = with pkgs; [
    neovim
  ];

  fonts = {
    fontDir.enable = true;
    packages = with pkgs; [
      source-code-pro
    ];
  };

  security.polkit.enable = true;
  hardware.graphics.enable = true;
  security.rtkit.enable = true;

  programs = {
    adb.enable = true;
    dconf.enable = true; # for gtk
    git = {
      enable = true;
      package = pkgs.gitFull;
      config.credential.helper = "libsecret";
    };
    nix-ld = {
      enable = true;
      package = pkgs.nix-ld-rs;
      libraries = with pkgs; [
        SDL
        SDL2
        SDL2_image
        SDL2_mixer
        SDL2_ttf
        SDL_image
        SDL_mixer
        SDL_ttf
        alsa-lib
        at-spi2-atk
        at-spi2-core
        atk
        cairo
        cups
        curl
        dbus
        fontconfig
        freetype
        fuse3
        gdk-pixbuf
        glib
        gtk3
        icu
        libGL
        libappindicator-gtk3
        libdrm
        libglvnd
        libnotify
        libpulseaudio
        libunwind
        libusb1
        libuuid
        libxkbcommon
        libxml2
        mesa
        nspr
        openssl
        pango
        pipewire
        stdenv.cc.cc
        systemd
        vulkan-loader
        wayland
        xz
        zlib
      ];
    };
  };

  system.autoUpgrade = {
    enable = true;
    dates = "weekly";
    rebootWindow = { lower = "01:00"; upper = "05:00"; };
  };

  # This value determines the NixOS release from which the default
  # settings for stateful data, like file locations and database versions
  # on your system were taken. It‘s perfectly fine and recommended to leave
  # this value at the release version of the first install of this system.
  # Before changing this value read the documentation for this option
  # (e.g. man configuration.nix or on https://nixos.org/nixos/options.html).
  system.stateVersion = "24.05"; # Did you read the comment?
}
