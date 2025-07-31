{
  self,
  inputs,
  ...
}: {
  flake.nixosConfigurations = let
    lib = inputs.nixpkgs.lib;
    system = "x86_64-linux";
    nixies-lib = import ../lib {
      inherit inputs;
      inherit (inputs.nixpkgs) lib;
    };
    commonModules = [
      ../modules/core
      inputs.home-manager.nixosModules.home-manager
      inputs.disko.nixosModules.disko
    ];
    commonConfig = {
      _module.args.nixies-lib = nixies-lib;
      home-manager = {
        useGlobalPkgs = true;
        useUserPackages = true;
        extraSpecialArgs = {
          inherit inputs;
          nixies-lib = nixies-lib;
        };
        users = {};
      };
      system.stateVersion = "24.11";
      nixpkgs.config.allowUnfree = true;
    };
  in {
    nixies = nixies-lib.mkSystem {
      hostname = "nixies";
      inherit system;
      profiles = ["base"];
      modules =
        commonModules
        ++ [
          commonConfig
          ../configurations/systems/nixies.nix
          {
            nixpkgs.overlays = [
              inputs.nix-gaming.overlays.default
            ];
            imports = [
              inputs.nix-gaming.nixosModules.pipewireLowLatency
              inputs.nix-gaming.nixosModules.platformOptimizations
            ];
          }
        ];
    };
  };
}