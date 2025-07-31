{
  config,
  lib,
  pkgs,
  ...
}: {
  options.unified.core.system = with lib; {
    enable = mkEnableOption "unified system configuration" // {default = true;};
    locale = {
      defaultLocale = mkOption {
        type = types.str;
        default = "en_US.UTF-8";
        description = "Default system locale";
      };
      supportedLocales = mkOption {
        type = types.listOf types.str;
        default = ["en_US.UTF-8/UTF-8"];
        description = "List of supported locales";
      };
      timeZone = mkOption {
        type = types.str;
        default = "UTC";
        description = "System timezone";
      };
    };
    keyboard = {
      layout = mkOption {
        type = types.str;
        default = "us";
        description = "Keyboard layout";
      };
      options = mkOption {
        type = types.str;
        default = "";
        description = "Keyboard options";
      };
    };
    audio = {
      enable = mkEnableOption "audio support" // {default = true;};
      backend = mkOption {
        type = types.enum ["pipewire" "pulseaudio" "alsa"];
        default = "pipewire";
        description = "Audio backend to use";
      };
    };
    fonts = {
      enable = mkEnableOption "font configuration" // {default = true;};
      packages = mkOption {
        type = types.listOf types.package;
        default = with pkgs; [
          dejavu_fonts
          liberation_ttf
          source-code-pro
          noto-fonts
          noto-fonts-cjk-sans
          noto-fonts-emoji
          fira-code
          fira-code-symbols
        ];
        description = "Font packages to install";
      };
    };
    printing = {
      enable = mkEnableOption "printing support";
      drivers = mkOption {
        type = types.listOf types.package;
        default = with pkgs; [
          gutenprint
          gutenprintBin
          hplip
          epson-escpr
          brlaser
          brgenml1lpr
          brgenml1cupswrapper
        ];
        description = "Printer driver packages";
      };
    };
    bluetooth = mkEnableOption "Bluetooth support";
    zram = {
      enable = mkEnableOption "zram swap compression";
      algorithm = mkOption {
        type = types.str;
        default = "zstd";
        description = "Compression algorithm for zram";
      };
      memoryPercent = mkOption {
        type = types.int;
        default = 25;
        description = "Percentage of RAM to use for zram";
      };
    };
    power = {
      management = mkEnableOption "power management" // {default = true;};
      cpuGovernor = mkOption {
        type = types.str;
        default = "ondemand";
        description = "CPU frequency governor";
      };
      powerProfiles = mkEnableOption "power profiles daemon";
    };
  };
  config = lib.mkIf config.unified.core.system.enable {
    i18n = {
      defaultLocale = config.unified.core.system.locale.defaultLocale;
      supportedLocales = config.unified.core.system.locale.supportedLocales;
    };
    time.timeZone = lib.mkIf (!config.services.localtimed.enable) config.unified.core.system.locale.timeZone;
    console = {
      keyMap = lib.mkDefault config.unified.core.system.keyboard.layout;
      font = "Lat2-Terminus16";
      useXkbConfig = true;
    };
    services = {
      xserver.xkb = {
        layout = config.unified.core.system.keyboard.layout;
        options = config.unified.core.system.keyboard.options;
      };
      pipewire = lib.mkIf (config.unified.core.system.audio.enable
        && config.unified.core.system.audio.backend == "pipewire") {
        enable = true;
        audio.enable = true;
        pulse.enable = true;
        jack.enable = true;
        alsa = {
          enable = true;
          support32Bit = true;
        };
        extraConfig.pipewire."92-low-latency" = {
          context.properties = {
            default.clock.rate = 48000;
            default.clock.quantum = 32;
            default.clock.min-quantum = 32;
            default.clock.max-quantum = 32;
          };
        };
      };
      pulseaudio = lib.mkIf (config.unified.core.system.audio.enable
        && config.unified.core.system.audio.backend == "pulseaudio") {
        enable = true;
        support32Bit = true;
        tcp = {
          enable = false;
          anonymousClients.allowAll = false;
        };
        extraModules = [pkgs.pulseaudio-modules-bt];
      };
      printing = lib.mkIf config.unified.core.system.printing.enable {
        enable = true;
        drivers = config.unified.core.system.printing.drivers;
        extraConf = ''
          DefaultEncryption Never
          DefaultAuthType Basic
          Browsing On
          BrowseLocalProtocols cups
        '';
        webInterface = false;
      };
      saned.enable = config.unified.core.system.printing.enable;
      blueman.enable = config.unified.core.system.bluetooth;
      smartd = {
        enable = true;
        autodetect = true;
      };
      fwupd.enable = true;
      journald = {
        extraConfig = ''
          Storage=persistent
          Compress=true
          SystemMaxUse=1G
          SystemMaxFileSize=100M
          SystemKeepFree=500M
          RuntimeMaxUse=200M
          RuntimeMaxFileSize=50M
          MaxRetentionSec=1month
        '';
      };
      timesyncd = {
        enable = true;
        servers = [
          "time.nist.gov"
          "time.cloudflare.com"
          "pool.ntp.org"
        ];
      };
      localtimed.enable = true;
      power-profiles-daemon.enable = config.unified.core.system.power.powerProfiles;
      thermald.enable = lib.mkDefault true;
    };
    hardware = {
      bluetooth = lib.mkIf config.unified.core.system.bluetooth {
        enable = true;
        powerOnBoot = true;
        settings = {
          General = {
            Enable = "Source,Sink,Media,Socket";
            Experimental = true;
          };
        };
      };
      graphics = {
        enable = true;
        enable32Bit = lib.mkDefault true;
      };
      sane = {
        enable = config.unified.core.system.printing.enable;
        extraBackends = with pkgs; [sane-airscan];
      };
    };
    powerManagement = lib.mkIf config.unified.core.system.power.management {
      enable = true;
      cpuFreqGovernor = config.unified.core.system.power.cpuGovernor;
      powertop.enable = true;
      resumeCommands = ''
        ${pkgs.systemd}/bin/systemctl restart --no-block user@*
      '';
    };
    zramSwap = lib.mkIf config.unified.core.system.zram.enable {
      enable = true;
      algorithm = config.unified.core.system.zram.algorithm;
      memoryPercent = config.unified.core.system.zram.memoryPercent;
    };
    fonts = lib.mkIf config.unified.core.system.fonts.enable {
      packages = config.unified.core.system.fonts.packages;
      fontconfig = {
        enable = true;
        antialias = true;
        cache32Bit = true;
        hinting.enable = true;
        hinting.style = "slight";
        subpixel.rgba = "rgb";
        defaultFonts = {
          serif = ["Liberation Serif" "Noto Serif"];
          sansSerif = ["Liberation Sans" "Noto Sans"];
          monospace = ["Source Code Pro" "Liberation Mono"];
          emoji = ["Noto Color Emoji"];
        };
      };
      fontDir.enable = true;
      enableGhostscriptFonts = true;
    };
    environment.systemPackages = with pkgs;
      [
        lshw
        pciutils
        usbutils
        dmidecode
        lsof
        parted
        gptfdisk
        ntfs3g
        exfat
        p7zip
        unrar
        nmap
        tcpdump
        wireshark-cli
        lm_sensors
        smartmontools
        iotop
        atop
        sysstat
      ]
      ++ lib.optionals config.unified.core.system.audio.enable [
        pavucontrol
        alsa-utils
        pulseaudio-ctl
      ]
      ++ lib.optionals config.unified.core.system.printing.enable [
        cups
        system-config-printer
      ]
      ++ lib.optionals config.unified.core.system.bluetooth [
        bluez
        bluez-tools
      ];
    security = {
      rtkit.enable = config.unified.core.system.audio.enable;
      polkit.enable = true;
    };
    systemd = {
      services = {
        systemd-resolved.serviceConfig = {
          Restart = "always";
          RestartSec = "1s";
        };
        systemd-timesyncd.serviceConfig = {
          Restart = "always";
          RestartSec = "30s";
        };
      };
      user.services = {
        powerManagement = lib.mkIf config.unified.core.system.power.management {
          enable = true;
          description = "User power management";
        };
      };
      tmpfiles.rules = [
        "d /var/cache/fontconfig 0755 root root 30d"
        "d /var/log/journal 0755 root systemd-journal -"
        "d /var/lib/systemd/linger 0755 root root -"
      ];
    };
    boot.kernelModules =
      [
        "snd-aloop"
        "snd-dummy"
      ]
      ++ lib.optionals config.unified.core.system.bluetooth [
        "btusb"
        "bluetooth"
      ];
    boot.kernelParams =
      [
        "snd_hda_intel.power_save=1"
      ]
      ++ lib.optionals config.unified.core.system.zram.enable [
        "zswap.enabled=0"
      ];
  };
}
