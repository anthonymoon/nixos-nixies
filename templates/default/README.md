# NixOS Nixies Template

This template provides a complete NixOS configuration based on your specific requirements.

## Features

- **UEFI systemd-boot** (no secure boot)
- **Users**: `amoon`, `nixos`, `root` (default password: `nixos`) <!-- pragma: allowlist secret -->
- **Shared SSH key** across all profiles
- **DHCP via systemd-networkd**
- **Desktop environments**: greetd + tuigreet + niri/hyprland/plasma6
- **Latest stable nixpkgs** with latest kernels
- **Three configurations**:
  - `enterprise`: Stable/secure packages
  - `home`: Bleeding-edge packages
  - `vm`: QEMU-optimized, minimal security

## Quick Start

### 1. Clone and Initialize

```bash
# Use this template
nix flake new -t github:amoon/nixos-nixies#default my-nixos-config
cd my-nixos-config

# Update the SSH key in flake.nix
# Edit the sharedSSHKey variable with your public key
```

### 2. Generate Hardware Configuration

```bash
# Boot from NixOS installer
# Generate hardware config for your system
nixos-generate-config --root /mnt --show-hardware-config > hardware-configuration.nix

# Add hardware-configuration.nix import to your chosen configuration
```

### 3. Install System

#### Enterprise Configuration (Stable/Secure)

```bash
# Install with enterprise profile
nixos-install --flake .#enterprise --root /mnt

# After reboot, switch to enterprise config
nixos-rebuild switch --flake .#enterprise
```

#### Home Configuration (Bleeding-edge)

```bash
# Install with home profile
nixos-install --flake .#home --root /mnt

# After reboot, switch to home config
nixos-rebuild switch --flake .#home
```

#### VM Configuration (QEMU-optimized)

```bash
# For VMs, use VM profile
nixos-install --flake .#vm --root /mnt

# After reboot, switch to VM config
nixos-rebuild switch --flake .#vm
```

### 4. Post-Installation Setup

```bash
# Change default passwords
passwd amoon
passwd nixos
passwd root

# Enable Home Manager for amoon user
home-manager switch --flake .#amoon@<hostname>

# Test deployment (if using remote hosts)
deploy .#enterprise  # or .#home or .#vm
```

## Configuration Details

### Users

All configurations include these users:

- **amoon**: Main user with wheel, networkmanager, docker, libvirtd groups
- **nixos**: Secondary user with wheel group
- **root**: System administrator

Default password for all users: `nixos` (change immediately!)

### Desktop Environments

#### Available Compositors

- **Niri**: Scrollable tiling compositor (default)
- **Hyprland**: Dynamic tiling compositor
- **Plasma 6**: Full KDE desktop (home config only)

#### Login Manager

- **greetd** with **tuigreet** for clean console login
- Session selection available in tuigreet

### Network Configuration

- Uses **systemd-networkd** for networking
- DHCP enabled on all Ethernet interfaces (`en*`)
- IPv6 Router Advertisement support
- DNS via DHCP

### Security Levels

#### Enterprise Configuration

- Hardened security level
- Only FOSS packages
- Minimal attack surface
- Comprehensive security hardening

#### Home Configuration

- Standard security level
- Unfree packages allowed
- Full desktop experience
- Development tools included

#### VM Configuration

- Basic security level
- No firewall (for VM networking)
- QEMU guest optimizations
- Fast boot configuration

## Customization

### Adding Packages

#### Enterprise (stable packages)

```nix
environment.systemPackages = with pkgs; [
  # Add stable packages here
];
```

#### Home (bleeding-edge packages)

```nix
environment.systemPackages = with nixpkgs-unstable.legacyPackages.${system}; [
  # Add unstable packages here
];
```

### Changing Desktop Environment

To use Hyprland instead of Niri:

```nix
# Disable Niri
programs.niri.enable = false;

# Enable Hyprland
programs.hyprland.enable = true;

# Update greetd session
services.greetd.settings.default_session.command = "tuigreet --time --cmd Hyprland";
```

To use Plasma 6:

```nix
# Enable Plasma
services.desktopManager.plasma6.enable = true;
services.displayManager.sddm.enable = true;

# Disable other compositors
programs.niri.enable = false;
programs.hyprland.enable = false;
services.greetd.enable = false;
```

### Adding SSH Keys

Replace the `sharedSSHKey` variable in `flake.nix`:

```nix
sharedSSHKey = "ssh-ed25519 YOUR_PUBLIC_KEY_HERE user@host";
```

### Deployment Configuration

Update hostnames in the deploy section:

```nix
deploy.nodes = {
  enterprise.hostname = "your-enterprise-host.local";
  home.hostname = "your-home-host.local";
  vm.hostname = "your-vm-host.local";
};
```

## Available Commands

### System Management

```bash
# Build configuration
nix build .#nixosConfigurations.enterprise.config.system.build.toplevel

# Switch configuration
nixos-rebuild switch --flake .#enterprise

# Test configuration (temporary)
nixos-rebuild test --flake .#enterprise
```

### Home Manager

```bash
# Switch home configuration
home-manager switch --flake .#amoon@hostname
```

### Deployment

```bash
# Deploy to remote host
deploy .#enterprise

# Deploy specific profile
deploy .#home

# Deploy to VM
deploy .#vm
```

### Development

```bash
# Enter development shell
nix develop

# Format code
nixpkgs-fmt .

# Check flake
nix flake check
```

## Troubleshooting

### Boot Issues

- Ensure UEFI mode is enabled in BIOS
- Check that `/boot` partition is properly mounted
- Verify hardware-configuration.nix includes correct disk UUIDs

### Network Issues

- Check systemd-networkd status: `systemctl status systemd-networkd`
- Verify interface names match the `en*` pattern
- Check DHCP configuration: `networkctl status`

### Desktop Environment Issues

- Check session availability: `ls /run/current-system/sw/share/wayland-sessions/`
- Verify compositor is installed: `which niri` or `which Hyprland`
- Check greetd logs: `journalctl -u greetd`

### SSH Access

- Verify SSH service is running: `systemctl status sshd`
- Check SSH key permissions: `ls -la ~/.ssh/`
- Test SSH key: `ssh-add -l`

## Security Notes

### Default Passwords

⚠️ **CRITICAL**: Change default passwords immediately after installation!

```bash
passwd amoon
passwd nixos
passwd root
```

### SSH Configuration

- Password authentication is enabled by default for initial setup
- Disable password auth after setting up SSH keys:

```nix
nixies.core.security.ssh.passwordAuth = false;
```

### Firewall

- Enterprise: Full firewall enabled
- Home: Standard firewall with common ports
- VM: Firewall disabled for VM networking

## License

This template is provided under the same license as NixOS Nixies.
