{
  config,
  lib,
  pkgs,
  ...
}: {
  meta = {
    name = "home-desktop";
    description = "Bleeding-edge home desktop profile with gaming, development, and media production capabilities";
    maintainers = ["nixos-unified"];
    tags = ["home" "desktop" "gaming" "bleeding-edge" "development" "media"];
  };

  imports = [
    ./base.nix
  ];

  # Home desktop unified configuration
  unified = {
    # Core with bleeding-edge optimizations
    core = {
      enable = true;
      security.level = "standard"; # Balanced security for home use
      performance.enable = true;
      performance.profile = "gaming"; # Gaming-optimized performance
      stability.channel = "bleeding-edge"; # Use latest packages
    };

    # Modern desktop environment
    desktop = {
      enable = true;
      environment = "niri"; # Modern scrollable tiling compositor
      wayland = true;
      bleeding-edge = true;
      gaming-optimized = true;
    };

    # Gaming configuration
    gaming = {
      enable = true;

      # Steam platform
      steam = {
        enable = true;
        proton.enable = true;
        proton.version = "latest";
        remote-play.enable = true;
        vr.enable = true;
      };

      # Performance optimization
      performance = {
        gamemode = true;
        mangohud = true;
        corectrl = true;
        latency-optimization = true;
        cpu-governor = "performance";
      };

      # Game launchers and stores
      launchers = {
        lutris = true;
        heroic = true;
        bottles = true;
        itch = true;
        gog = true;
      };

      # Emulation
      emulation = {
        retroarch = true;
        dolphin = true;
        yuzu = true;
        rpcs3 = true;
        pcsx2 = true;
        ppsspp = true;
      };

      # Streaming and recording
      streaming = {
        enable = true;
        obs = true;
        sunshine = true;
        discord = true;
      };

      # RGB and peripherals
      peripherals = {
        openrgb = true;
        gaming-controllers = true;
        racing-wheels = true;
        flight-controls = true;
      };
    };

    # Development environment
    development = {
      enable = true;
      bleeding-edge = true;

      # Languages and runtimes
      languages = {
        rust = true;
        python = true;
        nodejs = true;
        go = true;
        java = true;
        cpp = true;
        dotnet = true;
        haskell = true;
      };

      # Editors and IDEs
      editors = {
        vscode = true;
        neovim = true;
        jetbrains-suite = true;
        emacs = true;
      };

      # Tools and utilities
      tools = {
        git = true;
        docker = true;
        podman = true;
        kubernetes = true;
        terraform = true;
        ansible = true;
        vagrant = true;
      };

      # Databases
      databases = {
        postgresql = true;
        mysql = true;
        redis = true;
        mongodb = true;
      };
    };

    # Media production
    media = {
      enable = true;
      bleeding-edge = true;

      # Video editing
      video = {
        davinci-resolve = true;
        kdenlive = true;
        blender = true;
        obs-studio = true;
        handbrake = true;
      };

      # Audio production
      audio = {
        ardour = true;
        reaper = true;
        bitwig = true;
        audacity = true;
        carla = true;
        jack = true;
        low-latency = true;
      };

      # Graphics and design
      graphics = {
        gimp = true;
        inkscape = true;
        krita = true;
        darktable = true;
        rawtherapee = true;
        hugin = true;
      };

      # 3D modeling and animation
      modeling = {
        blender = true;
        freecad = true;
        openscad = true;
        meshlab = true;
      };
    };

    # Hardware optimization
    hardware = {
      enable = true;
      bleeding-edge = true;
      gaming = true;
      content-creation = true;

      # Graphics optimization
      graphics = {
        acceleration = true;
        vulkan = true;
        opencl = true;
        cuda = true;
        multi-gpu = true;
        vr-ready = true;
      };

      # Audio optimization
      audio = {
        professional = true;
        low-latency = true;
        jack-support = true;
        usb-audio = true;
      };

      # Storage optimization
      storage = {
        nvme-optimization = true;
        ssd-optimization = true;
        raid-support = true;
      };
    };

    # Networking
    networking = {
      enable = true;
      gaming-optimized = true;
      development-tools = true;

      # Gaming network optimization
      gaming = {
        low-latency = true;
        qos = true;
        port-forwarding = true;
      };

      # VPN and privacy
      privacy = {
        wireguard = true;
        tor = true;
        i2p = true;
      };
    };

    # Security for home use
    security = {
      home = {
        enable = true;
        privacy-focused = true;
        anti-malware = true;
        firewall = true;
        secure-boot = true;
      };
    };
  };

  # Use bleeding-edge packages
  nixpkgs = {
    config = {
      allowUnfree = true; # Gaming and proprietary software
      allowInsecure = false;
      allowBroken = false;
      permittedInsecurePackages = []; # Minimize security risks
    };
  };

  # Bleeding-edge boot configuration
  boot = {
    # Latest kernel for cutting-edge hardware support
    kernelPackages = pkgs.linuxPackages_latest;

    # Gaming and performance kernel parameters
    kernelParams = [
      # CPU performance
      "processor.max_cstate=1"
      "intel_idle.max_cstate=1"
      "intel_pstate=performance"

      # Memory optimization
      "transparent_hugepage=never"
      "vm.swappiness=1"

      # Gaming-specific optimizations
      "preempt=voluntary"
      "rcu_nocbs=0-7" # Adjust based on CPU cores

      # GPU optimizations
      "nvidia-drm.modeset=1" # For NVIDIA users
      "amdgpu.dc=1" # For AMD users

      # Audio low-latency
      "threadirqs"

      # Network performance
      "net.core.default_qdisc=fq_codel"
      "net.ipv4.tcp_congestion_control=bbr"

      # Reduce boot time
      "quiet"
      "splash"
      "loglevel=3"
      "rd.systemd.show_status=false"
      "rd.udev.log_level=3"
      "udev.log_priority=3"
    ];

    # Fast boot configuration
    loader = {
      systemd-boot = {
        enable = true;
        configurationLimit = 10;
        editor = false; # Security
      };
      efi.canTouchEfiVariables = true;
      timeout = 1; # Quick boot for gaming/development
    };

    # Modern init system optimizations
    initrd = {
      systemd.enable = true; # Faster boot with systemd in initrd
      availableKernelModules = [
        # Fast storage
        "nvme"
        "xhci_pci"
        "ahci"
        "usbhid"
        "usb_storage"
        "sd_mod"
        # Gaming controllers
        "uinput"
        "hid_generic"
        "hid_sony"
        "hid_microsoft"
        # VR devices
        "uvcvideo"
        "snd_usb_audio"
      ];
    };

    # Enable experimental features
    extraModulePackages = with config.boot.kernelPackages; [
      # Latest graphics drivers
      nvidia_x11
      # Gaming enhancements
      xpadneo # Xbox controller support
    ];

    # Plymouth for smooth boot experience
    plymouth = {
      enable = true;
      theme = "spinner"; # Clean, minimal theme
    };

    # Kernel sysctl optimizations
    kernel.sysctl = {
      # Gaming performance
      "vm.max_map_count" = 2147483642; # For some games
      "kernel.sched_rt_runtime_us" = -1; # Real-time scheduling

      # Network gaming optimization
      "net.core.rmem_default" = 262144;
      "net.core.rmem_max" = 16777216;
      "net.core.wmem_default" = 262144;
      "net.core.wmem_max" = 16777216;
      "net.ipv4.tcp_rmem" = "4096 87380 16777216";
      "net.ipv4.tcp_wmem" = "4096 65536 16777216";
      "net.core.netdev_max_backlog" = 5000;

      # File system performance
      "fs.file-max" = 2097152;
      "fs.inotify.max_user_watches" = 1048576;

      # Memory management for gaming
      "vm.dirty_ratio" = 3;
      "vm.dirty_background_ratio" = 2;
      "vm.vfs_cache_pressure" = 50;
    };
  };

  # Bleeding-edge hardware configuration
  hardware = {
    # Latest graphics support
    opengl = {
      enable = true;
      driSupport = true;
      driSupport32Bit = true; # For 32-bit games

      # Latest Mesa drivers
      package = pkgs.mesa.drivers;
      package32 = pkgs.pkgsi686Linux.mesa.drivers;

      extraPackages = with pkgs; [
        # Intel graphics
        intel-media-driver
        vaapiIntel
        intel-compute-runtime

        # AMD graphics
        amdvlk
        rocm-opencl-icd
        rocm-opencl-runtime

        # NVIDIA (when using proprietary drivers)
        # nvidia-vaapi-driver

        # Vulkan
        vulkan-loader
        vulkan-tools
        vulkan-headers

        # OpenCL
        opencl-headers
        opencl-info
        clinfo
      ];

      extraPackages32 = with pkgs.pkgsi686Linux; [
        amdvlk
      ];
    };

    # Professional audio configuration
    pulseaudio.enable = false; # Use PipeWire

    # Gaming peripherals
    steam-hardware.enable = true;

    # OpenGL and Vulkan support
    nvidia = {
      modesetting.enable = true;
      open = false; # Use proprietary drivers for gaming performance
      nvidiaSettings = true;
      powerManagement.enable = true;
      powerManagement.finegrained = false;

      # Latest driver version
      package = config.boot.kernelPackages.nvidiaPackages.stable;
    };

    # Bluetooth for controllers and audio
    bluetooth = {
      enable = true;
      powerOnBoot = true;
      settings = {
        General = {
          Enable = "Source,Sink,Media,Socket";
          Experimental = true; # For latest features
        };
      };
    };

    # Sensor support
    sensor.iio.enable = true;

    # RGB and gaming peripherals
    i2c.enable = true;

    # VR support
    openxr = {
      enable = true;
    };

    # Enable firmware updates
    enableRedistributableFirmware = true;
    enableAllFirmware = true;

    # CPU microcode
    cpu = {
      intel.updateMicrocode = true;
      amd.updateMicrocode = true;
    };
  };

  # Gaming-optimized services
  services = {
    # Desktop environment - Niri for modern tiling
    greetd = {
      enable = true;
      settings = {
        default_session = {
          command = "${pkgs.greetd.tuigreet}/bin/tuigreet --time --cmd niri-session";
          user = "greeter";
        };
      };
    };

    # Audio system with low-latency support
    pipewire = {
      enable = true;
      alsa.enable = true;
      alsa.support32Bit = true;
      pulse.enable = true;
      jack.enable = true;

      # Gaming audio configuration
      extraConfig.pipewire = {
        "context.properties" = {
          "default.clock.rate" = 48000;
          "default.clock.quantum" = 512; # Lower latency for gaming
          "default.clock.min-quantum" = 64;
          "default.clock.max-quantum" = 2048;

          # Gaming optimizations
          "core.daemon" = true;
          "core.name" = "pipewire-0";
          "settings.check-quantum" = true;
          "settings.check-rate" = true;
        };

        "context.modules" = [
          {
            name = "libpipewire-module-rt";
            args = {
              "nice.level" = -15;
              "rt.prio" = 88;
              "rt.time.soft" = 200000;
              "rt.time.hard" = 200000;
            };
          }
          {
            name = "libpipewire-module-protocol-native";
          }
          {
            name = "libpipewire-module-client-node";
          }
          {
            name = "libpipewire-module-adapter";
          }
          {
            name = "libpipewire-module-link-factory";
          }
        ];
      };

      # WirePlumber configuration for low-latency
      wireplumber.enable = true;
    };

    # Gaming services
    gamemode = {
      enable = true;
      settings = {
        general = {
          renice = 10;
          ioprio = 0;
          inhibit_screensaver = 1;
          softrealtime = "auto";
          reaper_freq = 5;
        };

        gpu = {
          apply_gpu_optimisations = "accept-responsibility";
          gpu_device = 0;
          amd_performance_level = "high";
          nvidia_powermizer_mode = 1;
        };

        custom = {
          start = "${pkgs.libnotify}/bin/notify-send 'GameMode started'";
          end = "${pkgs.libnotify}/bin/notify-send 'GameMode ended'";
        };
      };
    };

    # RGB peripheral support
    hardware.openrgb = {
      enable = true;
      motherboard = "amd"; # Adjust based on hardware
    };

    # Printing support
    printing = {
      enable = true;
      drivers = with pkgs; [
        hplip
        canon-cups-ufr2
        epson-escpr
        gutenprint
      ];
    };

    # Scanner support
    sane = {
      enable = true;
      extraBackends = with pkgs; [
        hplipWithPlugin
        epkowa
        utsushi
      ];
    };

    # Development services
    postgresql = {
      enable = true;
      package = pkgs.postgresql_15;
      enableTCPIP = true;
      authentication = pkgs.lib.mkOverride 10 ''
        local all all trust
        host all all 127.0.0.1/32 trust
        host all all ::1/128 trust
      '';
      initialScript = pkgs.writeText "backend-initScript" ''
        CREATE ROLE homeuser WITH LOGIN PASSWORD 'password' CREATEDB;
        CREATE DATABASE homeuser;
        GRANT ALL PRIVILEGES ON DATABASE homeuser TO homeuser;
      '';
    };

    redis.servers.default = {
      enable = true;
      port = 6379;
    };

    # Time synchronization
    timesyncd = {
      enable = true;
      servers = [
        "0.nixos.pool.ntp.org"
        "1.nixos.pool.ntp.org"
        "2.nixos.pool.ntp.org"
        "3.nixos.pool.ntp.org"
      ];
    };

    # Bluetooth management
    blueman.enable = true;

    # System monitoring
    netdata = {
      enable = true;
      config = {
        global = {
          "default port" = "19999";
          "bind to" = "127.0.0.1";
        };
      };
    };

    # Automatic updates for bleeding-edge
    system-update = {
      enable = true;
      schedule = "daily";
      randomizedDelaySec = "1h";
    };

    # SSH for development
    openssh = {
      enable = true;
      settings = {
        PermitRootLogin = "no";
        PasswordAuthentication = false;
        PubkeyAuthentication = true;
        X11Forwarding = false;
      };
    };

    # Flatpak for gaming applications
    flatpak.enable = true;

    # udev rules for gaming devices
    udev = {
      packages = with pkgs; [
        game-devices-udev-rules
        steam-devices
      ];

      extraRules = ''
        # Gaming controllers
        SUBSYSTEM=="usb", ATTRS{idVendor}=="045e", ATTRS{idProduct}=="028e", MODE="0666"
        SUBSYSTEM=="usb", ATTRS{idVendor}=="045e", ATTRS{idProduct}=="02d1", MODE="0666"
        SUBSYSTEM=="usb", ATTRS{idVendor}=="045e", ATTRS{idProduct}=="02dd", MODE="0666"

        # VR devices
        SUBSYSTEM=="usb", ATTRS{idVendor}=="0bb4", MODE="0666", GROUP="plugdev"
        SUBSYSTEM=="usb", ATTRS{idVendor}=="28de", MODE="0666", GROUP="plugdev"

        # RGB devices
        SUBSYSTEM=="usb", ATTRS{idVendor}=="1b1c", MODE="0666", GROUP="plugdev"
        SUBSYSTEM=="usb", ATTRS{idVendor}=="1038", MODE="0666", GROUP="plugdev"
      '';
    };

    # Locate database
    locate = {
      enable = true;
      package = pkgs.mlocate;
      interval = "hourly";
    };
  };

  # Security configuration for home use
  security = {
    # Sudo configuration
    sudo = {
      enable = true;
      wheelNeedsPassword = true;
      extraConfig = ''
        Defaults timestamp_timeout=30
        Defaults env_reset
        Defaults secure_path="/run/wrappers/bin:/nix/var/nix/profiles/default/bin:/run/current-system/sw/bin"
      '';
    };

    # Audio real-time access
    rtkit.enable = true;

    # Polkit for desktop applications
    polkit = {
      enable = true;
      extraConfig = ''
        polkit.addRule(function(action, subject) {
            if (
                subject.isInGroup("users")
                && (
                    action.id == "org.freedesktop.login1.reboot" ||
                    action.id == "org.freedesktop.login1.reboot-multiple-sessions" ||
                    action.id == "org.freedesktop.login1.power-off" ||
                    action.id == "org.freedesktop.login1.power-off-multiple-sessions"
                )
            ) {
                return polkit.Result.YES;
            }
        });

        polkit.addRule(function(action, subject) {
            if (action.id == "org.freedesktop.NetworkManager.network-control" && subject.isInGroup("networkmanager")) {
                return polkit.Result.YES;
            }
        });
      '';
    };

    # PAM configuration
    pam.services = {
      login.enableGnomeKeyring = true;
      swaylock = {};
    };

    # Desktop security
    apparmor.enable = true;

    # Gaming-friendly firewall
    firewall = {
      enable = true;
      allowedTCPPorts = [
        # Steam
        27015
        27036
        # GameMode
        22000
        # Development
        3000
        8000
        8080
        9000
      ];
      allowedUDPPorts = [
        # Steam
        27015
        27031
        27036
        # Gaming communication
        3478
        19302
        19303
        19309
        # mDNS
        5353
      ];

      # Allow Steam and gaming traffic
      extraCommands = ''
        # Steam remote play
        iptables -A INPUT -p udp --dport 27031:27036 -j ACCEPT
        iptables -A INPUT -p tcp --dport 27014:27050 -j ACCEPT

        # Discord voice
        iptables -A INPUT -p udp --dport 50000:65535 -j ACCEPT
      '';
    };
  };

  # Networking configuration
  networking = {
    # NetworkManager for easy connection management
    networkmanager = {
      enable = true;
      wifi.powersave = false; # Better for gaming

      # DNS configuration
      dns = "systemd-resolved";
    };

    # Hostname
    hostName = lib.mkDefault "home-desktop";

    # Enable IPv6
    enableIPv6 = true;

    # Gaming network optimizations
    firewall = {
      enable = true;
      checkReversePath = "loose"; # For some games
    };

    # Network performance
    dhcpcd.extraConfig = ''
      # Gaming optimizations
      option rapid_commit
      option domain_name_servers, domain_name, domain_search, host_name
      option classless_static_routes
      option ntp_servers
    '';
  };

  # System-wide packages
  environment.systemPackages = with pkgs;
    [
      # Essential tools
      git
      vim
      neovim
      wget
      curl
      tree
      htop
      btop
      iotop
      lsof
      strace

      # Compression and archives
      zip
      unzip
      p7zip
      rar
      unrar

      # Development tools
      gcc
      clang
      cmake
      make
      pkg-config

      # Editors and IDEs
      vscode
      jetbrains.idea-community

      # Web browsers
      firefox
      chromium
      brave

      # Communication
      discord
      slack
      telegram-desktop
      signal-desktop
      element-desktop

      # Gaming
      steam
      lutris
      heroic
      bottles
      wine-staging
      winetricks
      dxvk
      vkd3d
      gamemode
      mangohud
      goverlay

      # Game stores and launchers
      legendary-gl # Epic Games
      minigalaxy # GOG

      # Emulation
      retroarch
      dolphin-emu
      pcsx2
      ppsspp
      yuzu-mainline
      rpcs3

      # Audio/Video production
      obs-studio
      audacity
      reaper
      kdenlive
      blender
      davinci-resolve
      handbrake

      # Graphics and design
      gimp
      inkscape
      krita
      darktable
      rawtherapee

      # 3D modeling
      freecad
      openscad
      meshlab

      # Media players
      vlc
      mpv
      spotify

      # Productivity
      libreoffice-fresh
      thunderbird
      obsidian
      notion-app-enhanced

      # System utilities
      gparted
      filelight
      baobab
      gnome-disk-utility

      # Network tools
      networkmanagerapplet
      wireshark
      nmap
      traceroute

      # Virtualization
      qemu_kvm
      virt-manager
      docker
      docker-compose
      podman

      # Gaming peripherals
      openrgb
      piper # Gaming mouse configuration

      # VR support
      monado # OpenXR runtime

      # Streaming
      sunshine # Game streaming

      # Font management
      font-manager

      # File management
      ranger
      mc

      # Terminal emulators
      alacritty
      kitty

      # Shell enhancements
      zsh
      fish
      starship

      # System monitoring
      nvtop # GPU monitoring
      radeontop
      intel-gpu-tools

      # Performance tools
      stress
      stress-ng
      sysbench

      # Backup tools
      restic
      borgbackup

      # Password management
      bitwarden
      keepassxc

      # VPN clients
      openvpn
      wireguard-tools

      # Cryptocurrency (for modern users)
      monero-gui

      # AI/ML tools
      python3Packages.tensorflow
      python3Packages.pytorch

      # Development databases
      postgresql
      mysql80
      redis

      # Cloud tools
      awscli2
      azure-cli
      google-cloud-sdk
      terraform
      ansible

      # Container tools
      kubernetes
      helm
      kubectl
      k9s

      # Social and entertainment
      spotify
      discord

      # Bleeding-edge experimental
      # Add latest versions of everything when available
    ]
    ++ (with pkgs.unstable; [
      # Use unstable versions of key packages
      # firefox-nightly
      # vscode-insiders
      # discord-canary
    ]);

  # Fonts for a modern desktop
  fonts = {
    packages = with pkgs; [
      # Programming fonts
      fira-code
      fira-code-symbols
      jetbrains-mono
      source-code-pro
      hack-font

      # UI fonts
      inter
      roboto
      open-sans
      lato
      ubuntu_font_family

      # Icon fonts
      font-awesome
      material-icons

      # Emoji and symbols
      noto-fonts-emoji
      twemoji-color-font

      # CJK support
      noto-fonts-cjk
      source-han-sans
      source-han-serif

      # Gaming fonts
      liberation_ttf
      dejavu_fonts

      # Design fonts
      crimson
      eb-garamond
    ];

    fontconfig = {
      enable = true;
      defaultFonts = {
        serif = ["Noto Serif" "Liberation Serif"];
        sansSerif = ["Inter" "Liberation Sans"];
        monospace = ["JetBrains Mono" "Fira Code"];
        emoji = ["Noto Color Emoji" "Twitter Color Emoji"];
      };

      hinting = {
        enable = true;
        style = "slight";
      };

      subpixel = {
        lcdfilter = "default";
        rgba = "rgb";
      };
    };
  };

  # Users configuration
  users = {
    # Mutable users for home desktop
    mutableUsers = true;

    # Default shell
    defaultUserShell = pkgs.zsh;

    # Main user template
    users = {
      gamer = {
        isNormalUser = true;
        extraGroups = [
          "wheel" # sudo access
          "networkmanager" # network management
          "audio" # audio devices
          "video" # video devices
          "input" # input devices
          "plugdev" # USB devices
          "gamemode" # gaming optimizations
          "docker" # container management
          "libvirtd" # virtualization
          "scanner" # scanner access
          "lp" # printing
        ];
        shell = pkgs.zsh;
        description = "Home Desktop User";
        # Set password with: passwd gamer
      };
    };

    # Additional groups
    extraGroups = {
      gamemode = {gid = 1001;};
      plugdev = {gid = 1002;};
    };
  };

  # XDG configuration
  xdg = {
    portal = {
      enable = true;
      extraPortals = with pkgs; [
        xdg-desktop-portal-gtk
        xdg-desktop-portal-wlr
      ];
      config.common.default = "*";
    };

    mime.enable = true;
  };

  # Programs configuration
  programs = {
    # Gaming
    steam = {
      enable = true;
      remotePlay.openFirewall = true;
      dedicatedServer.openFirewall = true;

      # Proton and compatibility
      package = pkgs.steam.override {
        extraPkgs = pkgs:
          with pkgs; [
            xorg.libXcursor
            xorg.libXi
            xorg.libXinerama
            xorg.libXScrnSaver
            libpng
            libpulseaudio
            libvorbis
            stdenv.cc.cc.lib
            libkrb5
            keyutils
          ];
      };
    };

    gamemode.enable = true;

    # Shell configuration
    zsh = {
      enable = true;
      enableCompletion = true;
      autosuggestions.enable = true;
      syntaxHighlighting.enable = true;

      shellInit = ''
        # Gaming environment optimizations
        export STEAM_RUNTIME=1
        export PROTON_USE_WINED3D=0
        export DXVK_HUD=fps,memory,gpuload
        export MANGOHUD=1

        # Development environment
        export EDITOR=nvim
        export BROWSER=firefox
        export TERMINAL=alacritty

        # Performance
        export OMP_NUM_THREADS=$(nproc)

        # Gaming aliases
        alias steam-native='steam -no-cef-sandbox'
        alias fps='mangohud'
        alias gamemode='gamemoderun'

        # Development aliases
        alias ll='ls -la'
        alias la='ls -A'
        alias l='ls -CF'
        alias grep='grep --color=auto'
        alias ..='cd ..'
        alias ...='cd ../..'

        # Git aliases
        alias gs='git status'
        alias ga='git add'
        alias gc='git commit'
        alias gp='git push'
        alias gl='git log --oneline'

        # Docker aliases
        alias dc='docker-compose'
        alias dps='docker ps'
        alias di='docker images'

        # System monitoring
        alias top='btop'
        alias gpu='nvtop'
        alias cpu='htop'
        alias net='nethogs'
        alias disk='iotop'
      '';
    };

    # Git configuration
    git = {
      enable = true;
      config = {
        user.name = lib.mkDefault "Home User";
        user.email = lib.mkDefault "user@home.local";
        init.defaultBranch = "main";
        core.autocrlf = false;
        pull.rebase = true;
        push.autoSetupRemote = true;

        # Performance optimizations
        core.preloadindex = true;
        core.fscache = true;
        gc.auto = 256;
      };
    };

    # Development tools
    direnv = {
      enable = true;
      nix-direnv.enable = true;
    };

    # Terminal file manager
    nnn.enable = true;

    # Modern system tools
    fzf.enable = true;

    # AppImage support
    appimage = {
      enable = true;
      binfmt = true;
    };

    # Thunar file manager
    thunar = {
      enable = true;
      plugins = with pkgs.xfce; [
        thunar-archive-plugin
        thunar-volman
      ];
    };
  };

  # Virtualization
  virtualisation = {
    # QEMU/KVM for VMs
    libvirtd = {
      enable = true;
      qemu = {
        package = pkgs.qemu_kvm;
        runAsRoot = true;
        swtpm.enable = true;
        ovmf = {
          enable = true;
          packages = [pkgs.OVMFFull.fd];
        };
      };
    };

    # Docker for containers
    docker = {
      enable = true;
      enableOnBoot = true;
      autoPrune = {
        enable = true;
        dates = "weekly";
      };

      # Gaming and development optimizations
      extraOptions = "--default-runtime=runc --experimental";
    };

    # Podman as alternative
    podman = {
      enable = true;
      dockerCompat = true;
      defaultNetwork.settings.dns_enabled = true;
    };

    # Waydroid for Android apps
    waydroid.enable = true;
  };

  # File systems
  fileSystems = {
    # Performance optimizations
    "/" = {
      options = ["noatime" "nodiratime" "discard"];
    };

    # Gaming storage optimization
    "/home" = {
      options = ["noatime" "nodiratime" "discard" "user_xattr"];
    };

    # Temporary files in memory for performance
    "/tmp" = {
      device = "tmpfs";
      fsType = "tmpfs";
      options = [
        "defaults"
        "noatime"
        "nosuid"
        "nodev"
        "size=8G" # Adjust based on RAM
        "mode=1777"
      ];
    };
  };

  # Environment variables
  environment.variables = {
    # Gaming optimizations
    STEAM_RUNTIME = "1";
    PROTON_USE_WINED3D = "0";
    DXVK_HUD = "fps,memory";
    MANGOHUD = "1";

    # Development
    EDITOR = "nvim";
    BROWSER = "firefox";
    TERMINAL = "alacritty";

    # Performance
    OMP_NUM_THREADS = toString (lib.min 16 (lib.max 1 (builtins.floor (config.nix.settings.cores or 4))));

    # Wayland
    NIXOS_OZONE_WL = "1";
    MOZ_ENABLE_WAYLAND = "1";
    QT_QPA_PLATFORM = "wayland";
    SDL_VIDEODRIVER = "wayland";

    # Gaming
    __GL_SHADER_DISK_CACHE = "1";
    __GL_SHADER_DISK_CACHE_SKIP_CLEANUP = "1";

    # Development paths
    PKG_CONFIG_PATH = "/run/current-system/sw/lib/pkgconfig";
  };

  # Nix configuration for bleeding-edge
  nix = {
    settings = {
      # Build optimization
      max-jobs = "auto";
      cores = 0; # Use all cores

      # Performance
      auto-optimise-store = true;
      min-free = 5 * 1024 * 1024 * 1024; # 5GB
      max-free = 10 * 1024 * 1024 * 1024; # 10GB

      # Modern features
      experimental-features = ["nix-command" "flakes" "repl-flake"];

      # Trust settings for home use
      trusted-users = ["root" "@wheel"];
      allowed-users = ["@wheel" "@users"];

      # Bleeding-edge substituters
      substituters = [
        "https://cache.nixos.org"
        "https://nix-community.cachix.org"
        "https://cuda-maintainers.cachix.org"
        "https://devenv.cachix.org"
        "https://nixpkgs-unfree.cachix.org"
      ];

      trusted-public-keys = [
        "cache.nixos.org-1:6NCHdD59X431o0gWypbMrAURkbJ16ZPMQFGspcDShjY="
        "nix-community.cachix.org-1:mB9FSh9qf2dCimDSUo8Zy7bkq5CX+/rkCWyvRCYg3Fs="
        "cuda-maintainers.cachix.org-1:0dq3bujKpuEPiCgBEKTZL2M6FnfCuBdNOcP2EMKR6Mg="
        "devenv.cachix.org-1:w1cLUi8dv3hnoSPGAuibQv+f9TZLr6cv/Hm9XgU50cw="
        "nixpkgs-unfree.cachix.org-1:hqvoInulhbV4nJ9yJOEr+4wxhDV4xq2d1DK7S6Nj6rs="
      ];

      # Build settings for gaming/development
      keep-outputs = true;
      keep-derivations = true;

      # Sandbox with network for some builds
      sandbox = "relaxed";
    };

    # Aggressive garbage collection for bleeding-edge
    gc = {
      automatic = true;
      dates = "daily";
      options = "--delete-older-than 7d";
    };

    # Regular optimization
    optimise = {
      automatic = true;
      dates = ["03:45"];
    };

    # Registry for flakes
    registry = {
      nixpkgs.flake = lib.mkDefault (builtins.getFlake "github:NixOS/nixpkgs/nixos-unstable");
    };
  };

  # System configuration
  system = {
    stateVersion = "24.11";

    # Activation scripts
    activationScripts = {
      homeDesktopSetup = ''
        # Create gaming directories
        mkdir -p /opt/games
        mkdir -p /opt/emulation
        mkdir -p /opt/development

        # Create user directories
        mkdir -p /home/gamer/.config
        mkdir -p /home/gamer/.local/share/Steam
        mkdir -p /home/gamer/.local/share/lutris
        mkdir -p /home/gamer/Games
        mkdir -p /home/gamer/Development
        mkdir -p /home/gamer/Media

        # Set proper permissions
        chown -R gamer:users /home/gamer 2>/dev/null || true
        chmod 755 /opt/games /opt/emulation /opt/development

        # Create performance markers
        echo "bleeding-edge" > /etc/nixos-profile-type
        echo "$(date -Iseconds)" > /etc/nixos-build-date
        echo "gaming,development,media" > /etc/nixos-capabilities

        # Gaming optimizations
        echo 'kernel.sched_rt_runtime_us = -1' > /etc/sysctl.d/99-gaming.conf
        echo 'vm.max_map_count = 2147483642' >> /etc/sysctl.d/99-gaming.conf

        # Create symbolic links for easy access
        ln -sf /run/current-system/sw/bin/steam /usr/local/bin/steam 2>/dev/null || true
        ln -sf /run/current-system/sw/bin/lutris /usr/local/bin/lutris 2>/dev/null || true
      '';
    };
  };

  # Documentation
  documentation = {
    enable = true;
    nixos.enable = true;
    man.enable = true;
    info.enable = true;
    dev.enable = true; # Development documentation
  };

  # Internationalization
  time.timeZone = lib.mkDefault "America/New_York";

  i18n = {
    defaultLocale = "en_US.UTF-8";
    extraLocaleSettings = {
      LC_ADDRESS = "en_US.UTF-8";
      LC_IDENTIFICATION = "en_US.UTF-8";
      LC_MEASUREMENT = "en_US.UTF-8";
      LC_MONETARY = "en_US.UTF-8";
      LC_NAME = "en_US.UTF-8";
      LC_NUMERIC = "en_US.UTF-8";
      LC_PAPER = "en_US.UTF-8";
      LC_TELEPHONE = "en_US.UTF-8";
      LC_TIME = "en_US.UTF-8";
    };
  };

  # Console configuration
  console = {
    font = "Lat2-Terminus16";
    keyMap = "us";
    useXkbConfig = true;
  };

  # Power management
  powerManagement = {
    enable = true;
    cpuFreqGovernor = lib.mkDefault "performance"; # Gaming performance
  };
}
