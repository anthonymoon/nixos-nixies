# Package Sets Demo Configuration
# Demonstrates how to use the modular package sets system
{
  config,
  lib,
  pkgs,
  ...
}: {
  # Import the packages module
  imports = [
    ../modules/packages
  ];

  # Example 1: Enable specific package sets with default packages
  unified.packages = {
    enable = true;

    # Core development tools
    sets.core = {
      enable = true;
      packages = ["git" "vscode-insiders" "zed" "thorium" "neovim" "zsh" "fish"];
    };

    # Desktop environment
    sets.desktop = {
      enable = true;
      packages = ["niri" "hyprland" "plasma6" "greetd" "tuigreet"];
    };

    # Gaming setup
    sets.gaming = {
      enable = true;
      packages = ["steam" "gamemode" "gamescope" "ps5-controller" "xbox-controller"];
    };

    # Multimedia production
    sets.multimedia = {
      enable = true;
      packages = ["mpv" "ffmpeg" "cava" "pulseaudio" "rnnoise" "noise-torch"];
    };

    # Graphics drivers
    sets.drivers = {
      enable = true;
      packages = ["amdgpu" "nvidia" "vulkan" "dxvk" "libva" "av1"];
    };

    # Server applications
    sets.server = {
      enable = true;
      packages = ["docker" "libvirtd" "qbittorrent" "smb" "wsdd" "arr-stack"];
    };

    # Web browsers
    sets.browsers = {
      enable = true;
      packages = ["zen-browser" "tor-browser" "qutebrowser"];
    };

    # Virtualization
    sets.vm = {
      enable = true;
      packages = ["virtio" "kvm-guest"];
    };

    # Package management configuration
    management = {
      auto-resolve = true;
      prefer-bleeding-edge = true;
      include-dependencies = true;
      validate-sets = true;
    };

    # Package resolution strategy
    resolution = {
      strategy = "smart";
      prefer-source = "auto";
      override-conflicts = true;
    };

    # Performance optimizations
    optimization = {
      lazy-loading = true;
      cache-package-info = true;
      parallel-evaluation = true;
    };
  };

  # Example 2: Detailed configuration of individual sets
  unified.packages.sets = {
    # Core development configuration
    core = {
      development = {
        git = {
          enable = true;
          gui-tools = true;
          lfs = true;
        };

        editors = {
          vscode-insiders = true;
          zed = true;
          neovim = true;

          plugins = {
            language-servers = true;
            syntax-highlighting = true;
            auto-completion = true;
          };
        };
      };

      shells = {
        zsh = {
          enable = true;
          oh-my-zsh = true;
          powerlevel10k = true;
          plugins = true;
        };

        fish = {
          enable = true;
          plugins = true;
        };
      };

      utilities = {
        modern-alternatives = true;
        file-management = true;
        network-tools = true;
        system-monitoring = true;
      };
    };

    # Desktop environment configuration
    desktop = {
      window-managers = {
        niri = {
          enable = true;
          features = {
            xwayland = true;
            screensharing = true;
            clipboard = true;
            notifications = true;
          };
        };

        hyprland = {
          enable = true;
          plugins = true;
          animations = true;
          config-tools = true;
        };

        plasma6 = {
          enable = true;
          full-suite = true;
          wayland-session = true;
          customization = true;
        };
      };

      display-managers = {
        greetd = {
          enable = true;
          greeters.tuigreet = true;
        };
      };

      utilities = {
        terminal-emulators = {
          enable = true;
          packages = ["alacritty" "foot"];
        };

        launchers = {
          enable = true;
          packages = ["rofi" "fuzzel"];
        };

        status-bars = {
          enable = true;
          packages = ["waybar"];
        };
      };

      wayland = {
        screen-capture = {
          enable = true;
          packages = ["grim" "slurp" "wl-clipboard"];
        };
      };

      theming = {
        enable = true;
        icon-themes = true;
        gtk-themes = true;
        cursor-themes = true;
      };
    };

    # Gaming configuration
    gaming = {
      platforms = {
        steam = {
          enable = true;
          proton = true;
          remote-play = true;
          vr = true;

          compatibility = {
            enable = true;
            tools = ["proton-ge" "steam-tinker-launch"];
          };
        };

        alternatives = {
          lutris = true;
          heroic = true;
        };
      };

      performance = {
        gamemode.enable = true;
        gamescope = {
          enable = true;
          features = {
            hdr = true;
            vrr = true;
            upscaling = true;
          };
        };

        monitoring = {
          enable = true;
          tools = ["mangohud" "goverlay"];
        };
      };

      controllers = {
        ps5 = {
          enable = true;
          haptics = true;
          wireless = true;
        };

        xbox = {
          enable = true;
          wireless = true;
        };

        generic = {
          steam-input = true;
        };
      };

      streaming = {
        enable = true;
        obs.enable = true;
      };
    };
  };

  # Example 3: System integration
  system.stateVersion = "24.11";

  # The package sets will automatically configure:
  # - Environment variables
  # - Service configurations
  # - Hardware support
  # - User groups
  # - Security policies
  # - Font packages
  # - Networking rules

  # Example 4: User configuration
  users.users.demo-user = {
    isNormalUser = true;
    extraGroups = [
      "wheel"
      "networkmanager"
      "audio"
      "video"
      "docker"
      "libvirtd"
      "gamemode"
    ];
    shell = pkgs.zsh; # Configured by core package set
  };

  # Example 5: Custom overrides
  nixpkgs.config = {
    # The package sets system provides smart defaults
    # but you can still override specific packages
    packageOverrides = pkgs: {
      # Example: Use a different Firefox variant
      firefox = pkgs.firefox-nightly;
    };
  };

  # Example 6: Environment customization
  environment.variables = {
    # Package sets provide sensible defaults
    # Additional variables can be added here
    CUSTOM_VAR = "demo-value";
  };
}
