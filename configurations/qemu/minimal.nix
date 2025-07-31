{
  config,
  lib,
  pkgs,
  inputs,
  ...
}: {
  imports = [
    ../../profiles/qemu.nix
  ];
  unified = {
    core = {
      hostname = "nixos-qemu-minimal";
      security.level = "basic";
    };
  };
  environment.systemPackages = with pkgs; [
    vim
    nano
    htop
    tree
    curl
    wget
    iputils
    file
    which
    git
  ];
  services = {
    printing.enable = lib.mkForce false;
    pipewire.enable = lib.mkForce false;
    displayManager.gdm.enable = lib.mkForce false;
    desktopManager.gnome.enable = lib.mkForce false;
    journald.extraConfig = ''
      SystemMaxUse=50M
      SystemMaxFileSize=5M
      SystemKeepFree=100M
    '';
  };
  hardware = {
    bluetooth.enable = lib.mkForce false;
    graphics = {
      enable = true;
      enable32Bit = false;
    };
  };
  users.users = {
    nixos = {
      isNormalUser = true;
      extraGroups = ["wheel"];
      password = "nixos";
      description = "NixOS VM User";
    };
  };
  console = {
    keyMap = lib.mkDefault "us";
    font = "Lat2-Terminus16";
  };
  powerManagement = {
    enable = true;
    cpuFreqGovernor = lib.mkForce "powersave";
  };
  fileSystems = {
    "/" = {
      device = "/dev/disk/by-label/nixos";
      fsType = "ext4";
      options = ["noatime" "nodiratime"];
    };
    "/boot" = {
      device = "/dev/disk/by-label/boot";
      fsType = "vfat";
    };
  };
  swapDevices = [
    {
      device = "/dev/disk/by-label/swap";
      priority = 100;
    }
  ];
  boot = {
    loader.timeout = 0;
    kernelPackages = pkgs.linuxPackages;
    kernelModules = [
      "virtio_balloon"
      "virtio_console"
      "virtio_net"
      "virtio_blk"
    ];
    kernel.sysctl = {
      "vm.swappiness" = 60;
      "vm.dirty_background_ratio" = 2;
      "vm.dirty_ratio" = 5;
    };
  };
  nix = {
    settings = {
      max-jobs = lib.mkForce 1;
      cores = lib.mkForce 1;
      auto-optimise-store = true;
    };
    gc = {
      automatic = true;
      dates = lib.mkForce "daily";
      options = lib.mkForce "--delete-older-than 1d";
    };
  };
  documentation = {
    enable = lib.mkDefault false;
    nixos.enable = lib.mkDefault false;
    man.enable = lib.mkDefault false;
    info.enable = lib.mkDefault false;
  };
}
