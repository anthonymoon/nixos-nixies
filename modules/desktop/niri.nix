{
  config,
  lib,
  pkgs,
  inputs,
  ...
}: let
  nixies-lib = import ../../lib {inherit inputs lib;};
in
  (nixies-lib.mkUnifiedModule {
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
      programs.wayland-session.enable = true;
      programs.niri = {
        enable = true;
        package = pkgs.niri;
      };
      programs.xwayland.enable = lib.mkIf cfg.features.xwayland true;
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
      security.rtkit.enable = true;
      services.pipewire = {
        enable = true;
        alsa.enable = true;
        pulse.enable = true;
        jack.enable = true;
      };
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
      environment.systemPackages = with pkgs;
        lib.flatten [
          [niri waybar wofi]
          (lib.optional (cfg.applications.terminal == "foot") foot)
          (lib.optional (cfg.applications.terminal == "kitty") kitty)
          (lib.optional (cfg.applications.terminal == "alacritty") alacritty)
          (lib.optional (cfg.applications.browser == "firefox") firefox)
          (lib.optional (cfg.applications.browser == "chromium") chromium)
          (lib.optional (cfg.applications.launcher == "anyrun") anyrun)
          (lib.optional (cfg.applications.launcher == "rofi-wayland") rofi-wayland)
          (lib.optionals cfg.features.clipboard [wl-clipboard cliphist])
          [grim slurp swappy]
          (lib.optionals cfg.features.notifications [mako libnotify])
          [nautilus]
          (lib.optionals cfg.theming.enable [
            cfg.theming.cursor.package
            gsettings-desktop-schemas
            adwaita-icon-theme
          ])
        ];
      xdg.portal = lib.mkIf cfg.features.screensharing {
        enable = true;
        wlr.enable = true;
        config.common.default = "*";
      };
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
      programs.dconf.enable = lib.mkIf cfg.theming.gtk.enable true;
      environment.sessionVariables = {
        NIXOS_OZONE_WL = "1";
        WLR_NO_HARDWARE_CURSORS = "1";
        XDG_SESSION_TYPE = "wayland";
        XDG_CURRENT_DESKTOP = "niri";
      };
      boot.kernelModules = ["uinput"];
      hardware.graphics = {
        enable = true;
        driSupport = true;
        driSupport32Bit = true;
      };
    };
    security = cfg: {
      users.groups.video = {};
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
  }) {
    inherit config lib pkgs inputs;
  }
