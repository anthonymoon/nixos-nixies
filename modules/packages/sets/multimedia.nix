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
    name = "packages-multimedia";
    description = "Multimedia production and playback packages for audio, video, and content creation";
    category = "packages";
    options = with lib; {
      enable = mkEnableOption "multimedia package set";
      audio = {
        enable = mkEnableOption "audio packages" // {default = true;};
        playback = {
          mpv = mkEnableOption "MPV media player" // {default = true;};
          vlc = mkEnableOption "VLC media player";
          audacious = mkEnableOption "Audacious audio player";
          rhythmbox = mkEnableOption "Rhythmbox music player";
        };
        production = {
          enable = mkEnableOption "audio production tools";
          ardour = mkEnableOption "Ardour digital audio workstation";
          reaper = mkEnableOption "REAPER DAW";
          audacity = mkEnableOption "Audacity audio editor" // {default = true;};
          lmms = mkEnableOption "LMMS music production";
        };
        system = {
          pulseaudio = mkEnableOption "PulseAudio sound server";
          pipewire = mkEnableOption "PipeWire modern audio system" // {default = true;};
          jack = mkEnableOption "JACK professional audio server";
          alsa = mkEnableOption "ALSA low-level audio" // {default = true;};
        };
        enhancement = {
          rnnoise = mkEnableOption "RNNoise real-time noise suppression" // {default = true;};
          noise-torch = mkEnableOption "NoiseTorch noise suppression GUI";
          easyeffects = mkEnableOption "EasyEffects audio effects";
          jamesdsp = mkEnableOption "JamesDSP audio effects";
        };
        visualization = {
          cava = mkEnableOption "Cava audio visualizer" // {default = true;};
          spectrum-analyzer = mkEnableOption "spectrum analyzer tools";
          projectm = mkEnableOption "ProjectM music visualizer";
        };
      };
      video = {
        enable = mkEnableOption "video packages" // {default = true;};
        playback = {
          mpv = mkEnableOption "MPV video player" // {default = true;};
          vlc = mkEnableOption "VLC media player";
          celluloid = mkEnableOption "Celluloid MPV frontend";
          totem = mkEnableOption "GNOME Videos (Totem)";
        };
        encoding = {
          ffmpeg = mkEnableOption "FFmpeg multimedia framework" // {default = true;};
          handbrake = mkEnableOption "HandBrake video transcoder";
          x264 = mkEnableOption "x264 H.264 encoder";
          x265 = mkEnableOption "x265 H.265/HEVC encoder";
          av1 = mkEnableOption "AV1 codec support";
        };
        editing = {
          enable = mkEnableOption "video editing tools";
          kdenlive = mkEnableOption "Kdenlive video editor";
          davinci-resolve = mkEnableOption "DaVinci Resolve";
          blender = mkEnableOption "Blender 3D and video editing";
          openshot = mkEnableOption "OpenShot video editor";
        };
        streaming = {
          obs = mkEnableOption "OBS Studio streaming/recording";
          ffmpeg-streaming = mkEnableOption "FFmpeg streaming support";
          rtmp-tools = mkEnableOption "RTMP streaming tools";
        };
      };
      graphics = {
        enable = mkEnableOption "graphics and image editing packages";
        raster = {
          gimp = mkEnableOption "GIMP image editor";
          krita = mkEnableOption "Krita digital painting";
          inkscape = mkEnableOption "Inkscape vector graphics";
          darktable = mkEnableOption "Darktable photo workflow";
        };
        photography = {
          rawtherapee = mkEnableOption "RawTherapee RAW processor";
          digikam = mkEnableOption "digiKam photo management";
          luminance-hdr = mkEnableOption "Luminance HDR";
          hugin = mkEnableOption "Hugin panorama stitcher";
        };
        utilities = {
          imagemagick = mkEnableOption "ImageMagick image manipulation" // {default = true;};
          graphicsmagick = mkEnableOption "GraphicsMagick image processing";
          exiftool = mkEnableOption "ExifTool metadata editor";
          optipng = mkEnableOption "OptiPNG PNG optimizer";
        };
      };
      codecs = {
        enable = mkEnableOption "multimedia codecs and format support" // {default = true;};
        audio-codecs = {
          flac = mkEnableOption "FLAC lossless audio codec" // {default = true;};
          mp3 = mkEnableOption "MP3 audio codec" // {default = true;};
          ogg = mkEnableOption "Ogg Vorbis/Opus audio codecs" // {default = true;};
          aac = mkEnableOption "AAC audio codec" // {default = true;};
        };
        video-codecs = {
          h264 = mkEnableOption "H.264/AVC video codec" // {default = true;};
          h265 = mkEnableOption "H.265/HEVC video codec" // {default = true;};
          vp8 = mkEnableOption "VP8 video codec";
          vp9 = mkEnableOption "VP9 video codec" // {default = true;};
          av1 = mkEnableOption "AV1 video codec";
        };
        containers = {
          mkv = mkEnableOption "Matroska container support" // {default = true;};
          mp4 = mkEnableOption "MP4 container support" // {default = true;};
          webm = mkEnableOption "WebM container support" // {default = true;};
          avi = mkEnableOption "AVI container support";
        };
      };
      hardware-acceleration = {
        enable = mkEnableOption "hardware-accelerated multimedia processing" // {default = true;};
        vaapi = mkEnableOption "VA-API hardware acceleration" // {default = true;};
        vdpau = mkEnableOption "VDPAU hardware acceleration";
        nvenc = mkEnableOption "NVIDIA NVENC hardware encoding";
        qsv = mkEnableOption "Intel Quick Sync Video";
        amf = mkEnableOption "AMD AMF hardware encoding";
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
            (lib.optionals cfg.audio.playback.mpv [
              mpv
            ])
            (lib.optionals cfg.audio.playback.vlc [
              vlc
            ])
            (lib.optionals cfg.audio.production.audacity [
              audacity
            ])
            (lib.optionals cfg.audio.production.ardour [
              ardour
            ])
            (lib.optionals cfg.audio.production.lmms [
              lmms
            ])
            (lib.optionals cfg.audio.enhancement.rnnoise [
              rnnoise
              rnnoise-plugin
            ])
            (lib.optionals cfg.audio.enhancement.noise-torch [
              noisetorch
            ])
            (lib.optionals cfg.audio.enhancement.easyeffects [
              easyeffects
            ])
            (lib.optionals cfg.audio.visualization.cava [
              cava
            ])
            (lib.optionals cfg.audio.visualization.projectm [
              projectm
            ])
            (lib.optionals cfg.video.playback.mpv [
              mpv
            ])
            (lib.optionals cfg.video.playback.celluloid [
              celluloid
            ])
            (lib.optionals cfg.video.encoding.ffmpeg [
              ffmpeg-full
            ])
            (lib.optionals cfg.video.encoding.handbrake [
              handbrake
            ])
            (lib.optionals cfg.video.encoding.x264 [
              x264
            ])
            (lib.optionals cfg.video.encoding.x265 [
              x265
            ])
            (lib.optionals cfg.video.editing.kdenlive [
              kdenlive
            ])
            (lib.optionals cfg.video.editing.blender [
              blender
            ])
            (lib.optionals cfg.video.editing.openshot [
              openshot-qt
            ])
            (lib.optionals cfg.video.streaming.obs [
              obs-studio
              obs-studio-plugins.wlrobs
              obs-studio-plugins.obs-vkcapture
            ])
            (lib.optionals cfg.graphics.raster.gimp [
              gimp-with-plugins
            ])
            (lib.optionals cfg.graphics.raster.krita [
              krita
            ])
            (lib.optionals cfg.graphics.raster.inkscape [
              inkscape-with-extensions
            ])
            (lib.optionals cfg.graphics.raster.darktable [
              darktable
            ])
            (lib.optionals cfg.graphics.photography.rawtherapee [
              rawtherapee
            ])
            (lib.optionals cfg.graphics.photography.digikam [
              digikam
            ])
            (lib.optionals cfg.graphics.utilities.imagemagick [
              imagemagick
            ])
            (lib.optionals cfg.graphics.utilities.exiftool [
              exiftool
            ])
            (lib.optionals cfg.codecs.enable [
              gst_all_1.gstreamer
              gst_all_1.gst-plugins-base
              gst_all_1.gst-plugins-good
              gst_all_1.gst-plugins-bad
              gst_all_1.gst-plugins-ugly
              gst_all_1.gst-libav
              gst_all_1.gst-vaapi
            ])
            (lib.optionals cfg.codecs.audio-codecs.flac [
              flac
            ])
            (lib.optionals cfg.codecs.audio-codecs.mp3 [
              lame
            ])
            (lib.optionals cfg.codecs.audio-codecs.ogg [
              vorbis-tools
              opus-tools
            ])
            (lib.optionals cfg.codecs.video-codecs.h264 [
              x264
            ])
            (lib.optionals cfg.codecs.video-codecs.h265 [
              x265
            ])
            (lib.optionals cfg.codecs.video-codecs.vp9 [
              libvpx
            ])
            (lib.optionals cfg.codecs.video-codecs.av1 [
              libaom
              libdav1d
            ])
            (lib.optionals cfg.codecs.containers.mkv [
              mkvtoolnix
            ])
          ];
        services = lib.mkMerge [
          (lib.mkIf cfg.audio.system.pipewire {
            pipewire = {
              enable = true;
              alsa.enable = cfg.audio.system.alsa;
              alsa.support32Bit = true;
              pulse.enable = true;
              jack.enable = cfg.audio.system.jack;
              extraConfig.pipewire = lib.mkIf cfg.audio.production.enable {
                "context.properties" = {
                  "default.clock.rate" = 48000;
                  "default.clock.quantum" = 128;
                  "default.clock.min-quantum" = 32;
                  "default.clock.max-quantum" = 2048;
                };
              };
            };
          })
          (lib.mkIf cfg.audio.system.jack {
            jack = {
              jackd.enable = true;
              alsa.enable = true;
              loopback.enable = true;
            };
          })
        ];
        hardware.graphics = lib.mkIf cfg.hardware-acceleration.enable {
          extraPackages = with pkgs;
            lib.flatten [
              (lib.optionals cfg.hardware-acceleration.vaapi [
                intel-media-driver
                vaapiIntel
                vaapiVdpau
                libvdpau-va-gl
              ])
              (lib.optionals cfg.hardware-acceleration.qsv [
                intel-media-driver
                intel-compute-runtime
              ])
              (lib.optionals cfg.hardware-acceleration.amf [
                rocm-opencl-icd
                rocm-opencl-runtime
              ])
            ];
        };
        environment.variables = lib.mkMerge [
          (lib.mkIf cfg.hardware-acceleration.vaapi {
            LIBVA_DRIVER_NAME = "iHD";
            VDPAU_DRIVER = "va_gl";
          })
          (lib.mkIf cfg.audio.production.enable {
            JACK_DEFAULT_SERVER = "default";
            PIPEWIRE_LATENCY = "128/48000";
          })
          {
            GST_PLUGIN_SYSTEM_PATH_1_0 = lib.makeSearchPathOutput "lib" "lib/gstreamer-1.0" [
              pkgs.gst_all_1.gst-plugins-base
              pkgs.gst_all_1.gst-plugins-good
              pkgs.gst_all_1.gst-plugins-bad
              pkgs.gst_all_1.gst-plugins-ugly
              pkgs.gst_all_1.gst-libav
            ];
          }
        ];
        security.rtkit.enable = lib.mkIf cfg.audio.production.enable true;
        users.extraGroups = lib.mkIf cfg.audio.production.enable {
          audio = {};
          jackaudio = {};
        };
        fonts.packages = with pkgs; [
          liberation_ttf
          dejavu_fonts
          source-sans-pro
        ];
        networking.firewall = lib.mkIf cfg.video.streaming.obs {
          allowedTCPPorts = [1935];
          allowedUDPPorts = [1935];
        };
      };
    dependencies = ["core" "hardware"];
  }) {
    inherit config lib pkgs inputs;
  }
