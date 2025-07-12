# Development shell for NixOS Unified
{pkgs ? import <nixpkgs> {}}:
pkgs.mkShell {
  name = "nixos-unified-dev";

  buildInputs = with pkgs; [
    # Nix development tools
    nix
    nixpkgs-fmt
    alejandra
    nil # Nix language server
    nix-tree # Nix store analysis
    nix-du # Nix store disk usage
    statix # Nix linter
    deadnix # Dead code elimination
    nix-index # Nix package search
    nixos-rebuild # System rebuilding

    # Development tools
    git
    git-lfs
    pre-commit
    shellcheck
    shfmt # Shell formatter

    # Documentation tools
    mdbook # Documentation building
    markdownlint-cli # Markdown linting

    # Security tools
    detect-secrets # Secret detection

    # Testing and validation
    jq # JSON processing
    yq # YAML processing

    # Deployment tools
    deploy-rs # NixOS deployment

    # Code quality tools
    typos # Typo detection

    # Performance tools
    hyperfine # Benchmarking

    # Network tools (for testing)
    curl
    wget

    # System tools
    tree
    fd # Modern find
    ripgrep # Modern grep
    bat # Modern cat
    exa # Modern ls

    # Development utilities
    direnv # Environment management
    just # Command runner
  ];

  shellHook = ''
    echo "🏗️  NixOS Unified Development Environment"
    echo "======================================="
    echo ""
    echo "📦 Available tools:"
    echo "  Core:"
    echo "    nix develop          - Enter this development shell"
    echo "    nixos-rebuild        - Build and switch configurations"
    echo "    deploy-rs            - Deploy to remote systems"
    echo ""
    echo "  Development:"
    echo "    alejandra .          - Format all Nix files"
    echo "    statix check .       - Lint Nix files"
    echo "    deadnix .           - Find dead Nix code"
    echo "    nil                 - Nix language server"
    echo ""
    echo "  Quality assurance:"
    echo "    pre-commit install  - Setup pre-commit hooks"
    echo "    pre-commit run --all-files - Run all hooks"
    echo "    detect-secrets scan - Scan for secrets"
    echo "    markdownlint .      - Lint markdown files"
    echo ""
    echo "  Testing:"
    echo "    nix flake check     - Validate flake"
    echo "    nix run .#validate  - Run comprehensive validation"
    echo "    nix run .#security-audit - Security audit"
    echo "    nix run .#performance-check - Performance analysis"
    echo ""
    echo "  Building:"
    echo "    nix build .#nixosConfigurations.workstation.config.system.build.toplevel"
    echo "    nix build .#packages.x86_64-linux.installer"
    echo ""
    echo "  Local testing:"
    echo "    just test-configs   - Test all configurations"
    echo "    just test-security  - Run security tests"
    echo "    just test-performance - Run performance tests"
    echo ""
    echo "🔧 Setup commands:"
    echo "  just setup          - Initialize development environment"
    echo "  just install-hooks  - Install git hooks"
    echo "  just clean          - Clean build artifacts"
    echo ""

    # Check if pre-commit is installed
    if [ ! -f .git/hooks/pre-commit ] || [ ! -s .git/hooks/pre-commit ]; then
      echo "⚠️  Pre-commit hooks not installed. Run: just install-hooks"
    else
      echo "✅ Pre-commit hooks are installed"
    fi

    # Check for common issues
    if [ ! -f .envrc ]; then
      echo "💡 Tip: Create .envrc with 'use flake' for automatic shell activation"
    fi

    echo ""
    echo "📚 Documentation: ./README.md"
    echo "🐛 Issues: https://github.com/user/nixos-unified/issues"
    echo ""
  '';

  # Environment variables
  NIX_CONFIG = "experimental-features = nix-command flakes";

  # Git configuration for the project
  shellSetup = ''
    # Ensure git hooks directory exists
    mkdir -p .git/hooks

    # Set up git configuration for the project
    git config --local pull.rebase true
    git config --local push.autoSetupRemote true
    git config --local init.defaultBranch main

    # Configure commit template if it exists
    if [ -f .gitmessage ]; then
      git config --local commit.template .gitmessage
    fi
  '';
}
