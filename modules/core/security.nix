{
  config,
  lib,
  pkgs,
  ...
}: let
  cfg = config.unified.core.security;
in {
  options.unified.core.security = with lib; {
    enable = mkEnableOption "core security hardening" // {default = true;};
    level = mkOption {
      type = types.enum ["basic" "standard" "hardened" "paranoid"];
      default = "standard";
      description = "Security hardening level";
    };
    ssh = {
      enable = mkEnableOption "SSH hardening" // {default = true;};
      passwordAuth = mkOption {
        type = types.bool;
        default = false;
        description = "Allow SSH password authentication";
      };
      rootLogin = mkOption {
        type = types.bool;
        default = false;
        description = "Allow SSH root login";
      };
    };
    firewall = {
      enable = mkEnableOption "firewall" // {default = true;};
      allowedPorts = mkOption {
        type = types.listOf types.port;
        default = [];
        description = "Additional allowed TCP ports";
      };
    };
  };
  config = lib.mkIf cfg.enable (lib.mkMerge [
    {
      services.openssh = lib.mkIf cfg.ssh.enable {
        enable = true;
        settings = {
          PermitRootLogin =
            if cfg.ssh.rootLogin
            then "yes"
            else "no";
          PasswordAuthentication = cfg.ssh.passwordAuth;
          KbdInteractiveAuthentication = false;
          X11Forwarding = false;
          UseDns = false;
          Protocol = 2;
        };
      };
      networking.firewall = lib.mkIf cfg.firewall.enable {
        enable = true;
        allowedTCPPorts = [22] ++ cfg.firewall.allowedPorts;
        allowPing = true;
      };
      security.sudo = {
        enable = true;
        wheelNeedsPassword = true;
        execWheelOnly = true;
      };
    }
    (lib.mkIf (cfg.level == "standard" || cfg.level == "hardened" || cfg.level == "paranoid") {
      services.openssh.settings = {
        MaxAuthTries = 3;
        ClientAliveInterval = 300;
        ClientAliveCountMax = 2;
        LoginGraceTime = 30;
      };
      boot.kernel.sysctl = {
        "net.ipv4.ip_forward" = 0;
        "net.ipv4.conf.all.forwarding" = 0;
        "net.ipv4.conf.all.accept_source_route" = 0;
        "net.ipv4.conf.all.accept_redirects" = 0;
        "net.ipv4.conf.all.secure_redirects" = 0;
        "net.ipv4.conf.all.send_redirects" = 0;
        "net.ipv4.icmp_echo_ignore_broadcasts" = 1;
        "net.ipv4.icmp_ignore_bogus_error_responses" = 1;
        "kernel.dmesg_restrict" = 1;
        "kernel.kptr_restrict" = 2;
        "kernel.unprivileged_bpf_disabled" = 1;
        "net.core.bpf_jit_harden" = 2;
      };
      services.fail2ban = {
        enable = true;
        bantime = "1h";
        bantime-increment = {
          enable = true;
          maxtime = "168h";
          factor = "4";
        };
        maxretry = 3;
        ignoreIP = ["127.0.0.1/8" "::1"];
      };
    })
    (lib.mkIf (cfg.level == "hardened" || cfg.level == "paranoid") {
      security.apparmor = {
        enable = true;
        killUnconfinedConfinables = true;
      };
      boot.kernel.sysctl = {
        "kernel.yama.ptrace_scope" = 2;
        "vm.mmap_rnd_bits" = 32;
        "vm.mmap_rnd_compat_bits" = 16;
        "fs.protected_hardlinks" = 1;
        "fs.protected_symlinks" = 1;
      };
      boot.loader.systemd-boot.editor = false;
      systemd.coredump.enable = false;
    })
    (lib.mkIf (cfg.level == "paranoid") {
      boot.blacklistedKernelModules = [
        "dccp"
        "sctp"
        "rds"
        "tipc"
        "n-hdlc"
        "ax25"
        "netrom"
        "x25"
        "rose"
        "decnet"
        "econet"
        "af_802154"
        "ipx"
        "appletalk"
        "psnap"
        "p8023"
        "p8022"
        "can"
        "atm"
      ];
      networking.firewall = {
        allowedTCPPorts = lib.mkForce [22];
        allowedUDPPorts = lib.mkForce [];
        logRefusedConnections = true;
        logRefusedPackets = true;
      };
      services.avahi.enable = lib.mkForce false;
      services.printing.enable = lib.mkForce false;
      hardware.bluetooth.enable = lib.mkForce false;
      boot.kernel.sysctl = {
        "net.ipv4.tcp_timestamps" = 0;
        "net.ipv4.tcp_syncookies" = 1;
        "net.ipv4.tcp_rfc1337" = 1;
      };
    })
  ]);
}
