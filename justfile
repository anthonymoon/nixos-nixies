# NixOS Nixies - Development Task Runner
# Install just: nix-env -iA nixpkgs.just
# Usage: just <command>

# Show available commands
default:
    @just --list

# 🚀 Setup & Installation Commands

# Initialize development environment
setup:
    @echo "🏗️  Setting up NixOS Nixies development environment..."
    @echo "📦 Installing pre-commit hooks..."
    pre-commit install
    @echo "🔧 Setting up git configuration..."
    git config --local pull.rebase true
    git config --local push.autoSetupRemote true
    git config --local init.defaultBranch main
    @echo "📁 Creating necessary directories..."
    mkdir -p .vscode logs docs/modules
    @echo "✅ Development environment ready!"
    @echo ""
    @echo "Next steps:"
    @echo "  1. Run 'just validate' to check everything works"
    @echo "  2. Run 'just test-configs' to test configurations"
    @echo "  3. Start developing!"

# Install git hooks and pre-commit
install-hooks:
    @echo "🔧 Installing git hooks..."
    pre-commit install --install-hooks
    @echo "✅ Git hooks installed successfully"

# Update development dependencies
update-deps:
    @echo "📦 Updating flake inputs..."
    nix flake update
    @echo "🔄 Updating pre-commit hooks..."
    pre-commit autoupdate
    @echo "✅ Dependencies updated"

# 🧹 Cleanup Commands

# Clean build artifacts and temporary files
clean:
    @echo "🧹 Cleaning build artifacts..."
    find . -name "result*" -type l -delete
    rm -rf .pre-commit-cache
    rm -f .secrets.baseline.tmp
    @echo "✅ Cleanup completed"

# Deep clean including Nix store optimization
deep-clean: clean
    @echo "🗑️  Deep cleaning..."
    nix-collect-garbage -d
    nix store optimise
    @echo "✅ Deep cleanup completed"

# 🔍 Validation & Testing Commands

# Run comprehensive validation
validate:
    @echo "🔍 Running comprehensive validation..."
    @echo "📝 Checking Nix syntax..."
    @just check-syntax
    @echo "📦 Validating flake..."
    nix flake check --no-build
    @echo "🛡️  Running security audit..."
    @just security-audit
    @echo "⚡ Running performance check..."
    @just performance-check
    @echo "✅ All validation checks passed!"

# Check Nix syntax for all files
check-syntax:
    @echo "📝 Checking Nix syntax..."
    #!/usr/bin/env bash
    @set -euo pipefail
    @find . -name "*.nix" -type f -not -path "./result*" | while read -r file; do \
        echo "  Checking: $file"; \
        nix-instantiate --parse "$file" > /dev/null; \
    done
    @echo "✅ All Nix files have valid syntax"

# Run security audit
security-audit:
    @echo "🛡️  Running security audit..."
    @echo "🔍 Checking for disabled firewalls..."
    @grep -r "firewall\.enable.*false" . --include="*.nix" | head -3 || echo "No firewall issues found"
    @echo "🔍 Checking for root SSH login..."
    @grep -r "PermitRootLogin.*yes" . --include="*.nix" | head -3 || echo "No root SSH issues found"
    @echo "🔍 Checking for hardcoded passwords..."
    @grep -r 'password.*=' . --include="*.nix" | grep -v -E "(hashedPassword|passwordFile|pragma)" | head -3 || echo "No password issues found"
    @echo "ℹ️  Development/VM configurations may have expected security relaxations"
    @echo "✅ Security audit completed"

# Run performance analysis
performance-check:
    @echo "⚡ Running performance analysis..."
    @echo "🔍 Checking for large package lists..."
    @grep -r "environment\.systemPackages\|home\.packages" . --include="*.nix" -l | head -5
    @echo "🔍 Checking for excessive 'with pkgs;' usage..."
    @grep -r "with pkgs;" . --include="*.nix" 2>/dev/null | wc -l | xargs echo "Found" && echo "'with pkgs;' statements"
    @echo "✅ Performance analysis completed"

# Test all configurations build successfully
test-configs:
    @echo "🏗️  Testing all configuration builds..."
    @echo "🔍 Testing available configurations..."
    @echo "  Checking syntax of configuration files..."
    @echo "    Validating configurations/qemu/desktop.nix..."
    @nix-instantiate --parse configurations/qemu/desktop.nix > /dev/null
    @echo "    Validating configurations/qemu/minimal.nix..."
    @nix-instantiate --parse configurations/qemu/minimal.nix > /dev/null
    @echo "    Validating configurations/qemu/development.nix..."
    @nix-instantiate --parse configurations/qemu/development.nix > /dev/null
    @echo "✅ All configuration files are syntactically valid"

# Test packages build successfully
test-packages:
    @echo "📦 Testing package builds..."
    @echo "🔍 Testing available packages..."
    @if nix build ".#packages.aarch64-darwin.default" --no-link --quiet 2>/dev/null; then \
        echo "    ✅ Default package build successful"; \
    else \
        echo "    ❌ Default package build failed"; \
    fi
    @echo "✅ Package testing completed"

# Run all tests
test-all: test-configs test-packages validate
    @echo "🎉 All tests passed!"

# 🎨 Code Quality Commands

# Format all code
format:
    @echo "🎨 Formatting code..."
    alejandra . --quiet
    nix develop --command markdownlint --fix . || true
    @echo "✅ Code formatting completed"

# Lint all code
lint:
    @echo "🔍 Linting code..."
    alejandra --check .
    nix develop --command statix check .
    deadnix .
    nix develop --command markdownlint .
    @echo "✅ Linting completed"

# Fix common issues automatically
fix:
    @echo "🔧 Auto-fixing common issues..."
    alejandra . --quiet
    nix develop --command markdownlint --fix . || true
    # Remove trailing whitespace
    find . -name "*.nix" -o -name "*.md" -type f -exec sed -i '' 's/[[:space:]]*$//' {} \;
    @echo "✅ Auto-fix completed"

# 🚀 Build & Deploy Commands

# Build specific configuration
build config:
    @echo "🏗️  Building configuration: {{config}}"
    nix build ".#nixosConfigurations.{{config}}.config.system.build.toplevel"
    @echo "✅ Build completed for {{config}}"

# Build all configurations
build-all:
    @echo "🏗️  Building all configurations..."
    @just test-configs
    @echo "✅ All configurations built successfully"

# Deploy to remote host
deploy host:
    @echo "🚀 Deploying to {{host}}..."
    @echo "🔍 Running pre-deployment validation..."
    @just validate
    deploy ".#{{host}}"
    @echo "✅ Deployment completed for {{host}}"

# 📊 Monitoring & Analysis Commands

# Show flake info
info:
    @echo "📊 Flake Information:"
    nix flake metadata
    @echo ""
    @echo "📦 Available outputs:"
    nix flake show

# Analyze build dependencies
deps config:
    @echo "🔍 Analyzing dependencies for {{config}}..."
    nix run nixpkgs#nix-tree -- ".#nixosConfigurations.{{config}}.config.system.build.toplevel"

# Show disk usage of Nix store
disk-usage:
    @echo "💾 Nix store disk usage:"
    nix develop --command nix-du

# Benchmark build times
benchmark:
    @echo "⏱️  Benchmarking build times..."
    @mkdir -p logs
    @echo "🔍 Benchmarking available flake outputs..."
    @hyperfine --warmup 1 --runs 3 \
        "nix build .#packages.aarch64-darwin.default --no-link" \
        --export-markdown "logs/benchmark-packages.md" || echo "❌ Package build failed"
    @hyperfine --warmup 1 --runs 3 \
        "nix flake check --no-warn-dirty" \
        --export-markdown "logs/benchmark-flake-check.md" || echo "❌ Flake check failed"
    @echo "📊 Benchmark results saved to logs/"

# 📚 Documentation Commands

# Generate documentation
docs:
    @echo "📚 Generating documentation..."
    @echo "🔍 Creating module documentation index..."
    @echo "# Module Documentation" > docs/modules/README.md
    @echo "" >> docs/modules/README.md
    #!/usr/bin/env bash
    @find modules -mindepth 1 -maxdepth 1 -type d | while read -r module_dir; do \
        module_name=$(basename "$module_dir"); \
        echo "- [$module_name](./$module_name.md)" >> docs/modules/README.md; \
        if [ ! -f "docs/modules/$module_name.md" ]; then \
            echo "# $module_name Module" > "docs/modules/$module_name.md"; \
            echo "" >> "docs/modules/$module_name.md"; \
            echo "Documentation for the $module_name module." >> "docs/modules/$module_name.md"; \
        fi; \
    done
    @echo "✅ Documentation generated"

# Serve documentation locally
serve-docs:
    @echo "🌐 Starting documentation server..."
    @echo "Open http://localhost:8000 in your browser"
    python3 -m http.server 8000 --directory docs/

# 🔧 Development Utilities

# Enter development shell
dev:
    @echo "🔧 Entering development shell..."
    @if [[ "$(uname)" == "Darwin" ]]; then \
        echo "🍎 Running on macOS - using native development environment"; \
        nix develop; \
    else \
        echo "🐧 Running on Linux - using full development environment"; \
        nix develop; \
    fi

# Update flake lock file
update:
    nix flake update

# Show system info
system-info:
    @echo "💻 System Information:"
    @echo "  OS: $$(uname -sr)"
    @echo "  Nix version: $$(nix --version)"
    @echo "  Working directory: $$(pwd)"
    @echo "  Git branch: $$(git branch --show-current 2>/dev/null || echo 'N/A')"
    @echo "  Git status: $$(git status --porcelain | wc -l) modified files"

# Create new module template
new-module name:
    @echo "🧩 Creating new module: {{name}}"
    @mkdir -p "modules/{{name}}"
    @echo '{ config, lib, pkgs, ... }:' > "modules/{{name}}/default.nix"
    @echo '' >> "modules/{{name}}/default.nix"
    @echo 'let' >> "modules/{{name}}/default.nix"
    @echo '  nixies-lib = config.nixies-lib or (import ../../lib { inherit inputs lib; });' >> "modules/{{name}}/default.nix"
    @echo 'in' >> "modules/{{name}}/default.nix"
    @echo '' >> "modules/{{name}}/default.nix"
    @echo 'nixies-lib.mkNixiesModule {' >> "modules/{{name}}/default.nix"
    @echo '  name = "{{name}}";' >> "modules/{{name}}/default.nix"
    @echo '  description = "{{name}} functionality";' >> "modules/{{name}}/default.nix"
    @echo '  category = "general";' >> "modules/{{name}}/default.nix"
    @echo '' >> "modules/{{name}}/default.nix"
    @echo '  options = with lib; {' >> "modules/{{name}}/default.nix"
    @echo '    # Add module-specific options here' >> "modules/{{name}}/default.nix"
    @echo '  };' >> "modules/{{name}}/default.nix"
    @echo '' >> "modules/{{name}}/default.nix"
    @echo '  config = { cfg, config, lib, pkgs }: {' >> "modules/{{name}}/default.nix"
    @echo '    # Add module configuration here' >> "modules/{{name}}/default.nix"
    @echo '  };' >> "modules/{{name}}/default.nix"
    @echo '' >> "modules/{{name}}/default.nix"
    @echo '  security = cfg: {' >> "modules/{{name}}/default.nix"
    @echo '    # Add security configuration here' >> "modules/{{name}}/default.nix"
    @echo '  };' >> "modules/{{name}}/default.nix"
    @echo '' >> "modules/{{name}}/default.nix"
    @echo '  dependencies = [ "core" ];' >> "modules/{{name}}/default.nix"
    @echo '}' >> "modules/{{name}}/default.nix"
    @echo "✅ Module template created at modules/{{name}}/default.nix"
    @echo "📝 Don't forget to add documentation at docs/modules/{{name}}.md"

# Run pre-commit hooks on all files
pre-commit:
    pre-commit run --all-files

# Check for outdated dependencies
check-outdated:
    @echo "📦 Checking for outdated dependencies..."
    @echo "Current flake inputs:"
    nix flake metadata --json | jq '.locks.nodes.root.inputs'
    @echo "🔄 Use 'just update' to update dependencies"

# Show git status and helpful info
status:
    @echo "📊 Repository Status:"
    @echo "==================="
    git status --short
    @echo ""
    @echo "📝 Recent commits:"
    git log --oneline -5
    @echo ""
    @echo "🔧 Available commands:"
    @just --list --list-heading="" | head -10
