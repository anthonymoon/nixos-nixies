{lib}: {
  # System hardening utilities
  hardenSystem = securityLevel: {
    imports = [
      (./security-levels + "/${securityLevel}.nix")
    ];
  };

  # Security feature enablement
  enableSecurityFeatures = features:
    lib.mkMerge (map
      (
        feature:
          ./security-features + "/${feature}.nix"
      )
      features);

  # Security audit configuration
  auditConfiguration = config: pkgs: {
    # Security scanning tools
    environment.systemPackages = with pkgs; [
      lynis # Security auditing
      chkrootkit # Rootkit detection
      rkhunter # Rootkit hunter
      aide # File integrity monitoring
      fail2ban # Intrusion detection
      nmap # Network discovery
      wireshark-cli # Network analysis
    ];

    # Audit service configuration
    services.auditd = {
      enable = true;
      rules = [
        # Monitor authentication events
        "-w /etc/passwd -p wa -k passwd_changes"
        "-w /etc/shadow -p wa -k shadow_changes"
        "-w /etc/group -p wa -k group_changes"
        "-w /etc/sudoers -p wa -k sudoers_changes"

        # Monitor system calls
        "-a always,exit -F arch=b64 -S execve -k exec"
        "-a always,exit -F arch=b32 -S execve -k exec"

        # Monitor network connections
        "-a always,exit -F arch=b64 -S connect -k network_connect"
        "-a always,exit -F arch=b32 -S connect -k network_connect"

        # Monitor file access
        "-w /etc/ssh/sshd_config -p wa -k ssh_config"
        "-w /etc/nixos/ -p wa -k nixos_config"

        # Monitor privilege escalation
        "-w /bin/su -p x -k priv_esc"
        "-w /usr/bin/sudo -p x -k priv_esc"
        "-w /etc/sudoers -p rwa -k priv_esc"
      ];
    };

    # Log monitoring
    services.logrotate = {
      enable = true;
      settings = {
        "/var/log/audit/audit.log" = {
          frequency = "daily";
          rotate = 30;
          compress = true;
          delaycompress = true;
          missingok = true;
          notifempty = true;
        };
      };
    };
  };

  # Network security configuration
  networkSecurity = level: {
    # Firewall configuration by security level
    networking.firewall = {
      enable = true;

      # Port configuration by security level
      allowedTCPPorts =
        if level == "basic"
        then [22]
        else if level == "standard"
        then [22 80 443]
        else [22];
      allowedUDPPorts =
        if level == "basic"
        then []
        else if level == "standard"
        then [53]
        else [];

      # Hardened level - minimal ports with logging
      logRefusedConnections = lib.mkIf (level == "hardened") true;
      logRefusedPackets = lib.mkIf (level == "hardened") true;

      # Paranoid level - custom iptables rules
      extraCommands = lib.mkIf (level == "paranoid") ''
        # Drop all by default
        iptables -P INPUT DROP
        iptables -P FORWARD DROP
        iptables -P OUTPUT DROP

        # Allow loopback
        iptables -A INPUT -i lo -j ACCEPT
        iptables -A OUTPUT -o lo -j ACCEPT

        # Allow established connections
        iptables -A INPUT -m state --state ESTABLISHED,RELATED -j ACCEPT
        iptables -A OUTPUT -m state --state ESTABLISHED,RELATED -j ACCEPT

        # Allow SSH with rate limiting
        iptables -A INPUT -p tcp --dport 22 -m state --state NEW -m limit --limit 3/min --limit-burst 3 -j ACCEPT

        # Allow outbound DNS and HTTP/HTTPS
        iptables -A OUTPUT -p udp --dport 53 -j ACCEPT
        iptables -A OUTPUT -p tcp --dport 80 -j ACCEPT
        iptables -A OUTPUT -p tcp --dport 443 -j ACCEPT

        # Log dropped packets
        iptables -A INPUT -m limit --limit 5/min -j LOG --log-prefix "iptables INPUT denied: " --log-level 7
        iptables -A FORWARD -m limit --limit 5/min -j LOG --log-prefix "iptables FORWARD denied: " --log-level 7
        iptables -A OUTPUT -m limit --limit 5/min -j LOG --log-prefix "iptables OUTPUT denied: " --log-level 7
      '';
    };

    # Additional network security
    boot.kernel.sysctl = {
      # IP forwarding
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

      # Secure redirects
      "net.ipv4.conf.all.secure_redirects" = 0;
      "net.ipv4.conf.default.secure_redirects" = 0;

      # Send redirects
      "net.ipv4.conf.all.send_redirects" = 0;
      "net.ipv4.conf.default.send_redirects" = 0;

      # ICMP ignore
      "net.ipv4.icmp_echo_ignore_broadcasts" = 1;
      "net.ipv4.icmp_ignore_bogus_error_responses" = 1;

      # TCP SYN cookies
      "net.ipv4.tcp_syncookies" = 1;

      # TCP timestamps
      "net.ipv4.tcp_timestamps" = 0;

      # TCP SACK
      "net.ipv4.tcp_sack" = 0;
      "net.ipv4.tcp_dsack" = 0;

      # TCP window scaling
      "net.ipv4.tcp_window_scaling" = 1;

      # TCP keepalive
      "net.ipv4.tcp_keepalive_time" = 600;
      "net.ipv4.tcp_keepalive_intvl" = 60;
      "net.ipv4.tcp_keepalive_probes" = 3;

      # Log suspicious packets
      "net.ipv4.conf.all.log_martians" = 1;
      "net.ipv4.conf.default.log_martians" = 1;
    };
  };

  # Kernel hardening
  kernelHardening = level: {
    boot.kernel.sysctl = lib.mkMerge [
      # Basic kernel hardening
      (lib.mkIf (lib.elem level ["basic" "standard" "hardened" "paranoid"]) {
        # Restrict kernel messages
        "kernel.dmesg_restrict" = 1;

        # Restrict kernel pointers
        "kernel.kptr_restrict" = 2;

        # Disable magic SysRq key
        "kernel.sysrq" = 0;

        # Restrict access to kernel logs
        "dev.tty.ldisc_autoload" = 0;
      })

      # Standard kernel hardening
      (lib.mkIf (lib.elem level ["standard" "hardened" "paranoid"]) {
        # Process separation
        "kernel.yama.ptrace_scope" = 1;

        # Memory protection
        "kernel.randomize_va_space" = 2;

        # BPF hardening
        "kernel.unprivileged_bpf_disabled" = 1;
        "net.core.bpf_jit_harden" = 2;

        # Performance events restrictions
        "kernel.perf_event_paranoid" = 3;
        "kernel.perf_cpu_time_max_percent" = 1;
        "kernel.perf_event_max_sample_rate" = 1;
      })

      # Hardened kernel settings
      (lib.mkIf (lib.elem level ["hardened" "paranoid"]) {
        # Advanced ptrace restrictions
        "kernel.yama.ptrace_scope" = 2;

        # Memory randomization
        "vm.mmap_rnd_bits" = 32;
        "vm.mmap_rnd_compat_bits" = 16;

        # File system protections
        "fs.protected_hardlinks" = 1;
        "fs.protected_symlinks" = 1;
        "fs.protected_fifos" = 2;
        "fs.protected_regular" = 2;

        # User namespace restrictions
        "user.max_user_namespaces" = 0;

        # Kernel module restrictions
        "kernel.modules_disabled" = 1;
      })

      # Paranoid kernel settings
      (lib.mkIf (level == "paranoid") {
        # Maximum restrictions
        "kernel.yama.ptrace_scope" = 3;

        # Disable swap
        "vm.swappiness" = 1;

        # Memory overcommit restrictions
        "vm.overcommit_memory" = 2;
        "vm.overcommit_ratio" = 50;

        # Additional memory protections
        "vm.mmap_min_addr" = 65536;

        # Kexec restrictions
        "kernel.kexec_load_disabled" = 1;
      })
    ];

    # Kernel module blacklist by security level
    boot.blacklistedKernelModules = lib.mkMerge [
      # Standard blacklist
      (lib.mkIf (lib.elem level ["standard" "hardened" "paranoid"]) [
        # Unused network protocols
        "dccp"
        "sctp"
        "rds"
        "tipc"

        # Unused filesystems
        "cramfs"
        "freevxfs"
        "jffs2"
        "hfs"
        "hfsplus"
        "squashfs"
        "udf"

        # Unused drivers
        "n-hdlc"
        "ax25"
        "netrom"
        "x25"
        "rose"
        "decnet"
        "econet"
      ])

      # Aggressive blacklist
      (lib.mkIf (lib.elem level ["hardened" "paranoid"]) [
        # Additional protocols
        "af_802154"
        "ipx"
        "appletalk"
        "psnap"
        "p8023"
        "p8022"
        "can"
        "atm"

        # Bluetooth (if not needed)
        "bluetooth"
        "btusb"
        "btrtl"
        "btbcm"
        "btintel"

        # Wireless (if not needed)
        "cfg80211"
        "mac80211"
      ])
    ];
  };

  # Application security
  applicationSecurity = pkgs: {
    # AppArmor profiles
    apparmor = {
      security.apparmor = {
        enable = true;
        killUnconfinedConfinables = true;
        packages = with pkgs; [
          apparmor-profiles
          apparmor-utils
          apparmor-bin-utils
        ];
      };
    };

    # Mandatory Access Control
    mac = level: pkgs: {
      # SELinux (alternative to AppArmor)
      selinux = lib.mkIf (level == "paranoid") {
        boot.kernelParams = ["security=selinux" "selinux=1" "enforcing=1"];
        environment.systemPackages = with pkgs; [
          policycoreutils
          selinux-python
          setools
        ];
      };
    };

    # Container security
    containerSecurity = {
      # Docker security
      virtualisation.docker = {
        rootless = {
          enable = true;
          setSocketVariable = true;
        };

        daemon.settings = {
          userland-proxy = false;
          live-restore = true;
          no-new-privileges = true;
        };
      };

      # Podman security
      virtualisation.podman = {
        enable = true;
        dockerCompat = true;
        defaultNetwork.settings.dns_enabled = true;
      };
    };
  };

  # Cryptographic security
  cryptoSecurity = {
    # Strong crypto defaults
    strongCrypto = {
      # SSH configuration
      services.openssh.settings = {
        Ciphers = [
          "aes256-gcm@openssh.com"
          "aes128-gcm@openssh.com"
          "aes256-ctr"
          "aes192-ctr"
          "aes128-ctr"
        ];

        MACs = [
          "hmac-sha2-256-etm@openssh.com"
          "hmac-sha2-512-etm@openssh.com"
          "hmac-sha2-256"
          "hmac-sha2-512"
        ];

        KexAlgorithms = [
          "curve25519-sha256@libssh.org"
          "diffie-hellman-group16-sha512"
          "diffie-hellman-group18-sha512"
          "diffie-hellman-group14-sha256"
        ];

        HostKeyAlgorithms = [
          "ssh-ed25519"
          "ssh-rsa"
        ];

        PubkeyAcceptedKeyTypes = [
          "ssh-ed25519"
          "ssh-rsa"
        ];
      };

      # TLS configuration
      security.tls = {
        cipherSuites = [
          "TLS_AES_256_GCM_SHA384"
          "TLS_CHACHA20_POLY1305_SHA256"
          "TLS_AES_128_GCM_SHA256"
        ];

        protocols = ["TLSv1.2" "TLSv1.3"];
      };
    };

    # Certificate management
    certificates = {
      # Automatic certificate management
      security.acme = {
        acceptTerms = true;
        defaults.email = "admin@example.com";
      };

      # Certificate validation
      security.pki.certificates = [
        # Add custom CA certificates here
      ];
    };
  };

  # Security monitoring
  securityMonitoring = pkgs: {
    # Intrusion detection
    ids = {
      # Fail2ban
      services.fail2ban = {
        enable = true;
        bantime = "1h";
        bantime-increment = {
          enable = true;
          maxtime = "168h";
          factor = "4";
        };
        maxretry = 3;

        jails = {
          sshd = {
            settings = {
              enabled = true;
              port = "22";
              filter = "sshd";
              logpath = "/var/log/auth.log";
              maxretry = 3;
              bantime = "1h";
            };
          };
        };
      };

      # OSSEC HIDS
      ossec = {
        enable = false; # Enable if needed
        # Configuration would go here
      };
    };

    # Log analysis
    logAnalysis = {
      # Centralized logging
      services.journald.settings = {
        Storage = "persistent";
        Compress = true;
        SystemMaxUse = "500M";
        SystemMaxFileSize = "50M";
        SystemKeepFree = "1G";
        SystemMaxFiles = 100;
      };

      # Log monitoring tools
      environment.systemPackages = with pkgs; [
        logwatch
        goaccess
        multitail
      ];
    };
  };
}
