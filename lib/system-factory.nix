{
  inputs,
  lib,
}: {
  #
  #
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
    securityDefaults = {
      networking.firewall.enable = lib.mkDefault true;
      services.openssh.settings = {
        PermitRootLogin = lib.mkDefault "no";
        PasswordAuthentication = lib.mkDefault false;
      };
      security.sudo.wheelNeedsPassword = lib.mkDefault true;
    };
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
          ../modules/core
          securityDefaults
          performanceDefaults
          (lib.optionalAttrs (hardware != null) hardware)
        ]
        ++ (map (profile: ../profiles/${profile}.nix) profiles)
        ++ [
          {
            nixies.core.hostname = hostname;
            system.stateVersion = lib.mkDefault "24.11";
            users.users = users;
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
  #
  #
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
  #
  #
  mkSpecialization = {
    name,
    configuration,
  }: {
    specialisation.${name}.configuration = configuration;
  };
}
