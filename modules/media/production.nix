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
    name = "media-production";
    description = "Comprehensive media production suite for video, audio, graphics, and content creation";
    category = "media";
    options = with lib; {
      enable = mkEnableOption "media production capabilities";
      video = {
        enable = mkEnableOption "video production and editing" // {default = true;};
        editing = {
          professional = mkEnableOption "professional video editing suites";
          free = mkEnableOption "free and open-source video editors" // {default = true;};
          web = mkEnableOption "web-based video editing tools";
        };
        software = {
          davinci-resolve = mkEnableOption "DaVinci Resolve professional editor";
          kdenlive = mkEnableOption "KDEnlive non-linear editor" // {default = true;};
          blender = mkEnableOption "Blender for 3D and video editing" // {default = true;};
          openshot = mkEnableOption "OpenShot simple video editor";
          shotcut = mkEnableOption "Shotcut cross-platform editor";
          flowblade = mkEnableOption "Flowblade video editor";
          olive = mkEnableOption "Olive professional video editor";
          pitivi = mkEnableOption "Pitivi video editor";
        };
        encoding = {
          hardware = mkEnableOption "hardware-accelerated encoding" // {default = true;};
          codecs = {
            h264 = mkEnableOption "H.264/AVC codec support" // {default = true;};
            h265 = mkEnableOption "H.265/HEVC codec support" // {default = true;};
            av1 = mkEnableOption "AV1 codec support";
            vp9 = mkEnableOption "VP9 codec support" // {default = true;};
            prores = mkEnableOption "Apple ProRes codec support";
          };
          quality = mkOption {
            type = types.enum ["fast" "balanced" "quality" "lossless"];
            default = "balanced";
            description = "Default encoding quality preset";
          };
        };
        formats = {
          professional = mkEnableOption "professional video formats (ProRes, DNxHD, etc.)";
          consumer = mkEnableOption "consumer video formats (MP4, AVI, etc.)" // {default = true;};
          streaming = mkEnableOption "streaming formats optimization" // {default = true;};
          archive = mkEnableOption "archival formats (FFV1, etc.)";
        };
        effects = {
          color-grading = mkEnableOption "advanced color grading tools";
          motion-graphics = mkEnableOption "motion graphics and compositing";
          visual-effects = mkEnableOption "visual effects processing";
          transitions = mkEnableOption "transition effects library";
        };
      };
      audio = {
        enable = mkEnableOption "audio production and editing" // {default = true;};
        production = {
          professional = mkEnableOption "professional audio production suites";
          podcast = mkEnableOption "podcast production tools" // {default = true;};
          music = mkEnableOption "music production and composition";
          voice = mkEnableOption "voice recording and processing" // {default = true;};
        };
        software = {
          reaper = mkEnableOption "REAPER digital audio workstation";
          ardour = mkEnableOption "Ardour professional DAW" // {default = true;};
          audacity = mkEnableOption "Audacity audio editor" // {default = true;};
          tenacity = mkEnableOption "Tenacity (Audacity fork)";
          lmms = mkEnableOption "LMMS music production";
          rosegarden = mkEnableOption "Rosegarden music composition";
          qtractor = mkEnableOption "Qtractor audio/MIDI sequencer";
          zrythm = mkEnableOption "Zrythm digital audio workstation";
          bitwig = mkEnableOption "Bitwig Studio";
        };
        plugins = {
          ladspa = mkEnableOption "LADSPA audio plugins" // {default = true;};
          lv2 = mkEnableOption "LV2 audio plugins" // {default = true;};
          vst = mkEnableOption "VST plugin support";
          vst3 = mkEnableOption "VST3 plugin support";
          clap = mkEnableOption "CLAP plugin support";
        };
        synthesis = {
          synthesizers = mkEnableOption "software synthesizers";
          samplers = mkEnableOption "audio samplers";
          drum-machines = mkEnableOption "drum machine software";
          virtual-instruments = mkEnableOption "virtual instrument libraries";
        };
        processing = {
          realtime = mkEnableOption "real-time audio processing" // {default = true;};
          noise-reduction = mkEnableOption "noise reduction and cleanup";
          mastering = mkEnableOption "audio mastering tools";
          restoration = mkEnableOption "audio restoration tools";
        };
        formats = {
          lossless = mkEnableOption "lossless audio formats (FLAC, WAV)" // {default = true;};
          compressed = mkEnableOption "compressed audio formats (MP3, OGG)" // {default = true;};
          professional = mkEnableOption "professional audio formats (BWF, AIFF)";
          surround = mkEnableOption "surround sound format support";
        };
      };
      graphics = {
        enable = mkEnableOption "graphics design and digital art" // {default = true;};
        design = {
          raster = mkEnableOption "raster graphics editing" // {default = true;};
          vector = mkEnableOption "vector graphics design" // {default = true;};
          digital-painting = mkEnableOption "digital painting and illustration";
          photo-editing = mkEnableOption "photo editing and manipulation" // {default = true;};
          ui-design = mkEnableOption "UI/UX design tools";
        };
        software = {
          gimp = mkEnableOption "GIMP raster graphics editor" // {default = true;};
          krita = mkEnableOption "Krita digital painting application" // {default = true;};
          inkscape = mkEnableOption "Inkscape vector graphics editor" // {default = true;};
          blender = mkEnableOption "Blender 3D graphics suite" // {default = true;};
          darktable = mkEnableOption "darktable photo workflow" // {default = true;};
          rawtherapee = mkEnableOption "RawTherapee raw processor";
          digikam = mkEnableOption "digiKam photo management";
          luminance-hdr = mkEnableOption "Luminance HDR imaging";
          hugin = mkEnableOption "Hugin panorama stitcher";
          scribus = mkEnableOption "Scribus desktop publishing";
        };
        formats = {
          raw = mkEnableOption "camera RAW format support" // {default = true;};
          professional = mkEnableOption "professional graphics formats (PSD, AI, etc.)";
          web = mkEnableOption "web graphics optimization" // {default = true;};
          print = mkEnableOption "print-ready format support";
        };
        color = {
          management = mkEnableOption "color management system" // {default = true;};
          calibration = mkEnableOption "monitor calibration tools";
          profiles = mkEnableOption "professional color profiles";
          wide-gamut = mkEnableOption "wide color gamut support";
        };
      };
      modeling = {
        enable = mkEnableOption "3D modeling and animation";
        software = {
          blender = mkEnableOption "Blender 3D creation suite" // {default = true;};
          freecad = mkEnableOption "FreeCAD parametric 3D modeler";
          openscad = mkEnableOption "OpenSCAD programmable 3D modeler";
          meshlab = mkEnableOption "MeshLab 3D mesh processing";
          wings3d = mkEnableOption "Wings 3D subdivision modeler";
          art-of-illusion = mkEnableOption "Art of Illusion 3D studio";
        };
        features = {
          sculpting = mkEnableOption "3D sculpting capabilities";
          animation = mkEnableOption "3D animation tools" // {default = true;};
          rigging = mkEnableOption "character rigging tools";
          simulation = mkEnableOption "physics simulation";
          rendering = mkEnableOption "3D rendering engines" // {default = true;};
        };
        formats = {
          interchange = mkEnableOption "3D format interchange (OBJ, FBX, etc.)" // {default = true;};
          cad = mkEnableOption "CAD format support";
          game-engines = mkEnableOption "game engine format support";
          printing = mkEnableOption "3D printing format support";
        };
      };
      streaming = {
        enable = mkEnableOption "live streaming and content creation";
        software = {
          obs = mkEnableOption "OBS Studio streaming software" // {default = true;};
          streamlabs = mkEnableOption "Streamlabs OBS";
          xsplit = mkEnableOption "XSplit broadcasting software";
          wirecast = mkEnableOption "Wirecast live streaming";
        };
        platforms = {
          twitch = mkEnableOption "Twitch streaming optimization";
          youtube = mkEnableOption "YouTube streaming optimization";
          facebook = mkEnableOption "Facebook Live streaming";
          linkedin = mkEnableOption "LinkedIn Live streaming";
          custom-rtmp = mkEnableOption "Custom RTMP server support";
        };
        features = {
          multi-camera = mkEnableOption "multi-camera streaming setup";
          green-screen = mkEnableOption "chroma key (green screen) support";
          screen-capture = mkEnableOption "screen capture optimization";
          audio-mixing = mkEnableOption "live audio mixing" // {default = true;};
          overlays = mkEnableOption "streaming overlays and graphics";
          chatbots = mkEnableOption "streaming chatbot integration";
        };
        hardware = {
          capture-cards = mkEnableOption "capture card support";
          webcams = mkEnableOption "webcam optimization" // {default = true;};
          microphones = mkEnableOption "professional microphone support" // {default = true;};
          lighting = mkEnableOption "lighting control integration";
        };
      };
      collaboration = {
        enable = mkEnableOption "collaborative content creation tools";
        version-control = {
          git-lfs = mkEnableOption "Git LFS for large media files" // {default = true;};
          perforce = mkEnableOption "Perforce version control";
          subversion = mkEnableOption "Subversion version control";
        };
        cloud = {
          sync = mkEnableOption "cloud storage synchronization";
          backup = mkEnableOption "automated cloud backup";
          sharing = mkEnableOption "cloud-based file sharing";
        };
        review = {
          annotation = mkEnableOption "media annotation and review tools";
          approval = mkEnableOption "approval workflow systems";
          feedback = mkEnableOption "feedback and comment systems";
        };
      };
      optimization = {
        enable = mkEnableOption "media production optimizations" // {default = true;};
        storage = {
          fast-storage = mkEnableOption "fast storage optimization for media files";
          cache-drives = mkEnableOption "dedicated cache drive configuration";
          network-storage = mkEnableOption "network-attached storage optimization";
          raid = mkEnableOption "RAID configuration for media production";
        };
        memory = {
          large-files = mkEnableOption "large file handling optimization";
          preview-cache = mkEnableOption "preview cache optimization";
          undo-history = mkEnableOption "extensive undo history support";
        };
        gpu = {
          acceleration = mkEnableOption "GPU acceleration for media tasks" // {default = true;};
          compute = mkEnableOption "GPU compute for effects processing";
          multiple-gpu = mkEnableOption "multi-GPU rendering support";
          ai-acceleration = mkEnableOption "AI-accelerated media processing";
        };
        networking = {
          high-bandwidth = mkEnableOption "high-bandwidth network optimization";
          low-latency = mkEnableOption "low-latency streaming optimization";
          cdn = mkEnableOption "CDN integration for content delivery";
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
            ffmpeg-full
            mediainfo
            exiftool
            libheif
            libavif
            htop
            iotop
            tree
            rsync
          ];
          users.extraGroups = {
            media = {gid = 2001;};
            audio = {gid = 2002;};
            video = {gid = 2003;};
          };
          services.udisks2.enable = true;
          fonts.packages = with pkgs; [
            liberation_ttf
            dejavu_fonts
            source-sans-pro
            source-serif-pro
            source-code-pro
            inter
            roboto
            open-sans
            lato
            font-awesome
            material-icons
          ];
        })
        (lib.mkIf cfg.video.enable {
          environment.systemPackages = with pkgs;
            [
              (lib.mkIf cfg.video.software.kdenlive kdenlive)
              (lib.mkIf cfg.video.software.blender blender)
              (lib.mkIf cfg.video.software.openshot openshot-qt)
              (lib.mkIf cfg.video.software.shotcut shotcut)
              (lib.mkIf cfg.video.software.flowblade flowblade)
              (lib.mkIf cfg.video.software.pitivi pitivi)
              handbrake
              mkvtoolnix
              dvdauthor
              x264
              x265
              libvpx
              libaom
              intel-media-driver
              vaapiIntel
              libva-utils
              mediainfo-gui
              videomass
            ]
            ++ lib.optionals cfg.video.software.davinci-resolve [
              davinci-resolve
            ]
            ++ lib.optionals cfg.video.encoding.codecs.prores [
            ];
          hardware.graphics = {
            extraPackages = with pkgs; [
              intel-media-driver
              vaapiIntel
              vaapiVdpau
              libvdpau-va-gl
              intel-compute-runtime
            ];
          };
          nixpkgs.config.packageOverrides = pkgs: {
            ffmpeg = pkgs.ffmpeg-full.override {
              withVaapi = cfg.video.encoding.hardware;
              withVdpau = cfg.video.encoding.hardware;
              withNvenc = cfg.video.encoding.hardware;
            };
          };
          environment.variables = {
            LIBVA_DRIVER_NAME = lib.mkIf cfg.video.encoding.hardware "iHD";
            VDPAU_DRIVER = lib.mkIf cfg.video.encoding.hardware "va_gl";
          };
        })
        (lib.mkIf cfg.audio.enable {
          environment.systemPackages = with pkgs;
            [
              (lib.mkIf cfg.audio.software.ardour ardour)
              (lib.mkIf cfg.audio.software.audacity audacity)
              (lib.mkIf cfg.audio.software.lmms lmms)
              (lib.mkIf cfg.audio.software.rosegarden rosegarden)
              (lib.mkIf cfg.audio.software.qtractor qtractor)
              sox
              lame
              flac
              opus-tools
              vorbis-tools
              audacity
              spectacle-audio-analyzer
              qjackctl
              jack2
              carla
              alsa-utils
              pulseaudio-ctl
              pavucontrol
            ]
            ++ lib.optionals cfg.audio.software.reaper [
              reaper
            ]
            ++ lib.optionals cfg.audio.software.bitwig [
              bitwig-studio
            ]
            ++ lib.optionals cfg.audio.plugins.ladspa [
              ladspaPlugins
              caps
              swh_lv2
            ]
            ++ lib.optionals cfg.audio.plugins.lv2 [
              calf
              dragonfly-reverb
              guitarix
              gxplugins-lv2
              ir.lv2
              lsp-plugins
              mod-distortion
              x42-plugins
            ];
          services.pipewire = lib.mkIf cfg.audio.processing.realtime {
            extraConfig.pipewire = {
              "context.properties" = {
                "default.clock.rate" = 48000;
                "default.clock.quantum" = 256;
                "default.clock.min-quantum" = 64;
                "default.clock.max-quantum" = 2048;
              };
            };
            jack.enable = true;
          };
          services.jack = lib.mkIf cfg.audio.processing.realtime {
            jackd.enable = true;
            alsa.enable = true;
            loopback = {
              enable = true;
              dmixConfig = ''
                pcm.amix {
                type dmix
                ipc_key 12345
                slave {
                pcm "hw:0,0"
                period_time 0
                period_size 256
                buffer_time 0
                buffer_size 2048
                rate 48000
                }
                bindings {
                0 0
                1 1
                }
                }
              '';
            };
          };
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
        (lib.mkIf cfg.graphics.enable {
          environment.systemPackages = with pkgs; [
            (lib.mkIf cfg.graphics.software.gimp gimp-with-plugins)
            (lib.mkIf cfg.graphics.software.krita krita)
            (lib.mkIf cfg.graphics.software.inkscape inkscape-with-extensions)
            (lib.mkIf cfg.graphics.software.blender blender)
            (lib.mkIf cfg.graphics.software.darktable darktable)
            (lib.mkIf cfg.graphics.software.rawtherapee rawtherapee)
            (lib.mkIf cfg.graphics.software.digikam digikam)
            (lib.mkIf cfg.graphics.software.luminance-hdr luminance-hdr)
            (lib.mkIf cfg.graphics.software.hugin hugin)
            (lib.mkIf cfg.graphics.software.scribus scribus)
            imagemagick
            graphicsmagick
            optipng
            jpegoptim
            pngcrush
            argyllcms
            displaycal
            fontforge
            fonttools
            potrace
            autotrace
            shotwell
            gwenview
            nomacs
          ];
          services.colord.enable = cfg.graphics.color.management;
          hardware.graphics = {
            enable = true;
            driSupport = true;
            driSupport32Bit = true;
            extraPackages = with pkgs; [
              intel-media-driver
              vaapiIntel
              intel-compute-runtime
              amdvlk
              rocm-opencl-icd
              opencl-headers
              opencl-info
              clinfo
            ];
          };
          environment.variables = {
            OPENCL_VENDOR_PATH = "${pkgs.ocl-icd}/etc/OpenCL/vendors";
            COLOR_PROFILE_DIR = lib.mkIf cfg.graphics.color.management "/run/current-system/sw/share/color/icc";
          };
        })
        (lib.mkIf cfg.modeling.enable {
          environment.systemPackages = with pkgs; [
            (lib.mkIf cfg.modeling.software.blender blender)
            (lib.mkIf cfg.modeling.software.freecad freecad)
            (lib.mkIf cfg.modeling.software.openscad openscad)
            (lib.mkIf cfg.modeling.software.meshlab meshlab)
            (lib.mkIf cfg.modeling.software.wings3d wings3d)
            meshlab
            cloudcompare
            cura
            prusa-slicer
            openscad
            librecad
            qcad
            assimp
            povray
            yafaray
          ];
          hardware.graphics = {
            extraPackages = with pkgs; [
              opencl-headers
              ocl-icd
            ];
          };
          environment.variables = {
            BLENDER_USER_CONFIG = "$HOME/.config/blender";
            BLENDER_USER_SCRIPTS = "$HOME/.config/blender/scripts";
            __GL_SHADER_DISK_CACHE = "1";
            __GL_SHADER_DISK_CACHE_PATH = "/tmp/gl-shader-cache";
          };
        })
        (lib.mkIf cfg.streaming.enable {
          environment.systemPackages = with pkgs; [
            (lib.mkIf cfg.streaming.software.obs obs-studio)
            ffmpeg-full
            rtmp-dump
            chatty
            streamlink
            youtube-dl
            yt-dlp
          ];
          programs.obs-studio = lib.mkIf cfg.streaming.software.obs {
            enable = true;
            plugins = with pkgs.obs-studio-plugins; [
              wlrobs
              obs-vkcapture
              obs-gstreamer
              obs-pipewire-audio-capture
              looking-glass-obs
              obs-vaapi
              obs-nvfbc
              droidcam-obs
            ];
          };
          boot.kernel.sysctl = {
            "net.core.rmem_max" = 134217728;
            "net.core.wmem_max" = 134217728;
            "net.ipv4.tcp_rmem" = "4096 87380 134217728";
            "net.ipv4.tcp_wmem" = "4096 65536 134217728";
            "net.core.netdev_max_backlog" = 30000;
          };
          networking.firewall = {
            allowedTCPPorts = [
              1935
              8080
              8554
            ];
            allowedUDPPorts = [
              1935
              5004
              5005
            ];
          };
          boot.extraModulePackages = with config.boot.kernelPackages; [
            v4l2loopback
          ];
          boot.kernelModules = ["v4l2loopback"];
        })
        (lib.mkIf cfg.collaboration.enable {
          environment.systemPackages = with pkgs;
            [
              git
              git-lfs
              nextcloud-client
              dropbox
              syncthing
              rsync
              restic
              borgbackup
              discord
              slack
              zoom-us
              teams-for-linux
            ]
            ++ lib.optionals cfg.collaboration.version-control.perforce [
              perforce
            ]
            ++ lib.optionals cfg.collaboration.version-control.subversion [
              subversion
            ];
          programs.git = lib.mkIf cfg.collaboration.version-control.git-lfs {
            enable = true;
            lfs.enable = true;
          };
          services.syncthing = lib.mkIf cfg.collaboration.cloud.sync {
            enable = true;
            user = "media-user";
            dataDir = "/home/media-user/Sync";
            configDir = "/home/media-user/.config/syncthing";
          };
        })
        (lib.mkIf cfg.optimization.enable {
          fileSystems = lib.mkIf cfg.optimization.storage.fast-storage {
            "/media" = {
              options = ["noatime" "nodiratime" "discard"];
            };
          };
          boot.kernel.sysctl = {
            "vm.dirty_ratio" = lib.mkIf cfg.optimization.memory.large-files 20;
            "vm.dirty_background_ratio" = lib.mkIf cfg.optimization.memory.large-files 10;
            "vm.vfs_cache_pressure" = lib.mkIf cfg.optimization.memory.preview-cache 50;
            "net.core.rmem_max" = lib.mkIf cfg.optimization.networking.high-bandwidth 134217728;
            "net.core.wmem_max" = lib.mkIf cfg.optimization.networking.high-bandwidth 134217728;
          };
          hardware.opengl = lib.mkIf cfg.optimization.gpu.acceleration {
            extraPackages = with pkgs; [
              opencl-headers
              ocl-icd
              rocm-opencl-icd
              rocm-opencl-runtime
            ];
          };
          services.udev.extraRules = ''
            ACTION=="add|change", KERNEL=="sd[a-z]*", ATTR{queue/rotational}=="0", ATTR{queue/scheduler}="deadline"
            ACTION=="add|change", KERNEL=="nvme[0-9]*n[0-9]*", ATTR{queue/scheduler}="none"
            ACTION=="add|change", KERNEL=="sd[a-z]*", ATTR{bdi/read_ahead_kb}="8192"
            ACTION=="add|change", KERNEL=="nvme[0-9]*n[0-9]*", ATTR{bdi/read_ahead_kb}="8192"
          '';
        })
      ];
    dependencies = ["core" "hardware" "audio"];
  }) {
    inherit config lib pkgs inputs;
  }
