{
  config,
  lib,
  pkgs,
  ...
}: {
  imports = [
    ./base.nix
  ];
  services = {
    upower.enable = true;
    thermald.enable = true;
    fwupd.enable = true;
    printing = {
      enable = true;
      drivers = with pkgs; [hplip];
    };
    geoclue2.enable = true;
    flatpak.enable = true;
    avahi = {
      enable = true;
      nssmdns4 = true;
      openFirewall = true;
    };
  };
  hardware = {
    graphics = {
      enable = true;
      enable32Bit = true;
    };
    bluetooth.enable = true;
    cpu.intel.updateMicrocode = lib.mkDefault config.hardware.enableRedistributableFirmware;
    cpu.amd.updateMicrocode = lib.mkDefault config.hardware.enableRedistributableFirmware;
  };
  environment.systemPackages = with pkgs; [
    nautilus
    file-roller
    gedit
    firefox
    libreoffice-fresh
    eog
    evince
    gnome-system-monitor
    htop
    networkmanagerapplet
    unzip
    zip
    p7zip
    git
    curl
    wget
    gst_all_1.gstreamer
    gst_all_1.gst-plugins-base
    gst_all_1.gst-plugins-good
    gst_all_1.gst-plugins-bad
    gst_all_1.gst-plugins-ugly
    gst_all_1.gst-libav
  ];
  fonts = {
    packages = with pkgs; [
      dejavu_fonts
      liberation_ttf
      fira-code
      fira-code-symbols
      noto-fonts
      noto-fonts-cjk-sans
      noto-fonts-emoji
      corefonts
      vistafonts
    ];
    fontconfig = {
      enable = true;
      defaultFonts = {
        serif = ["DejaVu Serif"];
        sansSerif = ["DejaVu Sans"];
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
    mime.enable = true;
    sounds.enable = true;
    icons.enable = true;
  };
  security = {
    rtkit.enable = true;
    polkit.enable = true;
    wrappers = {
      fusermount = {
        source = "${pkgs.fuse}/bin/fusermount";
        owner = "root";
        group = "root";
        permissions = "u+s,g+s";
      };
    };
  };
  networking = {
    networkmanager = {
      enable = true;
      wifi.powersave = false;
    };
    dhcpcd.enable = false;
  };
  users.users = {
    workstation-user = {
      isNormalUser = true;
      extraGroups = [
        "wheel"
        "networkmanager"
        "audio"
        "video"
        "docker"
        "libvirtd"
      ];
      shell = pkgs.fish;
    };
  };
  programs = {
    fish.enable = true;
    command-not-found.enable = true;
    gnupg.agent = {
      enable = true;
      pinentryPackage = pkgs.pinentry-gtk2;
    };
    thunar = {
      enable = true;
      plugins = with pkgs.xfce; [
        thunar-archive-plugin
        thunar-volman
      ];
    };
  };
  boot = {
    kernelParams = [
      "quiet"
      "splash"
      "loglevel=3"
      "systemd.show_status=auto"
      "rd.udev.log_level=3"
    ];
    plymouth.enable = true;
  };
  systemd = {
    services.NetworkManager-wait-online.enable = false;
    user.services = {
      udisks2 = {
        enable = true;
        wantedBy = ["graphical-session.target"];
      };
    };
  };
  boot.tmp = {
    cleanOnBoot = true;
    useTmpfs = lib.mkDefault true;
    tmpfsSize = "50%";
  };
}
