{
  self,
  inputs,
  ...
}: {
  flake.nixosConfigurations = let
    lib = inputs.nixpkgs.lib;
    system = "x86_64-linux";

    # Import unified library
    unified-lib = import ../lib {
      inherit inputs;
      inherit (inputs.nixpkgs) lib;
    };

    # Standard modules for all configurations
    commonModules = [
      ../modules/core
      inputs.home-manager.nixosModules.home-manager
    ];

    # Common configuration
    commonConfig = {
      # Use unified library
      _module.args.unified-lib = unified-lib;

      # Home Manager integration
      home-manager = {
        useGlobalPkgs = true;
        useUserPackages = true;
        extraSpecialArgs = {
          inherit inputs;
          unified-lib = unified-lib;
        };
      };

      # System basics
      system.stateVersion = "24.11";
      nixpkgs.config.allowUnfree = true;
    };
  in {
    # Workstation configuration
    workstation = unified-lib.mkSystem {
      hostname = "workstation";
      inherit system;
      profiles = ["workstation"];
      modules =
        commonModules
        ++ [
          commonConfig
          {
            # Workstation-specific configuration
            unified = {
              core = {
                enable = true;
                security.level = "standard";
              };

              niri = {
                enable = true;
                session.displayManager = "greetd";
                features = {
                  xwayland = true;
                  screensharing = true;
                  clipboard = true;
                  notifications = true;
                };
              };

              gaming = {
                enable = lib.mkDefault false;
                steam.enable = lib.mkDefault false;
              };
            };

            # Users
            users.users = {
              workstation-user = {
                isNormalUser = true;
                extraGroups = ["wheel" "networkmanager" "audio" "video"];
                hashedPassword = "$6$rounds=4096$salt$workstation"; # Change this!
              };
            };

            # Home Manager
            home-manager.users.workstation-user = ../profiles/home/workstation.nix;
          }
        ];
    };

    # Server configuration
    server = unified-lib.mkSystem {
      hostname = "server";
      inherit system;
      profiles = ["base"];
      modules =
        commonModules
        ++ [
          commonConfig
          {
            # Server-specific configuration
            unified.core = {
              enable = true;
              security.level = "hardened";
            };

            # No desktop environment
            services.openssh.enable = true;

            # Server users
            users.users = {
              server-user = {
                isNormalUser = true;
                extraGroups = ["wheel"];
                hashedPassword = "$6$rounds=4096$salt$server"; # Change this!
              };
            };

            # Minimal packages
            environment.systemPackages = with inputs.nixpkgs.legacyPackages.${system}; [
              htop
              git
              curl
              wget
            ];
          }
        ];
    };

    # Development configuration
    development = unified-lib.mkSystem {
      hostname = "development";
      inherit system;
      profiles = ["workstation"];
      modules =
        commonModules
        ++ [
          commonConfig
          {
            # Development-specific configuration
            unified = {
              core = {
                enable = true;
                security.level = "standard";
              };

              niri.enable = true;

              development = {
                enable = true;
                languages = {
                  nix = true;
                  rust = true;
                  nodejs = true;
                  python = true;
                };
                editors = {
                  vscode = true;
                  helix = true;
                };
                tools = {
                  git = true;
                  docker = true;
                };
              };
            };

            # Development users
            users.users = {
              developer = {
                isNormalUser = true;
                extraGroups = ["wheel" "networkmanager" "docker" "libvirtd"];
                hashedPassword = "$6$rounds=4096$salt$developer"; # Change this!
              };
            };

            # Development services
            virtualisation.docker.enable = true;
            virtualisation.libvirtd.enable = true;

            # Home Manager
            home-manager.users.developer = ../profiles/home/development.nix;
          }
        ];
    };

    # Base/minimal configuration
    base = unified-lib.mkSystem {
      hostname = "base";
      inherit system;
      profiles = ["base"];
      modules =
        commonModules
        ++ [
          commonConfig
          {
            # Minimal configuration
            unified.core = {
              enable = true;
              security.level = "basic";
            };

            # Basic user
            users.users = {
              base-user = {
                isNormalUser = true;
                extraGroups = ["wheel"];
                hashedPassword = "$6$rounds=4096$salt$base"; # Change this!
              };
            };

            # Essential packages only
            environment.systemPackages = with inputs.nixpkgs.legacyPackages.${system}; [
              vim
              git
              curl
            ];
          }
        ];
    };

    # Gaming configuration
    gaming = unified-lib.mkSystem {
      hostname = "gaming";
      inherit system;
      profiles = ["workstation"];
      modules =
        commonModules
        ++ [
          commonConfig
          {
            # Gaming-optimized configuration
            unified = {
              core = {
                enable = true;
                security.level = "standard";
              };

              niri.enable = true;

              gaming = {
                enable = true;
                steam = {
                  enable = true;
                  proton.enable = true;
                };
                performance = {
                  gamemode = true;
                  mangohud = true;
                };
                streaming = {
                  enable = true;
                  obs = true;
                };
              };
            };

            # Gaming user
            users.users = {
              gamer = {
                isNormalUser = true;
                extraGroups = ["wheel" "networkmanager" "audio" "video" "gamemode"];
                hashedPassword = "$6$rounds=4096$salt$gamer"; # Change this!
              };
            };

            # Home Manager
            home-manager.users.gamer = ../profiles/home/gaming.nix;
          }
        ];
    };

    # QEMU VM Configurations
    qemu-minimal = unified-lib.mkSystem {
      hostname = "nixos-qemu-minimal";
      inherit system;
      profiles = ["qemu"];
      modules =
        commonModules
        ++ [
          commonConfig
          ../configurations/qemu/minimal.nix
        ];
    };

    qemu-desktop = unified-lib.mkSystem {
      hostname = "nixos-qemu-desktop";
      inherit system;
      profiles = ["qemu"];
      modules =
        commonModules
        ++ [
          commonConfig
          ../configurations/qemu/desktop.nix
        ];
    };

    qemu-development = unified-lib.mkSystem {
      hostname = "nixos-qemu-dev";
      inherit system;
      profiles = ["qemu"];
      modules =
        commonModules
        ++ [
          commonConfig
          ../configurations/qemu/development.nix
        ];
    };

    # Enterprise workstation configuration
    enterprise-workstation = unified-lib.mkSystem {
      hostname = "enterprise-workstation";
      inherit system;
      profiles = ["enterprise-workstation"];
      modules =
        commonModules
        ++ [
          commonConfig
          {
            # Enterprise workstation specific configuration
            unified = {
              core = {
                enable = true;
                security.level = "hardened";
                performance.enable = true;
                stability.channel = "stable";
              };

              desktop = {
                enterprise = {
                  enable = true;
                  environment.type = "gnome";
                  environment.theme.corporate-branding = true;
                  productivity.office-suite = "libreoffice";
                  communication.email-client = "thunderbird";
                  development.enable = true;
                  security.password-manager = "keepassxc";
                  remote-work.enable = true;
                };
              };

              security = {
                workstation = {
                  enable = true;
                  endpoint-protection.enable = true;
                  data-loss-prevention.enable = true;
                  access-control.smart-card = true;
                  application-security.sandboxing = true;
                  compliance.frameworks = ["SOC2" "ISO27001" "NIST"];
                };
              };

              deployment = {
                workstation = {
                  enable = true;
                  device-management.enable = true;
                  user-provisioning.enable = true;
                  software-deployment.enable = true;
                  remote-management.enable = true;
                  monitoring.enable = true;
                };
              };
            };

            # Enterprise workstation users
            users.users = {
              enterprise-user = {
                isNormalUser = true;
                extraGroups = ["wheel" "networkmanager" "audio" "video" "input" "scanner" "lp"];
                openssh.authorizedKeys.keys = [
                  # Add enterprise user SSH keys here
                  "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIG... enterprise-user@company.com" # pragma: allowlist secret
                ];
                hashedPassword = "!"; # Disable password login
                description = "Enterprise Workstation User";
              };

              admin = {
                isNormalUser = true;
                extraGroups = ["wheel"];
                openssh.authorizedKeys.keys = [
                  # Add admin SSH keys here
                ];
                hashedPassword = "!";
                description = "Workstation Administrator";
              };
            };

            # Enterprise workstation networking
            networking = {
              hostName = "enterprise-workstation";
              domain = "enterprise.local";

              # Use DHCP for workstations (more flexible than static)
              interfaces.eth0.useDHCP = true;
              wireless.enable = true;

              # Enterprise DNS
              nameservers = ["1.1.1.2" "1.0.0.2" "208.67.222.123"];

              # Workstation firewall (more restrictive than server)
              firewall = {
                enable = true;
                allowedTCPPorts = []; # No open ports by default
                allowedUDPPorts = [];

                extraCommands = ''
                  # Allow outbound enterprise traffic
                  iptables -A OUTPUT -d 10.0.0.0/8 -j ACCEPT
                  iptables -A OUTPUT -d 172.16.0.0/12 -j ACCEPT
                  iptables -A OUTPUT -d 192.168.0.0/16 -j ACCEPT

                  # Block social media during work hours (optional)
                  # iptables -A OUTPUT -d facebook.com -p tcp --dport 443 -j REJECT
                  # iptables -A OUTPUT -d twitter.com -p tcp --dport 443 -j REJECT

                  # Log denied connections for security monitoring
                  iptables -A INPUT -j LOG --log-prefix "DENIED INPUT: "
                  iptables -A OUTPUT -j LOG --log-prefix "DENIED OUTPUT: "
                '';
              };
            };

            # Enterprise storage configuration
            fileSystems = {
              "/" = {
                device = "/dev/mapper/enterprise-root";
                fsType = "ext4";
                options = ["noatime" "nodiratime"];
              };

              "/boot" = {
                device = "/dev/sda1";
                fsType = "vfat";
              };

              "/home" = {
                device = "/dev/mapper/enterprise-home";
                fsType = "ext4";
                options = ["noatime" "nodiratime" "nodev" "nosuid"];
              };
            };

            # Enterprise environment variables
            environment.variables = {
              ENTERPRISE_WORKSTATION = "1";
              SECURITY_LEVEL = "HARDENED";
              COMPLIANCE_FRAMEWORKS = "SOC2,ISO27001,NIST";
              DESKTOP_ENVIRONMENT = "GNOME";
              DEPLOYMENT_TYPE = "workstation";
            };

            # Enterprise workstation packages
            environment.systemPackages = with inputs.nixpkgs.legacyPackages.${system}; [
              # Productivity suite
              libreoffice-fresh
              thunderbird
              firefox-esr

              # Security tools
              keepassxc
              gnupg

              # Communication
              teams-for-linux
              slack
              element-desktop
              zoom-us

              # Development tools
              vscode
              git

              # System utilities
              htop
              tree
              rsync

              # Enterprise management
              ansible

              # Monitoring
              prometheus-node-exporter
            ];
          }
        ];
    };

    # Home desktop configuration with bleeding-edge packages and gaming
    home-desktop = unified-lib.mkSystem {
      hostname = "home-desktop";
      inherit system;
      profiles = ["home-desktop"];
      modules =
        commonModules
        ++ [
          commonConfig
          {
            # Home desktop specific configuration
            unified = {
              core = {
                enable = true;
                security.level = "standard";
                performance.enable = true;
                performance.profile = "gaming";
                stability.channel = "bleeding-edge";
              };

              # Modern desktop with Niri compositor
              desktop = {
                niri = {
                  enable = true;
                  session.displayManager = "greetd";
                  features = {
                    xwayland = true;
                    screensharing = true;
                    clipboard = true;
                    notifications = true;
                    bleeding-edge = true;
                  };
                };
              };

              # Comprehensive gaming setup
              gaming = {
                enable = true;
                steam = {
                  enable = true;
                  proton.enable = true;
                  remote-play.enable = true;
                  vr.enable = true;
                };
                performance = {
                  gamemode = true;
                  mangohud = true;
                  corectrl = true;
                  latency-optimization = true;
                };
                streaming = {
                  enable = true;
                  obs = true;
                  sunshine = true;
                };
              };

              # Bleeding-edge packages and features
              bleeding-edge = {
                enable = true;
                packages = {
                  source = "nixpkgs-unstable";
                  override-stable = true;
                  categories = {
                    desktop = true;
                    development = true;
                    gaming = true;
                    media = true;
                  };
                  experimental = {
                    enable = true;
                    allow-unfree = true;
                  };
                };
                kernel.version = "latest";
                graphics.drivers = "latest";
              };

              # Development environment
              development = {
                enable = true;
                languages = {
                  rust = true;
                  python = true;
                  nodejs = true;
                  go = true;
                  java = true;
                  cpp = true;
                };
                editors = {
                  vscode = true;
                  neovim = true;
                };
                tools = {
                  git = true;
                  docker = true;
                  kubernetes = true;
                };
              };

              # Media production
              media = {
                production = {
                  enable = true;
                  video.enable = true;
                  audio.enable = true;
                  graphics.enable = true;
                  streaming.enable = true;
                };
              };
            };

            # Home desktop users
            users.users = {
              gamer = {
                isNormalUser = true;
                extraGroups = [
                  "wheel"
                  "networkmanager"
                  "audio"
                  "video"
                  "input"
                  "plugdev"
                  "gamemode"
                  "docker"
                  "libvirtd"
                ];
                shell = inputs.nixpkgs.legacyPackages.${system}.zsh;
                description = "Home Desktop Gaming User";
                # Set password with: passwd gamer
              };
            };

            # Home desktop networking
            networking = {
              hostName = "home-desktop";
              networkmanager.enable = true;

              # Gaming network optimizations
              firewall = {
                enable = true;
                allowedTCPPorts = [22 3000 8000 8080 27015 27036];
                allowedUDPPorts = [27015 27031 27036];
              };
            };

            # Performance optimizations
            powerManagement.cpuFreqGovernor = "performance";

            # Environment variables
            environment.variables = {
              HOME_DESKTOP = "1";
              GAMING_MODE = "1";
              BLEEDING_EDGE = "1";
              NIXOS_OZONE_WL = "1";
              MOZ_ENABLE_WAYLAND = "1";
            };

            # Home desktop packages
            environment.systemPackages = with inputs.nixpkgs.legacyPackages.${system}; [
              # Gaming
              steam
              lutris
              heroic
              gamemode
              mangohud

              # Development
              vscode
              git
              docker

              # Media
              obs-studio
              gimp
              blender
              kdenlive

              # Communication
              discord
              firefox

              # Utilities
              htop
              tree
              zip
            ];
          }
        ];
    };

    # Enterprise server configuration
    enterprise-server = unified-lib.mkSystem {
      hostname = "enterprise-server";
      inherit system;
      profiles = ["enterprise-server"];
      modules =
        commonModules
        ++ [
          commonConfig
          {
            # Enterprise-specific configuration
            unified = {
              core = {
                enable = true;
                security.level = "paranoid";
                performance.enable = true;
                stability.channel = "stable";
              };

              security = {
                enterprise = {
                  enable = true;
                  compliance.frameworks = ["SOC2" "CIS" "NIST"];
                  compliance.level = "hardened";
                  access-control.rbac = true;
                  network-security.ids = true;
                  data-protection.encryption-at-rest = true;
                };
              };

              monitoring = {
                enterprise = {
                  enable = true;
                  metrics.prometheus = true;
                  metrics.grafana = true;
                  logging.centralized = true;
                  alerting.severity-levels = ["critical" "warning"];
                };
              };

              deployment = {
                enterprise = {
                  enable = true;
                  orchestration.ansible = true;
                  ci-cd.jenkins = true;
                  deployment.health-checks = true;
                  infrastructure.backup = true;
                };
              };
            };

            # Enterprise users (configure with real credentials)
            users.users = {
              enterprise-admin = {
                isNormalUser = true;
                extraGroups = ["wheel" "deployment" "monitoring"];
                openssh.authorizedKeys.keys = [
                  # Add your SSH public keys here
                  "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIG... enterprise-admin@company.com" # pragma: allowlist secret
                ];
                hashedPassword = "!"; # Disable password login
                description = "Enterprise Administrator";
              };

              security-admin = {
                isNormalUser = true;
                extraGroups = ["wheel" "audit"];
                openssh.authorizedKeys.keys = [
                  # Add security team SSH keys here
                ];
                hashedPassword = "!";
                description = "Security Administrator";
              };

              monitoring-user = {
                isNormalUser = true;
                extraGroups = ["monitoring"];
                openssh.authorizedKeys.keys = [
                  # Add monitoring team SSH keys here
                ];
                hashedPassword = "!";
                description = "Monitoring User";
              };
            };

            # Enterprise network configuration
            networking = {
              hostName = "enterprise-server";
              domain = "enterprise.local";

              # Static IP configuration (customize for your environment)
              interfaces.eth0 = {
                useDHCP = false;
                ipv4.addresses = [
                  {
                    address = "10.0.1.100";
                    prefixLength = 24;
                  }
                ];
              };

              defaultGateway = "10.0.1.1";
              nameservers = ["1.1.1.1" "1.0.0.1"];

              # Enterprise firewall rules
              firewall = {
                allowedTCPPorts = [22 80 443 9090 3000 5601]; # SSH, HTTP, HTTPS, Prometheus, Grafana, Kibana
                allowedUDPPorts = [];

                extraCommands = ''
                  # Allow monitoring traffic from specific subnets
                  iptables -A INPUT -s 10.0.1.0/24 -p tcp --dport 9100 -j ACCEPT # Node exporter
                  iptables -A INPUT -s 10.0.1.0/24 -p tcp --dport 9200 -j ACCEPT # Elasticsearch

                  # Log suspicious activity
                  iptables -A INPUT -m limit --limit 5/min -j LOG --log-prefix "iptables denied: " --log-level 7
                '';
              };
            };

            # Enterprise storage configuration
            fileSystems = {
              "/" = {
                device = "/dev/mapper/enterprise-root";
                fsType = "ext4";
                options = ["noatime" "nodiratime" "discard"];
              };

              "/boot" = {
                device = "/dev/sda1";
                fsType = "vfat";
              };

              "/var/lib/monitoring" = {
                device = "/dev/mapper/enterprise-monitoring";
                fsType = "ext4";
                options = ["noatime" "nodiratime"];
              };

              "/var/log" = {
                device = "/dev/mapper/enterprise-logs";
                fsType = "ext4";
                options = ["noatime" "nodiratime"];
              };
            };

            # Enterprise environment variables
            environment.variables = {
              ENTERPRISE_MODE = "1";
              COMPLIANCE_FRAMEWORKS = "SOC2,CIS,NIST";
              DEPLOYMENT_ENVIRONMENT = "production";
              SECURITY_LEVEL = "PARANOID";
            };

            # Enterprise-specific packages
            environment.systemPackages = with inputs.nixpkgs.legacyPackages.${system}; [
              # Compliance and auditing
              aide
              lynis
              rkhunter
              chkrootkit
              openscap

              # Security tools
              nmap
              wireshark-cli
              tcpdump

              # Monitoring tools
              prometheus
              grafana

              # Deployment tools
              ansible
              terraform

              # Enterprise utilities
              rsync
              screen
              tmux
            ];
          }
        ];
    };

    # Home server configuration with bleeding-edge packages and comprehensive services
    home-server = unified-lib.mkSystem {
      hostname = "home-server";
      inherit system;
      profiles = ["home-server"];
      modules =
        commonModules
        ++ [
          commonConfig
          {
            # Home server specific configuration
            unified = {
              core = {
                enable = true;
                security.level = "balanced";
                performance.enable = true;
                performance.profile = "server";
                stability.channel = "bleeding-edge";
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
                  navidrome = true;
                  photoprism = true;
                  plex = true;
                };

                # Cloud and productivity services
                cloud = {
                  enable = true;
                  nextcloud = true;
                  vaultwarden = true;
                  paperless = true;
                  bookstack = true;
                  freshrss = true;
                };

                # Home automation
                automation = {
                  enable = true;
                  home-assistant = true;
                  node-red = true;
                  mosquitto = true;
                  zigbee2mqtt = true;
                  esphome = true;
                };

                # Development services
                development = {
                  enable = true;
                  gitea = true;
                  drone = true;
                  registry = true;
                  database-cluster = true;
                  redis-cluster = true;
                };

                # Network services
                network = {
                  enable = true;
                  pihole = true;
                  unbound = true;
                  wireguard = true;
                  tailscale = true;
                  nginx-proxy = true;
                };

                # Monitoring and observability
                monitoring = {
                  enable = true;
                  prometheus = true;
                  grafana = true;
                  loki = true;
                  uptime-kuma = true;
                  ntopng = true;
                };

                # Backup and sync services
                backup = {
                  enable = true;
                  restic = true;
                  borgbackup = true;
                  syncthing = true;
                  duplicacy = true;
                };
              };

              # Bleeding-edge packages and features
              bleeding-edge = {
                enable = true;
                packages = {
                  source = "nixpkgs-unstable";
                  override-stable = true;
                  categories = {
                    system = true;
                    development = true;
                  };
                  experimental = {
                    enable = true;
                    allow-unfree = true;
                  };
                };
                kernel.version = "latest";
                graphics.drivers = "latest";
              };

              # Container orchestration
              containers = {
                enable = true;
                runtime = "podman";
                kubernetes = {
                  enable = true;
                  distribution = "k3s";
                };
                docker-compatibility = true;
                registry = true;
              };
            };

            # Home server users
            users.users = {
              homeserver = {
                isNormalUser = true;
                extraGroups = [
                  "wheel"
                  "networkmanager"
                  "docker"
                  "podman"
                  "media"
                  "backup"
                  "monitoring"
                ];
                shell = inputs.nixpkgs.legacyPackages.${system}.zsh;
                description = "Home Server Administrator";
                openssh.authorizedKeys.keys = [
                  # Add your SSH public keys here
                  # "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIG... homeserver@example.com" # pragma: allowlist secret
                ];
              };

              media = {
                isSystemUser = true;
                group = "media";
                home = "/var/lib/media";
                createHome = true;
                description = "Media services user";
              };

              automation = {
                isSystemUser = true;
                group = "automation";
                home = "/var/lib/automation";
                createHome = true;
                description = "Home automation user";
              };
            };

            users.groups = {
              media = {gid = 2001;};
              backup = {gid = 2002;};
              monitoring = {gid = 2003;};
              automation = {gid = 2004;};
            };

            # Home server networking
            networking = {
              hostName = "home-server";
              networkmanager.enable = false; # Use systemd-networkd for servers
              useNetworkd = true;
              useDHCP = false;

              # Configure your network interface (adjust as needed)
              interfaces.enp1s0 = {
                useDHCP = true;
                # Or use static IP:
                # useDHCP = false;
                # ipv4.addresses = [
                #   {
                #     address = "192.168.1.100";
                #     prefixLength = 24;
                #   }
                # ];
              };

              # Server firewall configuration
              firewall = {
                enable = true;
                allowedTCPPorts = [
                  22 # SSH
                  80 # HTTP
                  443 # HTTPS
                  8080 # Alternative HTTP
                  9090 # Prometheus
                  3000 # Grafana
                  8096 # Jellyfin
                  8920 # Jellyfin HTTPS
                  4533 # Navidrome
                  2283 # Immich
                  8123 # Home Assistant
                  1880 # Node-RED
                  3001 # Gitea
                  5432 # PostgreSQL (local network only)
                  6379 # Redis (local network only)
                  51820 # WireGuard
                ];
                allowedUDPPorts = [
                  51820 # WireGuard
                  1900 # UPnP/DLNA
                  7359 # DLNA
                ];

                # Allow local network access to services
                extraCommands = ''
                  # Allow local network to access database services
                  iptables -A INPUT -s 192.168.0.0/16 -p tcp --dport 5432 -j ACCEPT
                  iptables -A INPUT -s 10.0.0.0/8 -p tcp --dport 5432 -j ACCEPT
                  iptables -A INPUT -s 192.168.0.0/16 -p tcp --dport 6379 -j ACCEPT
                  iptables -A INPUT -s 10.0.0.0/8 -p tcp --dport 6379 -j ACCEPT

                  # Allow DLNA/UPnP discovery
                  iptables -A INPUT -p udp --dport 1900 -j ACCEPT
                  iptables -A INPUT -p udp --dport 7359 -j ACCEPT
                '';
              };

              # DNS configuration
              nameservers = ["1.1.1.1" "1.0.0.1" "8.8.8.8"];
            };

            # Server performance optimizations
            powerManagement = {
              enable = true;
              cpuFreqGovernor = "ondemand"; # Balance performance and power
            };

            # Storage optimization for server workloads
            fileSystems."/" = {
              options = ["noatime" "nodiratime" "discard"];
            };

            # Environment variables
            environment.variables = {
              HOME_SERVER = "1";
              SELF_HOSTING = "1";
              BLEEDING_EDGE = "1";
              CONTAINER_RUNTIME = "podman";
              MEDIA_ROOT = "/var/lib/media";
              BACKUP_ROOT = "/var/lib/backup";
            };

            # Home server essential packages
            environment.systemPackages = with inputs.nixpkgs.legacyPackages.${system}; [
              # Container tools
              podman
              podman-compose
              buildah
              skopeo

              # Server utilities
              htop
              iotop
              ncdu
              tree
              rsync
              rclone

              # Network tools
              nmap
              tcpdump
              iperf3

              # Monitoring
              lm_sensors
              smartmontools

              # Backup tools
              restic
              borgbackup

              # Development
              git
              curl
              wget
              jq

              # Media tools
              ffmpeg
              mediainfo

              # System tools
              tmux
              screen
              vim

              # Container management
              dive
              lazydocker

              # Networking
              wireguard-tools
            ];

            # Enable essential services
            services = {
              # SSH with secure configuration
              openssh = {
                enable = true;
                settings = {
                  PasswordAuthentication = false;
                  PermitRootLogin = "no";
                  Protocol = 2;
                  MaxAuthTries = 3;
                  ClientAliveInterval = 60;
                  ClientAliveCountMax = 3;
                };
                extraConfig = ''
                  AllowUsers homeserver
                '';
              };

              # Fail2ban for security
              fail2ban = {
                enable = true;
                maxretry = 3;
                ignoreIP = [
                  "127.0.0.0/8"
                  "192.168.0.0/16"
                  "10.0.0.0/8"
                ];
              };

              # Automatic updates for security
              automatic-timers = {
                enable = true;
                update-interval = "weekly";
              };
            };

            # Server-specific system configuration
            boot = {
              # Kernel parameters for server optimization
              kernelParams = [
                "elevator=mq-deadline" # Better for SSDs under server load
                "vm.swappiness=10" # Reduce swapping
              ];

              kernel.sysctl = {
                # Network optimizations
                "net.core.rmem_max" = 134217728;
                "net.core.wmem_max" = 134217728;
                "net.ipv4.tcp_rmem" = "4096 87380 134217728";
                "net.ipv4.tcp_wmem" = "4096 65536 134217728";

                # File system optimizations
                "vm.dirty_ratio" = 15;
                "vm.dirty_background_ratio" = 5;
                "vm.vfs_cache_pressure" = 50;

                # Server memory management
                "vm.min_free_kbytes" = 65536;
                "vm.overcommit_memory" = 1;
              };
            };

            # Create service directories
            systemd.tmpfiles.rules = [
              "d /var/lib/media 0755 media media -"
              "d /var/lib/backup 0755 root backup -"
              "d /var/lib/monitoring 0755 root monitoring -"
              "d /var/lib/automation 0755 automation automation -"
              "d /var/lib/containers 0755 root root -"
              "d /var/log/services 0755 root root -"
            ];

            # Virtual filesystem for server
            virtualisation = {
              podman = {
                enable = true;
                dockerCompat = true;
                defaultNetwork.settings.dns_enabled = true;
              };

              containers.enable = true;
            };
          }
        ];
    };
  };
}
