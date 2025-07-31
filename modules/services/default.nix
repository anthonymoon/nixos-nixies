{
  config,
  lib,
  pkgs,
  ...
}: {
  imports = [
    ./self-hosting.nix
  ];
}
