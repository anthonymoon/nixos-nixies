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
    name = "enterprise-monitoring";
    description = "Enterprise-grade monitoring, logging, and observability stack";
    category = "monitoring";

    options = with lib; {
      enable = mkEnableOption "enterprise monitoring and logging";

      metrics = {
        prometheus = mkEnableOption "Prometheus metrics collection" // {default = true;};
        grafana = mkEnableOption "Grafana dashboards and visualization" // {default = true;};
        alertmanager = mkEnableOption "Prometheus Alertmanager" // {default = true;};
        node-exporter = mkEnableOption "Node exporter for system metrics" // {default = true;};

        retention = mkOption {
          type = types.str;
          default = "30d";
          description = "Metrics retention period";
        };

        storage-size = mkOption {
          type = types.str;
          default = "10GB";
          description = "Metrics storage size";
        };
      };

      logging = {
        centralized = mkEnableOption "Centralized logging with ELK stack" // {default = true;};
        elasticsearch = mkEnableOption "Elasticsearch for log storage" // {default = true;};
        logstash = mkEnableOption "Logstash for log processing" // {default = true;};
        kibana = mkEnableOption "Kibana for log visualization" // {default = true;};
        filebeat = mkEnableOption "Filebeat for log shipping" // {default = true;};

        retention = mkOption {
          type = types.str;
          default = "90d";
          description = "Log retention period";
        };

        index-size = mkOption {
          type = types.str;
          default = "1GB";
          description = "Maximum index size before rotation";
        };
      };

      alerting = {
        email = mkOption {
          type = types.nullOr types.str;
          default = null;
          description = "Email address for alerts";
        };

        slack = mkOption {
          type = types.nullOr types.str;
          default = null;
          description = "Slack webhook URL for alerts";
        };

        pagerduty = mkOption {
          type = types.nullOr types.str;
          default = null;
          description = "PagerDuty service key for critical alerts";
        };

        severity-levels = mkOption {
          type = types.listOf (types.enum ["critical" "warning" "info"]);
          default = ["critical" "warning"];
          description = "Alert severity levels to process";
        };
      };

      security = {
        siem = mkEnableOption "Security Information and Event Management";
        threat-detection = mkEnableOption "Real-time threat detection" // {default = true;};
        compliance-reporting = mkEnableOption "Automated compliance reporting" // {default = true;};
        forensics = mkEnableOption "Digital forensics capabilities";
      };

      performance = {
        apm = mkEnableOption "Application Performance Monitoring";
        tracing = mkEnableOption "Distributed tracing";
        profiling = mkEnableOption "Performance profiling";

        thresholds = {
          cpu = mkOption {
            type = types.int;
            default = 80;
            description = "CPU usage alert threshold (percentage)";
          };

          memory = mkOption {
            type = types.int;
            default = 85;
            description = "Memory usage alert threshold (percentage)";
          };

          disk = mkOption {
            type = types.int;
            default = 90;
            description = "Disk usage alert threshold (percentage)";
          };

          load = mkOption {
            type = types.float;
            default = 5.0;
            description = "System load average alert threshold";
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
        # Base monitoring setup
        (lib.mkIf cfg.enable {
          # Create monitoring user and directories
          users.users.monitoring = {
            isSystemUser = true;
            group = "monitoring";
            home = "/var/lib/monitoring";
            createHome = true;
            description = "Enterprise monitoring user";
          };

          users.groups.monitoring = {};

          # Monitoring directories
          systemd.tmpfiles.rules = [
            "d /var/lib/monitoring 0755 monitoring monitoring -"
            "d /var/log/monitoring 0750 monitoring monitoring -"
            "d /etc/monitoring 0755 root root -"
            "d /var/lib/prometheus 0755 prometheus prometheus -"
            "d /var/lib/grafana 0755 grafana grafana -"
            "d /var/lib/elasticsearch 0755 elasticsearch elasticsearch -"
          ];
        })

        # Prometheus metrics collection
        (lib.mkIf cfg.metrics.prometheus {
          services.prometheus = {
            enable = true;
            port = 9090;
            dataDir = "/var/lib/prometheus";
            retentionTime = cfg.metrics.retention;

            # Global configuration
            globalConfig = {
              scrape_interval = "15s";
              evaluation_interval = "15s";
              external_labels = {
                monitor = "enterprise-prometheus";
                environment = "production";
              };
            };

            # Rule files for alerting
            ruleFiles = [
              (pkgs.writeText "enterprise-alerts.yml" (builtins.toJSON {
                groups = [
                  {
                    name = "enterprise.rules";
                    rules = [
                      {
                        alert = "HighCPUUsage";
                        expr = "100 - (avg by(instance) (irate(node_cpu_seconds_total{mode=\"idle\"}[5m])) * 100) > ${toString cfg.performance.thresholds.cpu}";
                        for = "2m";
                        labels = {
                          severity = "warning";
                          service = "system";
                        };
                        annotations = {
                          summary = "High CPU usage detected";
                          description = "CPU usage is above ${toString cfg.performance.thresholds.cpu}% for more than 2 minutes";
                        };
                      }
                      {
                        alert = "HighMemoryUsage";
                        expr = "(node_memory_MemTotal_bytes - node_memory_MemAvailable_bytes) / node_memory_MemTotal_bytes * 100 > ${toString cfg.performance.thresholds.memory}";
                        for = "2m";
                        labels = {
                          severity = "warning";
                          service = "system";
                        };
                        annotations = {
                          summary = "High memory usage detected";
                          description = "Memory usage is above ${toString cfg.performance.thresholds.memory}% for more than 2 minutes";
                        };
                      }
                      {
                        alert = "HighDiskUsage";
                        expr = "(node_filesystem_size_bytes - node_filesystem_avail_bytes) / node_filesystem_size_bytes * 100 > ${toString cfg.performance.thresholds.disk}";
                        for = "1m";
                        labels = {
                          severity = "critical";
                          service = "system";
                        };
                        annotations = {
                          summary = "High disk usage detected";
                          description = "Disk usage is above ${toString cfg.performance.thresholds.disk}% on {{ $labels.mountpoint }}";
                        };
                      }
                      {
                        alert = "HighLoadAverage";
                        expr = "node_load5 > ${toString cfg.performance.thresholds.load}";
                        for = "5m";
                        labels = {
                          severity = "warning";
                          service = "system";
                        };
                        annotations = {
                          summary = "High system load detected";
                          description = "5-minute load average is ${toString cfg.performance.thresholds.load}+ for more than 5 minutes";
                        };
                      }
                      {
                        alert = "ServiceDown";
                        expr = "up == 0";
                        for = "1m";
                        labels = {
                          severity = "critical";
                          service = "monitoring";
                        };
                        annotations = {
                          summary = "Service is down";
                          description = "{{ $labels.instance }} of job {{ $labels.job }} has been down for more than 1 minute";
                        };
                      }
                      {
                        alert = "SecurityBreach";
                        expr = "increase(node_audit_events_total[5m]) > 100";
                        for = "1m";
                        labels = {
                          severity = "critical";
                          service = "security";
                        };
                        annotations = {
                          summary = "Potential security breach detected";
                          description = "High number of audit events detected in the last 5 minutes";
                        };
                      }
                    ];
                  }
                ];
              }))
            ];

            # Scrape configurations
            scrapeConfigs =
              [
                {
                  job_name = "node";
                  static_configs = [
                    {
                      targets = ["localhost:9100"];
                      labels = {
                        alias = "enterprise-server";
                        environment = "production";
                      };
                    }
                  ];
                  scrape_interval = "15s";
                  metrics_path = "/metrics";
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
              ++ lib.optionals cfg.logging.elasticsearch [
                {
                  job_name = "elasticsearch";
                  static_configs = [
                    {
                      targets = ["localhost:9200"];
                    }
                  ];
                }
              ]
              ++ lib.optionals cfg.metrics.grafana [
                {
                  job_name = "grafana";
                  static_configs = [
                    {
                      targets = ["localhost:3000"];
                    }
                  ];
                }
              ];

            # Storage configuration
            extraFlags = [
              "--storage.tsdb.retention.time=${cfg.metrics.retention}"
              "--storage.tsdb.retention.size=${cfg.metrics.storage-size}"
              "--web.enable-lifecycle"
              "--web.enable-admin-api"
            ];
          };
        })

        # Node exporter for system metrics
        (lib.mkIf cfg.metrics.node-exporter {
          services.prometheus.exporters.node = {
            enable = true;
            port = 9100;
            enabledCollectors = [
              "systemd"
              "processes"
              "interrupts"
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
              "vmstat"
              "textfile"
            ];

            # Custom metrics collection
            extraFlags = [
              "--collector.textfile.directory=/var/lib/node_exporter/textfile_collector"
              "--collector.systemd.unit-include=(sshd|fail2ban|suricata|aide|prometheus|grafana|elasticsearch|logstash|kibana)\\.service"
              "--collector.filesystem.ignored-mount-points=^/(dev|proc|sys|var/lib/docker/.+)($|/)"
              "--collector.filesystem.ignored-fs-types=^(autofs|binfmt_misc|bpf|cgroup2?|configfs|debugfs|devpts|devtmpfs|fusectl|hugetlbfs|iso9660|mqueue|nsfs|overlay|proc|procfs|pstore|rpc_pipefs|securityfs|selinuxfs|squashfs|sysfs|tracefs)$"
            ];
          };

          # Create textfile collector directory
          systemd.tmpfiles.rules = [
            "d /var/lib/node_exporter 0755 nobody nobody -"
            "d /var/lib/node_exporter/textfile_collector 0755 nobody nobody -"
          ];

          # Custom metrics collection scripts
          systemd.services.custom-metrics = {
            description = "Collect custom enterprise metrics";
            serviceConfig = {
              Type = "oneshot";
              ExecStart = pkgs.writeScript "collect-metrics" ''
                #!/bin/bash

                TEXTFILE_DIR="/var/lib/node_exporter/textfile_collector"

                # Security metrics
                {
                  echo "# HELP enterprise_failed_logins_total Total number of failed login attempts"
                  echo "# TYPE enterprise_failed_logins_total counter"
                  failed_logins=$(journalctl --since="1 hour ago" | grep -c "Failed password" || echo 0)
                  echo "enterprise_failed_logins_total $failed_logins"

                  echo "# HELP enterprise_sudo_commands_total Total number of sudo commands executed"
                  echo "# TYPE enterprise_sudo_commands_total counter"
                  sudo_commands=$(journalctl --since="1 hour ago" | grep -c "sudo:" || echo 0)
                  echo "enterprise_sudo_commands_total $sudo_commands"

                  echo "# HELP enterprise_firewall_drops_total Total number of dropped packets"
                  echo "# TYPE enterprise_firewall_drops_total counter"
                  fw_drops=$(journalctl --since="1 hour ago" | grep -c "kernel.*DROP" || echo 0)
                  echo "enterprise_firewall_drops_total $fw_drops"

                  echo "# HELP enterprise_aide_changes_total Total number of file system changes detected by AIDE"
                  echo "# TYPE enterprise_aide_changes_total counter"
                  aide_changes=$(journalctl --since="1 hour ago" | grep -c "aide.*changed" || echo 0)
                  echo "enterprise_aide_changes_total $aide_changes"
                } > "$TEXTFILE_DIR/enterprise_security.prom.$$"
                mv "$TEXTFILE_DIR/enterprise_security.prom.$$" "$TEXTFILE_DIR/enterprise_security.prom"

                # Compliance metrics
                {
                  echo "# HELP enterprise_compliance_score Enterprise compliance score (0-100)"
                  echo "# TYPE enterprise_compliance_score gauge"

                  # Calculate compliance score based on various factors
                  score=100

                  # Check if audit logging is enabled
                  if ! systemctl is-active auditd >/dev/null 2>&1; then
                    score=$((score - 20))
                  fi

                  # Check if firewall is active
                  if ! systemctl is-active iptables >/dev/null 2>&1; then
                    score=$((score - 15))
                  fi

                  # Check if fail2ban is active
                  if ! systemctl is-active fail2ban >/dev/null 2>&1; then
                    score=$((score - 10))
                  fi

                  # Check if SSH is properly configured
                  if grep -q "PermitRootLogin yes" /etc/ssh/sshd_config 2>/dev/null; then
                    score=$((score - 25))
                  fi

                  echo "enterprise_compliance_score $score"
                } > "$TEXTFILE_DIR/enterprise_compliance.prom.$$"
                mv "$TEXTFILE_DIR/enterprise_compliance.prom.$$" "$TEXTFILE_DIR/enterprise_compliance.prom"
              '';
            };
          };

          systemd.timers.custom-metrics = {
            description = "Collect custom metrics every 5 minutes";
            wantedBy = ["timers.target"];
            timerConfig = {
              OnCalendar = "*:0/5";
              Persistent = true;
            };
          };
        })

        # Alertmanager configuration
        (lib.mkIf cfg.metrics.alertmanager {
          services.prometheus.alertmanager = {
            enable = true;
            port = 9093;

            configuration = {
              global = {
                smtp_smarthost = "localhost:587";
                smtp_from = "alerts@enterprise.local";
              };

              route = {
                group_by = ["alertname" "cluster" "service"];
                group_wait = "10s";
                group_interval = "10s";
                repeat_interval = "1h";
                receiver = "default";

                routes =
                  lib.optionals (cfg.alerting.pagerduty != null) [
                    {
                      match = {
                        severity = "critical";
                      };
                      receiver = "pagerduty";
                    }
                  ]
                  ++ lib.optionals (cfg.alerting.email != null) [
                    {
                      match = {
                        severity = "warning";
                      };
                      receiver = "email";
                    }
                  ];
              };

              receivers =
                [
                  {
                    name = "default";
                    slack_configs = lib.optionals (cfg.alerting.slack != null) [
                      {
                        api_url = cfg.alerting.slack;
                        channel = "#alerts";
                        title = "Enterprise Alert";
                        text = "{{ range .Alerts }}{{ .Annotations.summary }}\n{{ .Annotations.description }}{{ end }}";
                      }
                    ];
                  }
                ]
                ++ lib.optionals (cfg.alerting.email != null) [
                  {
                    name = "email";
                    email_configs = [
                      {
                        to = cfg.alerting.email;
                        subject = "Enterprise Alert: {{ .GroupLabels.alertname }}";
                        body = ''
                          {{ range .Alerts }}
                          Alert: {{ .Annotations.summary }}
                          Description: {{ .Annotations.description }}
                          Labels: {{ range .Labels.SortedPairs }}{{ .Name }}={{ .Value }} {{ end }}
                          {{ end }}
                        '';
                      }
                    ];
                  }
                ]
                ++ lib.optionals (cfg.alerting.pagerduty != null) [
                  {
                    name = "pagerduty";
                    pagerduty_configs = [
                      {
                        service_key = cfg.alerting.pagerduty;
                        description = "{{ .GroupLabels.alertname }}: {{ .CommonAnnotations.summary }}";
                      }
                    ];
                  }
                ];
            };
          };
        })

        # Grafana dashboards
        (lib.mkIf cfg.metrics.grafana {
          services.grafana = {
            enable = true;
            settings = {
              server = {
                http_addr = "127.0.0.1";
                http_port = 3000;
                domain = "localhost";
                root_url = "%(protocol)s://%(domain)s:%(http_port)s/";
              };

              database = {
                type = "sqlite3";
                path = "/var/lib/grafana/grafana.db";
              };

              security = {
                admin_user = "admin";
                admin_password = "$__env{GRAFANA_ADMIN_PASSWORD}";
                secret_key = "$__env{GRAFANA_SECRET_KEY}";
                disable_gravatar = true;
                cookie_secure = true;
                cookie_samesite = "strict";
              };

              users = {
                allow_sign_up = false;
                allow_org_create = false;
                auto_assign_org = true;
                auto_assign_org_role = "Viewer";
              };

              auth = {
                disable_login_form = false;
                disable_signout_menu = false;
              };

              snapshots = {
                external_enabled = false;
              };

              analytics = {
                reporting_enabled = false;
                check_for_updates = false;
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
                ++ lib.optionals cfg.logging.elasticsearch [
                  {
                    name = "Elasticsearch";
                    type = "elasticsearch";
                    access = "proxy";
                    url = "http://localhost:9200";
                    database = "[logstash-]YYYY.MM.DD";
                    interval = "Daily";
                    timeField = "@timestamp";
                  }
                ];

              dashboards.settings.providers = [
                {
                  name = "default";
                  orgId = 1;
                  folder = "";
                  type = "file";
                  disableDeletion = false;
                  updateIntervalSeconds = 10;
                  allowUiUpdates = true;
                  options.path = "/var/lib/grafana/dashboards";
                }
              ];
            };
          };

          # Enterprise dashboards
          environment.etc."grafana/dashboards/enterprise-overview.json".text = builtins.toJSON {
            dashboard = {
              id = null;
              title = "Enterprise Server Overview";
              tags = ["enterprise" "overview"];
              timezone = "browser";
              panels = [
                {
                  id = 1;
                  title = "System Load";
                  type = "graph";
                  targets = [
                    {
                      expr = "node_load1";
                      legendFormat = "1m load";
                      refId = "A";
                    }
                    {
                      expr = "node_load5";
                      legendFormat = "5m load";
                      refId = "B";
                    }
                    {
                      expr = "node_load15";
                      legendFormat = "15m load";
                      refId = "C";
                    }
                  ];
                  gridPos = {
                    h = 8;
                    w = 12;
                    x = 0;
                    y = 0;
                  };
                }
                {
                  id = 2;
                  title = "Memory Usage";
                  type = "graph";
                  targets = [
                    {
                      expr = "(node_memory_MemTotal_bytes - node_memory_MemAvailable_bytes) / node_memory_MemTotal_bytes * 100";
                      legendFormat = "Memory Usage %";
                      refId = "A";
                    }
                  ];
                  gridPos = {
                    h = 8;
                    w = 12;
                    x = 12;
                    y = 0;
                  };
                }
                {
                  id = 3;
                  title = "Security Events";
                  type = "graph";
                  targets = [
                    {
                      expr = "increase(enterprise_failed_logins_total[1h])";
                      legendFormat = "Failed Logins";
                      refId = "A";
                    }
                    {
                      expr = "increase(enterprise_firewall_drops_total[1h])";
                      legendFormat = "Firewall Drops";
                      refId = "B";
                    }
                  ];
                  gridPos = {
                    h = 8;
                    w = 24;
                    x = 0;
                    y = 8;
                  };
                }
                {
                  id = 4;
                  title = "Compliance Score";
                  type = "singlestat";
                  targets = [
                    {
                      expr = "enterprise_compliance_score";
                      refId = "A";
                    }
                  ];
                  gridPos = {
                    h = 8;
                    w = 6;
                    x = 0;
                    y = 16;
                  };
                  thresholds = "80,90";
                  colorBackground = true;
                }
              ];
              time = {
                from = "now-1h";
                to = "now";
              };
              refresh = "30s";
            };
          };
        })

        # Elasticsearch for log storage
        (lib.mkIf cfg.logging.elasticsearch {
          services.elasticsearch = {
            enable = true;
            package = pkgs.elasticsearch7;

            extraConf = ''
              cluster.name: enterprise-logs
              node.name: enterprise-node-1
              path.data: /var/lib/elasticsearch
              path.logs: /var/log/elasticsearch
              network.host: 127.0.0.1
              http.port: 9200
              discovery.type: single-node

              # Security settings
              xpack.security.enabled: false
              xpack.monitoring.enabled: false
              xpack.watcher.enabled: false

              # Performance settings
              indices.memory.index_buffer_size: 10%
              bootstrap.memory_lock: true

              # Index lifecycle management
              action.destructive_requires_name: true
              indices.lifecycle.poll_interval: 10m
            '';

            extraJavaOptions = [
              "-Xms2g"
              "-Xmx2g"
              "-XX:+UseG1GC"
              "-XX:+UnlockExperimentalVMOptions"
              "-XX:+UseCGroupMemoryLimitForHeap"
            ];
          };

          # Index template for enterprise logs
          systemd.services.elasticsearch-setup = {
            description = "Setup Elasticsearch for enterprise logging";
            after = ["elasticsearch.service"];
            wantedBy = ["multi-user.target"];
            serviceConfig = {
              Type = "oneshot";
              RemainAfterExit = true;
              ExecStart = pkgs.writeScript "setup-elasticsearch" ''
                #!/bin/bash

                # Wait for Elasticsearch to be ready
                while ! ${pkgs.curl}/bin/curl -s http://localhost:9200/_cluster/health >/dev/null; do
                  sleep 5
                done

                # Create index template for enterprise logs
                ${pkgs.curl}/bin/curl -X PUT "localhost:9200/_index_template/enterprise-logs" \
                  -H "Content-Type: application/json" \
                  -d '{
                    "index_patterns": ["enterprise-*"],
                    "template": {
                      "settings": {
                        "number_of_shards": 1,
                        "number_of_replicas": 0,
                        "index.lifecycle.name": "enterprise-policy",
                        "index.lifecycle.rollover_alias": "enterprise-logs"
                      },
                      "mappings": {
                        "properties": {
                          "@timestamp": { "type": "date" },
                          "level": { "type": "keyword" },
                          "message": { "type": "text" },
                          "service": { "type": "keyword" },
                          "host": { "type": "keyword" },
                          "severity": { "type": "keyword" }
                        }
                      }
                    }
                  }'

                # Create index lifecycle policy
                ${pkgs.curl}/bin/curl -X PUT "localhost:9200/_ilm/policy/enterprise-policy" \
                  -H "Content-Type: application/json" \
                  -d '{
                    "policy": {
                      "phases": {
                        "hot": {
                          "actions": {
                            "rollover": {
                              "max_size": "${cfg.logging.index-size}",
                              "max_age": "1d"
                            }
                          }
                        },
                        "delete": {
                          "min_age": "${cfg.logging.retention}",
                          "actions": {
                            "delete": {}
                          }
                        }
                      }
                    }
                  }'
              '';
            };
          };
        })

        # Logstash for log processing
        (lib.mkIf cfg.logging.logstash {
          services.logstash = {
            enable = true;
            package = pkgs.logstash7;

            inputConfig = ''
              input {
                journald {
                  path => "/var/log/journal"
                  seek_position => "tail"
                }

                file {
                  path => "/var/log/auth.log"
                  start_position => "beginning"
                  type => "auth"
                }

                file {
                  path => "/var/log/audit/audit.log"
                  start_position => "beginning"
                  type => "audit"
                }

                file {
                  path => "/var/log/suricata/eve.json"
                  start_position => "beginning"
                  type => "suricata"
                  codec => "json"
                }
              }
            '';

            filterConfig = ''
              filter {
                if [type] == "auth" {
                  grok {
                    match => { "message" => "%{SYSLOGTIMESTAMP:timestamp} %{HOSTNAME:host} %{WORD:service}(?:\[%{POSINT:pid}\])?: %{GREEDYDATA:auth_message}" }
                  }

                  if "Failed password" in [auth_message] {
                    mutate {
                      add_tag => [ "security", "failed_auth" ]
                      add_field => { "severity" => "warning" }
                    }
                  }

                  if "Accepted password" in [auth_message] {
                    mutate {
                      add_tag => [ "security", "successful_auth" ]
                      add_field => { "severity" => "info" }
                    }
                  }
                }

                if [type] == "audit" {
                  grok {
                    match => { "message" => "type=%{WORD:audit_type} msg=audit\(%{NUMBER:audit_timestamp}:%{NUMBER:audit_serial}\): %{GREEDYDATA:audit_data}" }
                  }

                  mutate {
                    add_tag => [ "security", "audit" ]
                    add_field => { "severity" => "info" }
                  }
                }

                if [type] == "suricata" {
                  if [alert] {
                    mutate {
                      add_tag => [ "security", "ids", "alert" ]
                      add_field => { "severity" => "warning" }
                    }
                  }
                }

                # Add enterprise-specific fields
                mutate {
                  add_field => { "environment" => "production" }
                  add_field => { "compliance_framework" => "SOC2" }
                }

                # Parse timestamp
                date {
                  match => [ "timestamp", "MMM dd HH:mm:ss", "MMM d HH:mm:ss" ]
                }
              }
            '';

            outputConfig = ''
              output {
                elasticsearch {
                  hosts => ["localhost:9200"]
                  index => "enterprise-logs-%{+YYYY.MM.dd}"
                }

                # Output critical alerts to separate index
                if "critical" in [tags] or [severity] == "critical" {
                  elasticsearch {
                    hosts => ["localhost:9200"]
                    index => "enterprise-alerts-%{+YYYY.MM.dd}"
                  }
                }

                # Debug output
                stdout {
                  codec => rubydebug
                }
              }
            '';
          };
        })

        # Kibana for log visualization
        (lib.mkIf cfg.logging.kibana {
          services.kibana = {
            enable = true;
            package = pkgs.kibana7;

            settings = {
              "server.host" = "127.0.0.1";
              "server.port" = 5601;
              "elasticsearch.hosts" = ["http://localhost:9200"];
              "kibana.index" = ".kibana";
              "server.name" = "enterprise-kibana";

              # Security settings
              "server.ssl.enabled" = false;
              "elasticsearch.ssl.verificationMode" = "none";

              # UI settings
              "kibana.defaultAppId" = "discover";
              "telemetry.enabled" = false;
              "telemetry.optIn" = false;
            };
          };
        })
      ];

    # Monitoring dependencies
    dependencies = ["core" "security"];
  }
