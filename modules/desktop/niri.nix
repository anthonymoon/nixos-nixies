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
    name = "niri";
    description = "Niri scrollable tiling compositor";
    category = "desktop";

    options = with lib; {
      enable = mkEnableOption "Niri compositor";

      session = {
        autoStart = mkOption {
          type = types.bool;
          default = false;
          description = "Auto-start Niri session";
        };

        displayManager = mkOption {
          type = types.enum ["gdm" "sddm" "greetd"];
          default = "greetd";
          description = "Display manager to use with Niri";
        };
      };

      features = {
        xwayland = mkEnableOption "Xwayland support" // {default = true;};
        screensharing = mkEnableOption "Screen sharing support" // {default = true;};
        clipboard = mkEnableOption "Clipboard integration" // {default = true;};
        notifications = mkEnableOption "Notification support" // {default = true;};
      };

      applications = {
        terminal = mkOption {
          type = types.str;
          default = "foot";
          description = "Default terminal emulator";
        };

        browser = mkOption {
          type = types.str;
          default = "firefox";
          description = "Default web browser";
        };

        launcher = mkOption {
          type = types.str;
          default = "anyrun";
          description = "Application launcher";
        };
      };

      theming = {
        enable = mkEnableOption "Custom theming" // {default = true;};

        cursor = {
          package = mkOption {
            type = types.package;
            default = pkgs.bibata-cursors;
            description = "Cursor theme package";
          };
          name = mkOption {
            type = types.str;
            default = "Bibata-Modern-Classic";
            description = "Cursor theme name";
          };
        };

        gtk = {
          enable = mkEnableOption "GTK theming" // {default = true;};
          theme = mkOption {
            type = types.str;
            default = "Adwaita-dark";
            description = "GTK theme name";
          };
        };
      };
    };

    config = {
      cfg,
      config,
      lib,
      pkgs,
    }: {
      # Enable Wayland
      programs.wayland-session.enable = true;

      # Niri compositor
      programs.niri = {
        enable = true;
        package = pkgs.niri;
      };

      # Xwayland support
      programs.xwayland.enable = lib.mkIf cfg.features.xwayland true;

      # Display manager configuration
      services.greetd = lib.mkIf (cfg.session.displayManager == "greetd") {
        enable = true;
        settings = {
          default_session = {
            command = "${pkgs.greetd.tuigreet}/bin/tuigreet --time --cmd niri-session";
            user = "greeter";
          };
        };
      };

      services.xserver = lib.mkIf (cfg.session.displayManager == "gdm") {
        enable = true;
        displayManager.gdm = {
          enable = true;
          wayland = true;
        };
      };

      # Audio system
      security.rtkit.enable = true;
      services.pipewire = {
        enable = true;
        alsa.enable = true;
        pulse.enable = true;
        jack.enable = true;
      };

      # Polkit for privilege escalation
      security.polkit.enable = true;
      systemd.user.services.polkit-gnome-authentication-agent-1 = {
        description = "polkit-gnome-authentication-agent-1";
        wantedBy = ["graphical-session.target"];
        wants = ["graphical-session.target"];
        after = ["graphical-session.target"];
        serviceConfig = {
          Type = "simple";
          ExecStart = "${pkgs.polkit_gnome}/libexec/polkit-gnome-authentication-agent-1";
          Restart = "on-failure";
          RestartSec = 1;
          TimeoutStopSec = 10;
        };
      };

      # Essential packages
      environment.systemPackages = with pkgs;
        lib.flatten [
          # Core Niri and Wayland
          [niri waybar wofi]

          # Terminal
          (lib.optional (cfg.applications.terminal == "foot") foot)
          (lib.optional (cfg.applications.terminal == "kitty") kitty)
          (lib.optional (cfg.applications.terminal == "alacritty") alacritty)

          # Browser
          (lib.optional (cfg.applications.browser == "firefox") firefox)
          (lib.optional (cfg.applications.browser == "chromium") chromium)

          # Launcher
          (lib.optional (cfg.applications.launcher == "anyrun") anyrun)
          (lib.optional (cfg.applications.launcher == "rofi-wayland") rofi-wayland)

          # Clipboard support
          (lib.optionals cfg.features.clipboard [wl-clipboard cliphist])

          # Screenshot tools
          [grim slurp swappy]

          # Notifications
          (lib.optionals cfg.features.notifications [mako libnotify])

          # File manager
          [nautilus]

          # Theming
          (lib.optionals cfg.theming.enable [
            cfg.theming.cursor.package
            gsettings-desktop-schemas
            adwaita-icon-theme
          ])
        ];

      # XDG portal for screen sharing and file dialogs
      xdg.portal = lib.mkIf cfg.features.screensharing {
        enable = true;
        wlr.enable = true;
        config.common.default = "*";
      };

      # Font configuration
      fonts = {
        packages = with pkgs; [
          noto-fonts
          noto-fonts-cjk
          noto-fonts-emoji
          liberation_ttf
          fira-code
          fira-code-symbols
        ];

        fontconfig = {
          enable = true;
          defaultFonts = {
            serif = ["Noto Serif"];
            sansSerif = ["Noto Sans"];
            monospace = ["Fira Code"];
          };
        };
      };

      # GTK configuration
      programs.dconf.enable = lib.mkIf cfg.theming.gtk.enable true;

      # Session variables
      environment.sessionVariables = {
        NIXOS_OZONE_WL = "1";
        WLR_NO_HARDWARE_CURSORS = "1";
        XDG_SESSION_TYPE = "wayland";
        XDG_CURRENT_DESKTOP = "niri";
      };

      # Kernel modules for graphics
      boot.kernelModules = ["uinput"];

      # Hardware acceleration
      hardware.opengl = {
        enable = true;
        driSupport = true;
        driSupport32Bit = true;
      };
    };

    # Security configuration for Niri
    security = cfg: {
      # Allow users in video group to access graphics devices
      users.groups.video = {};

      # Polkit rules for desktop operations
      security.polkit.extraConfig = ''
        polkit.addRule(function(action, subject) {
            if (action.id == "org.freedesktop.color-manager.create-device" ||
                action.id == "org.freedesktop.color-manager.create-profile" ||
                action.id == "org.freedesktop.color-manager.delete-device" ||
                action.id == "org.freedesktop.color-manager.delete-profile" ||
                action.id == "org.freedesktop.color-manager.modify-device" ||
                action.id == "org.freedesktop.color-manager.modify-profile") {
                if (subject.isInGroup("wheel")) {
                    return polkit.Result.YES;
                }
            }
        });
      '';
    };

    dependencies = ["core"];
  }
