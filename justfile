# NixOS Unified - Development Task Runner
# Install just: nix-env -iA nixpkgs.just
# Usage: just <command>

# Show available commands
default:
    @just --list

# 🚀 Setup & Installation Commands

# Initialize development environment
setup:
    @echo "🏗️  Setting up NixOS Unified development environment..."
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
    @find . -name "*.nix" -type f -not -path "./result*" | while IFS= read -r file; do \
        echo "  Checking: $$file"; \
        nix-instantiate --parse "$$file" > /dev/null || exit 1; \
    done
    @echo "✅ All Nix files have valid syntax"

# Run security audit
security-audit:
    @echo "🛡️  Running security audit..."
    @failed=0; \
    if grep -r "firewall\.enable.*false" . --include="*.nix" >/dev/null 2>&1; then \
        echo "❌ CRITICAL: Disabled firewall found!"; \
        grep -r "firewall\.enable.*false" . --include="*.nix"; \
        failed=1; \
    fi; \
    if grep -r "PermitRootLogin.*yes" . --include="*.nix" >/dev/null 2>&1; then \
        echo "❌ CRITICAL: Root SSH login enabled!"; \
        grep -r "PermitRootLogin.*yes" . --include="*.nix"; \
        failed=1; \
    fi; \
    if grep -r 'password.*=.*"[^"]*"' . --include="*.nix" | grep -v -E "(template|example|README)" >/dev/null 2>&1; then \
        echo "❌ CRITICAL: Hardcoded passwords found!"; \
        grep -r 'password.*=.*"[^"]*"' . --include="*.nix" | grep -v -E "(template|example|README)"; \
        failed=1; \
    fi; \
    if [ $$failed -eq 0 ]; then \
        echo "✅ Security audit passed"; \
    else \
        echo "❌ Security audit failed"; \
        exit 1; \
    fi

# Run performance analysis
performance-check:
    @echo "⚡ Running performance analysis..."
    @warnings=0; \
    find . -name "*.nix" -type f -exec grep -l "environment\.systemPackages\|home\.packages" {} \; | while IFS= read -r file; do \
        if [ -f "$$file" ]; then \
            count=$$(grep -c "pkgs\." "$$file" 2>/dev/null || echo 0); \
            if [ "$$count" -gt 50 ]; then \
                echo "⚠️  Large package list in $$file: $$count packages"; \
                warnings=$$((warnings + 1)); \
            fi; \
        fi; \
    done; \
    with_pkgs_count=$$(grep -r "with pkgs;" . --include="*.nix" 2>/dev/null | wc -l || echo 0); \
    if [ "$$with_pkgs_count" -gt 15 ]; then \
        echo "⚠️  Many 'with pkgs;' statements ($$with_pkgs_count) - consider package sets"; \
        warnings=$$((warnings + 1)); \
    fi; \
    echo "📊 Performance warnings: $$warnings"; \
    echo "✅ Performance analysis completed"

# Test all configurations build successfully
test-configs:
    @echo "🏗️  Testing all configuration builds..."
    @configs="workstation server development base gaming"; \
    for config in $$configs; do \
        echo "  Building nixosConfiguration.$$config..."; \
        if nix build ".#nixosConfigurations.$$config.config.system.build.toplevel" --no-link --quiet; then \
            echo "    ✅ $$config build successful"; \
        else \
            echo "    ❌ $$config build failed"; \
            exit 1; \
        fi; \
    done; \
    echo "✅ All configurations build successfully"

# Test packages build successfully
test-packages:
    @echo "📦 Testing package builds..."
    @packages="installer security-audit performance-benchmark migration-helper"; \
    for package in $$packages; do \
        echo "  Building package.$$package..."; \
        if nix build ".#packages.x86_64-linux.$$package" --no-link --quiet; then \
            echo "    ✅ $$package build successful"; \
        else \
            echo "    ❌ $$package build failed"; \
            exit 1; \
        fi; \
    done; \
    echo "✅ All packages build successfully"

# Run all tests
test-all: test-configs test-packages validate
    @echo "🎉 All tests passed!"

# 🎨 Code Quality Commands

# Format all code
format:
    @echo "🎨 Formatting code..."
    alejandra . --quiet
    markdownlint --fix . || true
    @echo "✅ Code formatting completed"

# Lint all code
lint:
    @echo "🔍 Linting code..."
    alejandra --check .
    statix check .
    deadnix .
    markdownlint .
    @echo "✅ Linting completed"

# Fix common issues automatically
fix:
    @echo "🔧 Auto-fixing common issues..."
    alejandra . --quiet
    markdownlint --fix . || true
    # Remove trailing whitespace
    find . -name "*.nix" -o -name "*.md" -type f -exec sed -i 's/[[:space:]]*$//' {} \;
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
    nix-tree ".#nixosConfigurations.{{config}}.config.system.build.toplevel"

# Show disk usage of Nix store
disk-usage:
    @echo "💾 Nix store disk usage:"
    nix-du

# Benchmark build times
benchmark:
    @echo "⏱️  Benchmarking build times..."
    @configs="workstation server development"; \
    for config in $$configs; do \
        echo "Benchmarking $$config..."; \
        hyperfine --warmup 1 --runs 3 \
            "nix build .#nixosConfigurations.$$config.config.system.build.toplevel --no-link" \
            --export-markdown "logs/benchmark-$$config.md"; \
    done; \
    echo "📊 Benchmark results saved to logs/"

# 📚 Documentation Commands

# Generate documentation
docs:
    @echo "📚 Generating documentation..."
    @echo "🔍 Creating module documentation index..."
    @echo "# Module Documentation" > docs/modules/README.md
    @echo "" >> docs/modules/README.md
    @find modules -mindepth 1 -maxdepth 1 -type d | while IFS= read -r module_dir; do \
        module_name=$$(basename "$$module_dir"); \
        echo "- [$$module_name](./$$module_name.md)" >> docs/modules/README.md; \
        if [ ! -f "docs/modules/$$module_name.md" ]; then \
            echo "# $$module_name Module" > "docs/modules/$$module_name.md"; \
            echo "" >> "docs/modules/$$module_name.md"; \
            echo "Documentation for the $$module_name module." >> "docs/modules/$$module_name.md"; \
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
    nix develop

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
    @cat > "modules/{{name}}/default.nix" << 'EOF'
    { config, lib, pkgs, ... }:

    let
      unified-lib = config.unified-lib or (import ../../lib { inherit inputs lib; });
    in

    unified-lib.mkUnifiedModule {
      name = "{{name}}";
      description = "{{name}} functionality";
      category = "general";

      options = with lib; {
        # Add module-specific options here
      };

      config = { cfg, config, lib, pkgs }: {
        # Add module configuration here
      };

      security = cfg: {
        # Add security configuration here
      };

      dependencies = [ "core" ];
    }
    EOF
    @echo "✅ Module template created at modules/{{name}}/default.nix"
    @echo "📝 Don't forget to add documentation at docs/modules/{{name}}.md"

# Run pre-commit hooks on all files
pre-commit:
    pre-commit run --all-files

# Check for outdated dependencies
check-outdated:
    @echo "📦 Checking for outdated dependencies..."
    nix flake update --dry-run
    pre-commit autoupdate --dry-run

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
