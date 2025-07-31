{lib}: {
  #
  #
  mkNixiesModule = {
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
    cfg = args.config.nixies.${name};
  in {
    meta = {
      inherit name description category;
      maintainers = ["nixos-nixies"];
      doc = ./docs + "/${name}.md";
    };
    options.nixies.${name} =
      {
        enable =
          lib.mkEnableOption description
          // {
            default = defaultEnable;
          };
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
      (config {
        inherit cfg lib pkgs;
        config = args.config;
      })
      (lib.mkIf (cfg.security.enable && (lib.isFunction security)) (security cfg))
      {
        assertions =
          map
          (dep: {
            assertion = args.config.nixies.${dep}.enable or false;
            message = ''
              Module '${name}' requires dependency '${dep}' to be enabled.
              To fix this, add the following to your configuration:
              nixies.${dep}.enable = true;
              Or disable module '${name}' by setting:
              nixies.${name}.enable = false;
            '';
          })
          dependencies;
      }
    ]);
  };
  #
  #
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
    cfg = config.nixies.features.${name};
  in {
    options.nixies.features.${name} = {
      enable = lib.mkEnableOption description;
    };
    config = lib.mkIf cfg.enable (lib.mkMerge [
      (lib.mkIf (packages != []) {
        environment.systemPackages = packages;
      })
      (lib.mkIf (services != {}) {
        systemd.services = services;
      })
      configuration
    ]);
  };
  #
  #
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
    cfg = config.nixies.services.${name};
  in {
    options.nixies.services.${name} = {
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
      users.users.${cfg.user} = {
        isSystemUser = true;
        group = cfg.group;
        description = "${description} service user";
      };
      users.groups.${cfg.group} = {};
      systemd.services.${name} = serviceConfig cfg;
      networking.firewall.allowedTCPPorts = lib.optional (cfg.port != null) cfg.port;
    };
  };
}
