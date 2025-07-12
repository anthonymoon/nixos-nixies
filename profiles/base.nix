{
  config,
  lib,
  pkgs,
  ...
}: {
  imports = [
    ../modules/core
  ];
  meta = {
    name = "base";
    description = "Base system profile with security defaults";
    maintainers = ["nixos-unified"];
  };

  # Core unified configuration
  unified.core = {
    enable = true;
    security = {
      enable = true;
      level = "standard";
      ssh = {
        enable = true;
        passwordAuth = false;
        rootLogin = false;
      };
      firewall = {
        enable = true;
        allowedPorts = [];
      };
    };
    performance.enable = true;
  };

  # Essential system configuration
  boot = {
    # Clean temporary files on boot
    tmp.cleanOnBoot = true;

    # Kernel parameters for security and performance
    kernelParams = [
      "quiet"
      "loglevel=3"
    ];

    # Default to latest kernel
    kernelPackages = lib.mkDefault pkgs.linuxPackages_latest;
  };

  # Nix configuration with security and performance
  nix = {
    settings = {
      # Flakes and new commands
      experimental-features = ["nix-command" "flakes"];

      # Optimize store automatically
      auto-optimise-store = true;

      # Build settings
      max-jobs = "auto";
      cores = 0; # Use all available cores

      # Security: only allow wheel users to manage Nix
      allowed-users = ["@wheel"];
      trusted-users = ["@wheel"];

      # Substituters for faster builds
      substituters = [
        "https://cache.nixos.org"
      ];

      trusted-public-keys = [
        "cache.nixos.org-1:6NCHdD59X431o0gWypbMrAURkbJ16ZPMQFGspcDShjY="
      ];
    };

    # Garbage collection
    gc = {
      automatic = true;
      dates = "weekly";
      options = "--delete-older-than 30d";
    };

    # Optimize store weekly
    optimise = {
      automatic = true;
      dates = ["weekly"];
    };
  };

  # Network configuration
  networking = {
    # Enable firewall with secure defaults
    firewall = {
      enable = true;
      allowPing = true;
      logRefusedConnections = false; # Reduce log spam
    };

    # Use systemd-resolved for DNS
    useNetworkd = lib.mkDefault false;
  };

  # Security configuration
  security = {
    # Sudo configuration
    sudo = {
      enable = true;
      wheelNeedsPassword = true;
      execWheelOnly = true;
    };

    # AppArmor for additional security
    apparmor.enable = lib.mkDefault true;

    # Real-time priority for audio
    rtkit.enable = true;
  };

  # Essential packages for all systems
  environment.systemPackages = with pkgs; [
    # Text editors
    nano
    vim

    # File management
    file
    tree

    # Network tools
    curl
    wget
    dig

    # System tools
    htop
    iotop
    lsof
    pciutils
    usbutils

    # Archive tools
    unzip
    zip

    # Git for configuration management
    git

    # Process management
    killall
    psmisc

    # System information
    neofetch

    # Security tools
    gnupg

    # Nix tools
    nix-tree
    nix-du
  ];

  # Program defaults
  programs = {
    # Enable command-not-found
    command-not-found.enable = true;

    # Enable completion for system packages
    bash.completion.enable = true;

    # GPG agent for key management
    gnupg.agent = {
      enable = true;
      enableSSHSupport = true;
    };

    # Git configuration
    git = {
      enable = true;
      config = {
        init.defaultBranch = "main";
        pull.rebase = true;
        push.autoSetupRemote = true;
      };
    };
  };

  # Services configuration
  services = {
    # SSH daemon with secure defaults
    openssh = {
      enable = true;
      settings = {
        # Security settings
        PermitRootLogin = "no";
        PasswordAuthentication = false;
        KbdInteractiveAuthentication = false;
        X11Forwarding = false;

        # Performance settings
        UseDns = false;

        # Protocol and cipher settings
        Protocol = 2;
        Ciphers = [
          "aes256-gcm@openssh.com"
          "aes128-gcm@openssh.com"
          "aes256-ctr"
          "aes192-ctr"
          "aes128-ctr"
        ];

        # Connection settings
        MaxAuthTries = 3;
        ClientAliveInterval = 300;
        ClientAliveCountMax = 2;
        LoginGraceTime = 30;
      };

      # Generate host keys
      hostKeys = [
        {
          path = "/etc/ssh/ssh_host_ed25519_key";
          type = "ed25519";
        }
        {
          path = "/etc/ssh/ssh_host_rsa_key";
          type = "rsa";
          bits = 4096;
        }
      ];
    };

    # Fail2ban for intrusion detection
    fail2ban = {
      enable = true;
      bantime = "1h";
      bantime-increment = {
        enable = true;
        maxtime = "168h"; # 1 week max
        factor = "4";
      };
      maxretry = 3;
      ignoreIP = [
        "127.0.0.1/8"
        "::1"
        "10.0.0.0/8"
        "172.16.0.0/12"
        "192.168.0.0/16"
      ];
    };

    # System logging
    journald.settings = {
      SystemMaxUse = "100M";
      SystemMaxFileSize = "10M";
      SystemKeepFree = "1G";
    };
  };

  # User configuration
  users = {
    # Disable mutable users for security
    mutableUsers = lib.mkDefault false;

    # Default shell
    defaultUserShell = pkgs.bash;

    # Root user configuration
    users.root = {
      # Disable root login
      hashedPassword = "!";

      # Root SSH keys (empty by default)
      openssh.authorizedKeys.keys = [];
    };
  };

  # System state version
  system.stateVersion = lib.mkDefault "24.11";

  # Locale and timezone
  time.timeZone = lib.mkDefault "UTC";
  i18n.defaultLocale = "en_US.UTF-8";

  # Console configuration
  console = {
    font = "Lat2-Terminus16";
    useXkbConfig = true;
  };

  # Hardware defaults
  hardware = {
    # Enable firmware updates
    enableRedistributableFirmware = lib.mkDefault true;

    # Enable microcode updates
    cpu.intel.updateMicrocode = lib.mkDefault config.hardware.enableRedistributableFirmware;
    cpu.amd.updateMicrocode = lib.mkDefault config.hardware.enableRedistributableFirmware;
  };

  # Systemd configuration
  systemd = {
    # Faster boot
    services.NetworkManager-wait-online.enable = lib.mkDefault false;

    # System hardening
    extraConfig = ''
      DefaultTimeoutStopSec=10s
      DefaultTimeoutStartSec=30s
    '';

    # Coredump handling
    coredump.enable = lib.mkDefault false;
  };

  # Environment variables
  environment.variables = {
    EDITOR = "nano";
    PAGER = "less -R";
  };
}
