{
  self,
  inputs,
  ...
}: {
  perSystem = {
    config,
    self',
    inputs',
    pkgs,
    system,
    ...
  }: {
    checks = {
      # Syntax validation for all Nix files
      nix-syntax = pkgs.runCommand "check-nix-syntax" {} ''
        set -euo pipefail

        echo "🔍 Checking Nix syntax for all files..."

        cd ${self}
        find . -name "*.nix" -type f | while IFS= read -r file; do
          echo "  Checking: $file"
          ${pkgs.nix}/bin/nix-instantiate --parse "$file" > /dev/null
        done

        touch $out
        echo "✅ All Nix files have valid syntax"
      '';

      # Flake validation
      flake-check = pkgs.runCommand "flake-check" {} ''
        set -euo pipefail

        echo "📦 Validating flake structure..."

        cd ${self}
        ${pkgs.nix}/bin/nix flake check --no-build

        touch $out
        echo "✅ Flake validation passed"
      '';

      # Security audit
      security-audit = pkgs.runCommand "security-audit" {} ''
        set -euo pipefail

        echo "🛡️  Running security audit..."

        cd ${self}

        # Critical security checks
        failed_checks=0

        # Check for disabled firewalls
        if grep -r "firewall\.enable.*false" . --include="*.nix" >/dev/null 2>&1; then
          echo "❌ CRITICAL: Disabled firewall found!"
          grep -r "firewall\.enable.*false" . --include="*.nix"
          failed_checks=$((failed_checks + 1))
        fi

        # Check for root SSH login
        if grep -r "PermitRootLogin.*yes" . --include="*.nix" >/dev/null 2>&1; then
          echo "❌ CRITICAL: Root SSH login enabled!"
          grep -r "PermitRootLogin.*yes" . --include="*.nix"
          failed_checks=$((failed_checks + 1))
        fi

        # Check for hardcoded passwords (excluding our template)
        if grep -r 'password.*=.*"[^"]*"' . --include="*.nix" | grep -v "template\|example" >/dev/null 2>&1; then
          echo "❌ CRITICAL: Hardcoded passwords found!"
          grep -r 'password.*=.*"[^"]*"' . --include="*.nix" | grep -v "template\|example"
          failed_checks=$((failed_checks + 1))
        fi

        if [ $failed_checks -gt 0 ]; then
          echo "❌ Security audit failed with $failed_checks critical issues"
          exit 1
        fi

        touch $out
        echo "✅ Security audit passed"
      '';

      # Performance analysis
      performance-check = pkgs.runCommand "performance-check" {} ''
        set -euo pipefail

        echo "⚡ Running performance analysis..."

        cd ${self}

        # Check for large package lists
        echo "📦 Analyzing package efficiency..."

        warnings=0

        # Count package references
        total_packages=$(find . -name "*.nix" -exec grep -o "pkgs\." {} \; 2>/dev/null | wc -l || echo 0)
        echo "📊 Total package references: $total_packages"

        if [ "$total_packages" -gt 500 ]; then
          echo "⚠️  HIGH: Very large number of packages ($total_packages)"
          warnings=$((warnings + 1))
        elif [ "$total_packages" -gt 300 ]; then
          echo "⚠️  MEDIUM: Large number of packages ($total_packages)"
          warnings=$((warnings + 1))
        fi

        # Check for repeated 'with pkgs;' usage
        with_pkgs_count=$(grep -r "with pkgs;" . --include="*.nix" 2>/dev/null | wc -l || echo 0)
        if [ "$with_pkgs_count" -gt 20 ]; then
          echo "⚠️  MEDIUM: Many 'with pkgs;' statements ($with_pkgs_count) - consider package sets"
          warnings=$((warnings + 1))
        fi

        echo "📊 Performance warnings: $warnings"

        touch $out
        echo "✅ Performance analysis completed"
      '';

      # Module interface consistency
      module-consistency = pkgs.runCommand "module-consistency" {} ''
        set -euo pipefail

        echo "🔧 Checking module interface consistency..."

        cd ${self}

        # Check that all modules follow unified pattern
        find modules -name "*.nix" -type f | while IFS= read -r module; do
          echo "  Checking: $module"

          # Skip default.nix files
          if [[ "$module" == *"/default.nix" ]]; then
            continue
          fi

          # Check for unified module pattern
          if ! grep -q "unified\." "$module" 2>/dev/null; then
            echo "⚠️  Module $module doesn't use unified pattern"
          fi
        done

        touch $out
        echo "✅ Module consistency check passed"
      '';

      # Documentation coverage
      documentation-check = pkgs.runCommand "documentation-check" {} ''
        set -euo pipefail

        echo "📚 Checking documentation coverage..."

        cd ${self}

        missing_docs=0

        # Check for README files
        if [ ! -f "README.md" ]; then
          echo "⚠️  Missing root README.md"
          missing_docs=$((missing_docs + 1))
        fi

        # Check for module documentation
        find modules -mindepth 1 -maxdepth 1 -type d | while IFS= read -r module_dir; do
          module_name=$(basename "$module_dir")
          if [ ! -f "$module_dir/README.md" ] && [ ! -f "docs/$module_name.md" ]; then
            echo "⚠️  Missing documentation for module: $module_name"
            missing_docs=$((missing_docs + 1))
          fi
        done

        echo "📊 Missing documentation items: $missing_docs"

        touch $out
        echo "✅ Documentation check completed"
      '';

      # Build all configurations
      build-all-configs = pkgs.runCommand "build-all-configs" {} ''
        set -euo pipefail

        echo "🏗️  Building all configurations to verify they work..."

        cd ${self}

        # List of configurations to build
        configs=("workstation" "server" "development" "base")

        for config in "''${configs[@]}"; do
          echo "  Building nixosConfiguration.$config..."

          if ${pkgs.nix}/bin/nix build ".#nixosConfigurations.$config.config.system.build.toplevel" --no-link --quiet; then
            echo "    ✅ $config build successful"
          else
            echo "    ❌ $config build failed"
            exit 1
          fi
        done

        touch $out
        echo "✅ All configurations build successfully"
      '';

      # Template validation
      template-validation = pkgs.runCommand "template-validation" {} ''
        set -euo pipefail

        echo "📋 Validating templates..."

        cd ${self}

        # Check if templates directory exists and has content
        if [ ! -d "templates" ]; then
          echo "⚠️  No templates directory found"
          touch $out
          exit 0
        fi

        # Validate each template
        find templates -name "flake.nix" | while IFS= read -r template_flake; do
          template_dir=$(dirname "$template_flake")
          template_name=$(basename "$template_dir")

          echo "  Validating template: $template_name"

          pushd "$template_dir" >/dev/null

          # Check template flake syntax
          ${pkgs.nix}/bin/nix-instantiate --parse flake.nix > /dev/null

          # Try to evaluate template
          ${pkgs.nix}/bin/nix flake show --quiet 2>/dev/null || {
            echo "    ⚠️  Template $template_name has evaluation issues"
          }

          popd >/dev/null
        done

        touch $out
        echo "✅ Template validation completed"
      '';
    };
  };
}
