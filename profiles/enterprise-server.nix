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
      security.level = "paranoid";
      performance.enable = true;
      stability.channel = "stable";
    };
    hardware = {
      enable = true;
      server = true;
      enterprise = true;
      performance.cpu.governor = "performance";
    };
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
    monitoring = {
      enable = true;
      prometheus = true;
      grafana = true;
      alertmanager = true;
      enterprise-grade = true;
    };
    compliance = {
      enable = true;
      frameworks = ["SOC2" "CIS" "NIST"];
      audit-logging = true;
      immutable-logs = true;
    };
  };
  nixpkgs = {
    config = {
      allowUnfree = false;
      permittedInsecurePackages = [];
    };
  };
  boot = {
    kernelPackages = pkgs.linuxPackages_hardened;
    kernelParams = [
      "slub_debug=P"
      "page_poison=1"
      "slab_nomerge"
      "init_on_alloc=1"
      "init_on_free=1"
      "mitigations=auto"
      "spectre_v2=on"
      "spec_store_bypass_disable=on"
      "l1tf=full,force"
      "mds=full,nosmt"
      "debugfs=off"
      "sysrq_always_enabled=0"
      "ipv6.disable=1"
      "audit=1"
      "audit_backlog_limit=8192"
      "lockdown=confidentiality"
      "intel_iommu=on"
      "amd_iommu=on"
    ];
    loader = {
      systemd-boot = {
        enable = true;
        editor = false;
        configurationLimit = 5;
      };
      timeout = 3;
    };
    blacklistedKernelModules = [
      "cramfs"
      "freevxfs"
      "jffs2"
      "hfs"
      "hfsplus"
      "squashfs"
      "udf"
      "dccp"
      "sctp"
      "rds"
      "tipc"
      "usb-storage"
      "firewire-core"
      "thunderbolt"
    ];
    kernelModules = [];
    extraModulePackages = [];
    tmp = {
      useTmpfs = true;
      tmpfsSize = "2G";
      cleanOnBoot = true;
    };
  };
  hardware = {
    cpu = {
      intel.updateMicrocode = true;
      amd.updateMicrocode = true;
    };
    enableRedistributableFirmware = true;
    bluetooth.enable = false;
    pulseaudio.enable = false;
  };
  security = {
    sudo = {
      enable = true;
      wheelNeedsPassword = true;
      execWheelOnly = true;
      extraConfig = ''
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
    apparmor = {
      enable = true;
      killUnconfinedConfinables = true;
    };
    auditd.enable = true;
    audit = {
      enable = true;
      rules = [
        "-a always,exit -F arch=b64 -S execve -C uid!=euid -F euid=0 -k setuid"
        "-a always,exit -F arch=b64 -S execve -C gid!=egid -F egid=0 -k setgid"
        "-a always,exit -F arch=b64 -S adjtimex -S settimeofday -k time-change"
        "-a always,exit -F arch=b64 -S clock_settime -k time-change"
        "-w /etc/localtime -p wa -k time-change"
        "-w /etc/passwd -p wa -k identity"
        "-w /etc/group -p wa -k identity"
        "-w /etc/gshadow -p wa -k identity"
        "-w /etc/shadow -p wa -k identity"
        "-w /etc/security/opasswd -p wa -k identity"
        "-a always,exit -F arch=b64 -S sethostname -S setdomainname -k system-locale"
        "-w /etc/issue -p wa -k system-locale"
        "-w /etc/issue.net -p wa -k system-locale"
        "-w /etc/hosts -p wa -k system-locale"
        "-w /etc/sysconfig/network -p wa -k system-locale"
        "-a always,exit -F arch=b64 -S chmod -S fchmod -S fchmodat -F auid>=1000 -F auid!=4294967295 -k perm_mod"
        "-a always,exit -F arch=b64 -S chown -S fchown -S fchownat -S lchown -F auid>=1000 -F auid!=4294967295 -k perm_mod"
        "-w /etc/sudoers -p wa -k scope"
        "-w /etc/sudoers.d/ -p wa -k scope"
        "-w /sbin/insmod -p x -k modules"
        "-w /sbin/rmmod -p x -k modules"
        "-w /sbin/modprobe -p x -k modules"
        "-a always,exit -F arch=b64 -S init_module -S delete_module -k modules"
        "-a always,exit -F arch=b64 -S mount -F auid>=1000 -F auid!=4294967295 -k mounts"
        "-a always,exit -F arch=b64 -S unlink -S unlinkat -S rename -S renameat -F auid>=1000 -F auid!=4294967295 -k delete"
      ];
    };
    pam = {
      enableSSHAgentAuth = false;
      services = {
        login.failDelay = 4000000;
        su.requireWheel = true;
      };
    };
    unprivilegedUsernsClone = false;
    lockKernelLogs = true;
    forcePageTableIsolation = true;
    virtualisation = {
      flushL1DataCache = "always";
    };
    rngd.enable = false;
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
  networking = {
    firewall = {
      enable = true;
      allowedTCPPorts = [22];
      allowedUDPPorts = [];
      logRefusedConnections = true;
      logRefusedPackets = true;
      logRefusedUnicastsOnly = false;
      pingLimit = "--limit 1/minute --limit-burst 1";
      extraCommands = ''
        iptables -A INPUT -m conntrack --ctstate INVALID -j DROP
        iptables -A INPUT -p tcp --dport 22 -m conntrack --ctstate NEW -m recent --set
        iptables -A INPUT -p tcp --dport 22 -m conntrack --ctstate NEW -m recent --update --seconds 60 --hitcount 4 -j DROP
        iptables -A INPUT -m recent --name portscan --set -j LOG --log-prefix "Portscan detected: "
        iptables -A INPUT -m pkttype --pkt-type broadcast -j DROP
        iptables -A INPUT -m pkttype --pkt-type multicast -j DROP
        iptables -A INPUT -p tcp --syn -m limit --limit 1/s --limit-burst 3 -j RETURN
        iptables -A INPUT -p tcp --syn -j DROP
      '';
    };
    enableIPv6 = false;
    useDHCP = false;
    nameservers = ["1.1.1.1" "1.0.0.1"];
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
      "net.ipv4.icmp_echo_ignore_all" = 1;
      "net.ipv6.icmp_echo_ignore_all" = 1;
      "net.ipv4.tcp_syncookies" = 1;
      "net.ipv4.tcp_rfc1337" = 1;
      "net.ipv4.tcp_timestamps" = 0;
      "net.ipv4.tcp_sack" = 0;
      "net.ipv4.tcp_dsack" = 0;
      "net.ipv4.tcp_fack" = 0;
      "net.core.rmem_max" = 8388608;
      "net.core.wmem_max" = 8388608;
      "net.core.netdev_max_backlog" = 5000;
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
      "vm.unprivileged_userfaultfd" = 0;
    };
  };
  services = {
    openssh = {
      enable = true;
      ports = [22];
      settings = {
        PermitRootLogin = "no";
        PasswordAuthentication = false;
        PubkeyAuthentication = true;
        AuthenticationMethods = "publickey";
        Protocol = 2;
        X11Forwarding = false;
        AllowAgentForwarding = false;
        AllowTcpForwarding = false;
        GatewayPorts = "no";
        PermitTunnel = "no";
        ClientAliveInterval = 300;
        ClientAliveCountMax = 2;
        LoginGraceTime = 60;
        MaxAuthTries = 3;
        MaxSessions = 2;
        MaxStartups = "10:30:60";
        Ciphers = ["aes256-gcm@openssh.com" "aes128-gcm@openssh.com" "aes256-ctr" "aes192-ctr" "aes128-ctr"];
        MACs = ["hmac-sha2-256-etm@openssh.com" "hmac-sha2-512-etm@openssh.com" "hmac-sha2-256" "hmac-sha2-512"];
        KexAlgorithms = ["curve25519-sha256@libssh.org" "ecdh-sha2-nistp521" "ecdh-sha2-nistp384" "ecdh-sha2-nistp256" "diffie-hellman-group-exchange-sha256"];
        LogLevel = "VERBOSE";
        SyslogFacility = "AUTHPRIV";
        UsePAM = true;
        PermitUserEnvironment = false;
        Compression = false;
        UseDNS = false;
        Banner = "/etc/ssh/banner";
      };
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
    fail2ban = {
      enable = true;
      bantime = "1h";
      bantime-increment = {
        enable = true;
        maxtime = "168h";
        factor = "2";
      };
      maxretry = 3;
      jails = {
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
    journald.settings = {
      Storage = "persistent";
      SystemMaxUse = "1G";
      SystemKeepFree = "2G";
      SystemMaxFileSize = "100M";
      SystemMaxFiles = 100;
      RuntimeMaxUse = "100M";
      RuntimeKeepFree = "500M";
      RuntimeMaxFileSize = "10M";
      RuntimeMaxFiles = 10;
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
    timesyncd = {
      enable = true;
      servers = [
        "time.cloudflare.com"
        "time.google.com"
        "pool.ntp.org"
      ];
    };
    avahi.enable = false;
    printing.enable = false;
    blueman.enable = false;
    aide = {
      enable = true;
      config = ''
        database=file:/var/lib/aide/aide.db
        database_out=file:/var/lib/aide/aide.db.new
        verbose=5
        report_level=changed_attributes
        Rule = p+i+n+u+g+s+b+m+c+md5+sha1+sha256+sha512+rmd160+tiger+haval+gost+crc32
        /boot Rule
        /bin Rule
        /sbin Rule
        /lib Rule
        /lib64 Rule
        /opt Rule
        /usr Rule
        /etc Rule
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
  users = {
    mutableUsers = false;
    defaultUserShell = pkgs.bash;
    users = {
      enterprise-admin = {
        isNormalUser = true;
        extraGroups = ["wheel"];
        openssh.authorizedKeys.keys = [
        ];
        hashedPassword = "!";
        description = "Enterprise Administrator";
      };
    };
    extraUsers = {};
    extraGroups = {
      audit = {gid = 500;};
    };
  };
  environment.systemPackages = with pkgs; [
    htop
    iotop
    nethogs
    tcpdump
    wireshark-cli
    nmap
    aide
    rkhunter
    chkrootkit
    lynis
    curl
    wget
    rsync
    openssh
    vim
    nano
    tree
    file
    which
    lsof
    strace
    gzip
    bzip2
    xz
    tar
    git
    openscap
  ];
  environment.variables = {
    ENTERPRISE_MODE = "1";
    COMPLIANCE_LEVEL = "SOC2";
    SECURITY_LEVEL = "PARANOID";
  };
  programs = {
    bash = {
      completion.enable = true;
      shellInit = ''
        set +h
        umask 027
        export HISTSIZE=1000
        export HISTFILESIZE=2000
        export HISTCONTROL=ignoreboth:erasedups
        export HISTTIMEFORMAT='%F %T '
        alias rm='rm -i'
        alias cp='cp -i'
        alias mv='mv -i'
        alias ll='ls -la'
        alias la='ls -A'
        alias l='ls -CF'
        alias grep='grep --color=auto'
      '';
    };
    command-not-found.enable = false;
    less.enable = true;
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
  nix = {
    settings = {
      max-jobs = 4;
      cores = 0;
      auto-optimise-store = true;
      min-free = 5 * 1024 * 1024 * 1024;
      max-free = 10 * 1024 * 1024 * 1024;
      sandbox = true;
      allowed-users = ["@wheel"];
      trusted-users = ["root"];
      experimental-features = [];
      substituters = [
        "https://cache.nixos.org"
      ];
      trusted-public-keys = [
        "cache.nixos.org-1:6NCHdD59X431o0gWypbMrAURkbJ16ZPMQFGspcDShjY="
      ];
    };
    gc = {
      automatic = true;
      dates = "daily";
      options = "--delete-older-than 7d";
    };
    optimise = {
      automatic = true;
      dates = ["03:00"];
    };
  };
  system = {
    stateVersion = "24.11";
    activationScripts = {
      enterpriseSetup = ''
        mkdir -p /var/log/enterprise
        mkdir -p /etc/enterprise/compliance
        mkdir -p /var/lib/enterprise
        chmod 750 /var/log/enterprise
        chmod 750 /etc/enterprise
        chmod 750 /var/lib/enterprise
        cat > /etc/ssh/banner << 'EOF'
        EOF
        chmod 644 /etc/ssh/banner
        if [ ! -f /var/lib/aide/aide.db ]; then
        ${pkgs.aide}/bin/aide --init || true
        if [ -f /var/lib/aide/aide.db.new ]; then
        mv /var/lib/aide/aide.db.new /var/lib/aide/aide.db
        fi
        fi
      '';
    };
  };
  documentation = {
    enable = true;
    nixos.enable = true;
    man.enable = true;
    info.enable = false;
  };
  time.timeZone = lib.mkDefault "UTC";
  i18n = {
    defaultLocale = "en_US.UTF-8";
    extraLocaleSettings = {
      LC_ALL = "en_US.UTF-8";
    };
  };
  console = {
    font = "Lat2-Terminus16";
    keyMap = "us";
    useXkbConfig = false;
  };
  services.xserver.enable = false;
  services.displayManager.enable = false;
  services.desktopManager.enable = false;
  powerManagement = {
    enable = true;
    cpuFreqGovernor = "performance";
  };
}
