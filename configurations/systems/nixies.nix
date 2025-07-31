{
  config,
  lib,
  pkgs,
  modulesPath,
  ...
}: {
  imports = [
    (modulesPath + "/installer/scan/not-detected.nix")
    ../disko/nixies.nix
  ];

  # Hardware configuration based on nixos-generate-config output
  boot.initrd.availableKernelModules = [ "nvme" "xhci_pci" "usbhid" "uas" "sd_mod" ];
  boot.initrd.kernelModules = [ ];
  boot.kernelModules = [ "kvm-amd" ];
  boot.extraModulePackages = [ ];

  # Boot loader configuration
  boot.loader = {
    systemd-boot.enable = true;
    efi.canTouchEfiVariables = true;
    timeout = lib.mkForce 3;
  };

  # Network interfaces detected by hardware scan
  networking = {
    hostName = "nixies";
    useDHCP = lib.mkDefault true;
    # Available interfaces (commented out, will be auto-detected):
    # interfaces.enp4s0f0np0.useDHCP = lib.mkDefault true;
    # interfaces.enp4s0f1np1.useDHCP = lib.mkDefault true;
    # interfaces.wlp6s0.useDHCP = lib.mkDefault true;
  };

  # Hardware platform
  nixpkgs.hostPlatform = lib.mkDefault "x86_64-linux";
  hardware.cpu.amd.updateMicrocode = lib.mkDefault config.hardware.enableRedistributableFirmware;

  # Basic unified configuration
  unified = {
    core = {
      enable = true;
      security.level = "standard";
      performance.enable = true;
    };
  };

  # User configuration
  users = {
    mutableUsers = true;
    users.amoon = {
      isNormalUser = true;
      extraGroups = [ "wheel" "networkmanager" ];
      shell = pkgs.bash;
      description = "System Administrator";
      initialPassword = "changeme";
    };
  };

  # Essential system packages
  environment.systemPackages = with pkgs; [
    vim
    git
    wget
    curl
    htop
    tree
    rsync
  ];

  # Enable SSH for remote access
  services.openssh = {
    enable = true;
    settings = {
      PasswordAuthentication = false;
      PermitRootLogin = "no";
    };
  };

  # Enable sudo without password for wheel group
  security.sudo.wheelNeedsPassword = lib.mkForce false;

  # System state version
  system.stateVersion = "24.11";
}