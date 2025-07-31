{
  config,
  lib,
  pkgs,
  ...
}: {
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
          "xhci_pci"
          "ehci_pci"
          "ahci"
          "usbhid"
          "usb_storage"
          "sd_mod"
          "sr_mod"
          "ext4"
          "vfat"
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
    boot = {
      loader = lib.mkMerge [
        (lib.mkIf (config.unified.core.boot.loader == "systemd-boot") {
          systemd-boot = {
            enable = true;
            configurationLimit = 10;
            editor = false;
          };
          efi.canTouchEfiVariables = true;
          timeout = 5;
        })
        (lib.mkIf (config.unified.core.boot.loader == "grub") {
          grub = {
            enable = true;
            device = "nodev";
            efiSupport = true;
            enableCryptodisk = config.unified.core.boot.initrd.luks;
          };
          efi.canTouchEfiVariables = true;
          timeout = 5;
        })
      ];
      kernelPackages =
        lib.mkIf config.unified.core.boot.kernel.latestKernel
        pkgs.linuxPackages_latest;
      kernelParams =
        config.unified.core.boot.kernel.customParams
        ++ lib.optionals config.unified.core.boot.kernel.hardening [
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
          "mitigations=auto"
        ];
      initrd = {
        availableKernelModules = config.unified.core.boot.initrd.availableKernelModules;
        luks.devices =
          lib.mkIf config.unified.core.boot.initrd.luks {
          };
        systemd.enable = true;
      };
      plymouth = lib.mkIf config.unified.core.boot.plymouth {
        enable = true;
        theme = "breeze";
      };
      tmp = lib.mkIf config.unified.core.boot.tmpOnTmpfs {
        useTmpfs = true;
        tmpfsSize = "50%";
        cleanOnBoot = true;
      };
      kernelModules = [
        "kvm-intel"
        "kvm-amd"
      ];
      kernel.sysctl = {
        "vm.swappiness" = lib.mkDefault 10;
        "vm.vfs_cache_pressure" = lib.mkDefault 50;
        "vm.dirty_ratio" = lib.mkDefault 15;
        "vm.dirty_background_ratio" = lib.mkDefault 5;
        "net.core.default_qdisc" = "fq";
        "net.ipv4.tcp_congestion_control" = "bbr";
        "net.ipv4.conf.all.accept_redirects" = lib.mkDefault 0;
        "net.ipv4.conf.default.accept_redirects" = lib.mkDefault 0;
        "net.ipv6.conf.all.accept_redirects" = lib.mkDefault 0;
        "net.ipv6.conf.default.accept_redirects" = lib.mkDefault 0;
        "net.ipv4.conf.all.send_redirects" = lib.mkDefault 0;
        "net.ipv4.conf.default.send_redirects" = lib.mkDefault 0;
        "net.ipv4.conf.all.accept_source_route" = lib.mkDefault 0;
        "net.ipv4.conf.default.accept_source_route" = 0;
        "net.ipv6.conf.all.accept_source_route" = 0;
        "net.ipv6.conf.default.accept_source_route" = 0;
      };
      consoleLogLevel = 3;
    };
    systemd = {
      watchdog = {
        runtimeTime = "20s";
        rebootTime = "30s";
      };
      services = {
        "systemd-udev-settle".enable = false;
        "NetworkManager-wait-online".enable = false;
      };
    };
    hardware = {
      enableAllFirmware = lib.mkDefault true;
      enableRedistributableFirmware = lib.mkDefault true;
    };
  };
}
