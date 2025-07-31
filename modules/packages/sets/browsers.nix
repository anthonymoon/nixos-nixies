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
      name = "packages-browsers";
      description = "Web browsers optimized for privacy, performance, and specialized use cases";
      category = "packages";
      options = with lib; {
        enable = mkEnableOption "browsers package set";
        mainstream = {
          enable = mkEnableOption "mainstream browsers" // {default = true;};
          firefox = {
            enable = mkEnableOption "Mozilla Firefox";
            variant = mkOption {
              type = types.enum ["stable" "beta" "nightly" "esr"];
              default = "stable";
              description = "Firefox variant to install";
            };
            hardening = mkEnableOption "Firefox privacy and security hardening";
            extensions = mkEnableOption "recommended privacy extensions";
          };
          chromium = {
            enable = mkEnableOption "Chromium browser";
            ungoogled = mkEnableOption "Ungoogled Chromium variant" // {default = true;};
            extensions = mkEnableOption "privacy-focused extensions";
            hardware-acceleration = mkEnableOption "hardware acceleration" // {default = true;};
          };
          zen-browser = {
            enable = mkEnableOption "Zen Browser (Firefox-based)" // {default = true;};
            privacy-focused = mkEnableOption "privacy-focused configuration" // {default = true;};
            performance-optimized = mkEnableOption "performance optimizations";
          };
        };
        privacy-focused = {
          enable = mkEnableOption "privacy and security focused browsers" // {default = true;};
          tor-browser = {
            enable = mkEnableOption "Tor Browser for anonymity" // {default = true;};
            security-level = mkOption {
              type = types.enum ["standard" "safer" "safest"];
              default = "safer";
              description = "Tor Browser security level";
            };
            bridges = mkEnableOption "Tor bridge configuration";
          };
          librewolf = {
            enable = mkEnableOption "LibreWolf privacy browser";
            custom-config = mkEnableOption "custom privacy configuration";
          };
          mullvad-browser = {
            enable = mkEnableOption "Mullvad Browser (Tor Browser based)";
            vpn-integration = mkEnableOption "Mullvad VPN integration";
          };
        };
        specialized = {
          enable = mkEnableOption "specialized and minimal browsers";
          qutebrowser = {
            enable = mkEnableOption "qutebrowser keyboard-driven browser" // {default = true;};
            vim-bindings = mkEnableOption "Vim-style key bindings" // {default = true;};
            ad-blocking = mkEnableOption "built-in ad blocking" // {default = true;};
            custom-config = mkEnableOption "custom configuration";
          };
          nyxt = {
            enable = mkEnableOption "Nyxt programmable browser";
            lisp-integration = mkEnableOption "Common Lisp integration";
          };
          surf = {
            enable = mkEnableOption "surf minimal WebKit browser";
            suckless-patches = mkEnableOption "suckless community patches";
          };
          luakit = mkEnableOption "Luakit fast micro-browser";
          vimb = mkEnableOption "Vimb Vim-like browser";
        };
        development = {
          enable = mkEnableOption "development and testing browsers";
          browser-sync = mkEnableOption "Browser-sync for web development";
          playwright = mkEnableOption "Playwright browser automation";
          selenium = mkEnableOption "Selenium WebDriver tools";
          headless = {
            chromium = mkEnableOption "headless Chromium for testing";
            firefox = mkEnableOption "headless Firefox for testing";
            webkit = mkEnableOption "headless WebKit engine";
          };
        };
        security-features = {
          enable = mkEnableOption "browser security enhancements" // {default = true;};
          sandboxing = mkEnableOption "enhanced browser sandboxing" // {default = true;};
          dns-over-https = mkEnableOption "DNS over HTTPS configuration";
          certificate-pinning = mkEnableOption "certificate pinning";
          content-security = mkEnableOption "content security policy enforcement";
          user-agent = {
            spoofing = mkEnableOption "user agent spoofing for privacy";
            randomization = mkEnableOption "user agent randomization";
          };
        };
        extensions = {
          enable = mkEnableOption "browser extensions and add-ons";
          privacy = {
            ublock-origin = mkEnableOption "uBlock Origin ad blocker" // {default = true;};
            privacy-badger = mkEnableOption "Privacy Badger tracker blocker";
            decentraleyes = mkEnableOption "Decentraleyes CDN protection";
            clearurls = mkEnableOption "ClearURLs tracking parameter removal";
          };
          security = {
            https-everywhere = mkEnableOption "HTTPS Everywhere";
            noscript = mkEnableOption "NoScript security extension";
            temporary-containers = mkEnableOption "Temporary Containers isolation";
          };
          productivity = {
            bitwarden = mkEnableOption "Bitwarden password manager";
            dark-reader = mkEnableOption "Dark Reader dark mode";
            tab-management = mkEnableOption "tab management extensions";
          };
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
              (lib.optionals cfg.mainstream.firefox.enable [
                (
                  if cfg.mainstream.firefox.variant == "nightly"
                  then firefox-nightly
                  else if cfg.mainstream.firefox.variant == "beta"
                  then firefox-beta
                  else if cfg.mainstream.firefox.variant == "esr"
                  then firefox-esr
                  else firefox
                )
              ])
              (lib.optionals cfg.mainstream.chromium.enable [
                (
                  if cfg.mainstream.chromium.ungoogled
                  then ungoogled-chromium
                  else chromium
                )
              ])
              (lib.optionals cfg.privacy-focused.tor-browser.enable [
                tor-browser-bundle-bin
              ])
              (lib.optionals cfg.privacy-focused.librewolf.enable [
                librewolf
              ])
              (lib.optionals cfg.specialized.qutebrowser.enable [
                qutebrowser
              ])
              (lib.optionals cfg.specialized.nyxt.enable [
                nyxt
              ])
              (lib.optionals cfg.specialized.surf.enable [
                surf
              ])
              (lib.optionals cfg.specialized.luakit [
                luakit
              ])
              (lib.optionals cfg.specialized.vimb [
                vimb
              ])
              (lib.optionals cfg.development.browser-sync [
                nodePackages.browser-sync
              ])
              (lib.optionals cfg.development.playwright [
                playwright-driver
                playwright-test
              ])
              (lib.optionals cfg.development.selenium [
                selenium-server-standalone
              ])
              [
                wget
                curl
                lynx
                w3m
              ]
            ];
          programs = lib.mkMerge [
            (lib.mkIf cfg.mainstream.firefox.enable {
              firefox = {
                enable = true;
                package =
                  if cfg.mainstream.firefox.variant == "nightly"
                  then pkgs.firefox-nightly
                  else if cfg.mainstream.firefox.variant == "beta"
                  then pkgs.firefox-beta
                  else if cfg.mainstream.firefox.variant == "esr"
                  then pkgs.firefox-esr
                  else pkgs.firefox;
                preferences = lib.mkIf cfg.mainstream.firefox.hardening {
                  "privacy.trackingprotection.enabled" = true;
                  "privacy.trackingprotection.socialtracking.enabled" = true;
                  "privacy.donottrackheader.enabled" = true;
                  "privacy.clearOnShutdown.cookies" = true;
                  "privacy.clearOnShutdown.history" = false;
                  "privacy.clearOnShutdown.formdata" = true;
                  "privacy.clearOnShutdown.downloads" = true;
                  "privacy.clearOnShutdown.sessions" = true;
                  "security.tls.version.min" = 3;
                  "security.ssl.require_safe_negotiation" = true;
                  "security.ssl3.rsa_seed_sha" = true;
                  "toolkit.telemetry.enabled" = false;
                  "toolkit.telemetry.archive.enabled" = false;
                  "toolkit.telemetry.unified" = false;
                  "datareporting.healthreport.uploadEnabled" = false;
                  "datareporting.policy.dataSubmissionEnabled" = false;
                  "webgl.disabled" = false;
                  "webgl.min_capability_mode" = true;
                  "webgl.disable-extensions" = true;
                  "browser.contentblocking.category" = "strict";
                  "privacy.annotate_channels.strict_list.enabled" = true;
                };
              };
            })
            (lib.mkIf cfg.mainstream.chromium.enable {
              chromium = {
                enable = true;
                package =
                  if cfg.mainstream.chromium.ungoogled
                  then pkgs.ungoogled-chromium
                  else pkgs.chromium;
                commandLineArgs = lib.flatten [
                  "--disable-background-networking"
                  "--disable-default-apps"
                  "--disable-extensions-http-throttling"
                  "--disable-preconnect"
                  "--no-default-browser-check"
                  "--no-first-run"
                  "--disable-client-side-phishing-detection"
                  "--disable-component-update"
                  "--disable-domain-reliability"
                  "--disable-background-timer-throttling"
                  "--disable-renderer-backgrounding"
                  "--disable-backgrounding-occluded-windows"
                  "--disable-ipc-flooding-protection"
                  (lib.optionals cfg.mainstream.chromium.hardware-acceleration [
                    "--enable-features=VaapiVideoDecoder,VaapiVideoEncoder"
                    "--disable-features=UseChromeOSDirectVideoDecoder"
                    "--enable-zero-copy"
                  ])
                  "--ozone-platform-hint=auto"
                  "--enable-features=UseOzonePlatform"
                ];
                extensions = lib.optionals cfg.extensions.privacy.ublock-origin [
                  {id = "cjpalhdlnbpafiamejdnhcphjbkeiagm";}
                ];
              };
            })
          ];
          environment.variables = lib.mkMerge [
            {
              BROWSER =
                if cfg.mainstream.firefox.enable
                then "firefox"
                else if cfg.mainstream.chromium.enable
                then "chromium"
                else if cfg.specialized.qutebrowser.enable
                then "qutebrowser"
                else "firefox";
            }
            (lib.mkIf cfg.mainstream.firefox.enable {
              MOZ_ENABLE_WAYLAND = "1";
              MOZ_USE_XINPUT2 = "1";
              MOZ_DBUS_REMOTE = "1";
            })
            (lib.mkIf cfg.mainstream.chromium.hardware-acceleration {
              VDPAU_DRIVER = "va_gl";
              LIBVA_DRIVER_NAME = "iHD";
            })
            (lib.mkIf cfg.security-features.dns-over-https {
              BROWSER_DNS_OVER_HTTPS = "1";
            })
          ];
          security = {
            apparmor = lib.mkIf cfg.security-features.sandboxing {
              packages = with pkgs; [
                apparmor-profiles
              ];
            };
          };
          networking = {
            nameservers =
              lib.mkIf cfg.security-features.dns-over-https [
                "1.1.1.1
  "
                1.0
                .0
                .1
                "8.8.8.8
  "
                8.8
                .4
                .4
              ];
            firewall = lib.mkIf cfg.privacy-focused.tor-browser.enable {
              allowedTCPPorts = [];
              allowedUDPPorts = [];
            };
          };
          services = lib.mkMerge [
            (lib.mkIf cfg.privacy-focused.tor-browser.enable {
              tor = {
                enable = true;
                client.enable = true;
                settings = {
                  SocksPort = 9050;
                  ControlPort = 9051;
                  CookieAuthentication = true;
                };
              };
            })
            (lib.mkIf cfg.security-features.dns-over-https {
              resolved = {
                enable = true;
                dns = ["1.1.1.1" "1.0.0.1"];
                fallbackDns = ["1.0.0.1" "8.8.4.4"];
                domains = ["~."];
                dnssec = "true";
                dnsOverTls = "true";
              };
            })
          ];
          fonts.packages = with pkgs; [
            liberation_ttf
            dejavu_fonts
            source-sans-pro
            source-serif-pro
            font-awesome
            material-icons
            noto-fonts-emoji
            twitter-color-emoji
          ];
          xdg.mime = {
            enable = true;
            defaultApplications = {
              "text/html" =
                if cfg.mainstream.firefox.enable
                then "firefox.desktop"
                else if cfg.mainstream.chromium.enable
                then "chromium.desktop"
                else if cfg.specialized.qutebrowser.enable
                then "org.qutebrowser.qutebrowser.desktop"
                else "firefox.desktop";
              "application/xhtml+xml" =
                if cfg.mainstream.firefox.enable
                then "firefox.desktop"
                else if cfg.mainstream.chromium.enable
                then "chromium.desktop"
                else "firefox.desktop";
              "x-scheme-handler/http" =
                if cfg.mainstream.firefox.enable
                then "firefox.desktop"
                else if cfg.mainstream.chromium.enable
                then "chromium.desktop"
                else "firefox.desktop";
              "x-scheme-handler/https" =
                if cfg.mainstream.firefox.enable
                then "firefox.desktop"
                else if cfg.mainstream.chromium.enable
                then "chromium.desktop"
                else "firefox.desktop";
            };
          };
        };
      dependencies = ["core" "desktop"];
    }) {
    inherit config lib pkgs inputs;
  }
