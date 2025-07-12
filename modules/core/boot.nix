{
  config,
  lib,
  pkgs,
  ...
}: {
  # Boot and system initialization configuration
  options.unified.core.boot = with lib; {
    enable = mkEnableOption "unified boot configuration" // {default = true;};
    
    loader = mkOption {
      type = types.enum ["systemd-boot" "grub"];
      default = "systemd-boot";
      description = "Boot loader to use";
    };
    
    kernel = {
      hardening = mkEnableOption "kernel hardening parameters";
      
      latestKernel = mkEnableOption "use latest kernel version";
      
      customParams = mkOption {
        type = types.listOf types.str;
        default = [];
        description = "Additional kernel parameters";
      };
    };
    
    plymouth = mkEnableOption "Plymouth boot splash screen";
    
    initrd = {
      availableKernelModules = mkOption {
        type = types.listOf types.str;
        default = [
          # Common storage drivers
          "xhci_pci"
          "ehci_pci"
          "ahci"
          "usbhid"
          "usb_storage"
          "sd_mod"
          "sr_mod"
          
          # File system support
          "ext4"
          "vfat"
          
          # Network drivers for netboot
          "e1000e"
          "r8169"
        ];
        description = "Kernel modules available in initrd";
      };
      
      luks = mkEnableOption "LUKS encryption support in initrd";
    };
    
    tmpOnTmpfs = mkEnableOption "mount /tmp on tmpfs" // {default = true;};
  };

  config = lib.mkIf config.unified.core.boot.enable {
    # Boot loader configuration
    boot = {
      # Loader setup
      loader = lib.mkMerge [
        (lib.mkIf (config.unified.core.boot.loader == "systemd-boot") {
          systemd-boot = {
            enable = true;
            configurationLimit = 10;
            editor = false; # Security: disable boot entry editing
          };
          efi.canTouchEfiVariables = true;
        })
        
        (lib.mkIf (config.unified.core.boot.loader == "grub") {
          grub = {
            enable = true;
            device = "nodev";
            efiSupport = true;
            enableCryptodisk = config.unified.core.boot.initrd.luks;
          };
          efi.canTouchEfiVariables = true;
        })
      ];

      # Kernel configuration
      kernelPackages = lib.mkIf config.unified.core.boot.kernel.latestKernel
        pkgs.linuxPackages_latest;
      
      kernelParams = 
        config.unified.core.boot.kernel.customParams
        ++ lib.optionals config.unified.core.boot.kernel.hardening [
          # Security hardening
          "slub_debug=FZP"
          "init_on_alloc=1"
          "init_on_free=1"
          "page_alloc.shuffle=1"
          "randomize_kstack_offset=on"
          "debugfs=off"
          "oops=panic"
          "module.sig_enforce=1"
          "lockdown=confidentiality"
          "mce=0"
          "page_poison=1"
          "vsyscall=none"
          
          # Performance
          "mitigations=auto"
        ];

      # Initrd configuration
      initrd = {
        availableKernelModules = config.unified.core.boot.initrd.availableKernelModules;
        
        luks.devices = lib.mkIf config.unified.core.boot.initrd.luks {
          # Placeholder for LUKS devices - to be configured per system
        };
        
        systemd.enable = true; # Use systemd in initrd for better boot process
      };

      # Plymouth boot splash
      plymouth = lib.mkIf config.unified.core.boot.plymouth {
        enable = true;
        theme = "breeze";
      };

      # Tmp filesystem
      tmp = lib.mkIf config.unified.core.boot.tmpOnTmpfs {
        useTmpfs = true;
        tmpfsSize = "50%";
        cleanOnBoot = true;
      };

      # Kernel modules
      kernelModules = [
        # Virtualization support
        "kvm-intel"
        "kvm-amd"
      ];

      # System control settings
      kernel.sysctl = {
        # Basic performance tuning
        "vm.swappiness" = lib.mkDefault 10;
        "vm.vfs_cache_pressure" = lib.mkDefault 50;
        "vm.dirty_ratio" = lib.mkDefault 15;
        "vm.dirty_background_ratio" = lib.mkDefault 5;
        
        # Network performance
        "net.core.default_qdisc" = "fq";
        "net.ipv4.tcp_congestion_control" = "bbr";
        
        # Security (basic level)
        "net.ipv4.conf.all.accept_redirects" = 0;
        "net.ipv4.conf.default.accept_redirects" = 0;
        "net.ipv6.conf.all.accept_redirects" = 0;
        "net.ipv6.conf.default.accept_redirects" = 0;
        "net.ipv4.conf.all.send_redirects" = 0;
        "net.ipv4.conf.default.send_redirects" = 0;
        "net.ipv4.conf.all.accept_source_route" = 0;
        "net.ipv4.conf.default.accept_source_route" = 0;
        "net.ipv6.conf.all.accept_source_route" = 0;
        "net.ipv6.conf.default.accept_source_route" = 0;
      };

      # Console configuration
      consoleLogLevel = 3; # Reduce console spam
      
      # Boot timeout
      timeout = 5;
    };

    # Additional boot-related system configuration
    systemd = {
      # Watchdog configuration
      watchdog = {
        runtimeTime = "20s";
        rebootTime = "30s";
      };
      
      # Boot performance
      services = {
        # Faster boot
        "systemd-udev-settle".enable = false;
        "NetworkManager-wait-online".enable = false;
      };
    };

    # Hardware detection and module loading
    hardware = {
      enableAllFirmware = lib.mkDefault true;
      enableRedistributableFirmware = lib.mkDefault true;
    };
  };
}