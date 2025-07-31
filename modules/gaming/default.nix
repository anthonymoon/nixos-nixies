{
  config,
  lib,
  pkgs,
  inputs,
  ...
}: let
  nixies-lib = import ../../lib {inherit inputs lib;};
in
  (nixies-lib.mkUnifiedModule {
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
      programs.steam = lib.mkIf cfg.steam.enable {
        enable = true;
        remotePlay.openFirewall = true;
        dedicatedServer.openFirewall = true;
        gamescopeSession.enable = lib.mkDefault true;
      };
      environment.systemPackages = with pkgs;
        lib.flatten [
          (lib.optionals cfg.steam.enable [
            steam
            steam-run
            steamcmd
          ])
          (lib.optionals cfg.performance.gamemode [gamemode])
          (lib.optionals cfg.performance.mangohud [mangohud])
          (lib.optionals cfg.performance.corectrl [corectrl])
          (lib.optionals cfg.streaming.sunshine [sunshine])
          (lib.optionals cfg.streaming.obs [obs-studio])
          (lib.optionals cfg.emulation.retroarch [retroarch])
          (lib.optionals cfg.emulation.yuzu [yuzu-mainline])
          (lib.optionals cfg.emulation.rpcs3 [rpcs3])
          (lib.optionals cfg.enable [
            vulkan-tools
            glxinfo
            mesa-demos
          ])
        ];
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
      hardware.graphics = {
        enable = true;
        driSupport = true;
        driSupport32Bit = true;
        extraPackages = with pkgs; [
          vulkan-validation-layers
          vulkan-extension-layer
        ];
      };
      security.rtkit.enable = lib.mkDefault true;
      services.pipewire = {
        enable = lib.mkDefault true;
        alsa.enable = lib.mkDefault true;
        pulse.enable = lib.mkDefault true;
      };
      boot.kernel.sysctl = lib.mkIf cfg.performance.gamemode {
        "net.core.netdev_max_backlog" = 5000;
        "net.core.rmem_max" = 134217728;
        "net.core.wmem_max" = 134217728;
        "net.ipv4.tcp_rmem" = "4096 65536 134217728";
        "net.ipv4.tcp_wmem" = "4096 65536 134217728";
        "net.ipv4.tcp_congestion_control" = "bbr";
      };
      networking.firewall = lib.mkIf cfg.enable {
        allowedTCPPortRanges = [
          {
            from = 27000;
            to = 27100;
          }
        ];
        allowedUDPPortRanges = [
          {
            from = 27000;
            to = 27100;
          }
          {
            from = 4380;
            to = 4380;
          }
        ];
      };
      users.groups.gamemode = {};
      services.udev.packages = with pkgs; [
        game-devices-udev-rules
      ];
    };
    security = cfg: {
      security.wrappers.gamemode = lib.mkIf cfg.performance.gamemode {
        source = "${pkgs.gamemode}/bin/gamemoderun";
        capabilities = "cap_sys_nice+ep";
        owner = "root";
        group = "gamemode";
      };
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
  }) {
    inherit config lib pkgs inputs;
  }
