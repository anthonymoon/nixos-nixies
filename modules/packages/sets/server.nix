{
  config,
  lib,
  pkgs,
  inputs,
  ...
}: let
  unified-lib = import ../../../lib {inherit inputs lib;};
in
  (unified-lib.mkUnifiedModule {
    name = "packages-server";
    description = "Server applications and services for hosting, virtualization, and network services";
    category = "packages";
    options = with lib; {
      enable = mkEnableOption "server package set";
      containers = {
        enable = mkEnableOption "container runtime and orchestration" // {default = true;};
        docker = {
          enable = mkEnableOption "Docker container platform" // {default = true;};
          compose = mkEnableOption "Docker Compose orchestration" // {default = true;};
          buildx = mkEnableOption "Docker Buildx multi-platform builds";
          registry = mkEnableOption "local Docker registry";
        };
        podman = {
          enable = mkEnableOption "Podman rootless containers";
          compose = mkEnableOption "Podman Compose compatibility";
          kubernetes = mkEnableOption "Podman Kubernetes integration";
        };
        kubernetes = {
          enable = mkEnableOption "Kubernetes container orchestration";
          k3s = mkEnableOption "K3s lightweight Kubernetes";
          tools = mkEnableOption "Kubernetes management tools";
        };
      };
      virtualization = {
        enable = mkEnableOption "virtualization platforms";
        libvirtd = {
          enable = mkEnableOption "libvirt virtualization management" // {default = true;};
          qemu = mkEnableOption "QEMU virtual machines" // {default = true;};
          networking = mkEnableOption "virtual networking support" // {default = true;};
          storage = mkEnableOption "virtual storage management";
        };
        virt-manager = mkEnableOption "Virtual Machine Manager GUI";
        vagrant = mkEnableOption "Vagrant development environments";
        virtualbox = mkEnableOption "VirtualBox virtualization";
      };
      media-server = {
        enable = mkEnableOption "media server applications";
        qbittorrent = {
          enable = mkEnableOption "qBittorrent torrent client" // {default = true;};
          web-ui = mkEnableOption "qBittorrent web interface" // {default = true;};
          vpn-binding = mkEnableOption "VPN interface binding";
        };
        jellyfin = mkEnableOption "Jellyfin media server";
        plex = mkEnableOption "Plex media server";
        emby = mkEnableOption "Emby media server";
        arr-stack = {
          enable = mkEnableOption "*arr media automation stack" // {default = true;};
          sonarr = mkEnableOption "Sonarr TV series management" // {default = true;};
          radarr = mkEnableOption "Radarr movie management" // {default = true;};
          prowlarr = mkEnableOption "Prowlarr indexer manager" // {default = true;};
          bazarr = mkEnableOption "Bazarr subtitle management";
          lidarr = mkEnableOption "Lidarr music management";
          readarr = mkEnableOption "Readarr ebook management";
        };
      };
      file-sharing = {
        enable = mkEnableOption "file sharing services";
        smb = {
          enable = mkEnableOption "SMB/CIFS file sharing" // {default = true;};
          server = mkEnableOption "Samba SMB server" // {default = true;};
          client = mkEnableOption "SMB client tools";
          time-machine = mkEnableOption "macOS Time Machine support";
        };
        wsdd = {
          enable = mkEnableOption "Windows Service Discovery Daemon" // {default = true;};
          workgroup = mkOption {
            type = types.str;
            default = "WORKGROUP";
            description = "SMB workgroup name";
          };
        };
        nfs = mkEnableOption "Network File System (NFS)";
        ftp = mkEnableOption "FTP server";
        sftp = mkEnableOption "SFTP server";
      };
      web-services = {
        enable = mkEnableOption "web server and related services";
        nginx = mkEnableOption "Nginx web server";
        apache = mkEnableOption "Apache HTTP server";
        caddy = mkEnableOption "Caddy web server with automatic HTTPS";
        reverse-proxy = mkEnableOption "reverse proxy configuration";
        ssl-certificates = mkEnableOption "automatic SSL certificate management";
      };
      databases = {
        enable = mkEnableOption "database servers";
        postgresql = mkEnableOption "PostgreSQL database";
        mysql = mkEnableOption "MySQL/MariaDB database";
        mongodb = mkEnableOption "MongoDB document database";
        redis = mkEnableOption "Redis key-value store";
        sqlite = mkEnableOption "SQLite embedded database" // {default = true;};
      };
      monitoring = {
        enable = mkEnableOption "monitoring and observability tools";
        prometheus = mkEnableOption "Prometheus metrics collection";
        grafana = mkEnableOption "Grafana dashboards";
        loki = mkEnableOption "Loki log aggregation";
        node-exporter = mkEnableOption "Prometheus Node Exporter";
        uptime = mkEnableOption "uptime monitoring tools";
        log-analysis = mkEnableOption "log analysis and aggregation";
      };
      security = {
        enable = mkEnableOption "security and hardening tools" // {default = true;};
        fail2ban = mkEnableOption "Fail2ban intrusion prevention" // {default = true;};
        ufw = mkEnableOption "Uncomplicated Firewall";
        iptables = mkEnableOption "iptables firewall rules";
        vpn = {
          wireguard = mkEnableOption "WireGuard VPN server";
          openvpn = mkEnableOption "OpenVPN server";
          tailscale = mkEnableOption "Tailscale mesh VPN";
        };
      };
    };
    config = {
      cfg,
      config,
      lib,
      pkgs,
    }:
      lib.mkIf cfg.enable {
        environment.systemPackages = with pkgs;
          lib.flatten [
            (lib.optionals cfg.containers.docker.enable [
              docker
            ])
            (lib.optionals cfg.containers.docker.compose [
              docker-compose
            ])
            (lib.optionals cfg.containers.docker.buildx [
              docker-buildx
            ])
            (lib.optionals cfg.containers.podman.enable [
              podman
              podman-compose
              buildah
              skopeo
            ])
            (lib.optionals cfg.containers.kubernetes.tools [
              kubectl
              kubernetes-helm
              k9s
              stern
            ])
            (lib.optionals cfg.virtualization.libvirtd.enable [
              libvirt
              qemu
              qemu_kvm
            ])
            (lib.optionals cfg.virtualization.virt-manager [
              virt-manager
              virt-viewer
            ])
            (lib.optionals cfg.virtualization.vagrant [
              vagrant
            ])
            (lib.optionals cfg.media-server.qbittorrent.enable [
              qbittorrent-nox
            ])
            (lib.optionals cfg.media-server.jellyfin [
              jellyfin
              jellyfin-web
              jellyfin-ffmpeg
            ])
            (lib.optionals cfg.media-server.arr-stack.sonarr [
              sonarr
            ])
            (lib.optionals cfg.media-server.arr-stack.radarr [
              radarr
            ])
            (lib.optionals cfg.media-server.arr-stack.prowlarr [
              prowlarr
            ])
            (lib.optionals cfg.media-server.arr-stack.bazarr [
              bazarr
            ])
            (lib.optionals cfg.file-sharing.smb.enable [
              samba
              cifs-utils
            ])
            (lib.optionals cfg.file-sharing.wsdd.enable [
              wsdd
            ])
            (lib.optionals cfg.file-sharing.nfs [
              nfs-utils
            ])
            (lib.optionals cfg.web-services.nginx [
              nginx
            ])
            (lib.optionals cfg.web-services.apache [
              httpd
            ])
            (lib.optionals cfg.web-services.caddy [
              caddy
            ])
            (lib.optionals cfg.databases.postgresql [
              postgresql
              pgcli
            ])
            (lib.optionals cfg.databases.mysql [
              mariadb
              mycli
            ])
            (lib.optionals cfg.databases.mongodb [
              mongodb
            ])
            (lib.optionals cfg.databases.redis [
              redis
            ])
            (lib.optionals cfg.databases.sqlite [
              sqlite
              sqlitebrowser
            ])
            (lib.optionals cfg.monitoring.prometheus [
              prometheus
            ])
            (lib.optionals cfg.monitoring.grafana [
              grafana
            ])
            (lib.optionals cfg.monitoring.node-exporter [
              prometheus-node-exporter
            ])
            (lib.optionals cfg.security.fail2ban [
              fail2ban
            ])
            (lib.optionals cfg.security.ufw [
              ufw
            ])
            (lib.optionals cfg.security.vpn.wireguard [
              wireguard-tools
            ])
            (lib.optionals cfg.security.vpn.openvpn [
              openvpn
            ])
            (lib.optionals cfg.security.vpn.tailscale [
              tailscale
            ])
            [
              htop
              iotop
              netdata
              rsync
              screen
              tmux
              wget
              curl
              git
              vim
              nano
            ]
          ];
        virtualisation = lib.mkMerge [
          (lib.mkIf cfg.containers.docker.enable {
            docker = {
              enable = true;
              enableOnBoot = true;
              autoPrune = {
                enable = true;
                dates = "weekly";
              };
            };
          })
          (lib.mkIf cfg.containers.podman.enable {
            podman = {
              enable = true;
              dockerCompat = true;
              defaultNetwork.settings.dns_enabled = true;
              autoPrune = {
                enable = true;
                dates = "weekly";
              };
            };
            containers.enable = true;
          })
          (lib.mkIf cfg.virtualization.libvirtd.enable {
            libvirtd = {
              enable = true;
              qemu = {
                package = pkgs.qemu_kvm;
                runAsRoot = false;
                swtpm.enable = true;
                ovmf.enable = true;
              };
            };
          })
        ];
        services = lib.mkMerge [
          (lib.mkIf cfg.file-sharing.smb.server {
            samba = {
              enable = true;
              openFirewall = true;
              settings = {
                global = {
                  workgroup = cfg.file-sharing.wsdd.workgroup;
                  "server string" = "NixOS SMB Server";
                  "netbios name" = "nixos-server";
                  security = "user";
                  "hosts allow" = "192.168. 127.";
                  "guest account" = "nobody";
                  "map to guest" = "bad user";
                };
              };
            };
          })
          (lib.mkIf cfg.file-sharing.wsdd.enable {
            wsdd = {
              enable = true;
              openFirewall = true;
              workgroup = cfg.file-sharing.wsdd.workgroup;
            };
          })
          (lib.mkIf cfg.web-services.nginx {
            nginx = {
              enable = true;
              recommendedTlsSettings = true;
              recommendedOptimisation = true;
              recommendedGzipSettings = true;
              recommendedProxySettings = true;
            };
          })
          (lib.mkIf cfg.databases.postgresql {
            postgresql = {
              enable = true;
              package = pkgs.postgresql_16;
              enableTCPIP = true;
              authentication = ''                \n            local all all trust\n            host all all 127.0.0.1/32 trust\n            host all all ::1/128 trust
              '';
            };
          })
          (lib.mkIf cfg.databases.redis {
            redis.servers.default = {
              enable = true;
              bind = "127.0.0.1";
              port = 6379;
            };
          })
          (lib.mkIf cfg.monitoring.prometheus {
            prometheus = {
              enable = true;
              port = 9090;
              scrapeConfigs = [
                {
                  job_name = "node";
                  static_configs = [
                    {
                      targets = ["localhost:9100"];
                    }
                  ];
                }
              ];
            };
          })
          (lib.mkIf cfg.monitoring.node-exporter {
            prometheus.exporters.node = {
              enable = true;
              port = 9100;
              enabledCollectors = [
                "systemd"
                "processes"
                "cpu"
                "diskstats"
                "filesystem"
                "loadavg"
                "meminfo"
                "netdev"
                "stat"
              ];
            };
          })
          (lib.mkIf cfg.monitoring.grafana {
            grafana = {
              enable = true;
              settings = {
                server = {
                  http_addr = "127.0.0.1";
                  http_port = 3000;
                };
              };
            };
          })
          (lib.mkIf cfg.security.fail2ban {
            fail2ban = {
              enable = true;
              maxretry = 3;
              bantime = "1h";
              ignoreIP = [
                "127.0.0.0/8"
                "10.0.0.0/8"
                "192.168.0.0/16"
                "172.16.0.0/12"
              ];
            };
          })
          (lib.mkIf cfg.security.vpn.tailscale {
            tailscale.enable = true;
          })
        ];
        networking.firewall = {
          allowedTCPPorts = lib.flatten [
            (lib.optionals cfg.web-services.nginx [80 443])
            (lib.optionals cfg.web-services.apache [80 443])
            (lib.optionals cfg.web-services.caddy [80 443])
            (lib.optionals cfg.file-sharing.smb.enable [139 445])
            (lib.optionals cfg.file-sharing.nfs [111 2049])
            (lib.optionals cfg.media-server.jellyfin [8096 8920])
            (lib.optionals cfg.media-server.qbittorrent.web-ui [8080])
            (lib.optionals cfg.monitoring.prometheus [9090])
            (lib.optionals cfg.monitoring.grafana [3000])
            (lib.optionals cfg.monitoring.node-exporter [9100])
            (lib.optionals cfg.databases.postgresql [5432])
            (lib.optionals cfg.databases.mysql [3306])
            (lib.optionals cfg.databases.redis [6379])
          ];
          allowedUDPPorts = lib.flatten [
            (lib.optionals cfg.file-sharing.smb.enable [137 138])
            (lib.optionals cfg.file-sharing.wsdd.enable [3702])
            (lib.optionals cfg.security.vpn.wireguard [51820])
          ];
        };
        users.extraGroups = lib.mkMerge [
          (lib.mkIf cfg.containers.docker.enable {
            docker = {};
          })
          (lib.mkIf cfg.virtualization.libvirtd.enable {
            libvirtd = {};
            kvm = {};
          })
        ];
        environment.variables = {
          SERVER_MODE = "1";
          CONTAINER_RUNTIME =
            if cfg.containers.docker.enable
            then "docker"
            else if cfg.containers.podman.enable
            then "podman"
            else "none";
        };
      };
    dependencies = ["core" "security"];
  }) {
    inherit config lib pkgs inputs;
  }
