{lib}: rec {
  validateConfig = config: {
    assertions = [
      {
        assertion = config.networking.firewall.enable or true;
        message = "Firewall must be enabled for security";
      }
      {
        assertion = !(config.services.openssh.settings.PermitRootLogin or "no" == "yes");
        message = "Root SSH login should be disabled for security";
      }
      {
        assertion = !(config.services.openssh.settings.PasswordAuthentication or false);
        message = "SSH password authentication should be disabled";
      }
      {
        assertion = config.nix.settings.auto-optimise-store or false;
        message = "Nix store optimization should be enabled for performance";
      }
      {
        assertion = config.system.stateVersion != null;
        message = "System state version must be set";
      }
    ];
  };
  validateSecurity = config: securityLevel: let
    requiredByLevel = {
      basic = [
        "networking.firewall.enable"
        "security.sudo.enable"
      ];
      standard = [
        "networking.firewall.enable"
        "security.sudo.enable"
        "services.fail2ban.enable"
        "security.apparmor.enable"
      ];
      hardened = [
        "networking.firewall.enable"
        "security.sudo.enable"
        "services.fail2ban.enable"
        "security.apparmor.enable"
        "boot.kernel.sysctl.\"kernel.dmesg_restrict\""
      ];
      paranoid = [
        "networking.firewall.enable"
        "security.sudo.enable"
        "services.fail2ban.enable"
        "security.apparmor.enable"
        "boot.kernel.sysctl.\"kernel.dmesg_restrict\""
        "systemd.coredump.enable"
      ];
    };
    required = requiredByLevel.${securityLevel} or [];
  in {
    assertions =
      map
      (path: {
        assertion = lib.attrByPath (lib.splitString "." path) false config;
        message = "Security level '${securityLevel}' requires '${path}' to be enabled";
      })
      required;
  };
  validatePerformance = config: {
    warnings = lib.flatten [
      (
        lib.optional
        (lib.length (config.environment.systemPackages or []) > 100)
        "Large package list detected (${toString (lib.length config.environment.systemPackages)} packages). Consider modularization."
      )
      (
        lib.optional
        (!(config.nix.settings.auto-optimise-store or false))
        "Nix store auto-optimization is disabled. Enable for better performance."
      )
      (
        lib.optional
        (config.nix.settings.max-jobs or "1" == "1")
        "Parallel builds are not optimized. Set max-jobs to 'auto' for better performance."
      )
    ];
  };
  validateDependencies = moduleName: dependencies: config: {
    assertions =
      map
      (dep: {
        assertion = config.unified.${dep}.enable or false;
        message = "Module '${moduleName}' requires module '${dep}' to be enabled";
      })
      dependencies;
  };
  validateHardware = config: hardware: {
    assertions = [
      {
        assertion =
          hardware.cpu
          != null
          -> (hardware.cpu.intel.enable -> config.hardware.cpu.intel.updateMicrocode or false)
          && (hardware.cpu.amd.enable -> config.hardware.cpu.amd.updateMicrocode or false);
        message = "CPU microcode updates should be enabled for security and stability";
      }
      {
        assertion = hardware.graphics.enable -> config.hardware.opengl.enable or false;
        message = "OpenGL must be enabled when graphics hardware is present";
      }
    ];
  };
  validateNetwork = config: {
    assertions = [
      {
        assertion = config.networking.hostName != null && config.networking.hostName != "";
        message = "System hostname must be set";
      }
      {
        assertion =
          !(config.networking.firewall.enable or true)
          -> lib.elem "development" (config.unified.profiles or []);
        message = "Firewall should only be disabled in development environments";
      }
    ];
    warnings = [
      (
        lib.optional
        (config.networking.useDHCP or false)
        "Global DHCP is deprecated. Use systemd-networkd or NetworkManager instead."
      )
    ];
  };
  validateUsers = config: {
    assertions = [
      {
        assertion =
          lib.any (user: user.isNormalUser or false && lib.elem "wheel" (user.extraGroups or []))
          (lib.attrValues config.users.users);
        message = "At least one normal user with wheel access must be configured";
      }
      {
        assertion = !(config.users.users.root.hashedPassword or "" == "");
        message = "Root user must have a password or be locked";
      }
    ];
    warnings = lib.flatten [
      (lib.mapAttrsToList
        (
          name: user:
            lib.optional (user.password or null != null)
            "User '${name}' has plaintext password. Use hashedPassword instead."
        )
        config.users.users)
      (lib.mapAttrsToList
        (
          name: user:
            lib.optional
            (user.isNormalUser or false
              && (user.openssh.authorizedKeys.keys or []) == [])
            "User '${name}' has no SSH keys configured."
        )
        config.users.users)
    ];
  };
  validateServices = config: {
    assertions = [
      {
        assertion =
          config.services.openssh.enable
          -> config.services.openssh.settings.PermitRootLogin or "no" != "yes";
        message = "SSH root login should be disabled when SSH is enabled";
      }
      {
        assertion =
          config.services.openssh.enable
          -> config.networking.firewall.allowedTCPPorts or []
          != []
          || config.networking.firewall.allowedTCPPortRanges or [] != []
          || !config.networking.firewall.enable;
        message = "SSH port must be allowed through firewall when SSH is enabled";
      }
    ];
  };
  validateAll = config: securityLevel:
    lib.mkMerge [
      (validateConfig config)
      (validateSecurity config securityLevel)
      (validatePerformance config)
      (validateNetwork config)
      (validateUsers config)
      (validateServices config)
    ];
}
