{
  config,
  lib,
  pkgs,
  inputs,
  ...
}: let
  unified-lib = import ../../../lib {inherit inputs lib;};
in
  (unified-lib.mkUnifiedModule {
    name = "packages-desktop";
    description = "Desktop environment packages including window managers, display managers, and desktop utilities";
    category = "packages";
    options = with lib; {
      enable = mkEnableOption "desktop package set";
      window-managers = {
        enable = mkEnableOption "window managers and compositors" // {default = true;};
        niri = {
          enable = mkEnableOption "Niri scrollable-tiling Wayland compositor";
          features = {
            xwayland = mkEnableOption "XWayland support for X11 applications" // {default = true;};
            screensharing = mkEnableOption "screen sharing capabilities";
            clipboard = mkEnableOption "clipboard integration" // {default = true;};
            notifications = mkEnableOption "notification support" // {default = true;};
          };
        };
        hyprland = {
          enable = mkEnableOption "Hyprland dynamic tiling Wayland compositor";
          plugins = mkEnableOption "Hyprland plugin ecosystem";
          animations = mkEnableOption "advanced animations and effects" // {default = true;};
          config-tools = mkEnableOption "configuration and management tools";
        };
        plasma6 = {
          enable = mkEnableOption "KDE Plasma 6 desktop environment";
          full-suite = mkEnableOption "full KDE application suite";
          wayland-session = mkEnableOption "Wayland session support" // {default = true;};
          customization = mkEnableOption "theme and customization packages";
        };
        alternatives = {
          sway = mkEnableOption "Sway i3-compatible Wayland compositor";
          i3 = mkEnableOption "i3 tiling window manager";
          awesome = mkEnableOption "Awesome dynamic window manager";
          dwm = mkEnableOption "DWM suckless window manager";
          bspwm = mkEnableOption "BSPWM binary space partitioning window manager";
        };
      };
      display-managers = {
        enable = mkEnableOption "display managers" // {default = true;};
        greetd = {
          enable = mkEnableOption "greetd minimal display manager" // {default = true;};
          greeters = {
            tuigreet = mkEnableOption "TUI greeter for greetd" // {default = true;};
            gtk-greet = mkEnableOption "GTK-based greeter";
            web-greeter = mkEnableOption "web-based greeter";
          };
        };
        alternatives = {
          gdm = mkEnableOption "GDM (GNOME Display Manager)";
          sddm = mkEnableOption "SDDM (Simple Desktop Display Manager)";
          lightdm = mkEnableOption "LightDM lightweight display manager";
          ly = mkEnableOption "Ly TUI display manager";
        };
      };
      utilities = {
        enable = mkEnableOption "desktop utilities and applications" // {default = true;};
        terminal-emulators = {
          enable = mkEnableOption "terminal emulators" // {default = true;};
          packages = mkOption {
            type = types.listOf (types.enum ["alacritty" "kitty" "foot" "wezterm" "gnome-terminal" "konsole"]);
            default = ["alacritty" "foot"];
            description = "Terminal emulators to install";
          };
        };
        file-managers = {
          enable = mkEnableOption "graphical file managers";
          packages = mkOption {
            type = types.listOf (types.enum ["nautilus" "dolphin" "thunar" "pcmanfm" "nemo"]);
            default = ["nautilus"];
            description = "File managers to install";
          };
        };
        launchers = {
          enable = mkEnableOption "application launchers" // {default = true;};
          packages = mkOption {
            type = types.listOf (types.enum ["rofi" "wofi" "fuzzel" "dmenu" "bemenu"]);
            default = ["rofi" "fuzzel"];
            description = "Application launchers to install";
          };
        };
        notifications = {
          enable = mkEnableOption "notification systems" // {default = true;};
          daemon = mkOption {
            type = types.enum ["mako" "dunst" "notification-daemon"];
            default = "mako";
            description = "Notification daemon to use";
          };
        };
        status-bars = {
          enable = mkEnableOption "status bars and panels";
          packages = mkOption {
            type = types.listOf (types.enum ["waybar" "polybar" "eww" "i3status" "yambar"]);
            default = ["waybar"];
            description = "Status bars to install";
          };
        };
        system-monitors = {
          enable = mkEnableOption "graphical system monitors";
          packages = mkOption {
            type = types.listOf (types.enum ["htop" "btop" "mission-center" "gnome-system-monitor"]);
            default = ["btop" "mission-center"];
            description = "System monitors to install";
          };
        };
      };
      wayland = {
        enable = mkEnableOption "Wayland display server and ecosystem" // {default = true;};
        core = {
          protocols = mkEnableOption "Wayland protocols and extensions" // {default = true;};
          utilities = mkEnableOption "Wayland-specific utilities" // {default = true;};
        };
        screen-capture = {
          enable = mkEnableOption "screen capture and recording tools";
          packages = mkOption {
            type = types.listOf (types.enum ["grim" "slurp" "wl-clipboard" "obs-studio" "kooha"]);
            default = ["grim" "slurp" "wl-clipboard"];
            description = "Screen capture tools";
          };
        };
        clipboard = {
          enable = mkEnableOption "clipboard managers" // {default = true;};
          manager = mkOption {
            type = types.enum ["wl-clipboard" "cliphist" "copyq"];
            default = "wl-clipboard";
            description = "Clipboard manager to use";
          };
        };
      };
      theming = {
        enable = mkEnableOption "theming and customization tools";
        icon-themes = mkEnableOption "icon theme packages";
        gtk-themes = mkEnableOption "GTK theme packages";
        qt-themes = mkEnableOption "Qt theme packages";
        cursor-themes = mkEnableOption "cursor theme packages";
        tools = {
          enable = mkEnableOption "theme management tools";
          lxappearance = mkEnableOption "LXAppearance GTK theme manager";
          qt5ct = mkEnableOption "Qt5 Configuration Tool";
          kvantum = mkEnableOption "Kvantum theme engine";
        };
      };
      accessibility = {
        enable = mkEnableOption "accessibility features and tools";
        screen-reader = mkEnableOption "screen reader support";
        magnifier = mkEnableOption "screen magnification tools";
        high-contrast = mkEnableOption "high contrast themes";
        large-fonts = mkEnableOption "large font support";
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
            (lib.optionals cfg.window-managers.niri.enable [
              ])
            (lib.optionals cfg.window-managers.hyprland.enable [
              hyprland
              hyprpaper
              hyprpicker
              hypridle
              hyprlock
            ])
            (lib.optionals cfg.window-managers.hyprland.plugins [
              hyprland-plugins.hy3
              hyprland-plugins.hyprexpo
            ])
            (lib.optionals cfg.window-managers.hyprland.config-tools [
              hyprland-monitor-attached
              wlr-randr
            ])
            (lib.optionals cfg.window-managers.plasma6.enable [
              kdePackages.plasma-desktop
              kdePackages.plasma-workspace
              kdePackages.systemsettings
              kdePackages.kwin
            ])
            (lib.optionals cfg.window-managers.plasma6.full-suite [
              kdePackages.kate
              kdePackages.dolphin
              kdePackages.konsole
              kdePackages.spectacle
              kdePackages.okular
              kdePackages.gwenview
              kdePackages.ark
              kdePackages.plasma-systemmonitor
            ])
            (lib.optionals cfg.window-managers.alternatives.sway [
              sway
              swaylock
              swayidle
              swaybg
            ])
            (lib.optionals cfg.window-managers.alternatives.i3 [
              i3
              i3status
              i3lock
              i3blocks
            ])
            (lib.optionals cfg.window-managers.alternatives.awesome [
              awesome
            ])
            (lib.optionals cfg.window-managers.alternatives.bspwm [
              bspwm
              sxhkd
            ])
            (lib.optionals cfg.display-managers.greetd.enable [
              greetd.greetd
            ])
            (lib.optionals cfg.display-managers.greetd.greeters.tuigreet [
              greetd.tuigreet
            ])
            (lib.optionals cfg.display-managers.greetd.greeters.gtk-greet [
              greetd.gtkgreet
            ])
            (lib.optionals cfg.display-managers.alternatives.gdm [
              gnome.gdm
            ])
            (lib.optionals cfg.display-managers.alternatives.sddm [
              sddm
            ])
            (lib.optionals cfg.display-managers.alternatives.lightdm [
              lightdm
              lightdm-gtk-greeter
            ])
            (lib.optionals
              (cfg.utilities.terminal-emulators.enable
                && builtins.elem "alacritty" cfg.utilities.terminal-emulators.packages) [
                alacritty
              ])
            (lib.optionals
              (cfg.utilities.terminal-emulators.enable
                && builtins.elem "kitty" cfg.utilities.terminal-emulators.packages) [
                kitty
              ])
            (lib.optionals
              (cfg.utilities.terminal-emulators.enable
                && builtins.elem "foot" cfg.utilities.terminal-emulators.packages) [
                foot
              ])
            (lib.optionals
              (cfg.utilities.terminal-emulators.enable
                && builtins.elem "wezterm" cfg.utilities.terminal-emulators.packages) [
                wezterm
              ])
            (lib.optionals
              (cfg.utilities.file-managers.enable
                && builtins.elem "nautilus" cfg.utilities.file-managers.packages) [
                gnome.nautilus
              ])
            (lib.optionals
              (cfg.utilities.file-managers.enable
                && builtins.elem "dolphin" cfg.utilities.file-managers.packages) [
                kdePackages.dolphin
              ])
            (lib.optionals
              (cfg.utilities.file-managers.enable
                && builtins.elem "thunar" cfg.utilities.file-managers.packages) [
                xfce.thunar
              ])
            (lib.optionals
              (cfg.utilities.launchers.enable
                && builtins.elem "rofi" cfg.utilities.launchers.packages) [
                rofi-wayland
              ])
            (lib.optionals
              (cfg.utilities.launchers.enable
                && builtins.elem "wofi" cfg.utilities.launchers.packages) [
                wofi
              ])
            (lib.optionals
              (cfg.utilities.launchers.enable
                && builtins.elem "fuzzel" cfg.utilities.launchers.packages) [
                fuzzel
              ])
            (lib.optionals
              (cfg.utilities.status-bars.enable
                && builtins.elem "waybar" cfg.utilities.status-bars.packages) [
                waybar
              ])
            (lib.optionals
              (cfg.utilities.status-bars.enable
                && builtins.elem "polybar" cfg.utilities.status-bars.packages) [
                polybar
              ])
            (lib.optionals
              (cfg.utilities.status-bars.enable
                && builtins.elem "eww" cfg.utilities.status-bars.packages) [
                eww
              ])
            (lib.optionals
              (cfg.utilities.system-monitors.enable
                && builtins.elem "mission-center" cfg.utilities.system-monitors.packages) [
                mission-center
              ])
            (lib.optionals
              (cfg.utilities.system-monitors.enable
                && builtins.elem "gnome-system-monitor" cfg.utilities.system-monitors.packages) [
                gnome.gnome-system-monitor
              ])
            (lib.optionals cfg.wayland.core.protocols [
              wayland-protocols
              wayland-scanner
              wlr-protocols
            ])
            (lib.optionals cfg.wayland.core.utilities [
              wlr-randr
              wlr-layout-ui
              wev
              wayland-utils
            ])
            (lib.optionals
              (cfg.wayland.screen-capture.enable
                && builtins.elem "grim" cfg.wayland.screen-capture.packages) [
                grim
              ])
            (lib.optionals
              (cfg.wayland.screen-capture.enable
                && builtins.elem "slurp" cfg.wayland.screen-capture.packages) [
                slurp
              ])
            (lib.optionals
              (cfg.wayland.screen-capture.enable
                && builtins.elem "wl-clipboard" cfg.wayland.screen-capture.packages) [
                wl-clipboard
              ])
            (lib.optionals
              (cfg.utilities.notifications.enable
                && cfg.utilities.notifications.daemon == "mako") [
                mako
              ])
            (lib.optionals
              (cfg.utilities.notifications.enable
                && cfg.utilities.notifications.daemon == "dunst") [
                dunst
              ])
            (lib.optionals cfg.theming.tools.enable [
              (lib.optionals cfg.theming.tools.lxappearance [lxappearance])
              (lib.optionals cfg.theming.tools.qt5ct [qt5ct])
              (lib.optionals cfg.theming.tools.kvantum [libsForQt5.qtstyleplugin-kvantum])
            ])
            (lib.optionals cfg.theming.icon-themes [
              papirus-icon-theme
              numix-icon-theme
              tela-icon-theme
              breeze-icons
            ])
            (lib.optionals cfg.theming.gtk-themes [
              arc-theme
              adapta-gtk-theme
              materia-theme
              orchis-theme
            ])
            (lib.optionals cfg.theming.cursor-themes [
              bibata-cursors
              numix-cursor-theme
              vanilla-dmz
            ])
            (lib.optionals cfg.accessibility.screen-reader [
              orca
              espeak
            ])
            (lib.optionals cfg.accessibility.magnifier [
              gnome.gnome-shell
              kmag
            ])
          ];
        services = lib.mkMerge [
          (lib.mkIf cfg.display-managers.greetd.enable {
            greetd = {
              enable = true;
              settings = {
                default_session = lib.mkIf cfg.display-managers.greetd.greeters.tuigreet {
                  command = "${pkgs.greetd.tuigreet}/bin/tuigreet --time --cmd ${
                    if cfg.window-managers.hyprland.enable
                    then "${pkgs.hyprland}/bin/Hyprland"
                    else if cfg.window-managers.plasma6.enable
                    then "${pkgs.kdePackages.plasma-workspace}/bin/startplasma-wayland"
                    else if cfg.window-managers.alternatives.sway
                    then "${pkgs.sway}/bin/sway"
                    else "bash"
                  }";
                };
              };
            };
          })
          (lib.mkIf cfg.display-managers.alternatives.gdm {
            xserver = {
              enable = true;
              displayManager.gdm.enable = true;
            };
          })
          (lib.mkIf cfg.display-managers.alternatives.sddm {
            xserver = {
              enable = true;
              displayManager.sddm.enable = true;
            };
          })
          (lib.mkIf cfg.wayland.enable {
            dbus.enable = true;
            xdg.portal = {
              enable = true;
              wlr.enable = true;
              extraPortals = lib.mkMerge [
                (lib.mkIf cfg.window-managers.hyprland.enable [pkgs.xdg-desktop-portal-hyprland])
                (lib.mkIf cfg.window-managers.plasma6.enable [pkgs.kdePackages.xdg-desktop-portal-kde])
              ];
            };
          })
        ];
        programs = lib.mkMerge [
          (lib.mkIf cfg.window-managers.hyprland.enable {
            hyprland = {
              enable = true;
              xwayland.enable = true;
            };
          })
          (lib.mkIf cfg.window-managers.alternatives.sway {
            sway = {
              enable = true;
              wrapperFeatures.gtk = true;
            };
          })
          (lib.mkIf cfg.utilities.terminal-emulators.enable {
            environment.variables.TERMINAL =
              if builtins.elem "alacritty" cfg.utilities.terminal-emulators.packages
              then "alacritty"
              else if builtins.elem "kitty" cfg.utilities.terminal-emulators.packages
              then "kitty"
              else if builtins.elem "foot" cfg.utilities.terminal-emulators.packages
              then "foot"
              else "xterm";
          })
        ];
        environment.variables = lib.mkMerge [
          (lib.mkIf cfg.wayland.enable {
            NIXOS_OZONE_WL = "1";
            MOZ_ENABLE_WAYLAND = "1";
            QT_QPA_PLATFORM = "wayland";
            GDK_BACKEND = "wayland";
            XDG_SESSION_TYPE = "wayland";
            XDG_CURRENT_DESKTOP =
              if cfg.window-managers.hyprland.enable
              then "Hyprland"
              else if cfg.window-managers.plasma6.enable
              then "KDE"
              else if cfg.window-managers.alternatives.sway
              then "sway"
              else "wayland";
          })
          {
            XDG_DATA_DIRS = "/run/current-system/sw/share";
            XDG_CONFIG_DIRS = "/etc/xdg";
          }
        ];
        fonts = {
          enableDefaultPackages = true;
          packages = with pkgs; [
            inter
            roboto
            open-sans
            lato
            ubuntu_font_family
            font-awesome
            material-icons
            noto-fonts-emoji
            twitter-color-emoji
          ];
          fontconfig = {
            enable = true;
            defaultFonts = {
              serif = ["Liberation Serif" "Noto Serif"];
              sansSerif = ["Inter" "Liberation Sans" "Noto Sans"];
              monospace = ["Source Code Pro" "Liberation Mono"];
              emoji = ["Noto Color Emoji" "Twitter Color Emoji"];
            };
          };
          pipewire = {
            enable = true;
            alsa.enable = true;
            alsa.support32Bit = true;
            pulse.enable = true;
            jack.enable = true;
          };
          avahi = {
            enable = true;
            nssmdns = true;
            openFirewall = true;
          };
        };
        security = {
          polkit.enable = true;
          rtkit.enable = true;
          pam.services.greetd.enableGnomeKeyring = lib.mkIf cfg.display-managers.greetd.enable true;
        };
        hardware = {
          opengl = {
            enable = true;
            driSupport = true;
            driSupport32Bit = true;
          };
          pulseaudio.enable = false;
        };
      };
    dependencies = ["core" "hardware"];
  }) {
    inherit config lib pkgs inputs;
  }
