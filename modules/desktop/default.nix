{
  config,
  lib,
  pkgs,
  ...
}: {
  imports = [
    ./enterprise.nix
    ./niri.nix
  ];
}
