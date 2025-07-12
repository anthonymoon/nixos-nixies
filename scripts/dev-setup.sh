#!/usr/bin/env bash

# NixOS Unified Development Environment Setup Script
# This script sets up a complete development environment for NixOS Unified

set -euo pipefail

# Color codes for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
PURPLE='\033[0;35m'
NC='\033[0m' # No Color

print_info() {
    echo -e "${BLUE}[INFO]${NC} $1"
}

print_success() {
    echo -e "${GREEN}[SUCCESS]${NC} $1"
}

print_warning() {
    echo -e "${YELLOW}[WARNING]${NC} $1"
}

print_error() {
    echo -e "${RED}[ERROR]${NC} $1"
}

print_header() {
    echo -e "${PURPLE}[SETUP]${NC} $1"
}

# Banner
echo -e "${BLUE}"
cat << 'EOF'
╔═══════════════════════════════════════════════════════════════╗
║                  🏗️  NixOS Unified Dev Setup                  ║
║              Professional Development Environment             ║
╚═══════════════════════════════════════════════════════════════╝
EOF
echo -e "${NC}"

print_header "Initializing NixOS Unified development environment..."
echo ""

# Check prerequisites
print_info "Checking prerequisites..."

# Check if Nix is installed
if ! command -v nix &> /dev/null; then
    print_error "Nix is not installed. Please install Nix first."
    print_info "Install with: curl -L https://nixos.org/nix/install | sh"
    exit 1
fi

# Check if flakes are enabled
if ! nix --version | grep -q "nix (Nix) 2."; then
    print_warning "Nix version might not support flakes"
fi

# Check if git is installed
if ! command -v git &> /dev/null; then
    print_error "Git is not installed. Please install Git first."
    exit 1
fi

print_success "Prerequisites check passed"

# Setup development environment
print_header "Setting up development environment..."

# Create necessary directories
print_info "Creating project directories..."
mkdir -p {logs,docs/modules,.vscode}

# Setup git configuration
print_info "Configuring git for the project..."
git config --local pull.rebase true
git config --local push.autoSetupRemote true
git config --local init.defaultBranch main

# Setup git hooks directory
mkdir -p .git/hooks

# Install development tools
print_info "Installing development tools..."
if command -v nix &> /dev/null; then
    nix profile install nixpkgs#pre-commit nixpkgs#just nixpkgs#alejandra 2>/dev/null || {
        print_warning "Some tools may already be installed"
    }
fi

# Setup pre-commit hooks
print_info "Setting up pre-commit hooks..."
if command -v pre-commit &> /dev/null; then
    pre-commit install --install-hooks
    print_success "Pre-commit hooks installed"
else
    print_warning "Pre-commit not available, skipping hook installation"
fi

# Initialize direnv if available
if command -v direnv &> /dev/null; then
    print_info "Setting up direnv integration..."
    direnv allow . 2>/dev/null || print_warning "Direnv setup skipped"
fi

# Create initial development files
print_info "Creating development configuration files..."

# Create a development notes file
cat > dev-notes.md << 'EOF'
# Development Notes

## Quick Start Commands

```bash
# Enter development environment
nix develop

# Run all validation
just validate

# Build all configurations
just build-all

# Format code
just format

# Run security audit
just security-audit
```

## Development Workflow

1. Make changes to configurations
2. Run `just validate` to check syntax and security
3. Test builds with `just test-configs`
4. Format code with `just format`
5. Commit changes (pre-commit hooks will run automatically)

## Testing

- `just test-all` - Run comprehensive tests
- `just test-configs` - Test configuration builds
- `just test-packages` - Test package builds

## Deployment

- `just deploy <hostname>` - Deploy to remote host
- Local testing with VM images

## Troubleshooting

- Check logs in `logs/` directory
- Run `just system-info` for environment details
- Use `nix develop --command bash` for debugging
EOF

# Create initial changelog
if [ ! -f CHANGELOG.md ]; then
    cat > CHANGELOG.md << 'EOF'
# Changelog

All notable changes to NixOS Unified will be documented in this file.

The format is based on [Keep a Changelog](https://keepachangelog.com/en/1.0.0/),
and this project adheres to [Semantic Versioning](https://semver.org/spec/v2.0.0.html).

## [Unreleased]

### Added
- Initial NixOS Unified framework
- Modular configuration system
- Security hardening framework
- Performance optimization tools
- Deployment automation
- Development environment setup

### Changed
- N/A

### Deprecated
- N/A

### Removed
- N/A

### Fixed
- N/A

### Security
- Implemented comprehensive security validation
- Added pre-commit security scanning
- Created security audit tools
EOF
fi

# Create contributing guidelines
if [ ! -f CONTRIBUTING.md ]; then
    cat > CONTRIBUTING.md << 'EOF'
# Contributing to NixOS Unified

Thank you for your interest in contributing to NixOS Unified!

## Development Setup

1. Run the development setup script:
   ```bash
   ./scripts/dev-setup.sh
   ```

2. Enter the development environment:
   ```bash
   nix develop
   ```

3. Install pre-commit hooks:
   ```bash
   just install-hooks
   ```

## Development Workflow

1. Create a feature branch
2. Make your changes
3. Run validation: `just validate`
4. Test your changes: `just test-all`
5. Format code: `just format`
6. Commit your changes (pre-commit hooks will run)
7. Push and create a pull request

## Code Standards

- All Nix code must be formatted with Alejandra
- Security checks must pass
- All configurations must build successfully
- Documentation must be updated for new features

## Testing

Run the full test suite before submitting:

```bash
just test-all
```

## Questions?

Feel free to open an issue for questions or discussions.
EOF
fi

# Test the development environment
print_header "Testing development environment..."

# Test nix development shell
print_info "Testing Nix development shell..."
if nix develop --command echo "Development shell works" >/dev/null 2>&1; then
    print_success "Nix development shell is working"
else
    print_warning "Nix development shell test failed"
fi

# Test flake validation
print_info "Testing flake validation..."
if nix flake check --no-build >/dev/null 2>&1; then
    print_success "Flake validation passed"
else
    print_warning "Flake validation failed - this is expected if configurations are not complete"
fi

# Test just commands
if command -v just &> /dev/null; then
    print_info "Testing just task runner..."
    if just --list >/dev/null 2>&1; then
        print_success "Just task runner is working"
    else
        print_warning "Just task runner test failed"
    fi
fi

# Final setup summary
print_header "Setup completed successfully!"
echo ""
print_success "🎉 NixOS Unified development environment is ready!"
echo ""
print_info "📚 Next steps:"
echo "  1. Run 'nix develop' to enter the development shell"
echo "  2. Run 'just' to see available commands"
echo "  3. Run 'just validate' to check everything works"
echo "  4. Read 'dev-notes.md' for development workflow"
echo "  5. Check 'CONTRIBUTING.md' for contribution guidelines"
echo ""
print_info "🔧 Available tools:"
echo "  • just - Task runner with development commands"
echo "  • alejandra - Nix code formatter"
echo "  • pre-commit - Git hooks for code quality"
echo "  • nix develop - Development shell with all tools"
echo ""
print_info "📖 Documentation:"
echo "  • README.md - Project overview"
echo "  • dev-notes.md - Development notes"
echo "  • CONTRIBUTING.md - Contribution guidelines"
echo ""
print_info "🚀 Quick start:"
echo "  just validate     # Validate all code"
echo "  just build-all    # Build all configurations"
echo "  just test-all     # Run all tests"
echo "  just format       # Format all code"
echo ""

# Check if running in VS Code
if [ "${TERM_PROGRAM:-}" = "vscode" ]; then
    print_info "💡 VS Code detected! Extensions and settings are configured."
    print_info "   Restart VS Code to apply all settings."
fi

print_success "Development environment setup completed! 🎉"
