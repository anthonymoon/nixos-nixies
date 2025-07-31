{
  config,
  lib,
  pkgs,
  ...
}: {
  imports = [
    ../modules/packages
  ];
  nixies.packages = {
    enable = true;
    sets.core = {
      enable = true;
      packages = ["git" "vscode-insiders" "zed" "thorium" "neovim" "zsh" "fish"];
    };
    sets.desktop = {
      enable = true;
      packages = ["niri" "hyprland" "plasma6" "greetd" "tuigreet"];
    };
    sets.gaming = {
      enable = true;
      packages = ["steam" "gamemode" "gamescope" "ps5-controller" "xbox-controller"];
    };
    sets.multimedia = {
      enable = true;
      packages = ["mpv" "ffmpeg" "cava" "pulseaudio" "rnnoise" "noise-torch"];
    };
    sets.drivers = {
      enable = true;
      packages = ["amdgpu" "nvidia" "vulkan" "dxvk" "libva" "av1"];
    };
    sets.server = {
      enable = true;
      packages = ["docker" "libvirtd" "qbittorrent" "smb" "wsdd" "arr-stack"];
    };
    sets.browsers = {
      enable = true;
      packages = ["zen-browser" "tor-browser" "qutebrowser"];
    };
    sets.vm = {
      enable = true;
      packages = ["virtio" "kvm-guest"];
    };
    management = {
      auto-resolve = true;
      prefer-bleeding-edge = true;
      include-dependencies = true;
      validate-sets = true;
    };
    resolution = {
      strategy = "smart";
      prefer-source = "auto";
      override-conflicts = true;
    };
    optimization = {
      lazy-loading = true;
      cache-package-info = true;
      parallel-evaluation = true;
    };
  };
  nixies.packages.sets = {
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
  system.stateVersion = "24.11";
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
    shell = pkgs.zsh;
  };
  nixpkgs.config = {
    packageOverrides = pkgs: {
      firefox = pkgs.firefox-nightly;
    };
  };
  environment.variables = {
    CUSTOM_VAR = "demo-value";
  };
}
