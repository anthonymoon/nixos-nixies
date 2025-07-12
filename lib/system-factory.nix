{
  inputs,
  lib,
}: {
  # Unified system creation function
  mkSystem = {
    hostname,
    system ? "x86_64-linux",
    profiles ? [],
    modules ? [],
    users ? {},
    hardware ? null,
    specialArgs ? {},
    deployment ? {},
  }: let
    # Security-first defaults
    securityDefaults = {
      networking.firewall.enable = lib.mkDefault true;
      services.openssh.settings = {
        PermitRootLogin = lib.mkDefault "no";
        PasswordAuthentication = lib.mkDefault false;
      };
      security.sudo.wheelNeedsPassword = lib.mkDefault true;
    };

    # Performance defaults
    performanceDefaults = {
      nix.settings = {
        experimental-features = ["nix-command" "flakes"];
        auto-optimise-store = lib.mkDefault true;
        max-jobs = lib.mkDefault "auto";
      };
      boot.tmp.cleanOnBoot = lib.mkDefault true;
    };
  in
    inputs.nixpkgs.lib.nixosSystem {
      inherit system;

      modules =
        [
          # Core unified modules
          ../modules/core

          # Security-first configuration
          securityDefaults

          # Performance optimizations
          performanceDefaults

          # Hardware configuration
          (lib.mkIf (hardware != null) hardware)

          # Profile composition
        ]
        ++ (map (profile: ../profiles/${profile}.nix) profiles)
        ++ [
          # Host-specific configuration
          {
            networking.hostName = hostname;
            system.stateVersion = lib.mkDefault "24.11";

            # User configuration
            users.users = users;

            # Deployment metadata
            unified.deployment = deployment;
          }
        ]
        ++ modules;

      specialArgs =
        {
          inherit hostname inputs;
          unified-lib = import ../lib {inherit inputs lib;};
        }
        // specialArgs;
    };

  # Profile creation helper
  mkProfile = {
    name,
    description,
    modules,
    defaultUsers ? {},
  }: {
    imports = modules;

    meta = {
      inherit name description;
      maintainers = ["nixos-unified"];
    };

    users.users = defaultUsers;
  };

  # Specialization helper for different variants
  mkSpecialization = {
    name,
    configuration,
  }: {
    specialisation.${name}.configuration = configuration;
  };
}
