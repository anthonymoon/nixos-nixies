{
  config,
  lib,
  pkgs,
  ...
}: {
  meta = {
    name = "qemu";
    description = "QEMU-optimized virtual machine profile with performance enhancements";
    maintainers = ["nixos-unified"];
  };

  imports = [
    ./base.nix
  ];

  # QEMU-specific unified configuration
  unified = {
    # Core settings for VMs
    core = {
      enable = true;
      security.level = "basic"; # Relaxed security for VMs
      performance.enable = true;
    };

    # VM-optimized hardware
    hardware = {
      enable = true;
      vm = true;
      qemu = true;
      graphics.acceleration = false; # Disable for headless VMs
    };

    # Networking optimized for VMs
    networking = {
      enable = true;
      vm-optimized = true;
      firewall.enable = false; # Disabled for VM networking
    };
  };

  # QEMU guest optimizations
  services.qemuGuest = {
    enable = true;
  };

  # SPICE guest agent for better VM integration
  services.spice-vdagentd = {
    enable = true;
  };

  # VM-specific boot configuration
  boot = {
    # Faster boot for VMs
    loader = {
      timeout = 1;
      systemd-boot.editor = false;
    };

    # QEMU-optimized kernel parameters
    kernelParams = [
      "quiet"
      "loglevel=3"
      "systemd.show_status=auto"
      "rd.udev.log_level=3"

      # VM-specific optimizations
      "elevator=noop" # Simple I/O scheduler for VMs
      "intel_idle.max_cstate=1" # Prevent deep sleep states
      "processor.max_cstate=1" # Better VM responsiveness
      "idle=poll" # Polling idle for VMs
    ];

    # VM kernel modules
    kernelModules = [
      "virtio_balloon" # Memory ballooning
      "virtio_console" # Serial console
      "virtio_rng" # Hardware RNG
      "virtio_net" # Network
      "virtio_blk" # Block devices
      "virtio_scsi" # SCSI
      "virtio_gpu" # Graphics
    ];

    # Available kernel modules for VMs
    initrd.availableKernelModules = [
      "ahci"
      "xhci_pci"
      "virtio_pci"
      "virtio_scsi"
      "virtio_blk"
      "sd_mod"
      "sr_mod"
    ];

    # Optimize initrd for VMs
    initrd = {
      compressor = "zstd";
      compressorArgs = ["-19" "-T0"];
    };

    # Faster temporary storage for VMs
    tmp = {
      useTmpfs = true;
      tmpfsSize = "50%";
      cleanOnBoot = true;
    };
  };

  # Hardware configuration for VMs
  hardware = {
    # Enable basic graphics for VMs
    opengl = {
      enable = true;
      driSupport = true;
    };

    # CPU microcode not needed in VMs
    cpu.intel.updateMicrocode = lib.mkForce false;
    cpu.amd.updateMicrocode = lib.mkForce false;

    # VM-specific hardware settings
    enableRedistributableFirmware = false;
  };

  # Network configuration optimized for VMs
  networking = {
    # Use predictable interface names
    usePredictableInterfaceNames = true;

    # Disable firewall for VM networking
    firewall.enable = false;

    # Optimize network for virtualization
    dhcpcd.enable = false;
    useNetworkd = true;

    # systemd-networkd configuration for VMs
    systemd.network = {
      enable = true;

      # Match all network interfaces in VMs
      networks."10-vm" = {
        matchConfig.Type = "ether";
        networkConfig = {
          DHCP = "yes";
          IPv6AcceptRA = true;
        };
        dhcpV4Config = {
          UseDNS = true;
          UseRoutes = true;
          UseMTU = true;
        };
        dhcpV6Config = {
          UseDNS = true;
        };
      };
    };
  };

  # Performance optimizations for VMs
  boot.kernel.sysctl = {
    # Memory management for VMs
    "vm.swappiness" = 10;
    "vm.dirty_background_ratio" = 5;
    "vm.dirty_ratio" = 10;
    "vm.dirty_writeback_centisecs" = 1500;
    "vm.dirty_expire_centisecs" = 3000;

    # Network optimizations for VMs
    "net.core.rmem_default" = 262144;
    "net.core.rmem_max" = 16777216;
    "net.core.wmem_default" = 262144;
    "net.core.wmem_max" = 16777216;
    "net.core.netdev_max_backlog" = 5000;

    # TCP optimizations for VMs
    "net.ipv4.tcp_rmem" = "4096 65536 16777216";
    "net.ipv4.tcp_wmem" = "4096 65536 16777216";
    "net.ipv4.tcp_congestion_control" = "bbr";

    # File system optimizations
    "fs.file-max" = 2097152;
    "fs.nr_open" = 1048576;
  };

  # Systemd optimizations for VMs
  systemd = {
    # Faster service startup
    extraConfig = ''
      DefaultTimeoutStopSec=30s
      DefaultTimeoutStartSec=30s
      DefaultDeviceTimeoutSec=30s
    '';

    # Disable unnecessary services for VMs
    services = {
      # Don't wait for network in VMs
      NetworkManager-wait-online.enable = false;
      systemd-networkd-wait-online.enable = false;

      # Disable power management in VMs
      systemd-logind.extraConfig = ''
        HandlePowerKey=ignore
        HandleSuspendKey=ignore
        HandleHibernateKey=ignore
        HandleLidSwitch=ignore
      '';
    };

    # VM-specific service overrides
    user.services = {
      # Faster user service startup
      default.environment.SYSTEMD_DEFAULT_TIMEOUT = "30";
    };
  };

  # Essential packages for VM environments
  environment.systemPackages = with pkgs; [
    # VM guest tools
    qemu-utils

    # Network utilities
    ethtool
    tcpdump
    iperf3

    # System monitoring
    htop
    iotop
    nload

    # File management
    tree
    rsync

    # Text processing
    vim
    nano

    # System utilities
    pciutils
    usbutils
    lshw
    dmidecode

    # Performance testing
    stress
    sysbench
  ];

  # Users configuration for VMs
  users = {
    # Allow password authentication for VMs (easier access)
    mutableUsers = lib.mkDefault true;

    users = {
      # VM user with convenient access
      vm-user = {
        isNormalUser = true;
        extraGroups = ["wheel" "networkmanager"];
        password = "vm"; # Simple password for VMs # pragma: allowlist secret
        description = "VM User";
      };

      # Root access for VM management
      root = {
        password = "vm"; # Simple password for VMs # pragma: allowlist secret
      };
    };
  };

  # Services configuration for VMs
  services = {
    # Enable SSH for VM management
    openssh = {
      enable = true;
      settings = {
        # Relaxed SSH settings for VMs
        PermitRootLogin = "yes";
        PasswordAuthentication = true;
        X11Forwarding = true;

        # VM-optimized SSH settings
        UseDns = false;
        ClientAliveInterval = 60;
        ClientAliveCountMax = 3;
      };
    };

    # Time synchronization for VMs
    timesyncd = {
      enable = true;
      servers = [
        "time.cloudflare.com"
        "pool.ntp.org"
      ];
    };

    # Logging configuration for VMs
    journald.settings = {
      SystemMaxUse = "100M";
      SystemMaxFileSize = "10M";
      SystemKeepFree = "500M";
      RuntimeMaxUse = "50M";
    };

    # Automatic garbage collection
    cron = {
      enable = true;
      systemCronJobs = [
        # Weekly Nix store cleanup
        "0 3 * * 0 root nix-collect-garbage -d"

        # Daily log cleanup
        "0 2 * * * root journalctl --vacuum-time=7d"
      ];
    };
  };

  # File systems configuration for VMs
  fileSystems = {
    # Root filesystem with VM optimizations
    "/" = {
      device = "/dev/disk/by-label/nixos";
      fsType = "ext4";
      options = [
        "noatime" # Don't update access times
        "nodiratime" # Don't update directory access times
        "discard" # Enable TRIM for SSDs
      ];
    };

    # Boot partition
    "/boot" = {
      device = "/dev/disk/by-label/boot";
      fsType = "vfat";
      options = [
        "noatime"
      ];
    };

    # Temporary filesystem in memory
    "/tmp" = {
      device = "tmpfs";
      fsType = "tmpfs";
      options = [
        "defaults"
        "size=1G"
        "mode=1777"
      ];
    };
  };

  # Swap configuration for VMs
  swapDevices = [
    {
      device = "/dev/disk/by-label/swap";
      priority = 100;
    }
  ];

  # VM-specific environment variables
  environment.variables = {
    # Indicate this is a VM environment
    NIXOS_VM = "1";
    NIXOS_VM_TYPE = "qemu";

    # Performance tuning
    EDITOR = "nano";
    PAGER = "less -R";
  };

  # Console configuration for VMs
  console = {
    font = "Lat2-Terminus16";
    keyMap = "us";
    useXkbConfig = true;
  };

  # Locale and timezone for VMs
  time.timeZone = lib.mkDefault "UTC";
  i18n.defaultLocale = "en_US.UTF-8";

  # Security settings appropriate for VMs
  security = {
    # Allow wheel group sudo without password for VMs
    sudo = {
      enable = true;
      wheelNeedsPassword = false; # pragma: allowlist secret
    };

    # Disable some security features for VM convenience
    apparmor.enable = false;

    # Enable polkit for desktop VMs
    polkit.enable = true;
  };

  # VM state version
  system.stateVersion = lib.mkDefault "24.11";

  # Performance monitoring and debugging
  programs = {
    # System information tools
    htop.enable = true;
    iotop.enable = true;

    # Network debugging
    mtr.enable = true;

    # File system tools
    fuse.userAllowOther = true;
  };

  # VM-specific system optimizations
  nixpkgs.config = {
    allowUnfree = true; # Allow unfree packages in VMs
  };

  # Nix configuration optimized for VMs
  nix = {
    settings = {
      # Reduce build parallelism in VMs
      max-jobs = 2;
      cores = 2;

      # Optimize for VM storage
      auto-optimise-store = true;
      min-free = 1024 * 1024 * 1024; # 1GB minimum free space
      max-free = 3 * 1024 * 1024 * 1024; # 3GB maximum free space

      # VM-specific substituters
      substituters = [
        "https://cache.nixos.org"
      ];
    };

    # More aggressive garbage collection for VMs
    gc = {
      automatic = true;
      dates = "daily";
      options = "--delete-older-than 3d";
    };

    # Optimize Nix store weekly
    optimise = {
      automatic = true;
      dates = ["03:00"];
    };
  };
}
