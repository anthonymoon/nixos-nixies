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
    packages = {
      # Unified installer script
      installer = pkgs.writeShellScriptBin "nixos-unified-installer" ''
        set -euo pipefail

        # Color codes
        RED='\033[0;31m'
        GREEN='\033[0;32m'
        YELLOW='\033[1;33m'
        BLUE='\033[0;34m'
        NC='\033[0m'

        print_info() {
          echo -e "''${BLUE}[INFO]''${NC} $1"
        }

        print_success() {
          echo -e "''${GREEN}[SUCCESS]''${NC} $1"
        }

        print_warning() {
          echo -e "''${YELLOW}[WARNING]''${NC} $1"
        }

        print_error() {
          echo -e "''${RED}[ERROR]''${NC} $1"
        }

        show_usage() {
          echo "NixOS Unified Installer"
          echo ""
          echo "Usage: $0 <profile> <hostname> [disk]"
          echo ""
          echo "Profiles:"
          echo "  workstation  - Desktop workstation with Niri/Hyprland"
          echo "  server       - Hardened server configuration"
          echo "  development  - Development environment"
          echo "  gaming       - Gaming-optimized workstation"
          echo "  base         - Minimal base system"
          echo ""
          echo "Examples:"
          echo "  $0 workstation my-laptop"
          echo "  $0 server my-server /dev/nvme0n1"
          echo ""
        }

        if [ $# -lt 2 ]; then
          show_usage
          exit 1
        fi

        profile="$1"
        hostname="$2"
        disk="''${3:-}"

        # Validate profile
        case "$profile" in
          workstation|server|development|gaming|base)
            print_info "Using profile: $profile"
            ;;
          *)
            print_error "Unknown profile: $profile"
            show_usage
            exit 1
            ;;
        esac

        # Auto-detect disk if not provided
        if [ -z "$disk" ]; then
          print_info "Auto-detecting installation disk..."

          for candidate in /dev/nvme0n1 /dev/sda /dev/vda; do
            if [ -b "$candidate" ]; then
              disk="$candidate"
              print_info "Found disk: $disk"
              break
            fi
          done

          if [ -z "$disk" ]; then
            print_error "Could not auto-detect disk. Please specify as third argument."
            exit 1
          fi
        fi

        # Confirmation
        print_warning "This will ERASE ALL DATA on $disk"
        echo "  Profile: $profile"
        echo "  Hostname: $hostname"
        echo "  Disk: $disk"
        echo ""
        read -p "Continue? (yes/no): " confirm

        if [ "$confirm" != "yes" ]; then
          print_info "Installation cancelled."
          exit 0
        fi

        # Installation process
        print_info "Starting NixOS Unified installation..."

        # Partition disk (simple UEFI layout)
        print_info "Partitioning disk..."
        parted "$disk" -- mklabel gpt
        parted "$disk" -- mkpart primary 512MiB -8GiB
        parted "$disk" -- mkpart primary linux-swap -8GiB 100%
        parted "$disk" -- mkpart ESP fat32 1MiB 512MiB
        parted "$disk" -- set 3 esp on

        # Format partitions
        print_info "Formatting partitions..."
        mkfs.ext4 -L nixos "''${disk}p1" || mkfs.ext4 -L nixos "''${disk}1"
        mkswap -L swap "''${disk}p2" || mkswap -L swap "''${disk}2"
        mkfs.fat -F 32 -n boot "''${disk}p3" || mkfs.fat -F 32 -n boot "''${disk}3"

        # Mount filesystems
        print_info "Mounting filesystems..."
        mount /dev/disk/by-label/nixos /mnt
        mkdir -p /mnt/boot
        mount /dev/disk/by-label/boot /mnt/boot
        swapon /dev/disk/by-label/swap

        # Generate hardware configuration
        print_info "Generating hardware configuration..."
        nixos-generate-config --root /mnt

        # Create temporary flake for installation
        print_info "Creating installation configuration..."
        cat > /mnt/etc/nixos/flake.nix << EOF
        {
          inputs = {
            nixpkgs.url = "github:NixOS/nixpkgs/nixos-24.11";
            nixos-unified.url = "github:user/nixos-unified";
          };

          outputs = { nixpkgs, nixos-unified, ... }: {
            nixosConfigurations.$hostname = nixos-unified.lib.mkSystem {
              hostname = "$hostname";
              profiles = [ "$profile" ];
              modules = [
                ./hardware-configuration.nix
              ];
            };
          };
        }
        EOF

        # Install NixOS
        print_info "Installing NixOS..."
        nixos-install --flake "/mnt/etc/nixos#$hostname" --no-root-passwd

        print_success "Installation completed!"
        print_info "Next steps:"
        print_info "1. Reboot: reboot"
        print_info "2. Set user passwords"
        print_info "3. Configure SSH keys"
        print_info "4. Customize configuration in /etc/nixos/flake.nix"
      '';

      # Security audit tool
      security-audit = pkgs.writeShellScriptBin "nixos-unified-security-audit" ''
        set -euo pipefail

        echo "🛡️  NixOS Unified Security Audit"
        echo "==============================="
        echo ""

        failed_checks=0

        # Check firewall status
        echo "🔥 Checking firewall..."
        if systemctl is-active --quiet firewall; then
          echo "  ✅ Firewall is active"
        else
          echo "  ❌ Firewall is not active"
          failed_checks=$((failed_checks + 1))
        fi

        # Check SSH configuration
        echo ""
        echo "🔐 Checking SSH configuration..."

        if grep -q "PermitRootLogin no" /etc/ssh/sshd_config; then
          echo "  ✅ Root SSH login is disabled"
        else
          echo "  ❌ Root SSH login is not properly disabled"
          failed_checks=$((failed_checks + 1))
        fi

        if grep -q "PasswordAuthentication no" /etc/ssh/sshd_config; then
          echo "  ✅ SSH password authentication is disabled"
        else
          echo "  ⚠️  SSH password authentication is enabled"
        fi

        # Check fail2ban
        echo ""
        echo "🚫 Checking intrusion detection..."
        if systemctl is-active --quiet fail2ban; then
          echo "  ✅ Fail2ban is active"
        else
          echo "  ⚠️  Fail2ban is not active"
        fi

        # Check AppArmor
        echo ""
        echo "🛡️  Checking mandatory access control..."
        if systemctl is-active --quiet apparmor; then
          echo "  ✅ AppArmor is active"
        else
          echo "  ⚠️  AppArmor is not active"
        fi

        # Check for default passwords
        echo ""
        echo "🔑 Checking for default passwords..."
        if grep -q "hashedPassword.*nixos" /etc/nixos/configuration.nix 2>/dev/null; then
          echo "  ❌ Default passwords detected in configuration"
          failed_checks=$((failed_checks + 1))
        else
          echo "  ✅ No default passwords found in configuration"
        fi

        # Check system updates
        echo ""
        echo "📦 Checking system updates..."
        if [ -f /var/lib/nixos/current-config-generation ]; then
          current=$(readlink /nix/var/nix/profiles/system | sed 's/.*system-//' | sed 's/-.*//')
          last_update=$(stat -c %Y /nix/var/nix/profiles/system)
          days_old=$(( ($(date +%s) - last_update) / 86400 ))

          if [ $days_old -lt 30 ]; then
            echo "  ✅ System updated $days_old days ago"
          else
            echo "  ⚠️  System not updated for $days_old days"
          fi
        fi

        # Summary
        echo ""
        echo "==============================="
        if [ $failed_checks -eq 0 ]; then
          echo "✅ Security audit passed ($failed_checks critical issues)"
        else
          echo "❌ Security audit failed ($failed_checks critical issues)"
          exit 1
        fi
      '';

      # Performance benchmark tool
      performance-benchmark = pkgs.writeShellScriptBin "nixos-unified-benchmark" ''
        set -euo pipefail

        echo "⚡ NixOS Unified Performance Benchmark"
        echo "====================================="
        echo ""

        # System information
        echo "🖥️  System Information:"
        echo "  OS: $(uname -sr)"
        echo "  CPU: $(nproc) cores"
        echo "  Memory: $(free -h | awk '/^Mem:/ {print $2}')"
        echo "  Uptime: $(uptime -p)"
        echo ""

        # Boot time analysis
        echo "🚀 Boot Performance:"
        systemd-analyze time
        echo ""

        # Service startup times
        echo "⏱️  Slowest Services:"
        systemd-analyze blame | head -10
        echo ""

        # Memory usage
        echo "💾 Memory Usage:"
        free -h
        echo ""
        echo "  Top memory consumers:"
        ps aux --sort=-%mem --no-headers | head -5 | awk '{printf "    %s: %s%%\n", $11, $4}'
        echo ""

        # Disk usage
        echo "💿 Disk Usage:"
        df -h / /boot 2>/dev/null || df -h /
        echo ""
        echo "  Nix store size:"
        du -sh /nix/store 2>/dev/null || echo "    Unable to check Nix store"
        echo ""

        # Network performance
        echo "🌐 Network Configuration:"
        ip route show default | head -1
        echo ""

        # Load average
        echo "📊 System Load:"
        uptime
        echo ""

        # Get system performance metrics (with fallback values)
        boot_time=$(systemd-analyze time 2>/dev/null | grep "startup finished" | sed 's/.*= //' | sed 's/s$//' || echo "30")
        mem_usage=$(free 2>/dev/null | grep Mem | awk '{printf "%.0f", $3/$2 * 100}' || echo "45")

        echo "📈 Performance Summary:"
        echo "  Boot time: ''${boot_time}s"
        echo "  Memory usage: ''${mem_usage}%"

        # Simple scoring
        if (( $(echo "''$boot_time < 30" | bc -l) )); then
          echo "  Boot performance: Excellent"
        elif (( $(echo "''$boot_time < 60" | bc -l) )); then
          echo "  Boot performance: Good"
        else
          echo "  Boot performance: Needs improvement"
        fi

        if [ "''$mem_usage" -lt 50 ]; then
          echo "  Memory efficiency: Excellent"
        elif [ "''$mem_usage" -lt 75 ]; then
          echo "  Memory efficiency: Good"
        else
          echo "  Memory efficiency: High usage"
        fi
      '';

      # Migration helper tool
      migration-helper = pkgs.writeShellScriptBin "nixos-unified-migrate" ''
        set -euo pipefail

        echo "🔄 NixOS Unified Migration Helper"
        echo "================================"
        echo ""

        if [ $# -lt 1 ]; then
          echo "Usage: $0 <source-config-dir>"
          echo ""
          echo "This tool helps migrate existing NixOS configurations to NixOS Unified."
          echo ""
          exit 1
        fi

        source_dir="$1"

        if [ ! -d "$source_dir" ]; then
          echo "❌ Source directory $source_dir does not exist"
          exit 1
        fi

        echo "📁 Analyzing source configuration: $source_dir"
        echo ""

        # Analyze existing configuration
        echo "🔍 Configuration Analysis:"

        # Check for flake.nix
        if [ -f "$source_dir/flake.nix" ]; then
          echo "  ✅ Flake-based configuration detected"
        else
          echo "  ⚠️  Legacy configuration.nix detected"
        fi

        # Check for home-manager
        if grep -r "home-manager" "$source_dir" >/dev/null 2>&1; then
          echo "  ✅ Home Manager integration found"
        else
          echo "  ℹ️  No Home Manager detected"
        fi

        # Check for gaming configuration
        if grep -r "steam\|gaming" "$source_dir" >/dev/null 2>&1; then
          echo "  🎮 Gaming configuration detected"
        fi

        # Check for development tools
        if grep -r "docker\|vscode\|development" "$source_dir" >/dev/null 2>&1; then
          echo "  💻 Development tools detected"
        fi

        # Check for desktop environment
        if grep -r "gnome\|kde\|xfce\|niri\|hyprland" "$source_dir" >/dev/null 2>&1; then
          echo "  🖥️  Desktop environment detected"
        fi

        echo ""
        echo "🎯 Recommended Migration Path:"

        # Suggest profile based on analysis
        if grep -r "server\|headless" "$source_dir" >/dev/null 2>&1; then
          echo "  Profile: server"
        elif grep -r "gaming\|steam" "$source_dir" >/dev/null 2>&1; then
          echo "  Profile: gaming"
        elif grep -r "development\|docker\|vscode" "$source_dir" >/dev/null 2>&1; then
          echo "  Profile: development"
        else
          echo "  Profile: workstation"
        fi

        echo ""
        echo "📋 Migration Steps:"
        echo "1. Create new unified configuration:"
        echo "   nix flake new -t github:user/nixos-unified#default my-unified-config"
        echo ""
        echo "2. Copy hardware configuration:"
        echo "   cp $source_dir/hardware-configuration.nix my-unified-config/"
        echo ""
        echo "3. Review and adapt custom configurations"
        echo "4. Test the new configuration"
        echo "5. Deploy when ready"
        echo ""
        echo "For detailed migration guide, see:"
        echo "https://github.com/user/nixos-unified/docs/migration.md"
      '';

      # Default package (installer)
      default = self'.packages.installer;
    };
  };
}
