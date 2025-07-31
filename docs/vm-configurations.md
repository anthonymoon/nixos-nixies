# QEMU VM Configurations

## Overview

Complete QEMU-optimized VM configurations for testing, development, and desktop use cases.

## Available Configurations

### 1. Minimal VM (`qemu-minimal`)

- **Purpose**: Lightweight testing and server environments
- **Resources**: 1GB RAM, 4GB disk
- **Features**:
  - Console-only interface
  - Essential system tools only
  - Basic security level
  - Aggressive power management
  - Minimal package set

### 2. Desktop VM (`qemu-desktop`)

- **Purpose**: Desktop environment testing with GUI
- **Resources**: 4GB RAM, 12GB disk
- **Features**:
  - Niri Wayland compositor
  - greetd display manager
  - PipeWire audio system
  - Full desktop applications
  - Graphics acceleration support

### 3. Development VM (`qemu-development`)

- **Purpose**: Full development environment
- **Resources**: 8GB RAM, 16GB disk
- **Features**:
  - Complete development toolchain
  - Multiple language support (Rust, Go, Python, JavaScript, Nix)
  - Container runtime (Docker, Podman)
  - Database services (PostgreSQL, Redis)
  - Host-guest file sharing via 9p
  - Enhanced graphics and audio

## VM Management Tools

### Building VM Images

```bash
# Build specific VM image
nix build .#vm-image-minimal
nix build .#vm-image-desktop
nix build .#vm-image-development

# Build all VM images
nix build .#vm-image-{minimal,desktop,development}
```

### Launching VMs

```bash
# Launch VMs directly
nix run .#vm-launcher-minimal
nix run .#vm-launcher-desktop
nix run .#vm-launcher-development

# Using VM manager tool
nix run .#vm-manager -- launch minimal
nix run .#vm-manager -- launch desktop
nix run .#vm-manager -- launch development
```

### VM Manager Commands

```bash
# VM management operations
vm-manager build <type>        # Build VM image
vm-manager launch <type>       # Launch VM
vm-manager list               # List available VMs
vm-manager clean              # Clean build artifacts
vm-manager info <type>        # Show VM information
vm-manager ssh <type>         # SSH into running VM
```

### Testing Framework

```bash
# Run comprehensive VM tests
nix run .#vm-test-runner

# Test specific components
nix build .#vm-image-minimal --dry-run
nix build .#vm-launcher-desktop --dry-run
```

## Performance Optimizations

### Kernel Optimizations

- **I/O Scheduler**: `noop` for VM environments
- **CPU States**: Disabled deep sleep states for responsiveness
- **Memory Management**: Optimized swappiness and dirty ratios
- **Network**: BBR congestion control, optimized buffer sizes

### VirtIO Drivers

- **Storage**: `virtio_blk` and `virtio_scsi` for high-performance I/O
- **Network**: `virtio_net` with optimized buffers
- **Graphics**: `virtio_gpu` for accelerated rendering
- **Input**: `virtio_input` for responsive input handling
- **Memory**: `virtio_balloon` for dynamic memory management

### System Optimizations

- **Boot Time**: Fast initrd with zstd compression
- **File Systems**: `noatime` and `nodiratime` for reduced I/O
- **Logging**: Reduced log retention for VM environments
- **Services**: Disabled unnecessary services for VM use

## Security Configuration

### VM-Appropriate Security

- **Firewall**: Disabled for development flexibility
- **SSH**: Password authentication enabled for convenience
- **Sudo**: Passwordless for wheel group members
- **AppArmor**: Disabled for VM environments
- **Users**: Simple passwords for easy access

### Host-Guest Security

- **File Sharing**: 9p filesystem for secure data exchange
- **Network**: Port forwarding for specific services
- **Isolation**: VM-contained environment with limited host access

## Network Configuration

### systemd-networkd

- **DHCP**: Automatic network configuration
- **DNS**: CloudFlare and pool.ntp.org for time sync
- **Performance**: Optimized buffer sizes and TCP settings

### Port Forwarding

- **SSH**: Host port 2222 → VM port 22
- **Development**: Ports 3000, 8000, 8080, 8443 forwarded
- **Services**: Database ports (5432, 6379) available

## Development Features

### Language Support

- **Rust**: Complete toolchain with rust-analyzer
- **Go**: Latest Go version with gopls LSP
- **Python**: Python 3.11 with development tools
- **JavaScript/TypeScript**: Node.js 20 with language servers
- **Nix**: nil LSP and alejandra formatter

### Development Tools

- **Editors**: VS Code, Vim, Neovim, Emacs
- **Containers**: Docker, Podman, Docker Compose
- **Cloud**: AWS CLI, Google Cloud SDK, Azure CLI, kubectl
- **Version Control**: Git, GitHub CLI, Git LFS
- **Databases**: PostgreSQL, Redis, SQLite, DBeaver

### Services

- **PostgreSQL**: Pre-configured database server
- **Redis**: Key-value store for development
- **Docker**: Container runtime with optimization
- **SSH**: Remote development access

## File System Layout

### Standard Mounts

- **Root**: `/` on `virtio_blk` with ext4
- **Boot**: `/boot` on VFAT for UEFI support
- **Tmp**: `/tmp` on tmpfs for performance

### Development VM Additions

- **Shared**: `/mnt/shared` via 9p for host-guest file sharing
- **Large tmpfs**: 4GB `/tmp` for development builds

## User Configuration

### Default Users

- **Minimal**: `nixos` user with basic permissions
- **Desktop**: `nixos` user with desktop group memberships
- **Development**: `dev` and `nixos` users with full development access

### Permissions

- **Wheel**: Sudo access without password
- **Docker**: Container management access
- **Audio/Video**: Multimedia device access
- **NetworkManager**: Network configuration access

## Quality Assurance

### Automated Testing

- **Build Tests**: All VM images build successfully
- **Launcher Tests**: VM launcher scripts validate
- **Manager Tests**: VM management tool functionality
- **Syntax**: All Nix files pass syntax validation

### Performance Validation

- **Boot Time**: Optimized for fast VM startup
- **Memory**: Efficient memory usage patterns
- **I/O**: High-performance storage operations
- **Network**: Optimized network throughput

### Security Validation

- **Services**: Only required services enabled
- **Permissions**: Appropriate user access controls
- **Hardening**: VM-appropriate security measures
- **Isolation**: Proper host-guest separation

## Integration Points

### Main Framework

- **Nixies Library**: Uses shared `mkSystem` function
- **Module System**: Integrates with nixies module architecture
- **Profiles**: Based on QEMU-optimized profile
- **Security**: Follows nixies security framework

### CI/CD Integration

- **Pre-commit**: VM configurations validated on commit
- **Testing**: Automated VM testing in pipeline
- **Deployment**: VM images can be built and distributed
- **Documentation**: Automatically updated VM documentation
