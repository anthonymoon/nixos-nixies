{
  config,
  lib,
  pkgs,
  ...
}: {
  imports = [
    ./boot.nix
    ./users.nix
    ./nix.nix
    ./security.nix
    ./system.nix
  ];

  # Core unified options
  options.unified.core = with lib; {
    enable =
      mkEnableOption "unified core functionality"
      // {
        default = true;
      };

    hostname = mkOption {
      type = types.str;
      description = "System hostname";
    };

    stateVersion = mkOption {
      type = types.str;
      default = "24.11";
      description = "NixOS state version";
    };

    security = {
      enable = mkOption {
        type = types.bool;
        default = true;
        description = "Enable core security hardening";
      };
    };

    performance = {
      enable = mkOption {
        type = types.bool;
        default = true;
        description = "Enable core performance optimizations";
      };
    };
  };

  config = lib.mkIf config.unified.core.enable {
    # Set hostname and state version
    networking.hostName = config.unified.core.hostname;
    system.stateVersion = config.unified.core.stateVersion;

    # Security defaults
    networking.firewall.enable = lib.mkDefault true;
    security.sudo.wheelNeedsPassword = lib.mkDefault true;

    # Performance defaults
    boot.tmp.cleanOnBoot = lib.mkDefault true;
    nix.gc.automatic = lib.mkDefault true;
  };
}
