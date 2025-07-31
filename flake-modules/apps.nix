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
      install = {
        type = "app";
        program = toString (pkgs.writeShellScript "unified-install" ''
          set -euo pipefail
          if [ $
          echo "Usage: nix run .
          echo ""
          echo "Profiles:"
          echo "  base         - Minimal server installation"
          echo "  workstation  - Desktop workstation"
          echo "  server       - Production server"
          echo "  development  - Development environment"
          echo ""
          echo "Examples:"
          echo "  nix run .
          echo "  nix run .
          exit 1
          fi
          profile="$1"
          hostname="$2"
          disk="''${3:-}"
          echo "🏗️  Installing NixOS Unified: $profile profile on $hostname"
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
          if [ -z "$disk" ]; then
          echo "🔍 Auto-detecting installation disk..."
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
          echo "🚀 Starting installation..."
          echo "📋 Generating hardware configuration..."
          nixos-generate-config --root /mnt --show-hardware-config > /tmp/hardware-configuration.nix
          echo "💾 Partitioning disk $disk..."
          nix run github:nix-community/disko -- --mode disko \
          ${../configurations/disko}/$profile.nix \
          --arg disk "\"$disk\""
          echo "📦 Installing NixOS with unified configuration..."
          nixos-install --flake ".
          echo "✅ Installation completed successfully!"
          echo ""
          echo "Next steps:"
          echo "1. Reboot into the new system"
          echo "2. Set user passwords: passwd <username>"
          echo "3. Configure SSH keys: ssh-copy-id user@$hostname"
          echo "4. Deploy updates: nix run .
        '');
      };
      validate = {
        type = "app";
        program = toString (pkgs.writeShellScript "unified-validate" ''
          set -euo pipefail
          echo "🔍 Validating NixOS Unified configuration..."
          echo "📝 Checking Nix syntax..."
          find . -name "*.nix" -type f | while IFS= read -r file; do
          echo "  Checking: $file"
          nix-instantiate --parse "$file" > /dev/null
          done
          echo "📦 Validating flake..."
          nix flake check --all-systems
          echo "🔒 Running security checks..."
          nix run .
          echo "⚡ Running performance checks..."
          nix run .
          echo "✅ All validation checks passed!"
        '');
      };
      security-audit = {
        type = "app";
        program = toString (pkgs.writeShellScript "security-audit" ''
          set -euo pipefail
          echo "🛡️  Running security audit..."
          echo "🔍 Scanning for security vulnerabilities..."
          if grep -r "firewall\.enable.*false" . --include="*.nix" >/dev/null 2>&1; then
          echo "❌ CRITICAL: Disabled firewall found!"
          grep -r "firewall\.enable.*false" . --include="*.nix"
          exit 1
          fi
          if grep -r "PermitRootLogin.*yes" . --include="*.nix" >/dev/null 2>&1; then
          echo "❌ CRITICAL: Root SSH login enabled!"
          grep -r "PermitRootLogin.*yes" . --include="*.nix"
          exit 1
          fi
          if grep -r "PasswordAuthentication.*true" . --include="*.nix" >/dev/null 2>&1; then
          echo "⚠️  WARNING: SSH password authentication enabled"
          grep -r "PasswordAuthentication.*true" . --include="*.nix"
          fi
          if grep -r "password.*=" . --include="*.nix" | grep -v "hashedPassword" >/dev/null 2>&1; then
          echo "❌ CRITICAL: Hardcoded passwords found!"
          grep -r "password.*=" . --include="*.nix" | grep -v "hashedPassword"
          exit 1
          fi
          if grep -r "wheelNeedsPassword.*false" . --include="*.nix" >/dev/null 2>&1; then
          echo "⚠️  WARNING: Passwordless sudo enabled"
          grep -r "wheelNeedsPassword.*false" . --include="*.nix"
          fi
          echo "✅ Security audit completed"
        '');
      };
      performance-check = {
        type = "app";
        program = toString (pkgs.writeShellScript "performance-check" ''
          set -euo pipefail
          echo "⚡ Running performance analysis..."
          echo "📦 Analyzing package lists..."
          find . -name "*.nix" -type f -exec grep -l "home\.packages\|environment\.systemPackages" {} \; | while IFS= read -r file; do
          count=$(grep -c "pkgs\." "$file" 2>/dev/null || echo 0)
          if [ "$count" -gt 50 ]; then
          echo "⚠️  Large package list in $file: $count packages"
          fi
          done
          echo "🔍 Checking for performance anti-patterns..."
          if grep -r "with pkgs;" . --include="*.nix" | wc -l | xargs test 10 -lt; then
          echo "⚠️  Multiple 'with pkgs;' statements found (may slow evaluation)"
          fi
          echo "⏱️  Estimating build complexity..."
          total_packages=$(find . -name "*.nix" -exec grep -o "pkgs\." {} \; | wc -l)
          echo "📊 Total package references: $total_packages"
          if [ "$total_packages" -gt 200 ]; then
          echo "⚠️  High package count may increase build times"
          fi
          echo "✅ Performance analysis completed"
        '');
      };
      update = {
        type = "app";
        program = toString (pkgs.writeShellScript "unified-update" ''
          set -euo pipefail
          echo "🔄 Updating NixOS Unified configurations..."
          echo "📦 Updating flake inputs..."
          nix flake update
          echo "🏗️  Testing configuration builds..."
          configs=(workstation server development base)
          for config in "''${configs[@]}"; do
          echo "  Building $config..."
          nix build ".
          done
          echo "🔍 Validating updated configurations..."
          nix run .
          echo "✅ Update completed successfully"
          echo ""
          echo "Next steps:"
          echo "1. Review changes: git diff"
          echo "2. Test deployment: nix run .
          echo "3. Commit changes: git add . && git commit -m 'Update configurations'"
        '');
      };
      clean = {
        type = "app";
        program = toString (pkgs.writeShellScript "unified-clean" ''
          set -euo pipefail
          echo "🧹 Cleaning build artifacts..."
          find . -name "result*" -type l -delete
          echo "🗑️  Cleaning Nix store..."
          nix-collect-garbage -d
          echo "📦 Optimizing Nix store..."
          nix store optimise
          echo "✅ Cleanup completed"
        '');
      };
      dev-setup = {
        type = "app";
        program = toString (pkgs.writeShellScript "dev-setup" ''
          set -euo pipefail
          echo "🛠️  Setting up development environment..."
          echo "🔧 Installing pre-commit hooks..."
          cat > .git/hooks/pre-commit << 'EOF'
          #!/usr/bin/env bash
          set -euo pipefail
          echo "🔍 Running pre-commit validation..."
          echo "🎨 Formatting Nix code..."
          alejandra . --quiet
          echo "📝 Validating syntax..."
          find . -name "*.nix" -type f | while IFS= read -r file; do
          nix-instantiate --parse "$file" > /dev/null
          done
          echo "🔒 Running security checks..."
          nix run .
          echo "✅ Pre-commit validation passed"
          EOF
          chmod +x .git/hooks/pre-commit
          echo "📝 Setting up editor integration..."
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
          echo "  nix run .
          echo "  nix run .
          echo "  nix run .
        '');
      };
    };
  };
}
