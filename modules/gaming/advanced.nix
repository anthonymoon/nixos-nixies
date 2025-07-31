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
        (lib.mkIf cfg.enable {
          environment.systemPackages = with pkgs; [
            gamemode
            mangohud
            goverlay
            steamtinkerlaunch
            nvtop
            radeontop
            iotop
            nethogs
            htop
            btop
            stress-ng
            sysbench
          ];
          users.extraGroups = {
            gamemode = {gid = 1001;};
            plugdev = {gid = 1002;};
            input = {gid = 1003;};
          };
          services.udev.extraRules = ''
            KERNEL=="hidraw*", ATTRS{idVendor}=="045e", MODE="0666", GROUP="input"
            KERNEL=="hidraw*", ATTRS{idVendor}=="054c", MODE="0666", GROUP="input"
            KERNEL=="hidraw*", ATTRS{idVendor}=="057e", MODE="0666", GROUP="input"
            SUBSYSTEM=="usb", ATTRS{idVendor}=="28de", MODE="0666", GROUP="plugdev"
            SUBSYSTEM=="input", GROUP="input", MODE="0664"
            KERNEL=="uinput", MODE="0660", GROUP="input", OPTIONS+="static_node=uinput"
          '';
        })
        (lib.mkIf cfg.vr.enable {
          environment.systemPackages = with pkgs;
            [
              monado
              openxr-loader
              index_camera_passthrough
              lighthouse_console
              openxr-developer-tools
            ]
            ++ lib.optionals cfg.vr.runtimes.steamvr [
              steam
            ];
          services.monado = lib.mkIf cfg.vr.runtimes.monado {
            enable = true;
            defaultRuntime = true;
          };
          services.udev.extraRules = ''
            SUBSYSTEM=="usb", ATTRS{idVendor}=="2833", MODE="0666", GROUP="plugdev"
            SUBSYSTEM=="usb", ATTRS{idVendor}=="0bb4", MODE="0666", GROUP="plugdev"
            SUBSYSTEM=="usb", ATTRS{idVendor}=="0bb4", ATTRS{idProduct}=="2c87", MODE="0666", GROUP="plugdev"
            SUBSYSTEM=="usb", ATTRS{idVendor}=="28de", MODE="0666", GROUP="plugdev"
            SUBSYSTEM=="usb", ATTRS{idVendor}=="28de", ATTRS{idProduct}=="2000", MODE="0666", GROUP="plugdev"
            SUBSYSTEM=="usb", ATTRS{idVendor}=="28de", ATTRS{idProduct}=="2012", MODE="0666", GROUP="plugdev"
            SUBSYSTEM=="usb", ATTRS{idVendor}=="28de", ATTRS{idProduct}=="2050", MODE="0666", GROUP="plugdev"
            SUBSYSTEM=="usb", ATTRS{idVendor}=="28de", ATTRS{idProduct}=="2051", MODE="0666", GROUP="plugdev"
            SUBSYSTEM=="usb", ATTRS{idVendor}=="2d40", MODE="0666", GROUP="plugdev"
            SUBSYSTEM=="usb", ATTRS{idVendor}=="0525", ATTRS{idProduct}=="a4a2", MODE="0666", GROUP="plugdev"
          '';
          boot.kernel.sysctl = lib.mkIf cfg.vr.optimization.low-latency {
            "kernel.sched_rt_runtime_us" = -1;
            "vm.swappiness" = 1;
          };
          environment.variables = {
            XR_RUNTIME_JSON = lib.mkIf cfg.vr.runtimes.monado "/run/openxr/1/openxr_monado.json";
            STEAMVR_LH_ENABLE = lib.mkIf cfg.vr.tracking.lighthouse "1";
          };
        })
        (lib.mkIf cfg.rgb.enable {
          environment.systemPackages = with pkgs;
            [
              openrgb
              ckb-next
              piper
              liquidctl
            ]
            ++ lib.optionals cfg.rgb.software.razergenie [
              razergenie
            ]
            ++ lib.optionals cfg.rgb.software.asus-rog [
              asusctl
              supergfxctl
            ];
          services.hardware.openrgb = lib.mkIf cfg.rgb.software.openrgb {
            enable = true;
            motherboard = "amd";
          };
          services.udev.extraRules = ''
            SUBSYSTEM=="usb", ATTRS{idVendor}=="1b1c", MODE="0666", GROUP="plugdev"
            SUBSYSTEM=="usb", ATTRS{idVendor}=="1038", MODE="0666", GROUP="plugdev"
            SUBSYSTEM=="usb", ATTRS{idVendor}=="0c45", MODE="0666", GROUP="plugdev"
            SUBSYSTEM=="usb", ATTRS{idVendor}=="1b1c", MODE="0666", GROUP="plugdev"
            SUBSYSTEM=="usb", ATTRS{idVendor}=="1532", MODE="0666", GROUP="plugdev"
            SUBSYSTEM=="usb", ATTRS{idVendor}=="046d", MODE="0666", GROUP="plugdev"
            SUBSYSTEM=="usb", ATTRS{idVendor}=="0b05", MODE="0666", GROUP="plugdev"
            SUBSYSTEM=="usb", ATTRS{idVendor}=="1462", MODE="0666", GROUP="plugdev"
            SUBSYSTEM=="usb", ATTRS{idVendor}=="1038", MODE="0666", GROUP="plugdev"
          '';
          systemd.services.rgb-startup = {
            description = "Apply RGB lighting on startup";
            wantedBy = ["multi-user.target"];
            after = ["graphical-session.target"];
            serviceConfig = {
              Type = "oneshot";
              ExecStart = pkgs.writeScript "rgb-startup" ''
                #!/bin/bash
                sleep 5
                if command -v openrgb >/dev/null 2>&1; then
                openrgb --list-devices
                openrgb --profile default.orp 2>/dev/null || true
                fi
              '';
            };
          };
        })
        (lib.mkIf cfg.controllers.enable {
          environment.systemPackages = with pkgs; [
            ds4drv
            dualsensectl
            xboxdrv
            antimicrox
            jstest-gtk
            evtest
            steam-controller-udev-rules
          ];
          services.joycond.enable = cfg.controllers.nintendo.joycons;
          boot.extraModulePackages = lib.mkIf cfg.controllers.xbox.wireless [
            config.boot.kernelPackages.xpadneo
          ];
          services.udev.extraRules = ''
            SUBSYSTEM=="usb", ATTRS{idVendor}=="045e", ATTRS{idProduct}=="028e", MODE="0666", GROUP="input"
            SUBSYSTEM=="usb", ATTRS{idVendor}=="045e", ATTRS{idProduct}=="02d1", MODE="0666", GROUP="input"
            SUBSYSTEM=="usb", ATTRS{idVendor}=="045e", ATTRS{idProduct}=="02dd", MODE="0666", GROUP="input"
            SUBSYSTEM=="usb", ATTRS{idVendor}=="045e", ATTRS{idProduct}=="0b12", MODE="0666", GROUP="input"
            SUBSYSTEM=="usb", ATTRS{idVendor}=="054c", ATTRS{idProduct}=="05c4", MODE="0666", GROUP="input"
            SUBSYSTEM=="usb", ATTRS{idVendor}=="054c", ATTRS{idProduct}=="09cc", MODE="0666", GROUP="input"
            SUBSYSTEM=="usb", ATTRS{idVendor}=="054c", ATTRS{idProduct}=="0ce6", MODE="0666", GROUP="input"
            SUBSYSTEM=="usb", ATTRS{idVendor}=="057e", ATTRS{idProduct}=="2009", MODE="0666", GROUP="input"
            SUBSYSTEM=="usb", ATTRS{idVendor}=="057e", ATTRS{idProduct}=="2017", MODE="0666", GROUP="input"
            SUBSYSTEM=="usb", ATTRS{idVendor}=="057e", ATTRS{idProduct}=="2006", MODE="0666", GROUP="input"
            SUBSYSTEM=="usb", ATTRS{idVendor}=="046d", ATTRS{idProduct}=="c262", MODE="0666", GROUP="input"
            SUBSYSTEM=="usb", ATTRS{idVendor}=="046d", ATTRS{idProduct}=="c29b", MODE="0666", GROUP="input"
            SUBSYSTEM=="usb", ATTRS{idVendor}=="046d", ATTRS{idProduct}=="c24f", MODE="0666", GROUP="input"
            SUBSYSTEM=="usb", ATTRS{idVendor}=="044f", MODE="0666", GROUP="input"
            SUBSYSTEM=="usb", ATTRS{idVendor}=="046d", ATTRS{idProduct}=="c215", MODE="0666", GROUP="input"
            SUBSYSTEM=="usb", ATTRS{idVendor}=="0f0d", MODE="0666", GROUP="input"
            SUBSYSTEM=="usb", ATTRS{idVendor}=="1532", ATTRS{idProduct}=="0a00", MODE="0666", GROUP="input"
          '';
          boot.kernelModules = lib.mkIf cfg.controllers.features.rumble ["ff-memless"];
        })
        (lib.mkIf cfg.audio.enable {
          services.pipewire = lib.mkIf cfg.audio.low-latency.enable {
            extraConfig.pipewire = {
              "context.properties" = {
                "default.clock.rate" = cfg.audio.low-latency.sample-rate;
                "default.clock.quantum" = cfg.audio.low-latency.buffer-size;
                "default.clock.min-quantum" = cfg.audio.low-latency.buffer-size / 2;
                "default.clock.max-quantum" = cfg.audio.low-latency.buffer-size * 4;
                "settings.check-quantum" = true;
                "settings.check-rate" = true;
              };
            };
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
          environment.systemPackages = with pkgs;
            [
              pavucontrol
              pwvucontrol
              qpwgraph
              easyeffects
              pulseeffects-legacy
              mumble
              teamspeak_client
              carla
            ]
            ++ lib.optionals cfg.audio.spatial.enable [
              openal
              freealut
            ]
            ++ lib.optionals cfg.audio.enhancement.noise-suppression [
              noisetorch
              rnnoise
            ];
          security.rtkit.enable = true;
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
        (lib.mkIf cfg.streaming.enable {
          environment.systemPackages = with pkgs;
            [
              obs-studio
              sunshine
              moonlight-qt
              parsec-bin
              simplescreenrecorder
              peek
              streamdeck-ui
            ]
            ++ lib.optionals cfg.streaming.broadcast.streamlabs [
              streamlabs-obs
            ];
          programs.obs-studio = lib.mkIf cfg.streaming.broadcast.obs {
            enable = true;
            plugins = with pkgs.obs-studio-plugins; [
              wlrobs
              obs-vkcapture
              obs-gstreamer
              obs-pipewire-audio-capture
              looking-glass-obs
              obs-vaapi
            ];
          };
          services.sunshine = lib.mkIf cfg.streaming.local.sunshine {
            enable = true;
            openFirewall = true;
            capSysAdmin = true;
          };
          networking.firewall = {
            allowedTCPPorts = [
              47989
              47990
              48010
              27036
              27037
              8000
              8001
            ];
            allowedUDPPorts = [
              47998
              47999
              48000
              48002
              27031
              27036
              8000
              8001
            ];
          };
        })
        (lib.mkIf cfg.launchers.enable {
          environment.systemPackages = with pkgs;
            [
              steam
              lutris
              heroic
              bottles
              legendary-gl
              minigalaxy
              gamemode
              gamescope
              steamtinkerlaunch
              firefox
              chromium
            ]
            ++ lib.optionals cfg.launchers.stores.itch [
              itch
            ];
          programs.steam = lib.mkIf cfg.launchers.native.steam {
            enable = true;
            remotePlay.openFirewall = true;
            dedicatedServer.openFirewall = true;
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
          environment.sessionVariables = lib.mkIf cfg.launchers.native.lutris {
            LUTRIS_SKIP_INIT = "1";
          };
        })
        (lib.mkIf cfg.optimization.enable {
          powerManagement.cpuFreqGovernor = cfg.optimization.cpu.governor;
          boot.kernel.sysctl = {
            "vm.swappiness" = cfg.optimization.storage.swappiness;
            "vm.vfs_cache_pressure" = 50;
            "vm.dirty_ratio" = 15;
            "vm.dirty_background_ratio" = 5;
            "net.core.rmem_default" = lib.mkIf cfg.optimization.network.latency 262144;
            "net.core.rmem_max" = lib.mkIf cfg.optimization.network.latency 16777216;
            "net.core.wmem_default" = lib.mkIf cfg.optimization.network.latency 262144;
            "net.core.wmem_max" = lib.mkIf cfg.optimization.network.latency 16777216;
            "net.ipv4.tcp_rmem" = lib.mkIf cfg.optimization.network.latency "4096 87380 16777216";
            "net.ipv4.tcp_wmem" = lib.mkIf cfg.optimization.network.latency "4096 65536 16777216";
            "net.core.netdev_max_backlog" = lib.mkIf cfg.optimization.network.latency 5000;
            "net.ipv4.tcp_congestion_control" = lib.mkIf cfg.optimization.network.tcp-optimization "bbr";
            "vm.max_map_count" = 2147483642;
            "kernel.sched_rt_runtime_us" = lib.mkIf cfg.optimization.cpu.realtime (-1);
          };
          services.udev.extraRules = ''
            ACTION=="add|change", KERNEL=="sd[a-z]*", ATTR{queue/rotational}=="0", ATTR{queue/scheduler}="${cfg.optimization.storage.scheduler}"
            ACTION=="add|change", KERNEL=="nvme[0-9]*n[0-9]*", ATTR{queue/scheduler}="${cfg.optimization.storage.scheduler}"
            ACTION=="add|change", KERNEL=="sd[a-z]*", ATTR{bdi/read_ahead_kb}="${toString cfg.optimization.storage.readahead}"
            ACTION=="add|change", KERNEL=="nvme[0-9]*n[0-9]*", ATTR{bdi/read_ahead_kb}="${toString cfg.optimization.storage.readahead}"
          '';
          boot.kernelParams = lib.mkIf cfg.optimization.memory.huge-pages [
            "transparent_hugepage=madvise"
            "hugepagesz=2M"
            "hugepages=1024"
          ];
          zramSwap = lib.mkIf cfg.optimization.memory.zram {
            enable = true;
            algorithm = "zstd";
            memoryPercent = 25;
          };
        })
        (lib.mkIf cfg.security.enable {
          networking.firewall = lib.mkIf cfg.security.privacy.firewall-rules {
            allowedTCPPorts = [
              27015
              27036
              27037
              50000
              9987
            ];
            allowedUDPPorts = [
              27015
              27031
              27036
              50000
              3478
              19302
              19303
              19309
            ];
            extraCommands = ''
              iptables -A INPUT -p udp --dport 27031:27036 -j ACCEPT
              iptables -A INPUT -p tcp --dport 27014:27050 -j ACCEPT
              iptables -A INPUT -p udp --dport 50000:65535 -s 162.159.128.0/24 -j ACCEPT
              iptables -t mangle -A OUTPUT -p udp --dport 27015 -j DSCP --set-dscp 46
              iptables -t mangle -A OUTPUT -p tcp --dport 27015 -j DSCP --set-dscp 46
            '';
          };
          boot.kernelModules = lib.mkIf cfg.security.anti-cheat.kernel-modules [
            "uinput"
          ];
          services.resolved = lib.mkIf cfg.security.privacy.dns-filtering {
            enable = true;
            domains = ["~."];
            fallbackDns = [
              "1.1.1.2"
              "1.0.0.2"
              "208.67.222.123"
            ];
          };
        })
      ];
    dependencies = ["core" "hardware" "audio"];
  }) {
    inherit config lib pkgs inputs;
  }
