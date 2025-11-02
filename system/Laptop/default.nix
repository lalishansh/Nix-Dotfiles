{ config, lib, pkgs, ... }:
{
  imports = [
    ../shared
  ];

  # TODO: move to nvidia.nix
  boot.initrd.kernelModules = [ "nvidia" ];
  hardware.graphics.enable = true;   # Enable OpenGL
  services.xserver.videoDrivers = [ "nvidia" ]; # Load nvidia driver for Xorg and Wayland
  hardware.nvidia = {
    # Modesetting is required.
    modesetting.enable = true;

    powerManagement.enable = true;
    powerManagement.finegrained = true;

    open = true;

    nvidiaSettings = true;

    prime = {
      offload = {
        enable = true;
        enableOffloadCmd = true;
      };
  		# Make sure to use the correct Bus ID values for your system!
      amdgpuBusId = "PCI:0:6:0";
  		#intelBusId = "PCI:0:2:0";
  		nvidiaBusId = "PCI:0:1:0";
  	};
  };
  # END TODO

  nixpkgs.config.allowUnfree = true;

  # Connectivity
  networking = {
    networkmanager.enable = true;
    extraHosts = # fuck you jio
      ''
        185.199.108.133 raw.githubusercontent.com
      '';
    firewall = {
      enable = true;
      # Source (https://github.com/NixOS/nixpkgs/blob/nixos-25.05):
      # - [for steam](nixos/modules/programs/steam.nix)
      # - [for kdeconnect](nixos/modules/programs/kdeconnect.nix)
      allowedUDPPortRanges = [
        { from = 1714; to = 1764; } # KDE-Connect
        { from = 27031; to = 27035; } # Steam: for remote play
      ];
      allowedTCPPortRanges = [
        { from = 1714; to = 1764; } # For KDE-Connect
      ];
      allowedUDPPorts = [
        27036 # Steam: for peer discovery (local game transfers and remote play)
        27015 # Steam: dedicated server gameplay traffic
      ];
      allowedTCPPorts = [
        27036 # Steam: for remote play
        27040 # Steam: for local game transfers
        27015 # Steam: dedicated server SRCDS Rcon port
      ];
    };
  };

  # Configure keymap in X11
  services.xserver.xkb = {
    layout = "us";
    variant = "";
  };

  # Environment
  environment.sessionVariables = {
    # For wayland in electron apps
    NIXOS_OZONE_WL = "1";
    MOZ_ENABLE_WAYLAND = "1";
  };
  programs.ccache.enable = true; # system-wide, for C/C++ incremental builds in recompile of packages

  # Audio with pipewire
  services.pulseaudio.enable = false;
  security.rtkit.enable = true;
  services.pipewire = {
    enable = true;
    alsa.enable = true;
    alsa.support32Bit = true;
    pulse.enable = true;
    wireplumber.enable = true;
  };

  # For virtual devices
  hardware.uinput.enable = true; # enables uinput kernel modules
  hardware.steam-hardware.enable = true; # Basically steam-controller etc. as virtual devices

  # Other Services
  security.polkit.enable = true; # toolkit to manage policy that allows unprivileged processes to speak to privileged processes
  services = {
    libinput.enable = true;
    thermald.enable = true;
    upower.enable = true;
    printing.enable = true;
    # acpid.enable = true; # daemon for delivering ACPI events basically powerbutton events etc.
    fwupd.enable = true; # enable firmware updates by applications
    gnome.gnome-keyring.enable = true; # Gnome Keyring, used for credential storage
  };
}
