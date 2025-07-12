{
  config,
  lib,
  pkgs,
  inputs,
  ...
}: {
  imports = [
    ../../profiles/qemu.nix
    ../../modules/desktop/niri.nix
  ];

  # Desktop VM configuration
  unified = {
    core = {
      hostname = "nixos-qemu-desktop";
      security.level = "standard";
    };

    qemu = {
      enable = true;
      performance.enable = true;
      guest.enable = true;
      graphics.enable = true;
    };

    niri = {
      enable = true;
      session.displayManager = "greetd";
      features = {
        xwayland = true;
        screensharing = false; # Not needed in VMs
        clipboard = true;
        notifications = true;
      };
      applications = {
        terminal = "foot";
        browser = "firefox";
        launcher = "wofi";
      };
    };
  };

  # Graphics and display for desktop VM
  services = {
    # Display manager for desktop
    greetd = {
      enable = true;
      settings = {
        default_session = {
          command = "${pkgs.greetd.tuigreet}/bin/tuigreet --time --cmd niri-session";
          user = "greeter";
        };
      };
    };

    # Audio system
    pipewire = {
      enable = true;
      alsa.enable = true;
      pulse.enable = true;
    };

    # Input devices
    libinput.enable = true;
  };

  # Hardware for desktop VM
  hardware = {
    # Graphics support
    opengl = {
      enable = true;
      driSupport = true;
    };

    # Audio
    pulseaudio.enable = false; # Using PipeWire
  };

  # Desktop packages
  environment.systemPackages = with pkgs; [
    # Desktop environment
    niri
    waybar
    wofi
    mako

    # Terminal emulators
    foot
    kitty

    # Web browsers
    firefox
    chromium

    # File managers
    nautilus

    # Text editors
    gedit
    vim
    nano

    # Media
    mpv
    imv

    # Utilities
    grim # Screenshots
    slurp # Region selection
    wl-clipboard # Clipboard

    # System tools
    htop
    tree
    git
    curl
    wget

    # Development basics
    vscode

    # Archive tools
    file-roller
    unzip
    zip

    # Graphics
    gimp
    inkscape

    # Office
    libreoffice-fresh

    # Network tools
    networkmanagerapplet
  ];

  # Fonts for desktop
  fonts = {
    packages = with pkgs; [
      noto-fonts
      noto-fonts-cjk
      noto-fonts-emoji
      liberation_ttf
      fira-code
      fira-code-symbols
    ];

    fontconfig = {
      enable = true;
      defaultFonts = {
        serif = ["Noto Serif"];
        sansSerif = ["Noto Sans"];
        monospace = ["Fira Code"];
      };
    };
  };

  # XDG integration
  xdg = {
    portal = {
      enable = true;
      wlr.enable = true;
      config.common.default = "*";
    };
  };

  # Users for desktop VM
  users.users = {
    # Desktop user
    nixos = {
      isNormalUser = true;
      extraGroups = ["wheel" "networkmanager" "audio" "video"];
      password = "nixos"; # pragma: allowlist secret
      description = "NixOS Desktop User";
    };
  };

  # Programs for desktop
  programs = {
    # File manager
    thunar.enable = true;

    # Archive integration
    file-roller.enable = true;

    # Git
    git.enable = true;

    # Fish shell
    fish.enable = true;
  };

  # Security for desktop VM
  security = {
    # Real-time kit for audio
    rtkit.enable = true;

    # Polkit for desktop operations
    polkit.enable = true;
  };

  # Network configuration
  networking = {
    networkmanager = {
      enable = true;
      wifi.powersave = false;
    };

    # Disable dhcpcd as NetworkManager handles DHCP
    dhcpcd.enable = false;
  };

  # File systems optimized for desktop VM
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

    # Larger tmpfs for desktop
    "/tmp" = {
      device = "tmpfs";
      fsType = "tmpfs";
      options = ["defaults" "size=2G" "mode=1777"];
    };
  };

  # Desktop VM optimizations
  boot = {
    # Desktop kernel with graphics support
    kernelPackages = pkgs.linuxPackages_latest;

    # Graphics and input modules
    kernelModules = [
      "virtio_balloon"
      "virtio_console"
      "virtio_net"
      "virtio_blk"
      "virtio_gpu"
      "virtio_input"
    ];

    # Desktop kernel parameters
    kernelParams = [
      "quiet"
      "splash"
      "loglevel=3"
    ];
  };

  # Desktop performance tuning
  boot.kernel.sysctl = {
    # Desktop responsiveness
    "vm.swappiness" = 10;
    "vm.dirty_background_ratio" = 10;
    "vm.dirty_ratio" = 20;

    # Audio latency
    "dev.hpet.max-user-freq" = 3072;
  };

  # Nix configuration for desktop
  nix = {
    settings = {
      max-jobs = 2;
      cores = 2;
      auto-optimise-store = true;
    };

    gc = {
      automatic = true;
      dates = "weekly";
      options = "--delete-older-than 7d";
    };
  };

  # Enable documentation for desktop
  documentation = {
    enable = true;
    nixos.enable = true;
    man.enable = true;
  };
}
