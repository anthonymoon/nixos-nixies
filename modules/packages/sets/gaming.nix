{
  config,
  lib,
  pkgs,
  inputs,
  ...
}: let
  nixies-lib = import ../../../lib {inherit inputs lib;};
in
  (nixies-lib.mkUnifiedModule {
    name = "packages-gaming";
    description = "Gaming platform packages including Steam, performance tools, and controller support";
    category = "packages";
    options = with lib; {
      enable = mkEnableOption "gaming package set";
      platforms = {
        enable = mkEnableOption "gaming platforms and storefronts" // {default = true;};
        steam = {
          enable = mkEnableOption "Steam gaming platform" // {default = true;};
          proton = mkEnableOption "Proton compatibility layer for Windows games" // {default = true;};
          remote-play = mkEnableOption "Steam Remote Play functionality";
          vr = mkEnableOption "Steam VR support";
          big-picture = mkEnableOption "Steam Big Picture mode optimizations";
          compatibility = {
            enable = mkEnableOption "Steam compatibility tools" // {default = true;};
            tools = mkOption {
              type = types.listOf (types.enum ["proton-ge" "lutris-fshack" "steam-tinker-launch"]);
              default = ["proton-ge" "steam-tinker-launch"];
              description = "Additional Steam compatibility tools";
            };
          };
        };
        alternatives = {
          lutris = mkEnableOption "Lutris gaming platform manager";
          heroic = mkEnableOption "Heroic Games Launcher (Epic/GOG)";
          bottles = mkEnableOption "Bottles Windows compatibility";
          itch = mkEnableOption "Itch.io game client";
          gog-galaxy = mkEnableOption "GOG Galaxy client";
        };
      };
      performance = {
        enable = mkEnableOption "gaming performance optimization tools" // {default = true;};
        gamemode = {
          enable = mkEnableOption "GameMode automatic performance optimization" // {default = true;};
          scripts = mkEnableOption "custom GameMode scripts and hooks";
        };
        gamescope = {
          enable = mkEnableOption "Gamescope Wayland gaming compositor" // {default = true;};
          features = {
            hdr = mkEnableOption "HDR support";
            vrr = mkEnableOption "Variable Refresh Rate support";
            upscaling = mkEnableOption "FSR/DLSS upscaling support";
          };
        };
        monitoring = {
          enable = mkEnableOption "performance monitoring tools";
          tools = mkOption {
            type = types.listOf (types.enum ["mangohud" "goverlay" "corectrl" "missioncenter"]);
            default = ["mangohud" "goverlay"];
            description = "Performance monitoring tools";
          };
        };
        optimization = {
          cpu-governor = mkEnableOption "automatic CPU governor switching for gaming";
          io-scheduler = mkEnableOption "optimized I/O scheduler for gaming workloads";
          memory-tuning = mkEnableOption "memory and swap optimization for gaming";
          network-tuning = mkEnableOption "network latency optimization";
        };
      };
      controllers = {
        enable = mkEnableOption "gaming controller support" // {default = true;};
        ps5 = {
          enable = mkEnableOption "PlayStation 5 DualSense controller support";
          haptics = mkEnableOption "DualSense haptic feedback support";
          adaptive-triggers = mkEnableOption "adaptive trigger support";
          wireless = mkEnableOption "wireless connectivity support" // {default = true;};
        };
        xbox = {
          enable = mkEnableOption "Xbox controller support";
          wireless = mkEnableOption "Xbox wireless controller support" // {default = true;};
          elite = mkEnableOption "Xbox Elite controller support";
        };
        nintendo = {
          switch-pro = mkEnableOption "Nintendo Switch Pro controller support";
          joycons = mkEnableOption "Nintendo Switch Joy-Con support";
        };
        generic = {
          enable = mkEnableOption "generic controller support" // {default = true;};
          steam-input = mkEnableOption "Steam Input for controller configuration" // {default = true;};
          xpadneo = mkEnableOption "advanced Xbox controller driver";
          ds4drv = mkEnableOption "DualShock 4 controller driver";
        };
      };
      emulation = {
        enable = mkEnableOption "game console emulation";
        platforms = mkOption {
          type = types.listOf (types.enum [
            "retroarch"
            "yuzu"
            "ryujinx"
            "cemu"
            "rpcs3"
            "pcsx2"
            "dolphin"
            "mgba"
            "snes9x"
            "mupen64plus"
            "ppsspp"
            "desmume"
          ]);
          default = ["retroarch" "dolphin"];
          description = "Emulation platforms to install";
        };
        cores = {
          enable = mkEnableOption "RetroArch emulation cores" // {default = true;};
          auto-download = mkEnableOption "automatic core downloads";
        };
        bios-management = mkEnableOption "BIOS and firmware management tools";
      };
      wine = {
        enable = mkEnableOption "Wine Windows compatibility layer";
        version = mkOption {
          type = types.enum ["stable" "staging" "lutris" "ge-proton" "tkg"];
          default = "staging";
          description = "Wine version to install";
        };
        tools = {
          winetricks = mkEnableOption "Winetricks Windows component installer" // {default = true;};
          protontricks = mkEnableOption "Protontricks for Steam Proton prefix management";
          lutris-wine = mkEnableOption "Lutris Wine builds";
        };
        graphics = {
          dxvk = mkEnableOption "DXVK DirectX to Vulkan translation" // {default = true;};
          vkd3d = mkEnableOption "VKD3D Direct3D 12 to Vulkan translation";
          d9vk = mkEnableOption "D9VK Direct3D 9 to Vulkan translation";
        };
      };
      development = {
        enable = mkEnableOption "game development tools";
        engines = mkOption {
          type = types.listOf (types.enum ["godot" "unity" "unreal" "blender" "love2d"]);
          default = ["godot" "blender"];
          description = "Game engines to install";
        };
        tools = {
          aseprite = mkEnableOption "Aseprite pixel art editor";
          krita = mkEnableOption "Krita digital painting";
          audacity = mkEnableOption "Audacity audio editing";
          ldtk = mkEnableOption "LDTK level editor";
        };
      };
      streaming = {
        enable = mkEnableOption "game streaming and content creation tools";
        obs = {
          enable = mkEnableOption "OBS Studio for streaming/recording";
          plugins = mkEnableOption "OBS plugins for gaming" // {default = true;};
        };
        capture = {
          gpu-screen-recorder = mkEnableOption "GPU Screen Recorder for high-performance recording";
          replay-sorcery = mkEnableOption "Replay Sorcery instant replay";
        };
        streaming-tools = {
          streamlabs = mkEnableOption "Streamlabs OBS";
          restream = mkEnableOption "Restream multi-platform streaming";
        };
      };
      social = {
        enable = mkEnableOption "gaming social and community tools";
        discord = mkEnableOption "Discord gaming communication" // {default = true;};
        teamspeak = mkEnableOption "TeamSpeak voice communication";
        mumble = mkEnableOption "Mumble low-latency voice chat";
        game-launchers = {
          steam-overlay = mkEnableOption "Steam overlay integration";
          discord-rpc = mkEnableOption "Discord Rich Presence support";
        };
      };
    };
    config = {
      cfg,
      config,
      lib,
      pkgs,
    }:
      lib.mkIf cfg.enable {
        environment.systemPackages = with pkgs;
          lib.flatten [
            (lib.optionals cfg.platforms.steam.enable [
              steam
              steam-run
              steamcmd
            ])
            (lib.optionals cfg.platforms.steam.compatibility.enable [
              (lib.optionals (builtins.elem "proton-ge" cfg.platforms.steam.compatibility.tools) [
                proton-ge-bin
              ])
              (lib.optionals (builtins.elem "steam-tinker-launch" cfg.platforms.steam.compatibility.tools) [
                steamtinkerlaunch
              ])
            ])
            (lib.optionals cfg.platforms.alternatives.lutris [
              lutris
              lutris-freeworld
            ])
            (lib.optionals cfg.platforms.alternatives.heroic [
              heroic
            ])
            (lib.optionals cfg.platforms.alternatives.bottles [
              bottles
            ])
            (lib.optionals cfg.platforms.alternatives.itch [
              itch
            ])
            (lib.optionals cfg.performance.gamemode.enable [
              gamemode
            ])
            (lib.optionals cfg.performance.gamescope.enable [
              gamescope
            ])
            (lib.optionals
              (cfg.performance.monitoring.enable
                && builtins.elem "mangohud" cfg.performance.monitoring.tools) [
                mangohud
              ])
            (lib.optionals
              (cfg.performance.monitoring.enable
                && builtins.elem "goverlay" cfg.performance.monitoring.tools) [
                goverlay
              ])
            (lib.optionals
              (cfg.performance.monitoring.enable
                && builtins.elem "corectrl" cfg.performance.monitoring.tools) [
                corectrl
              ])
            (lib.optionals cfg.controllers.ps5.enable [
              dualsensectl
            ])
            (lib.optionals cfg.controllers.xbox.enable [
              xboxdrv
            ])
            (lib.optionals cfg.controllers.generic.xpadneo [
              linuxKernel.packages.linux_zen.xpadneo
            ])
            (lib.optionals cfg.controllers.generic.ds4drv [
              ds4drv
            ])
            (lib.optionals
              (cfg.emulation.enable
                && builtins.elem "retroarch" cfg.emulation.platforms) [
                retroarch
                retroarch-assets
                retroarch-joypad-autoconfig
              ])
            (lib.optionals
              (cfg.emulation.enable
                && builtins.elem "yuzu" cfg.emulation.platforms) [
                yuzu-mainline
              ])
            (lib.optionals
              (cfg.emulation.enable
                && builtins.elem "ryujinx" cfg.emulation.platforms) [
                ryujinx
              ])
            (lib.optionals
              (cfg.emulation.enable
                && builtins.elem "dolphin" cfg.emulation.platforms) [
                dolphin-emu
              ])
            (lib.optionals
              (cfg.emulation.enable
                && builtins.elem "rpcs3" cfg.emulation.platforms) [
                rpcs3
              ])
            (lib.optionals
              (cfg.emulation.enable
                && builtins.elem "pcsx2" cfg.emulation.platforms) [
                pcsx2
              ])
            (lib.optionals
              (cfg.emulation.enable
                && builtins.elem "ppsspp" cfg.emulation.platforms) [
                ppsspp
              ])
            (lib.optionals cfg.wine.enable [
              (
                if cfg.wine.version == "staging"
                then wine-staging
                else if cfg.wine.version == "lutris"
                then lutris-freeworld
                else if cfg.wine.version == "ge-proton"
                then wine-ge
                else wine
              )
            ])
            (lib.optionals cfg.wine.tools.winetricks [
              winetricks
            ])
            (lib.optionals cfg.wine.tools.protontricks [
              protontricks
            ])
            (lib.optionals cfg.wine.graphics.dxvk [
              dxvk
            ])
            (lib.optionals cfg.wine.graphics.vkd3d [
              vkd3d
            ])
            (lib.optionals
              (cfg.development.enable
                && builtins.elem "godot" cfg.development.engines) [
                godot_4
              ])
            (lib.optionals
              (cfg.development.enable
                && builtins.elem "blender" cfg.development.engines) [
                blender
              ])
            (lib.optionals
              (cfg.development.enable
                && builtins.elem "love2d" cfg.development.engines) [
                love
              ])
            (lib.optionals cfg.development.tools.aseprite [
              aseprite
            ])
            (lib.optionals cfg.development.tools.krita [
              krita
            ])
            (lib.optionals cfg.streaming.obs.enable [
              obs-studio
            ])
            (lib.optionals cfg.streaming.obs.plugins [
              obs-studio-plugins.wlrobs
              obs-studio-plugins.obs-vkcapture
              obs-studio-plugins.obs-pipewire-audio-capture
              obs-studio-plugins.looking-glass-obs
            ])
            (lib.optionals cfg.streaming.capture.gpu-screen-recorder [
              gpu-screen-recorder
            ])
            (lib.optionals cfg.streaming.capture.replay-sorcery [
              replay-sorcery
            ])
            (lib.optionals cfg.social.discord [
              discord
              webcord
            ])
            (lib.optionals cfg.social.teamspeak [
              teamspeak_client
            ])
            (lib.optionals cfg.social.mumble [
              mumble
            ])
          ];
        programs = lib.mkMerge [
          (lib.mkIf cfg.platforms.steam.enable {
            steam = {
              enable = true;
              remotePlay.openFirewall = cfg.platforms.steam.remote-play;
              dedicatedServer.openFirewall = false;
              extraCompatPackages = lib.optionals cfg.platforms.steam.compatibility.enable [
                pkgs.proton-ge-bin
              ];
            };
          })
          (lib.mkIf cfg.performance.gamemode.enable {
            gamemode = {
              enable = true;
              settings = {
                general = {
                  renice = 10;
                  ioprio = 1;
                  inhibit_screensaver = 1;
                };
                gpu = {
                  apply_gpu_optimisations = "accept-responsibility";
                  gpu_device = 0;
                  amd_performance_level = "high";
                };
                cpu = {
                  park_cores = "no";
                  pin_cores = "no";
                };
              };
            };
          })
        ];
        hardware = {
          opengl = {
            enable = true;
            driSupport = true;
            driSupport32Bit = true;
            extraPackages = with pkgs; [
              mesa.drivers
              intel-media-driver
              intel-compute-runtime
              vaapiIntel
              amdvlk
              rocm-opencl-icd
              vulkan-loader
              vulkan-validation-layers
              vulkan-tools
            ];
            extraPackages32 = with pkgs.pkgsi686Linux; [
              amdvlk
              driversi686Linux.mesa
            ];
          };
          steam-hardware.enable = cfg.platforms.steam.enable;
          xboxdrv.enable = cfg.controllers.xbox.enable;
          bluetooth = lib.mkIf (cfg.controllers.ps5.wireless || cfg.controllers.xbox.wireless) {
            enable = true;
            powerOnBoot = true;
            settings = {
              General = {
                Enable = "Source,Sink,Media,Socket";
                Experimental = true;
              };
            };
          };
        };
        services = lib.mkMerge [
          (lib.mkIf cfg.controllers.enable {
            udev = {
              packages = lib.flatten [
                (lib.optionals cfg.controllers.ps5.enable [
                  pkgs.dualsensectl
                ])
                (lib.optionals cfg.platforms.steam.enable [
                  pkgs.steam
                ])
              ];
            };
          })
          {
            pipewire = {
              extraConfig.pipewire = lib.mkIf cfg.performance.enable {
                "context.properties" = {
                  "default.clock.rate" = 48000;
                  "default.clock.quantum" = 32;
                  "default.clock.min-quantum" = 32;
                  "default.clock.max-quantum" = 1024;
                };
              };
            };
          }
        ];
        security = {
          rtkit.enable = true;
          polkit.extraConfig = lib.mkIf cfg.performance.gamemode.enable ''
            polkit.addRule(function(action, subject) {
            if ((action.id == "org.freedesktop.RealtimeKit1.acquire-high-priority" ||
            action.id == "org.freedesktop.RealtimeKit1.acquire-real-time") &&
            subject.isInGroup("gamemode")) {
            return polkit.Result.YES;
            }
            });
          '';
        };
        boot = {
          kernelParams = lib.optionals cfg.performance.optimization.memory-tuning [
            "vm.max_map_count=2147483642"
            "transparent_hugepage=madvise"
          ];
          kernel.sysctl = lib.mkMerge [
            (lib.mkIf cfg.performance.optimization.memory-tuning {
              "vm.swappiness" = 1;
              "vm.vfs_cache_pressure" = 50;
              "vm.dirty_ratio" = 3;
              "vm.dirty_background_ratio" = 2;
            })
            (lib.mkIf cfg.performance.optimization.network-tuning {
              "net.core.rmem_max" = 16777216;
              "net.core.wmem_max" = 16777216;
              "net.ipv4.tcp_rmem" = "4096 87380 16777216";
              "net.ipv4.tcp_wmem" = "4096 65536 16777216";
              "net.core.netdev_max_backlog" = 30000;
              "net.ipv4.tcp_congestion_control" = "bbr";
            })
          ];
        };
        environment.variables = lib.mkMerge [
          {
            GAMING_SYSTEM = "1";
            MANGOHUD =
              lib.mkIf
              (cfg.performance.monitoring.enable
                && builtins.elem "mangohud" cfg.performance.monitoring.tools) "1";
          }
          (lib.mkIf cfg.wine.enable {
            WINEPREFIX = "$HOME/.wine";
            WINEARCH = "win64";
          })
          (lib.mkIf cfg.controllers.enable {
            SDL_JOYSTICK_HIDAPI_PS5 = lib.mkIf cfg.controllers.ps5.enable "1";
            SDL_JOYSTICK_HIDAPI_PS5_RUMBLE = lib.mkIf cfg.controllers.ps5.haptics "1";
          })
        ];
        networking.firewall = {
          allowedTCPPorts = lib.flatten [
            (lib.optionals cfg.platforms.steam.enable [27015 27036])
            (lib.optionals cfg.platforms.steam.remote-play [27031 27032 27033 27034 27035 27036])
          ];
          allowedUDPPorts = lib.flatten [
            (lib.optionals cfg.platforms.steam.enable [27015 27031 27036])
          ];
        };
        users.groups = {
          gamemode = lib.mkIf cfg.performance.gamemode.enable {};
        };
        users.extraGroups.gamemode = lib.mkIf cfg.performance.gamemode.enable {
          members = [];
        };
        fonts.packages = with pkgs; [
          corefonts
          liberation_ttf
          dejavu_fonts
        ];
      };
    dependencies = ["core" "hardware" "desktop"];
  }) {
    inherit config lib pkgs inputs;
  }
