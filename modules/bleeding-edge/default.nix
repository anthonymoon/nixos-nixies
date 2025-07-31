{
  config,
  lib,
  pkgs,
  inputs,
  ...
}: let
  unified-lib = import ../../lib {inherit inputs lib;};
in
  (unified-lib.mkUnifiedModule {
    name = "bleeding-edge";
    description = "Bleeding-edge package management and experimental features for home desktops";
    category = "system";
    options = with lib; {
      enable = mkEnableOption "bleeding-edge package management and experimental features";
      packages = {
        source = mkOption {
          type = types.enum ["nixpkgs-unstable" "nixos-unstable" "master" "local"];
          default = "nixpkgs-unstable";
          description = "Source for bleeding-edge packages";
        };
        override-stable = mkEnableOption "override stable packages with bleeding-edge versions";
        categories = {
          desktop = mkEnableOption "bleeding-edge desktop environment packages" // {default = true;};
          development = mkEnableOption "bleeding-edge development tools" // {default = true;};
          gaming = mkEnableOption "bleeding-edge gaming packages" // {default = true;};
          media = mkEnableOption "bleeding-edge media production tools" // {default = true;};
          system = mkEnableOption "bleeding-edge system components";
        };
        experimental = {
          enable = mkEnableOption "experimental and pre-release packages";
          allow-broken = mkEnableOption "allow packages marked as broken";
          allow-unfree = mkEnableOption "allow unfree packages" // {default = true;};
          allow-insecure = mkEnableOption "allow insecure packages (use with caution)";
        };
      };
      kernel = {
        version = mkOption {
          type = types.enum ["latest" "mainline" "zen" "xanmod" "liquorix" "rt"];
          default = "latest";
          description = "Kernel version to use";
        };
        patches = {
          gaming = mkEnableOption "apply gaming-optimized kernel patches";
          performance = mkEnableOption "apply performance optimization patches";
          security = mkEnableOption "apply latest security patches";
          experimental = mkEnableOption "apply experimental kernel patches";
        };
        modules = {
          out-of-tree = mkEnableOption "enable out-of-tree kernel modules";
          proprietary = mkEnableOption "enable proprietary kernel modules" // {default = true;};
        };
      };
      graphics = {
        drivers = mkOption {
          type = types.enum ["latest" "beta" "alpha" "git"];
          default = "latest";
          description = "Graphics driver version preference";
        };
        mesa = {
          version = mkOption {
            type = types.enum ["stable" "git" "llvm-git"];
            default = "git";
            description = "Mesa version to use";
          };
          optimizations = {
            enable = mkEnableOption "enable Mesa performance optimizations" // {default = true;};
            compiler = mkOption {
              type = types.enum ["gcc" "clang" "latest-clang"];
              default = "latest-clang";
              description = "Compiler for Mesa optimization";
            };
          };
        };
        vulkan = {
          beta-drivers = mkEnableOption "enable beta Vulkan drivers";
          experimental-features = mkEnableOption "enable experimental Vulkan features";
        };
      };
      desktop = {
        wayland = {
          compositor = mkOption {
            type = types.enum ["stable" "git" "experimental"];
            default = "git";
            description = "Wayland compositor version preference";
          };
          protocols = {
            experimental = mkEnableOption "enable experimental Wayland protocols" // {default = true;};
            custom = mkEnableOption "enable custom protocol implementations";
          };
        };
        gtk = {
          version = mkOption {
            type = types.enum ["3" "4" "git"];
            default = "4";
            description = "GTK version preference";
          };
          themes = {
            bleeding-edge = mkEnableOption "use bleeding-edge themes and customizations";
          };
        };
        qt = {
          version = mkOption {
            type = types.enum ["5" "6" "git"];
            default = "6";
            description = "Qt version preference";
          };
        };
      };
      development = {
        languages = {
          rust = {
            channel = mkOption {
              type = types.enum ["stable" "beta" "nightly"];
              default = "nightly";
              description = "Rust toolchain channel";
            };
          };
          python = {
            version = mkOption {
              type = types.enum ["3.11" "3.12" "3.13" "rc"];
              default = "3.12";
              description = "Python version";
            };
          };
          nodejs = {
            version = mkOption {
              type = types.enum ["18" "20" "21" "latest"];
              default = "latest";
              description = "Node.js version";
            };
          };
          go = {
            version = mkOption {
              type = types.enum ["1.21" "1.22" "rc" "tip"];
              default = "1.22";
              description = "Go version";
            };
          };
        };
        tools = {
          editors = {
            bleeding-edge = mkEnableOption "use bleeding-edge versions of editors" // {default = true;};
            experimental-features = mkEnableOption "enable experimental editor features";
          };
          lsp-servers = {
            latest = mkEnableOption "use latest LSP server versions" // {default = true;};
          };
        };
      };
      gaming = {
        drivers = {
          nvidia = {
            version = mkOption {
              type = types.enum ["stable" "beta" "vulkan-beta" "latest"];
              default = "latest";
              description = "NVIDIA driver version";
            };
          };
          amd = {
            version = mkOption {
              type = types.enum ["stable" "git" "experimental"];
              default = "git";
              description = "AMD driver version";
            };
          };
        };
        wine = {
          version = mkOption {
            type = types.enum ["stable" "staging" "tkg" "ge" "lutris"];
            default = "staging";
            description = "Wine version preference";
          };
          dxvk = mkOption {
            type = types.enum ["stable" "git" "async"];
            default = "git";
            description = "DXVK version";
          };
          vkd3d = mkOption {
            type = types.enum ["stable" "git"];
            default = "git";
            description = "VKD3D version";
          };
        };
        emulation = {
          latest = mkEnableOption "use latest emulator versions" // {default = true;};
          experimental = mkEnableOption "enable experimental emulation features";
        };
      };
      security = {
        sandbox = {
          relaxed = mkEnableOption "use relaxed sandbox for bleeding-edge builds";
        };
        verification = {
          skip-hash-check = mkEnableOption "skip hash verification for git packages (dangerous)";
          allow-unfree-redistribute = mkEnableOption "allow redistribution of unfree packages";
        };
      };
      build = {
        optimization = {
          level = mkOption {
            type = types.enum ["size" "speed" "aggressive" "native"];
            default = "speed";
            description = "Build optimization level";
          };
          parallel = mkOption {
            type = types.int;
            default = 0;
            description = "Number of parallel build jobs (0 = auto)";
          };
          ccache = mkEnableOption "enable ccache for faster compilation" // {default = true;};
          sccache = mkEnableOption "enable sccache for Rust compilation";
        };
        features = {
          lto = mkEnableOption "enable Link Time Optimization";
          pgo = mkEnableOption "enable Profile Guided Optimization";
          bolt = mkEnableOption "enable BOLT post-link optimization";
        };
      };
    };
    config = {
      cfg,
      config,
      lib,
      pkgs,
    }:
      lib.mkMerge [
        (lib.mkIf cfg.enable {
          nixpkgs = {
            config = lib.mkMerge [
              {
                allowUnfree = cfg.packages.experimental.allow-unfree;
                allowBroken = cfg.packages.experimental.allow-broken;
                allowInsecure = cfg.packages.experimental.allow-insecure;
                contentAddressedByDefault = true;
                experimental-features = [
                  "nix-command"
                  "flakes"
                  "repl-flake"
                  "auto-allocate-uids"
                  "cgroups"
                ];
              }
              (lib.mkIf cfg.packages.override-stable {
                packageOverrides = pkgs:
                  with pkgs; {
                    firefox = firefox-nightly;
                    vscode = vscode-insiders;
                    discord = discord-canary;
                    git = gitFull;
                    neovim = neovim-nightly;
                    steam = steam-beta;
                    lutris = lutris-freeworld;
                  };
              })
            ];
          };
          environment.systemPackages = with pkgs; [
            git-absorb
            git-branchless
            difftastic
            dust
            ripgrep-all
            fd
            bat
            exa
            zoxide
            starship
            bottom
            procs
            bandwhich
            choose
            sd
            hyperfine
            tokei
            rustup
            cargo-update
            cargo-audit
            cargo-outdated
            podman-compose
            dive
            lazydocker
            dog
            gping
            lsd
            broot
            gitui
            lazygit
            delta
          ];
          nix.settings = lib.mkMerge [
            {
              max-jobs =
                if cfg.build.optimization.parallel == 0
                then "auto"
                else cfg.build.optimization.parallel;
              cores = 0;
              experimental-features = [
                "nix-command"
                "flakes"
                "repl-flake"
                "auto-allocate-uids"
                "cgroups"
                "recursive-nix"
                "ca-derivations"
              ];
              builders-use-substitutes = true;
              keep-outputs = true;
              keep-derivations = true;
              sandbox =
                if cfg.security.sandbox.relaxed
                then "relaxed"
                else true;
              substituters = [
                "https://cache.nixos.org"
                "https://nix-community.cachix.org"
                "https://nixpkgs-unfree.cachix.org"
                "https://devenv.cachix.org"
                "https://cuda-maintainers.cachix.org"
                "https://numtide.cachix.org"
                "https://pre-commit-hooks.cachix.org"
              ];
              trusted-public-keys = [
                "cache.nixos.org-1:6NCHdD59X431o0gWypbMrAURkbJ16ZPMQFGspcDShjY="
                "nix-community.cachix.org-1:mB9FSh9qf2dCimDSUo8Zy7bkq5CX+/rkCWyvRCYg3Fs="
                "nixpkgs-unfree.cachix.org-1:hqvoInulhbV4nJ9yJOEr+4wxhDV4xq2d1DK7S6Nj6rs="
                "devenv.cachix.org-1:w1cLUi8dv3hnoSPGAuibQv+f9TZLr6cv/Hm9XgU50cw="
                "cuda-maintainers.cachix.org-1:0dq3bujKpuEPiCgBEKTZL2M6FnfCuBdNOcP2EMKR6Mg="
                "numtide.cachix.org-1:2ps1kLBUWjxIneOy2Aw2kO6s83S/6nFMW3ysq4Q2K6E="
                "pre-commit-hooks.cachix.org-1:Pkk3Panw5AW24TOv6kz3PvLhlH8puAsJTBbOPmBo7Rc="
              ];
            }
            (lib.mkIf cfg.build.optimization.ccache {
              extra-sandbox-paths = ["/var/cache/ccache"];
            })
          ];
          environment.variables = {
            MAKEFLAGS = "-j${toString (
              if cfg.build.optimization.parallel == 0
              then 8
              else cfg.build.optimization.parallel
            )}";
            CFLAGS = lib.mkMerge [
              (lib.mkIf (cfg.build.optimization.level == "speed") "-O3 -march=native")
              (lib.mkIf (cfg.build.optimization.level == "size") "-Os -march=native")
              (lib.mkIf (cfg.build.optimization.level == "aggressive") "-O3 -march=native -flto -ffast-math")
              (lib.mkIf (cfg.build.optimization.level == "native") "-O3 -march=native -mtune=native")
            ];
            CXXFLAGS = "$CFLAGS";
            CARGO_BUILD_JOBS = toString (
              if cfg.build.optimization.parallel == 0
              then 8
              else cfg.build.optimization.parallel
            );
            CCACHE_DIR = lib.mkIf cfg.build.optimization.ccache "/var/cache/ccache";
            USE_CCACHE = lib.mkIf cfg.build.optimization.ccache "1";
            RUSTC_WRAPPER = lib.mkIf cfg.build.optimization.sccache "sccache";
          };
          systemd.tmpfiles.rules = lib.mkMerge [
            (lib.mkIf cfg.build.optimization.ccache [
              "d /var/cache/ccache 0755 root root -"
            ])
            (lib.mkIf cfg.build.optimization.sccache [
              "d /var/cache/sccache 0755 root root -"
            ])
          ];
        })
        (lib.mkIf (cfg.enable && cfg.kernel.version != "stable") {
          boot.kernelPackages = lib.mkMerge [
            (lib.mkIf (cfg.kernel.version == "latest") pkgs.linuxPackages_latest)
            (lib.mkIf (cfg.kernel.version == "mainline") pkgs.linuxPackages_latest)
            (lib.mkIf (cfg.kernel.version == "zen") pkgs.linuxPackages_zen)
            (lib.mkIf (cfg.kernel.version == "xanmod") pkgs.linuxPackages_xanmod_latest)
            (lib.mkIf (cfg.kernel.version == "liquorix") pkgs.linuxPackages_lqx)
            (lib.mkIf (cfg.kernel.version == "rt") pkgs.linuxPackages_rt_latest)
          ];
          boot.kernelParams = lib.mkIf cfg.kernel.patches.gaming [
            "preempt=voluntary"
            "processor.max_cstate=1"
            "intel_idle.max_cstate=1"
            "intel_pstate=performance"
            "amd_pstate=guided"
          ];
          boot.kernel.sysctl = lib.mkIf cfg.kernel.patches.performance {
            "vm.max_map_count" = 2147483642;
            "kernel.sched_rt_runtime_us" = -1;
            "net.core.rmem_max" = 134217728;
            "net.core.wmem_max" = 134217728;
            "net.ipv4.tcp_rmem" = "4096 87380 134217728";
            "net.ipv4.tcp_wmem" = "4096 65536 134217728";
            "net.core.netdev_max_backlog" = 30000;
            "net.core.netdev_budget" = 600;
            "net.ipv4.tcp_congestion_control" = "bbr";
            "vm.dirty_ratio" = 15;
            "vm.dirty_background_ratio" = 5;
            "vm.swappiness" = 1;
            "vm.vfs_cache_pressure" = 50;
          };
        })
        (lib.mkIf (cfg.enable && cfg.graphics.drivers != "stable") {
          hardware.graphics = lib.mkIf (cfg.graphics.mesa.version != "stable") {
            extraPackages = with pkgs; [
              mesa.drivers
              amdvlk
              vulkan-loader
              vulkan-tools
              vulkan-headers
              vulkan-validation-layers
              intel-media-driver
              intel-compute-runtime
              rocm-opencl-icd
              rocm-opencl-runtime
            ];
            driSupport32Bit = true;
            extraPackages32 = with pkgs.pkgsi686Linux; [
              amdvlk
            ];
          };
          hardware.nvidia = lib.mkIf (cfg.graphics.drivers == "beta" || cfg.graphics.drivers == "latest") {
            package = lib.mkMerge [
              (lib.mkIf (cfg.graphics.drivers == "beta") config.boot.kernelPackages.nvidiaPackages.beta)
              (lib.mkIf (cfg.graphics.drivers == "latest") config.boot.kernelPackages.nvidiaPackages.latest)
            ];
            modesetting.enable = true;
            open = false;
            nvidiaSettings = true;
            powerManagement.enable = true;
            powerManagement.finegrained = cfg.graphics.vulkan.experimental-features;
          };
        })
        (lib.mkIf (cfg.enable && cfg.packages.categories.desktop) {
          environment.systemPackages = lib.mkIf cfg.desktop.wayland.protocols.experimental (with pkgs; [
            wayland-protocols
            wayland-scanner
            wlr-protocols
          ]);
          programs = {
            zsh.enable = true;
            fish.enable = true;
            direnv.enable = true;
            fzf.enable = true;
          };
        })
        (lib.mkIf (cfg.enable && cfg.packages.categories.development) {
          environment.systemPackages = lib.mkIf (cfg.development.languages.rust.channel != "stable") (with pkgs; [
            (rust-bin.selectLatestNightlyWith (toolchain:
              toolchain.default.override {
                extensions = ["rust-src" "rustfmt" "clippy" "rust-analyzer"];
              }))
          ]);
          services = {
            postgresql = {
              package = pkgs.postgresql_16;
              extraPlugins = with pkgs.postgresql_16.pkgs; [
                postgis
                timescaledb
                pg_partman
              ];
            };
            redis.servers.default = {
              enable = true;
              package = pkgs.redis;
            };
          };
        })
        (lib.mkIf (cfg.enable && cfg.packages.categories.gaming) {
          environment.systemPackages = with pkgs; [
            (lib.mkIf (cfg.gaming.wine.version == "staging") wine-staging)
            (lib.mkIf (cfg.gaming.wine.version == "tkg") wine-tkg)
            (lib.mkIf (cfg.gaming.wine.version == "ge") wine-ge)
            (lib.mkIf (cfg.gaming.wine.version == "lutris") lutris-freeworld)
            (lib.mkIf (cfg.gaming.dxvk == "git") dxvk)
            (lib.mkIf (cfg.gaming.vkd3d == "git") vkd3d)
            gamemode
            mangohud
            goverlay
            steamtinkerlaunch
            (lib.mkIf cfg.gaming.emulation.latest yuzu-mainline)
            (lib.mkIf cfg.gaming.emulation.latest rpcs3)
            (lib.mkIf cfg.gaming.emulation.latest dolphin-emu)
          ];
          programs = {
            steam.enable = true;
            gamemode.enable = true;
          };
        })
        (lib.mkIf (cfg.enable && cfg.packages.categories.media) {
          environment.systemPackages = with pkgs; [
            kdenlive
            davinci-resolve
            blender
            reaper
            bitwig-studio
            ardour
            gimp
            krita
            inkscape
            obs-studio
            obs-studio-plugins.wlrobs
            obs-studio-plugins.obs-vkcapture
          ];
          services.pipewire = {
            extraConfig.pipewire = {
              "context.properties" = {
                "default.clock.rate" = 48000;
                "default.clock.quantum" = 64;
                "default.clock.min-quantum" = 32;
                "default.clock.max-quantum" = 1024;
              };
            };
          };
        })
        (lib.mkIf cfg.enable {
          networking.firewall = {
            allowedTCPPorts = [3000 8000 8080 9000];
            allowedUDPPorts = [3478 19302 19303];
          };
          security.apparmor = {
            enable = true;
            packages = with pkgs; [
              apparmor-profiles
            ];
          };
        })
      ];
    dependencies = ["core" "hardware"];
  }) {
    inherit config lib pkgs inputs;
  }
