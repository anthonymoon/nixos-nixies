{
  lib,
  device,
  swapSize,
  ...
}: {
  disk = {
    main = {
      type = "disk";
      device = device;
      content = {
        type = "gpt";
        partitions = {
          ESP = {
            size = "512M";
            type = "EF00";
            content = {
              type = "filesystem";
              format = "vfat";
              mountpoint = "/boot";
              mountOptions = ["defaults"];
            };
          };
          zfs = {
            size = "100%";
            content = {
              type = "zfs";
              pool = "rpool";
            };
          };
        };
      };
    };
  };

  zpool = {
    rpool = {
      type = "zpool";
      options = {
        ashift = "12";
        autotrim = "on";
      };
      rootFsOptions = {
        acltype = "posixacl";
        canmount = "off";
        compression = "zstd";
        dnodesize = "auto";
        normalization = "formD";
        relatime = "on";
        xattr = "sa";
      };

      datasets = {
        root = {
          type = "zfs_fs";
          mountpoint = "/";
          options = {
            canmount = "noauto";
            mountpoint = "legacy";
          };
        };
        nix = {
          type = "zfs_fs";
          mountpoint = "/nix";
          options = {
            atime = "off";
            canmount = "on";
            mountpoint = "legacy";
          };
        };
        home = {
          type = "zfs_fs";
          mountpoint = "/home";
          options = {
            canmount = "on";
            mountpoint = "legacy";
          };
        };
        var = {
          type = "zfs_fs";
          mountpoint = "/var";
          options = {
            canmount = "on";
            mountpoint = "legacy";
          };
        };
        "var/log" = {
          type = "zfs_fs";
          mountpoint = "/var/log";
          options = {
            canmount = "on";
            mountpoint = "legacy";
          };
        };
      };
    };
  };
}
