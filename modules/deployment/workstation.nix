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
    name = "workstation-deployment";
    description = "Enterprise workstation deployment automation, device management, and user provisioning";
    category = "deployment";
    options = with lib; {
      enable = mkEnableOption "enterprise workstation deployment automation";
      device-management = {
        enable = mkEnableOption "enterprise device management" // {default = true;};
        mdm = {
          provider = mkOption {
            type = types.enum ["microsoft-intune" "jamf" "kandji" "airwatch" "custom"];
            default = "custom";
            description = "Mobile Device Management provider";
          };
          enrollment = {
            automatic = mkEnableOption "automatic device enrollment";
            zero-touch = mkEnableOption "zero-touch provisioning";
            self-service = mkEnableOption "self-service enrollment portal";
          };
          policies = {
            compliance = mkEnableOption "device compliance policies" // {default = true;};
            configuration = mkEnableOption "configuration management" // {default = true;};
            security = mkEnableOption "security policy enforcement" // {default = true;};
            updates = mkEnableOption "automatic update management" // {default = true;};
          };
        };
        inventory = {
          hardware = mkEnableOption "hardware inventory collection" // {default = true;};
          software = mkEnableOption "software inventory tracking" // {default = true;};
          licenses = mkEnableOption "software license management";
          assets = mkEnableOption "asset tracking and management";
        };
      };
      user-provisioning = {
        enable = mkEnableOption "automated user provisioning" // {default = true;};
        identity-provider = mkOption {
          type = types.enum ["active-directory" "azure-ad" "google-workspace" "okta" "auth0" "ldap"];
          default = "active-directory";
          description = "Identity provider for user authentication";
        };
        sso = {
          enable = mkEnableOption "single sign-on integration" // {default = true;};
          protocols = mkOption {
            type = types.listOf (types.enum ["saml" "oidc" "oauth2" "kerberos"]);
            default = ["saml" "oidc"];
            description = "SSO protocols to support";
          };
        };
        profile-management = {
          roaming-profiles = mkEnableOption "roaming user profiles";
          folder-redirection = mkEnableOption "folder redirection to network shares";
          preferences = mkEnableOption "centralized user preferences";
          applications = mkEnableOption "per-user application deployment";
        };
      };
      software-deployment = {
        enable = mkEnableOption "automated software deployment" // {default = true;};
        package-management = {
          system = mkOption {
            type = types.enum ["nix" "flatpak" "snap" "appimage"];
            default = "nix";
            description = "Primary package management system";
          };
          repositories = mkOption {
            type = types.listOf types.str;
            default = ["https://cache.nixos.org"];
            description = "Package repositories to use";
          };
          security = {
            signing = mkEnableOption "package signature verification" // {default = true;};
            scanning = mkEnableOption "package vulnerability scanning";
            approval = mkEnableOption "manual approval for new packages";
          };
        };
        application-catalog = {
          self-service = mkEnableOption "self-service application catalog";
          enterprise-apps = mkEnableOption "enterprise application repository";
          approval-workflow = mkEnableOption "application request approval workflow";
        };
        updates = {
          automatic = mkEnableOption "automatic system updates";
          schedule = mkOption {
            type = types.str;
            default = "weekly";
            description = "Update schedule (daily, weekly, monthly)";
          };
          maintenance-windows = mkEnableOption "maintenance window scheduling";
          rollback = mkEnableOption "automatic rollback on failure" // {default = true;};
        };
      };
      configuration-management = {
        enable = mkEnableOption "centralized configuration management" // {default = true;};
        system = mkOption {
          type = types.enum ["ansible" "puppet" "salt" "chef" "nixos"];
          default = "nixos";
          description = "Configuration management system";
        };
        policies = {
          security = mkEnableOption "security policy enforcement" // {default = true;};
          compliance = mkEnableOption "compliance policy management" // {default = true;};
          desktop = mkEnableOption "desktop environment policies";
          networking = mkEnableOption "network configuration policies";
        };
        drift-detection = {
          enable = mkEnableOption "configuration drift detection" // {default = true;};
          remediation = mkEnableOption "automatic drift remediation";
          reporting = mkEnableOption "drift reporting and alerts";
        };
      };
      remote-management = {
        enable = mkEnableOption "remote device management" // {default = true;};
        remote-access = {
          ssh = mkEnableOption "SSH remote access" // {default = true;};
          vnc = mkEnableOption "VNC remote desktop";
          rdp = mkEnableOption "RDP remote desktop";
          web-console = mkEnableOption "web-based management console";
        };
        troubleshooting = {
          remote-assistance = mkEnableOption "remote assistance capabilities";
          diagnostic-tools = mkEnableOption "remote diagnostic tools";
          log-collection = mkEnableOption "centralized log collection" // {default = true;};
        };
        power-management = {
          wake-on-lan = mkEnableOption "Wake-on-LAN support";
          remote-shutdown = mkEnableOption "remote shutdown capabilities";
          scheduled-tasks = mkEnableOption "scheduled task execution";
        };
      };
      monitoring = {
        enable = mkEnableOption "workstation monitoring and analytics" // {default = true;};
        health = {
          system-health = mkEnableOption "system health monitoring" // {default = true;};
          performance = mkEnableOption "performance metrics collection";
          storage = mkEnableOption "storage usage monitoring" // {default = true;};
          network = mkEnableOption "network connectivity monitoring";
        };
        security = {
          threat-detection = mkEnableOption "endpoint threat detection";
          compliance = mkEnableOption "compliance monitoring" // {default = true;};
          vulnerability = mkEnableOption "vulnerability assessment";
        };
        user-analytics = {
          usage-patterns = mkEnableOption "application usage analytics";
          productivity = mkEnableOption "productivity metrics";
          login-patterns = mkEnableOption "login pattern analysis";
        };
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
          users.users.workstation-manager = {
            isSystemUser = true;
            group = "workstation-manager";
            home = "/var/lib/workstation-manager";
            createHome = true;
            description = "Workstation management service user";
          };
          users.groups.workstation-manager = {};
          systemd.tmpfiles.rules = [
            "d /var/lib/workstation-manager 0755 workstation-manager workstation-manager -"
            "d /var/lib/workstation-manager/policies 0755 workstation-manager workstation-manager -"
            "d /var/lib/workstation-manager/inventory 0755 workstation-manager workstation-manager -"
            "d /var/lib/workstation-manager/configs 0755 workstation-manager workstation-manager -"
            "d /var/lib/workstation-manager/logs 0755 workstation-manager workstation-manager -"
            "d /var/log/workstation-manager 0750 workstation-manager workstation-manager -"
            "d /etc/workstation-manager 0755 root root -"
          ];
          environment.systemPackages = with pkgs; [
            systemd
            dbus
            polkit
            networkmanager
            nix
            htop
            iotop
            netstat
            openssh
            git
            rsync
          ];
        })
        (lib.mkIf cfg.device-management.enable {
          systemd.services.device-inventory = {
            description = "Device inventory collection";
            wantedBy = ["multi-user.target"];
            serviceConfig = {
              Type = "oneshot";
              User = "workstation-manager";
              Group = "workstation-manager";
              ExecStart = pkgs.writeScript "device-inventory" ''
                #!/bin/bash
                INVENTORY_DIR="/var/lib/workstation-manager/inventory"
                INVENTORY_FILE="$INVENTORY_DIR/$(hostname)-$(date +%Y%m%d).json"
                if [[ "${toString cfg.device-management.inventory.hardware}" == "true" ]]; then
                {
                echo "{"
                echo "  \"timestamp\": \"$(date -Iseconds)\","
                echo "  \"hostname\": \"$(hostname)\","
                echo "  \"hardware\": {"
                echo "    \"cpu\": {"
                echo "      \"model\": \"$(lscpu | grep 'Model name' | cut -d: -f2 | xargs)\","
                echo "      \"cores\": $(nproc),"
                echo "      \"architecture\": \"$(uname -m)\""
                echo "    },"
                echo "    \"memory\": {"
                echo "      \"total\": \"$(free -h | grep Mem | awk '{print $2}')\","
                echo "      \"available\": \"$(free -h | grep Mem | awk '{print $7}')\""
                echo "    },"
                echo "    \"storage\": ["
                lsblk -J | jq '.blockdevices[] | select(.type=="disk") | {name, size, model}'
                echo "    ],"
                echo "    \"network\": ["
                ip -j link show | jq '.[] | select(.operstate=="UP") | {ifname, address}'
                echo "    ]"
                echo "  },"
                } > "$INVENTORY_FILE.tmp"
                fi
                if [[ "${toString cfg.device-management.inventory.software}" == "true" ]]; then
                {
                echo "  \"software\": {"
                echo "    \"os\": {"
                echo "      \"distribution\": \"NixOS\","
                echo "      \"version\": \"$(nixos-version)\","
                echo "      \"kernel\": \"$(uname -r)\""
                echo "    },"
                echo "    \"packages\": ["
                nix-store -q --references /run/current-system | wc -l
                echo "    ],"
                echo "    \"services\": ["
                systemctl list-units --type=service --state=active --no-pager --quiet | wc -l
                echo "    ]"
                echo "  },"
                } >> "$INVENTORY_FILE.tmp"
                fi
                {
                echo "  \"status\": {"
                echo "    \"uptime\": \"$(uptime -p)\","
                echo "    \"load\": \"$(uptime | awk -F'load average:' '{print $2}')\","
                echo "    \"disk_usage\": \"$(df -h / | tail -1 | awk '{print $5}')\","
                echo "    \"last_boot\": \"$(systemctl show --value -p ActiveEnterTimestamp multi-user.target)\""
                echo "  }"
                echo "}"
                } >> "$INVENTORY_FILE.tmp"
                mv "$INVENTORY_FILE.tmp" "$INVENTORY_FILE"
                find "$INVENTORY_DIR" -name "$(hostname)-*.json" -mtime +30 -delete
              '';
            };
          };
          systemd.timers.device-inventory = {
            description = "Run device inventory daily";
            wantedBy = ["timers.target"];
            timerConfig = {
              OnCalendar = "daily";
              Persistent = true;
              RandomizedDelaySec = "1h";
            };
          };
          systemd.services.compliance-check = lib.mkIf cfg.device-management.mdm.policies.compliance {
            description = "Device compliance checking";
            wantedBy = ["multi-user.target"];
            serviceConfig = {
              Type = "oneshot";
              User = "workstation-manager";
              Group = "workstation-manager";
              ExecStart = pkgs.writeScript "compliance-check" ''
                #!/bin/bash
                COMPLIANCE_DIR="/var/lib/workstation-manager/compliance"
                COMPLIANCE_FILE="$COMPLIANCE_DIR/$(hostname)-$(date +%Y%m%d).json"
                mkdir -p "$COMPLIANCE_DIR"
                {
                echo "{"
                echo "  \"timestamp\": \"$(date -Iseconds)\","
                echo "  \"hostname\": \"$(hostname)\","
                echo "  \"compliance_checks\": {"
                echo "    \"security\": {"
                echo "      \"firewall_enabled\": $(systemctl is-active iptables >/dev/null && echo 'true' || echo 'false'),"
                echo "      \"ssh_secure\": $(grep -q 'PermitRootLogin no' /etc/ssh/sshd_config && echo 'true' || echo 'false'),"
                echo "      \"auto_updates\": $(systemctl is-enabled system-update-check >/dev/null 2>&1 && echo 'true' || echo 'false'),"
                echo "      \"antivirus_active\": $(systemctl is-active clamav-daemon >/dev/null 2>&1 && echo 'true' || echo 'false')"
                echo "    },"
                echo "    \"configuration\": {"
                echo "      \"ntp_synchronized\": $(timedatectl status | grep -q 'synchronized: yes' && echo 'true' || echo 'false'),"
                echo "      \"disk_encryption\": $(lsblk -f | grep -q crypt && echo 'true' || echo 'false'),"
                echo "      \"audit_enabled\": $(systemctl is-active auditd >/dev/null 2>&1 && echo 'true' || echo 'false')"
                echo "    },"
                echo "    \"users\": {"
                echo "      \"no_empty_passwords\": $(awk -F: '$2 == \"\" {print $1}' /etc/shadow | wc -l | awk '{print ($1 == 0 ? "true" : "false")}')"
                echo "    }"
                echo "  }"
                echo "}"
                } > "$COMPLIANCE_FILE"
                SCORE=$(jq -r '
                .compliance_checks as $checks |
                [
                $checks.security.firewall_enabled,
                $checks.security.ssh_secure,
                $checks.security.auto_updates,
                $checks.configuration.ntp_synchronized,
                $checks.configuration.disk_encryption,
                $checks.configuration.audit_enabled,
                $checks.users.no_empty_passwords
                ] | map(select(. == true)) | length
                ' "$COMPLIANCE_FILE")
                TOTAL=7
                PERCENTAGE=$((SCORE * 100 / TOTAL))
                echo "Compliance Score: $SCORE/$TOTAL ($PERCENTAGE%)" | \
                ${pkgs.systemd}/bin/systemd-cat -t compliance-check
                if [ $PERCENTAGE -lt 80 ]; then
                echo "WARNING: Compliance score below threshold!" | \
                ${pkgs.systemd}/bin/systemd-cat -t compliance-check -p warning
                fi
              '';
            };
          };
          systemd.timers.compliance-check = lib.mkIf cfg.device-management.mdm.policies.compliance {
            description = "Run compliance check every 4 hours";
            wantedBy = ["timers.target"];
            timerConfig = {
              OnCalendar = "*:0/4";
              Persistent = true;
            };
          };
        })
        (lib.mkIf cfg.user-provisioning.enable {
          systemd.services.sso-config = lib.mkIf cfg.user-provisioning.sso.enable {
            description = "SSO configuration management";
            wantedBy = ["multi-user.target"];
            serviceConfig = {
              Type = "oneshot";
              RemainAfterExit = true;
              ExecStart = pkgs.writeScript "sso-config" ''
                #!/bin/bash
                SSO_DIR="/etc/workstation-manager/sso"
                mkdir -p "$SSO_DIR"
                if [[ " ${toString cfg.user-provisioning.sso.protocols} " =~ " saml " ]]; then
                cat > "$SSO_DIR/saml.conf" << 'EOF'
                LoadModule auth_mellon_module modules/mod_auth_mellon.so
                <Location />
                MellonEnable "info"
                MellonSPPrivateKeyFile /etc/ssl/private/saml.key
                MellonSPCertFile /etc/ssl/certs/saml.crt
                MellonSPMetadataFile /etc/saml/metadata.xml
                MellonIdPMetadataFile /etc/saml/idp-metadata.xml
                MellonEndpointPath /mellon
                MellonVariable "mail"
                MellonVariable "cn"
                MellonVariable "givenName"
                MellonVariable "sn"
                </Location>
                EOF
                fi
                if [[ " ${toString cfg.user-provisioning.sso.protocols} " =~ " oidc " ]]; then
                cat > "$SSO_DIR/oidc.conf" << 'EOF'
                OIDCProviderMetadataURL https://login.microsoftonline.com/tenant-id/v2.0/.well-known/openid_configuration
                OIDCClientID your-client-id
                OIDCClientSecret your-client-secret
                OIDCCryptoPassphrase your-crypto-passphrase
                OIDCRedirectURI https://your-domain/oidc_redirect
                OIDCScope "openid email profile"
                OIDCRemoteUserClaim email
                OIDCPassClaimsAs headers
                EOF
                fi
                echo "SSO configuration completed" | \
                ${pkgs.systemd}/bin/systemd-cat -t sso-config
              '';
            };
          };
          systemd.services.user-profile-sync = lib.mkIf cfg.user-provisioning.profile-management.roaming-profiles {
            description = "User profile synchronization";
            serviceConfig = {
              Type = "simple";
              Restart = "always";
              RestartSec = "30s";
              ExecStart = pkgs.writeScript "user-profile-sync" ''
                #!/bin/bash
                ${pkgs.inotify-tools}/bin/inotifywait -m /var/log/wtmp -e modify | \
                while read event; do
                LAST_LOGIN=$(last -1 | head -1)
                USERNAME=$(echo "$LAST_LOGIN" | awk '{print $1}')
                ACTION=$(echo "$LAST_LOGIN" | awk '{print $3}')
                if [ "$ACTION" = "still" ]; then
                echo "User $USERNAME logged in - syncing profile" | \
                ${pkgs.systemd}/bin/systemd-cat -t profile-sync
                if [ -d "/home/$USERNAME" ]; then
                rsync -av "profile-server:/profiles/$USERNAME/" "/home/$USERNAME/" || \
                echo "Profile sync failed for $USERNAME" | \
                ${pkgs.systemd}/bin/systemd-cat -t profile-sync -p err
                fi
                fi
                done
              '';
            };
          };
        })
        (lib.mkIf cfg.software-deployment.enable {
          systemd.services.package-updates = lib.mkIf cfg.software-deployment.updates.automatic {
            description = "Automatic package updates";
            serviceConfig = {
              Type = "oneshot";
              ExecStart = pkgs.writeScript "package-updates" ''
                #!/bin/bash
                UPDATE_LOG="/var/log/workstation-manager/updates-$(date +%Y%m%d).log"
                {
                echo "=== Package Update Started: $(date) ==="
                if [ "${cfg.software-deployment.package-management.system}" = "nix" ]; then
                echo "Checking NixOS channel updates..."
                nix-channel --update
                if nixos-rebuild dry-build 2>&1 | grep -q "building"; then
                echo "Updates available, applying..."
                CURRENT_GEN=$(nixos-rebuild list-generations | tail -1 | awk '{print $1}')
                echo "Current generation: $CURRENT_GEN"
                if nixos-rebuild switch; then
                echo "Update successful"
                NEW_GEN=$(nixos-rebuild list-generations | tail -1 | awk '{print $1}')
                echo "New generation: $NEW_GEN"
                sleep 10
                if systemctl is-system-running --quiet; then
                echo "System health check passed"
                else
                echo "System health check failed, considering rollback"
                if [[ "${toString cfg.software-deployment.updates.rollback}" == "true" ]]; then
                echo "Rolling back to generation $CURRENT_GEN"
                nixos-rebuild switch --rollback
                fi
                fi
                else
                echo "Update failed"
                exit 1
                fi
                else
                echo "No updates available"
                fi
                fi
                echo "=== Package Update Completed: $(date) ==="
                } >> "$UPDATE_LOG" 2>&1
                ${pkgs.systemd}/bin/systemd-cat -t package-updates < "$UPDATE_LOG"
              '';
            };
          };
          systemd.timers.package-updates = lib.mkIf cfg.software-deployment.updates.automatic {
            description = "Run package updates ${cfg.software-deployment.updates.schedule}";
            wantedBy = ["timers.target"];
            timerConfig = lib.mkMerge [
              (lib.mkIf (cfg.software-deployment.updates.schedule == "daily") {
                OnCalendar = "daily";
              })
              (lib.mkIf (cfg.software-deployment.updates.schedule == "weekly") {
                OnCalendar = "weekly";
              })
              (lib.mkIf (cfg.software-deployment.updates.schedule == "monthly") {
                OnCalendar = "monthly";
              })
              {
                Persistent = true;
                RandomizedDelaySec = "2h";
              }
            ];
          };
          systemd.services.app-catalog = lib.mkIf cfg.software-deployment.application-catalog.self-service {
            description = "Enterprise application catalog";
            wantedBy = ["multi-user.target"];
            serviceConfig = {
              Type = "simple";
              User = "workstation-manager";
              Group = "workstation-manager";
              ExecStart = pkgs.writeScript "app-catalog" ''
                #!/bin/bash
                CATALOG_DIR="/var/lib/workstation-manager/app-catalog"
                mkdir -p "$CATALOG_DIR"
                cat > "$CATALOG_DIR/catalog.json" << 'EOF'
                {
                "enterprise_applications": [
                {
                "id": "firefox-esr",
                "name": "Firefox ESR",
                "description": "Enterprise web browser",
                "category": "productivity",
                "approved": true,
                "auto_install": true,
                "package": "firefox-esr"
                },
                {
                "id": "libreoffice",
                "name": "LibreOffice",
                "description": "Office productivity suite",
                "category": "productivity",
                "approved": true,
                "auto_install": true,
                "package": "libreoffice-fresh"
                },
                {
                "id": "thunderbird",
                "name": "Thunderbird",
                "description": "Email client",
                "category": "communication",
                "approved": true,
                "auto_install": true,
                "package": "thunderbird"
                },
                {
                "id": "vscode",
                "name": "Visual Studio Code",
                "description": "Code editor",
                "category": "development",
                "approved": true,
                "auto_install": false,
                "package": "vscode"
                }
                ]
                }
                EOF
                echo "Application catalog updated" | \
                ${pkgs.systemd}/bin/systemd-cat -t app-catalog
                sleep infinity
              '';
            };
          };
        })
        (lib.mkIf cfg.remote-management.enable {
          services.openssh = lib.mkIf cfg.remote-management.remote-access.ssh {
            enable = true;
            settings = {
              PermitRootLogin = "no";
              PasswordAuthentication = false;
              PubkeyAuthentication = true;
              X11Forwarding = false;
              AllowAgentForwarding = false;
              ClientAliveInterval = 300;
              ClientAliveCountMax = 2;
              MaxAuthTries = 3;
              MaxSessions = 5;
              LogLevel = "VERBOSE";
            };
          };
          services.x11vnc = lib.mkIf cfg.remote-management.remote-access.vnc {
            enable = true;
            display = 0;
            localhost = false;
            auth = "/var/run/lightdm/root/:0";
            rfbauth = "/etc/x11vnc.pass";
          };
          systemd.services.wake-on-lan = lib.mkIf cfg.remote-management.power-management.wake-on-lan {
            description = "Configure Wake-on-LAN";
            wantedBy = ["multi-user.target"];
            serviceConfig = {
              Type = "oneshot";
              RemainAfterExit = true;
              ExecStart = pkgs.writeScript "wake-on-lan-setup" ''
                #!/bin/bash
                for interface in $(ip link show | grep -E '^[0-9]+:' | awk -F': ' '{print $2}' | grep -v lo); do
                if ethtool "$interface" 2>/dev/null | grep -q "Supports Wake-on: g"; then
                ethtool -s "$interface" wol g
                echo "Wake-on-LAN enabled for $interface" | \
                ${pkgs.systemd}/bin/systemd-cat -t wake-on-lan
                fi
                done
              '';
            };
          };
          systemd.services.log-collector = lib.mkIf cfg.remote-management.troubleshooting.log-collection {
            description = "Centralized log collection";
            wantedBy = ["multi-user.target"];
            serviceConfig = {
              Type = "simple";
              Restart = "always";
              RestartSec = "60s";
              ExecStart = pkgs.writeScript "log-collector" ''
                #!/bin/bash
                LOG_SERVER="log-server.enterprise.local"
                LOG_PORT="514"
                journalctl -f --output=json | \
                while read -r line; do
                echo "$line" | nc "$LOG_SERVER" "$LOG_PORT" || \
                echo "Failed to send log to $LOG_SERVER" >&2
                done
              '';
            };
          };
        })
        (lib.mkIf cfg.monitoring.enable {
          systemd.services.workstation-health = lib.mkIf cfg.monitoring.health.system-health {
            description = "Workstation health monitoring";
            wantedBy = ["multi-user.target"];
            serviceConfig = {
              Type = "simple";
              Restart = "always";
              RestartSec = "60s";
              ExecStart = pkgs.writeScript "workstation-health" ''
                #!/bin/bash
                while true; do
                HEALTH_DIR="/var/lib/workstation-manager/health"
                mkdir -p "$HEALTH_DIR"
                TIMESTAMP=$(date -Iseconds)
                HEALTH_FILE="$HEALTH_DIR/health-$(date +%Y%m%d-%H%M).json"
                {
                echo "{"
                echo "  \"timestamp\": \"$TIMESTAMP\","
                echo "  \"hostname\": \"$(hostname)\","
                echo "  \"system\": {"
                echo "    \"uptime\": \"$(uptime -p)\","
                echo "    \"load_avg\": \"$(uptime | awk -F'load average:' '{print $2}' | xargs)\","
                echo "    \"cpu_usage\": $(top -bn1 | grep "Cpu(s)" | awk '{print $2}' | cut -d'%' -f1),"
                echo "    \"memory_usage\": $(free | grep Mem | awk '{printf \"%.1f\", $3/$2 * 100.0}'),"
                echo "    \"disk_usage\": \"$(df -h / | tail -1 | awk '{print $5}' | sed 's/%//')\""
                echo "  },"
                echo "  \"services\": {"
                echo "    \"ssh\": \"$(systemctl is-active sshd)\","
                echo "    \"network\": \"$(systemctl is-active NetworkManager)\","
                echo "    \"firewall\": \"$(systemctl is-active iptables)\","
                echo "    \"audit\": \"$(systemctl is-active auditd)\""
                echo "  },"
                echo "  \"network\": {"
                echo "    \"interfaces\": $(ip -j link show | jq '[.[] | select(.operstate=="UP") | {ifname, operstate}]'),"
                echo "    \"connectivity\": $(ping -c 1 8.8.8.8 >/dev/null 2>&1 && echo '"ok"' || echo '"failed"')"
                echo "  }"
                echo "}"
                } > "$HEALTH_FILE"
                CPU_USAGE=$(jq -r '.system.cpu_usage' "$HEALTH_FILE")
                MEMORY_USAGE=$(jq -r '.system.memory_usage' "$HEALTH_FILE")
                DISK_USAGE=$(jq -r '.system.disk_usage' "$HEALTH_FILE")
                if (( $(echo "$CPU_USAGE > 90" | bc -l) )); then
                echo "HIGH CPU USAGE: $CPU_USAGE%" | \
                ${pkgs.systemd}/bin/systemd-cat -t workstation-health -p warning
                fi
                if (( $(echo "$MEMORY_USAGE > 90" | bc -l) )); then
                echo "HIGH MEMORY USAGE: $MEMORY_USAGE%" | \
                ${pkgs.systemd}/bin/systemd-cat -t workstation-health -p warning
                fi
                if [ "$DISK_USAGE" -gt 90 ]; then
                echo "HIGH DISK USAGE: $DISK_USAGE%" | \
                ${pkgs.systemd}/bin/systemd-cat -t workstation-health -p err
                fi
                find "$HEALTH_DIR" -name "health-*.json" -mtime +7 -delete
                sleep 300
                done
              '';
            };
          };
          systemd.services.security-monitor = lib.mkIf cfg.monitoring.security.threat-detection {
            description = "Workstation security monitoring";
            wantedBy = ["multi-user.target"];
            serviceConfig = {
              Type = "simple";
              Restart = "always";
              RestartSec = "30s";
              ExecStart = pkgs.writeScript "security-monitor" ''
                #!/bin/bash
                journalctl -f | grep -E "(Failed|Denied|Invalid|Error)" | \
                while read -r line; do
                if echo "$line" | grep -q "Failed password"; then
                echo "SECURITY ALERT: Failed login attempt - $line" | \
                ${pkgs.systemd}/bin/systemd-cat -t security-monitor -p warning
                elif echo "$line" | grep -q "Invalid user"; then
                echo "SECURITY ALERT: Invalid user login attempt - $line" | \
                ${pkgs.systemd}/bin/systemd-cat -t security-monitor -p err
                elif echo "$line" | grep -q "Permission denied"; then
                echo "SECURITY EVENT: Permission denied - $line" | \
                ${pkgs.systemd}/bin/systemd-cat -t security-monitor -p info
                fi
                done
              '';
            };
          };
        })
      ];
    dependencies = ["core" "security" "desktop"];
  }) {
    inherit config lib pkgs inputs;
  }
