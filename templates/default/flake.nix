{
  description = "NixOS Unified Configuration Template";
  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixos-24.11";
    nixpkgs-unstable.url = "github:NixOS/nixpkgs/nixos-unstable";
    home-manager = {
      url = "github:nix-community/home-manager/release-24.11";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    nixos-unified = {
      url = "path:../..";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    deploy-rs = {
      url = "github:serokell/deploy-rs";
      inputs.nixpkgs.follows = "nixpkgs";
    };
  };
  outputs = {
    self,
    nixpkgs,
    nixpkgs-unstable,
    home-manager,
    nixos-unified,
    deploy-rs,
    ...
  }: let
    system = "x86_64-linux";
    sharedSSHKey = "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIA898oqxREsBRW49hvI92CPWTebvwPoUeMSq5VMyzoM3 amoon@nixos-unified";
    mkUser = name: isNormalUser: extraGroups: {
      ${name} = {
        inherit isNormalUser extraGroups;
        hashedPassword = "$6$rounds=4096$salt$password";
        openssh.authorizedKeys.keys = [sharedSSHKey];
        shell = nixpkgs.legacyPackages.${system}.fish;
      };
    };
    baseConfig = {
      nixos-unified = nixos-unified.lib;
      imports = [
        nixos-unified.nixosModules.core
        home-manager.nixosModules.home-manager
      ];
      unified.core = {
        enable = true;
        stateVersion = "24.11";
        security = {
          enable = true;
          level = "standard";
          ssh = {
            enable = true;
            passwordAuth = true;
            rootLogin = false;
          };
        };
      };
      users.users =
        (mkUser "amoon" true ["wheel" "networkmanager" "docker" "libvirtd"])
        // (mkUser "nixos" true ["wheel"])
        // {
          root = {
            hashedPassword = "$6$rounds=4096$salt$nixos";
            openssh.authorizedKeys.keys = [sharedSSHKey];
          };
        };
      boot = {
        loader = {
          systemd-boot = {
            enable = true;
            editor = false;
          };
          efi.canTouchEfiVariables = true;
        };
        kernelPackages = nixpkgs.legacyPackages.${system}.linuxPackages_latest;
      };
      networking = {
        useNetworkd = true;
        useDHCP = false;
        systemd.network = {
          enable = true;
          networks."10-lan" = {
            matchConfig.Name = "en*";
            networkConfig = {
              DHCP = "yes";
              IPv6AcceptRA = true;
            };
            dhcpV4Config = {
              UseDNS = true;
              UseRoutes = true;
            };
          };
        };
      };
      programs = {
        fish.enable = true;
        git.enable = true;
      };
      home-manager = {
        useGlobalPkgs = true;
        useUserPackages = true;
        users.amoon = import ./home.nix;
      };
    };
  in {
    nixosConfigurations.enterprise = nixpkgs.lib.nixosSystem {
      inherit system;
      modules = [
        baseConfig
        {
          unified.core.security.level = "hardened";
          nixpkgs.config.allowUnfree = false;
          services.greetd = {
            enable = true;
            settings = {
              default_session = {
                command = "${nixpkgs.legacyPackages.${system}.greetd.tuigreet}/bin/tuigreet --time --cmd niri-session";
                user = "greeter";
              };
            };
          };
          programs.niri.enable = true;
          environment.systemPackages = with nixpkgs.legacyPackages.${system}; [
            firefox
            foot
            waybar
            mako
          ];
        }
      ];
    };
    nixosConfigurations.home = nixpkgs.lib.nixosSystem {
      inherit system;
      modules = [
        baseConfig
        {
          nixpkgs.pkgs = nixpkgs-unstable.legacyPackages.${system};
          services.greetd = {
            enable = true;
            settings = {
              default_session = {
                command = "${nixpkgs-unstable.legacyPackages.${system}.greetd.tuigreet}/bin/tuigreet --time --remember --sessions ${nixpkgs-unstable.legacyPackages.${system}.writeText "sessions" ''
                  niri-session
                  Hyprland
                  startplasma-wayland
                ''}";
                user = "greeter";
              };
            };
          };
          programs.niri.enable = true;
          programs.hyprland.enable = true;
          services.desktopManager.plasma6.enable = true;
          environment.systemPackages = with nixpkgs-unstable.legacyPackages.${system}; [
            firefox
            chromium
            vscode
            git
            docker
            mpv
            obs-studio
            gimp
            foot
            kitty
            wezterm
            waybar
            wofi
            mako
            grim
            slurp
            kate
            dolphin
            konsole
          ];
          services.pipewire = {
            enable = true;
            alsa.enable = true;
            pulse.enable = true;
          };
          hardware.bluetooth.enable = true;
          services.printing.enable = true;
          virtualisation = {
            docker.enable = true;
            libvirtd.enable = true;
          };
        }
      ];
    };
    nixosConfigurations.vm = nixpkgs.lib.nixosSystem {
      inherit system;
      modules = [
        baseConfig
        {
          unified.core.security.level = "basic";
          services.qemuGuest.enable = true;
          services.spice-vdagentd.enable = true;
          boot.initrd.availableKernelModules = [
            "ahci"
            "xhci_pci"
            "virtio_pci"
            "virtio_scsi"
            "sd_mod"
            "sr_mod"
          ];
          boot.kernelModules = ["virtio_balloon" "virtio_console" "virtio_rng"];
          networking.firewall.enable = false;
          boot.loader.timeout = 1;
          services.greetd = {
            enable = true;
            settings = {
              default_session = {
                command = "${nixpkgs.legacyPackages.${system}.greetd.tuigreet}/bin/tuigreet --time --cmd niri-session";
                user = "greeter";
              };
            };
          };
          programs.niri.enable = true;
          environment.systemPackages = with nixpkgs.legacyPackages.${system}; [
            firefox
            foot
            nautilus
            gedit
          ];
          fileSystems."/" = {
            device = "/dev/disk/by-label/nixos";
            fsType = "ext4";
          };
          fileSystems."/boot" = {
            device = "/dev/disk/by-label/boot";
            fsType = "vfat";
          };
          swapDevices = [
            {device = "/dev/disk/by-label/swap";}
          ];
        }
      ];
    };
    deploy.nodes = {
      enterprise = {
        hostname = "enterprise.local";
        profiles.system = {
          user = "root";
          path = deploy-rs.lib.${system}.activate.nixos self.nixosConfigurations.enterprise;
        };
      };
      home = {
        hostname = "home.local";
        profiles.system = {
          user = "root";
          path = deploy-rs.lib.${system}.activate.nixos self.nixosConfigurations.home;
        };
      };
      vm = {
        hostname = "vm.local";
        profiles.system = {
          user = "root";
          path = deploy-rs.lib.${system}.activate.nixos self.nixosConfigurations.vm;
        };
      };
    };
    devShells.${system}.default = nixpkgs.legacyPackages.${system}.mkShell {
      buildInputs = with nixpkgs.legacyPackages.${system}; [
        nixpkgs-fmt
        deploy-rs.packages.${system}.default
        git
      ];
      shellHook = ''
        echo "🏗️  NixOS Unified Template Development Environment"
        echo ""
        echo "Available commands:"
        echo "  nixos-rebuild switch --flake .
        echo "  nixos-rebuild switch --flake .
        echo "  nixos-rebuild switch --flake .
        echo "  deploy .
        echo "  deploy .
        echo "  deploy .
        echo ""
        echo "Users configured: amoon, nixos, root"
        echo "Default password: nixos (change immediately!)"
        echo ""
      '';
    };
  };
}
