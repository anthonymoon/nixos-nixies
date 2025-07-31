{
  inputs,
  lib,
}: let
  systemFactory = import ./system-factory.nix {inherit inputs lib;};
  moduleFactory = import ./module-factory.nix {inherit lib;};
  validation = import ./validation.nix {inherit lib;};
  performance = import ./performance.nix {inherit lib;};
  security = import ./security.nix {inherit lib;};
in {
  inherit (systemFactory) mkSystem mkProfile mkSpecialization;
  inherit (moduleFactory) mkUnifiedModule mkFeatureModule mkServiceModule;
  inherit (validation) validateConfig validateSecurity validatePerformance;
  inherit (performance) optimizePackages lazyEvaluation parallelBuild;
  inherit (security) hardenSystem enableSecurityFeatures auditConfiguration;
  types = {
    enableOption = lib.mkEnableOption;
    securityLevel = lib.types.enum ["basic" "standard" "hardened" "paranoid"];
    performanceProfile = lib.types.enum ["minimal" "balanced" "performance"];
  };
  defaults = {
    security = {
      level = "standard";
      ssh.passwordAuth = false;
      firewall.enable = true;
      sudo.wheelNeedsPassword = true;
    };
    performance = {
      profile = "balanced";
      nix.optimizations = true;
      build.parallelism = true;
    };
    system = {
      stateVersion = "24.11";
      autoUpgrade = false;
      gc.automatic = true;
    };
  };
}
