{
  description = "NixOS Unified Configuration Template";

  inputs = {
    # Use latest stable for enterprise, unstable for home/bleeding-edge
    nixpkgs.url = "github:NixOS/nixpkgs/nixos-24.11";
    nixpkgs-unstable.url = "github:NixOS/nixpkgs/nixos-unstable";

    # Home Manager
    home-manager = {
      url = "github:nix-community/home-manager/release-24.11";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    # Unified framework
    nixos-unified = {
      url = "path:../.."; # In real use: "github:user/nixos-unified"
      inputs.nixpkgs.follows = "nixpkgs";
    };

    # Deployment
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

    # Shared SSH public key for all users
    sharedSSHKey = "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIA898oqxREsBRW49hvI92CPWTebvwPoUeMSq5VMyzoM3 amoon@nixos-unified";

    # Common user configuration
    mkUser = name: isNormalUser: extraGroups: {
      ${name} = {
        inherit isNormalUser extraGroups;
        hashedPassword = "$6$rounds=4096$salt$password"; # Change this!
        openssh.authorizedKeys.keys = [sharedSSHKey];
        shell = nixpkgs.legacyPackages.${system}.fish;
      };
    };

    # Base configuration for all hosts
    baseConfig = {
      # Use unified library
      nixos-unified = nixos-unified.lib;

      # Shared modules
      imports = [
        nixos-unified.nixosModules.core
        home-manager.nixosModules.home-manager
      ];

      # Core unified settings
      unified.core = {
        enable = true;
        stateVersion = "24.11";
        security = {
          enable = true;
          level = "standard";
          ssh = {
            enable = true;
            passwordAuth = true; # For initial setup
            rootLogin = false;
          };
        };
      };

      # Users as specified
      users.users =
        (mkUser "amoon" true ["wheel" "networkmanager" "docker" "libvirtd"])
        // (mkUser "nixos" true ["wheel"])
        // {
          root = {
            hashedPassword = "$6$rounds=4096$salt$nixos"; # password: nixos
            openssh.authorizedKeys.keys = [sharedSSHKey];
          };
        };

      # UEFI systemd-boot (no secure boot)
      boot = {
        loader = {
          systemd-boot = {
            enable = true;
            editor = false;
          };
          efi.canTouchEfiVariables = true;
        };

        # Latest kernels
        kernelPackages = nixpkgs.legacyPackages.${system}.linuxPackages_latest;
      };

      # DHCP via systemd-networkd
      networking = {
        useNetworkd = true;
        useDHCP = false;

        # Enable systemd-networkd
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

      # Common programs
      programs = {
        fish.enable = true;
        git.enable = true;
      };

      # Home Manager
      home-manager = {
        useGlobalPkgs = true;
        useUserPackages = true;
        users.amoon = import ./home.nix;
      };
    };
  in {
    # Enterprise configuration - stable/secure packages
    nixosConfigurations.enterprise = nixpkgs.lib.nixosSystem {
      inherit system;
      modules = [
        baseConfig
        {
          # Enterprise-specific configuration
          unified.core.security.level = "hardened";

          # Use stable packages
          nixpkgs.config.allowUnfree = false; # Only FOSS for enterprise

          # Minimal desktop with greetd + niri
          services.greetd = {
            enable = true;
            settings = {
              default_session = {
                command = "${nixpkgs.legacyPackages.${system}.greetd.tuigreet}/bin/tuigreet --time --cmd niri-session";
                user = "greeter";
              };
            };
          };

          # Niri compositor
          programs.niri.enable = true;

          # Essential packages only
          environment.systemPackages = with nixpkgs.legacyPackages.${system}; [
            firefox
            foot
            waybar
            mako
          ];
        }
      ];
    };

    # Home configuration - bleeding-edge packages
    nixosConfigurations.home = nixpkgs.lib.nixosSystem {
      inherit system;
      modules = [
        baseConfig
        {
          # Use unstable packages for home
          nixpkgs.pkgs = nixpkgs-unstable.legacyPackages.${system};

          # Full desktop experience
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

          # Multiple desktop environments
          programs.niri.enable = true;
          programs.hyprland.enable = true;
          services.desktopManager.plasma6.enable = true;

          # Full package set
          environment.systemPackages = with nixpkgs-unstable.legacyPackages.${system}; [
            # Browsers
            firefox
            chromium

            # Development
            vscode
            git
            docker

            # Media
            mpv
            obs-studio
            gimp

            # Terminals
            foot
            kitty
            wezterm

            # Wayland tools
            waybar
            wofi
            mako
            grim
            slurp

            # KDE applications
            kate
            dolphin
            konsole
          ];

          # Enable services for full desktop
          services.pipewire = {
            enable = true;
            alsa.enable = true;
            pulse.enable = true;
          };

          hardware.bluetooth.enable = true;
          services.printing.enable = true;

          # Virtualization
          virtualisation = {
            docker.enable = true;
            libvirtd.enable = true;
          };
        }
      ];
    };

    # VM configuration - QEMU-optimized, no security restrictions
    nixosConfigurations.vm = nixpkgs.lib.nixosSystem {
      inherit system;
      modules = [
        baseConfig
        {
          # VM-specific configuration
          unified.core.security.level = "basic"; # Minimal security for VMs

          # QEMU guest optimizations
          services.qemuGuest.enable = true;
          services.spice-vdagentd.enable = true;

          # VM-specific kernel modules
          boot.initrd.availableKernelModules = [
            "ahci"
            "xhci_pci"
            "virtio_pci"
            "virtio_scsi"
            "sd_mod"
            "sr_mod"
          ];
          boot.kernelModules = ["virtio_balloon" "virtio_console" "virtio_rng"];

          # No firewall for VMs
          networking.firewall.enable = false;

          # Fast boot
          boot.loader.timeout = 1;

          # Simple desktop for VMs
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

          # VM-optimized packages
          environment.systemPackages = with nixpkgs.legacyPackages.${system}; [
            firefox
            foot
            nautilus
            gedit
          ];

          # Hardware configuration for VMs
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

    # Deployment configurations
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

    # Development shell
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
        echo "  nixos-rebuild switch --flake .#enterprise"
        echo "  nixos-rebuild switch --flake .#home"
        echo "  nixos-rebuild switch --flake .#vm"
        echo "  deploy .#enterprise"
        echo "  deploy .#home"
        echo "  deploy .#vm"
        echo ""
        echo "Users configured: amoon, nixos, root"
        echo "Default password: nixos (change immediately!)"
        echo ""
      '';
    };
  };
}
