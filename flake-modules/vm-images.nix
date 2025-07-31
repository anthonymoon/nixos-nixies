{
  self,
  inputs,
  ...
}: {
  flake.packages = let
    system = "x86_64-linux";
    pkgs = inputs.nixpkgs.legacyPackages.${system};
    lib = inputs.nixpkgs.lib;
    buildVMImage = {
      config,
      name,
      format ? "qcow2",
      diskSize ? "8G",
      memorySize ? 2048,
    }: let
      makeDiskImage = import "${inputs.nixpkgs}/nixos/lib/make-disk-image.nix";
      baseConfig = {
        imports = [
          config
          {
            fileSystems."/" = {
              device = "/dev/disk/by-label/nixos";
              fsType = "ext4";
            };
            fileSystems."/boot" = {
              device = "/dev/disk/by-label/boot";
              fsType = "vfat";
            };
            boot.growPartition = true;
            boot.loader.grub.device = lib.mkForce "/dev/vda";
            boot.loader.timeout = 1;
            services.qemuGuest.enable = true;
            services.spice-vdagentd.enable = true;
            services.openssh.enable = true;
            users.users.nixos = {
              isNormalUser = true;
              extraGroups = ["wheel"];
              password = "nixos";
            };
            security.sudo.wheelNeedsPassword = false;
          }
        ];
      };
      evalConfig = import "${inputs.nixpkgs}/nixos/lib/eval-config.nix" {
        inherit system;
        modules = [baseConfig];
      };
    in
      makeDiskImage {
        inherit pkgs lib diskSize format;
        config = evalConfig.config;
        partitionTableType = "hybrid";
        installBootLoader = true;
        configFile = pkgs.writeText "configuration.nix" ''
          {}
        '';
        imageMetadata = {
          inherit name format diskSize memorySize;
          architecture = system;
          nixos-version = evalConfig.config.system.nixos.version;
          build-date = builtins.currentTime;
        };
      };
  in {
    vm-image-minimal = buildVMImage {
      name = "nixos-unified-minimal";
      config = self.nixosConfigurations.qemu-minimal.config.system.build.toplevel;
      diskSize = "4G";
      memorySize = 1024;
    };
    vm-image-desktop = buildVMImage {
      name = "nixos-unified-desktop";
      config = self.nixosConfigurations.qemu-desktop.config.system.build.toplevel;
      diskSize = "12G";
      memorySize = 4096;
    };
    vm-image-development = buildVMImage {
      name = "nixos-unified-development";
      config = self.nixosConfigurations.qemu-development.config.system.build.toplevel;
      diskSize = "16G";
      memorySize = 8192;
    };
    vm-launcher-minimal = pkgs.writeShellScriptBin "launch-minimal-vm" ''
      set -euo pipefail
      VM_IMAGE="$(nix build --print-out-paths --no-link .
      echo "🚀 Launching minimal NixOS VM..."
      echo "💾 Image: $VM_IMAGE"
      echo "🔧 Memory: 1GB"
      echo "💿 Disk: 4GB"
      echo ""
      exec ${pkgs.qemu}/bin/qemu-system-x86_64 \
      -enable-kvm \
      -m 1024 \
      -smp 2 \
      -drive file="$VM_IMAGE",format=qcow2,if=virtio \
      -netdev user,id=net0,hostfwd=tcp::2222-:22 \
      -device virtio-net-pci,netdev=net0 \
      -device virtio-balloon \
      -device virtio-rng-pci \
      -device virtio-serial-pci \
      -vga virtio \
      -display gtk,show-cursor=on \
      -monitor stdio \
      "$@"
    '';
    vm-launcher-desktop = pkgs.writeShellScriptBin "launch-desktop-vm" ''
      set -euo pipefail
      VM_IMAGE="$(nix build --print-out-paths --no-link .
      echo "🚀 Launching desktop NixOS VM..."
      echo "💾 Image: $VM_IMAGE"
      echo "🔧 Memory: 4GB"
      echo "💿 Disk: 12GB"
      echo ""
      exec ${pkgs.qemu}/bin/qemu-system-x86_64 \
      -enable-kvm \
      -m 4096 \
      -smp 4 \
      -drive file="$VM_IMAGE",format=qcow2,if=virtio \
      -netdev user,id=net0,hostfwd=tcp::2222-:22 \
      -device virtio-net-pci,netdev=net0 \
      -device virtio-balloon \
      -device virtio-rng-pci \
      -device virtio-serial-pci \
      -device virtio-gpu-pci \
      -device virtio-keyboard-pci \
      -device virtio-mouse-pci \
      -device intel-hda \
      -device hda-duplex \
      -vga virtio \
      -display gtk,show-cursor=on,gl=on \
      -audiodev pa,id=audio0 \
      -machine type=q35,accel=kvm \
      -cpu host \
      -usb \
      -device usb-tablet \
      "$@"
    '';
    vm-launcher-development = pkgs.writeShellScriptBin "launch-development-vm" ''
      set -euo pipefail
      VM_IMAGE="$(nix build --print-out-paths --no-link .
      echo "🚀 Launching development NixOS VM..."
      echo "💾 Image: $VM_IMAGE"
      echo "🔧 Memory: 8GB"
      echo "💿 Disk: 16GB"
      echo ""
      exec ${pkgs.qemu}/bin/qemu-system-x86_64 \
      -enable-kvm \
      -m 8192 \
      -smp 6 \
      -drive file="$VM_IMAGE",format=qcow2,if=virtio \
      -netdev user,id=net0,hostfwd=tcp::2222-:22,hostfwd=tcp::3000-:3000,hostfwd=tcp::8080-:8080 \
      -device virtio-net-pci,netdev=net0 \
      -device virtio-balloon \
      -device virtio-rng-pci \
      -device virtio-serial-pci \
      -device virtio-gpu-pci \
      -device virtio-keyboard-pci \
      -device virtio-mouse-pci \
      -device intel-hda \
      -device hda-duplex \
      -vga virtio \
      -display gtk,show-cursor=on,gl=on \
      -audiodev pa,id=audio0 \
      -machine type=q35,accel=kvm \
      -cpu host \
      -usb \
      -device usb-tablet \
      -device virtio-9p-pci,id=fs0,fsdev=fsdev0,mount_tag=hostshare \
      -fsdev local,security_model=passthrough,id=fsdev0,path=/tmp/vm-share \
      "$@"
    '';
    vm-manager = pkgs.writeShellScriptBin "vm-manager" ''
      set -euo pipefail
      show_help() {
      cat << 'EOF'
      VM Manager for NixOS Unified
      ============================
      Usage: vm-manager <command> [options]
      Commands:
      build <type>        Build VM image (minimal|desktop|development)
      launch <type>       Launch VM (minimal|desktop|development)
      list               List available VM images
      clean              Clean VM build artifacts
      info <type>        Show VM information
      ssh <type>         SSH into running VM
      Examples:
      vm-manager build minimal
      vm-manager launch desktop
      vm-manager ssh development
      vm-manager info desktop
      EOF
      }
      if [ $
      show_help
      exit 1
      fi
      command="$1"
      shift
      case "$command" in
      build)
      if [ $
      echo "Error: Please specify VM type (minimal|desktop|development)"
      exit 1
      fi
      vm_type="$1"
      echo "🏗️  Building $vm_type VM image..."
      nix build ".
      echo "✅ VM image built successfully"
      ;;
      launch)
      if [ $
      echo "Error: Please specify VM type (minimal|desktop|development)"
      exit 1
      fi
      vm_type="$1"
      shift
      echo "🚀 Launching $vm_type VM..."
      nix run ".
      ;;
      list)
      echo "📋 Available VM images:"
      echo ""
      for vm_type in minimal desktop development; do
      if nix build ".
      echo "  ✅ $vm_type"
      else
      echo "  ❌ $vm_type (not built)"
      fi
      done
      ;;
      clean)
      echo "🧹 Cleaning VM build artifacts..."
      find . -name "result*" -type l -delete
      nix-collect-garbage -d
      echo "✅ Cleanup completed"
      ;;
      info)
      if [ $
      echo "Error: Please specify VM type (minimal|desktop|development)"
      exit 1
      fi
      vm_type="$1"
      echo "ℹ️  VM Information: $vm_type"
      echo "==================="
      case "$vm_type" in
      minimal)
      echo "💾 Disk Size: 4GB"
      echo "🔧 Memory: 1GB"
      echo "🏷️  Description: Minimal NixOS VM for testing"
      echo "📦 Packages: Basic system tools only"
      ;;
      desktop)
      echo "💾 Disk Size: 12GB"
      echo "🔧 Memory: 4GB"
      echo "🏷️  Description: Desktop NixOS VM with GUI"
      echo "📦 Packages: Desktop environment + applications"
      ;;
      development)
      echo "💾 Disk Size: 16GB"
      echo "🔧 Memory: 8GB"
      echo "🏷️  Description: Development NixOS VM"
      echo "📦 Packages: Full development environment"
      ;;
      *)
      echo "❌ Unknown VM type: $vm_type"
      exit 1
      ;;
      esac
      echo ""
      echo "🔗 SSH Access: ssh -p 2222 nixos@localhost"
      echo "🔑 Default Password: nixos"
      ;;
      ssh)
      if [ $
      echo "Error: Please specify VM type (minimal|desktop|development)"
      exit 1
      fi
      vm_type="$1"
      shift
      echo "🔗 Connecting to $vm_type VM via SSH..."
      ssh -p 2222 -o StrictHostKeyChecking=no -o UserKnownHostsFile=/dev/null nixos@localhost "$@"
      ;;
      help|--help|-h)
      show_help
      ;;
      *)
      echo "❌ Unknown command: $command"
      echo ""
      show_help
      exit 1
      ;;
      esac
    '';
    vm-test-runner = pkgs.writeShellScriptBin "vm-test-runner" ''
      set -euo pipefail
      echo "🧪 NixOS Unified VM Test Runner"
      echo "==============================="
      echo ""
      run_test() {
      local vm_type="$1"
      local test_name="$2"
      local test_script="$3"
      echo "🔬 Testing $vm_type: $test_name"
      if ! nix build ".
      echo "  📦 Building VM image..."
      nix build ".
      fi
      if eval "$test_script"; then
      echo "  ✅ PASS: $test_name"
      return 0
      else
      echo "  ❌ FAIL: $test_name"
      return 1
      fi
      }
      failed_tests=0
      total_tests=0
      for vm_type in minimal desktop development; do
      total_tests=$((total_tests + 1))
      if ! run_test "$vm_type" "Image Build" "nix build .
      failed_tests=$((failed_tests + 1))
      fi
      done
      for vm_type in minimal desktop development; do
      total_tests=$((total_tests + 1))
      if ! run_test "$vm_type" "Launcher Build" "nix build .
      failed_tests=$((failed_tests + 1))
      fi
      done
      total_tests=$((total_tests + 1))
      if ! run_test "manager" "VM Manager Tool" "nix build .
      failed_tests=$((failed_tests + 1))
      fi
      echo ""
      echo "📊 Test Results:"
      echo "=================="
      echo "✅ Passed: $((total_tests - failed_tests))/$total_tests"
      echo "❌ Failed: $failed_tests/$total_tests"
      if [ $failed_tests -eq 0 ]; then
      echo ""
      echo "🎉 All VM tests passed!"
      exit 0
      else
      echo ""
      echo "💥 Some VM tests failed!"
      exit 1
      fi
    '';
  };
}
