{
  inputs,
  lib,
}: let
  # Import all library functions
  systemFactory = import ./system-factory.nix {inherit inputs lib;};
  moduleFactory = import ./module-factory.nix {inherit lib;};
  validation = import ./validation.nix {inherit lib;};
  performance = import ./performance.nix {inherit lib;};
  security = import ./security.nix {inherit lib;};
in {
  # System creation utilities
  inherit (systemFactory) mkSystem mkProfile mkSpecialization;

  # Module creation utilities
  inherit (moduleFactory) mkUnifiedModule mkFeatureModule mkServiceModule;

  # Validation utilities
  inherit (validation) validateConfig validateSecurity validatePerformance;

  # Performance optimization utilities
  inherit (performance) optimizePackages lazyEvaluation parallelBuild;

  # Security utilities
  inherit (security) hardenSystem enableSecurityFeatures auditConfiguration;

  # Common option types
  types = {
    enableOption = lib.mkEnableOption;
    securityLevel = lib.types.enum ["basic" "standard" "hardened" "paranoid"];
    performanceProfile = lib.types.enum ["minimal" "balanced" "performance"];
  };

  # Standard configurations
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
