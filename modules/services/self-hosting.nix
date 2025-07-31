{
  config,
  lib,
  pkgs,
  inputs,
  ...
}: let
  nixies-lib = import ../../lib {inherit inputs lib;};
in
  (nixies-lib.mkUnifiedModule {
    name = "self-hosting";
    description = "Comprehensive self-hosting services for home servers including media, cloud, automation, and development services";
    category = "services";
    options = with lib; {
      enable = mkEnableOption "self-hosting services suite";
      reverse-proxy = {
        enable = mkEnableOption "reverse proxy for service access" // {default = true;};
        provider = mkOption {
          type = types.enum ["traefik" "nginx" "caddy" "apache"];
          default = "traefik";
          description = "Reverse proxy provider";
        };
        ssl = {
          enable = mkEnableOption "SSL/TLS termination" // {default = true;};
          provider = mkOption {
            type = types.enum ["letsencrypt" "selfsigned" "custom"];
            default = "letsencrypt";
            description = "SSL certificate provider";
          };
          email = mkOption {
            type = types.str;
            default = "admin@localhost";
            description = "Email for Let's Encrypt registration";
          };
        };
        domain = mkOption {
          type = types.str;
          default = "home.local";
          description = "Base domain for services";
        };
        dashboard = mkEnableOption "proxy dashboard interface" // {default = true;};
      };
      media = {
        enable = mkEnableOption "media server services";
        jellyfin = {
          enable = mkEnableOption "Jellyfin media server";
          domain = mkOption {
            type = types.str;
            default = "jellyfin.home.local";
            description = "Domain for Jellyfin";
          };
          hardware-acceleration = mkEnableOption "hardware transcoding" // {default = true;};
          plugins = mkOption {
            type = types.listOf types.str;
            default = ["Kodi Sync Queue" "Playback Reporting"];
            description = "Jellyfin plugins to install";
          };
        };
        immich = {
          enable = mkEnableOption "Immich photo management";
          domain = mkOption {
            type = types.str;
            default = "photos.home.local";
            description = "Domain for Immich";
          };
          ai-features = mkEnableOption "AI-powered photo organization" // {default = true;};
          face-recognition = mkEnableOption "face recognition features";
        };
        navidrome = {
          enable = mkEnableOption "Navidrome music server";
          domain = mkOption {
            type = types.str;
            default = "music.home.local";
            description = "Domain for Navidrome";
          };
          transcoding = mkEnableOption "music transcoding" // {default = true;};
        };
        photoprism = {
          enable = mkEnableOption "PhotoPrism photo management";
          domain = mkOption {
            type = types.str;
            default = "photoprism.home.local";
            description = "Domain for PhotoPrism";
          };
        };
        plex = {
          enable = mkEnableOption "Plex media server";
          domain = mkOption {
            type = types.str;
            default = "plex.home.local";
            description = "Domain for Plex";
          };
          hardware-acceleration = mkEnableOption "Plex hardware transcoding";
        };
        storage = {
          movies-path = mkOption {
            type = types.str;
            default = "/srv/media/movies";
            description = "Path to movie library";
          };
          tv-path = mkOption {
            type = types.str;
            default = "/srv/media/tv";
            description = "Path to TV show library";
          };
          music-path = mkOption {
            type = types.str;
            default = "/srv/media/music";
            description = "Path to music library";
          };
          photos-path = mkOption {
            type = types.str;
            default = "/srv/media/photos";
            description = "Path to photos library";
          };
        };
      };
      cloud = {
        enable = mkEnableOption "cloud and productivity services";
        nextcloud = {
          enable = mkEnableOption "Nextcloud cloud platform";
          domain = mkOption {
            type = types.str;
            default = "cloud.home.local";
            description = "Domain for Nextcloud";
          };
          apps = mkOption {
            type = types.listOf types.str;
            default = ["calendar" "contacts" "mail" "notes" "tasks" "deck" "talk"];
            description = "Nextcloud apps to enable";
          };
          office = mkEnableOption "Collabora Online office suite";
        };
        vaultwarden = {
          enable = mkEnableOption "Vaultwarden password manager";
          domain = mkOption {
            type = types.str;
            default = "vault.home.local";
            description = "Domain for Vaultwarden";
          };
          admin-panel = mkEnableOption "admin panel access";
          backup = mkEnableOption "automated backup" // {default = true;};
        };
        paperless = {
          enable = mkEnableOption "Paperless-ngx document management";
          domain = mkOption {
            type = types.str;
            default = "documents.home.local";
            description = "Domain for Paperless";
          };
          ocr = mkEnableOption "OCR document processing" // {default = true;};
          ai-classification = mkEnableOption "AI document classification";
        };
        bookstack = {
          enable = mkEnableOption "BookStack wiki platform";
          domain = mkOption {
            type = types.str;
            default = "wiki.home.local";
            description = "Domain for BookStack";
          };
        };
        freshrss = {
          enable = mkEnableOption "FreshRSS feed reader";
          domain = mkOption {
            type = types.str;
            default = "rss.home.local";
            description = "Domain for FreshRSS";
          };
        };
        storage = {
          data-path = mkOption {
            type = types.str;
            default = "/srv/data";
            description = "Base path for cloud service data";
          };
        };
      };
      automation = {
        enable = mkEnableOption "home automation services";
        home-assistant = {
          enable = mkEnableOption "Home Assistant";
          domain = mkOption {
            type = types.str;
            default = "homeassistant.home.local";
            description = "Domain for Home Assistant";
          };
          supervisor = mkEnableOption "Home Assistant Supervisor (hassos)";
          addons = mkOption {
            type = types.listOf types.str;
            default = ["ESPHome" "Node-RED" "Mosquitto"];
            description = "Home Assistant add-ons";
          };
        };
        node-red = {
          enable = mkEnableOption "Node-RED automation platform";
          domain = mkOption {
            type = types.str;
            default = "nodered.home.local";
            description = "Domain for Node-RED";
          };
          auth = mkEnableOption "authentication for Node-RED";
        };
        mosquitto = {
          enable = mkEnableOption "Mosquitto MQTT broker";
          port = mkOption {
            type = types.int;
            default = 1883;
            description = "MQTT broker port";
          };
          websockets = mkEnableOption "WebSocket support" // {default = true;};
          auth = mkEnableOption "MQTT authentication";
        };
        zigbee2mqtt = {
          enable = mkEnableOption "Zigbee2MQTT bridge";
          device = mkOption {
            type = types.str;
            default = "/dev/ttyACM0";
            description = "Zigbee coordinator device";
          };
        };
        esphome = {
          enable = mkEnableOption "ESPHome device management";
          domain = mkOption {
            type = types.str;
            default = "esphome.home.local";
            description = "Domain for ESPHome";
          };
        };
      };
      development = {
        enable = mkEnableOption "development and DevOps services";
        gitea = {
          enable = mkEnableOption "Gitea Git hosting";
          domain = mkOption {
            type = types.str;
            default = "git.home.local";
            description = "Domain for Gitea";
          };
          actions = mkEnableOption "Gitea Actions CI/CD";
          lfs = mkEnableOption "Git LFS support" // {default = true;};
        };
        drone = {
          enable = mkEnableOption "Drone CI/CD platform";
          domain = mkOption {
            type = types.str;
            default = "drone.home.local";
            description = "Domain for Drone";
          };
          gitea-integration = mkEnableOption "integrate with Gitea" // {default = true;};
        };
        registry = {
          enable = mkEnableOption "Container registry";
          domain = mkOption {
            type = types.str;
            default = "registry.home.local";
            description = "Domain for container registry";
          };
          ui = mkEnableOption "registry web UI" // {default = true;};
          garbage-collection = mkEnableOption "automatic cleanup" // {default = true;};
        };
        database-cluster = {
          enable = mkEnableOption "database cluster services";
          postgresql = mkEnableOption "PostgreSQL cluster" // {default = true;};
          mysql = mkEnableOption "MySQL/MariaDB cluster";
          mongodb = mkEnableOption "MongoDB cluster";
          redis = mkEnableOption "Redis cluster" // {default = true;};
        };
        minio = {
          enable = mkEnableOption "MinIO object storage";
          domain = mkOption {
            type = types.str;
            default = "s3.home.local";
            description = "Domain for MinIO";
          };
          console = mkEnableOption "MinIO console" // {default = true;};
        };
      };
      network = {
        enable = mkEnableOption "network services";
        pihole = {
          enable = mkEnableOption "Pi-hole DNS filtering";
          domain = mkOption {
            type = types.str;
            default = "pihole.home.local";
            description = "Domain for Pi-hole admin";
          };
          upstream-dns = mkOption {
            type = types.listOf types.str;
            default = ["1.1.1.1" "1.0.0.1"];
            description = "Upstream DNS servers";
          };
          blocklists = mkOption {
            type = types.listOf types.str;
            default = [
              "https://raw.githubusercontent.com/StevenBlack/hosts/master/hosts"
              "https://mirror1.malwaredomains.com/files/justdomains"
            ];
            description = "DNS blocklists";
          };
        };
        unbound = {
          enable = mkEnableOption "Unbound recursive DNS resolver";
          forwarders = mkOption {
            type = types.listOf types.str;
            default = ["1.1.1.1@853" "1.0.0.1@853"];
            description = "DNS-over-TLS forwarders";
          };
        };
        wireguard = {
          enable = mkEnableOption "WireGuard VPN server";
          port = mkOption {
            type = types.int;
            default = 51820;
            description = "WireGuard port";
          };
          clients = mkOption {
            type = types.int;
            default = 10;
            description = "Maximum number of clients";
          };
        };
        tailscale = {
          enable = mkEnableOption "Tailscale mesh VPN";
          subnet-router = mkEnableOption "act as subnet router";
          exit-node = mkEnableOption "act as exit node";
        };
        nginx-proxy = {
          enable = mkEnableOption "Nginx reverse proxy";
          ssl = mkEnableOption "SSL termination" // {default = true;};
          rate-limiting = mkEnableOption "rate limiting" // {default = true;};
        };
      };
      monitoring = {
        enable = mkEnableOption "monitoring and observability";
        prometheus = {
          enable = mkEnableOption "Prometheus metrics collection" // {default = true;};
          domain = mkOption {
            type = types.str;
            default = "prometheus.home.local";
            description = "Domain for Prometheus";
          };
          retention = mkOption {
            type = types.str;
            default = "30d";
            description = "Metrics retention period";
          };
        };
        grafana = {
          enable = mkEnableOption "Grafana dashboards" // {default = true;};
          domain = mkOption {
            type = types.str;
            default = "grafana.home.local";
            description = "Domain for Grafana";
          };
          plugins = mkOption {
            type = types.listOf types.str;
            default = ["grafana-piechart-panel" "grafana-worldmap-panel"];
            description = "Grafana plugins";
          };
        };
        loki = {
          enable = mkEnableOption "Loki log aggregation";
          retention = mkOption {
            type = types.str;
            default = "30d";
            description = "Log retention period";
          };
        };
        uptime-kuma = {
          enable = mkEnableOption "Uptime Kuma service monitoring";
          domain = mkOption {
            type = types.str;
            default = "status.home.local";
            description = "Domain for Uptime Kuma";
          };
        };
        ntopng = {
          enable = mkEnableOption "ntopng network monitoring";
          domain = mkOption {
            type = types.str;
            default = "network.home.local";
            description = "Domain for ntopng";
          };
        };
        exporters = {
          node = mkEnableOption "Node exporter" // {default = true;};
          cadvisor = mkEnableOption "cAdvisor container metrics";
          blackbox = mkEnableOption "Blackbox exporter for service probing";
          snmp = mkEnableOption "SNMP exporter for network devices";
        };
      };
      backup = {
        enable = mkEnableOption "backup and storage services";
        restic = {
          enable = mkEnableOption "Restic backup";
          repositories = mkOption {
            type = types.listOf types.str;
            default = ["/srv/backup/restic"];
            description = "Restic repository paths";
          };
          schedule = mkOption {
            type = types.str;
            default = "daily";
            description = "Backup schedule";
          };
          retention = mkOption {
            type = types.str;
            default = "30d";
            description = "Backup retention period";
          };
        };
        borgbackup = {
          enable = mkEnableOption "BorgBackup";
          repository = mkOption {
            type = types.str;
            default = "/srv/backup/borg";
            description = "Borg repository path";
          };
        };
        syncthing = {
          enable = mkEnableOption "Syncthing file synchronization";
          domain = mkOption {
            type = types.str;
            default = "sync.home.local";
            description = "Domain for Syncthing";
          };
        };
        rclone = {
          enable = mkEnableOption "rclone cloud storage sync";
          cloud-providers = mkOption {
            type = types.listOf types.str;
            default = ["gdrive" "dropbox" "s3"];
            description = "Cloud storage providers to configure";
          };
        };
        automated-snapshots = {
          enable = mkEnableOption "automated ZFS/Btrfs snapshots";
          frequency = mkOption {
            type = types.str;
            default = "hourly";
            description = "Snapshot frequency";
          };
          retention = mkOption {
            type = types.str;
            default = "7d";
            description = "Snapshot retention";
          };
        };
      };
      security = {
        enable = mkEnableOption "security and privacy services";
        crowdsec = {
          enable = mkEnableOption "CrowdSec intrusion prevention";
          scenarios = mkOption {
            type = types.listOf types.str;
            default = ["ssh-bf" "http-bf" "http-crawl-non_statics"];
            description = "CrowdSec scenarios to enable";
          };
        };
        authelia = {
          enable = mkEnableOption "Authelia authentication service";
          domain = mkOption {
            type = types.str;
            default = "auth.home.local";
            description = "Domain for Authelia";
          };
          totp = mkEnableOption "TOTP two-factor authentication" // {default = true;};
        };
        vault = {
          enable = mkEnableOption "HashiCorp Vault secrets management";
          domain = mkOption {
            type = types.str;
            default = "vault-secrets.home.local";
            description = "Domain for Vault";
          };
        };
        certificate-management = {
          enable = mkEnableOption "automated certificate management" // {default = true;};
          provider = mkOption {
            type = types.enum ["letsencrypt" "step-ca" "selfsigned"];
            default = "letsencrypt";
            description = "Certificate authority provider";
          };
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
          systemd.tmpfiles.rules = [
            "d /srv/selfhosting 0755 root root -"
            "d /srv/data 0755 root root -"
            "d /srv/media 0755 root root -"
            "d /srv/backup 0755 root root -"
            "d /srv/containers 0755 root root -"
            "d /var/log/selfhosting 0750 root root -"
          ];
          systemd.services.selfhosting-network = {
            description = "Create Docker network for self-hosting services";
            after = ["docker.service"];
            wantedBy = ["multi-user.target"];
            serviceConfig = {
              Type = "oneshot";
              RemainAfterExit = true;
              ExecStart = "${pkgs.docker}/bin/docker network create selfhosting || true";
              ExecStop = "${pkgs.docker}/bin/docker network rm selfhosting || true";
            };
          };
          environment.systemPackages = with pkgs; [
            docker
            docker-compose
            podman
            podman-compose
            openssl
            letsencrypt
            certbot
            curl
            wget
            jq
            restic
            borgbackup
            rclone
            prometheus
            grafana
          ];
        })
        (lib.mkIf cfg.reverse-proxy.enable {
          services.traefik = lib.mkIf (cfg.reverse-proxy.provider == "traefik") {
            enable = true;
            staticConfigOptions = {
              entryPoints = {
                web = {
                  address = ":80";
                  http.redirections.entryPoint = {
                    to = "websecure";
                    scheme = "https";
                    permanent = true;
                  };
                };
                websecure = {
                  address = ":443";
                };
              };
              certificatesResolvers = lib.mkIf cfg.reverse-proxy.ssl.enable {
                letsencrypt = lib.mkIf (cfg.reverse-proxy.ssl.provider == "letsencrypt") {
                  acme = {
                    email = cfg.reverse-proxy.ssl.email;
                    storage = "/var/lib/traefik/acme.json";
                    httpChallenge.entryPoint = "web";
                  };
                };
              };
              api = lib.mkIf cfg.reverse-proxy.dashboard {
                dashboard = true;
                insecure = false;
              };
              providers = {
                docker = {
                  endpoint = "unix:///var/run/docker.sock";
                  exposedByDefault = false;
                };
                file = {
                  directory = "/etc/traefik/dynamic";
                  watch = true;
                };
              };
              log = {
                level = "INFO";
                filePath = "/var/log/traefik/traefik.log";
              };
              accessLog = {
                filePath = "/var/log/traefik/access.log";
              };
            };
          };
          services.nginx = lib.mkIf (cfg.reverse-proxy.provider == "nginx") {
            enable = true;
            recommendedGzipSettings = true;
            recommendedOptimisation = true;
            recommendedProxySettings = true;
            recommendedTlsSettings = true;
            commonHttpConfig = ''
              limit_req_zone $binary_remote_addr zone=api:10m rate=10r/s;
              limit_req_zone $binary_remote_addr zone=login:10m rate=1r/s;
              add_header X-Frame-Options SAMEORIGIN always;
              add_header X-Content-Type-Options nosniff always;
              add_header X-XSS-Protection "1; mode=block" always;
              add_header Referrer-Policy strict-origin-when-cross-origin always;
            '';
          };
          systemd.tmpfiles.rules = [
            "d /var/log/traefik 0755 traefik traefik -"
            "d /var/lib/traefik 0755 traefik traefik -"
            "d /etc/traefik/dynamic 0755 root root -"
          ];
          networking.firewall = {
            allowedTCPPorts = [80 443];
          };
        })
        (lib.mkIf cfg.media.enable {
          services.jellyfin = lib.mkIf cfg.media.jellyfin.enable {
            enable = true;
            openFirewall = true;
            dataDir = "/srv/data/jellyfin";
            configDir = "/srv/data/jellyfin/config";
            cacheDir = "/srv/data/jellyfin/cache";
            logDir = "/srv/data/jellyfin/log";
          };
          virtualisation.oci-containers.containers.immich = lib.mkIf cfg.media.immich.enable {
            image = "ghcr.io/immich-app/immich-server:release";
            ports = ["2283:3001"];
            volumes = [
              "${cfg.media.storage.photos-path}:/usr/src/app/upload"
              "/srv/data/immich:/usr/src/app/upload/library"
            ];
            environment = {
              DB_HOSTNAME = "immich-postgres";
              DB_USERNAME = "postgres";
              DB_PASSWORD = "postgres";
              DB_DATABASE_NAME = "immich";
              REDIS_HOSTNAME = "immich-redis";
            };
            dependsOn = ["immich-postgres" "immich-redis"];
            extraOptions = [
              "--network=selfhosting"
              "--label=traefik.enable=true"
              "--label=traefik.http.routers.immich.rule=Host(`${cfg.media.immich.domain}`)"
              "--label=traefik.http.routers.immich.entrypoints=websecure"
              "--label=traefik.http.routers.immich.tls.certresolver=letsencrypt"
            ];
          };
          virtualisation.oci-containers.containers.immich-postgres = lib.mkIf cfg.media.immich.enable {
            image = "postgres:14";
            volumes = [
              "/srv/data/immich/postgres:/var/lib/postgresql/data"
            ];
            environment = {
              POSTGRES_PASSWORD = "postgres";
              POSTGRES_USER = "postgres";
              POSTGRES_DB = "immich";
            };
            extraOptions = [
              "--network=selfhosting"
            ];
          };
          virtualisation.oci-containers.containers.immich-redis = lib.mkIf cfg.media.immich.enable {
            image = "redis:6.2";
            extraOptions = [
              "--network=selfhosting"
            ];
          };
          virtualisation.oci-containers.containers.navidrome = lib.mkIf cfg.media.navidrome.enable {
            image = "deluan/navidrome:latest";
            ports = ["4533:4533"];
            volumes = [
              "/srv/data/navidrome:/data"
              "${cfg.media.storage.music-path}:/music:ro"
            ];
            environment = {
              ND_SCANSCHEDULE = "1h";
              ND_LOGLEVEL = "info";
              ND_SESSIONTIMEOUT = "24h";
              ND_BASEURL = cfg.media.navidrome.domain;
            };
            extraOptions = [
              "--network=selfhosting"
              "--label=traefik.enable=true"
              "--label=traefik.http.routers.navidrome.rule=Host(`${cfg.media.navidrome.domain}`)"
              "--label=traefik.http.routers.navidrome.entrypoints=websecure"
              "--label=traefik.http.routers.navidrome.tls.certresolver=letsencrypt"
            ];
          };
          services.plex = lib.mkIf cfg.media.plex.enable {
            enable = true;
            openFirewall = true;
            dataDir = "/srv/data/plex";
            extraScanners = lib.mkIf cfg.media.plex.hardware-acceleration [
              pkgs.plex-mpv-shim
            ];
          };
          systemd.tmpfiles.rules = [
            "d ${cfg.media.storage.movies-path} 0755 jellyfin jellyfin -"
            "d ${cfg.media.storage.tv-path} 0755 jellyfin jellyfin -"
            "d ${cfg.media.storage.music-path} 0755 jellyfin jellyfin -"
            "d ${cfg.media.storage.photos-path} 0755 jellyfin jellyfin -"
            "d /srv/data/jellyfin 0755 jellyfin jellyfin -"
            "d /srv/data/immich 0755 root root -"
            "d /srv/data/navidrome 0755 root root -"
            "d /srv/data/plex 0755 plex plex -"
          ];
          hardware.graphics = lib.mkIf (cfg.media.jellyfin.hardware-acceleration || cfg.media.plex.hardware-acceleration) {
            enable = true;
            extraPackages = with pkgs; [
              intel-media-driver
              vaapiIntel
              intel-compute-runtime
            ];
          };
        })
        (lib.mkIf cfg.cloud.enable {
          services.nextcloud = lib.mkIf cfg.cloud.nextcloud.enable {
            enable = true;
            package = pkgs.nextcloud28;
            hostName = cfg.cloud.nextcloud.domain;
            database.createLocally = true;
            config = {
              dbtype = "pgsql";
              adminpassFile = "/etc/nextcloud-admin-pass";
            };
            extraApps = with config.services.nextcloud.package.packages; {
              inherit calendar contacts mail notes tasks deck talk;
            };
            extraAppsEnable = true;
            extraOptions = lib.mkIf cfg.cloud.nextcloud.office {
              "richdocuments.wopi_url" = "https://collabora.${cfg.reverse-proxy.domain}";
            };
          };
          services.vaultwarden = lib.mkIf cfg.cloud.vaultwarden.enable {
            enable = true;
            config = {
              DOMAIN = "https://${cfg.cloud.vaultwarden.domain}";
              SIGNUPS_ALLOWED = false;
              ROCKET_ADDRESS = "127.0.0.1";
              ROCKET_PORT = 8222;
              ADMIN_TOKEN = lib.mkIf cfg.cloud.vaultwarden.admin-panel "$argon2id$v=19$m=65540,t=3,p=4$bWd0azJnOGJTc0Y4RzhAE$XPNOyXyg3cBhsGaQSp8P8EpmdCz2gXnK+qyV6SJqHLA";
              DATABASE_URL = "postgresql://vaultwarden:vaultwarden@localhost/vaultwarden";
              DATA_FOLDER = "/srv/data/vaultwarden";
            };
            environmentFile = "/etc/vaultwarden.env";
          };
          virtualisation.oci-containers.containers.paperless = lib.mkIf cfg.cloud.paperless.enable {
            image = "ghcr.io/paperless-ngx/paperless-ngx:latest";
            ports = ["8000:8000"];
            volumes = [
              "/srv/data/paperless/data:/usr/src/paperless/data"
              "/srv/data/paperless/media:/usr/src/paperless/media"
              "/srv/data/paperless/export:/usr/src/paperless/export"
              "/srv/data/paperless/consume:/usr/src/paperless/consume"
            ];
            environment = {
              PAPERLESS_REDIS = "redis://paperless-redis:6379";
              PAPERLESS_DBHOST = "paperless-postgres";
              PAPERLESS_DBUSER = "paperless";
              PAPERLESS_DBPASS = "paperless";
              PAPERLESS_DBNAME = "paperless";
              PAPERLESS_SECRET_KEY = "change-me-in-production";
              PAPERLESS_URL = "https://${cfg.cloud.paperless.domain}";
              PAPERLESS_OCR_LANGUAGE = "eng";
              PAPERLESS_TIME_ZONE = "UTC";
            };
            dependsOn = ["paperless-postgres" "paperless-redis"];
            extraOptions = [
              "--network=selfhosting"
              "--label=traefik.enable=true"
              "--label=traefik.http.routers.paperless.rule=Host(`${cfg.cloud.paperless.domain}`)"
              "--label=traefik.http.routers.paperless.entrypoints=websecure"
              "--label=traefik.http.routers.paperless.tls.certresolver=letsencrypt"
            ];
          };
          virtualisation.oci-containers.containers.bookstack = lib.mkIf cfg.cloud.bookstack.enable {
            image = "lscr.io/linuxserver/bookstack:latest";
            ports = ["6875:80"];
            volumes = [
              "/srv/data/bookstack:/config"
            ];
            environment = {
              PUID = "1000";
              PGID = "1000";
              APP_URL = "https://${cfg.cloud.bookstack.domain}";
              DB_HOST = "bookstack-db";
              DB_DATABASE = "bookstackapp";
              DB_USERNAME = "bookstack";
              DB_PASSWORD = "bookstack";
            };
            dependsOn = ["bookstack-db"];
            extraOptions = [
              "--network=selfhosting"
              "--label=traefik.enable=true"
              "--label=traefik.http.routers.bookstack.rule=Host(`${cfg.cloud.bookstack.domain}`)"
              "--label=traefik.http.routers.bookstack.entrypoints=websecure"
              "--label=traefik.http.routers.bookstack.tls.certresolver=letsencrypt"
            ];
          };
          systemd.tmpfiles.rules = [
            "d /srv/data/nextcloud 0755 nextcloud nextcloud -"
            "d /srv/data/vaultwarden 0755 vaultwarden vaultwarden -"
            "d /srv/data/paperless 0755 root root -"
            "d /srv/data/paperless/data 0755 root root -"
            "d /srv/data/paperless/media 0755 root root -"
            "d /srv/data/paperless/export 0755 root root -"
            "d /srv/data/paperless/consume 0755 root root -"
            "d /srv/data/bookstack 0755 1000 1000 -"
          ];
          services.postgresql = {
            ensureDatabases =
              [
                "nextcloud"
              ]
              ++ lib.optionals cfg.cloud.vaultwarden.enable ["vaultwarden"]
              ++ lib.optionals cfg.cloud.paperless.enable ["paperless"];
            ensureUsers =
              [
                {
                  name = "nextcloud";
                  ensurePermissions = {
                    "DATABASE nextcloud" = "ALL PRIVILEGES";
                  };
                }
              ]
              ++ lib.optionals cfg.cloud.vaultwarden.enable [
                {
                  name = "vaultwarden";
                  ensurePermissions = {
                    "DATABASE vaultwarden" = "ALL PRIVILEGES";
                  };
                }
              ]
              ++ lib.optionals cfg.cloud.paperless.enable [
                {
                  name = "paperless";
                  ensurePermissions = {
                    "DATABASE paperless" = "ALL PRIVILEGES";
                  };
                }
              ];
          };
        })
        (lib.mkIf cfg.automation.enable {
          services.home-assistant = lib.mkIf cfg.automation.home-assistant.enable {
            enable = true;
            extraComponents = [
              "met"
              "radio_browser"
              "esphome"
              "mqtt"
              "zha"
              "tasmota"
              "shelly"
              "hue"
              "cast"
              "spotify"
            ];
            config = {
              homeassistant = {
                name = "Home";
                latitude = "!secret latitude";
                longitude = "!secret longitude";
                elevation = "!secret elevation";
                unit_system = "metric";
                time_zone = "UTC";
              };
              frontend = {
                themes = "!include_dir_merge_named themes";
              };
              http = {
                server_host = "0.0.0.0";
                server_port = 8123;
                trusted_proxies = ["127.0.0.1" "::1"];
                use_x_forwarded_for = true;
              };
              mqtt = lib.mkIf cfg.automation.mosquitto.enable {
                broker = "localhost";
                port = cfg.automation.mosquitto.port;
              };
              discovery = {};
              mobile_app = {};
              history = {};
              logbook = {};
              recorder = {
                db_url = "postgresql://homeassistant:homeassistant@localhost/homeassistant";
                purge_keep_days = 30;
              };
            };
          };
          services.mosquitto = lib.mkIf cfg.automation.mosquitto.enable {
            enable = true;
            listeners =
              [
                {
                  port = cfg.automation.mosquitto.port;
                  omitPasswordAuth = !cfg.automation.mosquitto.auth;
                  settings = {
                    allow_anonymous = !cfg.automation.mosquitto.auth;
                  };
                }
              ]
              ++ lib.optionals cfg.automation.mosquitto.websockets [
                {
                  port = 9001;
                  protocol = "websockets";
                  omitPasswordAuth = !cfg.automation.mosquitto.auth;
                  settings = {
                    allow_anonymous = !cfg.automation.mosquitto.auth;
                  };
                }
              ];
          };
          virtualisation.oci-containers.containers.nodered = lib.mkIf cfg.automation.node-red.enable {
            image = "nodered/node-red:latest";
            ports = ["1880:1880"];
            volumes = [
              "/srv/data/nodered:/data"
            ];
            environment = {
              TZ = "UTC";
            };
            extraOptions = [
              "--network=selfhosting"
              "--label=traefik.enable=true"
              "--label=traefik.http.routers.nodered.rule=Host(`${cfg.automation.node-red.domain}`)"
              "--label=traefik.http.routers.nodered.entrypoints=websecure"
              "--label=traefik.http.routers.nodered.tls.certresolver=letsencrypt"
            ];
          };
          services.zigbee2mqtt = lib.mkIf cfg.automation.zigbee2mqtt.enable {
            enable = true;
            settings = {
              homeassistant = cfg.automation.home-assistant.enable;
              permit_join = false;
              mqtt = {
                base_topic = "zigbee2mqtt";
                server = "mqtt://localhost:${toString cfg.automation.mosquitto.port}";
              };
              serial = {
                port = cfg.automation.zigbee2mqtt.device;
              };
              frontend = {
                port = 8080;
                host = "0.0.0.0";
              };
              advanced = {
                network_key = "GENERATE";
                pan_id = "GENERATE";
                ext_pan_id = "GENERATE";
              };
            };
          };
          virtualisation.oci-containers.containers.esphome = lib.mkIf cfg.automation.esphome.enable {
            image = "ghcr.io/esphome/esphome:latest";
            ports = ["6052:6052"];
            volumes = [
              "/srv/data/esphome:/config"
              "/etc/localtime:/etc/localtime:ro"
            ];
            extraOptions = [
              "--network=host"
              "--label=traefik.enable=true"
              "--label=traefik.http.routers.esphome.rule=Host(`${cfg.automation.esphome.domain}`)"
              "--label=traefik.http.routers.esphome.entrypoints=websecure"
              "--label=traefik.http.routers.esphome.tls.certresolver=letsencrypt"
            ];
          };
          systemd.tmpfiles.rules = [
            "d /srv/data/homeassistant 0755 hass hass -"
            "d /srv/data/nodered 0755 1000 1000 -"
            "d /srv/data/esphome 0755 root root -"
          ];
          services.postgresql = {
            ensureDatabases = lib.mkIf cfg.automation.home-assistant.enable ["homeassistant"];
            ensureUsers = lib.mkIf cfg.automation.home-assistant.enable [
              {
                name = "homeassistant";
                ensurePermissions = {
                  "DATABASE homeassistant" = "ALL PRIVILEGES";
                };
              }
            ];
          };
          networking.firewall = {
            allowedTCPPorts =
              [
                8123
                1880
                6052
              ]
              ++ lib.optionals cfg.automation.mosquitto.enable [
                cfg.automation.mosquitto.port
              ]
              ++ lib.optionals cfg.automation.mosquitto.websockets [
                9001
              ];
          };
        })
        (lib.mkIf cfg.development.enable {
          services.gitea = lib.mkIf cfg.development.gitea.enable {
            enable = true;
            database = {
              type = "postgres";
              host = "localhost";
              name = "gitea";
              user = "gitea";
              createDatabase = true;
            };
            settings = {
              server = {
                DOMAIN = cfg.development.gitea.domain;
                HTTP_PORT = 3000;
                ROOT_URL = "https://${cfg.development.gitea.domain}";
              };
              service = {
                DISABLE_REGISTRATION = true;
                REQUIRE_SIGNIN_VIEW = false;
              };
              actions = lib.mkIf cfg.development.gitea.actions {
                ENABLED = true;
              };
              lfs = lib.mkIf cfg.development.gitea.lfs {
                ENABLE = true;
              };
            };
          };
          virtualisation.oci-containers.containers.registry = lib.mkIf cfg.development.registry.enable {
            image = "registry:2";
            ports = ["5000:5000"];
            volumes = [
              "/srv/data/registry:/var/lib/registry"
            ];
            environment = {
              REGISTRY_STORAGE_FILESYSTEM_ROOTDIRECTORY = "/var/lib/registry";
              REGISTRY_HTTP_ADDR = "0.0.0.0:5000";
            };
            extraOptions = [
              "--network=selfhosting"
              "--label=traefik.enable=true"
              "--label=traefik.http.routers.registry.rule=Host(`${cfg.development.registry.domain}`)"
              "--label=traefik.http.routers.registry.entrypoints=websecure"
              "--label=traefik.http.routers.registry.tls.certresolver=letsencrypt"
            ];
          };
          virtualisation.oci-containers.containers.registry-ui = lib.mkIf (cfg.development.registry.enable && cfg.development.registry.ui) {
            image = "joxit/docker-registry-ui:latest";
            ports = ["5001:80"];
            environment = {
              SINGLE_REGISTRY = "true";
              REGISTRY_TITLE = "Home Server Registry";
              DELETE_IMAGES = "true";
              SHOW_CONTENT_DIGEST = "true";
              NGINX_PROXY_PASS_URL = "http://registry:5000";
              SHOW_CATALOG_NB_TAGS = "true";
              CATALOG_MIN_BRANCHES = "1";
              CATALOG_MAX_BRANCHES = "1";
              TAGLIST_PAGE_SIZE = "100";
              REGISTRY_SECURED = "false";
            };
            dependsOn = ["registry"];
            extraOptions = [
              "--network=selfhosting"
              "--label=traefik.enable=true"
              "--label=traefik.http.routers.registry-ui.rule=Host(`ui.${cfg.development.registry.domain}`)"
              "--label=traefik.http.routers.registry-ui.entrypoints=websecure"
              "--label=traefik.http.routers.registry-ui.tls.certresolver=letsencrypt"
            ];
          };
          services.minio = lib.mkIf cfg.development.minio.enable {
            enable = true;
            listenAddress = ":9000";
            consoleAddress = ":9001";
            rootCredentialsFile = "/etc/minio-root-credentials";
            dataDir = ["/srv/data/minio"];
          };
          systemd.tmpfiles.rules = [
            "d /srv/data/gitea 0755 gitea gitea -"
            "d /srv/data/registry 0755 root root -"
            "d /srv/data/minio 0755 minio minio -"
          ];
          services.postgresql = {
            ensureDatabases = lib.mkIf cfg.development.gitea.enable ["gitea"];
            ensureUsers = lib.mkIf cfg.development.gitea.enable [
              {
                name = "gitea";
                ensurePermissions = {
                  "DATABASE gitea" = "ALL PRIVILEGES";
                };
              }
            ];
          };
          networking.firewall = {
            allowedTCPPorts = [
              3000
              5000
              5001
              9000
              9001
            ];
          };
        })
        (lib.mkIf cfg.monitoring.enable {
          services.prometheus = lib.mkIf cfg.monitoring.prometheus.enable {
            enable = true;
            globalConfig = {
              scrape_interval = "15s";
              evaluation_interval = "15s";
            };
            scrapeConfigs =
              [
                {
                  job_name = "node";
                  static_configs = [
                    {
                      targets = ["localhost:9100"];
                    }
                  ];
                }
                {
                  job_name = "prometheus";
                  static_configs = [
                    {
                      targets = ["localhost:9090"];
                    }
                  ];
                }
              ]
              ++ lib.optionals cfg.monitoring.exporters.cadvisor [
                {
                  job_name = "cadvisor";
                  static_configs = [
                    {
                      targets = ["localhost:8080"];
                    }
                  ];
                }
              ];
            retentionTime = cfg.monitoring.prometheus.retention;
            exporters = {
              node = lib.mkIf cfg.monitoring.exporters.node {
                enable = true;
                openFirewall = true;
                enabledCollectors = [
                  "systemd"
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
                  "version"
                ];
                disabledCollectors = [
                  "arp"
                  "edac"
                  "entropy"
                  "hwmon"
                  "ipvs"
                  "ksmd"
                  "logind"
                  "mdadm"
                  "nfs"
                  "nfsd"
                  "nvme"
                  "powersupplyclass"
                  "rapl"
                  "thermal_zone"
                  "udp_queues"
                  "xfs"
                  "zfs"
                ];
              };
            };
          };
          services.grafana = lib.mkIf cfg.monitoring.grafana.enable {
            enable = true;
            settings = {
              server = {
                http_addr = "127.0.0.1";
                http_port = 3000;
                domain = cfg.monitoring.grafana.domain;
                root_url = "https://${cfg.monitoring.grafana.domain}";
              };
              security = {
                admin_user = "admin";
                admin_password = "$__file{/etc/grafana-admin-password}";
              };
              database = {
                type = "postgres";
                host = "localhost:5432";
                name = "grafana";
                user = "grafana";
                password = "$__file{/etc/grafana-db-password}";
              };
            };
            provision = {
              enable = true;
              datasources.settings.datasources =
                [
                  {
                    name = "Prometheus";
                    type = "prometheus";
                    access = "proxy";
                    url = "http://localhost:9090";
                    isDefault = true;
                  }
                ]
                ++ lib.optionals cfg.monitoring.loki.enable [
                  {
                    name = "Loki";
                    type = "loki";
                    access = "proxy";
                    url = "http://localhost:3100";
                  }
                ];
            };
          };
          services.loki = lib.mkIf cfg.monitoring.loki.enable {
            enable = true;
            configuration = {
              server = {
                http_listen_port = 3100;
                grpc_listen_port = 9096;
              };
              common = {
                path_prefix = "/var/lib/loki";
                storage.filesystem = {
                  chunks_directory = "/var/lib/loki/chunks";
                  rules_directory = "/var/lib/loki/rules";
                };
                replication_factor = 1;
                ring = {
                  instance_addr = "127.0.0.1";
                  kvstore.store = "inmemory";
                };
              };
              schema_config = {
                configs = [
                  {
                    from = "2020-10-24";
                    store = "boltdb-shipper";
                    object_store = "filesystem";
                    schema = "v11";
                    index = {
                      prefix = "index_";
                      period = "24h";
                    };
                  }
                ];
              };
              limits_config = {
                retention_period = cfg.monitoring.loki.retention;
              };
            };
          };
          virtualisation.oci-containers.containers.uptime-kuma = lib.mkIf cfg.monitoring.uptime-kuma.enable {
            image = "louislam/uptime-kuma:1";
            ports = ["3001:3001"];
            volumes = [
              "/srv/data/uptime-kuma:/app/data"
            ];
            extraOptions = [
              "--network=selfhosting"
              "--label=traefik.enable=true"
              "--label=traefik.http.routers.uptime-kuma.rule=Host(`${cfg.monitoring.uptime-kuma.domain}`)"
              "--label=traefik.http.routers.uptime-kuma.entrypoints=websecure"
              "--label=traefik.http.routers.uptime-kuma.tls.certresolver=letsencrypt"
            ];
          };
          virtualisation.oci-containers.containers.cadvisor = lib.mkIf cfg.monitoring.exporters.cadvisor {
            image = "gcr.io/cadvisor/cadvisor:latest";
            ports = ["8080:8080"];
            volumes = [
              "/:/rootfs:ro"
              "/var/run:/var/run:ro"
              "/sys:/sys:ro"
              "/var/lib/docker/:/var/lib/docker:ro"
              "/dev/disk/:/dev/disk:ro"
            ];
            extraOptions = [
              "--privileged"
              "--device=/dev/kmsg"
              "--network=host"
            ];
          };
          systemd.tmpfiles.rules = [
            "d /srv/data/uptime-kuma 0755 root root -"
            "d /var/lib/prometheus2 0755 prometheus prometheus -"
            "d /var/lib/grafana 0755 grafana grafana -"
            "d /var/lib/loki 0755 loki loki -"
          ];
          services.postgresql = {
            ensureDatabases = lib.mkIf cfg.monitoring.grafana.enable ["grafana"];
            ensureUsers = lib.mkIf cfg.monitoring.grafana.enable [
              {
                name = "grafana";
                ensurePermissions = {
                  "DATABASE grafana" = "ALL PRIVILEGES";
                };
              }
            ];
          };
        })
        (lib.mkIf cfg.backup.enable {
          services.restic.backups = lib.mkIf cfg.backup.restic.enable (
            lib.listToAttrs (map
              (repo: {
                name = "backup-${baseNameOf repo}";
                value = {
                  initialize = true;
                  repository = repo;
                  passwordFile = "/etc/restic-password";
                  paths = [
                    "/srv/data"
                    "/home"
                    "/etc/nixos"
                    "/var/lib/postgresql"
                  ];
                  exclude = [
                    "/srv/data/*/cache"
                    "/srv/data/*/tmp"
                    "*.log"
                    "*.tmp"
                  ];
                  timerConfig = {
                    OnCalendar = cfg.backup.restic.schedule;
                    Persistent = true;
                  };
                  pruneOpts = [
                    "--keep-daily 7"
                    "--keep-weekly 5"
                    "--keep-monthly 12"
                    "--keep-yearly 75"
                  ];
                };
              })
              cfg.backup.restic.repositories)
          );
          services.syncthing = lib.mkIf cfg.backup.syncthing.enable {
            enable = true;
            user = "amoon";
            dataDir = "/srv/data/syncthing";
            configDir = "/srv/data/syncthing/.config/syncthing";
            overrideDevices = true;
            overrideFolders = true;
            settings = {
              gui = {
                address = "0.0.0.0:8384";
                insecureAdminAccess = false;
              };
              options = {
                globalAnnounceEnabled = false;
                localAnnounceEnabled = true;
                relaysEnabled = false;
                natEnabled = false;
              };
            };
          };
          systemd.tmpfiles.rules = [
            "d /srv/backup 0755 root root -"
            "d /srv/backup/restic 0755 root root -"
            "d /srv/backup/borg 0755 root root -"
            "d /srv/data/syncthing 0755 amoon amoon -"
          ];
          networking.firewall = {
            allowedTCPPorts = lib.mkIf cfg.backup.syncthing.enable [
              8384
              22000
            ];
            allowedUDPPorts = lib.mkIf cfg.backup.syncthing.enable [
              21027
            ];
          };
        })
      ];
    dependencies = ["core" "containers" "bleeding-edge"];
  }) {
    inherit config lib pkgs inputs;
  }
