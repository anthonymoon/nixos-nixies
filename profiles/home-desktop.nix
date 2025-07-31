{
  config,
  lib,
  pkgs,
  ...
}: {
  imports = [
    ./base.nix
  ];
  unified = {
    core = {
      enable = true;
      security.level = "standard";
      performance.enable = true;
      performance.profile = "gaming";
      stability.channel = "bleeding-edge";
    };
    desktop = {
      enable = true;
      environment = "niri";
      wayland = true;
      bleeding-edge = true;
      gaming-optimized = true;
    };
    gaming = {
      enable = true;
      steam = {
        enable = true;
        proton.enable = true;
        proton.version = "latest";
        remote-play.enable = true;
        vr.enable = true;
      };
      performance = {
        gamemode = true;
        mangohud = true;
        corectrl = true;
        latency-optimization = true;
        cpu-governor = "performance";
      };
      launchers = {
        lutris = true;
        heroic = true;
        bottles = true;
        itch = true;
        gog = true;
      };
      emulation = {
        retroarch = true;
        dolphin = true;
        yuzu = true;
        rpcs3 = true;
        pcsx2 = true;
        ppsspp = true;
      };
      streaming = {
        enable = true;
        obs = true;
        sunshine = true;
        discord = true;
      };
      peripherals = {
        openrgb = true;
        gaming-controllers = true;
        racing-wheels = true;
        flight-controls = true;
      };
    };
    development = {
      enable = true;
      bleeding-edge = true;
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
      editors = {
        vscode = true;
        neovim = true;
        jetbrains-suite = true;
        emacs = true;
      };
      tools = {
        git = true;
        docker = true;
        podman = true;
        kubernetes = true;
        terraform = true;
        ansible = true;
        vagrant = true;
      };
      databases = {
        postgresql = true;
        mysql = true;
        redis = true;
        mongodb = true;
      };
    };
    media = {
      enable = true;
      bleeding-edge = true;
      video = {
        davinci-resolve = true;
        kdenlive = true;
        blender = true;
        obs-studio = true;
        handbrake = true;
      };
      audio = {
        ardour = true;
        reaper = true;
        bitwig = true;
        audacity = true;
        carla = true;
        jack = true;
        low-latency = true;
      };
      graphics = {
        gimp = true;
        inkscape = true;
        krita = true;
        darktable = true;
        rawtherapee = true;
        hugin = true;
      };
      modeling = {
        blender = true;
        freecad = true;
        openscad = true;
        meshlab = true;
      };
    };
    hardware = {
      enable = true;
      bleeding-edge = true;
      gaming = true;
      content-creation = true;
      graphics = {
        acceleration = true;
        vulkan = true;
        opencl = true;
        cuda = true;
        multi-gpu = true;
        vr-ready = true;
      };
      audio = {
        professional = true;
        low-latency = true;
        jack-support = true;
        usb-audio = true;
      };
      storage = {
        nvme-optimization = true;
        ssd-optimization = true;
        raid-support = true;
      };
    };
    networking = {
      enable = true;
      gaming-optimized = true;
      development-tools = true;
      gaming = {
        low-latency = true;
        qos = true;
        port-forwarding = true;
      };
      privacy = {
        wireguard = true;
        tor = true;
        i2p = true;
      };
    };
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
  nixpkgs = {
    config = {
      allowUnfree = true;
      allowInsecure = false;
      allowBroken = false;
      permittedInsecurePackages = [];
    };
  };
  boot = {
    kernelPackages = pkgs.linuxPackages_latest;
    kernelParams = [
      "processor.max_cstate=1"
      "intel_idle.max_cstate=1"
      "intel_pstate=performance"
      "transparent_hugepage=never"
      "vm.swappiness=1"
      "preempt=voluntary"
      "rcu_nocbs=0-7"
      "nvidia-drm.modeset=1"
      "amdgpu.dc=1"
      "threadirqs"
      "net.core.default_qdisc=fq_codel"
      "net.ipv4.tcp_congestion_control=bbr"
      "quiet"
      "splash"
      "loglevel=3"
      "rd.systemd.show_status=false"
      "rd.udev.log_level=3"
      "udev.log_priority=3"
    ];
    loader = {
      systemd-boot = {
        enable = true;
        configurationLimit = 10;
        editor = false;
      };
      efi.canTouchEfiVariables = true;
      timeout = 1;
    };
    initrd = {
      systemd.enable = true;
      availableKernelModules = [
        "nvme"
        "xhci_pci"
        "ahci"
        "usbhid"
        "usb_storage"
        "sd_mod"
        "uinput"
        "hid_generic"
        "hid_sony"
        "hid_microsoft"
        "uvcvideo"
        "snd_usb_audio"
      ];
    };
    extraModulePackages = with config.boot.kernelPackages; [
      nvidia_x11
      xpadneo
    ];
    plymouth = {
      enable = true;
      theme = "spinner";
    };
    kernel.sysctl = {
      "vm.max_map_count" = 2147483642;
      "kernel.sched_rt_runtime_us" = -1;
      "net.core.rmem_default" = 262144;
      "net.core.rmem_max" = 16777216;
      "net.core.wmem_default" = 262144;
      "net.core.wmem_max" = 16777216;
      "net.ipv4.tcp_rmem" = "4096 87380 16777216";
      "net.ipv4.tcp_wmem" = "4096 65536 16777216";
      "net.core.netdev_max_backlog" = 5000;
      "fs.file-max" = 2097152;
      "fs.inotify.max_user_watches" = 1048576;
      "vm.dirty_ratio" = 3;
      "vm.dirty_background_ratio" = 2;
      "vm.vfs_cache_pressure" = 50;
    };
  };
  hardware = {
    opengl = {
      enable = true;
      driSupport = true;
      driSupport32Bit = true;
      package = pkgs.mesa.drivers;
      package32 = pkgs.pkgsi686Linux.mesa.drivers;
      extraPackages = with pkgs; [
        intel-media-driver
        vaapiIntel
        intel-compute-runtime
        amdvlk
        rocm-opencl-icd
        rocm-opencl-runtime
        vulkan-loader
        vulkan-tools
        vulkan-headers
        opencl-headers
        opencl-info
        clinfo
      ];
      extraPackages32 = with pkgs.pkgsi686Linux; [
        amdvlk
      ];
    };
    pulseaudio.enable = false;
    steam-hardware.enable = true;
    nvidia = {
      modesetting.enable = true;
      open = false;
      nvidiaSettings = true;
      powerManagement.enable = true;
      powerManagement.finegrained = false;
      package = config.boot.kernelPackages.nvidiaPackages.stable;
    };
    bluetooth = {
      enable = true;
      powerOnBoot = true;
      settings = {
        General = {
          Enable = "Source,Sink,Media,Socket";
          Experimental = true;
        };
      };
    };
    sensor.iio.enable = true;
    i2c.enable = true;
    openxr = {
      enable = true;
    };
    enableRedistributableFirmware = true;
    enableAllFirmware = true;
    cpu = {
      intel.updateMicrocode = true;
      amd.updateMicrocode = true;
    };
  };
  services = {
    greetd = {
      enable = true;
      settings = {
        default_session = {
          command = "${pkgs.greetd.tuigreet}/bin/tuigreet --time --cmd niri-session";
          user = "greeter";
        };
      };
    };
    pipewire = {
      enable = true;
      alsa.enable = true;
      alsa.support32Bit = true;
      pulse.enable = true;
      jack.enable = true;
      extraConfig.pipewire = {
        "context.properties" = {
          "default.clock.rate" = 48000;
          "default.clock.quantum" = 512;
          "default.clock.min-quantum" = 64;
          "default.clock.max-quantum" = 2048;
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
      wireplumber.enable = true;
    };
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
    hardware.openrgb = {
      enable = true;
      motherboard = "amd";
    };
    printing = {
      enable = true;
      drivers = with pkgs; [
        hplip
        canon-cups-ufr2
        epson-escpr
        gutenprint
      ];
    };
    sane = {
      enable = true;
      extraBackends = with pkgs; [
        hplipWithPlugin
        epkowa
        utsushi
      ];
    };
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
    timesyncd = {
      enable = true;
      servers = [
        "0.nixos.pool.ntp.org"
        "1.nixos.pool.ntp.org"
        "2.nixos.pool.ntp.org"
        "3.nixos.pool.ntp.org"
      ];
    };
    blueman.enable = true;
    netdata = {
      enable = true;
      config = {
        global = {
          "default port" = "19999";
          "bind to" = "127.0.0.1";
        };
      };
    };
    system-update = {
      enable = true;
      schedule = "daily";
      randomizedDelaySec = "1h";
    };
    openssh = {
      enable = true;
      settings = {
        PermitRootLogin = "no";
        PasswordAuthentication = false;
        PubkeyAuthentication = true;
        X11Forwarding = false;
      };
    };
    flatpak.enable = true;
    udev = {
      packages = with pkgs; [
        game-devices-udev-rules
        steam-devices
      ];
      extraRules = ''
        SUBSYSTEM=="usb", ATTRS{idVendor}=="045e", ATTRS{idProduct}=="028e", MODE="0666"
        SUBSYSTEM=="usb", ATTRS{idVendor}=="045e", ATTRS{idProduct}=="02d1", MODE="0666"
        SUBSYSTEM=="usb", ATTRS{idVendor}=="045e", ATTRS{idProduct}=="02dd", MODE="0666"
        SUBSYSTEM=="usb", ATTRS{idVendor}=="0bb4", MODE="0666", GROUP="plugdev"
        SUBSYSTEM=="usb", ATTRS{idVendor}=="28de", MODE="0666", GROUP="plugdev"
        SUBSYSTEM=="usb", ATTRS{idVendor}=="1b1c", MODE="0666", GROUP="plugdev"
        SUBSYSTEM=="usb", ATTRS{idVendor}=="1038", MODE="0666", GROUP="plugdev"
      '';
    };
    locate = {
      enable = true;
      package = pkgs.mlocate;
      interval = "hourly";
    };
  };
  security = {
    sudo = {
      enable = true;
      wheelNeedsPassword = true;
      extraConfig = ''
        Defaults timestamp_timeout=30
        Defaults env_reset
        Defaults secure_path="/run/wrappers/bin:/nix/var/nix/profiles/default/bin:/run/current-system/sw/bin"
      '';
    };
    rtkit.enable = true;
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
    pam.services = {
      login.enableGnomeKeyring = true;
      swaylock = {};
    };
    apparmor.enable = true;
    firewall = {
      enable = true;
      allowedTCPPorts = [
        27015
        27036
        22000
        3000
        8000
        8080
        9000
      ];
      allowedUDPPorts = [
        27015
        27031
        27036
        3478
        19302
        19303
        19309
        5353
      ];
      extraCommands = ''
        iptables -A INPUT -p udp --dport 27031:27036 -j ACCEPT
        iptables -A INPUT -p tcp --dport 27014:27050 -j ACCEPT
        iptables -A INPUT -p udp --dport 50000:65535 -j ACCEPT
      '';
    };
  };
  networking = {
    networkmanager = {
      enable = true;
      wifi.powersave = false;
      dns = "systemd-resolved";
    };
    hostName = lib.mkDefault "home-desktop";
    enableIPv6 = true;
    firewall = {
      enable = true;
      checkReversePath = "loose";
    };
    dhcpcd.extraConfig = ''
      option rapid_commit
      option domain_name_servers, domain_name, domain_search, host_name
      option classless_static_routes
      option ntp_servers
    '';
  };
  environment.systemPackages = with pkgs;
    [
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
      zip
      unzip
      p7zip
      rar
      unrar
      gcc
      clang
      cmake
      make
      pkg-config
      vscode
      jetbrains.idea-community
      firefox
      chromium
      brave
      discord
      slack
      telegram-desktop
      signal-desktop
      element-desktop
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
      legendary-gl
      minigalaxy
      retroarch
      dolphin-emu
      pcsx2
      ppsspp
      yuzu-mainline
      rpcs3
      obs-studio
      audacity
      reaper
      kdenlive
      blender
      davinci-resolve
      handbrake
      gimp
      inkscape
      krita
      darktable
      rawtherapee
      freecad
      openscad
      meshlab
      vlc
      mpv
      spotify
      libreoffice-fresh
      thunderbird
      obsidian
      notion-app-enhanced
      gparted
      filelight
      baobab
      gnome-disk-utility
      networkmanagerapplet
      wireshark
      nmap
      traceroute
      qemu_kvm
      virt-manager
      docker
      docker-compose
      podman
      openrgb
      piper
      monado
      sunshine
      font-manager
      ranger
      mc
      alacritty
      kitty
      zsh
      fish
      starship
      nvtop
      radeontop
      intel-gpu-tools
      stress
      stress-ng
      sysbench
      restic
      borgbackup
      bitwarden
      keepassxc
      openvpn
      wireguard-tools
      monero-gui
      python3Packages.tensorflow
      python3Packages.pytorch
      postgresql
      mysql80
      redis
      awscli2
      azure-cli
      google-cloud-sdk
      terraform
      ansible
      kubernetes
      helm
      kubectl
      k9s
      spotify
      discord
    ]
    ++ (with pkgs.unstable; [
      ]);
  fonts = {
    packages = with pkgs; [
      fira-code
      fira-code-symbols
      jetbrains-mono
      source-code-pro
      hack-font
      inter
      roboto
      open-sans
      lato
      ubuntu_font_family
      font-awesome
      material-icons
      noto-fonts-emoji
      twemoji-color-font
      noto-fonts-cjk
      source-han-sans
      source-han-serif
      liberation_ttf
      dejavu_fonts
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
  users = {
    mutableUsers = true;
    defaultUserShell = pkgs.zsh;
    users = {
      gamer = {
        isNormalUser = true;
        extraGroups = [
          "wheel"
          "networkmanager"
          "audio"
          "video"
          "input"
          "plugdev"
          "gamemode"
          "docker"
          "libvirtd"
          "scanner"
          "lp"
        ];
        shell = pkgs.zsh;
        description = "Home Desktop User";
      };
    };
    extraGroups = {
      gamemode = {gid = 1001;};
      plugdev = {gid = 1002;};
    };
  };
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
  programs = {
    steam = {
      enable = true;
      remotePlay.openFirewall = true;
      dedicatedServer.openFirewall = true;
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
    zsh = {
      enable = true;
      completion.enable = true;
      autosuggestions.enable = true;
      syntaxHighlighting.enable = true;
      shellInit = ''
        export STEAM_RUNTIME=1
        export PROTON_USE_WINED3D=0
        export DXVK_HUD=fps,memory,gpuload
        export MANGOHUD=1
        export EDITOR=nvim
        export BROWSER=firefox
        export TERMINAL=alacritty
        export OMP_NUM_THREADS=$(nproc)
        alias steam-native='steam -no-cef-sandbox'
        alias fps='mangohud'
        alias gamemode='gamemoderun'
        alias ll='ls -la'
        alias la='ls -A'
        alias l='ls -CF'
        alias grep='grep --color=auto'
        alias ..='cd ..'
        alias ...='cd ../..'
        alias gs='git status'
        alias ga='git add'
        alias gc='git commit'
        alias gp='git push'
        alias gl='git log --oneline'
        alias dc='docker-compose'
        alias dps='docker ps'
        alias di='docker images'
        alias top='btop'
        alias gpu='nvtop'
        alias cpu='htop'
        alias net='nethogs'
        alias disk='iotop'
      '';
    };
    git = {
      enable = true;
      config = {
        user.name = lib.mkDefault "Home User";
        user.email = lib.mkDefault "user@home.local";
        init.defaultBranch = "main";
        core.autocrlf = false;
        pull.rebase = true;
        push.autoSetupRemote = true;
        core.preloadindex = true;
        core.fscache = true;
        gc.auto = 256;
      };
    };
    direnv = {
      enable = true;
      nix-direnv.enable = true;
    };
    nnn.enable = true;
    fzf.enable = true;
    appimage = {
      enable = true;
      binfmt = true;
    };
    thunar = {
      enable = true;
      plugins = with pkgs.xfce; [
        thunar-archive-plugin
        thunar-volman
      ];
    };
  };
  virtualisation = {
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
    docker = {
      enable = true;
      enableOnBoot = true;
      autoPrune = {
        enable = true;
        dates = "weekly";
      };
      extraOptions = "--default-runtime=runc --experimental";
    };
    podman = {
      enable = true;
      dockerCompat = true;
      defaultNetwork.settings.dns_enabled = true;
    };
    waydroid.enable = true;
  };
  fileSystems = {
    "/" = {
      options = ["noatime" "nodiratime" "discard"];
    };
    "/home" = {
      options = ["noatime" "nodiratime" "discard" "user_xattr"];
    };
    "/tmp" = {
      device = "tmpfs";
      fsType = "tmpfs";
      options = [
        "defaults"
        "noatime"
        "nosuid"
        "nodev"
        "size=8G"
        "mode=1777"
      ];
    };
  };
  environment.variables = {
    STEAM_RUNTIME = "1";
    PROTON_USE_WINED3D = "0";
    DXVK_HUD = "fps,memory";
    MANGOHUD = "1";
    EDITOR = "nvim";
    BROWSER = "firefox";
    TERMINAL = "alacritty";
    OMP_NUM_THREADS = toString (lib.min 16 (lib.max 1 (builtins.floor (config.nix.settings.cores or 4))));
    NIXOS_OZONE_WL = "1";
    MOZ_ENABLE_WAYLAND = "1";
    QT_QPA_PLATFORM = "wayland";
    SDL_VIDEODRIVER = "wayland";
    __GL_SHADER_DISK_CACHE = "1";
    __GL_SHADER_DISK_CACHE_SKIP_CLEANUP = "1";
    PKG_CONFIG_PATH = "/run/current-system/sw/lib/pkgconfig";
  };
  nix = {
    settings = {
      max-jobs = "auto";
      cores = 0;
      auto-optimise-store = true;
      min-free = 5 * 1024 * 1024 * 1024;
      max-free = 10 * 1024 * 1024 * 1024;
      experimental-features = ["nix-command" "flakes" "repl-flake"];
      trusted-users = ["root" "@wheel"];
      allowed-users = ["@wheel" "@users"];
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
      keep-outputs = true;
      keep-derivations = true;
      sandbox = "relaxed";
    };
    gc = {
      automatic = true;
      dates = "daily";
      options = "--delete-older-than 7d";
    };
    optimise = {
      automatic = true;
      dates = ["03:45"];
    };
    registry = {
      nixpkgs.flake = lib.mkDefault (builtins.getFlake "github:NixOS/nixpkgs/nixos-unstable");
    };
  };
  system = {
    stateVersion = "24.11";
    activationScripts = {
      homeDesktopSetup = ''
        mkdir -p /opt/games
        mkdir -p /opt/emulation
        mkdir -p /opt/development
        mkdir -p /home/gamer/.config
        mkdir -p /home/gamer/.local/share/Steam
        mkdir -p /home/gamer/.local/share/lutris
        mkdir -p /home/gamer/Games
        mkdir -p /home/gamer/Development
        mkdir -p /home/gamer/Media
        chown -R gamer:users /home/gamer 2>/dev/null || true
        chmod 755 /opt/games /opt/emulation /opt/development
        echo "bleeding-edge" > /etc/nixos-profile-type
        echo "$(date -Iseconds)" > /etc/nixos-build-date
        echo "gaming,development,media" > /etc/nixos-capabilities
        echo 'kernel.sched_rt_runtime_us = -1' > /etc/sysctl.d/99-gaming.conf
        echo 'vm.max_map_count = 2147483642' >> /etc/sysctl.d/99-gaming.conf
        ln -sf /run/current-system/sw/bin/steam /usr/local/bin/steam 2>/dev/null || true
        ln -sf /run/current-system/sw/bin/lutris /usr/local/bin/lutris 2>/dev/null || true
      '';
    };
  };
  documentation = {
    enable = true;
    nixos.enable = true;
    man.enable = true;
    info.enable = true;
    dev.enable = true;
  };
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
  console = {
    font = "Lat2-Terminus16";
    keyMap = "us";
    useXkbConfig = true;
  };
  powerManagement = {
    enable = true;
    cpuFreqGovernor = lib.mkDefault "performance";
  };
}
