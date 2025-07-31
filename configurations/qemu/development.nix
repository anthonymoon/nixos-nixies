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
      pulse.enable = true;
      jack.enable = true;
    };
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
    docker = {
      enable = true;
      daemon.settings = {
        data-root = "/var/lib/docker";
        storage-driver = "overlay2";
      };
    };
    libinput.enable = true;
  };
  hardware = {
    opengl = {
      enable = true;
      driSupport = true;
      driSupport32Bit = true;
    };
    pulseaudio.enable = false;
  };
  environment.systemPackages = with pkgs; [
    niri
    waybar
    wofi
    mako
    kitty
    foot
    alacritty
    firefox
    chromium
    vscode
    vim
    neovim
    emacs
    git
    github-cli
    gitui
    delta
    gnumake
    cmake
    ninja
    nil
    rust-analyzer
    gopls
    nodePackages.typescript-language-server
    nodePackages.pyright
    alejandra
    rustfmt
    gofmt
    black
    prettier
    git-lfs
    mercurial
    subversion
    docker
    docker-compose
    podman
    buildah
    skopeo
    awscli2
    google-cloud-sdk
    azure-cli
    kubectl
    helm
    terraform
    postgresql
    redis
    sqlite
    dbeaver
    curl
    wget
    httpie
    postman
    htop
    btop
    tree
    fd
    ripgrep
    bat
    exa
    zoxide
    nautilus
    ranger
    gedit
    mpv
    imv
    grim
    slurp
    wl-clipboard
    file-roller
    unzip
    zip
    p7zip
    gimp
    inkscape
    krita
    libreoffice-fresh
    discord
    slack
    iotop
    nload
    bandwhich
    gdb
    valgrind
    strace
    ltrace
    qemu
    virtualbox
    zeal
    gnupg
    pass
    wireshark
    tcpdump
    nmap
    nodejs_20
    python311
    go_1_21
    rustc
    cargo
    npm
    yarn
    pip
    pipenv
    poetry
  ];
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
  xdg = {
    portal = {
      enable = true;
      wlr.enable = true;
      config.common.default = "*";
    };
  };
  users.users = {
    dev = {
      isNormalUser = true;
      extraGroups = ["wheel" "networkmanager" "audio" "video" "docker" "postgres"];
      password = "dev";
      description = "Development User";
      shell = pkgs.fish;
    };
    nixos = {
      isNormalUser = true;
      extraGroups = ["wheel" "networkmanager" "audio" "video"];
      password = "nixos";
      description = "NixOS Test User";
    };
  };
  programs = {
    fish = {
      enable = true;
      vendor.completions.enable = true;
      vendor.config.enable = true;
    };
    thunar.enable = true;
    file-roller.enable = true;
    git = {
      enable = true;
      config = {
        init.defaultBranch = "main";
        pull.rebase = true;
        push.autoSetupRemote = true;
      };
    };
    gnupg.agent = {
      enable = true;
      enableSSHSupport = true;
    };
    direnv = {
      enable = true;
      nix-direnv.enable = true;
    };
  };
  security = {
    rtkit.enable = true;
    polkit.enable = true;
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
  networking = {
    networkmanager = {
      enable = true;
      wifi.powersave = false;
    };
    dhcpcd.enable = false;
    firewall = {
      enable = false;
      allowedTCPPorts = [3000 8000 8080 8443 9000 5432 6379];
    };
  };
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
    "/tmp" = {
      device = "tmpfs";
      fsType = "tmpfs";
      options = ["defaults" "size=4G" "mode=1777"];
    };
    "/mnt/shared" = {
      device = "hostshare";
      fsType = "9p";
      options = ["trans=virtio" "version=9p2000.L" "cache=loose"];
    };
  };
  boot = {
    kernelPackages = pkgs.linuxPackages_latest;
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
    kernelParams = [
      "quiet"
      "loglevel=3"
    ];
    enableContainerSupport = true;
  };
  boot.kernel.sysctl = {
    "vm.swappiness" = 5;
    "vm.dirty_background_ratio" = 5;
    "vm.dirty_ratio" = 10;
    "fs.file-max" = 2097152;
    "fs.nr_open" = 1048576;
    "net.core.rmem_max" = 16777216;
    "net.core.wmem_max" = 16777216;
    "kernel.unprivileged_userns_clone" = 1;
    "user.max_user_namespaces" = 28633;
  };
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
  documentation = {
    enable = true;
    nixos.enable = true;
    man.enable = true;
    dev.enable = true;
  };
  virtualisation = {
    docker = {
      enable = true;
      enableOnBoot = true;
      autoPrune = {
        enable = true;
        dates = "weekly";
      };
    };
    libvirtd = {
      enable = true;
      qemu = {
        package = pkgs.qemu_kvm;
        ovmf.enable = true;
        swtpm.enable = true;
      };
    };
  };
  environment.variables = {
    EDITOR = "code";
    BROWSER = "firefox";
    TERMINAL = "kitty";
    GOPATH = "$HOME/go";
    CARGO_HOME = "$HOME/.cargo";
    RUSTUP_HOME = "$HOME/.rustup";
    NODE_OPTIONS = "--max-old-space-size=4096";
    NIXOS_VM_TYPE = "development";
    DEVELOPMENT_MODE = "1";
  };
  system.stateVersion = "24.11";
}
