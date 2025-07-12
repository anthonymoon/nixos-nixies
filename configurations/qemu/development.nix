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
    ../../modules/development/languages.nix
    ../../modules/development/tools.nix
  ];

  # Development VM configuration
  unified = {
    core = {
      hostname = "nixos-qemu-dev";
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
        screensharing = true;
        clipboard = true;
        notifications = true;
      };
      applications = {
        terminal = "kitty";
        browser = "firefox";
        launcher = "wofi";
      };
    };

    development = {
      enable = true;
      languages = {
        rust = true;
        go = true;
        python = true;
        javascript = true;
        nix = true;
      };
      tools = {
        editors = true;
        containers = true;
        databases = true;
        cloud = true;
      };
    };
  };

  # Enhanced graphics for development
  services = {
    # Display manager
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
      jack.enable = true;
    };

    # Development services
    postgresql = {
      enable = true;
      package = pkgs.postgresql_15;
      settings = {
        max_connections = 100;
        shared_buffers = "128MB";
        effective_cache_size = "1GB";
      };
      authentication = lib.mkOverride 10 ''
        local all all trust
        host all all 127.0.0.1/32 trust
        host all all ::1/128 trust
      '';
    };

    redis = {
      enable = true;
      servers."".enable = true;
    };

    # Container runtime
    docker = {
      enable = true;
      daemon.settings = {
        data-root = "/var/lib/docker";
        storage-driver = "overlay2";
      };
    };

    # Input devices
    libinput.enable = true;
  };

  # Hardware for development VM
  hardware = {
    # Enhanced graphics support
    opengl = {
      enable = true;
      driSupport = true;
      driSupport32Bit = true;
    };

    # Audio
    pulseaudio.enable = false; # Using PipeWire
  };

  # Development packages
  environment.systemPackages = with pkgs; [
    # Desktop environment
    niri
    waybar
    wofi
    mako

    # Terminal emulators
    kitty
    foot
    alacritty

    # Web browsers
    firefox
    chromium

    # Code editors
    vscode
    vim
    neovim
    emacs

    # Development tools
    git
    github-cli
    gitui
    delta

    # Build tools
    gnumake
    cmake
    ninja

    # Language servers
    nil # Nix LSP
    rust-analyzer
    gopls
    nodePackages.typescript-language-server
    nodePackages.pyright

    # Formatters
    alejandra # Nix formatter
    rustfmt
    gofmt
    black # Python formatter
    prettier # JS/TS formatter

    # Version control
    git-lfs
    mercurial
    subversion

    # Container tools
    docker
    docker-compose
    podman
    buildah
    skopeo

    # Cloud tools
    awscli2
    google-cloud-sdk
    azure-cli
    kubectl
    helm
    terraform

    # Database tools
    postgresql
    redis
    sqlite
    dbeaver

    # Network tools
    curl
    wget
    httpie
    postman

    # System tools
    htop
    btop
    tree
    fd
    ripgrep
    bat
    exa
    zoxide

    # File managers
    nautilus
    ranger

    # Text editors
    gedit

    # Media
    mpv
    imv

    # Utilities
    grim # Screenshots
    slurp # Region selection
    wl-clipboard # Clipboard

    # Archive tools
    file-roller
    unzip
    zip
    p7zip

    # Graphics and design
    gimp
    inkscape
    krita

    # Office
    libreoffice-fresh

    # Communication
    discord
    slack

    # Performance monitoring
    iotop
    nload
    bandwhich

    # Debugging tools
    gdb
    valgrind
    strace
    ltrace

    # Virtualization
    qemu
    virtualbox

    # Documentation
    zeal

    # Security tools
    gnupg
    pass

    # Network debugging
    wireshark
    tcpdump
    nmap

    # Language runtimes
    nodejs_20
    python311
    go_1_21
    rustc
    cargo

    # Package managers
    npm
    yarn
    pip
    pipenv
    poetry
  ];

  # Enhanced fonts for development
  fonts = {
    packages = with pkgs; [
      noto-fonts
      noto-fonts-cjk
      noto-fonts-emoji
      liberation_ttf
      fira-code
      fira-code-symbols
      source-code-pro
      jetbrains-mono
      cascadia-code
      victor-mono
    ];

    fontconfig = {
      enable = true;
      defaultFonts = {
        serif = ["Noto Serif"];
        sansSerif = ["Noto Sans"];
        monospace = ["JetBrains Mono" "Fira Code"];
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

  # Development users
  users.users = {
    # Primary development user
    dev = {
      isNormalUser = true;
      extraGroups = ["wheel" "networkmanager" "audio" "video" "docker" "postgres"];
      password = "dev"; # pragma: allowlist secret
      description = "Development User";
      shell = pkgs.fish;
    };

    # Secondary user for testing
    nixos = {
      isNormalUser = true;
      extraGroups = ["wheel" "networkmanager" "audio" "video"];
      password = "nixos"; # pragma: allowlist secret
      description = "NixOS Test User";
    };
  };

  # Programs for development
  programs = {
    # Shell
    fish = {
      enable = true;
      vendor.completions.enable = true;
      vendor.config.enable = true;
    };

    # File manager
    thunar.enable = true;

    # Archive integration
    file-roller.enable = true;

    # Git configuration
    git = {
      enable = true;
      config = {
        init.defaultBranch = "main";
        pull.rebase = true;
        push.autoSetupRemote = true;
      };
    };

    # GPG
    gnupg.agent = {
      enable = true;
      enableSSHSupport = true;
    };

    # Direnv for development environments
    direnv = {
      enable = true;
      nix-direnv.enable = true;
    };
  };

  # Security for development VM
  security = {
    # Real-time kit for audio
    rtkit.enable = true;

    # Polkit for desktop operations
    polkit.enable = true;

    # Allow development tools
    sudo.extraRules = [
      {
        users = ["dev"];
        commands = [
          {
            command = "${pkgs.docker}/bin/docker";
            options = ["NOPASSWD"];
          }
          {
            command = "${pkgs.systemd}/bin/systemctl";
            options = ["NOPASSWD"];
          }
        ];
      }
    ];
  };

  # Enhanced networking for development
  networking = {
    networkmanager = {
      enable = true;
      wifi.powersave = false;
    };

    # Disable dhcpcd as NetworkManager handles DHCP
    dhcpcd.enable = false;

    # Development ports
    firewall = {
      enable = false; # Disabled for development flexibility
      allowedTCPPorts = [3000 8000 8080 8443 9000 5432 6379];
    };
  };

  # File systems optimized for development VM
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

    # Large tmpfs for development builds
    "/tmp" = {
      device = "tmpfs";
      fsType = "tmpfs";
      options = ["defaults" "size=4G" "mode=1777"];
    };

    # Shared folder for host-guest file sharing
    "/mnt/shared" = {
      device = "hostshare";
      fsType = "9p";
      options = ["trans=virtio" "version=9p2000.L" "cache=loose"];
    };
  };

  # Development VM boot configuration
  boot = {
    # Latest kernel for better hardware support
    kernelPackages = pkgs.linuxPackages_latest;

    # Development-friendly kernel modules
    kernelModules = [
      "virtio_balloon"
      "virtio_console"
      "virtio_net"
      "virtio_blk"
      "virtio_gpu"
      "virtio_input"
      "virtio_fs"
      "9p"
      "9pnet_virtio"
    ];

    # Development kernel parameters
    kernelParams = [
      "quiet"
      "loglevel=3"
    ];

    # Support for containers
    enableContainerSupport = true;
  };

  # Development performance tuning
  boot.kernel.sysctl = {
    # Enhanced responsiveness for development
    "vm.swappiness" = 5;
    "vm.dirty_background_ratio" = 5;
    "vm.dirty_ratio" = 10;

    # File handle limits for development
    "fs.file-max" = 2097152;
    "fs.nr_open" = 1048576;

    # Network performance for development
    "net.core.rmem_max" = 16777216;
    "net.core.wmem_max" = 16777216;

    # Container support
    "kernel.unprivileged_userns_clone" = 1;
    "user.max_user_namespaces" = 28633;
  };

  # Nix configuration for development
  nix = {
    settings = {
      max-jobs = 4;
      cores = 4;
      auto-optimise-store = true;
      experimental-features = ["nix-command" "flakes"];
      trusted-users = ["dev" "nixos"];
    };

    gc = {
      automatic = true;
      dates = "weekly";
      options = "--delete-older-than 14d";
    };
  };

  # Enable development documentation
  documentation = {
    enable = true;
    nixos.enable = true;
    man.enable = true;
    dev.enable = true;
  };

  # Virtualisation settings for development
  virtualisation = {
    docker = {
      enable = true;
      enableOnBoot = true;
      autoPrune = {
        enable = true;
        dates = "weekly";
      };
    };

    # Enable nested virtualization if available
    libvirtd = {
      enable = true;
      qemu = {
        package = pkgs.qemu_kvm;
        ovmf.enable = true;
        swtpm.enable = true;
      };
    };
  };

  # Environment variables for development
  environment.variables = {
    EDITOR = "code";
    BROWSER = "firefox";
    TERMINAL = "kitty";

    # Development paths
    GOPATH = "$HOME/go";
    CARGO_HOME = "$HOME/.cargo";
    RUSTUP_HOME = "$HOME/.rustup";

    # Node.js
    NODE_OPTIONS = "--max-old-space-size=4096";

    # Development indicators
    NIXOS_VM_TYPE = "development";
    DEVELOPMENT_MODE = "1";
  };

  # System state version
  system.stateVersion = "24.11";
}
