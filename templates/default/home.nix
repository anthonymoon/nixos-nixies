{
  config,
  pkgs,
  ...
}: {
  home = {
    username = "amoon";
    homeDirectory = "/home/amoon";
    stateVersion = "24.11";
  };
  wayland.windowManager.niri = {
    enable = true;
    settings = {
      input = {
        keyboard.xkb = {
          layout = "us";
          options = "grp:alt_shift_toggle";
        };
        touchpad = {
          tap = true;
          natural-scroll = true;
        };
      };
      layout = {
        gaps = 8;
        center-focused-column = "never";
        preset-column-widths = [
          {proportion = 1.0/3.0;}
          {proportion = 1.0/2.0;}
          {proportion = 2.0/3.0;}
        ];
      };
      spawn-at-startup = [
        {command = ["waybar"];}
        {command = ["mako"];}
      ];
      binds = with config.lib.niri.actions; {
        "Mod+Return" = spawn "foot";
        "Mod+D" = spawn "wofi" "--show" "drun";
        "Mod+Q" = close-window;
        "Mod+H" = focus-column-left;
        "Mod+L" = focus-column-right;
        "Mod+J" = focus-window-down;
        "Mod+K" = focus-window-up;
        "Mod+Shift+H" = move-column-left;
        "Mod+Shift+L" = move-column-right;
        "Mod+Shift+J" = move-window-down;
        "Mod+Shift+K" = move-window-up;
        "Mod+1" = focus-workspace 1;
        "Mod+2" = focus-workspace 2;
        "Mod+3" = focus-workspace 3;
        "Mod+4" = focus-workspace 4;
        "Mod+Shift+1" = move-column-to-workspace 1;
        "Mod+Shift+2" = move-column-to-workspace 2;
        "Mod+Shift+3" = move-column-to-workspace 3;
        "Mod+Shift+4" = move-column-to-workspace 4;
      };
    };
  };
  wayland.windowManager.hyprland = {
    enable = true;
    settings = {
      "$mod" = "SUPER";
      bind = [
        "$mod, Return, exec, foot"
        "$mod, D, exec, wofi --show drun"
        "$mod, Q, killactive"
        "$mod, H, movefocus, l"
        "$mod, L, movefocus, r"
        "$mod, K, movefocus, u"
        "$mod, J, movefocus, d"
        "$mod, 1, workspace, 1"
        "$mod, 2, workspace, 2"
        "$mod, 3, workspace, 3"
        "$mod, 4, workspace, 4"
        "$mod SHIFT, 1, movetoworkspace, 1"
        "$mod SHIFT, 2, movetoworkspace, 2"
        "$mod SHIFT, 3, movetoworkspace, 3"
        "$mod SHIFT, 4, movetoworkspace, 4"
      ];
      exec-once = [
        "waybar"
        "mako"
      ];
    };
  };
  programs.foot = {
    enable = true;
    settings = {
      main = {
        font = "Fira Code:size=12";
        dpi-aware = "yes";
      };
      colors = {
        background = "1e1e2e";
        foreground = "cdd6f4";
      };
    };
  };
  programs.fish = {
    enable = true;
    shellInit = ''
      set -g fish_greeting ""
    '';
    shellAliases = {
      ll = "ls -la";
      la = "ls -la";
      l = "ls -l";
      g = "git";
      gs = "git status";
      ga = "git add";
      gc = "git commit";
      gp = "git push";
      gl = "git pull";
      nrs = "nixos-rebuild switch --flake";
      nrt = "nixos-rebuild test --flake";
      hms = "home-manager switch --flake";
    };
  };
  programs.starship = {
    enable = true;
    settings = {
      format = "$directory$git_branch$git_status$nix_shell$character";
      directory = {
        truncation_length = 3;
        style = "bold blue";
      };
      git_branch = {
        format = "[$symbol$branch]($style) ";
        style = "bold purple";
      };
      nix_shell = {
        format = "[$symbol$state]($style) ";
        style = "bold yellow";
      };
      character = {
        success_symbol = "[❯](bold green)";
        error_symbol = "[❯](bold red)";
      };
    };
  };
  programs.waybar = {
    enable = true;
    settings = {
      mainBar = {
        layer = "top";
        position = "top";
        height = 30;
        modules-left = ["niri/workspaces"];
        modules-center = ["niri/window"];
        modules-right = ["pulseaudio" "network" "battery" "clock"];
        "niri/workspaces" = {
          format = "{name}";
        };
        "niri/window" = {
          format = "{title}";
          max-length = 50;
        };
        clock = {
          format = "{:%H:%M}";
          format-alt = "{:%Y-%m-%d %H:%M:%S}";
        };
        battery = {
          format = "{capacity}% {icon}";
          format-icons = ["" "" "" "" ""];
        };
        network = {
          format-wifi = "{essid} ({signalStrength}%) ";
          format-ethernet = "{ifname} ";
          format-disconnected = "Disconnected ⚠";
        };
        pulseaudio = {
          format = "{volume}% {icon}";
          format-muted = "muted ";
          format-icons = {
            default = ["" "" ""];
          };
        };
      };
    };
    style = ''
      * {
      font-family: "Fira Code", monospace;
      font-size: 13px;
      }
      window
      background-color: rgba(30, 30, 46, 0.9);
      border-bottom: 2px solid
      color:
      }
      padding: 0 8px;
      background-color: transparent;
      color:
      border: none;
      border-radius: 0;
      }
      background-color:
      color:
      }
      color:
      }
      padding: 0 10px;
      margin: 0 2px;
      }
    '';
  };
  services.mako = {
    enable = true;
    backgroundColor = "#2e3440";
    borderColor = "#88c0d0";
    textColor = "#d8dee9";
    borderRadius = 8;
    borderSize = 2;
    defaultTimeout = 5000;
  };
  programs.git = {
    enable = true;
    userName = "Your Name";
    userEmail = "your.email@example.com";
    extraConfig = {
      init.defaultBranch = "main";
      pull.rebase = true;
      push.autoSetupRemote = true;
    };
  };
  home.packages = with pkgs; [
    firefox
    vscode
    mpv
    nautilus
    wofi
    grim
    slurp
    wl-clipboard
    htop
    tree
    fira-code
    noto-fonts
    noto-fonts-emoji
  ];
  xdg = {
    enable = true;
    mimeApps = {
      enable = true;
      defaultApplications = {
        "text/html" = "firefox.desktop";
        "x-scheme-handler/http" = "firefox.desktop";
        "x-scheme-handler/https" = "firefox.desktop";
        "x-scheme-handler/about" = "firefox.desktop";
        "x-scheme-handler/unknown" = "firefox.desktop";
      };
    };
    userDirs = {
      enable = true;
      createDirectories = true;
      documents = "$HOME/Documents";
      download = "$HOME/Downloads";
      music = "$HOME/Music";
      pictures = "$HOME/Pictures";
      videos = "$HOME/Videos";
      desktop = "$HOME/Desktop";
      publicShare = "$HOME/Public";
      templates = "$HOME/Templates";
    };
  };
  fonts.fontconfig.enable = true;
  programs.home-manager.enable = true;
}
