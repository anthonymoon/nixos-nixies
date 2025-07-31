{
  config,
  lib,
  pkgs,
  inputs,
  ...
}: {
  imports = [
    ../disko/zfs-mirror.nix
  ];

  # ZFS root configuration
  zfs-root.boot = {
    enable = true;
    immutable = true;
    bootDevices = [
      "nvme-Samsung_SSD_980_PRO_1TB_S5GXNX0R123456A"
      "nvme-Samsung_SSD_980_PRO_1TB_S5GXNX0R123456B"
    ];
  };

  # Basic system configuration
  unified = {
    core = {
      enable = true;
      security.level = "standard";
      performance.enable = true;
    };
    desktop = {
      enable = true;
      environment = "gnome";
    };
    packages = {
      enable = true;
      sets = {
        core.enable = true;
        desktop.enable = true;
        multimedia.enable = true;
      };
    };
  };

  # User configuration
  users.users.amoon = {
    isNormalUser = true;
    extraGroups = [ "wheel" "networkmanager" "audio" "video" ];
    shell = pkgs.zsh;
    description = "amoon";
  };

  # Network configuration
  networking = {
    hostName = "zfs-desktop";
    hostId = "12345678"; # Required for ZFS
    networkmanager.enable = true;
  };

  # Boot configuration
  boot = {
    supportedFilesystems = [ "zfs" ];
    zfs.forceImportRoot = false;
    loader.systemd-boot.enable = lib.mkForce false;
    loader.grub.enable = lib.mkForce true;
  };

  # System state version
  system.stateVersion = "24.11";
}