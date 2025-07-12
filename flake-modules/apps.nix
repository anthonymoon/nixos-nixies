{
  self,
  inputs,
  ...
}: {
  perSystem = {
    config,
    self',
    inputs',
    pkgs,
    system,
    ...
  }: {
    apps = {
      # System installation app
      install = {
        type = "app";
        program = toString (pkgs.writeShellScript "unified-install" ''
          set -euo pipefail

          if [ $# -lt 2 ]; then
            echo "Usage: nix run .#install <profile> <hostname> [disk]"
            echo ""
            echo "Profiles:"
            echo "  base         - Minimal server installation"
            echo "  workstation  - Desktop workstation"
            echo "  server       - Production server"
            echo "  development  - Development environment"
            echo ""
            echo "Examples:"
            echo "  nix run .#install workstation my-laptop"
            echo "  nix run .#install server my-server /dev/nvme0n1"
            exit 1
          fi

          profile="$1"
          hostname="$2"
          disk="''${3:-}"

          echo "🏗️  Installing NixOS Unified: $profile profile on $hostname"

          # Validate profile exists
          case "$profile" in
            base|workstation|server|development)
              echo "✅ Using profile: $profile"
              ;;
            *)
              echo "❌ Error: Unknown profile '$profile'"
              echo "Available profiles: base, workstation, server, development"
              exit 1
              ;;
          esac

          # Auto-detect disk if not provided
          if [ -z "$disk" ]; then
            echo "🔍 Auto-detecting installation disk..."

            # Look for common disk types
            for candidate in /dev/nvme0n1 /dev/sda /dev/vda; do
              if [ -b "$candidate" ]; then
                disk="$candidate"
                echo "📀 Found disk: $disk"
                break
              fi
            done

            if [ -z "$disk" ]; then
              echo "❌ Error: Could not auto-detect disk. Please specify disk as third argument."
              exit 1
            fi
          fi

          # Confirm installation
          echo ""
          echo "⚠️  WARNING: This will ERASE ALL DATA on $disk"
          echo "   Profile: $profile"
          echo "   Hostname: $hostname"
          echo "   Disk: $disk"
          echo ""
          read -p "Continue? (yes/no): " confirm

          if [ "$confirm" != "yes" ]; then
            echo "Installation cancelled."
            exit 0
          fi

          # Run installation
          echo "🚀 Starting installation..."

          # Generate hardware configuration
          echo "📋 Generating hardware configuration..."
          nixos-generate-config --root /mnt --show-hardware-config > /tmp/hardware-configuration.nix

          # Partition disk using disko
          echo "💾 Partitioning disk $disk..."
          nix run github:nix-community/disko -- --mode disko \
            ${./disko-configs}/$profile.nix \
            --arg disk "\"$disk\""

          # Install NixOS
          echo "📦 Installing NixOS with unified configuration..."
          nixos-install --flake ".#$hostname" --root /mnt --no-root-passwd

          echo "✅ Installation completed successfully!"
          echo ""
          echo "Next steps:"
          echo "1. Reboot into the new system"
          echo "2. Set user passwords: passwd <username>"
          echo "3. Configure SSH keys: ssh-copy-id user@$hostname"
          echo "4. Deploy updates: nix run .#deploy-$profile"
        '');
      };

      # Configuration validation
      validate = {
        type = "app";
        program = toString (pkgs.writeShellScript "unified-validate" ''
          set -euo pipefail

          echo "🔍 Validating NixOS Unified configuration..."

          # Syntax validation
          echo "📝 Checking Nix syntax..."
          find . -name "*.nix" -type f | while IFS= read -r file; do
            echo "  Checking: $file"
            nix-instantiate --parse "$file" > /dev/null
          done

          # Flake validation
          echo "📦 Validating flake..."
          nix flake check --all-systems

          # Security validation
          echo "🔒 Running security checks..."
          nix run .#security-audit

          # Performance validation
          echo "⚡ Running performance checks..."
          nix run .#performance-check

          echo "✅ All validation checks passed!"
        '');
      };

      # Security audit
      security-audit = {
        type = "app";
        program = toString (pkgs.writeShellScript "security-audit" ''
          set -euo pipefail

          echo "🛡️  Running security audit..."

          # Check for security issues in configurations
          echo "🔍 Scanning for security vulnerabilities..."

          # Check for disabled firewalls
          if grep -r "firewall\.enable.*false" . --include="*.nix" >/dev/null 2>&1; then
            echo "❌ CRITICAL: Disabled firewall found!"
            grep -r "firewall\.enable.*false" . --include="*.nix"
            exit 1
          fi

          # Check for root SSH login
          if grep -r "PermitRootLogin.*yes" . --include="*.nix" >/dev/null 2>&1; then
            echo "❌ CRITICAL: Root SSH login enabled!"
            grep -r "PermitRootLogin.*yes" . --include="*.nix"
            exit 1
          fi

          # Check for password authentication
          if grep -r "PasswordAuthentication.*true" . --include="*.nix" >/dev/null 2>&1; then
            echo "⚠️  WARNING: SSH password authentication enabled"
            grep -r "PasswordAuthentication.*true" . --include="*.nix"
          fi

          # Check for hardcoded passwords
          if grep -r "password.*=" . --include="*.nix" | grep -v "hashedPassword" >/dev/null 2>&1; then
            echo "❌ CRITICAL: Hardcoded passwords found!"
            grep -r "password.*=" . --include="*.nix" | grep -v "hashedPassword"
            exit 1
          fi

          # Check for sudo without password
          if grep -r "wheelNeedsPassword.*false" . --include="*.nix" >/dev/null 2>&1; then
            echo "⚠️  WARNING: Passwordless sudo enabled"
            grep -r "wheelNeedsPassword.*false" . --include="*.nix"
          fi

          echo "✅ Security audit completed"
        '');
      };

      # Performance check
      performance-check = {
        type = "app";
        program = toString (pkgs.writeShellScript "performance-check" ''
          set -euo pipefail

          echo "⚡ Running performance analysis..."

          # Check for large package lists
          echo "📦 Analyzing package lists..."
          find . -name "*.nix" -type f -exec grep -l "home\.packages\|environment\.systemPackages" {} \; | while IFS= read -r file; do
            count=$(grep -c "pkgs\." "$file" 2>/dev/null || echo 0)
            if [ "$count" -gt 50 ]; then
              echo "⚠️  Large package list in $file: $count packages"
            fi
          done

          # Check for performance-impacting patterns
          echo "🔍 Checking for performance anti-patterns..."

          # Check for eager evaluation patterns
          if grep -r "with pkgs;" . --include="*.nix" | wc -l | xargs test 10 -lt; then
            echo "⚠️  Multiple 'with pkgs;' statements found (may slow evaluation)"
          fi

          # Build time estimation
          echo "⏱️  Estimating build complexity..."
          total_packages=$(find . -name "*.nix" -exec grep -o "pkgs\." {} \; | wc -l)
          echo "📊 Total package references: $total_packages"

          if [ "$total_packages" -gt 200 ]; then
            echo "⚠️  High package count may increase build times"
          fi

          echo "✅ Performance analysis completed"
        '');
      };

      # Update system configurations
      update = {
        type = "app";
        program = toString (pkgs.writeShellScript "unified-update" ''
          set -euo pipefail

          echo "🔄 Updating NixOS Unified configurations..."

          # Update flake inputs
          echo "📦 Updating flake inputs..."
          nix flake update

          # Rebuild all configurations to check for issues
          echo "🏗️  Testing configuration builds..."

          configs=(workstation server development base)
          for config in "''${configs[@]}"; do
            echo "  Building $config..."
            nix build ".#nixosConfigurations.$config.config.system.build.toplevel" --no-link
          done

          # Run validation
          echo "🔍 Validating updated configurations..."
          nix run .#validate

          echo "✅ Update completed successfully"
          echo ""
          echo "Next steps:"
          echo "1. Review changes: git diff"
          echo "2. Test deployment: nix run .#deploy-<target>"
          echo "3. Commit changes: git add . && git commit -m 'Update configurations'"
        '');
      };

      # Clean build artifacts
      clean = {
        type = "app";
        program = toString (pkgs.writeShellScript "unified-clean" ''
          set -euo pipefail

          echo "🧹 Cleaning build artifacts..."

          # Remove result symlinks
          find . -name "result*" -type l -delete

          # Clean Nix store (with confirmation)
          echo "🗑️  Cleaning Nix store..."
          nix-collect-garbage -d

          # Optimize store
          echo "📦 Optimizing Nix store..."
          nix store optimise

          echo "✅ Cleanup completed"
        '');
      };

      # Development setup
      dev-setup = {
        type = "app";
        program = toString (pkgs.writeShellScript "dev-setup" ''
          set -euo pipefail

          echo "🛠️  Setting up development environment..."

          # Install pre-commit hooks
          echo "🔧 Installing pre-commit hooks..."
          cat > .git/hooks/pre-commit << 'EOF'
          #!/usr/bin/env bash
          set -euo pipefail

          echo "🔍 Running pre-commit validation..."

          # Format code
          echo "🎨 Formatting Nix code..."
          alejandra . --quiet

          # Validate syntax
          echo "📝 Validating syntax..."
          find . -name "*.nix" -type f | while IFS= read -r file; do
            nix-instantiate --parse "$file" > /dev/null
          done

          # Security check
          echo "🔒 Running security checks..."
          nix run .#security-audit

          echo "✅ Pre-commit validation passed"
          EOF

          chmod +x .git/hooks/pre-commit

          # Setup editor integration
          echo "📝 Setting up editor integration..."

          # VSCode settings
          mkdir -p .vscode
          cat > .vscode/settings.json << 'EOF'
          {
            "nix.enableLanguageServer": true,
            "nix.serverPath": "nil",
            "editor.formatOnSave": true,
            "[nix]": {
              "editor.defaultFormatter": "kamadorueda.alejandra"
            }
          }
          EOF

          # Recommended extensions
          cat > .vscode/extensions.json << 'EOF'
          {
            "recommendations": [
              "jnoortheen.nix-ide",
              "kamadorueda.alejandra",
              "mkhl.direnv"
            ]
          }
          EOF

          echo "✅ Development environment setup completed"
          echo ""
          echo "Available commands:"
          echo "  nix develop          - Enter development shell"
          echo "  nix run .#validate   - Validate configuration"
          echo "  nix run .#install    - Install system"
          echo "  nix run .#deploy-*   - Deploy to target"
        '');
      };
    };
  };
}
