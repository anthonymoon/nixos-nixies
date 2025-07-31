{
  config,
  lib,
  pkgs,
  ...
}: {
  nixies.core = {
    enable = true;
    security = {
      enable = true;
      level = lib.mkDefault "standard";
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
  boot = {
    tmp.cleanOnBoot = true;
    kernelParams = [
      "quiet"
      "loglevel=3"
    ];
    kernelPackages = lib.mkDefault pkgs.linuxPackages_latest;
  };
  nix = {
    settings = {
      experimental-features = ["nix-command" "flakes"];
      auto-optimise-store = true;
      max-jobs = "auto";
      cores = 0;
      allowed-users = ["@wheel"];
      trusted-users = ["@wheel"];
      substituters = [
        "https://cache.nixos.org"
      ];
      trusted-public-keys = [
        "cache.nixos.org-1:6NCHdD59X431o0gWypbMrAURkbJ16ZPMQFGspcDShjY="
      ];
    };
    gc = {
      automatic = true;
      dates = "weekly";
      options = lib.mkDefault "--delete-older-than 30d";
    };
    optimise = {
      automatic = true;
      dates = ["weekly"];
    };
  };
  networking = {
    firewall = {
      enable = true;
      allowPing = true;
      logRefusedConnections = false;
    };
    useNetworkd = lib.mkDefault false;
  };
  security = {
    sudo = {
      enable = true;
      wheelNeedsPassword = true;
      execWheelOnly = true;
    };
    apparmor.enable = lib.mkDefault true;
    rtkit.enable = true;
  };
  environment.systemPackages = with pkgs; [
    nano
    vim
    file
    tree
    curl
    wget
    dig
    htop
    iotop
    lsof
    pciutils
    usbutils
    unzip
    zip
    git
    killall
    psmisc
    neofetch
    gnupg
    nix-tree
    nix-du
  ];
  programs = {
    command-not-found.enable = true;
    bash.completion.enable = true;
    gnupg.agent = {
      enable = true;
      enableSSHSupport = true;
    };
    git = {
      enable = true;
      config = {
        init.defaultBranch = "main";
        pull.rebase = true;
        push.autoSetupRemote = true;
      };
    };
  };
  services = {
    openssh = {
      enable = true;
      settings = {
        PermitRootLogin = "no";
        PasswordAuthentication = false;
        KbdInteractiveAuthentication = false;
        X11Forwarding = false;
        UseDns = false;
        Protocol = 2;
        Ciphers = [
          "aes256-gcm@openssh.com"
          "aes128-gcm@openssh.com"
          "aes256-ctr"
          "aes192-ctr"
          "aes128-ctr"
        ];
        MaxAuthTries = 3;
        ClientAliveInterval = 300;
        ClientAliveCountMax = 2;
        LoginGraceTime = 30;
      };
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
    # fail2ban disabled - requires firewall to be enabled
    journald.extraConfig = ''
      SystemMaxUse=100M
      SystemMaxFileSize=10M
      SystemKeepFree=1G
    '';
  };
  users = {
    mutableUsers = lib.mkDefault false;
    defaultUserShell = pkgs.bash;
    users.root = {
      hashedPassword = "!";
      openssh.authorizedKeys.keys = [];
    };
  };
  system.stateVersion = lib.mkDefault "24.11";
  fileSystems."/" = lib.mkDefault {
    device = "/dev/disk/by-label/nixos";
    fsType = "ext4";
  };
  time.timeZone = lib.mkDefault "UTC";
  i18n.defaultLocale = "en_US.UTF-8";
  console = {
    font = "Lat2-Terminus16";
    useXkbConfig = true;
  };
  hardware = {
    enableRedistributableFirmware = lib.mkDefault true;
    cpu.intel.updateMicrocode = lib.mkDefault config.hardware.enableRedistributableFirmware;
    cpu.amd.updateMicrocode = lib.mkDefault config.hardware.enableRedistributableFirmware;
  };
  systemd = {
    services.NetworkManager-wait-online.enable = lib.mkDefault false;
    extraConfig = ''
      DefaultTimeoutStopSec=10s
      DefaultTimeoutStartSec=30s
    '';
    coredump.enable = lib.mkDefault false;
  };
  environment.variables = {
    EDITOR = "nano";
    PAGER = lib.mkDefault "less -R";
  };
}
