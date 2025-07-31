{pkgs ? import <nixpkgs> {}}:
pkgs.mkShell {
  name = "nixos-nixies-dev";
  buildInputs = with pkgs; [
    nix
    nixpkgs-fmt
    alejandra
    nil
    nix-tree
    nix-du
    statix
    deadnix
    nix-index
    nixos-rebuild
    git
    git-lfs
    pre-commit
    shellcheck
    shfmt
    mdbook
    markdownlint-cli
    detect-secrets
    jq
    yq
    deploy-rs
    typos
    hyperfine
    curl
    wget
    tree
    fd
    ripgrep
    bat
    exa
    direnv
    just
  ];
  shellHook = ''
    echo "🏗️  NixOS Nixies Development Environment"
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
    echo "    nix run .
    echo "    nix run .
    echo "    nix run .
    echo ""
    echo "  Building:"
    echo "    nix build .
    echo "    nix build .
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
    if [ ! -f .git/hooks/pre-commit ] || [ ! -s .git/hooks/pre-commit ]; then
    echo "⚠️  Pre-commit hooks not installed. Run: just install-hooks"
    else
    echo "✅ Pre-commit hooks are installed"
    fi
    if [ ! -f .envrc ]; then
    echo "💡 Tip: Create .envrc with 'use flake' for automatic shell activation"
    fi
    echo ""
    echo "📚 Documentation: ./README.md"
    echo "🐛 Issues: https://github.com/amoon/nixos-nixies/issues"
    echo ""
  '';
  NIX_CONFIG = "experimental-features = nix-command flakes";
  shellSetup = ''
    mkdir -p .git/hooks
    git config --local pull.rebase true
    git config --local push.autoSetupRemote true
    git config --local init.defaultBranch main
    if [ -f .gitmessage ]; then
    git config --local commit.template .gitmessage
    fi
  '';
}
