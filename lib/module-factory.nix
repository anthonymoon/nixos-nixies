{lib}: {
  # Standard unified module factory
  mkUnifiedModule = {
    name,
    description,
    category ? "general",
    defaultEnable ? false,
    options ? {},
    config,
    dependencies ? [],
    security ? {},
  }: args @ {
    config,
    lib,
    pkgs,
    ...
  }: let
    cfg = args.config.unified.${name};
  in {
    meta = {
      inherit name description category;
      maintainers = ["nixos-unified"];
      doc = ./docs + "/${name}.md";
    };

    options.unified.${name} =
      {
        enable =
          lib.mkEnableOption description
          // {
            default = defaultEnable;
          };

        # Standard security options for all modules
        security = {
          enable = lib.mkOption {
            type = lib.types.bool;
            default = true;
            description = "Enable security hardening for this module";
          };

          level = lib.mkOption {
            type = lib.types.enum ["basic" "standard" "hardened"];
            default = "standard";
            description = "Security hardening level";
          };
        };

        # Standard performance options
        performance = {
          enable = lib.mkOption {
            type = lib.types.bool;
            default = true;
            description = "Enable performance optimizations";
          };

          profile = lib.mkOption {
            type = lib.types.enum ["minimal" "balanced" "performance"];
            default = "balanced";
            description = "Performance optimization profile";
          };
        };
      }
      // options;

    config = lib.mkIf cfg.enable (lib.mkMerge [
      # User-provided configuration
      (config {
        inherit cfg lib pkgs;
        config = args.config;
      })

      # Security hardening if enabled
      (lib.mkIf cfg.security.enable (security cfg))

      # Dependency assertions
      {
        assertions =
          map
          (dep: {
            assertion = args.config.unified.${dep}.enable or false;
            message = "Module '${name}' requires '${dep}' to be enabled";
          })
          dependencies;
      }
    ]);
  };

  # Feature module for smaller components
  mkFeatureModule = {
    name,
    description,
    packages ? [],
    services ? {},
    configuration ? {},
  }: {
    config,
    lib,
    pkgs,
    ...
  }: let
    cfg = config.unified.features.${name};
  in {
    options.unified.features.${name} = {
      enable = lib.mkEnableOption description;
    };

    config = lib.mkIf cfg.enable (lib.mkMerge [
      # Packages
      (lib.mkIf (packages != []) {
        environment.systemPackages = packages;
      })

      # Services
      (lib.mkIf (services != {}) {
        systemd.services = services;
      })

      # Additional configuration
      configuration
    ]);
  };

  # Service module template
  mkServiceModule = {
    name,
    description,
    serviceConfig,
    defaultPort ? null,
    user ? name,
    group ? name,
  }: {
    config,
    lib,
    pkgs,
    ...
  }: let
    cfg = config.unified.services.${name};
  in {
    options.unified.services.${name} = {
      enable = lib.mkEnableOption description;

      port = lib.mkOption {
        type = lib.types.port;
        default = defaultPort;
        description = "Port for ${name} service";
      };

      user = lib.mkOption {
        type = lib.types.str;
        default = user;
        description = "User to run ${name} service as";
      };

      group = lib.mkOption {
        type = lib.types.str;
        default = group;
        description = "Group for ${name} service";
      };
    };

    config = lib.mkIf cfg.enable {
      # Create user and group
      users.users.${cfg.user} = {
        isSystemUser = true;
        group = cfg.group;
        description = "${description} service user";
      };

      users.groups.${cfg.group} = {};

      # Service configuration
      systemd.services.${name} = serviceConfig cfg;

      # Firewall configuration if port specified
      networking.firewall.allowedTCPPorts = lib.optional (cfg.port != null) cfg.port;
    };
  };
}
