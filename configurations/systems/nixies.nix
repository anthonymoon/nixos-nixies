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
  boot.initrd.availableKernelModules = [ 
    "nvme" "nvme_core" "nvme_auth"
    "xhci_pci" "xhci_hcd" 
    "usbhid" "uas" "sd_mod" 
    "ahci" "sata_ahci"
  ];
  boot.extraModulePackages = [ ];
  
  # Additional kernel modules for hardware support
  boot.kernelModules = [ 
    "kvm-amd" "amdgpu" 
    "i40e" # Intel X710 NIC
    "iwlwifi" "iwlmvm" # Intel AX200 WiFi
    "ccp" # AMD Cryptographic Coprocessor
    "k10temp" # AMD CPU temperature monitoring
    "sp5100_tco" # AMD watchdog
    "piix4_smbus" # SMBus support
  ];

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
  nixpkgs.config.allowUnfree = true;
  hardware.cpu.amd.updateMicrocode = lib.mkDefault config.hardware.enableRedistributableFirmware;

  # Basic nixies configuration
  nixies = {
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
    amdgpu_top # AMD-specific GPU monitoring
    
    # NVMe/SSD management tools
    msecli         # Official Micron CLI (unfree)
    nvme-cli       # Open-source NVMe management
    smartmontools  # SMART monitoring
    zfs            # ZFS utilities
    
    # Gaming tools
    mangohud # FPS overlay
    gamescope # Wayland game compositor
    gamemode # Performance mode switcher
    vkbasalt # Vulkan post-processing
    
    # Wine and Proton dependencies
    wine-staging
    winetricks
    protontricks
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
  boot.kernelParams = [
    # AMD CPU/GPU optimizations
    "amd_pstate=active"
    "amd_iommu=on"
    "iommu=pt"
    "amdgpu.ppfeaturemask=0xffffffff"
    "amdgpu.gpu_recovery=1"
    "amdgpu.dpm=1"
    "amdgpu.dc=1"
    "amdgpu.runpm=0"
    "amdgpu.audio=1"
    
    # Disable CPU mitigations for performance
    "mitigations=off"
    
    # PCIe power management off for performance
    "pcie_aspm=off"
    "pcie_port_pm=off"
    
    # NVMe optimization
    "nvme_core.default_ps_max_latency_us=5500"
    "nvme.use_threaded_interrupts=1"
    "nvme.io_queue_depth=257"
    "nvme.poll_queues=8"
    "nvme.write_queues=4"
    
    # Network performance
    "net.ifnames=1"
    "biosdevname=0"
    
    # AMD Ryzen 5600X optimizations
    "processor.max_cstate=1"  # Disable deep C-states for lower latency
    "idle=poll"  # Maximum performance (increases power usage)
    "threadirqs"  # Better interrupt handling for Ryzen
    
    # General optimizations
    "nowatchdog"
    "nmi_watchdog=0"
    "preempt=voluntary"
    "transparent_hugepage=always"
    
    # Disable unnecessary features
    "nouveau.modeset=0"
    "nohibernate"
    
    # Logging
    "loglevel=4"
    
    # Security modules
    "lsm=landlock,yama,bpf"
    
    # Custom VT colors from your boot args
    "vt.default_red=0x00,0xCC,0x4E,0xC4,0x34,0x75,0x06,0xD3,0x55,0xEF,0x8A,0xFC,0x73,0xAD,0x34,0xEE"
    "vt.default_grn=0x00,0x00,0x9A,0xA0,0x65,0x50,0x98,0xD7,0x57,0x29,0xE2,0xE9,0x9F,0x7F,0xE2,0xEE"
    "vt.default_blu=0x00,0x00,0x06,0x00,0xA4,0x7B,0x9A,0xCF,0x53,0x29,0x29,0x4F,0xCF,0xA8,0xE2,0xEC"
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

  # Sysctl optimizations for 20Gbps networking and hardware
  boot.kernel.sysctl = {
    # Network performance for 20Gbps
    "net.core.rmem_max" = 268435456; # 256MB
    "net.core.wmem_max" = 268435456; # 256MB
    "net.ipv4.tcp_rmem" = "4096 87380 268435456";
    "net.ipv4.tcp_wmem" = "4096 65536 268435456";
    "net.core.netdev_max_backlog" = 50000;
    "net.ipv4.tcp_congestion_control" = lib.mkForce "bbr";
    "net.ipv4.tcp_mtu_probing" = 1;
    "net.core.default_qdisc" = lib.mkForce "fq";
    "net.ipv4.tcp_slow_start_after_idle" = 0;
    "net.ipv4.tcp_no_metrics_save" = 1;
    "net.ipv4.tcp_timestamps" = 0;
    "net.ipv4.tcp_sack" = 1;
    "net.ipv4.tcp_low_latency" = 1;
    
    # Intel X710 specific
    "net.core.netdev_budget" = 1200;
    "net.core.dev_weight" = 128;
    "net.core.busy_poll" = 50;
    "net.core.busy_read" = 50;
    
    # AMD Ryzen optimizations
    "kernel.sched_migration_cost_ns" = 5000000;
    "kernel.sched_autogroup_enabled" = 1;  # Better for desktop responsiveness
    "vm.zone_reclaim_mode" = 0;
    "vm.watermark_scale_factor" = 200;
    
    # ZFS-optimized memory management for 32GB RAM
    "vm.min_free_kbytes" = 2097152;  # 2GB minimum free for ZFS
    "vm.swappiness" = 1;  # Minimal swapping with ZFS
    "vm.dirty_ratio" = 10;  # Lower for ZFS
    "vm.dirty_background_ratio" = 5;
    "vm.vfs_cache_pressure" = 50;  # Prefer ZFS ARC over VFS cache
    "vm.max_map_count" = lib.mkForce 2147483642;
    
    # SSD optimizations
    "vm.page-cluster" = 0; # Disable swap readahead for SSDs
    "vm.dirty_expire_centisecs" = 12000;
    "vm.dirty_writeback_centisecs" = 6000;
    
    # Transparent hugepages
    "vm.nr_hugepages" = 1024;
    
    # NUMA optimizations for AMD
    "kernel.numa_balancing" = 1;
    
    # File system optimizations
    "fs.file-max" = 2097152;
    "fs.nr_open" = 1048576;
    "fs.inotify.max_user_watches" = 1048576;
    "fs.inotify.max_user_instances" = 8192;
    "fs.aio-max-nr" = 1048576;
  };

  # ZFS configuration optimized for 32GB RAM
  boot.zfs = {
    extraPools = [ "rpool" ];
    forceImportRoot = false;
  };
  
  # ZFS module parameters
  boot.extraModprobeConfig = ''
    # Optimize ZFS for NVMe with 32GB RAM
    options zfs zfs_arc_max=17179869184  # 16GB ARC max (50% of RAM)
    options zfs zfs_arc_min=8589934592   # 8GB ARC min (25% of RAM)
    options zfs zfs_arc_meta_limit_percent=75
    options zfs zfs_arc_dnode_limit_percent=40
    options zfs zfs_txg_timeout=5        # Faster transaction groups
    options zfs zfs_vdev_async_write_active_max_dirty_percent=60
    options zfs zfs_vdev_sync_write_max_active=16  # Increased for Ryzen 5600X
    options zfs zfs_vdev_sync_read_max_active=16
    options zfs zfs_vdev_async_read_max_active=16
    options zfs zfs_vdev_async_write_max_active=16
    options zfs zfs_prefetch_disable=0
    options zfs l2arc_write_boost=33554432   # 32MB for better NVMe utilization
    options zfs l2arc_write_max=33554432
    options zfs l2arc_noprefetch=0
    options zfs l2arc_headroom=8
    options zfs zfs_compressed_arc_enabled=1
    options zfs zfs_abd_scatter_enabled=1
    options zfs zfs_vdev_cache_size=16777216  # 16MB vdev cache
    
    # Intel X710 driver options for 20Gbps
    options i40e max_vfs=0
    options i40e int_mode=2
    options i40e rx_itr=0
    options i40e tx_itr=0
    
    # AMD GPU power management
    options amdgpu ppfeaturemask=0xffffffff
    options amdgpu gpu_recovery=1
    options amdgpu dpm=1
    options amdgpu dc=1
    options amdgpu runpm=0
    options amdgpu audio=1
    options amdgpu aspm=0
    options amdgpu bapm=1
    options amdgpu deep_color=1
    options amdgpu si_support=1
    options amdgpu cik_support=1
    
    # NVMe optimizations
    options nvme_core io_timeout=255
    options nvme_core max_retries=10
    options nvme_core multipath=Y
    
    # USB optimizations
    options usbcore autosuspend=-1
    options usbcore use_both_schemes=Y
    options usbcore initial_descriptor_timeout=10
    
    # Intel WiFi optimizations
    options iwlwifi power_save=0
    options iwlwifi led_mode=1
    options iwlmvm power_scheme=1
  '';

  # ZFS services
  services.zfs = {
    autoScrub.enable = true;
    autoScrub.interval = "weekly";
    trim.enable = true;  # Enable TRIM for ZFS pools
  };
  
  # I/O scheduler - none for NVMe with ZFS
  services.udev.extraRules = ''
    ACTION=="add|change", KERNEL=="nvme[0-9]*n[0-9]*", ATTR{queue/scheduler}="none"
  '';

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
  
  # Power management optimizations
  powerManagement = {
    enable = true;
    cpuFreqGovernor = lib.mkForce "performance";
  };
  
  # CPU performance settings
  systemd.services.cpu-performance = {
    description = "Set CPU performance settings";
    wantedBy = [ "multi-user.target" ];
    serviceConfig = {
      Type = "oneshot";
      RemainAfterExit = true;
      ExecStart = pkgs.writeShellScript "cpu-performance" ''
        # Disable CPU idle states for maximum performance
        for cpu in /sys/devices/system/cpu/cpu*/cpuidle/state*/disable; do
          echo 1 > $cpu 2>/dev/null || true
        done
        
        # Set performance governor
        for cpu in /sys/devices/system/cpu/cpu*/cpufreq/scaling_governor; do
          echo performance > $cpu 2>/dev/null || true
        done
        
        # Disable CPU frequency boost limits
        echo 1 > /sys/devices/system/cpu/cpufreq/boost 2>/dev/null || true
        
        # Set PCIe ASPM to performance
        echo performance > /sys/module/pcie_aspm/parameters/policy 2>/dev/null || true
      '';
    };
  };

  # Gaming optimizations
  programs.steam = {
    enable = true;
    remotePlay.openFirewall = true;
    dedicatedServer.openFirewall = true;
    gamescopeSession.enable = true;
  };

  # Enable gamemode for performance optimization
  programs.gamemode = {
    enable = true;
    settings = {
      general = {
        renice = 10;
        ioprio = 0;
        inhibit_screensaver = 1;
      };
      gpu = {
        apply_gpu_optimisations = "accept-responsibility";
        gpu_device = 0;
        amd_performance_level = "high";
      };
    };
  };

  # Nix-gaming optimizations
  services.pipewire.lowLatency = {
    enable = true;
    # 32 samples is ~0.7ms latency at 48kHz
    quantum = 32;
    rate = 48000;
  };

  # Platform optimizations from nix-gaming
  programs.steam.platformOptimizations.enable = true;

  # SMART monitoring for NVMe with conservative temperature warnings
  services.smartd = {
    enable = true;
    autodetect = lib.mkForce false;
    
    devices = [{
      device = "/dev/nvme0n1";
      options = "-a -o on -W 4,65,70";  # All attributes, offline testing, temperature warnings
    }];
  };
  
  # Enable Netdata for real-time monitoring
  services.netdata.enable = true;
  
  # Prometheus exporter for Grafana dashboards
  services.prometheus.exporters.smartctl = {
    enable = true;
    devices = [ "/dev/nvme0n1" ];
  };

  # Apply NVMe optimizations via system activation
  system.activationScripts.nvmeOptimize = ''
    echo kyber > /sys/block/nvme0n1/queue/scheduler
    echo 8 > /sys/block/nvme0n1/queue/nr_requests
    echo 2048 > /sys/block/nvme0n1/queue/max_sectors_kb
    echo 3333 > /sys/block/nvme0n1/queue/wbt_lat_usec
  '';

  # System state version
  system.stateVersion = "24.11";
}