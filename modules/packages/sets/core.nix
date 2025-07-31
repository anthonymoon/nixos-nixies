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
    name = "packages-core";
    description = "Core development and productivity packages essential for any modern system";
    category = "packages";
    options = with lib; {
      enable = mkEnableOption "core package set";
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
        environment.systemPackages = with pkgs;
          lib.flatten [
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
            (lib.optionals cfg.development.editors.vscode-insiders [
              vscode-insiders
            ])
            (lib.optionals cfg.development.editors.zed [
              zed-editor
            ])
            (lib.optionals cfg.development.editors.neovim [
              neovim
              neovim-remote
              tree-sitter
            ])
            (lib.optionals cfg.development.editors.plugins.language-servers [
              nil
              nodePackages.typescript-language-server
              nodePackages.vscode-langservers-extracted
              rust-analyzer
              gopls
              python3Packages.python-lsp-server
              lua-language-server
              yaml-language-server
              marksman
            ])
            (lib.optionals cfg.browsers.thorium.enable [
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
            (lib.optionals cfg.utilities.enable [
              curl
              wget
              rsync
              unzip
              zip
              p7zip
              jq
              yq
              ripgrep
              fd
              neofetch
              htop
              btop
            ])
            (lib.optionals cfg.utilities.modern-alternatives [
              exa
              bat
              dust
              tokei
              hyperfine
              procs
              bottom
              zoxide
              starship
              lsd
              choose
              sd
              grex
            ])
            (lib.optionals cfg.utilities.file-management [
              ranger
              nnn
              broot
              fzf
              skim
              lf
            ])
            (lib.optionals cfg.utilities.network-tools [
              dog
              gping
              bandwhich
              httpie
              aria2
            ])
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
        programs = lib.mkMerge [
          (lib.mkIf cfg.shells.zsh.enable {
            zsh = {
              enable = true;
              completion.enable = true;
              autosuggestions.enable = true;
              syntaxHighlighting.enable = true;
              histSize = 10000;
              shellAliases = {
                g = "git";
                ga = "git add";
                gc = "git commit";
                gp = "git push";
                gl = "git pull";
                gs = "git status";
                gd = "git diff";
                ls = lib.mkIf cfg.utilities.modern-alternatives "exa --icons";
                ll = lib.mkIf cfg.utilities.modern-alternatives "exa --icons -la";
                cat = lib.mkIf cfg.utilities.modern-alternatives "bat";
                find = lib.mkIf cfg.utilities.modern-alternatives "fd";
                grep = lib.mkIf cfg.utilities.modern-alternatives "rg";
                ps = lib.mkIf cfg.utilities.modern-alternatives "procs";
                top = lib.mkIf cfg.utilities.modern-alternatives "btop";
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
                g = "git";
                ga = "git add";
                gc = "git commit";
                gp = "git push";
                gl = "git pull";
                gs = "git status";
                gd = "git diff";
                ls = lib.mkIf cfg.utilities.modern-alternatives "exa --icons";
                ll = lib.mkIf cfg.utilities.modern-alternatives "exa --icons -la";
                cat = lib.mkIf cfg.utilities.modern-alternatives "bat";
                find = lib.mkIf cfg.utilities.modern-alternatives "fd";
                grep = lib.mkIf cfg.utilities.modern-alternatives "rg";
                update = "sudo nixos-rebuild switch";
                upgrade = "sudo nixos-rebuild switch --upgrade";
                cleanup = "sudo nix-collect-garbage -d";
              };
            };
          })
          (lib.mkIf cfg.utilities.file-management {
            fzf = {
              enable = true;
              enableZshIntegration = cfg.shells.zsh.enable;
              enableFishIntegration = cfg.shells.fish.enable;
              defaultCommand = lib.mkIf cfg.utilities.modern-alternatives "fd --type f";
              defaultOptions = ["--height 40%" "--border"];
            };
          })
          (lib.mkIf cfg.utilities.modern-alternatives {
            starship = {
              enable = true;
              enableZshIntegration = cfg.shells.zsh.enable;
              enableFishIntegration = cfg.shells.fish.enable;
            };
          })
          (lib.mkIf cfg.development.enable {
            direnv = {
              enable = true;
              enableZshIntegration = cfg.shells.zsh.enable;
              enableFishIntegration = cfg.shells.fish.enable;
              nix-direnv.enable = true;
            };
          })
        ];
        environment.variables = lib.mkIf cfg.development.enable {
          EDITOR = lib.mkIf cfg.development.editors.neovim "nvim";
          VISUAL = lib.mkIf cfg.development.editors.neovim "nvim";
          GIT_EDITOR = lib.mkIf cfg.development.editors.neovim "nvim";
          PAGER = lib.mkIf cfg.utilities.modern-alternatives "bat";
          MANPAGER = lib.mkIf cfg.utilities.modern-alternatives "sh -c 'col -bx | bat -l man -p'";
        };
        fonts.packages = with pkgs; [
          source-code-pro
          fira-code
          jetbrains-mono
          victor-mono
          cascadia-code
          font-awesome
          material-icons
          (nerdfonts.override {fonts = ["FiraCode" "JetBrainsMono" "SourceCodePro"];})
        ];
        users.defaultUserShell = lib.mkIf cfg.shells.zsh.enable pkgs.zsh;
        environment.shellInit = lib.mkIf cfg.utilities.modern-alternatives ''
          ${lib.optionalString cfg.utilities.file-management "eval \"$(zoxide init bash)\""}
          ${lib.optionalString cfg.utilities.modern-alternatives "eval \"$(starship init bash)\""}
        '';
      };
    dependencies = ["core"];
  }) {
    inherit config lib pkgs inputs;
  }
