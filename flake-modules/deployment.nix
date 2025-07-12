{
  self,
  inputs,
  ...
}: {
  flake.deploy = {
    # SSH connection settings
    sshUser = "deploy";
    sshOpts = [
      "-o"
      "StrictHostKeyChecking=accept-new"
      "-o"
      "UserKnownHostsFile=/dev/null"
      "-o"
      "ServerAliveInterval=30"
    ];

    # Default deployment settings
    magicRollback = true;
    autoRollback = true;

    # Node configurations
    nodes = {
      # Example workstation deployment
      workstation = {
        hostname = "workstation.local";

        profiles.system = {
          user = "root";
          path =
            inputs.deploy-rs.lib.x86_64-linux.activate.nixos
            self.nixosConfigurations.workstation;

          # Pre-activation hooks
          hooks.preActivate = [
            "unified-validate-security"
            "unified-backup-config"
            "unified-check-dependencies"
          ];

          # Post-activation hooks
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

      # Example server deployment
      server = {
        hostname = "server.example.com";

        profiles.system = {
          user = "root";
          path =
            inputs.deploy-rs.lib.x86_64-linux.activate.nixos
            self.nixosConfigurations.server;

          # Stricter validation for production
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

        # Production deployment settings
        remoteBuild = true;
        autoRollback = true;
        magicRollback = true;
      };

      # Development/testing deployment
      development = {
        hostname = "dev.local";

        profiles.system = {
          user = "root";
          path =
            inputs.deploy-rs.lib.x86_64-linux.activate.nixos
            self.nixosConfigurations.development;

          # Faster deployment for development
          hooks.preActivate = [
            "unified-validate-syntax"
            "unified-check-basic-security"
          ];

          hooks.postActivate = [
            "unified-quick-health-check"
          ];
        };

        # Development settings
        remoteBuild = false;
        autoRollback = false;
      };
    };
  };

  flake.apps = {
    # Deployment applications
    deploy-workstation = {
      type = "app";
      program = toString (inputs.nixpkgs.legacyPackages.x86_64-linux.writeShellScript "deploy-workstation" ''
        set -euo pipefail
        echo "🚀 Deploying workstation configuration..."

        # Pre-deployment validation
        echo "🔍 Running pre-deployment checks..."
        nix run .#validate-config

        # Deploy with rollback capability
        ${inputs.deploy-rs.packages.x86_64-linux.default}/bin/deploy \
          --hostname workstation.local \
          --profile system \
          --magic-rollback \
          --auto-rollback

        echo "✅ Workstation deployment completed successfully"
      '');
    };

    deploy-server = {
      type = "app";
      program = toString (inputs.nixpkgs.legacyPackages.x86_64-linux.writeShellScript "deploy-server" ''
        set -euo pipefail
        echo "🏢 Deploying server configuration..."

        # Comprehensive pre-deployment validation
        echo "🔒 Running security validation..."
        nix run .#security-audit

        echo "⚡ Running performance validation..."
        nix run .#performance-check

        echo "🔧 Running configuration validation..."
        nix run .#validate-config

        # Production deployment with full validation
        ${inputs.deploy-rs.packages.x86_64-linux.default}/bin/deploy \
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
      program = toString (inputs.nixpkgs.legacyPackages.x86_64-linux.writeShellScript "rollback" ''
        set -euo pipefail

        if [ $# -eq 0 ]; then
          echo "Usage: nix run .#rollback <hostname>"
          exit 1
        fi

        hostname="$1"

        echo "🔄 Rolling back $hostname to previous configuration..."

        # Rollback using deploy-rs
        ${inputs.deploy-rs.packages.x86_64-linux.default}/bin/deploy \
          --hostname "$hostname" \
          --rollback

        echo "✅ Rollback completed for $hostname"
      '');
    };

    health-check = {
      type = "app";
      program = toString (inputs.nixpkgs.legacyPackages.x86_64-linux.writeShellScript "health-check" ''
        set -euo pipefail

        if [ $# -eq 0 ]; then
          echo "Usage: nix run .#health-check <hostname>"
          exit 1
        fi

        hostname="$1"

        echo "🩺 Running health check on $hostname..."

        # System health checks
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
}
