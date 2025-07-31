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
      security.level = "balanced";
      performance.enable = true;
      performance.profile = "server";
      stability.channel = "bleeding-edge";
    };
    desktop.enable = false;
    services = {
      enable = true;
      profile = "home-server";
      self-hosting = {
        enable = true;
        reverse-proxy = "traefik";
        ssl-certificates = "letsencrypt";
        dns-provider = "cloudflare";
      };
      media = {
        enable = true;
        jellyfin = true;
        immich = true;
        navidrome = true;
        photoprism = true;
        plex = true;
      };
      cloud = {
        enable = true;
        nextcloud = true;
        vaultwarden = true;
        paperless = true;
        bookstack = true;
        freshrss = true;
      };
      automation = {
        enable = true;
        home-assistant = true;
        node-red = true;
        mosquitto = true;
        zigbee2mqtt = true;
        esphome = true;
      };
      development = {
        enable = true;
        gitea = true;
        drone = true;
        registry = true;
        database-cluster = true;
        redis-cluster = true;
      };
      network = {
        enable = true;
        pihole = true;
        unbound = true;
        wireguard = true;
        tailscale = true;
        nginx-proxy = true;
      };
      monitoring = {
        enable = true;
        prometheus = true;
        grafana = true;
        loki = true;
        uptime-kuma = true;
        ntopng = true;
      };
      backup = {
        enable = true;
        restic = true;
        borgbackup = true;
        syncthing = true;
        rclone = true;
        automated-snapshots = true;
      };
    };
    containers = {
      enable = true;
      runtime = "podman";
      podman = {
        enable = true;
        rootless = true;
        gpu-support = true;
        compose = true;
        quadlet = true;
      };
      docker = {
        enable = true;
        compatibility = true;
        buildx = true;
        compose = true;
      };
      kubernetes = {
        enable = true;
        distribution = "k3s";
        gpu-operator = true;
        local-storage = true;
        ingress = "traefik";
      };
      registry = {
        enable = true;
        private = true;
        garbage-collection = true;
      };
    };
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
    hardware = {
      enable = true;
      server = true;
      graphics = {
        acceleration = true;
        transcoding = true;
        ai-workloads = true;
        headless = true;
      };
      storage = {
        zfs = true;
        nvme-optimization = true;
        raid-support = true;
        encryption = true;
      };
      networking = {
        high-performance = true;
        multiple-interfaces = true;
        vlan-support = true;
        bridge-support = true;
      };
    };
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
      network = {
        firewall = true;
        dmz-support = true;
        vlan-isolation = true;
        vpn-server = true;
      };
    };
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
  nixpkgs = {
    config = {
      allowUnfree = true;
      allowInsecure = false;
      allowBroken = false;
      packageOverrides = pkgs:
        with pkgs; {
          docker = docker_25;
          kubernetes = kubernetes_1_29;
          prometheus = prometheus_2_48;
        };
    };
  };
  boot = {
    kernelPackages = pkgs.linuxPackages_latest;
    kernelParams = [
      "transparent_hugepage=madvise"
      "vm.swappiness=10"
      "vm.vfs_cache_pressure=50"
      "net.core.default_qdisc=fq_codel"
      "net.ipv4.tcp_congestion_control=bbr"
      "net.core.rmem_max=134217728"
      "net.core.wmem_max=134217728"
      "cgroup_enable=memory"
      "cgroup_memory=1"
      "systemd.unified_cgroup_hierarchy=1"
      "kernel.kptr_restrict=2"
      "kernel.dmesg_restrict=1"
      "kernel.unprivileged_bpf_disabled=1"
      "panic=10"
      "oops=panic"
      "intel_pstate=active"
      "processor.max_cstate=1"
      "quiet"
      "loglevel=3"
      "systemd.show_status=false"
      "rd.udev.log_level=3"
    ];
    loader = {
      systemd-boot = {
        enable = true;
        configurationLimit = 5;
        editor = false;
      };
      efi.canTouchEfiVariables = true;
      timeout = 2;
    };
    initrd = {
      systemd.enable = true;
      availableKernelModules = [
        "nvme"
        "ahci"
        "xhci_pci"
        "usb_storage"
        "sd_mod"
        "sr_mod"
        "e1000e"
        "igb"
        "ixgbe"
        "r8169"
        "overlay"
        "br_netfilter"
        "ip_tables"
        "iptable_nat"
        "zfs"
      ];
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
    supportedFilesystems = ["zfs" "btrfs" "ext4" "xfs" "ntfs" "vfat"];
    zfs = {
      forceImportRoot = false;
      requestEncryptionCredentials = true;
    };
    kernelModules = [
      "kvm-intel"
      "kvm-amd"
      "overlay"
      "br_netfilter"
      "bonding"
      "8021q"
      "zfs"
    ];
    kernel.sysctl = {
      "net.ipv4.ip_forward" = 1;
      "net.ipv6.conf.all.forwarding" = 1;
      "net.bridge.bridge-nf-call-iptables" = 1;
      "net.bridge.bridge-nf-call-ip6tables" = 1;
      "net.ipv4.ip_nonlocal_bind" = 1;
      "net.ipv4.conf.all.route_localnet" = 1;
      "fs.file-max" = 2097152;
      "fs.inotify.max_user_watches" = 1048576;
      "fs.inotify.max_user_instances" = 1024;
      "vm.max_map_count" = 262144;
      "vm.overcommit_memory" = 1;
      "kernel.core_pattern" = "|/bin/false";
      "kernel.kexec_load_disabled" = 1;
      "user.max_user_namespaces" = 15000;
      "user.max_inotify_watches" = 1048576;
    };
  };
  hardware = {
    enableRedistributableFirmware = true;
    enableAllFirmware = true;
    cpu = {
      intel.updateMicrocode = true;
      amd.updateMicrocode = true;
    };
    opengl = {
      enable = true;
      driSupport = true;
      extraPackages = with pkgs; [
        intel-media-driver
        vaapiIntel
        intel-compute-runtime
        mesa.drivers
        rocm-opencl-icd
      ];
    };
    pulseaudio.enable = false;
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
    i2c.enable = true;
    sensor.iio.enable = true;
  };
  services = {
    openssh = {
      enable = true;
      settings = {
        PermitRootLogin = "no";
        PasswordAuthentication = false;
        PubkeyAuthentication = true;
        AuthenticationMethods = "publickey";
        ClientAliveInterval = 300;
        ClientAliveCountMax = 2;
        MaxAuthTries = 3;
        MaxSessions = 10;
        LoginGraceTime = 60;
        X11Forwarding = false;
        AllowAgentForwarding = true;
        AllowTcpForwarding = true;
        GatewayPorts = "clientspecified";
        LogLevel = "INFO";
        SyslogFacility = "AUTHPRIV";
      };
      ports = [22 2222];
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
    podman = {
      enable = true;
      dockerCompat = true;
      defaultNetwork.settings.dns_enabled = true;
      autoPrune = {
        enable = true;
        dates = "weekly";
        flags = ["--all"];
      };
    };
    chrony = {
      enable = true;
      servers = [
        "time.cloudflare.com"
        "time.google.com"
        "pool.ntp.org"
        "time.nist.gov"
      ];
      extraConfig = ''
        makestep 1.0 3
        rtcsync
        allow 192.168.0.0/16
        allow 10.0.0.0/8
        allow 172.16.0.0/12
      '';
    };
    journald.settings = {
      Storage = "persistent";
      SystemMaxUse = "4G";
      SystemKeepFree = "8G";
      SystemMaxFileSize = "200M";
      SystemMaxFiles = 50;
      RuntimeMaxUse = "400M";
      RuntimeKeepFree = "2G";
      Compress = true;
      Seal = true;
      SplitMode = "uid";
      RateLimitInterval = "30s";
      RateLimitBurst = 10000;
      ForwardToSyslog = true;
      ForwardToWall = false;
    };
    prometheus.exporters.node = {
      enable = true;
      port = 9100;
      listenAddress = "0.0.0.0";
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
        "textfile"
      ];
    };
    ntp = {
      enable = false;
    };
    avahi = {
      enable = true;
      nssmdns = true;
      openFirewall = true;
      publish = {
        enable = true;
        addresses = true;
        workstation = false;
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
        sshd = {
          enabled = true;
          port = "ssh";
          filter = "sshd";
          logpath = "/var/log/auth.log";
          maxretry = 3;
          bantime = 3600;
        };
        nginx-http-auth = {
          enabled = true;
          port = "http,https";
          logpath = "/var/log/nginx/error.log";
        };
      };
    };
    system-update = {
      enable = true;
      dates = "weekly";
      randomizedDelaySec = "6h";
    };
    smartd = {
      enable = true;
      autodetect = true;
      notifications = {
        wall.enable = false;
        mail.enable = true;
        mail.recipient = "admin@localhost";
      };
    };
    hddtemp = {
      enable = true;
      drives = ["/dev/sda" "/dev/sdb" "/dev/nvme0n1"];
    };
    apcupsd = {
      enable = false;
      configText = ''
        UPSNAME homeserver-ups
        UPSCABLE usb
        UPSTYPE usb
        DEVICE
        BATTERYLEVEL 20
        MINUTES 5
      '';
    };
    zfs = {
      autoScrub = {
        enable = true;
        interval = "weekly";
      };
      autoSnapshot = {
        enable = true;
        flags = "-k -p --utc";
        frequent = 8;
        hourly = 24;
        daily = 7;
        weekly = 4;
        monthly = 12;
      };
    };
    nixos-containers = {
      enable = true;
    };
    postgresql = {
      enable = true;
      package = pkgs.postgresql_16;
      enableTCPIP = true;
      settings = {
        shared_buffers = "256MB";
        effective_cache_size = "1GB";
        maintenance_work_mem = "64MB";
        checkpoint_completion_target = "0.9";
        wal_buffers = "16MB";
        default_statistics_target = "100";
        random_page_cost = "1.1";
        log_statement = "mod";
        log_duration = true;
        log_line_prefix = "%t [%p]: [%l-1] user=%u,db=%d,app=%a,client=%h ";
      };
      authentication = pkgs.lib.mkOverride 10 ''
        local all all trust
        host all all 127.0.0.1/32 trust
        host all all ::1/128 trust
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
  security = {
    sudo = {
      enable = true;
      wheelNeedsPassword = true;
      extraConfig = ''
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
        %wheel ALL=(ALL) NOPASSWD: /run/current-system/sw/bin/systemctl restart *, /run/current-system/sw/bin/systemctl reload *
        %wheel ALL=(ALL) NOPASSWD: /run/current-system/sw/bin/podman *, /run/current-system/sw/bin/docker *
      '';
    };
    apparmor = {
      enable = true;
      killUnconfinedConfinables = false;
      packages = with pkgs; [
        apparmor-profiles
      ];
    };
    auditd.enable = true;
    audit = {
      enable = true;
      rules = [
        "-a always,exit -F arch=b64 -S execve -C uid!=euid -F euid=0 -k privilege_escalation"
        "-a always,exit -F arch=b64 -S execve -C gid!=egid -F egid=0 -k privilege_escalation"
        "-w /etc/passwd -p wa -k identity"
        "-w /etc/group -p wa -k identity"
        "-w /etc/shadow -p wa -k identity"
        "-w /etc/sudoers -p wa -k privilege"
        "-w /etc/hosts -p wa -k network"
        "-w /etc/resolv.conf -p wa -k network"
        "-w /var/lib/containers -p wa -k containers"
        "-w /etc/containers -p wa -k containers"
        "-w /etc/systemd/system -p wa -k services"
        "-w /etc/systemd/user -p wa -k services"
      ];
    };
    pam.services = {
      sshd.failDelay = 2000000;
      sudo.failDelay = 2000000;
    };
    rtkit.enable = true;
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
    lockKernelLogs = false;
    forcePageTableIsolation = true;
  };
  networking = {
    networkmanager = {
      enable = true;
      dns = "systemd-resolved";
      wifi.powersave = false;
      ethernet.macAddress = "preserve";
    };
    hostName = lib.mkDefault "home-server";
    domain = lib.mkDefault "home.local";
    enableIPv6 = true;
    firewall = {
      enable = true;
      allowedTCPPorts = [
        22
        80
        443
        2222
        8080
        9090
        3000
        5432
        6379
      ];
      allowedUDPPorts = [
        53
        123
        5353
        67
        68
      ];
      extraCommands = ''
        iptables -A INPUT -i podman+ -j ACCEPT
        iptables -A INPUT -i docker+ -j ACCEPT
        iptables -A INPUT -i br-+ -j ACCEPT
        iptables -A INPUT -m conntrack --ctstate ESTABLISHED,RELATED -j ACCEPT
        iptables -A INPUT -i lo -j ACCEPT
        iptables -A INPUT -p icmp -j ACCEPT
        iptables -A INPUT -m limit --limit 5/min -j LOG --log-prefix "iptables denied: " --log-level 7
      '';
      pingLimit = "--limit 10/minute --limit-burst 5";
      logRefusedConnections = true;
      logRefusedPackets = false;
    };
    nameservers = ["1.1.1.1" "1.0.0.1" "8.8.8.8"];
    dhcpcd.extraConfig = ''
      noarp
      option rapid_commit
      option domain_name_servers, domain_name, domain_search, host_name
      option classless_static_routes
      option ntp_servers
      timeout 30
      reboot 5
    '';
    hosts = {
      "127.0.0.1" = ["localhost" "home-server.local"];
      "::1" = ["localhost" "home-server.local"];
    };
  };
  environment.systemPackages = with pkgs; [
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
    nmap
    netcat
    socat
    iperf3
    mtr
    dig
    whois
    traceroute
    sysstat
    iostat
    vmstat
    smartmontools
    lm_sensors
    podman
    podman-compose
    docker
    docker-compose
    buildah
    skopeo
    kubectl
    k9s
    helm
    zip
    unzip
    p7zip
    gzip
    bzip2
    xz
    zstd
    jq
    yq
    xmlstarlet
    restic
    borgbackup
    rclone
    rsnapshot
    gcc
    clang
    make
    cmake
    pkg-config
    postgresql
    redis
    sqlite
    nginx
    apache2
    caddy
    openssl
    letsencrypt
    certbot
    prometheus
    grafana
    fail2ban
    ufw
    iptables
    nftables
    zfs
    btrfs-progs
    e2fsprogs
    xfsprogs
    dosfstools
    pciutils
    usbutils
    dmidecode
    hdparm
    stress
    stress-ng
    sysbench
    logrotate
    rsyslog
    ansible
    terraform
    crun
    runc
    istioctl
    par2cmdline
    ffmpeg-full
    imagemagick
    python3
    python3Packages.pip
    python3Packages.requests
    python3Packages.pyyaml
    nodejs
    yarn
    go
    rustc
    cargo
  ];
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
  users = {
    mutableUsers = true;
    defaultUserShell = pkgs.bash;
    users = {
      homeserver = {
        isNormalUser = true;
        extraGroups = [
          "wheel"
          "networkmanager"
          "docker"
          "podman"
          "systemd-journal"
          "audio"
          "video"
        ];
        shell = pkgs.bash;
        description = "Home Server Administrator";
        openssh.authorizedKeys.keys = [
        ];
      };
      container-user = {
        isSystemUser = true;
        group = "containers";
        home = "/var/lib/containers";
        createHome = true;
        description = "Container service user";
      };
    };
    extraGroups = {
      containers = {gid = 3001;};
      media = {gid = 3002;};
      backup = {gid = 3003;};
    };
  };
  virtualisation = {
    podman = {
      enable = true;
      dockerCompat = true;
      defaultNetwork.settings.dns_enabled = true;
      autoPrune = {
        enable = true;
        dates = "weekly";
        flags = ["--all"];
      };
    };
    docker = {
      enable = true;
      enableOnBoot = true;
      autoPrune = {
        enable = true;
        dates = "weekly";
      };
      extraOptions = "--default-runtime=runc --log-driver=journald";
      storageDriver = "overlay2";
    };
    oci-containers = {
      backend = "podman";
    };
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
  fileSystems = {
    "/" = {
      options = ["noatime" "nodiratime" "discard"];
    };
    "/var" = lib.mkIf false {
      options = ["noatime" "nodiratime" "discard"];
    };
    "/var/lib/containers" = {
      options = ["noatime" "nodiratime" "discard" "user_xattr"];
    };
  };
  environment.variables = {
    HOME_SERVER = "1";
    SERVER_PROFILE = "home-server";
    BLEEDING_EDGE = "1";
    PODMAN_USERNS = "keep-id";
    DOCKER_BUILDKIT = "1";
    COMPOSE_DOCKER_CLI_BUILD = "1";
    EDITOR = "vim";
    PATH = lib.mkForce "$PATH:/run/current-system/sw/bin";
  };
  nix = {
    settings = {
      max-jobs = "auto";
      cores = 0;
      auto-optimise-store = true;
      min-free = 5 * 1024 * 1024 * 1024;
      max-free = 20 * 1024 * 1024 * 1024;
      sandbox = true;
      allowed-users = ["@wheel" "@users"];
      trusted-users = ["root" "@wheel"];
      experimental-features = ["nix-command" "flakes" "auto-allocate-uids"];
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
      keep-outputs = true;
      keep-derivations = true;
    };
    gc = {
      automatic = true;
      dates = "weekly";
      options = "--delete-older-than 30d";
    };
    optimise = {
      automatic = true;
      dates = ["04:00"];
    };
  };
  system = {
    stateVersion = "24.11";
    activationScripts = {
      homeServerSetup = ''
        mkdir -p /srv/data
        mkdir -p /srv/media
        mkdir -p /srv/backup
        mkdir -p /srv/containers
        mkdir -p /var/log/home-server
        chmod 755 /srv/data /srv/media /srv/containers
        chmod 750 /srv/backup /var/log/home-server
        echo "home-server" > /etc/server-type
        echo "$(date -Iseconds)" > /etc/server-build-date
        echo "bleeding-edge,containers,media,automation" > /etc/server-capabilities
        mkdir -p /etc/containers/systemd
        mkdir -p /var/lib/containers/storage
        mkdir -p /srv/media/{movies,tv,music,photos,books}
        mkdir -p /srv/data/{nextcloud,vaultwarden,paperless,homeassistant}
        chown -R homeserver:media /srv/media 2>/dev/null || true
        chown -R homeserver:containers /srv/containers 2>/dev/null || true
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
    cpuFreqGovernor = lib.mkDefault "ondemand";
  };
}
