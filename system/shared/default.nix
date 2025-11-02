{ config, pkgs, lib, ... }:
{
  imports = [
    ./options
  ];

  # Bootloader
  boot = {
    loader = {
      efi.canTouchEfiVariables = true;
      # Limit the number of system generations to keep/show on systemd
      systemd-boot = {
        enable = true;
        configurationLimit = 12;
      };
    };
    kernelPackages = pkgs.linuxPackages_latest;
    supportedFilesystems = [
      "ntfs"
      "nfs"
    ];
  };

  # NixOS Management
  nix = {
    settings = {
      experimental-features = [
        "nix-command"
        "flakes"
      ];
      # auto-optimise-store = true; # slows down rebuilds quite a bit
      trusted-users = [
        "root"
        "@wheel"
      ];
    };
    gc = {
      automatic = true;
      dates = "weekly";
      options = "--delete-older-than 15d";
    };
    optimise.automatic = true;
  };

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

  # Misc
  console.useXkbConfig = true;
  fonts = {
    fontDir.enable = true;
    packages = with pkgs; [
      material-design-icons
      material-symbols
      nerd-fonts.caskaydia-cove
      source-code-pro
    ];
  };
  environment.localBinInPath = true;

  # Enable login/display manager tuigreet
  services.greetd = {
    enable = true;
    settings.default_session = {
      command = "${lib.getExe pkgs.tuigreet} --time --greeting 'GREETINGS !' --cmd '${config.shared.defaultSessionCmdFile}' --remember --user-menu --theme border=magenta;text=cyan;prompt=green;time=red;action=blue;button=yellow;container=black;input=red";
      user = "greeter"; # Required
    };
  };
  # this is a life saver.
  # literally no documentation about this anywhere.
  # might be good to write about this...
  # https://www.reddit.com/r/NixOS/comments/u0cdpi/tuigreet_with_xmonad_how/
  systemd.services.greetd.serviceConfig = {
    Type = "idle";
    StandardInput = "tty";
    StandardOutput = "tty";
    # Without this errors will spam on screen
    StandardError = "journal";
    # Without these bootlogs will spam on screen
    TTYReset = true;
    TTYVHangup = true;
    TTYVTDisallocate = true;
  };

  system.autoUpgrade = {
    enable = true;
    operation = "switch";
    dates = "weekly";
    flags = [ "--recreate-lock-file -L" ];
    # To see the status of the timer run
    # $ systemctl status nixos-upgrade.timer
    # The upgrade log can be printed with this command
    # $ systemctl status nixos-upgrade.service
  };

  # This value determines the NixOS release from which the default
  # settings for stateful data, like file locations and database versions
  # on your system were taken. It‘s perfectly fine and recommended to leave
  # this value at the release version of the first install of this system.
  # Before changing this value read the documentation for this option
  # (e.g. man configuration.nix or on https://nixos.org/nixos/options.html).
  system.stateVersion = "25.05";
}
