{
  config,
  lib,
  pkgs,
  inputs,
  ...
}: let
  unified-lib = config.unified-lib or (import ../../../lib {inherit inputs lib;});
in
  unified-lib.mkUnifiedModule {
    name = "packages-core";
    description = "Core development and productivity packages essential for any modern system";
    category = "packages";

    options = with lib; {
      enable = mkEnableOption "core package set";

      # Core categories
      development = {
        enable = mkEnableOption "development tools" // {default = true;};

        git = {
          enable = mkEnableOption "Git version control system" // {default = true;};
          gui-tools = mkEnableOption "Git GUI tools and integrations";
          lfs = mkEnableOption "Git Large File Storage support";
        };

        editors = {
          vscode-insiders = mkEnableOption "Visual Studio Code Insiders (bleeding-edge)";
          zed = mkEnableOption "Zed high-performance code editor";
          neovim = mkEnableOption "Neovim modern Vim-based editor" // {default = true;};

          plugins = {
            language-servers = mkEnableOption "Language Server Protocol (LSP) support" // {default = true;};
            syntax-highlighting = mkEnableOption "Enhanced syntax highlighting";
            auto-completion = mkEnableOption "Intelligent auto-completion";
          };
        };
      };

      browsers = {
        enable = mkEnableOption "core web browsers" // {default = true;};

        thorium = {
          enable = mkEnableOption "Thorium high-performance Chromium-based browser";
          optimizations = mkEnableOption "Thorium performance optimizations" // {default = true;};
        };
      };

      shells = {
        enable = mkEnableOption "modern shell environments" // {default = true;};

        zsh = {
          enable = mkEnableOption "Z Shell with modern features";
          oh-my-zsh = mkEnableOption "Oh My Zsh framework";
          powerlevel10k = mkEnableOption "Powerlevel10k theme";
          plugins = mkEnableOption "Essential Zsh plugins" // {default = true;};
        };

        fish = {
          enable = mkEnableOption "Fish shell with smart defaults";
          plugins = mkEnableOption "Fish plugins and themes";
        };
      };

      utilities = {
        enable = mkEnableOption "essential system utilities" // {default = true;};

        modern-alternatives = mkEnableOption "modern alternatives to classic Unix tools" // {default = true;};
        file-management = mkEnableOption "advanced file management tools";
        network-tools = mkEnableOption "network diagnostic and management tools";
        system-monitoring = mkEnableOption "system monitoring and performance tools";
      };

      # Package resolution
      versions = {
        prefer-latest = mkEnableOption "prefer latest/bleeding-edge versions";
        prefer-stable = mkEnableOption "prefer stable releases for reliability";
        mixed-strategy = mkEnableOption "smart version selection based on package maturity" // {default = true;};
      };
    };

    config = {
      cfg,
      config,
      lib,
      pkgs,
    }:
      lib.mkIf cfg.enable {
        # Core development packages
        environment.systemPackages = with pkgs;
          lib.flatten [
            # Version control
            (lib.optionals cfg.development.git.enable [
              git
              git-absorb
              git-branchless
              difftastic
              delta
            ])

            (lib.optionals cfg.development.git.gui-tools [
              gitui
              lazygit
              gitg
              git-cola
            ])

            (lib.optionals cfg.development.git.lfs [
              git-lfs
            ])

            # Code editors
            (lib.optionals cfg.development.editors.vscode-insiders [
              vscode-insiders
              # VS Code extensions via nixpkgs when available
            ])

            (lib.optionals cfg.development.editors.zed [
              zed-editor
            ])

            (lib.optionals cfg.development.editors.neovim [
              neovim
              neovim-remote
              tree-sitter
            ])

            # Language servers (if enabled)
            (lib.optionals cfg.development.editors.plugins.language-servers [
              # Universal language servers
              nil # Nix LSP
              nodePackages.typescript-language-server
              nodePackages.vscode-langservers-extracted # HTML, CSS, JSON, ESLint
              rust-analyzer
              gopls
              python3Packages.python-lsp-server
              lua-language-server
              yaml-language-server
              marksman # Markdown LSP
            ])

            # Browsers
            (lib.optionals cfg.browsers.thorium.enable [
              # Note: Thorium might need to be built from source or available in nixpkgs-unstable
              # Fallback to chromium with optimizations
              (chromium.override {
                enableWideVine = true;
                commandLineArgs = lib.optionals cfg.browsers.thorium.optimizations [
                  "--enable-features=VaapiVideoDecoder,VaapiVideoEncoder"
                  "--disable-features=UseChromeOSDirectVideoDecoder"
                  "--ozone-platform-hint=auto"
                  "--enable-zero-copy"
                ];
              })
            ])

            # Shell environments
            (lib.optionals cfg.shells.zsh.enable [
              zsh
              zsh-completions
              zsh-autosuggestions
              zsh-syntax-highlighting
              zsh-history-substring-search
            ])

            (lib.optionals cfg.shells.zsh.oh-my-zsh [
              oh-my-zsh
            ])

            (lib.optionals cfg.shells.zsh.powerlevel10k [
              zsh-powerlevel10k
            ])

            (lib.optionals cfg.shells.fish.enable [
              fish
              fishPlugins.done
              fishPlugins.fzf-fish
              fishPlugins.forgit
              fishPlugins.hydro
            ])

            # Essential utilities
            (lib.optionals cfg.utilities.enable [
              # Core utilities
              curl
              wget
              rsync
              unzip
              zip
              p7zip

              # Text processing
              jq
              yq
              ripgrep
              fd

              # System info
              neofetch
              htop
              btop
            ])

            # Modern alternatives to classic tools
            (lib.optionals cfg.utilities.modern-alternatives [
              # Better alternatives to classic Unix tools
              exa # ls replacement
              bat # cat replacement
              dust # du replacement
              tokei # loc counter
              hyperfine # benchmarking
              procs # ps replacement
              bottom # top replacement
              zoxide # cd replacement
              starship # shell prompt
              lsd # ls replacement (alternative to exa)
              choose # cut replacement
              sd # sed replacement
              grex # regex generator
            ])

            # File management
            (lib.optionals cfg.utilities.file-management [
              ranger
              nnn
              broot
              fzf
              skim
              lf
            ])

            # Network tools
            (lib.optionals cfg.utilities.network-tools [
              dog # dig replacement
              gping # ping with graph
              bandwhich # network monitor
              httpie
              aria2
            ])

            # System monitoring
            (lib.optionals cfg.utilities.system-monitoring [
              lm_sensors
              pciutils
              usbutils
              dmidecode
              lshw
              hwinfo
              smartmontools
            ])
          ];

        # Shell configuration
        programs = lib.mkMerge [
          (lib.mkIf cfg.shells.zsh.enable {
            zsh = {
              enable = true;
              enableCompletion = true;
              autosuggestions.enable = true;
              syntaxHighlighting.enable = true;
              histSize = 10000;

              shellAliases = {
                # Git aliases
                g = "git";
                ga = "git add";
                gc = "git commit";
                gp = "git push";
                gl = "git pull";
                gs = "git status";
                gd = "git diff";

                # Modern tool aliases
                ls = lib.mkIf cfg.utilities.modern-alternatives "exa --icons";
                ll = lib.mkIf cfg.utilities.modern-alternatives "exa --icons -la";
                cat = lib.mkIf cfg.utilities.modern-alternatives "bat";
                find = lib.mkIf cfg.utilities.modern-alternatives "fd";
                grep = lib.mkIf cfg.utilities.modern-alternatives "rg";
                ps = lib.mkIf cfg.utilities.modern-alternatives "procs";
                top = lib.mkIf cfg.utilities.modern-alternatives "btop";

                # System aliases
                update = "sudo nixos-rebuild switch";
                upgrade = "sudo nixos-rebuild switch --upgrade";
                cleanup = "sudo nix-collect-garbage -d";
              };

              ohMyZsh = lib.mkIf cfg.shells.zsh.oh-my-zsh {
                enable = true;
                plugins = ["git" "sudo" "docker" "kubectl" "rust" "node"];
                theme = lib.mkIf cfg.shells.zsh.powerlevel10k "powerlevel10k";
              };
            };
          })

          (lib.mkIf cfg.shells.fish.enable {
            fish = {
              enable = true;
              shellAliases = {
                # Git aliases
                g = "git";
                ga = "git add";
                gc = "git commit";
                gp = "git push";
                gl = "git pull";
                gs = "git status";
                gd = "git diff";

                # Modern tool aliases
                ls = lib.mkIf cfg.utilities.modern-alternatives "exa --icons";
                ll = lib.mkIf cfg.utilities.modern-alternatives "exa --icons -la";
                cat = lib.mkIf cfg.utilities.modern-alternatives "bat";
                find = lib.mkIf cfg.utilities.modern-alternatives "fd";
                grep = lib.mkIf cfg.utilities.modern-alternatives "rg";

                # System aliases
                update = "sudo nixos-rebuild switch";
                upgrade = "sudo nixos-rebuild switch --upgrade";
                cleanup = "sudo nix-collect-garbage -d";
              };
            };
          })

          # FZF integration
          (lib.mkIf cfg.utilities.file-management {
            fzf = {
              enable = true;
              enableZshIntegration = cfg.shells.zsh.enable;
              enableFishIntegration = cfg.shells.fish.enable;
              defaultCommand = lib.mkIf cfg.utilities.modern-alternatives "fd --type f";
              defaultOptions = ["--height 40%" "--border"];
            };
          })

          # Starship prompt
          (lib.mkIf cfg.utilities.modern-alternatives {
            starship = {
              enable = true;
              enableZshIntegration = cfg.shells.zsh.enable;
              enableFishIntegration = cfg.shells.fish.enable;
            };
          })

          # Direnv for automatic environment loading
          (lib.mkIf cfg.development.enable {
            direnv = {
              enable = true;
              enableZshIntegration = cfg.shells.zsh.enable;
              enableFishIntegration = cfg.shells.fish.enable;
              nix-direnv.enable = true;
            };
          })
        ];

        # Development environment variables
        environment.variables = lib.mkIf cfg.development.enable {
          # Editor preferences
          EDITOR = lib.mkIf cfg.development.editors.neovim "nvim";
          VISUAL = lib.mkIf cfg.development.editors.neovim "nvim";

          # Git configuration
          GIT_EDITOR = lib.mkIf cfg.development.editors.neovim "nvim";

          # Development tools
          PAGER = lib.mkIf cfg.utilities.modern-alternatives "bat";
          MANPAGER = lib.mkIf cfg.utilities.modern-alternatives "sh -c 'col -bx | bat -l man -p'";
        };

        # Font configuration for development
        fonts.packages = with pkgs; [
          # Programming fonts
          source-code-pro
          fira-code
          jetbrains-mono
          victor-mono
          cascadia-code

          # Icon fonts for terminal
          font-awesome
          material-icons

          # Nerd fonts for powerline/starship
          (nerdfonts.override {fonts = ["FiraCode" "JetBrainsMono" "SourceCodePro"];})
        ];

        # User shell configuration
        users.defaultUserShell = lib.mkIf cfg.shells.zsh.enable pkgs.zsh;

        # Environment setup for modern tools
        environment.shellInit = lib.mkIf cfg.utilities.modern-alternatives ''
          # Initialize modern tools
          ${lib.optionalString cfg.utilities.file-management "eval \"$(zoxide init bash)\""}
          ${lib.optionalString cfg.utilities.modern-alternatives "eval \"$(starship init bash)\""}
        '';
      };

    # Dependencies
    dependencies = ["core"];
  }
