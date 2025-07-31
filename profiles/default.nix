{
  base = import ./base.nix;
  workstation = import ./workstation.nix;
  home-desktop = import ./home-desktop.nix;
  home-server = import ./home-server.nix;
  enterprise-workstation = import ./enterprise-workstation.nix;
  enterprise-server = import ./enterprise-server.nix;
  qemu = import ./qemu.nix;
}
