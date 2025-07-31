{
  self,
  inputs,
  ...
}: {
  flake.nixosConfigurations = let
    lib = inputs.nixpkgs.lib;
    system = "x86_64-linux";
    unified-lib = import ../lib {
      inherit inputs;
      inherit (inputs.nixpkgs) lib;
    };
    commonModules = [
      ../modules/core
      inputs.home-manager.nixosModules.home-manager
      inputs.disko.nixosModules.disko
    ];
    commonConfig = {
      _module.args.unified-lib = unified-lib;
      home-manager = {
        useGlobalPkgs = true;
        useUserPackages = true;
        extraSpecialArgs = {
          inherit inputs;
          unified-lib = unified-lib;
        };
        users = {};
      };
      system.stateVersion = "24.11";
      nixpkgs.config.allowUnfree = true;
    };
  in {
    nixies = unified-lib.mkSystem {
      hostname = "nixies";
      inherit system;
      profiles = ["base"];
      modules =
        commonModules
        ++ [
          commonConfig
          ../configurations/systems/nixies.nix
        ];
    };
  };
}