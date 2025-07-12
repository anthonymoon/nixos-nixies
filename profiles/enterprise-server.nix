{
  config,
  lib,
  pkgs,
  ...
}: {
  meta = {
    name = "enterprise-server";
    description = "Enterprise-grade server profile with hardened security, stable packages, and compliance features";
    maintainers = ["nixos-unified"];
    tags = ["enterprise" "server" "security" "compliance" "stable"];
  };

  imports = [
    ./base.nix
  ];

  # Enterprise unified configuration
  unified = {
    # Core enterprise settings
    core = {
      enable = true;
      security.level = "paranoid"; # Maximum security for enterprise
      performance.enable = true;
      stability.channel = "stable"; # Use only stable packages
    };

    # Enterprise hardware optimization
    hardware = {
      enable = true;
      server = true;
      enterprise = true;
      performance.cpu.governor = "performance";
    };

    # Enterprise networking
    networking = {
      enable = true;
      firewall = {
        enable = true;
        strict = true;
        enterprise = true;
      };
      security = {
        fail2ban = true;
        intrusion-detection = true;
      };
    };

    # Enterprise monitoring
    monitoring = {
      enable = true;
      prometheus = true;
      grafana = true;
      alertmanager = true;
      enterprise-grade = true;
    };

    # Compliance and auditing
    compliance = {
      enable = true;
      frameworks = ["SOC2" "CIS" "NIST"];
      audit-logging = true;
      immutable-logs = true;
    };
  };

  # Use stable nixpkgs for enterprise reliability
  nixpkgs = {
    config = {
      allowUnfree = false; # Restrict to open source for compliance
      permittedInsecurePackages = []; # No insecure packages allowed
    };
  };

  # Enterprise boot configuration
  boot = {
    # Hardened kernel for enterprise security
    kernelPackages = pkgs.linuxPackages_hardened;

    # Security-focused kernel parameters
    kernelParams = [
      # Memory protection
      "slub_debug=P"
      "page_poison=1"
      "slab_nomerge"
      "init_on_alloc=1"
      "init_on_free=1"

      # CPU security mitigations (keep enabled for enterprise)
      "mitigations=auto"
      "spectre_v2=on"
      "spec_store_bypass_disable=on"
      "l1tf=full,force"
      "mds=full,nosmt"

      # Disable debugging interfaces in production
      "debugfs=off"
      "sysrq_always_enabled=0"

      # Network security
      "ipv6.disable=1" # Disable IPv6 if not used

      # Audit system
      "audit=1"
      "audit_backlog_limit=8192"

      # Kernel lockdown
      "lockdown=confidentiality"

      # IOMMU for hardware isolation
      "intel_iommu=on"
      "amd_iommu=on"
    ];

    # Secure boot loader configuration
    loader = {
      # Use systemd-boot with timeout
      systemd-boot = {
        enable = true;
        editor = false; # Disable boot parameter editing
        configurationLimit = 5; # Limit stored generations
      };
      timeout = 3;
    };

    # Kernel modules blacklist for security
    blacklistedKernelModules = [
      # Disable unused filesystems
      "cramfs"
      "freevxfs"
      "jffs2"
      "hfs"
      "hfsplus"
      "squashfs"
      "udf"

      # Disable rare network protocols
      "dccp"
      "sctp"
      "rds"
      "tipc"

      # Disable unused hardware
      "usb-storage"
      "firewire-core"
      "thunderbolt"
    ];

    # Enable kernel module signing
    kernelModules = [];
    extraModulePackages = [];

    # Secure tmp
    tmp = {
      useTmpfs = true;
      tmpfsSize = "2G";
      cleanOnBoot = true;
    };
  };

  # Enterprise hardware configuration
  hardware = {
    # CPU microcode updates for security
    cpu = {
      intel.updateMicrocode = true;
      amd.updateMicrocode = true;
    };

    # Enable firmware updates
    enableRedistributableFirmware = true;

    # Disable Bluetooth for servers
    bluetooth.enable = false;

    # Audio not needed for servers
    pulseaudio.enable = false;
  };

  # Enterprise security configuration
  security = {
    # Advanced access controls
    sudo = {
      enable = true;
      wheelNeedsPassword = true;
      execWheelOnly = true;
      extraConfig = ''
        # Require password for all commands
        Defaults timestamp_timeout=0
        Defaults !visiblepw
        Defaults always_set_home
        Defaults match_group_by_gid
        Defaults always_query_group_plugin
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
        Defaults!/usr/bin/sudoreplay !log_input, !log_output
      '';
    };

    # Enable AppArmor mandatory access control
    apparmor = {
      enable = true;
      killUnconfinedConfinables = true;
    };

    # Audit system
    auditd.enable = true;
    audit = {
      enable = true;
      rules = [
        # Monitor privileged commands
        "-a always,exit -F arch=b64 -S execve -C uid!=euid -F euid=0 -k setuid"
        "-a always,exit -F arch=b64 -S execve -C gid!=egid -F egid=0 -k setgid"

        # Monitor system calls
        "-a always,exit -F arch=b64 -S adjtimex -S settimeofday -k time-change"
        "-a always,exit -F arch=b64 -S clock_settime -k time-change"
        "-w /etc/localtime -p wa -k time-change"

        # Monitor authentication
        "-w /etc/passwd -p wa -k identity"
        "-w /etc/group -p wa -k identity"
        "-w /etc/gshadow -p wa -k identity"
        "-w /etc/shadow -p wa -k identity"
        "-w /etc/security/opasswd -p wa -k identity"

        # Monitor network configuration
        "-a always,exit -F arch=b64 -S sethostname -S setdomainname -k system-locale"
        "-w /etc/issue -p wa -k system-locale"
        "-w /etc/issue.net -p wa -k system-locale"
        "-w /etc/hosts -p wa -k system-locale"
        "-w /etc/sysconfig/network -p wa -k system-locale"

        # Monitor file access
        "-a always,exit -F arch=b64 -S chmod -S fchmod -S fchmodat -F auid>=1000 -F auid!=4294967295 -k perm_mod"
        "-a always,exit -F arch=b64 -S chown -S fchown -S fchownat -S lchown -F auid>=1000 -F auid!=4294967295 -k perm_mod"

        # Monitor privileged files
        "-w /etc/sudoers -p wa -k scope"
        "-w /etc/sudoers.d/ -p wa -k scope"

        # Monitor kernel modules
        "-w /sbin/insmod -p x -k modules"
        "-w /sbin/rmmod -p x -k modules"
        "-w /sbin/modprobe -p x -k modules"
        "-a always,exit -F arch=b64 -S init_module -S delete_module -k modules"

        # Monitor file system mounts
        "-a always,exit -F arch=b64 -S mount -F auid>=1000 -F auid!=4294967295 -k mounts"

        # Monitor file deletions
        "-a always,exit -F arch=b64 -S unlink -S unlinkat -S rename -S renameat -F auid>=1000 -F auid!=4294967295 -k delete"
      ];
    };

    # PAM configuration for enterprise security
    pam = {
      enableSSHAgentAuth = false; # Disable for security
      services = {
        login.failDelay = 4000000; # 4 second delay on failed login
        su.requireWheel = true;
      };
    };

    # Disable unprivileged user namespaces
    unprivilegedUsernsClone = false;

    # Kernel lockdown
    lockKernelLogs = true;
    forcePageTableIsolation = true;

    # Virtualization security
    virtualisation = {
      flushL1DataCache = "always";
    };

    # Disable KRNG
    rngd.enable = false;

    # Polkit restrictions
    polkit = {
      enable = true;
      extraConfig = ''
        /* Disable shutdown/reboot for non-root users */
        polkit.addRule(function(action, subject) {
            if (action.id == "org.freedesktop.systemd1.manage-unit-files" ||
                action.id == "org.freedesktop.systemd1.reload-daemon" ||
                action.id == "org.freedesktop.systemd1.manage-units") {
                return polkit.Result.AUTH_ADMIN;
            }
        });
      '';
    };
  };

  # Enterprise networking configuration
  networking = {
    # Secure firewall configuration
    firewall = {
      enable = true;

      # Default deny policy
      allowedTCPPorts = [22]; # Only SSH by default
      allowedUDPPorts = [];

      # Log dropped packets
      logRefusedConnections = true;
      logRefusedPackets = true;
      logRefusedUnicastsOnly = false;

      # Rate limiting
      pingLimit = "--limit 1/minute --limit-burst 1";

      # Extra rules for enterprise security
      extraCommands = ''
        # Drop invalid packets
        iptables -A INPUT -m conntrack --ctstate INVALID -j DROP

        # Rate limit SSH connections
        iptables -A INPUT -p tcp --dport 22 -m conntrack --ctstate NEW -m recent --set
        iptables -A INPUT -p tcp --dport 22 -m conntrack --ctstate NEW -m recent --update --seconds 60 --hitcount 4 -j DROP

        # Log suspicious activity
        iptables -A INPUT -m recent --name portscan --set -j LOG --log-prefix "Portscan detected: "

        # Drop broadcast traffic
        iptables -A INPUT -m pkttype --pkt-type broadcast -j DROP
        iptables -A INPUT -m pkttype --pkt-type multicast -j DROP

        # Prevent SYN flooding
        iptables -A INPUT -p tcp --syn -m limit --limit 1/s --limit-burst 3 -j RETURN
        iptables -A INPUT -p tcp --syn -j DROP
      '';
    };

    # Network hardening
    enableIPv6 = false; # Disable IPv6 unless required
    useDHCP = false; # Use static configuration for servers

    # DNS configuration
    nameservers = ["1.1.1.1" "1.0.0.1"]; # Cloudflare DNS

    # Network security parameters
    kernel.sysctl = {
      # IP forwarding (disable for non-routers)
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

      # Ignore ping requests
      "net.ipv4.icmp_echo_ignore_all" = 1;
      "net.ipv6.icmp_echo_ignore_all" = 1;

      # TCP hardening
      "net.ipv4.tcp_syncookies" = 1;
      "net.ipv4.tcp_rfc1337" = 1;
      "net.ipv4.tcp_timestamps" = 0;
      "net.ipv4.tcp_sack" = 0;
      "net.ipv4.tcp_dsack" = 0;
      "net.ipv4.tcp_fack" = 0;

      # Memory constraints
      "net.core.rmem_max" = 8388608;
      "net.core.wmem_max" = 8388608;
      "net.core.netdev_max_backlog" = 5000;

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
      "vm.unprivileged_userfaultfd" = 0;
    };
  };

  # Enterprise services configuration
  services = {
    # SSH hardening
    openssh = {
      enable = true;
      ports = [22];
      settings = {
        # Authentication
        PermitRootLogin = "no";
        PasswordAuthentication = false;
        PubkeyAuthentication = true;
        AuthenticationMethods = "publickey";

        # Security settings
        Protocol = 2;
        X11Forwarding = false;
        AllowAgentForwarding = false;
        AllowTcpForwarding = false;
        GatewayPorts = "no";
        PermitTunnel = "no";

        # Connection settings
        ClientAliveInterval = 300;
        ClientAliveCountMax = 2;
        LoginGraceTime = 60;
        MaxAuthTries = 3;
        MaxSessions = 2;
        MaxStartups = "10:30:60";

        # Cryptography
        Ciphers = ["aes256-gcm@openssh.com" "aes128-gcm@openssh.com" "aes256-ctr" "aes192-ctr" "aes128-ctr"];
        MACs = ["hmac-sha2-256-etm@openssh.com" "hmac-sha2-512-etm@openssh.com" "hmac-sha2-256" "hmac-sha2-512"];
        KexAlgorithms = ["curve25519-sha256@libssh.org" "ecdh-sha2-nistp521" "ecdh-sha2-nistp384" "ecdh-sha2-nistp256" "diffie-hellman-group-exchange-sha256"];

        # Logging
        LogLevel = "VERBOSE";
        SyslogFacility = "AUTHPRIV";

        # Disable unused features
        UsePAM = true;
        PermitUserEnvironment = false;
        Compression = false;
        UseDNS = false;

        # Banner
        Banner = "/etc/ssh/banner";
      };

      # Host keys
      hostKeys = [
        {
          path = "/etc/ssh/ssh_host_rsa_key";
          type = "rsa";
          bits = 4096;
        }
        {
          path = "/etc/ssh/ssh_host_ed25519_key";
          type = "ed25519";
        }
      ];
    };

    # Fail2ban for intrusion prevention
    fail2ban = {
      enable = true;
      bantime = "1h";
      bantime-increment = {
        enable = true;
        maxtime = "168h"; # 1 week
        factor = "2";
      };
      maxretry = 3;

      jails = {
        # SSH protection
        sshd = {
          settings = {
            enabled = true;
            port = "ssh";
            filter = "sshd";
            logpath = "/var/log/auth.log";
            maxretry = 3;
            findtime = 600;
            bantime = 3600;
          };
        };

        # Nginx protection (if enabled)
        nginx-http-auth = {
          settings = {
            enabled = false;
            port = "http,https";
            filter = "nginx-http-auth";
            logpath = "/var/log/nginx/error.log";
            maxretry = 3;
          };
        };
      };
    };

    # System logging
    journald.settings = {
      # Persistent logging
      Storage = "persistent";

      # Log retention
      SystemMaxUse = "1G";
      SystemKeepFree = "2G";
      SystemMaxFileSize = "100M";
      SystemMaxFiles = 100;

      # Runtime logging
      RuntimeMaxUse = "100M";
      RuntimeKeepFree = "500M";
      RuntimeMaxFileSize = "10M";
      RuntimeMaxFiles = 10;

      # Security
      Compress = true;
      Seal = true;
      SplitMode = "uid";

      # Rate limiting
      RateLimitInterval = "1s";
      RateLimitBurst = 1000;

      # Forwarding
      ForwardToSyslog = false;
      ForwardToKMsg = false;
      ForwardToConsole = false;
      ForwardToWall = true;
    };

    # Time synchronization
    timesyncd = {
      enable = true;
      servers = [
        "time.cloudflare.com"
        "time.google.com"
        "pool.ntp.org"
      ];
    };

    # Disable unnecessary services for servers
    avahi.enable = false;
    printing.enable = false;
    blueman.enable = false;

    # File integrity monitoring
    aide = {
      enable = true;
      config = ''
        # Database location
        database=file:/var/lib/aide/aide.db
        database_out=file:/var/lib/aide/aide.db.new

        # Report settings
        verbose=5
        report_level=changed_attributes

        # Rules
        Rule = p+i+n+u+g+s+b+m+c+md5+sha1+sha256+sha512+rmd160+tiger+haval+gost+crc32

        # Directories to monitor
        /boot Rule
        /bin Rule
        /sbin Rule
        /lib Rule
        /lib64 Rule
        /opt Rule
        /usr Rule
        /etc Rule

        # Exclude temporary and variable directories
        !/var/log
        !/var/spool
        !/var/cache
        !/tmp
        !/proc
        !/sys
        !/dev
      '';
    };
  };

  # File system configuration
  fileSystems = {
    "/" = {
      options = [
        "noatime"
        "nodiratime"
        "nodev"
        "nosuid"
      ];
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
        "size=2G"
      ];
    };

    "/var/tmp" = {
      device = "tmpfs";
      fsType = "tmpfs";
      options = [
        "defaults"
        "noatime"
        "nosuid"
        "nodev"
        "noexec"
        "mode=1777"
        "size=1G"
      ];
    };
  };

  # User configuration
  users = {
    # Disable mutable users for enterprise
    mutableUsers = false;

    # Default shell
    defaultUserShell = pkgs.bash;

    # Enterprise admin user (configure with real credentials)
    users = {
      enterprise-admin = {
        isNormalUser = true;
        extraGroups = ["wheel"];
        # Use proper SSH keys in production
        openssh.authorizedKeys.keys = [
          # Add your SSH public keys here
        ];
        hashedPassword = "!"; # Disable password login
        description = "Enterprise Administrator";
      };
    };

    # Disable guest account
    extraUsers = {};

    # Password policy (if passwords are used)
    extraGroups = {
      audit = {gid = 500;};
    };
  };

  # Essential enterprise packages
  environment.systemPackages = with pkgs; [
    # System administration
    htop
    iotop
    nethogs
    tcpdump
    wireshark-cli
    nmap

    # Security tools
    aide
    rkhunter
    chkrootkit
    lynis

    # Network tools
    curl
    wget
    rsync
    openssh

    # Text editors
    vim
    nano

    # System utilities
    tree
    file
    which
    lsof
    strace

    # Archive tools
    gzip
    bzip2
    xz
    tar

    # Development tools (minimal)
    git

    # Compliance tools
    openscap
  ];

  # Enterprise environment variables
  environment.variables = {
    ENTERPRISE_MODE = "1";
    COMPLIANCE_LEVEL = "SOC2";
    SECURITY_LEVEL = "PARANOID";
  };

  # Programs configuration
  programs = {
    # Enable bash completion
    bash = {
      enableCompletion = true;
      shellInit = ''
        # Security-focused shell configuration
        set +h
        umask 027

        # History settings
        export HISTSIZE=1000
        export HISTFILESIZE=2000
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
      '';
    };

    # Disable automatic package installation
    command-not-found.enable = false;

    # Essential programs only
    less.enable = true;

    # Git configuration
    git = {
      enable = true;
      config = {
        user.name = lib.mkDefault "Enterprise Admin";
        user.email = lib.mkDefault "admin@enterprise.local";
        init.defaultBranch = "main";
        core.autocrlf = false;
        pull.rebase = true;
      };
    };
  };

  # Nix configuration for enterprise
  nix = {
    settings = {
      # Build settings
      max-jobs = 4;
      cores = 0; # Use all available cores

      # Storage optimization
      auto-optimise-store = true;
      min-free = 5 * 1024 * 1024 * 1024; # 5GB
      max-free = 10 * 1024 * 1024 * 1024; # 10GB

      # Security settings
      sandbox = true;
      allowed-users = ["@wheel"];
      trusted-users = ["root"];

      # Disable experimental features for stability
      experimental-features = [];

      # Use only trusted substituters
      substituters = [
        "https://cache.nixos.org"
      ];
      trusted-public-keys = [
        "cache.nixos.org-1:6NCHdD59X431o0gWypbMrAURkbJ16ZPMQFGspcDShjY="
      ];
    };

    # Aggressive garbage collection for servers
    gc = {
      automatic = true;
      dates = "daily";
      options = "--delete-older-than 7d";
    };

    # Optimize store weekly
    optimise = {
      automatic = true;
      dates = ["03:00"];
    };
  };

  # System configuration
  system = {
    stateVersion = "24.11";

    # Activation scripts for enterprise setup
    activationScripts = {
      enterpriseSetup = ''
        # Create enterprise directories
        mkdir -p /var/log/enterprise
        mkdir -p /etc/enterprise/compliance
        mkdir -p /var/lib/enterprise

        # Set proper permissions
        chmod 750 /var/log/enterprise
        chmod 750 /etc/enterprise
        chmod 750 /var/lib/enterprise

        # Create SSH banner
        cat > /etc/ssh/banner << 'EOF'
        ################################################################################
        #                              ENTERPRISE SERVER                              #
        #                                                                              #
        #  This system is for authorized users only. All activities are monitored     #
        #  and logged. Unauthorized access is prohibited and will be prosecuted       #
        #  to the full extent of the law.                                             #
        #                                                                              #
        #  By accessing this system, you acknowledge and consent to monitoring.       #
        ################################################################################
        EOF
        chmod 644 /etc/ssh/banner

        # Initialize AIDE database if not exists
        if [ ! -f /var/lib/aide/aide.db ]; then
          ${pkgs.aide}/bin/aide --init || true
          if [ -f /var/lib/aide/aide.db.new ]; then
            mv /var/lib/aide/aide.db.new /var/lib/aide/aide.db
          fi
        fi
      '';
    };
  };

  # Documentation
  documentation = {
    enable = true;
    nixos.enable = true;
    man.enable = true;
    info.enable = false; # Reduce attack surface
  };

  # Locale configuration
  time.timeZone = lib.mkDefault "UTC";
  i18n = {
    defaultLocale = "en_US.UTF-8";
    extraLocaleSettings = {
      LC_ALL = "en_US.UTF-8";
    };
  };

  # Console configuration
  console = {
    font = "Lat2-Terminus16";
    keyMap = "us";
    useXkbConfig = false;
  };

  # Disable GUI components for servers
  services.xserver.enable = false;
  services.displayManager.enable = false;
  services.desktopManager.enable = false;

  # Power management for servers
  powerManagement = {
    enable = true;
    cpuFreqGovernor = "performance";
  };
}
