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
      security.level = "hardened";
      performance.enable = true;
      stability.channel = "stable";
    };
    desktop = {
      enable = true;
      environment = "gnome";
      wayland = true;
      security-enhanced = true;
    };
    hardware = {
      enable = true;
      workstation = true;
      enterprise = true;
      graphics.acceleration = true;
      audio.professional = true;
    };
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
    productivity = {
      enable = true;
      office-suite = "libreoffice";
      collaboration-tools = true;
      communication = true;
      development-tools = true;
    };
    monitoring = {
      enable = true;
      endpoint-agent = true;
      performance-tracking = true;
      security-monitoring = true;
    };
  };
  nixpkgs = {
    config = {
      allowUnfree = true;
      permittedInsecurePackages = [];
    };
  };
  boot = {
    kernelPackages = pkgs.linuxPackages;
    kernelParams = [
      "slub_debug=P"
      "page_poison=1"
      "init_on_alloc=1"
      "init_on_free=1"
      "mitigations=auto"
      "spectre_v2=on"
      "spec_store_bypass_disable=on"
      "intel_iommu=on"
      "amd_iommu=on"
      "lockdown=integrity"
      "audit=1"
      "quiet"
      "splash"
      "loglevel=3"
    ];
    loader = {
      systemd-boot = {
        enable = true;
        editor = false;
        configurationLimit = 10;
      };
      efi.canTouchEfiVariables = true;
      timeout = 5;
    };
    tpm2.enable = true;
    initrd.luks.devices = {
      root = {
        device = "/dev/disk/by-label/luks-root";
        preLVM = true;
        allowDiscards = true;
        crypttabExtraOpts = ["fido2-device=auto" "token-timeout=10"];
      };
    };
    plymouth = {
      enable = true;
      theme = "breeze";
    };
  };
  hardware = {
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
    pulseaudio.enable = false;
    rtkit.enable = true;
    bluetooth = {
      enable = true;
      powerOnBoot = false;
      settings = {
        General = {
          Enable = "Source,Sink,Media,Socket";
          Experimental = false;
        };
      };
    };
    cpu = {
      intel.updateMicrocode = true;
      amd.updateMicrocode = true;
    };
    enableRedistributableFirmware = true;
    sane = {
      enable = true;
      extraBackends = [pkgs.hplipWithPlugin];
    };
  };
  security = {
    sudo = {
      enable = true;
      wheelNeedsPassword = true;
      execWheelOnly = true;
      extraConfig = ''
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
    apparmor = {
      enable = true;
      killUnconfinedConfinables = true;
      packages = with pkgs; [
        apparmor-profiles
      ];
    };
    auditd.enable = true;
    audit = {
      enable = true;
      rules = [
        "-a always,exit -F arch=b64 -S execve -C uid!=euid -F euid=0 -k setuid"
        "-a always,exit -F arch=b64 -S execve -C gid!=egid -F egid=0 -k setgid"
        "-w /etc/passwd -p wa -k identity"
        "-w /etc/group -p wa -k identity"
        "-w /etc/gshadow -p wa -k identity"
        "-w /etc/shadow -p wa -k identity"
        "-w /etc/sudoers -p wa -k scope"
        "-w /etc/sudoers.d/ -p wa -k scope"
        "-w /etc/hosts -p wa -k network"
        "-w /etc/resolv.conf -p wa -k network"
        "-a always,exit -F arch=b64 -S chmod -S fchmod -S fchmodat -F auid>=1000 -F auid!=4294967295 -k perm_mod"
        "-a always,exit -F arch=b64 -S chown -S fchown -S fchownat -S lchown -F auid>=1000 -F auid!=4294967295 -k perm_mod"
        "-a always,exit -F arch=b64 -S unlink -S unlinkat -S rename -S renameat -F auid>=1000 -F auid!=4294967295 -k delete"
      ];
    };
    pam = {
      enableSSHAgentAuth = true;
      services = {
        login.failDelay = 4000000;
        su.requireWheel = true;
        sshd.u2fAuth = true;
        login.u2fAuth = true;
        sudo.u2fAuth = true;
      };
      u2f = {
        enable = true;
        control = "sufficient";
        settings = {
          cue = true;
          debug = false;
        };
      };
    };
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
    tpm2 = {
      enable = true;
      pkcs11.enable = true;
      tctiEnvironment.enable = true;
    };
    unprivilegedUsernsClone = false;
    lockKernelLogs = true;
    forcePageTableIsolation = true;
    rtkit.enable = true;
  };
  networking = {
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
    firewall = {
      enable = true;
      allowedTCPPorts = [];
      allowedUDPPorts = [];
      logRefusedConnections = true;
      logRefusedPackets = true;
      logRefusedUnicastsOnly = false;
      pingLimit = "--limit 1/minute --limit-burst 1";
      extraCommands = ''
        iptables -A INPUT -m conntrack --ctstate INVALID -j DROP
        iptables -A INPUT -i lo -j ACCEPT
        iptables -A INPUT -m conntrack --ctstate ESTABLISHED,RELATED -j ACCEPT
        iptables -A INPUT -m conntrack --ctstate NEW -m limit --limit 50/sec --limit-burst 50 -j ACCEPT
        iptables -A INPUT -m recent --name portscan --set -j LOG --log-prefix "Portscan detected: "
        iptables -A INPUT -j DROP
      '';
    };
    nameservers = ["1.1.1.1" "1.0.0.1" "8.8.8.8"];
    enableIPv6 = true;
    kernel.sysctl = {
      "net.ipv4.ip_forward" = 0;
      "net.ipv6.conf.all.forwarding" = 0;
      "net.ipv4.conf.all.accept_source_route" = 0;
      "net.ipv4.conf.default.accept_source_route" = 0;
      "net.ipv6.conf.all.accept_source_route" = 0;
      "net.ipv6.conf.default.accept_source_route" = 0;
      "net.ipv4.conf.all.accept_redirects" = 0;
      "net.ipv4.conf.default.accept_redirects" = 0;
      "net.ipv6.conf.all.accept_redirects" = 0;
      "net.ipv6.conf.default.accept_redirects" = 0;
      "net.ipv4.conf.all.secure_redirects" = 0;
      "net.ipv4.conf.default.secure_redirects" = 0;
      "net.ipv4.conf.all.send_redirects" = 0;
      "net.ipv4.conf.default.send_redirects" = 0;
      "net.ipv6.conf.all.accept_ra" = 0;
      "net.ipv6.conf.default.accept_ra" = 0;
      "net.ipv4.conf.all.log_martians" = 1;
      "net.ipv4.conf.default.log_martians" = 1;
      "net.ipv4.icmp_echo_ignore_all" = 0;
      "net.ipv4.tcp_syncookies" = 1;
      "net.ipv4.tcp_rfc1337" = 1;
      "net.ipv4.tcp_timestamps" = 0;
      "kernel.dmesg_restrict" = 1;
      "kernel.kptr_restrict" = 2;
      "kernel.yama.ptrace_scope" = 1;
      "kernel.unprivileged_bpf_disabled" = 1;
      "net.core.bpf_jit_harden" = 2;
      "fs.protected_hardlinks" = 1;
      "fs.protected_symlinks" = 1;
      "fs.protected_fifos" = 2;
      "fs.protected_regular" = 2;
      "fs.suid_dumpable" = 0;
      "vm.mmap_rnd_bits" = 32;
      "vm.mmap_rnd_compat_bits" = 16;
    };
  };
  services = {
    xserver = {
      enable = true;
      displayManager.gdm = {
        enable = true;
        wayland = true;
        autoSuspend = false;
      };
      desktopManager.gnome.enable = true;
      libinput = {
        enable = true;
        touchpad = {
          tapping = true;
          naturalScrolling = true;
          disableWhileTyping = true;
        };
      };
      layout = "us";
      xkbOptions = "caps:escape";
    };
    pipewire = {
      enable = true;
      alsa.enable = true;
      alsa.support32Bit = true;
      pulse.enable = true;
      jack.enable = true;
      extraConfig.pipewire = {
        "context.properties" = {
          "default.clock.rate" = 48000;
          "default.clock.quantum" = 1024;
          "default.clock.min-quantum" = 32;
          "default.clock.max-quantum" = 8192;
        };
      };
    };
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
    avahi = {
      enable = true;
      nssmdns = true;
      openFirewall = true;
    };
    blueman.enable = true;
    timesyncd = {
      enable = true;
      servers = [
        "time.cloudflare.com"
        "time.google.com"
        "pool.ntp.org"
      ];
    };
    openssh = {
      enable = true;
      settings = {
        PermitRootLogin = "no";
        PasswordAuthentication = false;
        PubkeyAuthentication = true;
        AuthenticationMethods = "publickey";
        ClientAliveInterval = 300;
        ClientAliveCountMax = 2;
        LoginGraceTime = 60;
        MaxAuthTries = 3;
        MaxSessions = 2;
        X11Forwarding = false;
        AllowAgentForwarding = false;
        AllowTcpForwarding = false;
        GatewayPorts = "no";
        PermitTunnel = "no";
        LogLevel = "VERBOSE";
        SyslogFacility = "AUTHPRIV";
      };
    };
    journald.settings = {
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
    fwupd.enable = true;
    flatpak.enable = true;
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
    cron = {
      enable = true;
      systemCronJobs = [
        "0 3 * * 0 root nix-collect-garbage -d"
        "0 2 * * * root journalctl --vacuum-time=30d"
        "0 4 * * * root find /tmp -type f -atime +7 -delete"
      ];
    };
    power-profiles-daemon.enable = true;
    geoclue2.enable = true;
    gnome = {
      glib-networking.enable = true;
      gnome-keyring.enable = true;
      gnome-online-accounts.enable = true;
    };
  };
  environment.systemPackages = with pkgs; [
    vim
    nano
    git
    wget
    curl
    rsync
    tree
    htop
    iotop
    zip
    unzip
    p7zip
    rar
    networkmanagerapplet
    network-manager-applet
    wireless-tools
    wpa_supplicant_gui
    gnupg
    pinentry-gtk2
    keepassxc
    clamav
    chkrootkit
    rkhunter
    libreoffice-fresh
    onlyoffice-bin
    thunderbird
    element-desktop
    signal-desktop
    firefox-esr
    chromium
    vlc
    gimp
    inkscape
    vscode
    git
    docker
    teams-for-linux
    slack
    zoom-us
    skypeforlinux
    gparted
    baobab
    dconf-editor
    gnome-tweaks
    font-manager
    file-roller
    evince
    okular
    gedit
    gnome-terminal
    nautilus
    eog
    hplip
    hplipWithPlugin
    openvpn
    openconnect
    networkmanager-openvpn
    networkmanager-openconnect
    remmina
    virt-manager
    prometheus-node-exporter
    borgbackup
    rsnapshot
  ];
  fonts = {
    packages = with pkgs; [
      corefonts
      vistafonts
      liberation_ttf
      dejavu_fonts
      noto-fonts
      noto-fonts-cjk
      noto-fonts-emoji
      fira-code
      fira-code-symbols
      source-code-pro
      jetbrains-mono
      ubuntu_font_family
      open-sans
      roboto
      font-awesome
    ];
    fontconfig = {
      enable = true;
      defaultFonts = {
        serif = ["Liberation Serif" "DejaVu Serif"];
        sansSerif = ["Liberation Sans" "DejaVu Sans"];
        monospace = ["Fira Code" "DejaVu Sans Mono"];
      };
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
  users = {
    mutableUsers = false;
    defaultUserShell = pkgs.bash;
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
        openssh.authorizedKeys.keys = [
        ];
        hashedPassword = "!";
        description = "Enterprise User";
        shell = pkgs.bash;
      };
    };
    extraGroups = {
      enterprise = {gid = 1000;};
      audit = {gid = 1001;};
    };
  };
  xdg = {
    portal = {
      enable = true;
      extraPortals = with pkgs; [
        xdg-desktop-portal-gnome
        xdg-desktop-portal-gtk
      ];
      config.common.default = "*";
    };
    mime.enable = true;
  };
  programs = {
    gnome-disks.enable = true;
    file-roller.enable = true;
    bash = {
      completion.enable = true;
      shellInit = ''
        set +h
        umask 022
        export HISTSIZE=10000
        export HISTFILESIZE=20000
        export HISTCONTROL=ignoreboth:erasedups
        export HISTTIMEFORMAT='%F %T '
        alias rm='rm -i'
        alias cp='cp -i'
        alias mv='mv -i'
        alias ll='ls -la'
        alias la='ls -A'
        alias l='ls -CF'
        alias grep='grep --color=auto'
        alias egrep='egrep --color=auto'
        alias fgrep='fgrep --color=auto'
        export EDITOR=vim
        export BROWSER=firefox
        export TERMINAL=gnome-terminal
      '';
    };
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
    gnupg.agent = {
      enable = true;
      enableSSHSupport = true;
      pinentryFlavor = "gtk2";
    };
    fuse.userAllowOther = true;
    ssh = {
      startAgent = true;
      agentTimeout = "1h";
    };
    appimage = {
      enable = true;
      binfmt = true;
    };
    firefox = {
      enable = true;
      package = pkgs.firefox-esr;
      preferences = {
        "privacy.trackingprotection.enabled" = true;
        "privacy.trackingprotection.pbmode.enabled" = true;
        "privacy.donottrackheader.enabled" = true;
        "security.tls.version.min" = 3;
        "security.tls.version.max" = 4;
        "dom.security.https_only_mode" = true;
        "toolkit.telemetry.enabled" = false;
        "toolkit.telemetry.unified" = false;
        "datareporting.healthreport.uploadEnabled" = false;
        "datareporting.policy.dataSubmissionEnabled" = false;
        "browser.startup.homepage" = "about:blank";
        "browser.newtabpage.enabled" = false;
        "browser.download.useDownloadDir" = true;
        "browser.download.dir" = "/home/enterprise-user/Downloads";
      };
    };
  };
  virtualisation = {
    libvirtd = {
      enable = true;
      qemu = {
        package = pkgs.qemu_kvm;
        ovmf.enable = true;
        swtpm.enable = true;
      };
    };
    docker = {
      enable = true;
      enableOnBoot = true;
      autoPrune = {
        enable = true;
        dates = "weekly";
      };
    };
    podman = {
      enable = true;
      dockerCompat = true;
      defaultNetwork.settings.dns_enabled = true;
    };
  };
  fileSystems = {
    "/" = {
      options = ["noatime" "nodiratime"];
    };
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
  environment.variables = {
    ENTERPRISE_WORKSTATION = "1";
    SECURITY_LEVEL = "HARDENED";
    COMPLIANCE_FRAMEWORKS = "SOC2,ISO27001,NIST";
    BROWSER = "firefox";
    EDITOR = "vim";
    TERMINAL = "gnome-terminal";
    DOCKER_BUILDKIT = "1";
    GNUPGHOME = "$HOME/.gnupg";
  };
  nix = {
    settings = {
      max-jobs = "auto";
      cores = 0;
      auto-optimise-store = true;
      min-free = 2 * 1024 * 1024 * 1024;
      max-free = 5 * 1024 * 1024 * 1024;
      sandbox = true;
      allowed-users = ["@wheel"];
      trusted-users = ["root"];
      experimental-features = ["nix-command" "flakes"];
      substituters = [
        "https://cache.nixos.org"
        "https://nix-community.cachix.org"
      ];
      trusted-public-keys = [
        "cache.nixos.org-1:6NCHdD59X431o0gWypbMrAURkbJ16ZPMQFGspcDShjY="
        "nix-community.cachix.org-1:mB9FSh9qf2dCimDSUo8Zy7bkq5CX+/rkCWyvRCYg3Fs="
      ];
    };
    gc = {
      automatic = true;
      dates = "weekly";
      options = "--delete-older-than 14d";
    };
    optimise = {
      automatic = true;
      dates = ["04:00"];
    };
  };
  system = {
    stateVersion = "24.11";
    activationScripts = {
      enterpriseWorkstationSetup = ''
        mkdir -p /etc/enterprise
        mkdir -p /var/log/enterprise
        mkdir -p /var/lib/enterprise
        chmod 755 /etc/enterprise
        chmod 750 /var/log/enterprise
        chmod 750 /var/lib/enterprise
        echo "SOC2,ISO27001,NIST" > /etc/enterprise/compliance-frameworks
        echo "$(date -Iseconds)" > /etc/enterprise/deployment-date
        echo "enterprise-workstation" > /etc/enterprise/profile-type
        if [ ! -f /etc/enterprise/hostname-configured ]; then
        echo "enterprise-ws-$(cat /etc/machine-id | cut -c1-8)" > /etc/hostname
        touch /etc/enterprise/hostname-configured
        fi
      '';
    };
  };
  documentation = {
    enable = true;
    nixos.enable = true;
    man.enable = true;
    info.enable = true;
  };
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
  console = {
    font = "Lat2-Terminus16";
    keyMap = "us";
    useXkbConfig = true;
  };
  powerManagement = {
    enable = true;
    cpuFreqGovernor = lib.mkDefault "powersave";
  };
}
