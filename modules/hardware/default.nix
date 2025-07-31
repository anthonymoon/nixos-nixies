{
  config,
  lib,
  pkgs,
  ...
}: {
  imports = [
    ./qemu.nix
  ];
}
