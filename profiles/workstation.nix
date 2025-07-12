{
  config,
  lib,
  pkgs,
  ...
}: {
  meta = {
    name = "workstation";
    description = "Full-featured desktop workstation profile";
    maintainers = ["nixos-unified"];
  };

  imports = [
    ./base.nix
  ];

  # Enable unified modules for workstation use
  unified = {
    # Core functionality
    core = {
      enable = true;
      security.level = "standard";
      performance.enable = true;
    };

    # Desktop environment
    niri = {
      enable = true;
      session.autoStart = true;
      session.displayManager = "greetd";
      features = {
        xwayland = true;
        screensharing = true;
        clipboard = true;
        notifications = true;
      };
      applications = {
        terminal = "foot";
        browser = "firefox";
        launcher = "anyrun";
      };
      theming.enable = true;
    };

    # Development tools
    development = {
      enable = true;
      languages = {
        nix = true;
        rust = true;
        nodejs = true;
        python = true;
      };
      editors = {
        vscode = true;
        helix = true;
        vim = true;
      };
      tools = {
        git = true;
        docker = true;
        virtualization = true;
      };
    };

    # Media capabilities
    media = {
      enable = true;
      audio = {
        pipewire = true;
        bluetooth = true;
      };
      video = {
        mpv = true;
        obs = true;
      };
      graphics = {
        gimp = true;
        inkscape = true;
      };
    };

    # Gaming (optional)
    gaming = {
      enable = lib.mkDefault false;
      steam.enable = lib.mkDefault false;
      performance.gamemode = lib.mkDefault false;
    };

    # Networking
    networking = {
      enable = true;
      wifi = true;
      bluetooth = true;
      firewall = {
        enable = true;
        allowedPorts = [];
      };
    };
  };

  # System services for workstation
  services = {
    # Power management
    upower.enable = true;
    thermald.enable = true;

    # Hardware support
    fwupd.enable = true;
    hardware.bluetooth.enable = true;

    # Printing
    printing = {
      enable = true;
      drivers = with pkgs; [hplip];
    };

    # Location services
    geoclue2.enable = true;

    # Flatpak support
    flatpak.enable = true;
  };

  # Hardware optimizations
  hardware = {
    # Graphics acceleration
    opengl = {
      enable = true;
      driSupport = true;
      driSupport32Bit = true;
    };

    # Audio
    pulseaudio.enable = false; # Using PipeWire

    # Power management
    cpu.intel.updateMicrocode = lib.mkDefault config.hardware.enableRedistributableFirmware;
    cpu.amd.updateMicrocode = lib.mkDefault config.hardware.enableRedistributableFirmware;
  };

  # Essential workstation packages
  environment.systemPackages = with pkgs; [
    # File management
    nautilus
    file-roller

    # Text editors
    gedit

    # Web browsers (fallback)
    firefox

    # Office suite
    libreoffice-fresh

    # Image viewers
    eog
    evince

    # System monitoring
    gnome.gnome-system-monitor
    htop

    # Network tools
    networkmanagerapplet

    # Archive tools
    unzip
    zip
    p7zip

    # Development basics
    git
    curl
    wget

    # Media codecs
    gstreamer
    gst_all_1.gstreamer
    gst_all_1.gst-plugins-base
    gst_all_1.gst-plugins-good
    gst_all_1.gst-plugins-bad
    gst_all_1.gst-plugins-ugly
    gst_all_1.gst-libav
  ];

  # Fonts for better desktop experience
  fonts = {
    packages = with pkgs; [
      # Basic fonts
      dejavu_fonts
      liberation_ttf

      # Programming fonts
      fira-code
      fira-code-symbols

      # System fonts
      noto-fonts
      noto-fonts-cjk
      noto-fonts-emoji

      # Microsoft fonts compatibility
      corefonts
      vistafonts
    ];

    fontconfig = {
      enable = true;
      defaultFonts = {
        serif = ["DejaVu Serif"];
        sansSerif = ["DejaVu Sans"];
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

    mime.enable = true;
    sounds.enable = true;
    icons.enable = true;
  };

  # Security for workstation
  security = {
    rtkit.enable = true;
    polkit.enable = true;

    # Allow users to mount filesystems
    wrappers = {
      fusermount = {
        source = "${pkgs.fuse}/bin/fusermount";
        capabilities = "cap_sys_admin+ep";
      };
    };
  };

  # Networking configuration
  networking = {
    networkmanager = {
      enable = true;
      wifi.powersave = false;
    };

    # Disable dhcpcd as NetworkManager handles DHCP
    dhcpcd.enable = false;

    # Enable Avahi for network discovery
    avahi = {
      enable = true;
      nssmdns4 = true;
      openFirewall = true;
    };
  };

  # User configuration for workstation
  users.users = {
    # Default user template for workstation
    workstation-user = {
      isNormalUser = true;
      extraGroups = [
        "wheel" # sudo access
        "networkmanager" # network management
        "audio" # audio devices
        "video" # video devices
        "docker" # docker access (if enabled)
        "libvirtd" # virtualization (if enabled)
      ];
      shell = pkgs.fish;
    };
  };

  # Programs configuration
  programs = {
    fish.enable = true;
    command-not-found.enable = true;

    # GPG agent
    gnupg.agent = {
      enable = true;
      pinentryPackage = pkgs.pinentry-gtk2;
    };

    # File manager integration
    thunar = {
      enable = true;
      plugins = with pkgs.xfce; [
        thunar-archive-plugin
        thunar-volman
      ];
    };
  };

  # Performance optimizations for desktop
  boot = {
    # Faster boot
    kernelParams = [
      "quiet"
      "splash"
      "loglevel=3"
      "systemd.show_status=auto"
      "rd.udev.log_level=3"
    ];

    # Plymouth for boot splash
    plymouth.enable = true;

    # Kernel selection
    kernelPackages = lib.mkDefault pkgs.linuxPackages_latest;
  };

  # System optimization
  systemd = {
    # Faster startup
    services.NetworkManager-wait-online.enable = false;

    # User services
    user.services = {
      # Auto-mount removable media
      udisks2 = {
        enable = true;
        wantedBy = ["graphical-session.target"];
      };
    };
  };

  # Temporary files cleanup
  boot.tmp = {
    cleanOnBoot = true;
    useTmpfs = lib.mkDefault true;
    tmpfsSize = "50%";
  };
}
