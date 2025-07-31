{
  config,
  lib,
  pkgs,
  modulesPath,
  ...
}: {
  imports = [
    (modulesPath + "/installer/scan/not-detected.nix")
    ../disko/nixies-zfs.nix
  ];

  # Hardware configuration based on nixos-generate-config output
  boot.initrd.availableKernelModules = [ "nvme" "xhci_pci" "usbhid" "uas" "sd_mod" ];
  boot.extraModulePackages = [ ];

  # Boot loader configuration
  boot.loader = {
    systemd-boot.enable = true;
    efi.canTouchEfiVariables = true;
    timeout = lib.mkForce 3;
  };

  # ZFS support
  boot.supportedFilesystems = [ "zfs" ];
  boot.zfs.devNodes = "/dev/disk/by-id";
  networking.hostId = "8425e349"; # Required for ZFS

  # Network interfaces detected by hardware scan
  networking = {
    hostName = "nixies";
    useDHCP = false;
    
    # Intel X710 bonding configuration
    bonds.bond0 = {
      interfaces = [ "enp4s0f0np0" "enp4s0f1np1" ];
      driverOptions = {
        mode = "802.3ad";
        miimon = "100";
        lacp_rate = "fast";
        xmit_hash_policy = "layer3+4";
      };
    };
    
    interfaces.bond0.useDHCP = true;
    
    # Disable firewall
    firewall.enable = lib.mkForce false;
  };

  # Hardware platform
  nixpkgs.hostPlatform = lib.mkDefault "x86_64-linux";
  hardware.cpu.amd.updateMicrocode = lib.mkDefault config.hardware.enableRedistributableFirmware;

  # Basic unified configuration
  unified = {
    core = {
      enable = true;
      security.level = "standard";
      performance.enable = true;
    };
  };

  # User configuration
  users = {
    mutableUsers = true;
    users.amoon = {
      isNormalUser = true;
      extraGroups = [ "wheel" "networkmanager" ];
      shell = pkgs.bash;
      description = "System Administrator";
      initialPassword = "nixos";
      openssh.authorizedKeys.keys = [
        "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIA898oqxREsBRW49hvI92CPWTebvwPoUeMSq5VMyzoM3 amoon@starbux.us"
      ];
    };
    users.root = {
      openssh.authorizedKeys.keys = [
        "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIA898oqxREsBRW49hvI92CPWTebvwPoUeMSq5VMyzoM3 amoon@starbux.us"
      ];
    };
  };

  # Essential system packages
  environment.systemPackages = with pkgs; [
    neovim
    git
    wget
    curl
    htop
    btop
    tree
    rsync
    lact # AMD GPU control
    nvtop # GPU monitoring
  ];

  # Enable SSH for remote access
  services.openssh = {
    enable = true;
    settings = {
      PasswordAuthentication = lib.mkForce true;
      PermitRootLogin = lib.mkForce "yes";
    };
  };

  # Enable sudo without password for wheel group
  security.sudo.wheelNeedsPassword = lib.mkForce false;

  # Enable zram swap
  zramSwap = {
    enable = true;
    memoryPercent = 50; # Use up to 50% of RAM for zram (16GB)
    algorithm = "zstd";
  };

  # AMD GPU configuration for Radeon 7800XT (RDNA3)
  hardware.graphics = {
    enable = true;
    enable32Bit = true;
    extraPackages = with pkgs; [
      amdvlk
      rocmPackages.clr.icd
      rocmPackages.clr
    ];
    extraPackages32 = with pkgs; [
      driversi686Linux.amdvlk
    ];
  };

  # Kernel modules for AMD GPU
  boot.initrd.kernelModules = [ "amdgpu" ];
  boot.kernelModules = [ "kvm-amd" "amdgpu" ];
  boot.kernelParams = [
    "amd_pstate=active"
    "amdgpu.ppfeaturemask=0xffffffff"
    "amdgpu.gpu_recovery=1"
    "amdgpu.dpm=1"
    "amdgpu.dc=1"
    "amdgpu.runpm=0"
    "amdgpu.audio=1"
  ];

  # TUI greeter
  services.greetd = {
    enable = true;
    settings = {
      default_session = {
        command = "${pkgs.greetd.tuigreet}/bin/tuigreet --time --cmd bash";
        user = "greeter";
      };
    };
  };

  # Sysctl optimizations for 20Gbps networking
  boot.kernel.sysctl = {
    # Network performance
    "net.core.rmem_max" = 134217728;
    "net.core.wmem_max" = 134217728;
    "net.ipv4.tcp_rmem" = "4096 87380 134217728";
    "net.ipv4.tcp_wmem" = "4096 65536 134217728";
    "net.core.netdev_max_backlog" = 30000;
    "net.ipv4.tcp_congestion_control" = "bbr";
    "net.ipv4.tcp_mtu_probing" = 1;
    "net.core.default_qdisc" = "fq";
    "net.ipv4.tcp_slow_start_after_idle" = 0;
    "net.ipv4.tcp_no_metrics_save" = 1;
    
    # Intel X710 specific
    "net.core.netdev_budget" = 600;
    "net.core.dev_weight" = 64;
    
    # ZFS memory tuning for 32GB RAM
    "vm.min_free_kbytes" = 1048576; # 1GB
    "vm.swappiness" = 10;
  };

  # ZFS configuration optimized for 32GB RAM
  boot.zfs = {
    extraPools = [ "rpool" ];
    forceImportRoot = false;
  };
  
  # ZFS module parameters
  boot.extraModprobeConfig = ''
    # ZFS ARC size: 8-16GB for 32GB system
    options zfs zfs_arc_min=8589934592
    options zfs zfs_arc_max=17179869184
    options zfs zfs_prefetch_disable=0
    options zfs zfs_txg_timeout=5
    options zfs l2arc_noprefetch=0
    options zfs l2arc_write_max=134217728
    options zfs zfs_vdev_async_read_max_active=8
    options zfs zfs_vdev_async_write_max_active=8
    
    # Intel X710 driver options
    options i40e max_vfs=0
  '';

  # ZFS services
  services.zfs = {
    autoScrub.enable = true;
    autoScrub.interval = "weekly";
    trim.enable = true;
  };

  # Enable ZFS dedup on nix store dataset
  systemd.services.zfs-enable-dedup = {
    description = "Enable ZFS deduplication on nix store";
    wantedBy = [ "multi-user.target" ];
    after = [ "zfs-import.target" ];
    serviceConfig = {
      Type = "oneshot";
      ExecStart = "${pkgs.zfs}/bin/zfs set dedup=on rpool/nixos/nix";
      RemainAfterExit = true;
    };
  };

  # Use latest kernel for best hardware support
  boot.kernelPackages = pkgs.linuxPackages_latest;

  # System state version
  system.stateVersion = "24.11";
}