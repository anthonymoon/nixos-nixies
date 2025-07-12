{
  config,
  lib,
  pkgs,
  inputs,
  ...
}: let
  unified-lib = config.unified-lib or (import ../../lib {inherit inputs lib;});
in
  unified-lib.mkUnifiedModule {
    name = "gaming";
    description = "Gaming functionality with performance optimization";
    category = "entertainment";

    options = with lib; {
      steam = {
        enable = mkEnableOption "Steam gaming platform";
        proton = {
          enable = mkOption {
            type = types.bool;
            default = true;
            description = "Enable Proton for Windows games";
          };
          version = mkOption {
            type = types.str;
            default = "latest";
            description = "Proton version to use";
          };
        };
      };

      performance = {
        gamemode = mkEnableOption "GameMode for performance optimization" // {default = true;};
        mangohud = mkEnableOption "MangoHUD for performance monitoring";
        corectrl = mkEnableOption "CoreCtrl for GPU/CPU control";
      };

      streaming = {
        enable = mkEnableOption "Game streaming capabilities";
        sunshine = mkEnableOption "Sunshine game streaming server";
        obs = mkEnableOption "OBS Studio for streaming";
      };

      emulation = {
        enable = mkEnableOption "Game emulation support";
        retroarch = mkEnableOption "RetroArch multi-emulator";
        yuzu = mkEnableOption "Nintendo Switch emulator";
        rpcs3 = mkEnableOption "PlayStation 3 emulator";
      };
    };

    config = {
      cfg,
      config,
      lib,
      pkgs,
    }: {
      # Steam configuration
      programs.steam = lib.mkIf cfg.steam.enable {
        enable = true;
        remotePlay.openFirewall = true;
        dedicatedServer.openFirewall = true;
        gamescopeSession.enable = lib.mkDefault true;
      };

      # Performance optimization packages
      environment.systemPackages = with pkgs;
        lib.flatten [
          # Steam and related
          (lib.optionals cfg.steam.enable [
            steam
            steam-run
            steamcmd
          ])

          # Performance tools
          (lib.optionals cfg.performance.gamemode [gamemode])
          (lib.optionals cfg.performance.mangohud [mangohud])
          (lib.optionals cfg.performance.corectrl [corectrl])

          # Streaming tools
          (lib.optionals cfg.streaming.sunshine [sunshine])
          (lib.optionals cfg.streaming.obs [obs-studio])

          # Emulation
          (lib.optionals cfg.emulation.retroarch [retroarch])
          (lib.optionals cfg.emulation.yuzu [yuzu-mainline])
          (lib.optionals cfg.emulation.rpcs3 [rpcs3])

          # Utilities
          (lib.optionals cfg.enable [
            vulkan-tools
            glxinfo
            mesa-demos
          ])
        ];

      # GameMode configuration
      programs.gamemode = lib.mkIf cfg.performance.gamemode {
        enable = true;
        settings = {
          general = {
            renice = 10;
            ioprio = 7;
          };
          gpu = {
            apply_gpu_optimisations = "accept-responsibility";
            gpu_device = 0;
            amd_performance_level = "high";
          };
        };
      };

      # Graphics drivers and Vulkan support
      hardware.opengl = {
        enable = true;
        driSupport = true;
        driSupport32Bit = true;
        extraPackages = with pkgs; [
          vulkan-validation-layers
          vulkan-extension-layer
        ];
      };

      # Audio configuration for gaming
      security.rtkit.enable = lib.mkDefault true;
      services.pipewire = {
        enable = lib.mkDefault true;
        alsa.enable = lib.mkDefault true;
        pulse.enable = lib.mkDefault true;
      };

      # Network optimizations for gaming
      boot.kernel.sysctl = lib.mkIf cfg.performance.gamemode {
        # Reduce network latency
        "net.core.netdev_max_backlog" = 5000;
        "net.core.rmem_max" = 134217728;
        "net.core.wmem_max" = 134217728;
        "net.ipv4.tcp_rmem" = "4096 65536 134217728";
        "net.ipv4.tcp_wmem" = "4096 65536 134217728";
        "net.ipv4.tcp_congestion_control" = "bbr";
      };

      # Firewall configuration for gaming
      networking.firewall = lib.mkIf cfg.enable {
        allowedTCPPortRanges = [
          {
            from = 27000;
            to = 27100;
          } # Steam
        ];
        allowedUDPPortRanges = [
          {
            from = 27000;
            to = 27100;
          } # Steam
          {
            from = 4380;
            to = 4380;
          } # Steam
        ];
      };

      # User groups for gaming access
      users.groups.gamemode = {};

      # Udev rules for controllers
      services.udev.packages = with pkgs; [
        game-devices-udev-rules
      ];
    };

    # Security configuration for gaming
    security = cfg: {
      # Allow gamemode to adjust process priorities
      security.wrappers.gamemode = lib.mkIf cfg.performance.gamemode {
        source = "${pkgs.gamemode}/bin/gamemoderun";
        capabilities = "cap_sys_nice+ep";
        owner = "root";
        group = "gamemode";
      };

      # Polkit rules for GameMode
      security.polkit.extraConfig = lib.mkIf cfg.performance.gamemode ''
        polkit.addRule(function(action, subject) {
            if (action.id == "org.freedesktop.policykit.exec" &&
                action.lookup("program") == "${pkgs.gamemode}/bin/gamemoderun" &&
                subject.isInGroup("gamemode")) {
                return polkit.Result.YES;
            }
        });
      '';
    };

    dependencies = ["core"];
  }
