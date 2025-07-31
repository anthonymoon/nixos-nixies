{
  description = "Unified Modular NixOS Configuration Framework";
  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixos-unstable";
    nixpkgs-stable.url = "github:NixOS/nixpkgs/nixos-24.11";
    flake-parts = {
      url = "github:hercules-ci/flake-parts";
      inputs.nixpkgs-lib.follows = "nixpkgs";
    };
    home-manager = {
      url = "github:nix-community/home-manager";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    deploy-rs = {
      url = "github:serokell/deploy-rs";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    agenix = {
      url = "github:ryantm/agenix";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    disko = {
      url = "github:nix-community/disko";
      inputs.nixpkgs.follows = "nixpkgs";
    };
  };
  outputs = inputs @ {
    self,
    nixpkgs,
    flake-parts,
    ...
  }:
    flake-parts.lib.mkFlake {inherit inputs;} {
      systems = ["x86_64-linux" "aarch64-linux"];
      imports = [
        ./flake-modules/systems.nix
        ./flake-modules/packages.nix
        ./flake-modules/apps.nix
        ./flake-modules/checks.nix
        ./flake-modules/deployment.nix
        ./flake-modules/vm-images.nix
      ];
      flake = {
        lib = import ./lib {
          inherit inputs;
          inherit (nixpkgs) lib;
        };
        nixosModules = import ./modules;
        templates = import ./templates;
      };
      perSystem = {
        config,
        self',
        inputs',
        pkgs,
        system,
        ...
      }: {
        _module.args.pkgs = import nixpkgs {
          inherit system;
          config = {
            allowUnfree = true;
          };
        };
        devShells.default = pkgs.mkShell {
          buildInputs = with pkgs; [
            nixpkgs-fmt
            alejandra
            nil
            nix-tree
            inputs.deploy-rs.packages.${system}.default or pkgs.deploy-rs
            git
            pre-commit
            shellcheck
            jq
            statix
            deadnix
            hyperfine
            nodePackages.markdownlint-cli
            nix-du
          ];
          shellHook = ''
            echo "🏗️  Unified NixOS Development Environment"
            echo "📦 Available commands:"
            echo "  nix run .
            echo "  nix run .
            echo "  nix run .
            echo "  nix run .
            echo ""
            echo "💡 For more help, see: https://github.com/nixos-unified/docs"
          '';
        };
        formatter = pkgs.alejandra;
      };
    };
}
