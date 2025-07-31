{
  config,
  lib,
  pkgs,
  ...
}: {
  imports = [
    ./enterprise.nix
    ./workstation.nix
  ];
}
