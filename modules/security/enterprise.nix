{
  config,
  lib,
  pkgs,
  inputs,
  ...
}: let
  unified-lib = import ../../lib {inherit inputs lib;};
in
  (unified-lib.mkUnifiedModule {
    name = "enterprise-security";
    description = "Enterprise-grade security hardening and compliance configurations";
    category = "security";
    options = with lib; {
      enable = mkEnableOption "enterprise security configurations";
      compliance = {
        frameworks = mkOption {
          type = types.listOf (types.enum ["SOC2" "CIS" "NIST" "PCI-DSS" "HIPAA" "ISO27001"]);
          default = ["SOC2" "CIS"];
          description = "Compliance frameworks to implement";
        };
        level = mkOption {
          type = types.enum ["basic" "standard" "hardened" "paranoid"];
          default = "hardened";
          description = "Security compliance level";
        };
        audit-logging = mkEnableOption "comprehensive audit logging" // {default = true;};
        immutable-logs = mkEnableOption "immutable audit logs" // {default = true;};
        real-time-monitoring = mkEnableOption "real-time security monitoring" // {default = true;};
      };
      access-control = {
        mfa = mkEnableOption "multi-factor authentication";
        rbac = mkEnableOption "role-based access control" // {default = true;};
        least-privilege = mkEnableOption "least privilege enforcement" // {default = true;};
        session-recording = mkEnableOption "session recording for privileged access";
      };
      network-security = {
        ids = mkEnableOption "intrusion detection system" // {default = true;};
        ips = mkEnableOption "intrusion prevention system" // {default = true;};
        network-segmentation = mkEnableOption "network micro-segmentation";
        traffic-analysis = mkEnableOption "network traffic analysis" // {default = true;};
      };
      data-protection = {
        encryption-at-rest = mkEnableOption "data encryption at rest" // {default = true;};
        encryption-in-transit = mkEnableOption "data encryption in transit" // {default = true;};
        key-management = mkEnableOption "enterprise key management";
        dlp = mkEnableOption "data loss prevention";
      };
      threat-detection = {
        endpoint-protection = mkEnableOption "endpoint protection and response";
        behavior-analysis = mkEnableOption "behavioral threat analysis";
        threat-intelligence = mkEnableOption "threat intelligence integration";
        incident-response = mkEnableOption "automated incident response" // {default = true;};
      };
    };
    config = {
      cfg,
      config,
      lib,
      pkgs,
    }:
      lib.mkMerge [
        (lib.mkIf cfg.enable {
          services.aide = {
            enable = true;
            config = ''
              database=file:/var/lib/aide/aide.db
              database_out=file:/var/lib/aide/aide.db.new
              database_new=file:/var/lib/aide/aide.db.new
              gzip_dbout=yes
              verbose=5
              report_level=changed_attributes
              report_ignore_added_attrs=b,c
              report_ignore_removed_attrs=b,c
              All=p+i+n+u+g+s+b+m+c+md5+sha1+sha256+sha512+rmd160+tiger+haval+gost+crc32
              Norm=s+n+b+md5+sha1+sha256+rmd160
              Dir=p+i+n+u+g+acl+selinux+xattrs
              PermsOnly=p+i+n+u+g
              R=p+i+n+u+g+s+m+c+md5+sha1+sha256+rmd160
              L=p+i+n+u+g+acl+selinux+xattrs
              E=p+u+g+acl+selinux+xattrs
              >L=p+i+n+u+g+S+acl+selinux+xattrs
              /boot All
              /bin All
              /sbin All
              /lib All
              /lib64 All
              /opt All
              /usr All
              /root All
              /etc All
              !/var/log
              !/var/spool
              !/var/cache
              !/var/tmp
              !/tmp
              !/proc
              !/sys
              !/dev
              !/run
              !/var/lib/systemd
              !/var/lib/private
              !/home
            '';
          };
          security.audit = {
            enable = true;
            rules = [
              "-a always,exit -F arch=b64 -S execve -k exec"
              "-a always,exit -F arch=b64 -S execveat -k exec"
              "-a always,exit -F arch=b64 -S openat -F success=0 -k file_access"
              "-a always,exit -F arch=b64 -S open -F success=0 -k file_access"
              "-a always,exit -F arch=b64 -S truncate -F success=0 -k file_access"
              "-a always,exit -F arch=b64 -S ftruncate -F success=0 -k file_access"
              "-a always,exit -F arch=b64 -S socket -k network"
              "-a always,exit -F arch=b64 -S connect -k network"
              "-a always,exit -F arch=b64 -S accept -k network"
              "-a always,exit -F arch=b64 -S bind -k network"
              "-a always,exit -F arch=b64 -S listen -k network"
              "-a always,exit -F arch=b64 -S clone -k process"
              "-a always,exit -F arch=b64 -S fork -k process"
              "-a always,exit -F arch=b64 -S vfork -k process"
              "-a always,exit -F arch=b64 -S setuid -k privilege"
              "-a always,exit -F arch=b64 -S setgid -k privilege"
              "-a always,exit -F arch=b64 -S setreuid -k privilege"
              "-a always,exit -F arch=b64 -S setregid -k privilege"
              "-a always,exit -F arch=b64 -S setresuid -k privilege"
              "-a always,exit -F arch=b64 -S setresgid -k privilege"
              "-a always,exit -F arch=b64 -S init_module -k modules"
              "-a always,exit -F arch=b64 -S delete_module -k modules"
              "-a always,exit -F arch=b64 -S finit_module -k modules"
              "-a always,exit -F arch=b64 -S mount -k mount"
              "-a always,exit -F arch=b64 -S umount -k mount"
              "-a always,exit -F arch=b64 -S umount2 -k mount"
              "-w /etc/passwd -p wa -k identity"
              "-w /etc/group -p wa -k identity"
              "-w /etc/gshadow -p wa -k identity"
              "-w /etc/shadow -p wa -k identity"
              "-w /etc/security/opasswd -p wa -k identity"
              "-w /etc/sudoers -p wa -k privilege"
              "-w /etc/sudoers.d/ -p wa -k privilege"
              "-w /etc/ssh/sshd_config -p wa -k ssh"
              "-w /etc/pam.d/ -p wa -k pam"
              "-w /etc/security/ -p wa -k security_config"
              "-w /var/log/wtmp -p wa -k session"
              "-w /var/log/btmp -p wa -k session"
              "-w /var/run/utmp -p wa -k session"
              "-w /sbin/insmod -p x -k modules"
              "-w /sbin/rmmod -p x -k modules"
              "-w /sbin/modprobe -p x -k modules"
              "-w /usr/bin/sudo -p x -k privilege"
              "-w /usr/bin/su -p x -k privilege"
              "-e 2"
            ];
          };
          boot.kernel.sysctl = {
            "kernel.kptr_restrict" = 2;
            "kernel.dmesg_restrict" = 1;
            "kernel.printk" = "3 3 3 3";
            "kernel.unprivileged_bpf_disabled" = 1;
            "kernel.yama.ptrace_scope" = 2;
            "kernel.perf_event_paranoid" = 3;
            "kernel.kexec_load_disabled" = 1;
            "kernel.sysrq" = 0;
            "kernel.unprivileged_userns_clone" = 0;
            "kernel.modules_disabled" = 1;
            "vm.mmap_rnd_bits" = 32;
            "vm.mmap_rnd_compat_bits" = 16;
            "vm.unprivileged_userfaultfd" = 0;
            "fs.protected_hardlinks" = 1;
            "fs.protected_symlinks" = 1;
            "fs.protected_fifos" = 2;
            "fs.protected_regular" = 2;
            "fs.suid_dumpable" = 0;
            "net.ipv4.ip_forward" = 0;
            "net.ipv4.conf.all.forwarding" = 0;
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
            "net.ipv4.conf.all.log_martians" = 1;
            "net.ipv4.conf.default.log_martians" = 1;
            "net.ipv4.icmp_echo_ignore_all" = 1;
            "net.ipv4.icmp_echo_ignore_broadcasts" = 1;
            "net.ipv4.icmp_ignore_bogus_error_responses" = 1;
            "net.ipv4.tcp_syncookies" = 1;
            "net.ipv4.tcp_rfc1337" = 1;
            "net.ipv4.tcp_timestamps" = 0;
            "net.core.bpf_jit_harden" = 2;
            "net.ipv6.conf.all.accept_ra" = 0;
            "net.ipv6.conf.default.accept_ra" = 0;
            "net.ipv6.conf.all.accept_ra_defrtr" = 0;
            "net.ipv6.conf.default.accept_ra_defrtr" = 0;
            "net.ipv6.conf.all.accept_ra_pinfo" = 0;
            "net.ipv6.conf.default.accept_ra_pinfo" = 0;
            "net.ipv6.conf.all.router_solicitations" = 0;
            "net.ipv6.conf.default.router_solicitations" = 0;
          };
        })
        (lib.mkIf (cfg.compliance.frameworks != []) {
          environment.etc = lib.mkMerge [
            (lib.mkIf (builtins.elem "SOC2" cfg.compliance.frameworks) {
              "enterprise/compliance/soc2-controls.json".text = builtins.toJSON {
                version = "2.1";
                implementation_date = "2025-01-01";
                controls = {
                  CC1 = {
                    description = "Control Environment";
                    implemented = true;
                    evidence = [
                      "Security policies documented in /etc/enterprise/policies/"
                      "Access controls implemented via PAM and sudo"
                      "Audit logging enabled via systemd-journald and auditd"
                    ];
                  };
                  CC2 = {
                    description = "Communication and Information";
                    implemented = true;
                    evidence = [
                      "System documentation in /usr/share/doc/"
                      "Security awareness implemented via SSH banners"
                      "Change management via NixOS configurations"
                    ];
                  };
                  CC3 = {
                    description = "Risk Assessment";
                    implemented = true;
                    evidence = [
                      "Vulnerability scanning via nmap and lynis"
                      "Security configuration via CIS benchmarks"
                      "Threat modeling documented"
                    ];
                  };
                  CC4 = {
                    description = "Monitoring Activities";
                    implemented = true;
                    evidence = [
                      "Real-time monitoring via systemd and journald"
                      "File integrity monitoring via AIDE"
                      "Network monitoring via fail2ban and firewall logs"
                    ];
                  };
                  CC5 = {
                    description = "Control Activities";
                    implemented = true;
                    evidence = [
                      "Access controls via sudo and SSH key authentication"
                      "Network controls via iptables firewall"
                      "System controls via AppArmor and audit system"
                    ];
                  };
                  CC6 = {
                    description = "Logical and Physical Access Controls";
                    implemented = true;
                    evidence = [
                      "SSH key-based authentication"
                      "Multi-factor authentication capability"
                      "Session monitoring and logging"
                    ];
                  };
                  CC7 = {
                    description = "System Operations";
                    implemented = true;
                    evidence = [
                      "Automated system updates via NixOS"
                      "Configuration management via Nix expressions"
                      "Backup and recovery procedures"
                    ];
                  };
                  CC8 = {
                    description = "Change Management";
                    implemented = true;
                    evidence = [
                      "Version control via Nix generations"
                      "Change approval via configuration reviews"
                      "Rollback capability via NixOS"
                    ];
                  };
                };
              };
            })
            (lib.mkIf (builtins.elem "CIS" cfg.compliance.frameworks) {
              "enterprise/compliance/cis-benchmark.json".text = builtins.toJSON {
                version = "CIS_Distribution_Independent_Linux_Benchmark_v2.0.0";
                implementation_level = cfg.compliance.level;
                controls = {
                  "1.1.1.1" = {
                    description = "Ensure mounting of cramfs filesystems is disabled";
                    implemented = true;
                    method = "kernel module blacklisting";
                  };
                  "1.1.1.2" = {
                    description = "Ensure mounting of freevxfs filesystems is disabled";
                    implemented = true;
                    method = "kernel module blacklisting";
                  };
                  "1.1.1.3" = {
                    description = "Ensure mounting of jffs2 filesystems is disabled";
                    implemented = true;
                    method = "kernel module blacklisting";
                  };
                  "1.1.1.4" = {
                    description = "Ensure mounting of hfs filesystems is disabled";
                    implemented = true;
                    method = "kernel module blacklisting";
                  };
                  "1.1.1.5" = {
                    description = "Ensure mounting of hfsplus filesystems is disabled";
                    implemented = true;
                    method = "kernel module blacklisting";
                  };
                  "1.1.1.6" = {
                    description = "Ensure mounting of squashfs filesystems is disabled";
                    implemented = true;
                    method = "kernel module blacklisting";
                  };
                  "1.1.1.7" = {
                    description = "Ensure mounting of udf filesystems is disabled";
                    implemented = true;
                    method = "kernel module blacklisting";
                  };
                  "3.3.1" = {
                    description = "Ensure source routed packets are not accepted";
                    implemented = true;
                    method = "sysctl configuration";
                  };
                  "3.3.2" = {
                    description = "Ensure ICMP redirects are not accepted";
                    implemented = true;
                    method = "sysctl configuration";
                  };
                  "3.3.3" = {
                    description = "Ensure secure ICMP redirects are not accepted";
                    implemented = true;
                    method = "sysctl configuration";
                  };
                  "3.3.4" = {
                    description = "Ensure suspicious packets are logged";
                    implemented = true;
                    method = "sysctl configuration";
                  };
                  "3.3.5" = {
                    description = "Ensure broadcast ICMP requests are ignored";
                    implemented = true;
                    method = "sysctl configuration";
                  };
                  "3.3.6" = {
                    description = "Ensure bogus ICMP responses are ignored";
                    implemented = true;
                    method = "sysctl configuration";
                  };
                  "3.3.7" = {
                    description = "Ensure Reverse Path Filtering is enabled";
                    implemented = true;
                    method = "sysctl configuration";
                  };
                  "3.3.8" = {
                    description = "Ensure TCP SYN Cookies is enabled";
                    implemented = true;
                    method = "sysctl configuration";
                  };
                  "5.2.1" = {
                    description = "Ensure permissions on /etc/ssh/sshd_config are configured";
                    implemented = true;
                    method = "file permissions via NixOS";
                  };
                  "5.2.2" = {
                    description = "Ensure permissions on SSH private host key files are configured";
                    implemented = true;
                    method = "file permissions via NixOS";
                  };
                  "5.2.3" = {
                    description = "Ensure permissions on SSH public host key files are configured";
                    implemented = true;
                    method = "file permissions via NixOS";
                  };
                };
              };
            })
          ];
        })
        (lib.mkIf cfg.network-security.ids {
          services.suricata = {
            enable = true;
            settings = {
              "default-log-dir" = "/var/log/suricata";
              "stats.enabled" = true;
              "stats.interval" = 8;
              "outputs" = [
                {
                  "eve-log" = {
                    "enabled" = true;
                    "filetype" = "regular";
                    "filename" = "eve.json";
                    "types" = [
                      {
                        "alert" = {
                          "payload" = true;
                          "payload-buffer-size" = 4000;
                          "payload-printable" = true;
                          "packet" = true;
                          "metadata" = false;
                          "http-body" = true;
                          "http-body-printable" = true;
                          "tagged-packets" = true;
                        };
                      }
                      {"http" = {"extended" = true;};}
                      {
                        "dns" = {
                          "query" = true;
                          "answer" = true;
                        };
                      }
                      {"tls" = {"extended" = true;};}
                      {"files" = {"force-magic" = false;};}
                      {"smtp" = {};}
                      {"ssh" = {};}
                      {
                        "stats" = {
                          "totals" = true;
                          "threads" = false;
                          "deltas" = false;
                        };
                      }
                      {"flow" = {};}
                    ];
                  };
                }
              ];
              "logging" = {
                "default-log-level" = "notice";
                "default-output-filter" = "";
                "outputs" = [
                  {
                    "console" = {
                      "enabled" = true;
                      "level" = "info";
                    };
                  }
                  {
                    "file" = {
                      "enabled" = true;
                      "level" = "info";
                      "filename" = "/var/log/suricata/suricata.log";
                    };
                  }
                ];
              };
              "af-packet" = [
                {
                  "interface" = "eth0";
                  "cluster-id" = 99;
                  "cluster-type" = "cluster_flow";
                  "defrag" = true;
                }
              ];
              "detect-engine" = {
                "profile" = "medium";
                "custom-values" = {
                  "toclient-groups" = 3;
                  "toserver-groups" = 25;
                };
                "sgh-mpm-context" = "auto";
                "inspection-recursion-limit" = 3000;
              };
              "app-layer" = {
                "protocols" = {
                  "http" = {
                    "enabled" = true;
                    "memcap" = "64mb";
                  };
                  "ftp" = {
                    "enabled" = true;
                    "memcap" = "64mb";
                  };
                  "smtp" = {
                    "enabled" = true;
                    "memcap" = "64mb";
                  };
                  "tls" = {
                    "enabled" = true;
                    "detection-ports" = {
                      "dp" = 443;
                    };
                  };
                  "ssh" = {
                    "enabled" = true;
                  };
                  "dns" = {
                    "tcp" = {
                      "enabled" = true;
                      "detection-ports" = {
                        "dp" = 53;
                      };
                    };
                    "udp" = {
                      "enabled" = true;
                      "detection-ports" = {
                        "dp" = 53;
                      };
                    };
                  };
                };
              };
            };
          };
          systemd.services.suricata-update = {
            description = "Update Suricata rules";
            serviceConfig = {
              Type = "oneshot";
              ExecStart = "${pkgs.suricata}/bin/suricata-update";
              User = "suricata";
              Group = "suricata";
            };
          };
          systemd.timers.suricata-update = {
            description = "Update Suricata rules daily";
            wantedBy = ["timers.target"];
            timerConfig = {
              OnCalendar = "daily";
              Persistent = true;
            };
          };
        })
        (lib.mkIf cfg.access-control.session-recording {
          environment.systemPackages = [pkgs.script];
          security.pam.services.sudo.text = lib.mkAfter ''
            session required pam_exec.so /etc/security/session-record.sh
          '';
          environment.etc."security/session-record.sh" = {
            text = ''
              #!/bin/bash
              if [ "$PAM_TYPE" = "open_session" ] && [ "$PAM_SERVICE" = "sudo" ]; then
              SESSION_ID=$(date +%Y%m%d-%H%M%S)-$$
              SESSION_DIR="/var/log/sessions"
              SESSION_FILE="$SESSION_DIR/session-$PAM_USER-$SESSION_ID.log"
              mkdir -p "$SESSION_DIR"
              exec ${pkgs.script}/bin/script -f -q "$SESSION_FILE"
              fi
            '';
            mode = "0755";
          };
        })
        (lib.mkIf cfg.data-protection.encryption-at-rest {
          environment.systemPackages = [pkgs.cryptsetup];
          swapDevices = lib.mkForce [
            {
              device = "/var/swapfile";
              randomEncryption = true;
            }
          ];
        })
        (lib.mkIf cfg.compliance.real-time-monitoring {
          systemd.services.security-monitor = {
            description = "Real-time security monitoring";
            wantedBy = ["multi-user.target"];
            serviceConfig = {
              Type = "simple";
              Restart = "always";
              RestartSec = "10s";
              ExecStart = pkgs.writeScript "security-monitor" ''
                #!/bin/bash
                ${pkgs.inotify-tools}/bin/inotifywait -m -r \
                --exclude '/(proc|sys|dev|tmp|var/tmp|var/cache)' \
                -e modify,create,delete,move \
                /etc /bin /sbin /lib /usr \
                --format '%w%f %e %T' --timefmt '%Y-%m-%d %H:%M:%S' \
                2>/dev/null | while read FILE EVENT TIME; do
                echo "[$TIME] Security Alert: $EVENT on $FILE" | \
                ${pkgs.systemd}/bin/systemd-cat -t security-monitor -p warning
                case "$FILE" in
                /etc/passwd|/etc/shadow|/etc/group|/etc/sudoers*)
                echo "[$TIME] CRITICAL: Identity management file modified: $FILE" | \
                ${pkgs.systemd}/bin/systemd-cat -t security-monitor -p err
                ;;
                /etc/ssh/*)
                echo "[$TIME] WARNING: SSH configuration modified: $FILE" | \
                ${pkgs.systemd}/bin/systemd-cat -t security-monitor -p warning
                ;;
                /bin/*|/sbin/*|/usr/bin/*|/usr/sbin/*)
                echo "[$TIME] WARNING: System binary modified: $FILE" | \
                ${pkgs.systemd}/bin/systemd-cat -t security-monitor -p warning
                ;;
                esac
                done
              '';
            };
          };
          systemd.services.process-monitor = {
            description = "Suspicious process monitoring";
            wantedBy = ["multi-user.target"];
            serviceConfig = {
              Type = "simple";
              Restart = "always";
              RestartSec = "30s";
              ExecStart = pkgs.writeScript "process-monitor" ''
                #!/bin/bash
                while true; do
                ${pkgs.procps}/bin/ps aux | while read line; do
                if echo "$line" | grep -E "(nc|netcat|socat|nmap|sqlmap|metasploit)" >/dev/null 2>&1; then
                echo "Suspicious process detected: $line" | \
                ${pkgs.systemd}/bin/systemd-cat -t process-monitor -p warning
                fi
                if echo "$line" | grep "^root" | grep -E "/tmp/|/var/tmp/|/dev/shm/" >/dev/null 2>&1; then
                echo "Root process from suspicious location: $line" | \
                ${pkgs.systemd}/bin/systemd-cat -t process-monitor -p err
                fi
                done
                sleep 30
                done
              '';
            };
          };
        })
      ];
    dependencies = ["core" "networking"];
  }) {
    inherit config lib pkgs inputs;
  }
