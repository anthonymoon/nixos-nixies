# Disko Module

The disko module provides declarative disk partitioning and formatting for NixOS systems.

## Overview

This module integrates [disko](https://github.com/nix-community/disko) to replace manual disk setup with declarative configuration. It supports multiple disk layouts including standard partitioning, LUKS encryption, ZFS, and Btrfs.

## Configuration

### Basic Usage

```nix
{
  unified.disko = {
    enable = true;
    layout = "standard";  # or "encrypted", "zfs", "btrfs"
    device = "/dev/disk/by-id/nvme-CT2000T500SSD8_241047B9A4C2";
    swapSize = "8G";
  };
}
```

### Available Layouts

#### Standard Layout
- EFI System Partition (512M)
- Swap partition (configurable size)
- Root partition (ext4, remainder of disk)

#### Encrypted Layout
- EFI System Partition (512M)
- LUKS encrypted partition containing:
  - LVM volume group with swap and root volumes

#### ZFS Layout
- EFI System Partition (512M)
- ZFS pool (rpool) with datasets:
  - root, nix, home, var, var/log

#### Btrfs Layout
- EFI System Partition (512M)
- Swap partition (configurable size)
- Btrfs partition with subvolumes:
  - @, @home, @nix, @var, @log, @tmp, @snapshots

## Options

- `enable`: Enable disko disk management
- `layout`: Disk layout type ("standard", "encrypted", "zfs", "btrfs")
- `device`: Primary disk device (use /dev/disk/by-id/ for stability)
- `swapSize`: Size of swap partition (default: "8G")
- `encryptionPassphrase`: Encryption passphrase for encrypted layouts

## Installation

When installing a new system with disko:

1. Boot from NixOS installer
2. Configure your flake with desired disko settings
3. Run: `nix run github:nix-community/disko -- --mode disko --flake .#yourSystem`
4. Install NixOS: `nixos-install --flake .#yourSystem`

## Example Configurations

### Encrypted System
```nix
{
  unified.disko = {
    enable = true;
    layout = "encrypted";
    device = "/dev/disk/by-id/nvme-YourDisk";
    swapSize = "16G";
  };
}
```

### ZFS System
```nix
{
  unified.disko = {
    enable = true;
    layout = "zfs";
    device = "/dev/disk/by-id/nvme-YourDisk";
  };
  
  # Additional ZFS configuration
  boot.supportedFilesystems = [ "zfs" ];
  boot.zfs.forceImportRoot = false;
  services.zfs.autoScrub.enable = true;
}
```

### Btrfs with Snapshots
```nix
{
  unified.disko = {
    enable = true;
    layout = "btrfs";
    device = "/dev/disk/by-id/nvme-YourDisk";
    swapSize = "8G";
  };
  
  # Additional Btrfs configuration
  services.btrfs.autoScrub.enable = true;
}
```

## Tips

1. Always use `/dev/disk/by-id/` paths for device specification
2. Test your configuration in a VM first
3. Back up your data before running disko
4. For encrypted setups, consider using a keyfile or TPM unlocking