{
  config,
  lib,
  pkgs,
  inputs,
  ...
}: {
  imports = [
    ../../profiles/qemu.nix
    ../../modules/desktop/niri.nix
  ];
  unified = {
    core = {
      hostname = "nixos-qemu-desktop";
      security.level = "standard";
    };
    qemu = {
      enable = true;
      performance.enable = true;
      guest.enable = true;
      graphics.enable = true;
    };
    niri = {
      enable = true;
      session.displayManager = "greetd";
      features = {
        xwayland = true;
        screensharing = false;
        clipboard = true;
        notifications = true;
      };
      applications = {
        terminal = "foot";
        browser = "firefox";
        launcher = "wofi";
      };
    };
  };
  services = {
    greetd = {
      enable = true;
      settings = {
        default_session = {
          command = "${pkgs.greetd.tuigreet}/bin/tuigreet --time --cmd niri-session";
          user = "greeter";
        };
      };
    };
    pipewire = {
      enable = true;
      alsa.enable = true;
      pulse.enable = true;
    };
    libinput.enable = true;
  };
  hardware = {
    opengl = {
      enable = true;
      driSupport = true;
    };
    pulseaudio.enable = false;
  };
  environment.systemPackages = with pkgs; [
    niri
    waybar
    wofi
    mako
    foot
    kitty
    firefox
    chromium
    nautilus
    gedit
    vim
    nano
    mpv
    imv
    grim
    slurp
    wl-clipboard
    htop
    tree
    git
    curl
    wget
    vscode
    file-roller
    unzip
    zip
    gimp
    inkscape
    libreoffice-fresh
    networkmanagerapplet
  ];
  fonts = {
    packages = with pkgs; [
      noto-fonts
      noto-fonts-cjk
      noto-fonts-emoji
      liberation_ttf
      fira-code
      fira-code-symbols
    ];
    fontconfig = {
      enable = true;
      defaultFonts = {
        serif = ["Noto Serif"];
        sansSerif = ["Noto Sans"];
        monospace = ["Fira Code"];
      };
    };
  };
  xdg = {
    portal = {
      enable = true;
      wlr.enable = true;
      config.common.default = "*";
    };
  };
  users.users = {
    nixos = {
      isNormalUser = true;
      extraGroups = ["wheel" "networkmanager" "audio" "video"];
      password = "nixos";
      description = "NixOS Desktop User";
    };
  };
  programs = {
    thunar.enable = true;
    file-roller.enable = true;
    git.enable = true;
    fish.enable = true;
  };
  security = {
    rtkit.enable = true;
    polkit.enable = true;
  };
  networking = {
    networkmanager = {
      enable = true;
      wifi.powersave = false;
    };
    dhcpcd.enable = false;
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
    "/tmp" = {
      device = "tmpfs";
      fsType = "tmpfs";
      options = ["defaults" "size=2G" "mode=1777"];
    };
  };
  boot = {
    kernelPackages = pkgs.linuxPackages_latest;
    kernelModules = [
      "virtio_balloon"
      "virtio_console"
      "virtio_net"
      "virtio_blk"
      "virtio_gpu"
      "virtio_input"
    ];
    kernelParams = [
      "quiet"
      "splash"
      "loglevel=3"
    ];
  };
  boot.kernel.sysctl = {
    "vm.swappiness" = 10;
    "vm.dirty_background_ratio" = 10;
    "vm.dirty_ratio" = 20;
    "dev.hpet.max-user-freq" = 3072;
  };
  nix = {
    settings = {
      max-jobs = 2;
      cores = 2;
      auto-optimise-store = true;
    };
    gc = {
      automatic = true;
      dates = "weekly";
      options = "--delete-older-than 7d";
    };
  };
  documentation = {
    enable = true;
    nixos.enable = true;
    man.enable = true;
  };
}
