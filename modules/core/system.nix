{
  config,
  lib,
  pkgs,
  ...
}: {
  # System-wide configuration and services
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
          # Core fonts
          dejavu_fonts
          liberation_ttf
          source-code-pro
          
          # Unicode support
          noto-fonts
          noto-fonts-cjk
          noto-fonts-emoji
          
          # Programming fonts
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
          # Common printer drivers
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
    # Internationalization
    i18n = {
      defaultLocale = config.unified.core.system.locale.defaultLocale;
      supportedLocales = config.unified.core.system.locale.supportedLocales;
    };
    
    # Timezone
    time.timeZone = config.unified.core.system.locale.timeZone;
    
    # Console configuration
    console = {
      keyMap = config.unified.core.system.keyboard.layout;
      font = "Lat2-Terminus16";
      useXkbConfig = true;
    };
    
    # Services configuration
    services = {
      # X11 keyboard configuration
      xserver.xkb = {
        layout = config.unified.core.system.keyboard.layout;
        options = config.unified.core.system.keyboard.options;
      };
      
      # Audio configuration
      pipewire = lib.mkIf (config.unified.core.system.audio.enable && 
                          config.unified.core.system.audio.backend == "pipewire") {
        enable = true;
        audio.enable = true;
        pulse.enable = true;
        jack.enable = true;
        alsa = {
          enable = true;
          support32Bit = true;
        };
        
        # Low latency configuration
        extraConfig.pipewire."92-low-latency" = {
          context.properties = {
            default.clock.rate = 48000;
            default.clock.quantum = 32;
            default.clock.min-quantum = 32;
            default.clock.max-quantum = 32;
          };
        };
      };
      
      # PulseAudio fallback
      pulseaudio = lib.mkIf (config.unified.core.system.audio.enable && 
                            config.unified.core.system.audio.backend == "pulseaudio") {
        enable = true;
        support32Bit = true;
        
        # Network audio
        tcp = {
          enable = false;
          anonymousClients.allowAll = false;
        };
        
        # Additional modules
        extraModules = [pkgs.pulseaudio-modules-bt];
      };
      
      # Printing
      printing = lib.mkIf config.unified.core.system.printing.enable {
        enable = true;
        drivers = config.unified.core.system.printing.drivers;
        
        # CUPS configuration
        extraConf = ''
          DefaultEncryption Never
          DefaultAuthType Basic
          Browsing On
          BrowseLocalProtocols cups
        '';
        
        # Web interface
        webInterface = false; # Security: disable by default
      };
      
      # Scanner support
      saned.enable = config.unified.core.system.printing.enable;
      
      # Bluetooth
      blueman.enable = config.unified.core.system.bluetooth;
      
      # SMART monitoring
      smartd = {
        enable = true;
        autodetect = true;
      };
      
      # Firmware updates
      fwupd.enable = true;
      
      # System logging
      journald = {
        settings = {
          Storage = "persistent";
          Compress = true;
          SystemMaxUse = "1G";
          SystemMaxFileSize = "100M";
          SystemKeepFree = "500M";
          RuntimeMaxUse = "200M";
          RuntimeMaxFileSize = "50M";
          MaxRetentionSec = "1month";
        };
      };
      
      # Time synchronization
      timesyncd = {
        enable = true;
        servers = [
          "time.nist.gov"
          "time.cloudflare.com"
          "pool.ntp.org"
        ];
      };
      
      # Location services (for automatic timezone)
      localtimed.enable = true;
      
      # Power management
      power-profiles-daemon.enable = config.unified.core.system.power.powerProfiles;
      
      # Thermald for Intel CPUs
      thermald.enable = lib.mkDefault true;
    };
    
    # Hardware configuration
    hardware = {
      # Audio
      pulseaudio.enable = lib.mkForce (config.unified.core.system.audio.enable && 
                                     config.unified.core.system.audio.backend == "pulseaudio");
      
      # Bluetooth
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
      
      # Graphics
      opengl = {
        enable = true;
        driSupport = true;
        driSupport32Bit = true;
      };
      
      # Scanner support
      sane = {
        enable = config.unified.core.system.printing.enable;
        extraBackends = with pkgs; [sane-airscan];
      };
    };
    
    # Power management
    powerManagement = lib.mkIf config.unified.core.system.power.management {
      enable = true;
      cpuFreqGovernor = config.unified.core.system.power.cpuGovernor;
      
      # Power saving
      powertop.enable = true;
      
      # Resume from hibernation
      resumeCommands = ''
        ${pkgs.systemd}/bin/systemctl restart --no-block user@*
      '';
    };
    
    # Zram configuration
    zramSwap = lib.mkIf config.unified.core.system.zram.enable {
      enable = true;
      algorithm = config.unified.core.system.zram.algorithm;
      memoryPercent = config.unified.core.system.zram.memoryPercent;
    };
    
    # Font configuration
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
      
      # Font directories
      fontDir.enable = true;
      enableGhostscriptFonts = true;
    };
    
    # System packages
    environment.systemPackages = with pkgs;
      [
        # System utilities
        lshw
        pciutils
        usbutils
        dmidecode
        lsof
        
        # File system tools
        parted
        gptfdisk
        ntfs3g
        exfat
        
        # Archive tools
        p7zip
        unrar
        
        # Network tools
        nmap
        tcpdump
        wireshark-cli
        
        # Hardware monitoring
        lm_sensors
        smartmontools
        
        # Performance monitoring
        iotop
        atop
        sysstat
      ]
      ++ lib.optionals config.unified.core.system.audio.enable [
        # Audio tools
        pavucontrol
        alsa-utils
        pulseaudio-ctl
      ]
      ++ lib.optionals config.unified.core.system.printing.enable [
        # Printing tools
        cups
        system-config-printer
      ]
      ++ lib.optionals config.unified.core.system.bluetooth [
        # Bluetooth tools
        bluez
        bluez-tools
      ];
    
    # System security
    security = {
      rtkit.enable = config.unified.core.system.audio.enable;
      polkit.enable = true;
    };
    
    # Systemd configuration
    systemd = {
      # Service hardening
      services = {
        # Improve service reliability
        systemd-resolved.serviceConfig = {
          Restart = "always";
          RestartSec = "1s";
        };
        
        systemd-timesyncd.serviceConfig = {
          Restart = "always";
          RestartSec = "30s";
        };
      };
      
      # User services
      user.services = {
        # User-level power management
        powerManagement = lib.mkIf config.unified.core.system.power.management {
          enable = true;
          description = "User power management";
        };
      };
      
      # Tmpfiles
      tmpfiles.rules = [
        # System directories
        "d /var/cache/fontconfig 0755 root root 30d"
        "d /var/log/journal 0755 root systemd-journal -"
        
        # User directories
        "d /var/lib/systemd/linger 0755 root root -"
      ];
    };
    
    # Kernel modules
    boot.kernelModules = [
      # Audio modules
      "snd-aloop"
      "snd-dummy"
    ]
    ++ lib.optionals config.unified.core.system.bluetooth [
      "btusb"
      "bluetooth"
    ];
    
    # Additional kernel parameters
    boot.kernelParams = [
      # Audio improvements
      "snd_hda_intel.power_save=1"
    ]
    ++ lib.optionals config.unified.core.system.zram.enable [
      "zswap.enabled=0" # Disable zswap when using zram
    ];
  };
}