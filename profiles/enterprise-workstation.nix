{
  config,
  lib,
  pkgs,
  ...
}: {
  meta = {
    name = "enterprise-workstation";
    description = "Enterprise-grade workstation profile with security hardening, productivity tools, and compliance features";
    maintainers = ["nixos-unified"];
    tags = ["enterprise" "workstation" "desktop" "security" "stable"];
  };

  imports = [
    ./base.nix
  ];

  # Enterprise workstation unified configuration
  unified = {
    # Core enterprise settings
    core = {
      enable = true;
      security.level = "hardened"; # High security for workstations
      performance.enable = true;
      stability.channel = "stable"; # Use only stable packages
    };

    # Desktop environment configuration
    desktop = {
      enable = true;
      environment = "gnome"; # Enterprise-friendly desktop
      wayland = true;
      security-enhanced = true;
    };

    # Enterprise hardware optimization
    hardware = {
      enable = true;
      workstation = true;
      enterprise = true;
      graphics.acceleration = true;
      audio.professional = true;
    };

    # Enterprise networking
    networking = {
      enable = true;
      firewall = {
        enable = true;
        strict = true;
        enterprise = true;
      };
      vpn.enterprise = true;
      proxy.corporate = true;
    };

    # Enterprise security
    security = {
      enterprise = {
        enable = true;
        compliance.frameworks = ["SOC2" "ISO27001" "NIST"];
        endpoint-protection = true;
        dlp.enable = true;
        device-control = true;
      };
      authentication = {
        multi-factor = true;
        smart-card = true;
        biometric = true;
      };
    };

    # Enterprise productivity
    productivity = {
      enable = true;
      office-suite = "libreoffice";
      collaboration-tools = true;
      communication = true;
      development-tools = true;
    };

    # Enterprise monitoring
    monitoring = {
      enable = true;
      endpoint-agent = true;
      performance-tracking = true;
      security-monitoring = true;
    };
  };

  # Use stable nixpkgs for enterprise reliability
  nixpkgs = {
    config = {
      allowUnfree = true; # Allow enterprise software
      permittedInsecurePackages = []; # No insecure packages
    };
  };

  # Enterprise boot configuration
  boot = {
    # Use latest stable kernel for workstations
    kernelPackages = pkgs.linuxPackages;

    # Security-focused kernel parameters
    kernelParams = [
      # Memory protection
      "slub_debug=P"
      "page_poison=1"
      "init_on_alloc=1"
      "init_on_free=1"

      # CPU security mitigations (keep enabled for enterprise)
      "mitigations=auto"
      "spectre_v2=on"
      "spec_store_bypass_disable=on"

      # Enable IOMMU for hardware isolation
      "intel_iommu=on"
      "amd_iommu=on"

      # Kernel lockdown
      "lockdown=integrity"

      # Audit system
      "audit=1"

      # Quiet boot for professional appearance
      "quiet"
      "splash"
      "loglevel=3"
    ];

    # Secure boot configuration
    loader = {
      systemd-boot = {
        enable = true;
        editor = false; # Disable boot parameter editing
        configurationLimit = 10;
      };
      efi.canTouchEfiVariables = true;
      timeout = 5;
    };

    # TPM support for enterprise security
    tpm2.enable = true;

    # LUKS encryption for data protection
    initrd.luks.devices = {
      root = {
        device = "/dev/disk/by-label/luks-root";
        preLVM = true;
        allowDiscards = true;
        # Enable FIDO2 token support
        crypttabExtraOpts = ["fido2-device=auto" "token-timeout=10"];
      };
    };

    # Plymouth for professional boot screen
    plymouth = {
      enable = true;
      theme = "breeze";
    };
  };

  # Enterprise hardware configuration
  hardware = {
    # Graphics support for workstations
    opengl = {
      enable = true;
      driSupport = true;
      driSupport32Bit = true;
      extraPackages = with pkgs; [
        intel-media-driver
        vaapiIntel
        vaapiVdpau
        libvdpau-va-gl
      ];
    };

    # Audio configuration
    pulseaudio.enable = false;

    # Professional audio with PipeWire
    rtkit.enable = true;

    # Bluetooth for enterprise peripherals
    bluetooth = {
      enable = true;
      powerOnBoot = false; # Disabled by default for security
      settings = {
        General = {
          Enable = "Source,Sink,Media,Socket";
          Experimental = false;
        };
      };
    };

    # CPU microcode updates
    cpu = {
      intel.updateMicrocode = true;
      amd.updateMicrocode = true;
    };

    # Enable firmware updates
    enableRedistributableFirmware = true;

    # Scanner support for office environments
    sane = {
      enable = true;
      extraBackends = [pkgs.hplipWithPlugin];
    };
  };

  # Enterprise security configuration
  security = {
    # Advanced access controls
    sudo = {
      enable = true;
      wheelNeedsPassword = true;
      execWheelOnly = true;
      extraConfig = ''
        # Enterprise sudo configuration
        Defaults timestamp_timeout=15
        Defaults !visiblepw
        Defaults always_set_home
        Defaults env_reset
        Defaults env_keep="COLORS DISPLAY HOSTNAME HISTSIZE KDEDIR LS_COLORS"
        Defaults env_keep+="MAIL PS1 PS2 QTDIR USERNAME LANG LC_ADDRESS LC_CTYPE"
        Defaults env_keep+="LC_COLLATE LC_IDENTIFICATION LC_MEASUREMENT LC_MESSAGES"
        Defaults env_keep+="LC_MONETARY LC_NAME LC_NUMERIC LC_PAPER LC_TELEPHONE"
        Defaults env_keep+="LC_TIME LC_ALL LANGUAGE LINGUAS _XKB_CHARSET XAUTHORITY"
        Defaults secure_path="/usr/local/sbin:/usr/local/bin:/usr/sbin:/usr/bin:/sbin:/bin"
        Defaults use_pty
        Defaults log_input
        Defaults log_output
      '';
    };

    # Enable AppArmor for application isolation
    apparmor = {
      enable = true;
      killUnconfinedConfinables = true;
      packages = with pkgs; [
        apparmor-profiles
      ];
    };

    # Audit system for compliance
    auditd.enable = true;
    audit = {
      enable = true;
      rules = [
        # Monitor privileged commands
        "-a always,exit -F arch=b64 -S execve -C uid!=euid -F euid=0 -k setuid"
        "-a always,exit -F arch=b64 -S execve -C gid!=egid -F egid=0 -k setgid"

        # Monitor authentication
        "-w /etc/passwd -p wa -k identity"
        "-w /etc/group -p wa -k identity"
        "-w /etc/gshadow -p wa -k identity"
        "-w /etc/shadow -p wa -k identity"

        # Monitor sudo usage
        "-w /etc/sudoers -p wa -k scope"
        "-w /etc/sudoers.d/ -p wa -k scope"

        # Monitor network configuration
        "-w /etc/hosts -p wa -k network"
        "-w /etc/resolv.conf -p wa -k network"

        # Monitor file access
        "-a always,exit -F arch=b64 -S chmod -S fchmod -S fchmodat -F auid>=1000 -F auid!=4294967295 -k perm_mod"
        "-a always,exit -F arch=b64 -S chown -S fchown -S fchownat -S lchown -F auid>=1000 -F auid!=4294967295 -k perm_mod"

        # Monitor file deletions
        "-a always,exit -F arch=b64 -S unlink -S unlinkat -S rename -S renameat -F auid>=1000 -F auid!=4294967295 -k delete"
      ];
    };

    # PAM configuration for enterprise
    pam = {
      enableSSHAgentAuth = true;
      services = {
        login.failDelay = 4000000; # 4 second delay on failed login
        su.requireWheel = true;

        # Smart card authentication
        sshd.u2fAuth = true;
        login.u2fAuth = true;
        sudo.u2fAuth = true;
      };

      # U2F/FIDO2 configuration
      u2f = {
        enable = true;
        control = "sufficient";
        settings = {
          cue = true;
          debug = false;
        };
      };
    };

    # Polkit configuration for desktop
    polkit = {
      enable = true;
      extraConfig = ''
        /* Allow users in wheel group to manage systemd user services */
        polkit.addRule(function(action, subject) {
            if (action.id == "org.freedesktop.systemd1.manage-user-units" &&
                subject.isInGroup("wheel")) {
                return polkit.Result.YES;
            }
        });

        /* Require authentication for NetworkManager */
        polkit.addRule(function(action, subject) {
            if (action.id.indexOf("org.freedesktop.NetworkManager.") == 0 &&
                !subject.isInGroup("networkmanager")) {
                return polkit.Result.AUTH_ADMIN;
            }
        });
      '';
    };

    # TPM2 integration
    tpm2 = {
      enable = true;
      pkcs11.enable = true;
      tctiEnvironment.enable = true;
    };

    # Disable unprivileged user namespaces
    unprivilegedUsernsClone = false;

    # Enable KRSI (Kernel Runtime Security Interface)
    lockKernelLogs = true;
    forcePageTableIsolation = true;

    # Real-time security
    rtkit.enable = true;
  };

  # Enterprise networking configuration
  networking = {
    # Use NetworkManager for enterprise Wi-Fi
    networkmanager = {
      enable = true;
      plugins = with pkgs; [
        networkmanager-openvpn
        networkmanager-openconnect
        networkmanager-vpnc
        networkmanager-l2tp
      ];
      wifi = {
        powersave = false;
        macAddress = "random";
      };
    };

    # Enterprise firewall configuration
    firewall = {
      enable = true;

      # Minimal open ports for workstation
      allowedTCPPorts = [];
      allowedUDPPorts = [];

      # Log dropped packets for security monitoring
      logRefusedConnections = true;
      logRefusedPackets = true;
      logRefusedUnicastsOnly = false;

      # Rate limiting
      pingLimit = "--limit 1/minute --limit-burst 1";

      # Enterprise firewall rules
      extraCommands = ''
        # Drop invalid packets
        iptables -A INPUT -m conntrack --ctstate INVALID -j DROP

        # Allow loopback
        iptables -A INPUT -i lo -j ACCEPT

        # Allow established connections
        iptables -A INPUT -m conntrack --ctstate ESTABLISHED,RELATED -j ACCEPT

        # Rate limit new connections
        iptables -A INPUT -m conntrack --ctstate NEW -m limit --limit 50/sec --limit-burst 50 -j ACCEPT

        # Log suspicious activity
        iptables -A INPUT -m recent --name portscan --set -j LOG --log-prefix "Portscan detected: "

        # Drop everything else
        iptables -A INPUT -j DROP
      '';
    };

    # DNS configuration
    nameservers = ["1.1.1.1" "1.0.0.1" "8.8.8.8"];

    # Network hardening
    enableIPv6 = true;

    # Network security parameters
    kernel.sysctl = {
      # IP forwarding (disable for workstations)
      "net.ipv4.ip_forward" = 0;
      "net.ipv6.conf.all.forwarding" = 0;

      # Source routing
      "net.ipv4.conf.all.accept_source_route" = 0;
      "net.ipv4.conf.default.accept_source_route" = 0;
      "net.ipv6.conf.all.accept_source_route" = 0;
      "net.ipv6.conf.default.accept_source_route" = 0;

      # ICMP redirects
      "net.ipv4.conf.all.accept_redirects" = 0;
      "net.ipv4.conf.default.accept_redirects" = 0;
      "net.ipv6.conf.all.accept_redirects" = 0;
      "net.ipv6.conf.default.accept_redirects" = 0;
      "net.ipv4.conf.all.secure_redirects" = 0;
      "net.ipv4.conf.default.secure_redirects" = 0;

      # Send redirects
      "net.ipv4.conf.all.send_redirects" = 0;
      "net.ipv4.conf.default.send_redirects" = 0;

      # Router advertisements
      "net.ipv6.conf.all.accept_ra" = 0;
      "net.ipv6.conf.default.accept_ra" = 0;

      # Log suspicious packets
      "net.ipv4.conf.all.log_martians" = 1;
      "net.ipv4.conf.default.log_martians" = 1;

      # Ignore ping requests (optional for high security)
      "net.ipv4.icmp_echo_ignore_all" = 0;

      # TCP hardening
      "net.ipv4.tcp_syncookies" = 1;
      "net.ipv4.tcp_rfc1337" = 1;
      "net.ipv4.tcp_timestamps" = 0;

      # Kernel security
      "kernel.dmesg_restrict" = 1;
      "kernel.kptr_restrict" = 2;
      "kernel.yama.ptrace_scope" = 1;
      "kernel.unprivileged_bpf_disabled" = 1;
      "net.core.bpf_jit_harden" = 2;

      # File system security
      "fs.protected_hardlinks" = 1;
      "fs.protected_symlinks" = 1;
      "fs.protected_fifos" = 2;
      "fs.protected_regular" = 2;
      "fs.suid_dumpable" = 0;

      # Virtual memory
      "vm.mmap_rnd_bits" = 32;
      "vm.mmap_rnd_compat_bits" = 16;
    };
  };

  # Enterprise services configuration
  services = {
    # Desktop environment - GNOME for enterprise
    xserver = {
      enable = true;
      displayManager.gdm = {
        enable = true;
        wayland = true;
        autoSuspend = false;
      };
      desktopManager.gnome.enable = true;

      # Input device configuration
      libinput = {
        enable = true;
        touchpad = {
          tapping = true;
          naturalScrolling = true;
          disableWhileTyping = true;
        };
      };

      # Enterprise keyboard layout
      layout = "us";
      xkbOptions = "caps:escape";
    };

    # Audio system
    pipewire = {
      enable = true;
      alsa.enable = true;
      alsa.support32Bit = true;
      pulse.enable = true;
      jack.enable = true;

      # Professional audio configuration
      extraConfig.pipewire = {
        "context.properties" = {
          "default.clock.rate" = 48000;
          "default.clock.quantum" = 1024;
          "default.clock.min-quantum" = 32;
          "default.clock.max-quantum" = 8192;
        };
      };
    };

    # Printing support for office environments
    printing = {
      enable = true;
      drivers = with pkgs; [
        hplip
        hplipWithPlugin
        gutenprint
        gutenprintBin
        canon-cups-ufr2
        cnijfilter2
      ];
    };

    # CUPS configuration for enterprise printing
    avahi = {
      enable = true;
      nssmdns = true;
      openFirewall = true;
    };

    # Bluetooth management
    blueman.enable = true;

    # Time synchronization
    timesyncd = {
      enable = true;
      servers = [
        "time.cloudflare.com"
        "time.google.com"
        "pool.ntp.org"
      ];
    };

    # SSH for remote management
    openssh = {
      enable = true;
      settings = {
        # Security settings
        PermitRootLogin = "no";
        PasswordAuthentication = false;
        PubkeyAuthentication = true;
        AuthenticationMethods = "publickey";

        # Connection settings
        ClientAliveInterval = 300;
        ClientAliveCountMax = 2;
        LoginGraceTime = 60;
        MaxAuthTries = 3;
        MaxSessions = 2;

        # Disable unused features
        X11Forwarding = false;
        AllowAgentForwarding = false;
        AllowTcpForwarding = false;
        GatewayPorts = "no";
        PermitTunnel = "no";

        # Logging
        LogLevel = "VERBOSE";
        SyslogFacility = "AUTHPRIV";
      };
    };

    # System logging
    journald.settings = {
      # Enterprise logging configuration
      Storage = "persistent";
      SystemMaxUse = "2G";
      SystemKeepFree = "5G";
      SystemMaxFileSize = "100M";
      SystemMaxFiles = 100;
      RuntimeMaxUse = "200M";
      RuntimeKeepFree = "1G";
      RuntimeMaxFileSize = "50M";
      RuntimeMaxFiles = 20;
      Compress = true;
      Seal = true;
      SplitMode = "uid";
      RateLimitInterval = "1s";
      RateLimitBurst = 1000;
      ForwardToSyslog = false;
      ForwardToKMsg = false;
      ForwardToConsole = false;
      ForwardToWall = true;
    };

    # Firmware updates
    fwupd.enable = true;

    # Flatpak for enterprise applications
    flatpak.enable = true;

    # Enterprise monitoring
    prometheus.exporters.node = {
      enable = true;
      port = 9100;
      enabledCollectors = [
        "systemd"
        "processes"
        "cpu"
        "diskstats"
        "filesystem"
        "loadavg"
        "meminfo"
        "netdev"
        "netstat"
        "stat"
        "time"
        "uname"
      ];
    };

    # Automatic garbage collection
    cron = {
      enable = true;
      systemCronJobs = [
        # Nix store cleanup
        "0 3 * * 0 root nix-collect-garbage -d"

        # Log cleanup
        "0 2 * * * root journalctl --vacuum-time=30d"

        # Temporary file cleanup
        "0 4 * * * root find /tmp -type f -atime +7 -delete"
      ];
    };

    # Power management for laptops
    power-profiles-daemon.enable = true;

    # Location services (for timezone)
    geoclue2.enable = true;

    # GNOME services
    gnome = {
      glib-networking.enable = true;
      gnome-keyring.enable = true;
      gnome-online-accounts.enable = true;
    };
  };

  # Enterprise package selection
  environment.systemPackages = with pkgs; [
    # Essential system tools
    vim
    nano
    git
    wget
    curl
    rsync
    tree
    htop
    iotop

    # Archive and compression
    zip
    unzip
    p7zip
    rar

    # Network tools
    networkmanagerapplet
    network-manager-applet
    wireless-tools
    wpa_supplicant_gui

    # Security tools
    gnupg
    pinentry-gtk2
    keepassxc
    clamav
    chkrootkit
    rkhunter

    # Office and productivity
    libreoffice-fresh
    onlyoffice-bin

    # Communication
    thunderbird
    element-desktop
    signal-desktop

    # Web browsers
    firefox-esr
    chromium

    # Media and graphics
    vlc
    gimp
    inkscape

    # Development tools
    vscode
    git
    docker

    # Enterprise applications
    teams-for-linux
    slack
    zoom-us
    skypeforlinux

    # System utilities
    gparted
    baobab
    dconf-editor
    gnome-tweaks

    # Font management
    font-manager

    # Archive managers
    file-roller

    # PDF tools
    evince
    okular

    # Text editors
    gedit

    # Terminal emulator
    gnome-terminal

    # File managers
    nautilus

    # Image viewers
    eog

    # Enterprise printer drivers
    hplip
    hplipWithPlugin

    # VPN clients
    openvpn
    openconnect
    networkmanager-openvpn
    networkmanager-openconnect

    # Remote desktop
    remmina

    # Virtualization
    virt-manager

    # Monitoring
    prometheus-node-exporter

    # Backup tools
    borgbackup
    rsnapshot
  ];

  # Fonts for enterprise environments
  fonts = {
    packages = with pkgs; [
      # Microsoft fonts for compatibility
      corefonts
      vistafonts

      # Professional fonts
      liberation_ttf
      dejavu_fonts
      noto-fonts
      noto-fonts-cjk
      noto-fonts-emoji

      # Monospace fonts for development
      fira-code
      fira-code-symbols
      source-code-pro
      jetbrains-mono

      # Business fonts
      ubuntu_font_family
      open-sans
      roboto

      # Font awesome for icons
      font-awesome
    ];

    fontconfig = {
      enable = true;
      defaultFonts = {
        serif = ["Liberation Serif" "DejaVu Serif"];
        sansSerif = ["Liberation Sans" "DejaVu Sans"];
        monospace = ["Fira Code" "DejaVu Sans Mono"];
      };

      # Font rendering optimization
      hinting = {
        enable = true;
        style = "slight";
      };

      subpixel = {
        lcdfilter = "default";
        rgba = "rgb";
      };
    };
  };

  # Users configuration
  users = {
    # Immutable users for enterprise security
    mutableUsers = false;

    # Default shell
    defaultUserShell = pkgs.bash;

    # Enterprise user template (configure with real users)
    users = {
      enterprise-user = {
        isNormalUser = true;
        extraGroups = [
          "wheel"
          "networkmanager"
          "audio"
          "video"
          "input"
          "scanner"
          "lp"
          "docker"
          "libvirtd"
        ];
        # Configure with actual SSH keys
        openssh.authorizedKeys.keys = [
          # Add SSH public keys here
        ];
        hashedPassword = "!"; # Disable password login
        description = "Enterprise User";
        shell = pkgs.bash;
      };
    };

    # Enterprise groups
    extraGroups = {
      enterprise = {gid = 1000;};
      audit = {gid = 1001;};
    };
  };

  # XDG configuration for desktop integration
  xdg = {
    portal = {
      enable = true;
      extraPortals = with pkgs; [
        xdg-desktop-portal-gnome
        xdg-desktop-portal-gtk
      ];
      config.common.default = "*";
    };

    # MIME type associations
    mime.enable = true;
  };

  # Programs configuration
  programs = {
    # GNOME packages
    gnome-disks.enable = true;
    file-roller.enable = true;

    # Shell configuration
    bash = {
      enableCompletion = true;
      shellInit = ''
        # Enterprise shell configuration
        set +h
        umask 022

        # History settings
        export HISTSIZE=10000
        export HISTFILESIZE=20000
        export HISTCONTROL=ignoreboth:erasedups
        export HISTTIMEFORMAT='%F %T '

        # Security aliases
        alias rm='rm -i'
        alias cp='cp -i'
        alias mv='mv -i'
        alias ll='ls -la'
        alias la='ls -A'
        alias l='ls -CF'
        alias grep='grep --color=auto'
        alias egrep='egrep --color=auto'
        alias fgrep='fgrep --color=auto'

        # Enterprise environment
        export EDITOR=vim
        export BROWSER=firefox
        export TERMINAL=gnome-terminal
      '';
    };

    # Git configuration
    git = {
      enable = true;
      config = {
        user.name = lib.mkDefault "Enterprise User";
        user.email = lib.mkDefault "user@enterprise.local";
        init.defaultBranch = "main";
        core.autocrlf = false;
        pull.rebase = true;
        push.autoSetupRemote = true;
      };
    };

    # GPG configuration
    gnupg.agent = {
      enable = true;
      enableSSHSupport = true;
      pinentryFlavor = "gtk2";
    };

    # Filesystem access
    fuse.userAllowOther = true;

    # SSH client configuration
    ssh = {
      startAgent = true;
      agentTimeout = "1h";
    };

    # AppImage support
    appimage = {
      enable = true;
      binfmt = true;
    };

    # Firefox configuration
    firefox = {
      enable = true;
      package = pkgs.firefox-esr;
      preferences = {
        # Security settings
        "privacy.trackingprotection.enabled" = true;
        "privacy.trackingprotection.pbmode.enabled" = true;
        "privacy.donottrackheader.enabled" = true;
        "security.tls.version.min" = 3;
        "security.tls.version.max" = 4;
        "dom.security.https_only_mode" = true;

        # Disable telemetry
        "toolkit.telemetry.enabled" = false;
        "toolkit.telemetry.unified" = false;
        "datareporting.healthreport.uploadEnabled" = false;
        "datareporting.policy.dataSubmissionEnabled" = false;

        # Enterprise settings
        "browser.startup.homepage" = "about:blank";
        "browser.newtabpage.enabled" = false;
        "browser.download.useDownloadDir" = true;
        "browser.download.dir" = "/home/enterprise-user/Downloads";
      };
    };
  };

  # Virtualization support for enterprise
  virtualisation = {
    libvirtd = {
      enable = true;
      qemu = {
        package = pkgs.qemu_kvm;
        ovmf.enable = true;
        swtpm.enable = true;
      };
    };

    # Docker for development
    docker = {
      enable = true;
      enableOnBoot = true;
      autoPrune = {
        enable = true;
        dates = "weekly";
      };
    };

    # Podman as Docker alternative
    podman = {
      enable = true;
      dockerCompat = true;
      defaultNetwork.settings.dns_enabled = true;
    };
  };

  # File systems configuration
  fileSystems = {
    # Optimize mount options for enterprise
    "/" = {
      options = ["noatime" "nodiratime"];
    };

    # Temporary filesystem in memory
    "/tmp" = {
      device = "tmpfs";
      fsType = "tmpfs";
      options = [
        "defaults"
        "noatime"
        "nosuid"
        "nodev"
        "noexec"
        "mode=1777"
        "size=4G"
      ];
    };
  };

  # Enterprise environment variables
  environment.variables = {
    # Enterprise identifiers
    ENTERPRISE_WORKSTATION = "1";
    SECURITY_LEVEL = "HARDENED";
    COMPLIANCE_FRAMEWORKS = "SOC2,ISO27001,NIST";

    # Application defaults
    BROWSER = "firefox";
    EDITOR = "vim";
    TERMINAL = "gnome-terminal";

    # Development environment
    DOCKER_BUILDKIT = "1";

    # Security
    GNUPGHOME = "$HOME/.gnupg";
  };

  # Nix configuration for enterprise
  nix = {
    settings = {
      # Build settings
      max-jobs = "auto";
      cores = 0; # Use all available cores

      # Storage optimization
      auto-optimise-store = true;
      min-free = 2 * 1024 * 1024 * 1024; # 2GB
      max-free = 5 * 1024 * 1024 * 1024; # 5GB

      # Security settings
      sandbox = true;
      allowed-users = ["@wheel"];
      trusted-users = ["root"];

      # Enable flakes for reproducible builds
      experimental-features = ["nix-command" "flakes"];

      # Use only trusted substituters
      substituters = [
        "https://cache.nixos.org"
        "https://nix-community.cachix.org"
      ];
      trusted-public-keys = [
        "cache.nixos.org-1:6NCHdD59X431o0gWypbMrAURkbJ16ZPMQFGspcDShjY="
        "nix-community.cachix.org-1:mB9FSh9qf2dCimDSUo8Zy7bkq5CX+/rkCWyvRCYg3Fs="
      ];
    };

    # Garbage collection for workstations
    gc = {
      automatic = true;
      dates = "weekly";
      options = "--delete-older-than 14d";
    };

    # Optimize store weekly
    optimise = {
      automatic = true;
      dates = ["04:00"];
    };
  };

  # System configuration
  system = {
    stateVersion = "24.11";

    # Activation scripts for enterprise setup
    activationScripts = {
      enterpriseWorkstationSetup = ''
        # Create enterprise directories
        mkdir -p /etc/enterprise
        mkdir -p /var/log/enterprise
        mkdir -p /var/lib/enterprise

        # Set proper permissions
        chmod 755 /etc/enterprise
        chmod 750 /var/log/enterprise
        chmod 750 /var/lib/enterprise

        # Create compliance markers
        echo "SOC2,ISO27001,NIST" > /etc/enterprise/compliance-frameworks
        echo "$(date -Iseconds)" > /etc/enterprise/deployment-date
        echo "enterprise-workstation" > /etc/enterprise/profile-type

        # Set enterprise hostname pattern
        if [ ! -f /etc/enterprise/hostname-configured ]; then
          echo "enterprise-ws-$(cat /etc/machine-id | cut -c1-8)" > /etc/hostname
          touch /etc/enterprise/hostname-configured
        fi
      '';
    };
  };

  # Documentation
  documentation = {
    enable = true;
    nixos.enable = true;
    man.enable = true;
    info.enable = true;
  };

  # Locale and timezone
  time.timeZone = lib.mkDefault "UTC";
  i18n = {
    defaultLocale = "en_US.UTF-8";
    extraLocaleSettings = {
      LC_ADDRESS = "en_US.UTF-8";
      LC_IDENTIFICATION = "en_US.UTF-8";
      LC_MEASUREMENT = "en_US.UTF-8";
      LC_MONETARY = "en_US.UTF-8";
      LC_NAME = "en_US.UTF-8";
      LC_NUMERIC = "en_US.UTF-8";
      LC_PAPER = "en_US.UTF-8";
      LC_TELEPHONE = "en_US.UTF-8";
      LC_TIME = "en_US.UTF-8";
    };
  };

  # Console configuration
  console = {
    font = "Lat2-Terminus16";
    keyMap = "us";
    useXkbConfig = true;
  };

  # Power management for workstations
  powerManagement = {
    enable = true;
    cpuFreqGovernor = lib.mkDefault "powersave";
  };
}
