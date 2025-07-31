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
      security.level = "basic";
      performance.enable = true;
    };
  };
  services.qemuGuest = {
    enable = true;
  };
  services.spice-vdagentd = {
    enable = true;
  };
  boot = {
    loader = {
      timeout = 1;
      systemd-boot.editor = false;
    };
    kernelParams = [
      "quiet"
      "loglevel=3"
      "systemd.show_status=auto"
      "rd.udev.log_level=3"
      "elevator=noop"
      "intel_idle.max_cstate=1"
      "processor.max_cstate=1"
      "idle=poll"
    ];
    kernelModules = [
      "virtio_balloon"
      "virtio_console"
      "virtio_rng"
      "virtio_net"
      "virtio_blk"
      "virtio_scsi"
      "virtio_gpu"
    ];
    initrd.availableKernelModules = [
      "ahci"
      "xhci_pci"
      "virtio_pci"
      "virtio_scsi"
      "virtio_blk"
      "sd_mod"
      "sr_mod"
    ];
    initrd = {
      compressor = "zstd";
      compressorArgs = ["-19" "-T0"];
    };
    tmp = {
      useTmpfs = true;
      tmpfsSize = "50%";
      cleanOnBoot = true;
    };
  };
  hardware = {
    graphics = {
      enable = true;
    };
    cpu.intel.updateMicrocode = lib.mkForce false;
    cpu.amd.updateMicrocode = lib.mkForce false;
    enableRedistributableFirmware = false;
  };
  networking = {
    usePredictableInterfaceNames = true;
    firewall.enable = lib.mkForce false;
    dhcpcd.enable = false;
    useNetworkd = true;
  };
  systemd.network = {
    enable = true;
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
  boot.kernel.sysctl = {
    "vm.swappiness" = 10;
    "vm.dirty_background_ratio" = 5;
    "vm.dirty_ratio" = 10;
    "vm.dirty_writeback_centisecs" = 1500;
    "vm.dirty_expire_centisecs" = 3000;
    "net.core.rmem_default" = 262144;
    "net.core.rmem_max" = 16777216;
    "net.core.wmem_default" = 262144;
    "net.core.wmem_max" = 16777216;
    "net.core.netdev_max_backlog" = 5000;
    "net.ipv4.tcp_rmem" = "4096 65536 16777216";
    "net.ipv4.tcp_wmem" = "4096 65536 16777216";
    "net.ipv4.tcp_congestion_control" = "bbr";
    "fs.file-max" = 2097152;
    "fs.nr_open" = 1048576;
  };
  systemd = {
    extraConfig = ''
      DefaultTimeoutStopSec=30s
      DefaultTimeoutStartSec=30s
      DefaultDeviceTimeoutSec=30s
    '';
    services = {
      NetworkManager-wait-online.enable = false;
      systemd-networkd-wait-online.enable = lib.mkForce false;
    };
    user.services = {
      default.environment.SYSTEMD_DEFAULT_TIMEOUT = "30";
    };
  };
  environment.systemPackages = with pkgs; [
    qemu-utils
    ethtool
    tcpdump
    iperf3
    htop
    iotop
    nload
    tree
    rsync
    vim
    nano
    pciutils
    usbutils
    lshw
    dmidecode
    stress
    sysbench
  ];
  users = {
    mutableUsers = lib.mkForce true;
    users = {
      vm-user = {
        isNormalUser = true;
        extraGroups = ["wheel" "networkmanager"];
        password = "vm";
        description = "VM User";
      };
      root = {
        initialPassword = "vm";
      };
    };
  };
  services = {
    openssh = {
      enable = true;
      settings = {
        PermitRootLogin = lib.mkForce "yes";
        PasswordAuthentication = lib.mkForce true;
        X11Forwarding = lib.mkForce true;
        UseDns = false;
        ClientAliveInterval = lib.mkForce 60;
        ClientAliveCountMax = lib.mkForce 3;
      };
    };
    timesyncd = {
      enable = true;
      servers = [
        "time.cloudflare.com"
        "pool.ntp.org"
      ];
    };
    logind.extraConfig = ''
      HandlePowerKey=ignore
      HandleSuspendKey=ignore
      HandleHibernateKey=ignore
      HandleLidSwitch=ignore
    '';
    journald.extraConfig = ''
      SystemMaxUse=100M
      SystemMaxFileSize=10M
      SystemKeepFree=500M
      RuntimeMaxUse=50M
    '';
    cron = {
      enable = true;
      systemCronJobs = [
        "0 3 * * 0 root nix-collect-garbage -d"
        "0 2 * * * root journalctl --vacuum-time=7d"
      ];
    };
  };
  fileSystems = {
    "/" = {
      device = "/dev/disk/by-label/nixos";
      fsType = "ext4";
      options = [
        "noatime"
        "nodiratime"
        "discard"
      ];
    };
    "/boot" = {
      device = "/dev/disk/by-label/boot";
      fsType = "vfat";
      options = [
        "noatime"
      ];
    };
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
  swapDevices = [
    {
      device = "/dev/disk/by-label/swap";
      priority = 100;
    }
  ];
  environment.variables = {
    NIXOS_VM = "1";
    NIXOS_VM_TYPE = "qemu";
    EDITOR = "nano";
    PAGER = lib.mkForce "less -R";
  };
  console = {
    font = "Lat2-Terminus16";
    keyMap = lib.mkDefault "us";
    useXkbConfig = true;
  };
  time.timeZone = lib.mkDefault "UTC";
  i18n.defaultLocale = "en_US.UTF-8";
  security = {
    sudo = {
      enable = true;
      wheelNeedsPassword = false;
    };
    apparmor.enable = false;
    polkit.enable = true;
  };
  system.stateVersion = lib.mkDefault "24.11";
  programs = {
    htop.enable = true;
    iotop.enable = true;
    mtr.enable = true;
    fuse.userAllowOther = true;
  };
  nixpkgs.config = {
    allowUnfree = true;
  };
  nix = {
    settings = {
      max-jobs = lib.mkDefault 2;
      cores = lib.mkDefault 2;
      auto-optimise-store = true;
      min-free = 1024 * 1024 * 1024;
      max-free = 3 * 1024 * 1024 * 1024;
      substituters = [
        "https://cache.nixos.org"
      ];
    };
    gc = {
      automatic = true;
      dates = "daily";
      options = "--delete-older-than 3d";
    };
    optimise = {
      automatic = true;
      dates = ["03:00"];
    };
  };
}
