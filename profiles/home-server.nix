{
  config,
  lib,
  pkgs,
  ...
}: {
  meta = {
    name = "home-server";
    description = "Bleeding-edge home server profile with comprehensive self-hosting services, media management, and automation";
    maintainers = ["nixos-unified"];
    tags = ["home" "server" "bleeding-edge" "self-hosting" "media" "automation" "containers"];
  };

  imports = [
    ./base.nix
  ];

  # Home server unified configuration
  unified = {
    # Core with bleeding-edge optimizations for servers
    core = {
      enable = true;
      security.level = "balanced"; # Usable security for home environment
      performance.enable = true;
      performance.profile = "server"; # Server-optimized performance
      stability.channel = "bleeding-edge"; # Latest packages for modern features
    };

    # No desktop environment for servers
    desktop.enable = false;

    # Comprehensive services stack
    services = {
      enable = true;
      profile = "home-server";

      # Self-hosting core services
      self-hosting = {
        enable = true;
        reverse-proxy = "traefik";
        ssl-certificates = "letsencrypt";
        dns-provider = "cloudflare";
      };

      # Media services
      media = {
        enable = true;
        jellyfin = true;
        immich = true;
        navidrome = true; # Music streaming
        photoprism = true;
        plex = true; # Alternative to Jellyfin
      };

      # Cloud and productivity services
      cloud = {
        enable = true;
        nextcloud = true;
        vaultwarden = true; # Password manager
        paperless = true; # Document management
        bookstack = true; # Wiki/documentation
        freshrss = true; # RSS reader
      };

      # Home automation
      automation = {
        enable = true;
        home-assistant = true;
        node-red = true;
        mosquitto = true; # MQTT broker
        zigbee2mqtt = true;
        esphome = true;
      };

      # Development services
      development = {
        enable = true;
        gitea = true; # Git hosting
        drone = true; # CI/CD
        registry = true; # Container registry
        database-cluster = true;
        redis-cluster = true;
      };

      # Network services
      network = {
        enable = true;
        pihole = true; # DNS filtering
        unbound = true; # DNS resolver
        wireguard = true; # VPN server
        tailscale = true; # Mesh VPN
        nginx-proxy = true;
      };

      # Monitoring and observability
      monitoring = {
        enable = true;
        prometheus = true;
        grafana = true;
        loki = true; # Log aggregation
        uptime-kuma = true; # Service monitoring
        ntopng = true; # Network monitoring
      };

      # Backup and storage
      backup = {
        enable = true;
        restic = true;
        borgbackup = true;
        syncthing = true;
        rclone = true;
        automated-snapshots = true;
      };
    };

    # Container orchestration
    containers = {
      enable = true;
      runtime = "podman";

      # Podman configuration
      podman = {
        enable = true;
        rootless = true;
        gpu-support = true;
        compose = true;
        quadlet = true; # NixOS integration
      };

      # Docker compatibility
      docker = {
        enable = true;
        compatibility = true;
        buildx = true;
        compose = true;
      };

      # Kubernetes (K3s)
      kubernetes = {
        enable = true;
        distribution = "k3s";
        gpu-operator = true;
        local-storage = true;
        ingress = "traefik";
      };

      # Container registry
      registry = {
        enable = true;
        private = true;
        garbage-collection = true;
      };
    };

    # Bleeding-edge features
    bleeding-edge = {
      enable = true;

      packages = {
        source = "nixpkgs-unstable";
        override-stable = true;
        categories = {
          server = true;
          containers = true;
          development = true;
          monitoring = true;
        };
        experimental = {
          enable = true;
          allow-unfree = true;
        };
      };

      kernel = {
        version = "latest";
        patches = {
          performance = true;
          security = true;
          networking = true;
        };
      };

      services = {
        systemd-experimental = true;
        container-innovations = true;
        networking-stack = "latest";
      };
    };

    # Hardware optimization for servers
    hardware = {
      enable = true;
      server = true;

      # GPU support for transcoding and AI
      graphics = {
        acceleration = true;
        transcoding = true;
        ai-workloads = true;
        headless = true;
      };

      # Storage optimization
      storage = {
        zfs = true;
        nvme-optimization = true;
        raid-support = true;
        encryption = true;
      };

      # Network optimization
      networking = {
        high-performance = true;
        multiple-interfaces = true;
        vlan-support = true;
        bridge-support = true;
      };
    };

    # Security for home servers
    security = {
      home-server = {
        enable = true;
        level = "balanced";
        remote-access = true;
        fail2ban = true;
        intrusion-detection = true;
        encrypted-storage = true;
        backup-encryption = true;
      };

      # Network security
      network = {
        firewall = true;
        dmz-support = true;
        vlan-isolation = true;
        vpn-server = true;
      };
    };

    # Automation and maintenance
    automation = {
      enable = true;

      updates = {
        automatic = true;
        schedule = "weekly";
        security-patches = "immediate";
        rollback-on-failure = true;
      };

      maintenance = {
        log-rotation = true;
        cleanup = true;
        health-checks = true;
        self-healing = true;
      };

      monitoring = {
        alerting = true;
        notifications = true;
        health-dashboard = true;
      };
    };
  };

  # Use bleeding-edge packages for home server
  nixpkgs = {
    config = {
      allowUnfree = true; # For some server applications
      allowInsecure = false;
      allowBroken = false;

      # Server-specific package preferences
      packageOverrides = pkgs:
        with pkgs; {
          # Use latest stable versions
          docker = docker_25;
          kubernetes = kubernetes_1_29;
          prometheus = prometheus_2_48;
        };
    };
  };

  # Server boot configuration
  boot = {
    # Latest kernel for server features and hardware support
    kernelPackages = pkgs.linuxPackages_latest;

    # Server-optimized kernel parameters
    kernelParams = [
      # Memory management for servers
      "transparent_hugepage=madvise"
      "vm.swappiness=10"
      "vm.vfs_cache_pressure=50"

      # Network performance
      "net.core.default_qdisc=fq_codel"
      "net.ipv4.tcp_congestion_control=bbr"
      "net.core.rmem_max=134217728"
      "net.core.wmem_max=134217728"

      # Container optimizations
      "cgroup_enable=memory"
      "cgroup_memory=1"
      "systemd.unified_cgroup_hierarchy=1"

      # Security
      "kernel.kptr_restrict=2"
      "kernel.dmesg_restrict=1"
      "kernel.unprivileged_bpf_disabled=1"

      # Server stability
      "panic=10"
      "oops=panic"

      # Power management for always-on servers
      "intel_pstate=active"
      "processor.max_cstate=1"

      # Quiet boot for headless operation
      "quiet"
      "loglevel=3"
      "systemd.show_status=false"
      "rd.udev.log_level=3"
    ];

    # Fast boot configuration for servers
    loader = {
      systemd-boot = {
        enable = true;
        configurationLimit = 5; # Keep fewer generations
        editor = false; # Security
      };
      efi.canTouchEfiVariables = true;
      timeout = 2; # Quick boot
    };

    # Server initrd optimizations
    initrd = {
      systemd.enable = true; # Modern init
      availableKernelModules = [
        # Storage
        "nvme"
        "ahci"
        "xhci_pci"
        "usb_storage"
        "sd_mod"
        "sr_mod"
        # Network
        "e1000e"
        "igb"
        "ixgbe"
        "r8169"
        # Containers
        "overlay"
        "br_netfilter"
        "ip_tables"
        "iptable_nat"
        # ZFS support
        "zfs"
      ];

      # Network in initrd for remote unlocking
      network = {
        enable = true;
        ssh = {
          enable = true;
          port = 2222;
          hostKeys = [
            "/etc/secrets/initrd/ssh_host_rsa_key"
            "/etc/secrets/initrd/ssh_host_ed25519_key"
          ];
        };
      };
    };

    # Support for various filesystems
    supportedFilesystems = ["zfs" "btrfs" "ext4" "xfs" "ntfs" "vfat"];

    # ZFS configuration
    zfs = {
      forceImportRoot = false;
      requestEncryptionCredentials = true;
    };

    # Kernel modules for server functionality
    kernelModules = [
      # Virtualization
      "kvm-intel"
      "kvm-amd"
      # Containers
      "overlay"
      "br_netfilter"
      # Network
      "bonding"
      "8021q"
      # Storage
      "zfs"
    ];

    # Server-specific sysctl settings
    kernel.sysctl = {
      # Network performance
      "net.ipv4.ip_forward" = 1;
      "net.ipv6.conf.all.forwarding" = 1;
      "net.bridge.bridge-nf-call-iptables" = 1;
      "net.bridge.bridge-nf-call-ip6tables" = 1;

      # Container networking
      "net.ipv4.ip_nonlocal_bind" = 1;
      "net.ipv4.conf.all.route_localnet" = 1;

      # File system limits
      "fs.file-max" = 2097152;
      "fs.inotify.max_user_watches" = 1048576;
      "fs.inotify.max_user_instances" = 1024;

      # Memory management
      "vm.max_map_count" = 262144;
      "vm.overcommit_memory" = 1;

      # Security
      "kernel.core_pattern" = "|/bin/false";
      "kernel.kexec_load_disabled" = 1;

      # Container limits
      "user.max_user_namespaces" = 15000;
      "user.max_inotify_watches" = 1048576;
    };
  };

  # Server hardware configuration
  hardware = {
    # Enable all firmware
    enableRedistributableFirmware = true;
    enableAllFirmware = true;

    # CPU microcode updates
    cpu = {
      intel.updateMicrocode = true;
      amd.updateMicrocode = true;
    };

    # Graphics for transcoding (headless)
    opengl = {
      enable = true;
      driSupport = true;

      extraPackages = with pkgs; [
        # Intel Quick Sync Video
        intel-media-driver
        vaapiIntel
        intel-compute-runtime

        # AMD VCE/VCN
        mesa.drivers
        rocm-opencl-icd

        # NVIDIA NVENC (if using proprietary drivers)
        # nvidia-vaapi-driver
      ];
    };

    # Audio (for media servers)
    pulseaudio.enable = false;

    # Bluetooth (for IoT devices)
    bluetooth = {
      enable = true;
      powerOnBoot = false; # Manual control
      settings = {
        General = {
          Enable = "Source,Sink,Media,Socket";
          Experimental = false; # Stability over features
        };
      };
    };

    # I2C for hardware monitoring
    i2c.enable = true;

    # Sensor support
    sensor.iio.enable = true;
  };

  # Server services configuration
  services = {
    # SSH for remote administration
    openssh = {
      enable = true;
      settings = {
        # Security settings
        PermitRootLogin = "no";
        PasswordAuthentication = false;
        PubkeyAuthentication = true;
        AuthenticationMethods = "publickey";

        # Performance settings
        ClientAliveInterval = 300;
        ClientAliveCountMax = 2;
        MaxAuthTries = 3;
        MaxSessions = 10; # More sessions for server
        LoginGraceTime = 60;

        # Server-specific settings
        X11Forwarding = false;
        AllowAgentForwarding = true; # Useful for server administration
        AllowTcpForwarding = true; # For tunnel access
        GatewayPorts = "clientspecified";

        # Logging
        LogLevel = "INFO"; # Balanced logging
        SyslogFacility = "AUTHPRIV";
      };

      # Multiple ports for redundancy
      ports = [22 2222];

      # Host keys
      hostKeys = [
        {
          path = "/etc/ssh/ssh_host_ed25519_key";
          type = "ed25519";
        }
        {
          path = "/etc/ssh/ssh_host_rsa_key";
          type = "rsa";
          bits = 4096;
        }
      ];
    };

    # Container runtime
    podman = {
      enable = true;

      # Docker compatibility
      dockerCompat = true;
      defaultNetwork.settings.dns_enabled = true;

      # Autoupdate containers
      autoPrune = {
        enable = true;
        dates = "weekly";
        flags = ["--all"];
      };
    };

    # Time synchronization (critical for servers)
    chrony = {
      enable = true;
      servers = [
        "time.cloudflare.com"
        "time.google.com"
        "pool.ntp.org"
        "time.nist.gov"
      ];

      # Server-specific settings
      extraConfig = ''
        # Server time synchronization
        makestep 1.0 3
        rtcsync

        # Allow clients to sync from this server
        allow 192.168.0.0/16
        allow 10.0.0.0/8
        allow 172.16.0.0/12
      '';
    };

    # System logging
    journald.settings = {
      # Server logging configuration
      Storage = "persistent";
      SystemMaxUse = "4G"; # More logs for servers
      SystemKeepFree = "8G";
      SystemMaxFileSize = "200M";
      SystemMaxFiles = 50;
      RuntimeMaxUse = "400M";
      RuntimeKeepFree = "2G";
      Compress = true;
      Seal = true;
      SplitMode = "uid";

      # Rate limiting for stability
      RateLimitInterval = "30s";
      RateLimitBurst = 10000;

      # Forward to syslog for external log management
      ForwardToSyslog = true;
      ForwardToWall = false;
    };

    # System monitoring
    prometheus.exporters.node = {
      enable = true;
      port = 9100;
      listenAddress = "0.0.0.0"; # Allow monitoring from network

      enabledCollectors = [
        "systemd"
        "processes"
        "interrupts"
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
        "vmstat"
        "logind"
        "thermal_zone"
        "hwmon"
      ];

      disabledCollectors = [
        "textfile" # Security: disable arbitrary file reading
      ];
    };

    # Network time serving
    ntp = {
      enable = false; # Using chrony instead
    };

    # mDNS for service discovery
    avahi = {
      enable = true;
      nssmdns = true;
      openFirewall = true;

      # Publish server services
      publish = {
        enable = true;
        addresses = true;
        workstation = false; # This is a server
        domain = true;
      };

      extraServiceFiles = {
        ssh = ''
          <?xml version="1.0" standalone='no'?>
          <!DOCTYPE service-group SYSTEM "avahi-service.dtd">
          <service-group>
            <name replace-wildcards="yes">%h SSH</name>
            <service>
              <type>_ssh._tcp</type>
              <port>22</port>
            </service>
          </service-group>
        '';
      };
    };

    # Fail2ban for security
    fail2ban = {
      enable = true;
      maxretry = 3;
      ignoreIP = [
        "127.0.0.0/8"
        "10.0.0.0/8"
        "192.168.0.0/16"
        "172.16.0.0/12"
      ];

      jails = {
        # SSH protection
        sshd = {
          enabled = true;
          port = "ssh";
          filter = "sshd";
          logpath = "/var/log/auth.log";
          maxretry = 3;
          bantime = 3600;
        };

        # HTTP services protection
        nginx-http-auth = {
          enabled = true;
          port = "http,https";
          logpath = "/var/log/nginx/error.log";
        };
      };
    };

    # Automatic updates
    system-update = {
      enable = true;
      dates = "weekly";
      randomizedDelaySec = "6h";
    };

    # Hardware monitoring
    smartd = {
      enable = true;
      autodetect = true;
      notifications = {
        wall.enable = false; # No console for servers
        mail.enable = true;
        mail.recipient = "admin@localhost";
      };
    };

    # Disk health monitoring
    hddtemp = {
      enable = true;
      drives = ["/dev/sda" "/dev/sdb" "/dev/nvme0n1"];
    };

    # UPS monitoring (if UPS present)
    apcupsd = {
      enable = false; # Enable if UPS is connected
      configText = ''
        UPSNAME homeserver-ups
        UPSCABLE usb
        UPSTYPE usb
        DEVICE
        BATTERYLEVEL 20
        MINUTES 5
      '';
    };

    # ZFS services
    zfs = {
      autoScrub = {
        enable = true;
        interval = "weekly";
      };
      autoSnapshot = {
        enable = true;
        flags = "-k -p --utc";
        frequent = 8; # Every 15 minutes for 2 hours
        hourly = 24;
        daily = 7;
        weekly = 4;
        monthly = 12;
      };
    };

    # Container image building
    nixos-containers = {
      enable = true;
    };

    # Database services (basic setup)
    postgresql = {
      enable = true;
      package = pkgs.postgresql_16;
      enableTCPIP = true;

      settings = {
        # Performance tuning for servers
        shared_buffers = "256MB";
        effective_cache_size = "1GB";
        maintenance_work_mem = "64MB";
        checkpoint_completion_target = "0.9";
        wal_buffers = "16MB";
        default_statistics_target = "100";
        random_page_cost = "1.1"; # For SSDs

        # Logging
        log_statement = "mod";
        log_duration = true;
        log_line_prefix = "%t [%p]: [%l-1] user=%u,db=%d,app=%a,client=%h ";
      };

      authentication = pkgs.lib.mkOverride 10 ''
        # Allow local connections
        local all all trust
        host all all 127.0.0.1/32 trust
        host all all ::1/128 trust

        # Allow network connections (configure as needed)
        host all all 192.168.0.0/16 md5
        host all all 10.0.0.0/8 md5
      '';
    };

    redis.servers.default = {
      enable = true;
      bind = "127.0.0.1";
      port = 6379;

      settings = {
        maxmemory = "256mb";
        maxmemory-policy = "allkeys-lru";
        save = "900 1 300 10 60 10000";
        tcp-keepalive = 300;
      };
    };
  };

  # Server security configuration
  security = {
    # Sudo configuration for server administration
    sudo = {
      enable = true;
      wheelNeedsPassword = true;
      extraConfig = ''
        # Server sudo configuration
        Defaults timestamp_timeout=60
        Defaults !visiblepw
        Defaults always_set_home
        Defaults env_reset
        Defaults env_keep="COLORS DISPLAY HOSTNAME HISTSIZE KDEDIR LS_COLORS"
        Defaults env_keep+="MAIL PS1 PS2 QTDIR USERNAME LANG LC_ADDRESS LC_CTYPE"
        Defaults env_keep+="LC_COLLATE LC_IDENTIFICATION LC_MEASUREMENT LC_MESSAGES"
        Defaults env_keep+="LC_MONETARY LC_NAME LC_NUMERIC LC_PAPER LC_TELEPHONE"
        Defaults env_keep+="LC_TIME LC_ALL LANGUAGE LINGUAS _XKB_CHARSET XAUTHORITY"
        Defaults secure_path="/run/wrappers/bin:/nix/var/nix/profiles/default/bin:/run/current-system/sw/bin"
        Defaults use_pty

        # Allow server management without password for specific commands
        %wheel ALL=(ALL) NOPASSWD: /run/current-system/sw/bin/systemctl restart *, /run/current-system/sw/bin/systemctl reload *
        %wheel ALL=(ALL) NOPASSWD: /run/current-system/sw/bin/podman *, /run/current-system/sw/bin/docker *
      '';
    };

    # AppArmor for container security
    apparmor = {
      enable = true;
      killUnconfinedConfinables = false; # Don't break servers
      packages = with pkgs; [
        apparmor-profiles
      ];
    };

    # Audit system for server monitoring
    auditd.enable = true;
    audit = {
      enable = true;
      rules = [
        # Monitor system administration
        "-a always,exit -F arch=b64 -S execve -C uid!=euid -F euid=0 -k privilege_escalation"
        "-a always,exit -F arch=b64 -S execve -C gid!=egid -F egid=0 -k privilege_escalation"

        # Monitor file access
        "-w /etc/passwd -p wa -k identity"
        "-w /etc/group -p wa -k identity"
        "-w /etc/shadow -p wa -k identity"
        "-w /etc/sudoers -p wa -k privilege"

        # Monitor network configuration
        "-w /etc/hosts -p wa -k network"
        "-w /etc/resolv.conf -p wa -k network"

        # Monitor container activities
        "-w /var/lib/containers -p wa -k containers"
        "-w /etc/containers -p wa -k containers"

        # Monitor service files
        "-w /etc/systemd/system -p wa -k services"
        "-w /etc/systemd/user -p wa -k services"
      ];
    };

    # PAM configuration
    pam.services = {
      sshd.failDelay = 2000000; # 2 second delay
      sudo.failDelay = 2000000;
    };

    # Real-time scheduling for containers
    rtkit.enable = true;

    # Polkit for service management
    polkit = {
      enable = true;
      extraConfig = ''
        /* Allow users in wheel group to manage systemd services */
        polkit.addRule(function(action, subject) {
            if (action.id == "org.freedesktop.systemd1.manage-units" &&
                subject.isInGroup("wheel")) {
                return polkit.Result.YES;
            }
        });

        /* Allow users in wheel group to manage containers */
        polkit.addRule(function(action, subject) {
            if (action.id.indexOf("org.freedesktop.machine1.") == 0 &&
                subject.isInGroup("wheel")) {
                return polkit.Result.YES;
            }
        });
      '';
    };

    # Disable unnecessary features for servers
    lockKernelLogs = false; # Allow log access for debugging
    forcePageTableIsolation = true; # Security
  };

  # Server networking configuration
  networking = {
    # Use NetworkManager for flexibility
    networkmanager = {
      enable = true;
      dns = "systemd-resolved";

      # Server-specific settings
      wifi.powersave = false;
      ethernet.macAddress = "preserve"; # Keep MAC addresses
    };

    # Hostname
    hostName = lib.mkDefault "home-server";
    domain = lib.mkDefault "home.local";

    # Enable IPv6
    enableIPv6 = true;

    # Server firewall configuration
    firewall = {
      enable = true;

      # Server ports
      allowedTCPPorts = [
        22 # SSH
        80 # HTTP
        443 # HTTPS
        2222 # Alternative SSH
        8080 # Alternative HTTP
        9090 # Prometheus
        3000 # Grafana
        5432 # PostgreSQL
        6379 # Redis
      ];

      allowedUDPPorts = [
        53 # DNS
        123 # NTP
        5353 # mDNS
        67 # DHCP (if serving)
        68 # DHCP (if serving)
      ];

      # Server-specific rules
      extraCommands = ''
        # Allow containers to communicate
        iptables -A INPUT -i podman+ -j ACCEPT
        iptables -A INPUT -i docker+ -j ACCEPT
        iptables -A INPUT -i br-+ -j ACCEPT

        # Allow established connections
        iptables -A INPUT -m conntrack --ctstate ESTABLISHED,RELATED -j ACCEPT

        # Allow loopback
        iptables -A INPUT -i lo -j ACCEPT

        # Allow ICMP (ping)
        iptables -A INPUT -p icmp -j ACCEPT

        # Log dropped packets
        iptables -A INPUT -m limit --limit 5/min -j LOG --log-prefix "iptables denied: " --log-level 7
      '';

      # Rate limiting
      pingLimit = "--limit 10/minute --limit-burst 5";
      logRefusedConnections = true;
      logRefusedPackets = false; # Too verbose for servers
    };

    # DNS resolution
    nameservers = ["1.1.1.1" "1.0.0.1" "8.8.8.8"];

    # Enable IP forwarding for containers and VMs

    # Network optimization
    dhcpcd.extraConfig = ''
      # Server network optimizations
      noarp
      option rapid_commit
      option domain_name_servers, domain_name, domain_search, host_name
      option classless_static_routes
      option ntp_servers
      timeout 30
      reboot 5
    '';

    # Hosts file for local services
    hosts = {
      "127.0.0.1" = ["localhost" "home-server.local"];
      "::1" = ["localhost" "home-server.local"];
    };
  };

  # Server-specific packages
  environment.systemPackages = with pkgs; [
    # Essential server tools
    vim
    neovim
    git
    wget
    curl
    rsync
    tree
    htop
    btop
    iotop
    lsof
    strace
    tcpdump

    # Network tools
    nmap
    netcat
    socat
    iperf3
    mtr
    dig
    whois
    traceroute

    # System monitoring
    sysstat
    iostat
    vmstat
    smartmontools
    lm_sensors

    # Container tools
    podman
    podman-compose
    docker
    docker-compose
    buildah
    skopeo

    # Kubernetes tools
    kubectl
    k9s
    helm

    # Archive and compression
    zip
    unzip
    p7zip
    gzip
    bzip2
    xz
    zstd

    # Text processing
    jq
    yq
    xmlstarlet

    # Backup tools
    restic
    borgbackup
    rclone
    rsnapshot

    # Development tools
    gcc
    clang
    make
    cmake
    pkg-config

    # Database tools
    postgresql
    redis
    sqlite

    # Web tools
    nginx
    apache2
    caddy

    # SSL/TLS
    openssl
    letsencrypt
    certbot

    # Monitoring tools
    prometheus
    grafana

    # Security tools
    fail2ban
    ufw
    iptables
    nftables

    # File system tools
    zfs
    btrfs-progs
    e2fsprogs
    xfsprogs
    dosfstools

    # Hardware tools
    pciutils
    usbutils
    dmidecode
    hdparm

    # Performance tools
    stress
    stress-ng
    sysbench

    # Log management
    logrotate
    rsyslog

    # Automation tools
    ansible
    terraform

    # Container security
    crun
    runc

    # Service mesh (if using K8s)
    istioctl

    # Backup verification
    par2cmdline

    # Media tools (for media servers)
    ffmpeg-full
    imagemagick

    # Python tools for server management
    python3
    python3Packages.pip
    python3Packages.requests
    python3Packages.pyyaml

    # Node.js for modern server apps
    nodejs
    yarn

    # Go tools
    go

    # Rust tools
    rustc
    cargo
  ];

  # Server fonts (minimal)
  fonts = {
    packages = with pkgs; [
      dejavu_fonts
      liberation_ttf
      source-code-pro
    ];

    fontconfig = {
      enable = true;
      defaultFonts = {
        serif = ["Liberation Serif"];
        sansSerif = ["Liberation Sans"];
        monospace = ["Source Code Pro"];
      };
    };
  };

  # Users configuration for server
  users = {
    # Mutable users for easier management
    mutableUsers = true;

    # Default shell
    defaultUserShell = pkgs.bash;

    # Server users
    users = {
      homeserver = {
        isNormalUser = true;
        extraGroups = [
          "wheel" # sudo access
          "networkmanager" # network management
          "docker" # container management
          "podman" # podman containers
          "systemd-journal" # log access
          "audio" # for media services
          "video" # for transcoding
        ];
        shell = pkgs.bash;
        description = "Home Server Administrator";
        openssh.authorizedKeys.keys = [
          # Add SSH public keys here
          # "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIG... admin@example.com"
        ];
        # Set password with: passwd homeserver
      };

      # Service user for containers
      container-user = {
        isSystemUser = true;
        group = "containers";
        home = "/var/lib/containers";
        createHome = true;
        description = "Container service user";
      };
    };

    # Server groups
    extraGroups = {
      containers = {gid = 3001;};
      media = {gid = 3002;};
      backup = {gid = 3003;};
    };
  };

  # Virtualization support
  virtualisation = {
    # Podman for rootless containers
    podman = {
      enable = true;
      dockerCompat = true;
      defaultNetwork.settings.dns_enabled = true;

      # Autoupdate containers
      autoPrune = {
        enable = true;
        dates = "weekly";
        flags = ["--all"];
      };
    };

    # Docker for compatibility
    docker = {
      enable = true;
      enableOnBoot = true;
      autoPrune = {
        enable = true;
        dates = "weekly";
      };

      # Server optimizations
      extraOptions = "--default-runtime=runc --log-driver=journald";

      # Storage driver
      storageDriver = "overlay2";
    };

    # Container networking
    oci-containers = {
      backend = "podman";
    };

    # QEMU/KVM for VMs if needed
    libvirtd = {
      enable = true;
      qemu = {
        package = pkgs.qemu_kvm;
        runAsRoot = false;
        swtpm.enable = true;
        ovmf.enable = true;
      };
    };
  };

  # File systems
  fileSystems = {
    # Root filesystem optimizations
    "/" = {
      options = ["noatime" "nodiratime" "discard"];
    };

    # Separate /var for logs and containers
    "/var" = lib.mkIf false {
      # Enable if using separate partition
      options = ["noatime" "nodiratime" "discard"];
    };

    # Container storage
    "/var/lib/containers" = {
      options = ["noatime" "nodiratime" "discard" "user_xattr"];
    };
  };

  # Environment variables
  environment.variables = {
    # Server identification
    HOME_SERVER = "1";
    SERVER_PROFILE = "home-server";
    BLEEDING_EDGE = "1";

    # Container environment
    PODMAN_USERNS = "keep-id";
    DOCKER_BUILDKIT = "1";
    COMPOSE_DOCKER_CLI_BUILD = "1";

    # Development
    EDITOR = "vim";

    # Paths
    PATH = lib.mkForce "$PATH:/run/current-system/sw/bin";
  };

  # Nix configuration for servers
  nix = {
    settings = {
      # Build settings for servers
      max-jobs = "auto";
      cores = 0; # Use all available cores

      # Storage optimization
      auto-optimise-store = true;
      min-free = 5 * 1024 * 1024 * 1024; # 5GB
      max-free = 20 * 1024 * 1024 * 1024; # 20GB

      # Security settings
      sandbox = true;
      allowed-users = ["@wheel" "@users"];
      trusted-users = ["root" "@wheel"];

      # Modern features
      experimental-features = ["nix-command" "flakes" "auto-allocate-uids"];

      # Server substituters
      substituters = [
        "https://cache.nixos.org"
        "https://nix-community.cachix.org"
        "https://cuda-maintainers.cachix.org"
        "https://devenv.cachix.org"
      ];

      trusted-public-keys = [
        "cache.nixos.org-1:6NCHdD59X431o0gWypbMrAURkbJ16ZPMQFGspcDShjY="
        "nix-community.cachix.org-1:mB9FSh9qf2dCimDSUo8Zy7bkq5CX+/rkCWyvRCYg3Fs="
        "cuda-maintainers.cachix.org-1:0dq3bujKpuEPiCgBEKTZL2M6FnfCuBdNOcP2EMKR6Mg="
        "devenv.cachix.org-1:w1cLUi8dv3hnoSPGAuibQv+f9TZLr6cv/Hm9XgU50cw="
      ];

      # Keep outputs for server development
      keep-outputs = true;
      keep-derivations = true;
    };

    # Garbage collection for servers (conservative)
    gc = {
      automatic = true;
      dates = "weekly";
      options = "--delete-older-than 30d";
    };

    # Regular optimization
    optimise = {
      automatic = true;
      dates = ["04:00"];
    };
  };

  # System configuration
  system = {
    stateVersion = "24.11";

    # Server activation scripts
    activationScripts = {
      homeServerSetup = ''
        # Create server directories
        mkdir -p /srv/data
        mkdir -p /srv/media
        mkdir -p /srv/backup
        mkdir -p /srv/containers
        mkdir -p /var/log/home-server

        # Set proper permissions
        chmod 755 /srv/data /srv/media /srv/containers
        chmod 750 /srv/backup /var/log/home-server

        # Create server identification
        echo "home-server" > /etc/server-type
        echo "$(date -Iseconds)" > /etc/server-build-date
        echo "bleeding-edge,containers,media,automation" > /etc/server-capabilities

        # Container setup
        mkdir -p /etc/containers/systemd
        mkdir -p /var/lib/containers/storage

        # Media server setup
        mkdir -p /srv/media/{movies,tv,music,photos,books}
        mkdir -p /srv/data/{nextcloud,vaultwarden,paperless,homeassistant}

        # Set ownership for media
        chown -R homeserver:media /srv/media 2>/dev/null || true
        chown -R homeserver:containers /srv/containers 2>/dev/null || true
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
  time.timeZone = lib.mkDefault "UTC"; # Servers typically use UTC

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

  # Power management for servers
  powerManagement = {
    enable = true;
    cpuFreqGovernor = lib.mkDefault "ondemand"; # Balance performance and power
  };
}
