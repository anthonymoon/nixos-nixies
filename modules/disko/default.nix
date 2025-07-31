{
  config,
  lib,
  pkgs,
  ...
}: let
  cfg = config.unified.disko;
in {
  options.unified.disko = {
    enable = lib.mkEnableOption "disko disk management";

    layout = lib.mkOption {
      type = lib.types.enum ["standard" "encrypted" "zfs" "btrfs"];
      default = "standard";
      description = "Disk layout type to use";
    };

    device = lib.mkOption {
      type = lib.types.str;
      default = "/dev/disk/by-id/nvme-CT2000T500SSD8_241047B9A4C2";
      description = "Primary disk device to partition";
    };

    swapSize = lib.mkOption {
      type = lib.types.str;
      default = "8G";
      description = "Size of swap partition";
    };

    encryptionPassphrase = lib.mkOption {
      type = lib.types.nullOr lib.types.str;
      default = null;
      description = "Encryption passphrase for encrypted layouts";
    };
  };

  config = lib.mkIf cfg.enable {
    disko.devices = import ./layouts/${cfg.layout}.nix {
      inherit lib;
      device = cfg.device;
      swapSize = cfg.swapSize;
      encryptionPassphrase = cfg.encryptionPassphrase;
    };
  };
}
