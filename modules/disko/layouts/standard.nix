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
          swap = {
            size = swapSize;
            content = {
              type = "swap";
              randomEncryption = true;
            };
          };
          root = {
            size = "100%";
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
  };
}
