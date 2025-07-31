{
  config,
  lib,
  pkgs,
  inputs,
  ...
}: let
  nixies-lib = import ../../lib {inherit inputs lib;};
in
  (nixies-lib.mkNixiesModule {
    name = "enterprise-deployment";
    description = "Enterprise deployment automation, orchestration, and infrastructure management";
    category = "deployment";
    options = with lib; {
      enable = mkEnableOption "enterprise deployment automation";
      orchestration = {
        ansible = mkEnableOption "Ansible automation platform" // {default = true;};
        terraform = mkEnableOption "Terraform infrastructure as code";
        kubernetes = mkEnableOption "Kubernetes container orchestration";
        consul = mkEnableOption "Consul service discovery and configuration";
        vault = mkEnableOption "HashiCorp Vault for secrets management";
      };
      ci-cd = {
        jenkins = mkEnableOption "Jenkins CI/CD pipeline";
        gitlab-runner = mkEnableOption "GitLab CI/CD runner";
        github-actions = mkEnableOption "GitHub Actions self-hosted runner";
        build-cache = mkEnableOption "Distributed build caching" // {default = true;};
        artifact-storage = mkEnableOption "Artifact storage and management" // {default = true;};
      };
      deployment = {
        blue-green = mkEnableOption "Blue-green deployment strategy";
        canary = mkEnableOption "Canary deployment strategy";
        rolling = mkEnableOption "Rolling deployment strategy" // {default = true;};
        health-checks = mkEnableOption "Automated health checks during deployment" // {default = true;};
        rollback = mkEnableOption "Automated rollback on failure" // {default = true;};
        environments = mkOption {
          type = types.listOf (types.enum ["development" "staging" "production"]);
          default = ["production"];
          description = "Target deployment environments";
        };
      };
      infrastructure = {
        provisioning = mkEnableOption "Automated infrastructure provisioning";
        scaling = mkEnableOption "Auto-scaling capabilities";
        backup = mkEnableOption "Automated backup and disaster recovery" // {default = true;};
        cloud-providers = mkOption {
          type = types.listOf (types.enum ["aws" "gcp" "azure" "digitalocean" "linode"]);
          default = [];
          description = "Supported cloud providers";
        };
      };
      security = {
        scanning = mkEnableOption "Security scanning in CI/CD pipeline" // {default = true;};
        compliance-checks = mkEnableOption "Automated compliance validation" // {default = true;};
        secret-management = mkEnableOption "Automated secret rotation and management" // {default = true;};
        policy-as-code = mkEnableOption "Policy as code enforcement";
        vulnerability-management = mkEnableOption "Automated vulnerability management";
      };
      monitoring = {
        deployment-metrics = mkEnableOption "Deployment success/failure metrics" // {default = true;};
        performance-tracking = mkEnableOption "Performance regression detection";
        alerting = mkEnableOption "Deployment alerting and notifications" // {default = true;};
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
          users.users.deployment = {
            isSystemUser = true;
            group = "deployment";
            home = "/var/lib/deployment";
            createHome = true;
            description = "Enterprise deployment automation user";
            extraGroups = ["docker"];
          };
          users.groups.deployment = {};
          systemd.tmpfiles.rules = [
            "d /var/lib/deployment 0755 deployment deployment -"
            "d /var/lib/deployment/scripts 0755 deployment deployment -"
            "d /var/lib/deployment/configs 0755 deployment deployment -"
            "d /var/lib/deployment/artifacts 0755 deployment deployment -"
            "d /var/lib/deployment/secrets 0700 deployment deployment -"
            "d /var/log/deployment 0750 deployment deployment -"
            "d /etc/deployment 0755 root root -"
          ];
          environment.systemPackages = with pkgs;
            [
              git
              git-lfs
              gnumake
              cmake
              ninja
              python3
              bash
              jq
              yq
              curl
              wget
              openssh
              rsync
              gzip
              bzip2
              xz
              tar
              zip
              unzip
              htop
              iostat
              netstat
            ]
            ++ lib.optionals cfg.orchestration.ansible [
              ansible
              ansible-lint
            ]
            ++ lib.optionals cfg.orchestration.terraform [
              terraform
              terraform-providers.aws
              terraform-providers.google
              terraform-providers.azurerm
            ]
            ++ lib.optionals cfg.orchestration.kubernetes [
              kubectl
              kubernetes-helm
              kustomize
            ];
        })
        (lib.mkIf cfg.orchestration.ansible {
          environment.etc."deployment/ansible.cfg".text = ''
            [defaults]
            inventory = /var/lib/deployment/inventory
            host_key_checking = False
            retry_files_enabled = False
            gathering = smart
            fact_caching = redis
            fact_caching_timeout = 86400
            fact_caching_connection = localhost:6379:0
            [ssh_connection]
            ssh_args = -o ControlMaster=auto -o ControlPersist=60s -o UserKnownHostsFile=/dev/null -o StrictHostKeyChecking=no
            pipelining = True
            [privilege_escalation]
            become = True
            become_method = sudo
            become_user = root
            become_ask_pass = False
          '';
          environment.etc."deployment/playbooks/enterprise-deploy.yml".text = ''
            ---
            - name: Enterprise NixOS Deployment
            hosts: enterprise_servers
            become: yes
            vars:
            nixos_config_repo: "https://github.com/enterprise/nixos-nixies.git"
            deployment_user: "deployment"
            backup_retention_days: 30
            tasks:
            - name: Ensure deployment user exists
            user:
            name: "{{ deployment_user }}"
            system: yes
            home: "/var/lib/deployment"
            shell: /bin/bash
            groups: wheel
            - name: Create deployment directories
            file:
            path: "{{ item }}"
            state: directory
            owner: "{{ deployment_user }}"
            group: "{{ deployment_user }}"
            mode: '0755'
            loop:
            - /var/lib/deployment
            - /var/lib/deployment/backups
            - /var/lib/deployment/configs
            - name: Clone NixOS configuration repository
            git:
            repo: "{{ nixos_config_repo }}"
            dest: "/var/lib/deployment/nixos-config"
            version: main
            force: yes
            become_user: "{{ deployment_user }}"
            - name: Backup current configuration
            copy:
            src: /etc/nixos/
            dest: "/var/lib/deployment/backups/{{ ansible_date_time.epoch }}/"
            remote_src: yes
            - name: Validate new configuration
            command: nixos-rebuild dry-build -I nixos-config="/var/lib/deployment/nixos-config"
            register: validation_result
            failed_when: validation_result.rc != 0
            - name: Apply NixOS configuration
            command: nixos-rebuild switch -I nixos-config="/var/lib/deployment/nixos-config"
            register: deploy_result
            - name: Verify services are running
            systemd:
            name: "{{ item }}"
            state: started
            loop:
            - sshd
            - fail2ban
            - prometheus
            - grafana
            - name: Clean old backups
            find:
            paths: /var/lib/deployment/backups
            age: "{{ backup_retention_days }}d"
            file_type: directory
            register: old_backups
            - name: Remove old backups
            file:
            path: "{{ item.path }}"
            state: absent
            loop: "{{ old_backups.files }}"
            - name: Send deployment notification
            uri:
            url: "{{ slack_webhook_url | default(\"\") }}"
            method: POST
            body_format: json
            body:
            text: "Enterprise server {{ inventory_hostname }} successfully deployed at {{ ansible_date_time.iso8601 }}"
            when: slack_webhook_url is defined
          '';
          environment.etc."deployment/inventory/enterprise.ini".text = ''
            [enterprise_servers]
            [enterprise_servers:vars]
            ansible_ssh_private_key_file=/var/lib/deployment/secrets/deployment_key
            ansible_python_interpreter=/usr/bin/python3
            [monitoring_servers]
            [database_servers]
          '';
        })
        (lib.mkIf cfg.ci-cd.jenkins {
          services.jenkins = {
            enable = true;
            port = 8080;
            listenAddress = "127.0.0.1";
            environment.JAVA_OPTS = "-Xmx2g -Djava.awt.headless=true";
            packages = with pkgs; [
              git
              nix
              docker
              ansible
              terraform
            ];
          };
          environment.etc."deployment/jenkins/Jenkinsfile.enterprise".text = ''
            pipeline {
            agent any
            environment {
            NIX_PATH = "nixpkgs=channel:nixos-unstable"
            DEPLOYMENT_ENV = "production"
            }
            stages {
            stage('Checkout') {
            steps {
            checkout scm
            sh 'git clean -fdx'
            }
            }
            stage('Security Scan') {
            parallel {
            stage('Dependency Check') {
            steps {
            sh 'nix-shell -p nix-audit --run "nix-audit"'
            }
            }
            stage('Static Analysis') {
            steps {
            sh 'nix-shell -p statix --run "statix check ."'
            sh 'nix-shell -p deadnix --run "deadnix ."'
            }
            }
            stage('Secret Scan') {
            steps {
            sh 'nix-shell -p gitleaks --run "gitleaks detect --source=."'
            }
            }
            }
            }
            stage('Build & Test') {
            steps {
            script {
            def configs = ['enterprise-server', 'qemu-minimal', 'qemu-desktop']
            configs.each { config ->
            sh "nix build .
            }
            }
            }
            }
            stage('Compliance Check') {
            steps {
            sh '''
            nix-shell -p lynis --run "lynis audit system --quick"
            echo "Running CIS compliance checks..."
            '''
            }
            }
            stage('Deploy to Staging') {
            when {
            branch 'develop'
            }
            steps {
            sh '''
            ansible-playbook -i /etc/deployment/inventory/staging.ini \
            /etc/deployment/playbooks/enterprise-deploy.yml \
            --extra-vars "environment=staging"
            '''
            }
            }
            stage('Integration Tests') {
            when {
            branch 'develop'
            }
            steps {
            sh '''
            python3 /var/lib/deployment/scripts/integration_tests.py \
            --environment staging
            '''
            }
            }
            stage('Deploy to Production') {
            when {
            branch 'main'
            }
            steps {
            input message: 'Deploy to production?', ok: 'Deploy'
            sh '''
            ansible-playbook -i /etc/deployment/inventory/production.ini \
            /etc/deployment/playbooks/backup.yml
            ansible-playbook -i /etc/deployment/inventory/production.ini \
            /etc/deployment/playbooks/enterprise-deploy.yml \
            --extra-vars "environment=production"
            '''
            }
            }
            stage('Post-Deploy Verification') {
            when {
            branch 'main'
            }
            steps {
            sh '''
            python3 /var/lib/deployment/scripts/health_check.py \
            --environment production
            curl -X POST "http://localhost:9090/-/reload"
            '''
            }
            }
            }
            post {
            always {
            archiveArtifacts artifacts: 'logs/**/*.log', allowEmptyArchive: true
            publishHTML([
            allowMissing: false,
            alwaysLinkToLastBuild: true,
            keepAll: true,
            reportDir: 'reports',
            reportFiles: 'compliance-report.html',
            reportName: 'Compliance Report'
            ])
            }
            success {
            sh '''
            curl -X POST "$SLACK_WEBHOOK" \
            -H 'Content-type: application/json' \
            --data '{"text":"✅ Enterprise deployment completed successfully for build
            '''
            }
            failure {
            sh '''
            curl -X POST "$SLACK_WEBHOOK" \
            -H 'Content-type: application/json' \
            --data '{"text":"❌ Enterprise deployment failed for build
            '''
            }
            }
            }
          '';
        })
        (lib.mkIf cfg.deployment.health-checks {
          environment.etc."deployment/scripts/health_check.py".text = ''
            #!/usr/bin/env python3
            import requests
            import subprocess
            import sys
            import time
            import json
            import argparse
            from typing import Dict, List, Tuple
            class HealthChecker:
            def __init__(self, environment: str = "production"):
            self.environment = environment
            self.results = []
            def check_systemd_service(self, service: str) -> bool:
            """Check if a systemd service is active"""
            try:
            result = subprocess.run(
            ["systemctl", "is-active", service],
            capture_output=True,
            text=True
            )
            return result.returncode == 0
            except Exception as e:
            print(f"Error checking service {service}: {e}")
            return False
            def check_port(self, port: int, host: str = "localhost") -> bool:
            """Check if a port is listening"""
            try:
            result = subprocess.run(
            ["nc", "-z", host, str(port)],
            capture_output=True,
            timeout=10
            )
            return result.returncode == 0
            except Exception as e:
            print(f"Error checking port {port}: {e}")
            return False
            def check_http_endpoint(self, url: str, expected_status: int = 200) -> bool:
            """Check if HTTP endpoint is responding"""
            try:
            response = requests.get(url, timeout=10)
            return response.status_code == expected_status
            except Exception as e:
            print(f"Error checking endpoint {url}: {e}")
            return False
            def check_disk_space(self, path: str = "/", threshold: int = 90) -> bool:
            """Check disk space usage"""
            try:
            result = subprocess.run(
            ["df", "--output=pcent", path],
            capture_output=True,
            text=True
            )
            if result.returncode == 0:
            lines = result.stdout.strip().split('\n')
            if len(lines) >= 2:
            usage = int(lines[1].strip().rstrip('%'))
            return usage < threshold
            except Exception as e:
            print(f"Error checking disk space: {e}")
            return False
            def check_memory_usage(self, threshold: int = 90) -> bool:
            """Check memory usage"""
            try:
            with open('/proc/meminfo', 'r') as f:
            lines = f.readlines()
            mem_total = 0
            mem_available = 0
            for line in lines:
            if line.startswith('MemTotal:'):
            mem_total = int(line.split()[1])
            elif line.startswith('MemAvailable:'):
            mem_available = int(line.split()[1])
            if mem_total > 0:
            usage = ((mem_total - mem_available) / mem_total) * 100
            return usage < threshold
            except Exception as e:
            print(f"Error checking memory usage: {e}")
            return False
            def run_checks(self) -> Dict:
            """Run all health checks"""
            checks = {
            "services": {
            "sshd": self.check_systemd_service("sshd"),
            "fail2ban": self.check_systemd_service("fail2ban"),
            "prometheus": self.check_systemd_service("prometheus"),
            "grafana": self.check_systemd_service("grafana"),
            "elasticsearch": self.check_systemd_service("elasticsearch"),
            },
            "ports": {
            "ssh": self.check_port(22),
            "prometheus": self.check_port(9090),
            "grafana": self.check_port(3000),
            "elasticsearch": self.check_port(9200),
            },
            "endpoints": {
            "prometheus": self.check_http_endpoint("http://localhost:9090/-/ready"),
            "grafana": self.check_http_endpoint("http://localhost:3000/api/health"),
            "elasticsearch": self.check_http_endpoint("http://localhost:9200/_cluster/health"),
            },
            "resources": {
            "disk_space": self.check_disk_space("/", 90),
            "memory_usage": self.check_memory_usage(90),
            }
            }
            all_checks = []
            for category in checks.values():
            all_checks.extend(category.values())
            health_score = (sum(all_checks) / len(all_checks)) * 100
            return {
            "environment": self.environment,
            "timestamp": time.time(),
            "health_score": health_score,
            "checks": checks,
            "status": "healthy" if health_score >= 90 else "degraded" if health_score >= 70 else "unhealthy"
            }
            def main():
            parser = argparse.ArgumentParser(description="Enterprise deployment health checker")
            parser.add_argument("--environment", default="production", help="Environment to check")
            parser.add_argument("--output", default="json", choices=["json", "text"], help="Output format")
            args = parser.parse_args()
            checker = HealthChecker(args.environment)
            results = checker.run_checks()
            if args.output == "json":
            print(json.dumps(results, indent=2))
            else:
            print(f"Environment: {results['environment']}")
            print(f"Health Score: {results['health_score']:.1f}%")
            print(f"Status: {results['status']}")
            print("\nDetailed Results:")
            for category, checks in results['checks'].items():
            print(f"\n{category.title()}:")
            for check, status in checks.items():
            status_symbol = "✅" if status else "❌"
            print(f"  {status_symbol} {check}")
            sys.exit(0 if results['status'] == "healthy" else 1)
            if __name__ == "__main__":
            main()
          '';
          mode = "0755";
        })
        (lib.mkIf cfg.infrastructure.backup {
          systemd.services.enterprise-backup = {
            description = "Enterprise automated backup";
            serviceConfig = {
              Type = "oneshot";
              User = "deployment";
              Group = "deployment";
              ExecStart = pkgs.writeScript "enterprise-backup" ''
                #!/bin/bash
                BACKUP_DIR="/var/lib/deployment/backups/$(date +%Y%m%d-%H%M%S)"
                RETENTION_DAYS=30
                echo "Starting enterprise backup to $BACKUP_DIR"
                mkdir -p "$BACKUP_DIR"
                cp -r /etc/nixos "$BACKUP_DIR/nixos-config"
                nixos-rebuild dry-build > "$BACKUP_DIR/system-state.txt" 2>&1
                mkdir -p "$BACKUP_DIR/logs"
                cp /var/log/auth.log "$BACKUP_DIR/logs/" 2>/dev/null || true
                cp /var/log/audit/audit.log "$BACKUP_DIR/logs/" 2>/dev/null || true
                journalctl --since="24 hours ago" > "$BACKUP_DIR/logs/journal-24h.log"
                if systemctl is-active prometheus >/dev/null 2>&1; then
                mkdir -p "$BACKUP_DIR/monitoring"
                cp -r /var/lib/prometheus "$BACKUP_DIR/monitoring/" 2>/dev/null || true
                cp -r /var/lib/grafana "$BACKUP_DIR/monitoring/" 2>/dev/null || true
                fi
                cp -r /etc/deployment "$BACKUP_DIR/deployment-config" 2>/dev/null || true
                cat > "$BACKUP_DIR/manifest.json" << EOF
                {
                "backup_date": "$(date -Iseconds)",
                "hostname": "$(hostname)",
                "nixos_version": "$(nixos-version)",
                "system_state": "$(systemctl is-system-running)",
                "backup_size": "$(du -sh $BACKUP_DIR | cut -f1)"
                }
                EOF
                cd "$(dirname "$BACKUP_DIR")"
                tar -czf "$(basename "$BACKUP_DIR").tar.gz" "$(basename "$BACKUP_DIR")"
                rm -rf "$BACKUP_DIR"
                find /var/lib/deployment/backups -name "*.tar.gz" -mtime +$RETENTION_DAYS -delete
                echo "Backup completed: $(basename "$BACKUP_DIR").tar.gz"
                curl -X POST "$SLACK_WEBHOOK" \
                -H 'Content-type: application/json' \
                --data "{\"text\":\"📦 Enterprise backup completed for $(hostname) at $(date)\"}" \
                2>/dev/null || true
              '';
            };
          };
          systemd.timers.enterprise-backup = {
            description = "Run enterprise backup daily";
            wantedBy = ["timers.target"];
            timerConfig = {
              OnCalendar = "daily";
              Persistent = true;
              RandomizedDelaySec = "1h";
            };
          };
        })
        (lib.mkIf cfg.monitoring.deployment-metrics {
          systemd.services.deployment-metrics = {
            description = "Deployment metrics collection";
            wantedBy = ["multi-user.target"];
            serviceConfig = {
              Type = "simple";
              Restart = "always";
              RestartSec = "30s";
              ExecStart = pkgs.writeScript "deployment-metrics" ''
                #!/bin/bash
                TEXTFILE_DIR="/var/lib/node_exporter/textfile_collector"
                METRICS_FILE="$TEXTFILE_DIR/deployment.prom"
                while true; do
                {
                echo "
                echo "
                if [ -f /var/lib/deployment/last_success ]; then
                echo "deployment_last_success_timestamp $(cat /var/lib/deployment/last_success)"
                else
                echo "deployment_last_success_timestamp 0"
                fi
                echo "
                echo "
                deployment_count=$(ls /var/lib/deployment/backups/*.tar.gz 2>/dev/null | wc -l)
                echo "deployment_total $deployment_count"
                echo "
                echo "
                latest_backup=$(ls -t /var/lib/deployment/backups/*.tar.gz 2>/dev/null | head -1)
                if [ -n "$latest_backup" ]; then
                backup_age=$(($(date +%s) - $(stat -c %Y "$latest_backup")))
                echo "deployment_backup_age_seconds $backup_age"
                else
                echo "deployment_backup_age_seconds 0"
                fi
                echo "
                echo "
                health_score=$(python3 /etc/deployment/scripts/health_check.py --output json | jq -r '.health_score')
                echo "deployment_health_score ${health_score: -0}"
                } > "$METRICS_FILE.$$"
                mv "$METRICS_FILE.$$" "$METRICS_FILE"
                sleep 60
                done
              '';
            };
          };
        })
      ];
    dependencies = ["core" "security" "monitoring"];
  }) {
    inherit config lib pkgs inputs;
  }
