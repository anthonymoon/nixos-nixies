{
  self,
  inputs,
  ...
}: {
  flake.deploy = {
    sshUser = "deploy";
    sshOpts = [
      "-o"
      "StrictHostKeyChecking=accept-new"
      "-o"
      "UserKnownHostsFile=/dev/null"
      "-o"
      "ServerAliveInterval=30"
    ];
    magicRollback = true;
    autoRollback = true;
    nodes = {
      workstation = {
        hostname = "workstation.local";
        profiles.system = {
          user = "root";
          path =
            inputs.deploy-rs.lib.x86_64-linux.activate.nixos
            self.nixosConfigurations.workstation;
          hooks.preActivate = [
            "unified-validate-security"
            "unified-backup-config"
            "unified-check-dependencies"
          ];
          hooks.postActivate = [
            "unified-health-check"
            "unified-security-audit"
            "unified-performance-check"
          ];
        };
        profiles.user = {
          user = "workstation-user";
          path =
            inputs.deploy-rs.lib.x86_64-linux.activate.home-manager
            self.homeConfigurations."workstation-user@workstation";
        };
      };
      server = {
        hostname = "server.example.com";
        profiles.system = {
          user = "root";
          path =
            inputs.deploy-rs.lib.x86_64-linux.activate.nixos
            self.nixosConfigurations.server;
          hooks.preActivate = [
            "unified-security-scan-strict"
            "unified-compliance-check"
            "unified-backup-full"
            "unified-downtime-notification"
          ];
          hooks.postActivate = [
            "unified-service-validation"
            "unified-security-baseline-check"
            "unified-performance-benchmark"
            "unified-uptime-notification"
          ];
        };
        remoteBuild = true;
        autoRollback = true;
        magicRollback = true;
      };
      development = {
        hostname = "dev.local";
        profiles.system = {
          user = "root";
          path =
            inputs.deploy-rs.lib.x86_64-linux.activate.nixos
            self.nixosConfigurations.development;
          hooks.preActivate = [
            "unified-validate-syntax"
            "unified-check-basic-security"
          ];
          hooks.postActivate = [
            "unified-quick-health-check"
          ];
        };
        remoteBuild = false;
        autoRollback = false;
      };
    };
  };
  perSystem = {
    config,
    pkgs,
    system,
    ...
  }: {
    apps = {
    deploy-workstation = {
      type = "app";
      program = toString (pkgs.writeShellScript "deploy-workstation" ''
        set -euo pipefail
        echo "🚀 Deploying workstation configuration..."
        echo "🔍 Running pre-deployment checks..."
        nix run .
        ${inputs.deploy-rs.packages.${system}.default}/bin/deploy \
        --hostname workstation.local \
        --profile system \
        --magic-rollback \
        --auto-rollback
        echo "✅ Workstation deployment completed successfully"
      '');
    };
    deploy-server = {
      type = "app";
      program = toString (pkgs.writeShellScript "deploy-server" ''
        set -euo pipefail
        echo "🏢 Deploying server configuration..."
        echo "🔒 Running security validation..."
        nix run .
        echo "⚡ Running performance validation..."
        nix run .
        echo "🔧 Running configuration validation..."
        nix run .
        ${inputs.deploy-rs.packages.${system}.default}/bin/deploy \
        --hostname server.example.com \
        --profile system \
        --remote-build \
        --magic-rollback \
        --auto-rollback
        echo "✅ Server deployment completed successfully"
      '');
    };
    rollback = {
      type = "app";
      program = toString (pkgs.writeShellScript "rollback" ''
        set -euo pipefail
        if [ $
        echo "Usage: nix run .
        exit 1
        fi
        hostname="$1"
        echo "🔄 Rolling back $hostname to previous configuration..."
        ${inputs.deploy-rs.packages.${system}.default}/bin/deploy \
        --hostname "$hostname" \
        --rollback
        echo "✅ Rollback completed for $hostname"
      '');
    };
    health-check = {
      type = "app";
      program = toString (pkgs.writeShellScript "health-check" ''
        set -euo pipefail
        if [ $
        echo "Usage: nix run .
        exit 1
        fi
        hostname="$1"
        echo "🩺 Running health check on $hostname..."
        ssh "$hostname" '
        echo "System Status:"
        systemctl is-system-running
        echo -e "\nCritical Services:"
        systemctl status sshd NetworkManager
        echo -e "\nDisk Usage:"
        df -h / /boot 2>/dev/null || true
        echo -e "\nMemory Usage:"
        free -h
        echo -e "\nLoad Average:"
        uptime
        echo -e "\nFailed Services:"
        systemctl --failed --no-legend || echo "No failed services"
        '
        echo "✅ Health check completed for $hostname"
      '');
    };
    };
  };
}
