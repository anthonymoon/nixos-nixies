{
  config,
  lib,
  pkgs,
  inputs,
  ...
}: {
  imports = [
    ../../profiles/qemu.nix
  ];

  # Override base configuration for minimal VM
  unified = {
    core = {
      hostname = "nixos-qemu-minimal";
      security.level = "basic";
    };

    qemu = {
      enable = true;
      performance.enable = true;
      guest.enable = true;
    };
  };

  # Minimal package set for small VM footprint
  environment.systemPackages = with pkgs; [
    # Essential system tools
    vim
    nano
    htop
    tree

    # Network utilities
    curl
    wget
    ping

    # System utilities
    file
    which
    uname

    # Development basics
    git
  ];

  # Disable unnecessary services
  services = {
    # No printing in minimal VM
    printing.enable = lib.mkForce false;

    # No Bluetooth
    bluetooth.enable = lib.mkForce false;

    # No audio services
    pipewire.enable = lib.mkForce false;
    pulseaudio.enable = lib.mkForce false;

    # No desktop services
    displayManager.gdm.enable = lib.mkForce false;
    desktopManager.gnome.enable = lib.mkForce false;

    # Minimal logging
    journald.settings = {
      SystemMaxUse = "50M";
      SystemMaxFileSize = "5M";
      SystemKeepFree = "100M";
    };
  };

  # Disable hardware not present in VMs
  hardware = {
    bluetooth.enable = lib.mkForce false;
    pulseaudio.enable = lib.mkForce false;

    # Basic graphics only
    opengl = {
      enable = true;
      driSupport = false;
      driSupport32Bit = false;
    };
  };

  # Minimal users setup
  users.users = {
    # Single user for minimal VM
    nixos = {
      isNormalUser = true;
      extraGroups = ["wheel"];
      password = "nixos"; # pragma: allowlist secret
      description = "NixOS VM User";
    };
  };

  # Console-only interface
  console = {
    keyMap = "us";
    font = "Lat2-Terminus16";
  };

  # Aggressive power management for VMs
  powerManagement = {
    enable = true;
    cpuFreqGovernor = "powersave";
  };

  # Minimal file systems
  fileSystems = {
    "/" = {
      device = "/dev/disk/by-label/nixos";
      fsType = "ext4";
      options = ["noatime" "nodiratime"];
    };

    "/boot" = {
      device = "/dev/disk/by-label/boot";
      fsType = "vfat";
    };
  };

  # Small swap for minimal RAM usage
  swapDevices = [
    {
      device = "/dev/disk/by-label/swap";
      priority = 100;
    }
  ];

  # System optimizations for minimal VM
  boot = {
    # Fast boot
    loader.timeout = 0;

    # Minimal kernel
    kernelPackages = pkgs.linuxPackages;

    # Essential kernel modules only
    kernelModules = [
      "virtio_balloon"
      "virtio_console"
      "virtio_net"
      "virtio_blk"
    ];

    # Memory optimization
    kernel.sysctl = {
      "vm.swappiness" = 60; # Use swap more aggressively in minimal VM
      "vm.dirty_background_ratio" = 2;
      "vm.dirty_ratio" = 5;
    };
  };

  # Minimal Nix configuration
  nix = {
    settings = {
      max-jobs = 1;
      cores = 1;
      auto-optimise-store = true;
    };

    gc = {
      automatic = true;
      dates = "daily";
      options = "--delete-older-than 1d";
    };
  };

  # Documentation
  documentation = {
    enable = lib.mkDefault false;
    nixos.enable = lib.mkDefault false;
    man.enable = lib.mkDefault false;
    info.enable = lib.mkDefault false;
  };
}
