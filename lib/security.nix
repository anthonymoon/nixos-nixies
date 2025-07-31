{lib}: {
  hardenSystem = securityLevel: {
    imports = [
      (./security-levels + "/${securityLevel}.nix")
    ];
  };
  enableSecurityFeatures = features:
    lib.mkMerge (map
      (
        feature:
          ./security-features + "/${feature}.nix"
      )
      features);
  auditConfiguration = config: pkgs: {
    environment.systemPackages = with pkgs; [
      lynis
      chkrootkit
      rkhunter
      aide
      fail2ban
      nmap
      wireshark-cli
    ];
    services.auditd = {
      enable = true;
      rules = [
        "-w /etc/passwd -p wa -k passwd_changes"
        "-w /etc/shadow -p wa -k shadow_changes"
        "-w /etc/group -p wa -k group_changes"
        "-w /etc/sudoers -p wa -k sudoers_changes"
        "-a always,exit -F arch=b64 -S execve -k exec"
        "-a always,exit -F arch=b32 -S execve -k exec"
        "-a always,exit -F arch=b64 -S connect -k network_connect"
        "-a always,exit -F arch=b32 -S connect -k network_connect"
        "-w /etc/ssh/sshd_config -p wa -k ssh_config"
        "-w /etc/nixos/ -p wa -k nixos_config"
        "-w /bin/su -p x -k priv_esc"
        "-w /usr/bin/sudo -p x -k priv_esc"
        "-w /etc/sudoers -p rwa -k priv_esc"
      ];
    };
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
  networkSecurity = level: {
    networking.firewall = {
      enable = true;
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
      logRefusedConnections = lib.mkIf (level == "hardened") true;
      logRefusedPackets = lib.mkIf (level == "hardened") true;
      extraCommands = lib.mkIf (level == "paranoid") ''
        iptables -P INPUT DROP
        iptables -P FORWARD DROP
        iptables -P OUTPUT DROP
        iptables -A INPUT -i lo -j ACCEPT
        iptables -A OUTPUT -o lo -j ACCEPT
        iptables -A INPUT -m state --state ESTABLISHED,RELATED -j ACCEPT
        iptables -A OUTPUT -m state --state ESTABLISHED,RELATED -j ACCEPT
        iptables -A INPUT -p tcp --dport 22 -m state --state NEW -m limit --limit 3/min --limit-burst 3 -j ACCEPT
        iptables -A OUTPUT -p udp --dport 53 -j ACCEPT
        iptables -A OUTPUT -p tcp --dport 80 -j ACCEPT
        iptables -A OUTPUT -p tcp --dport 443 -j ACCEPT
        iptables -A INPUT -m limit --limit 5/min -j LOG --log-prefix "iptables INPUT denied: " --log-level 7
        iptables -A FORWARD -m limit --limit 5/min -j LOG --log-prefix "iptables FORWARD denied: " --log-level 7
        iptables -A OUTPUT -m limit --limit 5/min -j LOG --log-prefix "iptables OUTPUT denied: " --log-level 7
      '';
    };
    boot.kernel.sysctl = {
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
      "net.ipv4.icmp_echo_ignore_broadcasts" = 1;
      "net.ipv4.icmp_ignore_bogus_error_responses" = 1;
      "net.ipv4.tcp_syncookies" = 1;
      "net.ipv4.tcp_timestamps" = 0;
      "net.ipv4.tcp_sack" = 0;
      "net.ipv4.tcp_dsack" = 0;
      "net.ipv4.tcp_window_scaling" = 1;
      "net.ipv4.tcp_keepalive_time" = 600;
      "net.ipv4.tcp_keepalive_intvl" = 60;
      "net.ipv4.tcp_keepalive_probes" = 3;
      "net.ipv4.conf.all.log_martians" = 1;
      "net.ipv4.conf.default.log_martians" = 1;
    };
  };
  kernelHardening = level: {
    boot.kernel.sysctl = lib.mkMerge [
      (lib.mkIf (lib.elem level ["basic" "standard" "hardened" "paranoid"]) {
        "kernel.dmesg_restrict" = 1;
        "kernel.kptr_restrict" = 2;
        "kernel.sysrq" = 0;
        "dev.tty.ldisc_autoload" = 0;
      })
      (lib.mkIf (lib.elem level ["standard" "hardened" "paranoid"]) {
        "kernel.yama.ptrace_scope" = 1;
        "kernel.randomize_va_space" = 2;
        "kernel.unprivileged_bpf_disabled" = 1;
        "net.core.bpf_jit_harden" = 2;
        "kernel.perf_event_paranoid" = 3;
        "kernel.perf_cpu_time_max_percent" = 1;
        "kernel.perf_event_max_sample_rate" = 1;
      })
      (lib.mkIf (lib.elem level ["hardened" "paranoid"]) {
        "kernel.yama.ptrace_scope" = 2;
        "vm.mmap_rnd_bits" = 32;
        "vm.mmap_rnd_compat_bits" = 16;
        "fs.protected_hardlinks" = 1;
        "fs.protected_symlinks" = 1;
        "fs.protected_fifos" = 2;
        "fs.protected_regular" = 2;
        "user.max_user_namespaces" = 0;
        "kernel.modules_disabled" = 1;
      })
      (lib.mkIf (level == "paranoid") {
        "kernel.yama.ptrace_scope" = 3;
        "vm.swappiness" = 1;
        "vm.overcommit_memory" = 2;
        "vm.overcommit_ratio" = 50;
        "vm.mmap_min_addr" = 65536;
        "kernel.kexec_load_disabled" = 1;
      })
    ];
    boot.blacklistedKernelModules = lib.mkMerge [
      (lib.mkIf (lib.elem level ["standard" "hardened" "paranoid"]) [
        "dccp"
        "sctp"
        "rds"
        "tipc"
        "cramfs"
        "freevxfs"
        "jffs2"
        "hfs"
        "hfsplus"
        "squashfs"
        "udf"
        "n-hdlc"
        "ax25"
        "netrom"
        "x25"
        "rose"
        "decnet"
        "econet"
      ])
      (lib.mkIf (lib.elem level ["hardened" "paranoid"]) [
        "af_802154"
        "ipx"
        "appletalk"
        "psnap"
        "p8023"
        "p8022"
        "can"
        "atm"
        "bluetooth"
        "btusb"
        "btrtl"
        "btbcm"
        "btintel"
        "cfg80211"
        "mac80211"
      ])
    ];
  };
  applicationSecurity = pkgs: {
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
    mac = level: pkgs: {
      selinux = lib.mkIf (level == "paranoid") {
        boot.kernelParams = ["security=selinux" "selinux=1" "enforcing=1"];
        environment.systemPackages = with pkgs; [
          policycoreutils
          selinux-python
          setools
        ];
      };
    };
    containerSecurity = {
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
      virtualisation.podman = {
        enable = true;
        dockerCompat = true;
        defaultNetwork.settings.dns_enabled = true;
      };
    };
  };
  cryptoSecurity = {
    strongCrypto = {
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
      security.tls = {
        cipherSuites = [
          "TLS_AES_256_GCM_SHA384"
          "TLS_CHACHA20_POLY1305_SHA256"
          "TLS_AES_128_GCM_SHA256"
        ];
        protocols = ["TLSv1.2" "TLSv1.3"];
      };
    };
    certificates = {
      security.acme = {
        acceptTerms = true;
        defaults.email = "admin@example.com";
      };
      security.pki.certificates = [
      ];
    };
  };
  securityMonitoring = pkgs: {
    ids = {
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
      ossec = {
        enable = false;
      };
    };
    logAnalysis = {
      services.journald.settings = {
        Storage = "persistent";
        Compress = true;
        SystemMaxUse = "500M";
        SystemMaxFileSize = "50M";
        SystemKeepFree = "1G";
        SystemMaxFiles = 100;
      };
      environment.systemPackages = with pkgs; [
        logwatch
        goaccess
        multitail
      ];
    };
  };
}
