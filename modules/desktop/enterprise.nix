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
    name = "enterprise-desktop";
    description = "Enterprise desktop environment with productivity tools, collaboration software, and business applications";
    category = "desktop";

    options = with lib; {
      enable = mkEnableOption "enterprise desktop environment";

      environment = {
        type = mkOption {
          type = types.enum ["gnome" "kde" "xfce" "cinnamon"];
          default = "gnome";
          description = "Desktop environment for enterprise use";
        };

        theme = {
          name = mkOption {
            type = types.str;
            default = "enterprise";
            description = "Enterprise theme name";
          };

          corporate-branding = mkEnableOption "corporate branding and customization";
          locked-settings = mkEnableOption "lock desktop settings for users" // {default = true;};
        };

        accessibility = {
          enable = mkEnableOption "accessibility features" // {default = true;};
          screen-reader = mkEnableOption "screen reader support";
          magnification = mkEnableOption "screen magnification";
          high-contrast = mkEnableOption "high contrast themes";
        };
      };

      productivity = {
        office-suite = mkOption {
          type = types.enum ["libreoffice" "onlyoffice" "wps-office"];
          default = "libreoffice";
          description = "Office suite for enterprise productivity";
        };

        document-management = {
          enable = mkEnableOption "document management integration";
          version-control = mkEnableOption "document version control";
          collaboration = mkEnableOption "real-time document collaboration";
          templates = mkEnableOption "enterprise document templates";
        };

        pdf-tools = {
          editor = mkEnableOption "PDF editing capabilities" // {default = true;};
          forms = mkEnableOption "PDF form handling";
          signing = mkEnableOption "digital document signing" // {default = true;};
          encryption = mkEnableOption "PDF encryption and security";
        };
      };

      communication = {
        email-client = mkOption {
          type = types.enum ["thunderbird" "evolution" "kmail"];
          default = "thunderbird";
          description = "Enterprise email client";
        };

        messaging = {
          teams = mkEnableOption "Microsoft Teams integration" // {default = true;};
          slack = mkEnableOption "Slack workspace integration" // {default = true;};
          element = mkEnableOption "Matrix/Element secure messaging" // {default = true;};
          signal = mkEnableOption "Signal secure messaging";
        };

        voip = {
          zoom = mkEnableOption "Zoom video conferencing" // {default = true;};
          webex = mkEnableOption "Cisco Webex integration";
          meet = mkEnableOption "Google Meet support";
          skype = mkEnableOption "Skype for Business";
        };

        calendar = {
          integration = mkEnableOption "calendar integration" // {default = true;};
          scheduling = mkEnableOption "meeting scheduling tools";
          room-booking = mkEnableOption "conference room booking";
        };
      };

      development = {
        enable = mkEnableOption "development tools for technical users";

        ides = {
          vscode = mkEnableOption "Visual Studio Code" // {default = true;};
          intellij = mkEnableOption "IntelliJ IDEA";
          eclipse = mkEnableOption "Eclipse IDE";
        };

        tools = {
          git = mkEnableOption "Git version control" // {default = true;};
          docker = mkEnableOption "Docker containers";
          kubernetes = mkEnableOption "Kubernetes tools";
          terraform = mkEnableOption "Terraform infrastructure";
        };

        languages = {
          python = mkEnableOption "Python development environment";
          nodejs = mkEnableOption "Node.js development environment";
          java = mkEnableOption "Java development environment";
          dotnet = mkEnableOption ".NET development environment";
        };
      };

      security = {
        password-manager = mkOption {
          type = types.enum ["keepassxc" "bitwarden" "1password"];
          default = "keepassxc";
          description = "Enterprise password manager";
        };

        vpn = {
          clients = mkOption {
            type = types.listOf (types.enum ["openvpn" "wireguard" "openconnect" "forticlient"]);
            default = ["openvpn" "openconnect"];
            description = "VPN client applications";
          };

          auto-connect = mkEnableOption "automatic VPN connection";
          kill-switch = mkEnableOption "VPN kill switch functionality";
        };

        encryption = {
          file-encryption = mkEnableOption "file encryption tools" // {default = true;};
          email-encryption = mkEnableOption "email encryption (GPG)" // {default = true;};
          disk-encryption = mkEnableOption "additional disk encryption tools";
        };
      };

      multimedia = {
        enable = mkEnableOption "multimedia applications for presentations";

        graphics = {
          design = mkEnableOption "graphic design applications";
          photo-editing = mkEnableOption "photo editing software";
          vector-graphics = mkEnableOption "vector graphics tools";
        };

        video = {
          editing = mkEnableOption "video editing capabilities";
          streaming = mkEnableOption "video streaming tools";
          recording = mkEnableOption "screen recording software" // {default = true;};
        };

        audio = {
          editing = mkEnableOption "audio editing software";
          recording = mkEnableOption "audio recording tools";
          conferencing = mkEnableOption "high-quality audio for conferences" // {default = true;};
        };
      };

      remote-work = {
        enable = mkEnableOption "remote work tools and optimization" // {default = true;};

        remote-desktop = {
          clients = mkOption {
            type = types.listOf (types.enum ["remmina" "vnc" "rdp" "teamviewer" "anydesk"]);
            default = ["remmina" "vnc" "rdp"];
            description = "Remote desktop client applications";
          };

          server = mkEnableOption "remote desktop server capabilities";
        };

        file-sync = {
          cloud-storage = mkOption {
            type = types.listOf (types.enum ["nextcloud" "dropbox" "onedrive" "googledrive"]);
            default = ["nextcloud"];
            description = "Cloud storage synchronization";
          };

          enterprise-sync = mkEnableOption "enterprise file synchronization";
        };

        time-tracking = {
          enable = mkEnableOption "time tracking applications";
          automatic = mkEnableOption "automatic time tracking";
          project-integration = mkEnableOption "project management integration";
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
        # Base desktop environment
        (lib.mkIf cfg.enable {
          # Desktop environment configuration
          services.xserver = {
            enable = true;

            # GNOME desktop environment
            displayManager.gdm = lib.mkIf (cfg.environment.type == "gnome") {
              enable = true;
              wayland = true;
              autoSuspend = false;

              # Enterprise branding
              banner = lib.mkIf cfg.environment.theme.corporate-branding ''
                Enterprise Workstation
                Authorized Users Only
              '';
            };

            desktopManager = {
              gnome.enable = lib.mkIf (cfg.environment.type == "gnome") true;
              plasma5.enable = lib.mkIf (cfg.environment.type == "kde") true;
              xfce.enable = lib.mkIf (cfg.environment.type == "xfce") true;
              cinnamon.enable = lib.mkIf (cfg.environment.type == "cinnamon") true;
            };
          };

          # GNOME configuration
          environment.gnome.excludePackages = lib.mkIf (cfg.environment.type == "gnome") (with pkgs; [
            # Remove games and non-enterprise applications
            gnome-tour
            gnome.gnome-music
            gnome.gnome-photos
            gnome.totem
            gnome.geary
            gnome.epiphany
            gnome.gnome-maps
            gnome.gnome-weather
            gnome.gnome-contacts
            gnome.simple-scan
          ]);

          # Enterprise GNOME extensions
          environment.systemPackages = lib.mkIf (cfg.environment.type == "gnome") (with pkgs; [
            gnomeExtensions.dash-to-panel
            gnomeExtensions.desktop-icons-ng-ding
            gnomeExtensions.user-themes
            gnomeExtensions.workspace-indicator
            gnomeExtensions.applications-menu
            gnomeExtensions.places-status-indicator
            gnomeExtensions.removable-drive-menu
            gnomeExtensions.launch-new-instance
            gnomeExtensions.auto-move-windows
          ]);

          # Enterprise theme configuration
          environment.etc."dconf/db/site.d/00-enterprise-theme" = lib.mkIf cfg.environment.theme.corporate-branding {
            text = ''
              [org/gnome/desktop/interface]
              gtk-theme='Adwaita-dark'
              icon-theme='Adwaita'
              cursor-theme='Adwaita'
              font-name='Cantarell 11'

              [org/gnome/desktop/background]
              picture-uri='file:///etc/enterprise/wallpaper.jpg'
              picture-uri-dark='file:///etc/enterprise/wallpaper-dark.jpg'

              [org/gnome/desktop/screensaver]
              picture-uri='file:///etc/enterprise/lockscreen.jpg'

              [org/gnome/shell]
              favorite-apps=['firefox.desktop', 'org.gnome.Nautilus.desktop', 'thunderbird.desktop', 'libreoffice-writer.desktop', 'org.gnome.Terminal.desktop']

              [org/gnome/desktop/session]
              idle-delay=900

              [org/gnome/desktop/screensaver]
              lock-enabled=true
              lock-delay=0

              [org/gnome/settings-daemon/plugins/power]
              sleep-inactive-ac-timeout=1800
              sleep-inactive-battery-timeout=900
            '';
          };

          # Lock desktop settings for enterprise
          environment.etc."dconf/db/site.d/locks/00-enterprise-locks" = lib.mkIf cfg.environment.theme.locked-settings {
            text = ''
              /org/gnome/desktop/interface/gtk-theme
              /org/gnome/desktop/interface/icon-theme
              /org/gnome/desktop/background/picture-uri
              /org/gnome/desktop/screensaver/picture-uri
              /org/gnome/desktop/session/idle-delay
              /org/gnome/desktop/screensaver/lock-enabled
              /org/gnome/settings-daemon/plugins/power/sleep-inactive-ac-timeout
            '';
          };

          # Update dconf database
          system.activationScripts.dconf-update = lib.mkIf cfg.environment.theme.locked-settings ''
            ${pkgs.dconf}/bin/dconf update
          '';
        })

        # Accessibility features
        (lib.mkIf cfg.environment.accessibility.enable {
          services.gnome.at-spi2-core.enable = true;

          # Accessibility packages
          environment.systemPackages = with pkgs;
            [
              # Screen reader
              orca
              # Magnification
              gnome.gnome-mag
              # On-screen keyboard
              onboard
              # Voice control
              speech-dispatcher
              espeak
            ]
            ++ lib.optionals cfg.environment.accessibility.screen-reader [
              speechd
              festival
            ];

          # High contrast themes
          environment.etc."dconf/db/site.d/01-accessibility" = lib.mkIf cfg.environment.accessibility.high-contrast {
            text = ''
              [org/gnome/desktop/interface]
              gtk-theme='HighContrast'
              icon-theme='HighContrast'

              [org/gnome/desktop/a11y/applications]
              screen-reader-enabled=true
              screen-keyboard-enabled=true
              screen-magnifier-enabled=true
            '';
          };
        })

        # Office and productivity suite
        (lib.mkIf (cfg.productivity.office-suite != null) {
          environment.systemPackages = with pkgs;
          # LibreOffice suite
            (lib.optionals (cfg.productivity.office-suite == "libreoffice") [
              libreoffice-fresh
              libreoffice-fresh-unwrapped
              hunspell
              hunspellDicts.en_US
              hunspellDicts.en_GB
            ])
            ++
            # OnlyOffice suite
            (lib.optionals (cfg.productivity.office-suite == "onlyoffice") [
              onlyoffice-bin
            ])
            ++
            # WPS Office
            (lib.optionals (cfg.productivity.office-suite == "wps-office") [
              wps-office
            ])
            ++
            # Common productivity tools
            [
              # Document viewers
              evince # PDF viewer
              okular # Alternative PDF viewer

              # Text editors
              gedit

              # Note taking
              gnote

              # Calculator
              gnome.gnome-calculator

              # Archive manager
              file-roller

              # Font viewer
              gnome.gnome-font-viewer

              # Character map
              gnome.gnome-characters
            ];

          # LibreOffice enterprise configuration
          environment.etc."libreoffice/registry/main.xcd" = lib.mkIf (cfg.productivity.office-suite == "libreoffice") {
            text = ''
              <?xml version="1.0" encoding="UTF-8"?>
              <oor:component-data xmlns:oor="http://openoffice.org/2001/registry">
                <node oor:name="Common">
                  <node oor:name="Security">
                    <node oor:name="Scripting">
                      <prop oor:name="MacroSecurityLevel" oor:type="xs:int">
                        <value>3</value>
                      </prop>
                    </node>
                  </node>
                  <node oor:name="Save">
                    <node oor:name="Document">
                      <prop oor:name="AutoSave" oor:type="xs:boolean">
                        <value>true</value>
                      </prop>
                      <prop oor:name="AutoSaveTimeIntervall" oor:type="xs:int">
                        <value>5</value>
                      </prop>
                    </node>
                  </node>
                </node>
              </oor:component-data>
            '';
          };
        })

        # PDF tools
        (lib.mkIf cfg.productivity.pdf-tools.editor {
          environment.systemPackages = with pkgs; [
            # PDF editors
            masterpdfeditor
            pdfarranger

            # PDF form tools
            pdftk

            # PDF signing
            qpdf

            # PDF encryption
            poppler_utils
          ];
        })

        # Communication tools
        (lib.mkIf (cfg.communication.email-client != null) {
          environment.systemPackages = with pkgs;
          # Email clients
            (lib.optionals (cfg.communication.email-client == "thunderbird") [
              thunderbird
            ])
            ++ (lib.optionals (cfg.communication.email-client == "evolution") [
              gnome.evolution
              gnome.evolution-ews
              gnome.evolution-data-server
            ])
            ++ (lib.optionals (cfg.communication.email-client == "kmail") [
              kmail
              kmail-account-wizard
            ])
            ++
            # Messaging applications
            (lib.optionals cfg.communication.messaging.teams [
              teams-for-linux
            ])
            ++ (lib.optionals cfg.communication.messaging.slack [
              slack
            ])
            ++ (lib.optionals cfg.communication.messaging.element [
              element-desktop
            ])
            ++ (lib.optionals cfg.communication.messaging.signal [
              signal-desktop
            ])
            ++
            # VoIP applications
            (lib.optionals cfg.communication.voip.zoom [
              zoom-us
            ])
            ++ (lib.optionals cfg.communication.voip.skype [
              skypeforlinux
            ]);

          # Thunderbird enterprise configuration
          environment.etc."thunderbird/policies/policies.json" = lib.mkIf (cfg.communication.email-client == "thunderbird") {
            text = builtins.toJSON {
              policies = {
                DisableAppUpdate = true;
                DisableTelemetry = true;
                DisableFirefoxStudies = true;
                DontCheckDefaultClient = true;

                Preferences = {
                  "mail.spam.version" = 1;
                  "mail.phishing.detection.enabled" = true;
                  "mailnews.message_display.disable_remote_image" = true;
                  "security.tls.version.min" = 3;
                  "security.tls.version.max" = 4;
                };

                Certificates = {
                  ImportEnterpriseRoots = true;
                };
              };
            };
          };
        })

        # Development tools
        (lib.mkIf cfg.development.enable {
          environment.systemPackages = with pkgs;
          # IDEs
            (lib.optionals cfg.development.ides.vscode [
              vscode
              vscode-extensions.ms-vscode.cpptools
              vscode-extensions.ms-python.python
              vscode-extensions.ms-vscode.vscode-typescript-next
            ])
            ++ (lib.optionals cfg.development.ides.intellij [
              jetbrains.idea-community
            ])
            ++ (lib.optionals cfg.development.ides.eclipse [
              eclipses.eclipse-platform
            ])
            ++
            # Development tools
            (lib.optionals cfg.development.tools.git [
              git
              gitg
              git-cola
            ])
            ++ (lib.optionals cfg.development.tools.docker [
              docker
              docker-compose
            ])
            ++ (lib.optionals cfg.development.tools.kubernetes [
              kubectl
              kubernetes-helm
              k9s
            ])
            ++ (lib.optionals cfg.development.tools.terraform [
              terraform
              terraform-ls
            ])
            ++
            # Language environments
            (lib.optionals cfg.development.languages.python [
              python3
              python3Packages.pip
              python3Packages.virtualenv
            ])
            ++ (lib.optionals cfg.development.languages.nodejs [
              nodejs
              nodePackages.npm
              nodePackages.yarn
            ])
            ++ (lib.optionals cfg.development.languages.java [
              jdk11
              gradle
              maven
            ])
            ++ (lib.optionals cfg.development.languages.dotnet [
              dotnet-sdk
            ]);

          # Git enterprise configuration
          programs.git = lib.mkIf cfg.development.tools.git {
            enable = true;
            config = {
              user.name = lib.mkDefault "Enterprise Developer";
              user.email = lib.mkDefault "developer@enterprise.local";
              init.defaultBranch = "main";
              core.autocrlf = false;
              pull.rebase = true;
              push.autoSetupRemote = true;

              # Enterprise security settings
              transfer.fsckobjects = true;
              fetch.fsckobjects = true;
              receive.fsckObjects = true;

              # Signing configuration
              commit.gpgsign = true;
              tag.gpgsign = true;
            };
          };
        })

        # Security tools
        (lib.mkIf (cfg.security.password-manager != null) {
          environment.systemPackages = with pkgs;
          # Password managers
            (lib.optionals (cfg.security.password-manager == "keepassxc") [
              keepassxc
            ])
            ++ (lib.optionals (cfg.security.password-manager == "bitwarden") [
              bitwarden
            ])
            ++
            # VPN clients
            (lib.optionals (builtins.elem "openvpn" cfg.security.vpn.clients) [
              openvpn
              networkmanager-openvpn
            ])
            ++ (lib.optionals (builtins.elem "wireguard" cfg.security.vpn.clients) [
              wireguard-tools
              networkmanager-wireguard
            ])
            ++ (lib.optionals (builtins.elem "openconnect" cfg.security.vpn.clients) [
              openconnect
              networkmanager-openconnect
            ])
            ++
            # Encryption tools
            (lib.optionals cfg.security.encryption.file-encryption [
              gnupg
              pinentry-gtk2
              seahorse
            ])
            ++ (lib.optionals cfg.security.encryption.email-encryption [
              enigmail
            ]);

          # GPG configuration
          programs.gnupg.agent = lib.mkIf cfg.security.encryption.email-encryption {
            enable = true;
            enableSSHSupport = true;
            pinentryFlavor = "gtk2";
          };
        })

        # Multimedia applications
        (lib.mkIf cfg.multimedia.enable {
          environment.systemPackages = with pkgs;
          # Graphics applications
            (lib.optionals cfg.multimedia.graphics.design [
              gimp
              inkscape
              krita
            ])
            ++ (lib.optionals cfg.multimedia.graphics.photo-editing [
              darktable
              rawtherapee
            ])
            ++
            # Video applications
            (lib.optionals cfg.multimedia.video.editing [
              kdenlive
              openshot-qt
            ])
            ++ (lib.optionals cfg.multimedia.video.recording [
              obs-studio
              simplescreenrecorder
            ])
            ++
            # Audio applications
            (lib.optionals cfg.multimedia.audio.editing [
              audacity
            ])
            ++ (lib.optionals cfg.multimedia.audio.recording [
              audacity
              pavucontrol
            ])
            ++
            # Media players
            [
              vlc
              mpv
              gnome.totem
            ];
        })

        # Remote work tools
        (lib.mkIf cfg.remote-work.enable {
          environment.systemPackages = with pkgs;
          # Remote desktop clients
            (lib.optionals (builtins.elem "remmina" cfg.remote-work.remote-desktop.clients) [
              remmina
            ])
            ++ (lib.optionals (builtins.elem "vnc" cfg.remote-work.remote-desktop.clients) [
              tigervnc
              vncviewer
            ])
            ++ (lib.optionals (builtins.elem "rdp" cfg.remote-work.remote-desktop.clients) [
              freerdp
            ])
            ++
            # Cloud storage
            (lib.optionals (builtins.elem "nextcloud" cfg.remote-work.file-sync.cloud-storage) [
              nextcloud-client
            ])
            ++ (lib.optionals (builtins.elem "dropbox" cfg.remote-work.file-sync.cloud-storage) [
              dropbox
            ])
            ++
            # Time tracking
            (lib.optionals cfg.remote-work.time-tracking.enable [
              timewarrior
              toggldesktop
            ]);

          # VNC server configuration
          services.xrdp = lib.mkIf cfg.remote-work.remote-desktop.server {
            enable = true;
            defaultWindowManager = "gnome-session";
          };

          # File synchronization
          services.nextcloud-client = lib.mkIf (builtins.elem "nextcloud" cfg.remote-work.file-sync.cloud-storage) {
            enable = true;
          };
        })

        # Enterprise fonts
        {
          fonts.packages = with pkgs; [
            # Microsoft fonts for document compatibility
            corefonts
            vistafonts

            # Professional fonts
            liberation_ttf
            dejavu_fonts
            noto-fonts
            noto-fonts-cjk
            noto-fonts-emoji

            # Business fonts
            ubuntu_font_family
            open-sans
            roboto
            lato

            # Monospace fonts for development
            fira-code
            fira-code-symbols
            source-code-pro
            jetbrains-mono
            cascadia-code

            # Icon fonts
            font-awesome
            material-icons
          ];
        }

        # Enterprise MIME types and file associations
        {
          environment.etc."xdg/mimeapps.list".text = ''
            [Default Applications]
            application/pdf=org.gnome.Evince.desktop
            text/plain=org.gnome.gedit.desktop
            image/jpeg=org.gnome.eog.desktop
            image/png=org.gnome.eog.desktop
            application/vnd.oasis.opendocument.text=libreoffice-writer.desktop
            application/vnd.oasis.opendocument.spreadsheet=libreoffice-calc.desktop
            application/vnd.oasis.opendocument.presentation=libreoffice-impress.desktop
            application/vnd.openxmlformats-officedocument.wordprocessingml.document=libreoffice-writer.desktop
            application/vnd.openxmlformats-officedocument.spreadsheetml.sheet=libreoffice-calc.desktop
            application/vnd.openxmlformats-officedocument.presentationml.presentation=libreoffice-impress.desktop
            text/html=firefox.desktop
            x-scheme-handler/http=firefox.desktop
            x-scheme-handler/https=firefox.desktop
            x-scheme-handler/mailto=${cfg.communication.email-client}.desktop

            [Added Associations]
            application/pdf=org.gnome.Evince.desktop;
            text/plain=org.gnome.gedit.desktop;
            image/jpeg=org.gnome.eog.desktop;
            image/png=org.gnome.eog.desktop;
          '';
        }
      ];

    # Desktop dependencies
    dependencies = ["core" "security"];
  }
