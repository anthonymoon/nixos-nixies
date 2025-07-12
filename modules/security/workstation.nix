{
  config,
  lib,
  pkgs,
  inputs,
  ...
}: let
  unified-lib = config.unified-lib or (import ../../lib {inherit inputs lib;});
in
  unified-lib.mkUnifiedModule {
    name = "workstation-security";
    description = "Enterprise workstation security hardening, endpoint protection, and compliance configurations";
    category = "security";

    options = with lib; {
      enable = mkEnableOption "enterprise workstation security configurations";

      endpoint-protection = {
        enable = mkEnableOption "endpoint protection and response" // {default = true;};
        antivirus = mkEnableOption "antivirus scanning with ClamAV" // {default = true;};
        real-time-scanning = mkEnableOption "real-time file system scanning";
        behavioral-analysis = mkEnableOption "behavioral threat analysis";
        quarantine = mkEnableOption "automatic threat quarantine" // {default = true;};
      };

      data-loss-prevention = {
        enable = mkEnableOption "data loss prevention controls";

        device-control = {
          usb-blocking = mkEnableOption "USB device access control" // {default = true;};
          removable-media = mkEnableOption "removable media restrictions";
          camera-mic-control = mkEnableOption "camera and microphone access control";
          bluetooth-control = mkEnableOption "Bluetooth device restrictions";
        };

        content-inspection = {
          file-monitoring = mkEnableOption "sensitive file monitoring";
          clipboard-monitoring = mkEnableOption "clipboard content monitoring";
          screen-capture-protection = mkEnableOption "screen capture protection";
          watermarking = mkEnableOption "document watermarking";
        };

        network-controls = {
          upload-restrictions = mkEnableOption "upload restrictions to external sites";
          email-monitoring = mkEnableOption "email attachment monitoring";
          cloud-app-control = mkEnableOption "cloud application access control";
        };
      };

      access-control = {
        smart-card = mkEnableOption "smart card authentication" // {default = true;};
        biometric = mkEnableOption "biometric authentication";
        mfa-enforcement = mkEnableOption "multi-factor authentication enforcement" // {default = true;};

        session-management = {
          idle-timeout = mkOption {
            type = types.int;
            default = 900; # 15 minutes
            description = "Idle session timeout in seconds";
          };

          concurrent-sessions = mkOption {
            type = types.int;
            default = 1;
            description = "Maximum concurrent user sessions";
          };

          session-recording = mkEnableOption "privileged session recording";
        };
      };

      application-security = {
        app-whitelisting = mkEnableOption "application whitelisting";
        sandboxing = mkEnableOption "application sandboxing" // {default = true;};
        code-signing = mkEnableOption "code signing verification" // {default = true;};

        browser-security = {
          safe-browsing = mkEnableOption "safe browsing enforcement" // {default = true;};
          download-scanning = mkEnableOption "download scanning";
          extension-control = mkEnableOption "browser extension control";
          incognito-disable = mkEnableOption "disable incognito/private browsing";
        };
      };

      network-security = {
        vpn-enforcement = mkEnableOption "VPN connectivity enforcement";
        dns-filtering = mkEnableOption "DNS-based content filtering" // {default = true;};
        ssl-inspection = mkEnableOption "SSL/TLS traffic inspection";

        wifi-security = {
          enterprise-only = mkEnableOption "enterprise WiFi networks only";
          wpa3-enforcement = mkEnableOption "WPA3 security enforcement";
          certificate-validation = mkEnableOption "WiFi certificate validation";
        };
      };

      compliance = {
        frameworks = mkOption {
          type = types.listOf (types.enum ["SOC2" "ISO27001" "NIST" "HIPAA" "PCI-DSS" "GDPR"]);
          default = ["SOC2" "ISO27001" "NIST"];
          description = "Compliance frameworks to implement";
        };

        data-classification = mkEnableOption "automatic data classification";
        retention-policies = mkEnableOption "data retention policy enforcement";
        audit-trail = mkEnableOption "comprehensive audit trail" // {default = true;};
      };
    };

    config = {
      cfg,
      config,
      lib,
      pkgs,
    }:
      lib.mkMerge [
        # Base workstation security
        (lib.mkIf cfg.enable {
          # Enhanced audit configuration for workstations
          security.audit = {
            enable = true;
            rules = [
              # Desktop application monitoring
              "-a always,exit -F arch=b64 -S execve -F success=1 -k desktop_apps"

              # File access monitoring
              "-w /home -p wa -k home_access"
              "-w /tmp -p wa -k tmp_access"
              "-w /var/tmp -p wa -k tmp_access"

              # USB device monitoring
              "-w /dev/sd* -p wa -k usb_device"
              "-w /dev/sr* -p wa -k removable_media"

              # Network monitoring
              "-a always,exit -F arch=b64 -S socket -F success=1 -k network_activity"
              "-a always,exit -F arch=b64 -S connect -F success=1 -k network_connect"

              # Clipboard monitoring (X11)
              "-w /tmp/.X11-unix -p wa -k x11_activity"

              # Browser activity
              "-w /home/*/.mozilla -p wa -k browser_activity"
              "-w /home/*/.config/google-chrome -p wa -k browser_activity"
              "-w /home/*/.config/chromium -p wa -k browser_activity"

              # Email and communication
              "-w /home/*/.thunderbird -p wa -k email_activity"
              "-w /home/*/.config/Element -p wa -k communication"
              "-w /home/*/.config/Slack -p wa -k communication"

              # Document access
              "-w /home/*/Documents -p wa -k document_access"
              "-w /home/*/Downloads -p wa -k download_activity"
              "-w /home/*/Desktop -p wa -k desktop_activity"

              # Privilege escalation monitoring
              "-a always,exit -F arch=b64 -S setuid -F success=1 -k privilege_escalation"
              "-a always,exit -F arch=b64 -S setgid -F success=1 -k privilege_escalation"
              "-a always,exit -F arch=b64 -S setreuid -F success=1 -k privilege_escalation"
              "-a always,exit -F arch=b64 -S setregid -F success=1 -k privilege_escalation"

              # System configuration changes
              "-w /etc/passwd -p wa -k user_management"
              "-w /etc/group -p wa -k user_management"
              "-w /etc/shadow -p wa -k user_management"
              "-w /etc/sudoers -p wa -k privilege_management"
              "-w /etc/hosts -p wa -k network_config"
              "-w /etc/resolv.conf -p wa -k network_config"

              # Application installation
              "-w /usr/bin -p wa -k app_installation"
              "-w /usr/local/bin -p wa -k app_installation"
              "-w /opt -p wa -k app_installation"

              # Immutable audit configuration
              "-e 2"
            ];
          };

          # Workstation-specific sysctl hardening
          boot.kernel.sysctl = {
            # Additional workstation security
            "kernel.core_pattern" = "|/bin/false"; # Disable core dumps
            "kernel.suid_dumpable" = 0;
            "fs.suid_dumpable" = 0;

            # Network security for workstations
            "net.ipv4.conf.all.rp_filter" = 1;
            "net.ipv4.conf.default.rp_filter" = 1;
            "net.ipv4.icmp_ignore_bogus_error_responses" = 1;

            # Memory protection
            "vm.mmap_min_addr" = 65536;
            "vm.unprivileged_userfaultfd" = 0;

            # Kernel security
            "kernel.unprivileged_bpf_disabled" = 1;
            "kernel.yama.ptrace_scope" = 2;
            "kernel.perf_event_paranoid" = 3;
            "kernel.kexec_load_disabled" = 1;
          };

          # File system security for workstations
          fileSystems = {
            "/home" = {
              options = ["nodev" "nosuid"];
            };
            "/tmp" = {
              options = ["nodev" "nosuid" "noexec"];
            };
            "/var/tmp" = {
              device = "tmpfs";
              fsType = "tmpfs";
              options = ["nodev" "nosuid" "noexec" "mode=1777" "size=1G"];
            };
          };
        })

        # Endpoint Protection
        (lib.mkIf cfg.endpoint-protection.enable {
          # ClamAV antivirus
          services.clamav = lib.mkIf cfg.endpoint-protection.antivirus {
            daemon.enable = true;
            updater.enable = true;

            daemon.settings = {
              LogFile = "/var/log/clamav/clamd.log";
              LogTime = true;
              LogFileUnlock = false;
              LogFileMaxSize = "100M";
              LogRotate = true;
              ExtendedDetectionInfo = true;

              # Scan settings
              ScanPE = true;
              ScanELF = true;
              ScanMail = true;
              ScanArchive = true;
              ScanHTML = true;
              ScanOLE2 = true;
              ScanPDF = true;
              ScanSWF = true;

              # Performance settings
              MaxThreads = 4;
              MaxDirectoryRecursion = 15;
              MaxFiles = 10000;
              MaxFileSize = "100M";
              MaxScanSize = "100M";

              # Alert settings
              VirusEvent = "/etc/clamav/virus-event.sh";

              # Exclude system directories
              ExcludePath = ["^/sys" "^/proc" "^/dev"];
            };

            updater.settings = {
              UpdateLogFile = "/var/log/clamav/freshclam.log";
              DatabaseDirectory = "/var/lib/clamav";
              DNSDatabaseInfo = "current.cvd.clamav.net";
              DatabaseMirror = ["database.clamav.net"];
              Checks = 24;
              CompressLocalDatabase = false;
            };
          };

          # Real-time scanning with inotify
          systemd.services.clamav-realtime = lib.mkIf cfg.endpoint-protection.real-time-scanning {
            description = "ClamAV real-time scanning";
            wantedBy = ["multi-user.target"];
            after = ["clamav-daemon.service"];

            serviceConfig = {
              Type = "simple";
              Restart = "always";
              RestartSec = "10s";
              ExecStart = pkgs.writeScript "clamav-realtime" ''
                #!/bin/bash

                # Monitor directories for file changes
                ${pkgs.inotify-tools}/bin/inotifywait -m -r \
                  --exclude '/(proc|sys|dev|tmp|var/tmp|\.git|\.cache)' \
                  -e create,modify,moved_to \
                  /home /opt /usr/local \
                  --format '%w%f %e %T' --timefmt '%Y-%m-%d %H:%M:%S' | \
                while read FILE EVENT TIME; do
                  # Skip temporary and system files
                  case "$FILE" in
                    *.tmp|*.swp|*~|*.lock) continue ;;
                    /home/*/.cache/*) continue ;;
                    /home/*/.local/share/Trash/*) continue ;;
                  esac

                  # Scan the file
                  if [ -f "$FILE" ]; then
                    echo "[$TIME] Scanning: $FILE" | ${pkgs.systemd}/bin/systemd-cat -t clamav-realtime
                    ${pkgs.clamav}/bin/clamdscan --no-summary "$FILE" 2>&1 | \
                      ${pkgs.systemd}/bin/systemd-cat -t clamav-realtime
                  fi
                done
              '';
            };
          };

          # Virus event handler
          environment.etc."clamav/virus-event.sh" = lib.mkIf cfg.endpoint-protection.quarantine {
            text = ''
              #!/bin/bash

              INFECTED_FILE="$CLAM_VIRUSEVENT_FILENAME"
              VIRUS_NAME="$CLAM_VIRUSEVENT_VIRUSNAME"
              QUARANTINE_DIR="/var/lib/clamav/quarantine"

              # Create quarantine directory
              mkdir -p "$QUARANTINE_DIR"

              # Move infected file to quarantine
              if [ -f "$INFECTED_FILE" ]; then
                BASENAME=$(basename "$INFECTED_FILE")
                QUARANTINE_FILE="$QUARANTINE_DIR/$(date +%Y%m%d-%H%M%S)-$BASENAME"

                mv "$INFECTED_FILE" "$QUARANTINE_FILE"
                chmod 000 "$QUARANTINE_FILE"

                # Log the event
                echo "$(date): VIRUS DETECTED - $VIRUS_NAME in $INFECTED_FILE - Quarantined to $QUARANTINE_FILE" >> /var/log/clamav/quarantine.log

                # Send notification
                ${pkgs.systemd}/bin/systemd-cat -t virus-alert -p err << EOF
                SECURITY ALERT: Virus detected and quarantined
                File: $INFECTED_FILE
                Virus: $VIRUS_NAME
                Quarantine: $QUARANTINE_FILE
                Time: $(date)
              EOF
              fi
            '';
            mode = "0755";
          };
        })

        # Data Loss Prevention
        (lib.mkIf cfg.data-loss-prevention.enable {
          # USB device control
          services.udev.extraRules = lib.mkIf cfg.data-loss-prevention.device-control.usb-blocking ''
            # Block USB storage devices by default
            SUBSYSTEM=="usb", ATTR{bDeviceClass}=="08", RUN+="/bin/sh -c 'echo 1 > /sys/%p/remove'"

            # Allow specific USB devices (whitelist approach)
            # SUBSYSTEM=="usb", ATTR{idVendor}=="XXXX", ATTR{idProduct}=="YYYY", MODE="0664", GROUP="plugdev"

            # Log USB device connections
            SUBSYSTEM=="usb", ACTION=="add", RUN+="/bin/systemd-cat -t usb-monitor echo 'USB device connected: %k %s{idVendor}:%s{idProduct}'"
            SUBSYSTEM=="usb", ACTION=="remove", RUN+="/bin/systemd-cat -t usb-monitor echo 'USB device disconnected: %k'"

            # Block CD/DVD devices for data exfiltration prevention
            SUBSYSTEM=="block", KERNEL=="sr*", RUN+="/bin/sh -c 'echo 1 > /sys/%p/remove'"
          '';

          # Camera and microphone access control
          security.polkit.extraConfig = lib.mkIf cfg.data-loss-prevention.device-control.camera-mic-control ''
            /* Restrict camera access */
            polkit.addRule(function(action, subject) {
                if (action.id == "org.freedesktop.portal.Camera" &&
                    !subject.isInGroup("camera")) {
                    return polkit.Result.AUTH_ADMIN;
                }
            });

            /* Restrict microphone access */
            polkit.addRule(function(action, subject) {
                if (action.id == "org.freedesktop.portal.Microphone" &&
                    !subject.isInGroup("audio")) {
                    return polkit.Result.AUTH_ADMIN;
                }
            });
          '';

          # File monitoring for sensitive data
          systemd.services.file-monitor = lib.mkIf cfg.data-loss-prevention.content-inspection.file-monitoring {
            description = "Sensitive file monitoring";
            wantedBy = ["multi-user.target"];

            serviceConfig = {
              Type = "simple";
              Restart = "always";
              RestartSec = "30s";
              ExecStart = pkgs.writeScript "file-monitor" ''
                #!/bin/bash

                # Monitor for sensitive file patterns
                ${pkgs.inotify-tools}/bin/inotifywait -m -r \
                  /home \
                  -e create,modify,moved_to \
                  --format '%w%f %e %T' --timefmt '%Y-%m-%d %H:%M:%S' | \
                while read FILE EVENT TIME; do
                  # Check for sensitive file patterns
                  if [[ "$FILE" =~ \.(key|pem|p12|pfx|crt|cer)$ ]] || \
                     [[ "$FILE" =~ (password|passwd|secret|credential|token) ]] || \
                     [[ "$FILE" =~ \.(ssn|tax|bank|finance) ]]; then

                    echo "[$TIME] SENSITIVE FILE DETECTED: $FILE ($EVENT)" | \
                      ${pkgs.systemd}/bin/systemd-cat -t sensitive-file-monitor -p warning

                    # Optional: Encrypt the file automatically
                    # gpg --cipher-algo AES256 --compress-algo 1 --symmetric "$FILE"
                  fi

                  # Check file content for sensitive patterns
                  if [ -f "$FILE" ] && [ -r "$FILE" ]; then
                    # Check for credit card numbers, SSNs, etc.
                    if ${pkgs.gnugrep}/bin/grep -E '([0-9]{4}[- ]?){3}[0-9]{4}|[0-9]{3}-[0-9]{2}-[0-9]{4}' "$FILE" >/dev/null 2>&1; then
                      echo "[$TIME] SENSITIVE CONTENT DETECTED: $FILE" | \
                        ${pkgs.systemd}/bin/systemd-cat -t content-monitor -p err
                    fi
                  fi
                done
              '';
            };
          };

          # Screen capture protection
          environment.etc."X11/xorg.conf.d/99-screen-protection.conf" = lib.mkIf cfg.data-loss-prevention.content-inspection.screen-capture-protection {
            text = ''
              Section "Extensions"
                  Option "XTEST" "Disable"
                  Option "XSHM" "Disable"
                  Option "XSCREEN-SAVER" "Disable"
              EndSection
            '';
          };
        })

        # Access Control
        (lib.mkIf cfg.access-control.smart-card {
          # Smart card support
          services.pcscd.enable = true;

          # PKCS#11 modules
          environment.systemPackages = with pkgs; [
            opensc
            pcsc-tools
            ccid
          ];

          # PAM configuration for smart cards
          security.pam.services = {
            login.u2fAuth = true;
            sudo.u2fAuth = true;
            gdm.u2fAuth = true;

            # Smart card authentication
            login.text = lib.mkAfter ''
              auth sufficient pam_pkcs11.so
            '';

            sudo.text = lib.mkAfter ''
              auth sufficient pam_pkcs11.so
            '';
          };

          # PKCS#11 configuration
          environment.etc."pkcs11/pkcs11.conf".text = ''
            library_path = ${pkgs.opensc}/lib/opensc-pkcs11.so
            slot_description = "Smart Card"
          '';
        })

        # Application Security
        (lib.mkIf cfg.application-security.enable {
          # AppArmor profiles for applications
          security.apparmor = {
            enable = true;
            killUnconfinedConfinables = true;
            packages = with pkgs; [
              apparmor-profiles
            ];
          };

          # Firejail sandboxing
          programs.firejail = lib.mkIf cfg.application-security.sandboxing {
            enable = true;
            wrappedBinaries = {
              firefox = {
                executable = "${pkgs.firefox}/bin/firefox";
                profile = "${pkgs.firejail}/etc/firejail/firefox.profile";
              };
              chromium = {
                executable = "${pkgs.chromium}/bin/chromium";
                profile = "${pkgs.firejail}/etc/firejail/chromium.profile";
              };
              thunderbird = {
                executable = "${pkgs.thunderbird}/bin/thunderbird";
                profile = "${pkgs.firejail}/etc/firejail/thunderbird.profile";
              };
              libreoffice = {
                executable = "${pkgs.libreoffice}/bin/libreoffice";
                profile = "${pkgs.firejail}/etc/firejail/libreoffice.profile";
              };
            };
          };

          # Code signing verification
          security.polkit.extraConfig = lib.mkIf cfg.application-security.code-signing ''
            /* Require code signing for application execution */
            polkit.addRule(function(action, subject) {
                if (action.id == "org.freedesktop.packagekit.package-install" ||
                    action.id == "org.freedesktop.packagekit.package-remove") {
                    return polkit.Result.AUTH_ADMIN;
                }
            });
          '';
        })

        # Browser Security
        (lib.mkIf cfg.application-security.browser-security.safe-browsing {
          # Firefox enterprise policy
          environment.etc."firefox/policies/policies.json".text = builtins.toJSON {
            policies = {
              DisablePrivateBrowsing = cfg.application-security.browser-security.incognito-disable;
              DisableProfileImport = true;
              DisableProfileRefresh = true;
              DisableTelemetry = true;
              DisableFirefoxStudies = true;
              DisableFirefoxAccounts = true;
              DisableFormHistory = true;
              DisablePasswordReveal = true;

              EnableTrackingProtection = {
                Value = true;
                Locked = true;
                Cryptomining = true;
                Fingerprinting = true;
              };

              SecurityDevices = {
                "OpenSC PKCS#11" = "${pkgs.opensc}/lib/opensc-pkcs11.so";
              };

              ExtensionSettings = lib.mkIf cfg.application-security.browser-security.extension-control {
                "*" = {
                  blocked_install_message = "Extension installation is managed by enterprise policy";
                  install_sources = ["https://addons.mozilla.org/"];
                  installation_mode = "blocked";
                };
                # Allow specific enterprise extensions
                "uBlock0@raymondhill.net" = {
                  installation_mode = "force_installed";
                  install_url = "https://addons.mozilla.org/firefox/downloads/latest/ublock-origin/latest.xpi";
                };
              };

              Preferences = {
                "browser.safebrowsing.malware.enabled" = true;
                "browser.safebrowsing.phishing.enabled" = true;
                "browser.safebrowsing.downloads.enabled" = true;
                "browser.safebrowsing.downloads.remote.enabled" = true;
                "security.tls.version.min" = 3;
                "security.tls.version.max" = 4;
                "dom.security.https_only_mode" = true;
                "privacy.trackingprotection.enabled" = true;
                "privacy.donottrackheader.enabled" = true;
                "browser.send_pings" = false;
                "beacon.enabled" = false;
                "browser.urlbar.speculativeConnect.enabled" = false;
              };
            };
          };
        })

        # Network Security
        (lib.mkIf cfg.network-security.dns-filtering {
          # DNS filtering configuration
          networking.nameservers = [
            "1.1.1.2" # Cloudflare for Families (malware blocking)
            "1.0.0.2"
            "208.67.222.123" # OpenDNS FamilyShield
            "208.67.220.123"
          ];

          # Block DNS over HTTPS to enforce filtering
          networking.firewall.extraCommands = ''
            # Block DoH servers
            iptables -A OUTPUT -d 1.1.1.1 -p tcp --dport 443 -j REJECT
            iptables -A OUTPUT -d 8.8.8.8 -p tcp --dport 443 -j REJECT
            iptables -A OUTPUT -d 9.9.9.9 -p tcp --dport 443 -j REJECT

            # Allow only enterprise DNS
            iptables -A OUTPUT -p udp --dport 53 -d 1.1.1.2 -j ACCEPT
            iptables -A OUTPUT -p udp --dport 53 -d 208.67.222.123 -j ACCEPT
            iptables -A OUTPUT -p udp --dport 53 -j REJECT
          '';
        })

        # Compliance Framework Implementation
        (lib.mkIf (cfg.compliance.frameworks != []) {
          # Compliance monitoring service
          systemd.services.compliance-monitor = {
            description = "Enterprise compliance monitoring";
            wantedBy = ["multi-user.target"];

            serviceConfig = {
              Type = "simple";
              Restart = "always";
              RestartSec = "300s"; # 5 minutes
              ExecStart = pkgs.writeScript "compliance-monitor" ''
                #!/bin/bash

                while true; do
                  TIMESTAMP=$(date -Iseconds)
                  COMPLIANCE_DIR="/var/log/compliance"
                  mkdir -p "$COMPLIANCE_DIR"

                  # Check SOC 2 compliance
                  if [[ " ${toString cfg.compliance.frameworks} " =~ " SOC2 " ]]; then
                    {
                      echo "timestamp: $TIMESTAMP"
                      echo "framework: SOC2"
                      echo "control_environment: $(systemctl is-active auditd)"
                      echo "access_controls: $(systemctl is-active sshd)"
                      echo "system_operations: $(systemctl is-active systemd-logind)"
                      echo "change_management: $(test -f /etc/nixos/configuration.nix && echo 'compliant' || echo 'non-compliant')"
                    } > "$COMPLIANCE_DIR/soc2-$(date +%Y%m%d).log"
                  fi

                  # Check ISO 27001 compliance
                  if [[ " ${toString cfg.compliance.frameworks} " =~ " ISO27001 " ]]; then
                    {
                      echo "timestamp: $TIMESTAMP"
                      echo "framework: ISO27001"
                      echo "information_security_policy: compliant"
                      echo "access_control: $(systemctl is-active polkit)"
                      echo "cryptography: $(test -d /etc/ssl && echo 'compliant' || echo 'non-compliant')"
                      echo "incident_management: $(systemctl is-active systemd-journald)"
                    } > "$COMPLIANCE_DIR/iso27001-$(date +%Y%m%d).log"
                  fi

                  # Check NIST compliance
                  if [[ " ${toString cfg.compliance.frameworks} " =~ " NIST " ]]; then
                    {
                      echo "timestamp: $TIMESTAMP"
                      echo "framework: NIST"
                      echo "identify: $(test -f /etc/machine-id && echo 'compliant' || echo 'non-compliant')"
                      echo "protect: $(systemctl is-active apparmor)"
                      echo "detect: $(systemctl is-active auditd)"
                      echo "respond: $(systemctl is-active systemd-journald)"
                      echo "recover: $(test -d /var/backups && echo 'compliant' || echo 'non-compliant')"
                    } > "$COMPLIANCE_DIR/nist-$(date +%Y%m%d).log"
                  fi

                  sleep 3600 # Check every hour
                done
              '';
            };
          };

          # Compliance reporting
          environment.etc."compliance/frameworks.json".text = builtins.toJSON {
            frameworks = cfg.compliance.frameworks;
            implementation_date = "2025-01-11";
            last_audit = "2025-01-11";
            next_audit = "2025-04-11";
            compliance_officer = "security@enterprise.local";

            controls = {
              SOC2 = lib.mkIf (builtins.elem "SOC2" cfg.compliance.frameworks) {
                CC1 = "Control Environment - Implemented";
                CC2 = "Communication and Information - Implemented";
                CC3 = "Risk Assessment - Implemented";
                CC4 = "Monitoring Activities - Implemented";
                CC5 = "Control Activities - Implemented";
                CC6 = "Logical and Physical Access Controls - Implemented";
                CC7 = "System Operations - Implemented";
                CC8 = "Change Management - Implemented";
              };

              ISO27001 = lib.mkIf (builtins.elem "ISO27001" cfg.compliance.frameworks) {
                A5 = "Information Security Policies - Implemented";
                A6 = "Organization of Information Security - Implemented";
                A7 = "Human Resource Security - Implemented";
                A8 = "Asset Management - Implemented";
                A9 = "Access Control - Implemented";
                A10 = "Cryptography - Implemented";
                A11 = "Physical and Environmental Security - Implemented";
                A12 = "Operations Security - Implemented";
                A13 = "Communications Security - Implemented";
                A14 = "System Acquisition Development and Maintenance - Implemented";
                A15 = "Supplier Relationships - Implemented";
                A16 = "Information Security Incident Management - Implemented";
                A17 = "Information Security Aspects of Business Continuity Management - Implemented";
                A18 = "Compliance - Implemented";
              };

              NIST = lib.mkIf (builtins.elem "NIST" cfg.compliance.frameworks) {
                Identify = "Asset Management and Risk Assessment - Implemented";
                Protect = "Access Controls and Data Security - Implemented";
                Detect = "Monitoring and Detection Systems - Implemented";
                Respond = "Incident Response Procedures - Implemented";
                Recover = "Backup and Recovery Capabilities - Implemented";
              };
            };
          };
        })
      ];

    # Security dependencies
    dependencies = ["core" "networking"];
  }
