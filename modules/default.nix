{
  # NixOS Unified Modules
  # This file exports all available modules for use in configurations

  imports = [
    ./core
    ./bleeding-edge
    ./desktop
    ./deployment
    ./gaming
    ./hardware
    ./media
    ./monitoring
    ./packages
    ./security
    ./services
  ];
}
