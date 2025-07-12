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
    name = "gaming-advanced";
    description = "Advanced gaming features including VR, RGB peripherals, and cutting-edge gaming technologies";
    category = "entertainment";

    options = with lib; {
      enable = mkEnableOption "advanced gaming features";

      vr = {
        enable = mkEnableOption "Virtual Reality support";

        runtimes = {
          openxr = mkEnableOption "OpenXR runtime support" // {default = true;};
          steamvr = mkEnableOption "SteamVR support";
          monado = mkEnableOption "Monado open-source XR runtime";
        };

        devices = {
          oculus = mkEnableOption "Oculus/Meta headset support";
          htc-vive = mkEnableOption "HTC Vive headset support";
          valve-index = mkEnableOption "Valve Index headset support";
          pico = mkEnableOption "Pico headset support";
          varjo = mkEnableOption "Varjo headset support";
        };

        tracking = {
          lighthouse = mkEnableOption "SteamVR Lighthouse tracking";
          inside-out = mkEnableOption "Inside-out tracking support";
          external-cameras = mkEnableOption "External camera tracking";
        };

        optimization = {
          low-latency = mkEnableOption "VR low-latency optimizations" // {default = true;};
          motion-smoothing = mkEnableOption "Motion smoothing/reprojection";
          foveated-rendering = mkEnableOption "Foveated rendering support";
        };
      };

      rgb = {
        enable = mkEnableOption "RGB lighting and peripheral control";

        software = {
          openrgb = mkEnableOption "OpenRGB universal RGB control" // {default = true;};
          ckb-next = mkEnableOption "Corsair RGB keyboard/mouse control";
          razergenie = mkEnableOption "Razer device control";
          gx52 = mkEnableOption "Logitech G device control";
          msi-rgb = mkEnableOption "MSI motherboard RGB control";
          asus-rog = mkEnableOption "ASUS ROG device control";
        };

        effects = {
          audio-reactive = mkEnableOption "Audio-reactive RGB effects";
          game-integration = mkEnableOption "Game-integrated RGB effects";
          ambient-lighting = mkEnableOption "Ambient lighting effects";
        };

        devices = {
          keyboards = mkEnableOption "RGB keyboard support" // {default = true;};
          mice = mkEnableOption "RGB mouse support" // {default = true;};
          headsets = mkEnableOption "RGB headset support";
          case-fans = mkEnableOption "RGB case fan control";
          gpu = mkEnableOption "GPU RGB control";
          motherboard = mkEnableOption "Motherboard RGB control";
          memory = mkEnableOption "RGB memory control";
        };
      };

      controllers = {
        enable = mkEnableOption "Advanced gaming controller support" // {default = true;};

        xbox = {
          wireless = mkEnableOption "Xbox wireless controller support" // {default = true;};
          elite = mkEnableOption "Xbox Elite controller support";
          adaptive = mkEnableOption "Xbox Adaptive controller support";
        };

        playstation = {
          dualsense = mkEnableOption "PlayStation 5 DualSense controller support" // {default = true;};
          dualshock4 = mkEnableOption "PlayStation 4 DualShock controller support" // {default = true;};
          haptic-feedback = mkEnableOption "DualSense haptic feedback";
          adaptive-triggers = mkEnableOption "DualSense adaptive triggers";
        };

        nintendo = {
          pro-controller = mkEnableOption "Nintendo Pro Controller support";
          joycons = mkEnableOption "Nintendo Joy-Con support";
          motion-controls = mkEnableOption "Nintendo motion control support";
        };

        specialty = {
          racing-wheels = mkEnableOption "Racing wheel support";
          flight-sticks = mkEnableOption "Flight stick/HOTAS support";
          arcade-sticks = mkEnableOption "Arcade fighting stick support";
          dance-pads = mkEnableOption "Dance pad support";
          guitar-hero = mkEnableOption "Guitar Hero controller support";
        };

        features = {
          rumble = mkEnableOption "Controller rumble/vibration" // {default = true;};
          gyroscope = mkEnableOption "Controller gyroscope support";
          touchpad = mkEnableOption "Controller touchpad support";
          audio = mkEnableOption "Controller audio (headset jack)";
        };
      };

      audio = {
        enable = mkEnableOption "Gaming audio optimizations" // {default = true;};

        low-latency = {
          enable = mkEnableOption "Low-latency audio for competitive gaming" // {default = true;};
          buffer-size = mkOption {
            type = types.int;
            default = 64;
            description = "Audio buffer size for low latency (samples)";
          };
          sample-rate = mkOption {
            type = types.int;
            default = 48000;
            description = "Audio sample rate for gaming";
          };
        };

        spatial = {
          enable = mkEnableOption "Spatial audio support";
          hrtf = mkEnableOption "HRTF (Head-Related Transfer Function) processing";
          surround = mkEnableOption "Virtual surround sound";
          binaural = mkEnableOption "Binaural audio processing";
        };

        enhancement = {
          noise-suppression = mkEnableOption "Real-time noise suppression";
          echo-cancellation = mkEnableOption "Echo cancellation for voice chat";
          compression = mkEnableOption "Dynamic range compression";
          bass-boost = mkEnableOption "Bass enhancement";
        };

        voice-chat = {
          enable = mkEnableOption "Voice chat optimizations" // {default = true;};
          push-to-talk = mkEnableOption "Global push-to-talk support";
          voice-activity = mkEnableOption "Voice activity detection";
          noise-gate = mkEnableOption "Noise gate for microphone";
        };
      };

      streaming = {
        enable = mkEnableOption "Game streaming and recording";

        local = {
          sunshine = mkEnableOption "Sunshine game streaming server";
          steam-link = mkEnableOption "Steam Link streaming";
          parsec = mkEnableOption "Parsec game streaming";
          moonlight = mkEnableOption "Moonlight game streaming client";
        };

        broadcast = {
          obs = mkEnableOption "OBS Studio for streaming/recording" // {default = true;};
          streamlabs = mkEnableOption "Streamlabs OBS";
          restream = mkEnableOption "Restream multi-platform streaming";
        };

        platforms = {
          twitch = mkEnableOption "Twitch streaming integration";
          youtube = mkEnableOption "YouTube streaming integration";
          discord = mkEnableOption "Discord streaming integration";
          facebook = mkEnableOption "Facebook Gaming integration";
        };

        features = {
          hardware-encoding = mkEnableOption "Hardware-accelerated encoding" // {default = true;};
          screen-capture = mkEnableOption "Screen capture optimization";
          game-capture = mkEnableOption "Game-specific capture";
          webcam = mkEnableOption "Webcam integration";
          green-screen = mkEnableOption "Green screen/chroma key";
        };
      };

      launchers = {
        enable = mkEnableOption "Game launcher and store support" // {default = true;};

        native = {
          steam = mkEnableOption "Steam" // {default = true;};
          lutris = mkEnableOption "Lutris game manager" // {default = true;};
          heroic = mkEnableOption "Heroic Games Launcher (Epic/GOG)" // {default = true;};
          bottles = mkEnableOption "Bottles Wine manager";
          gamemode-ui = mkEnableOption "GameMode UI launcher";
        };

        web = {
          stadia = mkEnableOption "Google Stadia (web)";
          geforce-now = mkEnableOption "NVIDIA GeForce Now";
          xbox-cloud = mkEnableOption "Xbox Cloud Gaming";
          luna = mkEnableOption "Amazon Luna";
        };

        stores = {
          epic = mkEnableOption "Epic Games Store support";
          gog = mkEnableOption "GOG Galaxy support";
          origin = mkEnableOption "EA Origin support";
          uplay = mkEnableOption "Ubisoft Connect support";
          battlenet = mkEnableOption "Battle.net support";
          itch = mkEnableOption "itch.io support";
        };
      };

      optimization = {
        enable = mkEnableOption "Gaming system optimizations" // {default = true;};

        cpu = {
          governor = mkOption {
            type = types.enum ["performance" "ondemand" "conservative" "powersave"];
            default = "performance";
            description = "CPU frequency governor for gaming";
          };

          affinity = mkEnableOption "CPU affinity optimization for games";
          realtime = mkEnableOption "Real-time process priorities";
          isolation = mkEnableOption "CPU core isolation for gaming";
        };

        gpu = {
          overclocking = mkEnableOption "GPU overclocking support";
          fan-curves = mkEnableOption "Custom GPU fan curves";
          power-limits = mkEnableOption "GPU power limit adjustments";
          memory-clocks = mkEnableOption "GPU memory clock optimization";
        };

        memory = {
          huge-pages = mkEnableOption "Huge pages for memory optimization";
          zram = mkEnableOption "ZRAM compression for more available memory";
          ksm = mkEnableOption "Kernel Same-page Merging";
          numa = mkEnableOption "NUMA memory optimization";
        };

        storage = {
          scheduler = mkOption {
            type = types.enum ["noop" "deadline" "cfq" "bfq" "kyber" "mq-deadline"];
            default = "mq-deadline";
            description = "I/O scheduler for gaming performance";
          };

          readahead = mkOption {
            type = types.int;
            default = 8192;
            description = "Read-ahead value for game loading";
          };

          swappiness = mkOption {
            type = types.int;
            default = 1;
            description = "Swappiness value for gaming";
          };
        };

        network = {
          latency = mkEnableOption "Network latency optimization" // {default = true;};
          qos = mkEnableOption "Quality of Service for gaming traffic";
          tcp-optimization = mkEnableOption "TCP optimization for gaming";
          buffer-tuning = mkEnableOption "Network buffer tuning";
        };
      };

      security = {
        enable = mkEnableOption "Gaming security considerations" // {default = true;};

        anti-cheat = {
          battleye = mkEnableOption "BattlEye anti-cheat support";
          eac = mkEnableOption "Easy Anti-Cheat support";
          vac = mkEnableOption "Valve Anti-Cheat compatibility";
          kernel-modules = mkEnableOption "Anti-cheat kernel module support";
        };

        privacy = {
          telemetry-blocking = mkEnableOption "Block game telemetry";
          dns-filtering = mkEnableOption "DNS-based ad/tracker blocking";
          firewall-rules = mkEnableOption "Gaming-specific firewall rules";
        };

        sandboxing = {
          wine-prefix = mkEnableOption "Sandboxed Wine prefixes";
          flatpak-games = mkEnableOption "Sandboxed Flatpak games";
          bubblewrap = mkEnableOption "Bubblewrap sandboxing";
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
        # Base advanced gaming configuration
        (lib.mkIf cfg.enable {
          # Essential gaming packages
          environment.systemPackages = with pkgs; [
            # Gaming utilities
            gamemode
            mangohud
            goverlay
            steamtinkerlaunch

            # Performance monitoring
            nvtop
            radeontop
            iotop
            nethogs

            # System utilities
            htop
            btop
            stress-ng
            sysbench
          ];

          # Gaming groups
          users.extraGroups = {
            gamemode = {gid = 1001;};
            plugdev = {gid = 1002;};
            input = {gid = 1003;};
          };

          # udev rules for gaming devices
          services.udev.extraRules = ''
            # Gaming controllers base rules
            KERNEL=="hidraw*", ATTRS{idVendor}=="045e", MODE="0666", GROUP="input"
            KERNEL=="hidraw*", ATTRS{idVendor}=="054c", MODE="0666", GROUP="input"
            KERNEL=="hidraw*", ATTRS{idVendor}=="057e", MODE="0666", GROUP="input"

            # Steam Deck
            SUBSYSTEM=="usb", ATTRS{idVendor}=="28de", MODE="0666", GROUP="plugdev"

            # Generic gaming devices
            SUBSYSTEM=="input", GROUP="input", MODE="0664"
            KERNEL=="uinput", MODE="0660", GROUP="input", OPTIONS+="static_node=uinput"
          '';
        })

        # VR Configuration
        (lib.mkIf cfg.vr.enable {
          environment.systemPackages = with pkgs;
            [
              # OpenXR runtime
              monado
              openxr-loader

              # VR utilities
              index_camera_passthrough
              lighthouse_console

              # Development tools
              openxr-developer-tools
            ]
            ++ lib.optionals cfg.vr.runtimes.steamvr [
              # SteamVR support (through Steam)
              steam
            ];

          # VR services
          services.monado = lib.mkIf cfg.vr.runtimes.monado {
            enable = true;
            defaultRuntime = true;
          };

          # VR udev rules
          services.udev.extraRules = ''
            # Oculus/Meta devices
            SUBSYSTEM=="usb", ATTRS{idVendor}=="2833", MODE="0666", GROUP="plugdev"
            SUBSYSTEM=="usb", ATTRS{idVendor}=="0bb4", MODE="0666", GROUP="plugdev"

            # HTC Vive
            SUBSYSTEM=="usb", ATTRS{idVendor}=="0bb4", ATTRS{idProduct}=="2c87", MODE="0666", GROUP="plugdev"
            SUBSYSTEM=="usb", ATTRS{idVendor}=="28de", MODE="0666", GROUP="plugdev"

            # Valve Index
            SUBSYSTEM=="usb", ATTRS{idVendor}=="28de", ATTRS{idProduct}=="2000", MODE="0666", GROUP="plugdev"
            SUBSYSTEM=="usb", ATTRS{idVendor}=="28de", ATTRS{idProduct}=="2012", MODE="0666", GROUP="plugdev"
            SUBSYSTEM=="usb", ATTRS{idVendor}=="28de", ATTRS{idProduct}=="2050", MODE="0666", GROUP="plugdev"
            SUBSYSTEM=="usb", ATTRS{idVendor}=="28de", ATTRS{idProduct}=="2051", MODE="0666", GROUP="plugdev"

            # Pico devices
            SUBSYSTEM=="usb", ATTRS{idVendor}=="2d40", MODE="0666", GROUP="plugdev"

            # Varjo devices
            SUBSYSTEM=="usb", ATTRS{idVendor}=="0525", ATTRS{idProduct}=="a4a2", MODE="0666", GROUP="plugdev"
          '';

          # VR system optimizations
          boot.kernel.sysctl = lib.mkIf cfg.vr.optimization.low-latency {
            "kernel.sched_rt_runtime_us" = -1; # Allow real-time scheduling
            "vm.swappiness" = 1; # Minimize swapping for VR
          };

          # VR environment variables
          environment.variables = {
            XR_RUNTIME_JSON = lib.mkIf cfg.vr.runtimes.monado "/run/openxr/1/openxr_monado.json";
            STEAMVR_LH_ENABLE = lib.mkIf cfg.vr.tracking.lighthouse "1";
          };
        })

        # RGB and Peripheral Control
        (lib.mkIf cfg.rgb.enable {
          environment.systemPackages = with pkgs;
            [
              # RGB control software
              openrgb

              # Brand-specific tools
              ckb-next # Corsair
              piper # Logitech gaming mice

              # RGB effects
              liquidctl # All-in-one liquid coolers and RGB
            ]
            ++ lib.optionals cfg.rgb.software.razergenie [
              razergenie
            ]
            ++ lib.optionals cfg.rgb.software.asus-rog [
              asusctl
              supergfxctl
            ];

          # RGB services
          services.hardware.openrgb = lib.mkIf cfg.rgb.software.openrgb {
            enable = true;
            motherboard = "amd"; # Adjust based on actual hardware
          };

          # udev rules for RGB devices
          services.udev.extraRules = ''
            # OpenRGB devices
            SUBSYSTEM=="usb", ATTRS{idVendor}=="1b1c", MODE="0666", GROUP="plugdev"
            SUBSYSTEM=="usb", ATTRS{idVendor}=="1038", MODE="0666", GROUP="plugdev"
            SUBSYSTEM=="usb", ATTRS{idVendor}=="0c45", MODE="0666", GROUP="plugdev"

            # Corsair devices
            SUBSYSTEM=="usb", ATTRS{idVendor}=="1b1c", MODE="0666", GROUP="plugdev"

            # Razer devices
            SUBSYSTEM=="usb", ATTRS{idVendor}=="1532", MODE="0666", GROUP="plugdev"

            # Logitech devices
            SUBSYSTEM=="usb", ATTRS{idVendor}=="046d", MODE="0666", GROUP="plugdev"

            # ASUS devices
            SUBSYSTEM=="usb", ATTRS{idVendor}=="0b05", MODE="0666", GROUP="plugdev"

            # MSI devices
            SUBSYSTEM=="usb", ATTRS{idVendor}=="1462", MODE="0666", GROUP="plugdev"

            # SteelSeries devices
            SUBSYSTEM=="usb", ATTRS{idVendor}=="1038", MODE="0666", GROUP="plugdev"
          '';

          # RGB systemd services
          systemd.services.rgb-startup = {
            description = "Apply RGB lighting on startup";
            wantedBy = ["multi-user.target"];
            after = ["graphical-session.target"];

            serviceConfig = {
              Type = "oneshot";
              ExecStart = pkgs.writeScript "rgb-startup" ''
                #!/bin/bash
                # Wait for devices to be ready
                sleep 5

                # Apply RGB settings if OpenRGB is available
                if command -v openrgb >/dev/null 2>&1; then
                  openrgb --list-devices
                  # Apply default profile
                  openrgb --profile default.orp 2>/dev/null || true
                fi
              '';
            };
          };
        })

        # Advanced Controller Support
        (lib.mkIf cfg.controllers.enable {
          environment.systemPackages = with pkgs; [
            # Controller tools
            ds4drv # DualShock 4
            dualsensectl # DualSense
            xboxdrv # Xbox controllers
            antimicrox # Controller to keyboard/mouse mapping

            # Calibration tools
            jstest-gtk
            evtest

            # Steam controller
            steam-controller-udev-rules
          ];

          # Controller services
          services.joycond.enable = cfg.controllers.nintendo.joycons;

          # Xbox controller support
          boot.extraModulePackages = lib.mkIf cfg.controllers.xbox.wireless [
            config.boot.kernelPackages.xpadneo
          ];

          # Controller udev rules
          services.udev.extraRules = ''
            # Xbox controllers
            SUBSYSTEM=="usb", ATTRS{idVendor}=="045e", ATTRS{idProduct}=="028e", MODE="0666", GROUP="input"
            SUBSYSTEM=="usb", ATTRS{idVendor}=="045e", ATTRS{idProduct}=="02d1", MODE="0666", GROUP="input"
            SUBSYSTEM=="usb", ATTRS{idVendor}=="045e", ATTRS{idProduct}=="02dd", MODE="0666", GROUP="input"
            SUBSYSTEM=="usb", ATTRS{idVendor}=="045e", ATTRS{idProduct}=="0b12", MODE="0666", GROUP="input"

            # PlayStation controllers
            SUBSYSTEM=="usb", ATTRS{idVendor}=="054c", ATTRS{idProduct}=="05c4", MODE="0666", GROUP="input"
            SUBSYSTEM=="usb", ATTRS{idVendor}=="054c", ATTRS{idProduct}=="09cc", MODE="0666", GROUP="input"
            SUBSYSTEM=="usb", ATTRS{idVendor}=="054c", ATTRS{idProduct}=="0ce6", MODE="0666", GROUP="input"

            # Nintendo controllers
            SUBSYSTEM=="usb", ATTRS{idVendor}=="057e", ATTRS{idProduct}=="2009", MODE="0666", GROUP="input"
            SUBSYSTEM=="usb", ATTRS{idVendor}=="057e", ATTRS{idProduct}=="2017", MODE="0666", GROUP="input"
            SUBSYSTEM=="usb", ATTRS{idVendor}=="057e", ATTRS{idProduct}=="2006", MODE="0666", GROUP="input"

            # Racing wheels (Logitech)
            SUBSYSTEM=="usb", ATTRS{idVendor}=="046d", ATTRS{idProduct}=="c262", MODE="0666", GROUP="input"
            SUBSYSTEM=="usb", ATTRS{idVendor}=="046d", ATTRS{idProduct}=="c29b", MODE="0666", GROUP="input"
            SUBSYSTEM=="usb", ATTRS{idVendor}=="046d", ATTRS{idProduct}=="c24f", MODE="0666", GROUP="input"

            # Flight sticks (Thrustmaster, Logitech)
            SUBSYSTEM=="usb", ATTRS{idVendor}=="044f", MODE="0666", GROUP="input"
            SUBSYSTEM=="usb", ATTRS{idVendor}=="046d", ATTRS{idProduct}=="c215", MODE="0666", GROUP="input"

            # Arcade sticks
            SUBSYSTEM=="usb", ATTRS{idVendor}=="0f0d", MODE="0666", GROUP="input"
            SUBSYSTEM=="usb", ATTRS{idVendor}=="1532", ATTRS{idProduct}=="0a00", MODE="0666", GROUP="input"
          '';

          # Enable controller features
          boot.kernelModules = lib.mkIf cfg.controllers.features.rumble ["ff-memless"];
        })

        # Gaming Audio Optimizations
        (lib.mkIf cfg.audio.enable {
          # Low-latency audio configuration
          services.pipewire = lib.mkIf cfg.audio.low-latency.enable {
            extraConfig.pipewire = {
              "context.properties" = {
                "default.clock.rate" = cfg.audio.low-latency.sample-rate;
                "default.clock.quantum" = cfg.audio.low-latency.buffer-size;
                "default.clock.min-quantum" = cfg.audio.low-latency.buffer-size / 2;
                "default.clock.max-quantum" = cfg.audio.low-latency.buffer-size * 4;

                # Gaming audio optimizations
                "settings.check-quantum" = true;
                "settings.check-rate" = true;
              };
            };

            # Real-time scheduling for audio
            extraConfig.pipewire-pulse = {
              "pulse.properties" = {
                "pulse.min.req" = "${toString cfg.audio.low-latency.buffer-size}/48000";
                "pulse.default.req" = "${toString cfg.audio.low-latency.buffer-size}/48000";
                "pulse.max.req" = "${toString (cfg.audio.low-latency.buffer-size * 4)}/48000";
                "pulse.min.quantum" = "${toString cfg.audio.low-latency.buffer-size}/48000";
                "pulse.max.quantum" = "${toString (cfg.audio.low-latency.buffer-size * 4)}/48000";
              };
            };
          };

          # Audio packages
          environment.systemPackages = with pkgs;
            [
              # Audio control
              pavucontrol
              pwvucontrol
              qpwgraph

              # Audio effects
              easyeffects
              pulseeffects-legacy

              # Voice chat
              mumble
              teamspeak_client

              # Audio monitoring
              carla
            ]
            ++ lib.optionals cfg.audio.spatial.enable [
              # Spatial audio
              openal
              freealut
            ]
            ++ lib.optionals cfg.audio.enhancement.noise-suppression [
              # Noise suppression
              noisetorch
              rnnoise
            ];

          # Real-time audio scheduling
          security.rtkit.enable = true;

          # Audio group memberships
          users.users =
            lib.mapAttrs
            (
              name: user:
                if user.isNormalUser
                then {
                  extraGroups = user.extraGroups or [] ++ ["audio" "jackaudio"];
                }
                else {}
            )
            config.users.users;
        })

        # Game Streaming and Recording
        (lib.mkIf cfg.streaming.enable {
          environment.systemPackages = with pkgs;
            [
              # Streaming software
              obs-studio

              # Game streaming
              sunshine
              moonlight-qt
              parsec-bin

              # Recording utilities
              simplescreenrecorder
              peek # GIF recorder

              # Stream deck
              streamdeck-ui
            ]
            ++ lib.optionals cfg.streaming.broadcast.streamlabs [
              streamlabs-obs
            ];

          # OBS Studio plugins
          programs.obs-studio = lib.mkIf cfg.streaming.broadcast.obs {
            enable = true;
            plugins = with pkgs.obs-studio-plugins; [
              wlrobs # Wayland capture
              obs-vkcapture # Vulkan/OpenGL capture
              obs-gstreamer # GStreamer integration
              obs-pipewire-audio-capture
              looking-glass-obs # Looking Glass capture
              obs-vaapi # Hardware encoding
            ];
          };

          # Streaming services
          services.sunshine = lib.mkIf cfg.streaming.local.sunshine {
            enable = true;
            openFirewall = true;
            capSysAdmin = true;
          };

          # Firewall rules for streaming
          networking.firewall = {
            allowedTCPPorts = [
              # Sunshine
              47989
              47990
              48010
              # Steam Link
              27036
              27037
              # Parsec
              8000
              8001
            ];
            allowedUDPPorts = [
              # Sunshine
              47998
              47999
              48000
              48002
              # Steam Link
              27031
              27036
              # Parsec
              8000
              8001
            ];
          };
        })

        # Game Launchers and Stores
        (lib.mkIf cfg.launchers.enable {
          environment.systemPackages = with pkgs;
            [
              # Native launchers
              steam
              lutris
              heroic
              bottles

              # Store clients
              legendary-gl # Epic Games
              minigalaxy # GOG

              # Game management
              gamemode
              gamescope
              steamtinkerlaunch

              # Web browsers for cloud gaming
              firefox
              chromium
            ]
            ++ lib.optionals cfg.launchers.stores.itch [
              itch
            ];

          # Steam configuration
          programs.steam = lib.mkIf cfg.launchers.native.steam {
            enable = true;
            remotePlay.openFirewall = true;
            dedicatedServer.openFirewall = true;

            # Proton configuration
            package = pkgs.steam.override {
              extraPkgs = pkgs:
                with pkgs; [
                  xorg.libXcursor
                  xorg.libXi
                  xorg.libXinerama
                  xorg.libXScrnSaver
                  libpng
                  libpulseaudio
                  libvorbis
                  stdenv.cc.cc.lib
                  libkrb5
                  keyutils
                ];
            };
          };

          # Lutris configuration
          environment.sessionVariables = lib.mkIf cfg.launchers.native.lutris {
            LUTRIS_SKIP_INIT = "1"; # Skip initialization for faster startup
          };
        })

        # System Optimizations
        (lib.mkIf cfg.optimization.enable {
          # CPU optimizations
          powerManagement.cpuFreqGovernor = cfg.optimization.cpu.governor;

          # Memory optimizations
          boot.kernel.sysctl = {
            # Gaming memory settings
            "vm.swappiness" = cfg.optimization.storage.swappiness;
            "vm.vfs_cache_pressure" = 50;
            "vm.dirty_ratio" = 15;
            "vm.dirty_background_ratio" = 5;

            # Network gaming optimizations
            "net.core.rmem_default" = lib.mkIf cfg.optimization.network.latency 262144;
            "net.core.rmem_max" = lib.mkIf cfg.optimization.network.latency 16777216;
            "net.core.wmem_default" = lib.mkIf cfg.optimization.network.latency 262144;
            "net.core.wmem_max" = lib.mkIf cfg.optimization.network.latency 16777216;
            "net.ipv4.tcp_rmem" = lib.mkIf cfg.optimization.network.latency "4096 87380 16777216";
            "net.ipv4.tcp_wmem" = lib.mkIf cfg.optimization.network.latency "4096 65536 16777216";
            "net.core.netdev_max_backlog" = lib.mkIf cfg.optimization.network.latency 5000;
            "net.ipv4.tcp_congestion_control" = lib.mkIf cfg.optimization.network.tcp-optimization "bbr";

            # Gaming-specific
            "vm.max_map_count" = 2147483642; # For some games
            "kernel.sched_rt_runtime_us" = lib.mkIf cfg.optimization.cpu.realtime (-1);
          };

          # I/O scheduler optimization
          services.udev.extraRules = ''
            # Set I/O scheduler for SSDs
            ACTION=="add|change", KERNEL=="sd[a-z]*", ATTR{queue/rotational}=="0", ATTR{queue/scheduler}="${cfg.optimization.storage.scheduler}"
            ACTION=="add|change", KERNEL=="nvme[0-9]*n[0-9]*", ATTR{queue/scheduler}="${cfg.optimization.storage.scheduler}"

            # Set read-ahead for gaming storage
            ACTION=="add|change", KERNEL=="sd[a-z]*", ATTR{bdi/read_ahead_kb}="${toString cfg.optimization.storage.readahead}"
            ACTION=="add|change", KERNEL=="nvme[0-9]*n[0-9]*", ATTR{bdi/read_ahead_kb}="${toString cfg.optimization.storage.readahead}"
          '';

          # Huge pages configuration
          boot.kernelParams = lib.mkIf cfg.optimization.memory.huge-pages [
            "transparent_hugepage=madvise"
            "hugepagesz=2M"
            "hugepages=1024"
          ];

          # ZRAM configuration
          zramSwap = lib.mkIf cfg.optimization.memory.zram {
            enable = true;
            algorithm = "zstd";
            memoryPercent = 25;
          };
        })

        # Gaming Security
        (lib.mkIf cfg.security.enable {
          # Firewall rules for gaming
          networking.firewall = lib.mkIf cfg.security.privacy.firewall-rules {
            allowedTCPPorts = [
              # Steam
              27015
              27036
              27037
              # Discord
              50000
              # TeamSpeak
              9987
            ];
            allowedUDPPorts = [
              # Steam
              27015
              27031
              27036
              # Discord voice
              50000
              # Game-specific ports
              3478
              19302
              19303
              19309
            ];

            # Game-specific rules
            extraCommands = ''
              # Allow Steam Remote Play
              iptables -A INPUT -p udp --dport 27031:27036 -j ACCEPT
              iptables -A INPUT -p tcp --dport 27014:27050 -j ACCEPT

              # Allow Discord voice chat
              iptables -A INPUT -p udp --dport 50000:65535 -s 162.159.128.0/24 -j ACCEPT

              # Gaming traffic prioritization
              iptables -t mangle -A OUTPUT -p udp --dport 27015 -j DSCP --set-dscp 46
              iptables -t mangle -A OUTPUT -p tcp --dport 27015 -j DSCP --set-dscp 46
            '';
          };

          # Anti-cheat support
          boot.kernelModules = lib.mkIf cfg.security.anti-cheat.kernel-modules [
            # BattlEye support
            "uinput"
          ];

          # DNS filtering for privacy
          services.resolved = lib.mkIf cfg.security.privacy.dns-filtering {
            enable = true;
            domains = ["~."];
            fallbackDns = [
              "1.1.1.2" # Cloudflare for Families
              "1.0.0.2"
              "208.67.222.123" # OpenDNS FamilyShield
            ];
          };
        })
      ];

    # Dependencies
    dependencies = ["core" "hardware" "audio"];
  }
