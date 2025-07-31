{
  lib,
  device,
  swapSize,
  encryptionPassphrase,
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
          luks = {
            size = "100%";
            content = {
              type = "luks";
              name = "cryptroot";
              settings = {
                allowDiscards = true;
                keyFile = lib.mkIf (encryptionPassphrase != null) null;
              };
              askPassword = encryptionPassphrase == null;
              content = {
                type = "lvm_pv";
                vg = "pool";
              };
            };
          };
        };
      };
    };
  };

  lvm_vg = {
    pool = {
      type = "lvm_vg";
      lvs = {
        swap = {
          size = swapSize;
          content = {
            type = "swap";
            resumeDevice = true;
          };
        };
        root = {
          size = "100%FREE";
          content = {
            type = "filesystem";
            format = "ext4";
            mountpoint = "/";
            mountOptions = ["defaults" "noatime"];
          };
        };
      };
    };
  };
}
