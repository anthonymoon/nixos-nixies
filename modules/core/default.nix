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
  options.unified.core = with lib; {
    enable =
      mkEnableOption "unified core functionality"
      // {
        default = true;
      };
    hostname = mkOption {
      type = types.str;
      default = "nixos";
      description = ''
        System hostname used for network identification.
        This should be unique within your network environment.
      '';
    };
    stateVersion = mkOption {
      type = types.str;
      default = "24.11";
      description = ''
        NixOS state version for backwards compatibility.
        This should match the NixOS version when the system was first installed.
        Warning: Do not change this value unless you know what you're doing.
      '';
    };
    performance = {
      enable = mkOption {
        type = types.bool;
        default = true;
        description = ''
          Enable core performance optimizations including:
          - Automatic garbage collection
          - Temporary file cleanup on boot
          - Nix store optimization
        '';
      };
    };
  };
  config = lib.mkIf config.unified.core.enable {
    networking.hostName = config.unified.core.hostname;
    system.stateVersion = config.unified.core.stateVersion;
    networking.firewall.enable = lib.mkDefault true;
    security.sudo.wheelNeedsPassword = lib.mkDefault true;
    boot.tmp.cleanOnBoot = lib.mkDefault true;
    nix.gc.automatic = lib.mkDefault true;
  };
}
