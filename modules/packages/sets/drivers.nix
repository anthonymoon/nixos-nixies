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
    name = "packages-drivers";
    description = "Graphics drivers and hardware acceleration packages for optimal performance";
    category = "packages";
    options = with lib; {
      enable = mkEnableOption "drivers package set";
      graphics = {
        amdgpu = {
          enable = mkEnableOption "AMD GPU drivers and support";
          mesa = mkEnableOption "Mesa AMD drivers" // {default = true;};
          rocm = mkEnableOption "ROCm compute platform";
          vulkan = mkEnableOption "AMD Vulkan drivers" // {default = true;};
        };
        nvidia = {
          enable = mkEnableOption "NVIDIA GPU drivers";
          version = mkOption {
            type = types.enum ["stable" "beta" "latest"];
            default = "stable";
            description = "NVIDIA driver version";
          };
          vulkan = mkEnableOption "NVIDIA Vulkan support" // {default = true;};
          cuda = mkEnableOption "CUDA support";
          nvenc = mkEnableOption "NVENC hardware encoding";
          optimus = mkEnableOption "Optimus laptop support";
        };
        intel = {
          enable = mkEnableOption "Intel integrated graphics drivers" // {default = true;};
          vulkan = mkEnableOption "Intel Vulkan drivers" // {default = true;};
          media-driver = mkEnableOption "Intel media driver for hardware acceleration" // {default = true;};
          compute = mkEnableOption "Intel compute runtime";
        };
      };
      acceleration = {
        vulkan = {
          enable = mkEnableOption "Vulkan graphics API support" // {default = true;};
          tools = mkEnableOption "Vulkan development and debugging tools";
          validation = mkEnableOption "Vulkan validation layers";
        };
        vaapi = {
          enable = mkEnableOption "VA-API hardware video acceleration" // {default = true;};
          intel = mkEnableOption "Intel VA-API drivers";
          amd = mkEnableOption "AMD VA-API drivers";
        };
        libva = {
          enable = mkEnableOption "libva video acceleration library" // {default = true;};
          utils = mkEnableOption "libva utilities and tools";
        };
        av1 = {
          enable = mkEnableOption "AV1 codec hardware acceleration";
          intel = mkEnableOption "Intel AV1 acceleration";
          amd = mkEnableOption "AMD AV1 acceleration";
          nvidia = mkEnableOption "NVIDIA AV1 acceleration";
        };
      };
      compatibility = {
        dxvk = {
          enable = mkEnableOption "DXVK DirectX to Vulkan translation" // {default = true;};
          version = mkOption {
            type = types.enum ["stable" "git" "async"];
            default = "stable";
            description = "DXVK version preference";
          };
        };
        vkd3d = mkEnableOption "VKD3D Direct3D 12 to Vulkan translation";
        d9vk = mkEnableOption "D9VK Direct3D 9 to Vulkan translation";
        gallium-nine = mkEnableOption "Gallium Nine Direct3D 9 state tracker";
      };
      optimization = {
        mesa-optimizations = mkEnableOption "Mesa performance optimizations";
        gpu-scheduling = mkEnableOption "GPU-based scheduling optimizations";
        memory-management = mkEnableOption "GPU memory management optimizations";
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
            (lib.optionals cfg.graphics.amdgpu.enable [
              mesa.drivers
              amdvlk
            ])
            (lib.optionals cfg.graphics.amdgpu.rocm [
              rocm-opencl-icd
              rocm-opencl-runtime
              rocminfo
              rocm-smi
            ])
            (lib.optionals cfg.graphics.intel.enable [
              mesa.drivers
            ])
            (lib.optionals cfg.graphics.intel.media-driver [
              intel-media-driver
              intel-gpu-tools
            ])
            (lib.optionals cfg.graphics.intel.compute [
              intel-compute-runtime
              level-zero
            ])
            (lib.optionals cfg.acceleration.vulkan.enable [
              vulkan-loader
              vulkan-headers
            ])
            (lib.optionals cfg.acceleration.vulkan.tools [
              vulkan-tools
              vulkan-caps-viewer
              gfxreconstruct
            ])
            (lib.optionals cfg.acceleration.vulkan.validation [
              vulkan-validation-layers
              vulkan-extension-layer
            ])
            (lib.optionals cfg.acceleration.vaapi.intel [
              vaapiIntel
            ])
            (lib.optionals cfg.acceleration.vaapi.amd [
              mesa.drivers
            ])
            (lib.optionals cfg.acceleration.libva.enable [
              libva
            ])
            (lib.optionals cfg.acceleration.libva.utils [
              libva-utils
            ])
            (lib.optionals cfg.compatibility.dxvk.enable [
              (
                if cfg.compatibility.dxvk.version == "git"
                then dxvk
                else if cfg.compatibility.dxvk.version == "async"
                then dxvk-async
                else dxvk
              )
            ])
            (lib.optionals cfg.compatibility.vkd3d [
              vkd3d
            ])
            (lib.optionals cfg.acceleration.av1.enable [
              libaom
              libdav1d
              libavif
            ])
          ];
        hardware = {
          opengl = {
            enable = true;
            driSupport = true;
            driSupport32Bit = true;
            extraPackages = with pkgs;
              lib.flatten [
                (lib.optionals cfg.graphics.amdgpu.enable [
                  mesa.drivers
                  amdvlk
                ])
                (lib.optionals cfg.graphics.intel.enable [
                  intel-media-driver
                  vaapiIntel
                  intel-compute-runtime
                ])
                (lib.optionals cfg.acceleration.vulkan.enable [
                  vulkan-loader
                  vulkan-validation-layers
                ])
                (lib.optionals cfg.acceleration.vaapi.enable [
                  vaapiVdpau
                  libvdpau-va-gl
                ])
              ];
            extraPackages32 = with pkgs.pkgsi686Linux;
              lib.flatten [
                (lib.optionals cfg.graphics.amdgpu.enable [
                  amdvlk
                ])
                (lib.optionals cfg.graphics.intel.enable [
                  vaapiIntel
                ])
              ];
          };
          nvidia = lib.mkIf cfg.graphics.nvidia.enable {
            package =
              if cfg.graphics.nvidia.version == "beta"
              then config.boot.kernelPackages.nvidiaPackages.beta
              else if cfg.graphics.nvidia.version == "latest"
              then config.boot.kernelPackages.nvidiaPackages.latest
              else config.boot.kernelPackages.nvidiaPackages.stable;
            modesetting.enable = true;
            open = false;
            nvidiaSettings = true;
            prime = lib.mkIf cfg.graphics.nvidia.optimus {
              offload.enable = true;
              offload.enableOffloadCmd = true;
            };
            powerManagement.enable = true;
            powerManagement.finegrained = cfg.graphics.nvidia.optimus;
          };
        };
        services = lib.mkMerge [
          (lib.mkIf cfg.graphics.amdgpu.enable {
            xserver.videoDrivers = ["amdgpu"];
          })
          (lib.mkIf cfg.graphics.nvidia.enable {
            xserver.videoDrivers = ["nvidia"];
          })
          (lib.mkIf cfg.graphics.intel.enable {
            xserver.videoDrivers = lib.mkDefault ["modesetting"];
          })
        ];
        environment.variables = lib.mkMerge [
          (lib.mkIf cfg.acceleration.vaapi.enable {
            LIBVA_DRIVER_NAME =
              if cfg.graphics.intel.enable
              then "iHD"
              else if cfg.graphics.amdgpu.enable
              then "radeonsi"
              else "auto";
            VDPAU_DRIVER = "va_gl";
          })
          (lib.mkIf cfg.acceleration.vulkan.enable {
            VK_LAYER_PATH = "${pkgs.vulkan-validation-layers}/share/vulkan/explicit_layer.d";
          })
          (lib.mkIf cfg.optimization.mesa-optimizations {
            MESA_LOADER_DRIVER_OVERRIDE =
              if cfg.graphics.amdgpu.enable
              then "radeonsi"
              else if cfg.graphics.intel.enable
              then "iris"
              else "auto";
            MESA_GLSL_CACHE_DISABLE = "false";
            MESA_GLSL_CACHE_MAX_SIZE = "1GB";
          })
          (lib.mkIf cfg.graphics.nvidia.enable {
            __GL_SHADER_DISK_CACHE = "1";
            __GL_SHADER_DISK_CACHE_PATH = "/tmp/gl-shader-cache";
            CUDA_CACHE_PATH = lib.mkIf cfg.graphics.nvidia.cuda "/tmp/cuda-cache";
          })
          (lib.mkIf cfg.graphics.amdgpu.enable {
            AMD_VULKAN_ICD = "RADV";
            RADV_PERFTEST = "gpl";
          })
        ];
        boot = {
          kernelModules = lib.flatten [
            (lib.optionals cfg.graphics.amdgpu.enable [
              "amdgpu"
            ])
            (lib.optionals cfg.graphics.intel.enable [
              "i915"
            ])
          ];
          kernelParams = lib.flatten [
            (lib.optionals cfg.graphics.amdgpu.enable [
              "amdgpu.si_support=1"
              "amdgpu.cik_support=1"
              "radeon.si_support=0"
              "radeon.cik_support=0"
            ])
            (lib.optionals cfg.graphics.intel.enable [
              "i915.enable_guc=2"
              "i915.enable_fbc=1"
            ])
            (lib.optionals cfg.graphics.nvidia.enable [
              "nvidia-drm.modeset=1"
            ])
          ];
          initrd.kernelModules = lib.flatten [
            (lib.optionals cfg.graphics.amdgpu.enable ["amdgpu"])
            (lib.optionals cfg.graphics.intel.enable ["i915"])
            (lib.optionals cfg.graphics.nvidia.enable ["nvidia" "nvidia_modeset" "nvidia_uvm" "nvidia_drm"])
          ];
        };
        systemd.tmpfiles.rules = lib.flatten [
          (lib.optionals cfg.optimization.mesa-optimizations [
            "d /tmp/mesa-shader-cache 1777 root root 30d"
          ])
          (lib.optionals cfg.graphics.nvidia.enable [
            "d /tmp/gl-shader-cache 1777 root root 30d"
            "d /tmp/cuda-cache 1777 root root 30d"
          ])
        ];
        security.polkit.extraConfig = ''
          polkit.addRule(function(action, subject) {
          if (action.id == "org.freedesktop.color-manager.create-device" ||
          action.id == "org.freedesktop.color-manager.modify-profile" ||
          action.id == "org.freedesktop.color-manager.delete-profile") {
          return polkit.Result.YES;
          }
          });
        '';
      };
    dependencies = ["core" "hardware"];
  }) {
    inherit config lib pkgs inputs;
  }
