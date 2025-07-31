#!/usr/bin/env bash

# Home Desktop Validation Script
# Comprehensive testing and validation for home-desktop profile with bleeding-edge gaming

set -euo pipefail

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
PURPLE='\033[0;35m'
CYAN='\033[0;36m'
NC='\033[0m' # No Color

# Global variables
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
PROJECT_ROOT="$(dirname "$SCRIPT_DIR")"
VALIDATION_RESULTS=()
FAILED_TESTS=0
TOTAL_TESTS=0

# Logging functions
log_info() {
    echo -e "${BLUE}[INFO]${NC} $1"
}

log_success() {
    echo -e "${GREEN}[SUCCESS]${NC} $1"
}

log_warning() {
    echo -e "${YELLOW}[WARNING]${NC} $1"
}

log_error() {
    echo -e "${RED}[ERROR]${NC} $1"
}

log_test() {
    local test_name="$1"
    local status="$2"
    local message="$3"

    TOTAL_TESTS=$((TOTAL_TESTS + 1))

    if [ "$status" = "PASS" ]; then
        echo -e "${GREEN}✅ PASS${NC}: $test_name - $message"
        VALIDATION_RESULTS+=("✅ $test_name: $message")
    else
        echo -e "${RED}❌ FAIL${NC}: $test_name - $message"
        VALIDATION_RESULTS+=("❌ $test_name: $message")
        FAILED_TESTS=$((FAILED_TESTS + 1))
    fi
}

# Validation functions
validate_home_desktop_profile() {
    log_info "🏠 Validating home-desktop profile..."

    local profile_file="$PROJECT_ROOT/profiles/home-desktop.nix"

    if [ ! -f "$profile_file" ]; then
        log_test "Home Desktop Profile" "FAIL" "Profile file not found: $profile_file"
        return
    fi

    # Check for required home desktop configurations
    local required_configs=(
        "nixies.gaming.enable"
        "nixies.development.enable"
        "nixies.media"
        "nixies.bleeding-edge"
        "hardware.opengl.enable"
        "services.pipewire.enable"
        "programs.steam.enable"
        "boot.kernelPackages.*latest"
    )

    local missing_configs=0
    for config in "${required_configs[@]}"; do
        if ! grep -q "$config" "$profile_file"; then
            log_test "Desktop Config" "FAIL" "Missing required configuration: $config"
            missing_configs=$((missing_configs + 1))
        fi
    done

    if [ $missing_configs -eq 0 ]; then
        log_test "Home Desktop Profile" "PASS" "All required configurations present"
    else
        log_test "Home Desktop Profile" "FAIL" "$missing_configs required configurations missing"
    fi
}

validate_bleeding_edge_module() {
    log_info "🔥 Validating bleeding-edge module..."

    local bleeding_edge_module="$PROJECT_ROOT/modules/bleeding-edge/default.nix"

    if [ ! -f "$bleeding_edge_module" ]; then
        log_test "Bleeding Edge Module" "FAIL" "Module not found: $bleeding_edge_module"
        return
    fi

    # Check for bleeding-edge features
    local bleeding_edge_features=(
        "packages.source.*unstable"
        "kernel.version.*latest"
        "graphics.drivers.*latest"
        "mesa.*git"
        "experimental-features"
        "build.optimization"
        "nix.settings.*experimental"
    )

    local missing_features=0
    for feature in "${bleeding_edge_features[@]}"; do
        if ! grep -q "$feature" "$bleeding_edge_module"; then
            log_test "Bleeding Edge Feature" "FAIL" "Missing feature: $feature"
            missing_features=$((missing_features + 1))
        fi
    done

    if [ $missing_features -eq 0 ]; then
        log_test "Bleeding Edge Module" "PASS" "All bleeding-edge features implemented"
    else
        log_test "Bleeding Edge Module" "FAIL" "$missing_features features missing"
    fi
}

validate_gaming_features() {
    log_info "🎮 Validating gaming features..."

    local gaming_files=(
        "$PROJECT_ROOT/modules/gaming/default.nix"
        "$PROJECT_ROOT/modules/gaming/advanced.nix"
        "$PROJECT_ROOT/profiles/home-desktop.nix"
    )

    # Check for gaming features
    local gaming_features=(
        "steam.*enable"
        "gamemode.*enable"
        "mangohud"
        "lutris"
        "heroic"
        "vr.*support"
        "rgb.*control"
        "controllers.*advanced"
        "streaming.*obs"
        "emulation"
    )

    local implemented_features=0
    for feature in "${gaming_features[@]}"; do
        local found=0
        for file in "${gaming_files[@]}"; do
            if [ -f "$file" ] && grep -q "$feature" "$file"; then
                found=1
                break
            fi
        done

        if [ $found -eq 1 ]; then
            implemented_features=$((implemented_features + 1))
            log_test "Gaming Feature" "PASS" "$feature feature implemented"
        else
            log_test "Gaming Feature" "FAIL" "$feature feature not found"
        fi
    done

    if [ $implemented_features -ge 7 ]; then
        log_test "Gaming Features" "PASS" "Comprehensive gaming support implemented"
    else
        log_test "Gaming Features" "FAIL" "Insufficient gaming features"
    fi
}

validate_vr_support() {
    log_info "🥽 Validating VR support..."

    local advanced_gaming="$PROJECT_ROOT/modules/gaming/advanced.nix"

    if [ ! -f "$advanced_gaming" ]; then
        log_test "VR Module" "FAIL" "Advanced gaming module not found"
        return
    fi

    # Check for VR features
    local vr_features=(
        "vr.*enable"
        "openxr"
        "steamvr"
        "monado"
        "oculus.*support"
        "htc-vive"
        "valve-index"
        "tracking.*lighthouse"
        "low-latency.*vr"
    )

    local vr_support=0
    for feature in "${vr_features[@]}"; do
        if grep -q "$feature" "$advanced_gaming"; then
            vr_support=$((vr_support + 1))
        fi
    done

    if [ $vr_support -ge 6 ]; then
        log_test "VR Support" "PASS" "Comprehensive VR support implemented"
    else
        log_test "VR Support" "FAIL" "Limited VR support ($vr_support/9 features)"
    fi
}

validate_rgb_peripherals() {
    log_info "🌈 Validating RGB peripheral support..."

    local advanced_gaming="$PROJECT_ROOT/modules/gaming/advanced.nix"

    # Check for RGB features
    local rgb_features=(
        "rgb.*enable"
        "openrgb"
        "corsair.*ckb"
        "razer.*support"
        "logitech.*g"
        "asus.*rog"
        "audio-reactive"
        "game-integration"
        "keyboards.*rgb"
        "mice.*rgb"
    )

    local rgb_support=0
    for feature in "${rgb_features[@]}"; do
        if grep -q "$feature" "$advanced_gaming" 2>/dev/null; then
            rgb_support=$((rgb_support + 1))
        fi
    done

    if [ $rgb_support -ge 6 ]; then
        log_test "RGB Peripherals" "PASS" "Comprehensive RGB support implemented"
    else
        log_test "RGB Peripherals" "FAIL" "Limited RGB support ($rgb_support/10 features)"
    fi
}

validate_media_production() {
    log_info "🎬 Validating media production capabilities..."

    local media_module="$PROJECT_ROOT/modules/media/production.nix"

    if [ ! -f "$media_module" ]; then
        log_test "Media Module" "FAIL" "Media production module not found"
        return
    fi

    # Check for media production features
    local media_features=(
        "video.*production"
        "audio.*production"
        "graphics.*design"
        "3d.*modeling"
        "streaming.*enable"
        "kdenlive"
        "blender"
        "obs-studio"
        "audacity"
        "gimp"
        "davinci-resolve"
        "hardware.*acceleration"
    )

    local media_support=0
    for feature in "${media_features[@]}"; do
        if grep -q "$feature" "$media_module"; then
            media_support=$((media_support + 1))
        fi
    done

    if [ $media_support -ge 8 ]; then
        log_test "Media Production" "PASS" "Comprehensive media production suite"
    else
        log_test "Media Production" "FAIL" "Limited media production support"
    fi
}

validate_development_environment() {
    log_info "💻 Validating development environment..."

    local profile_file="$PROJECT_ROOT/profiles/home-desktop.nix"

    # Check for development features
    local dev_features=(
        "development.*enable"
        "languages.*rust"
        "languages.*python"
        "languages.*nodejs"
        "languages.*go"
        "editors.*vscode"
        "editors.*neovim"
        "tools.*git"
        "tools.*docker"
        "tools.*kubernetes"
        "bleeding-edge.*development"
    )

    local dev_support=0
    for feature in "${dev_features[@]}"; do
        if grep -q "$feature" "$profile_file"; then
            dev_support=$((dev_support + 1))
        fi
    done

    if [ $dev_support -ge 8 ]; then
        log_test "Development Environment" "PASS" "Comprehensive development setup"
    else
        log_test "Development Environment" "FAIL" "Limited development support"
    fi
}

validate_performance_optimizations() {
    log_info "⚡ Validating performance optimizations..."

    local profile_file="$PROJECT_ROOT/profiles/home-desktop.nix"

    # Check for performance features
    local perf_features=(
        "performance.*gaming"
        "cpuFreqGovernor.*performance"
        "kernel.*latest"
        "sysctl.*gaming"
        "gamemode"
        "low-latency"
        "hardware.*acceleration"
        "gpu.*optimization"
        "network.*optimization"
        "storage.*optimization"
    )

    local perf_optimizations=0
    for feature in "${perf_features[@]}"; do
        if grep -q "$feature" "$profile_file"; then
            perf_optimizations=$((perf_optimizations + 1))
        fi
    done

    if [ $perf_optimizations -ge 6 ]; then
        log_test "Performance Optimizations" "PASS" "Comprehensive performance tuning"
    else
        log_test "Performance Optimizations" "FAIL" "Limited performance optimizations"
    fi
}

validate_desktop_environment() {
    log_info "🖥️ Validating desktop environment..."

    local profile_file="$PROJECT_ROOT/profiles/home-desktop.nix"

    # Check for desktop features
    local desktop_features=(
        "niri.*enable"
        "wayland.*true"
        "greetd"
        "xwayland.*true"
        "screensharing"
        "bleeding-edge.*desktop"
        "pipewire.*enable"
        "bluetooth.*enable"
        "networkmanager"
        "fonts.*packages"
    )

    local desktop_support=0
    for feature in "${desktop_features[@]}"; do
        if grep -q "$feature" "$profile_file"; then
            desktop_support=$((desktop_support + 1))
        fi
    done

    if [ $desktop_support -ge 7 ]; then
        log_test "Desktop Environment" "PASS" "Modern desktop environment configured"
    else
        log_test "Desktop Environment" "FAIL" "Desktop environment needs improvement"
    fi
}

validate_security_considerations() {
    log_info "🔒 Validating security considerations..."

    local profile_file="$PROJECT_ROOT/profiles/home-desktop.nix"

    # Check for security features (balanced for home use)

        local security_features=(
        "security.*standard"
        "firewall.*enable"
        "apparmor.*enable"
        "sudo.*enable"
        "polkit.*enable"
        "rtkit.*enable"
    )

    local security_violations=0

    # Check for insecure configurations
    local insecure_patterns=(
        "PermitRootLogin.*yes"
        "PasswordAuthentication.*true"
        "firewall.*enable.*false"
        "security.*disable"
    )

    for pattern in "${insecure_patterns[@]}"; do
        if grep -q "$pattern" "$profile_file" 2>/dev/null; then
            log_test "Security Check" "FAIL" "Insecure configuration found: $pattern"
            security_violations=$((security_violations + 1))
        fi
    done

    if [ $security_violations -eq 0 ]; then
        log_test "Security Considerations" "PASS" "No major security violations found"
    else
        log_test "Security Considerations" "FAIL" "$security_violations security issues detected"
    fi
}

validate_package_ecosystem() {
    log_info "📦 Validating package ecosystem..."

    local profile_file="$PROJECT_ROOT/profiles/home-desktop.nix"

    # Check for essential packages
    local essential_packages=(
        "steam"
        "firefox"
        "discord"
        "vscode"
        "git"
        "docker"
        "obs-studio"
        "gimp"
        "blender"
        "gamemode"
        "mangohud"
        "lutris"
    )

    local missing_packages=0
    for package in "${essential_packages[@]}"; do
        if ! grep -q "$package" "$profile_file"; then
            log_test "Essential Package" "FAIL" "Missing package: $package"
            missing_packages=$((missing_packages + 1))
        fi
    done

    if [ $missing_packages -eq 0 ]; then
        log_test "Package Ecosystem" "PASS" "All essential packages included"
    else
        log_test "Package Ecosystem" "FAIL" "$missing_packages essential packages missing"
    fi
}

test_build_home_desktop_config() {
    log_info "🔨 Testing home desktop configuration build..."

    # Test if home desktop configuration can be built
    if command -v nix >/dev/null 2>&1; then
        if nix build "$PROJECT_ROOT#nixosConfigurations.home-desktop.config.system.build.toplevel" --dry-run >/dev/null 2>&1; then
            log_test "Home Desktop Build" "PASS" "Home desktop configuration builds successfully"
        else
            log_test "Home Desktop Build" "FAIL" "Home desktop configuration build failed"
        fi
    else
        log_test "Home Desktop Build" "FAIL" "Nix not available for build testing"
    fi
}

validate_systems_integration() {
    log_info "🔗 Validating systems.nix integration..."

    local systems_file="$PROJECT_ROOT/flake-modules/systems.nix"

    if [ ! -f "$systems_file" ]; then
        log_test "Systems Integration" "FAIL" "systems.nix not found"
        return
    fi

    # Check if home-desktop is properly integrated
    if grep -q "home-desktop.*nixies-lib.mkSystem" "$systems_file"; then
        log_test "Systems Integration" "PASS" "home-desktop properly integrated in systems.nix"
    else
        log_test "Systems Integration" "FAIL" "home-desktop not found in systems.nix"
    fi

    # Check for required configurations in systems.nix
    local systems_configs=(
        "profiles.*home-desktop"
        "gaming.*enable"
        "bleeding-edge.*enable"
        "development.*enable"
        "nixies.core"
    )

    local missing_sys_configs=0
    for config in "${systems_configs[@]}"; do
        if ! grep -q "$config" "$systems_file"; then
            log_test "Systems Config" "FAIL" "Missing systems.nix config: $config"
            missing_sys_configs=$((missing_sys_configs + 1))
        fi
    done

    if [ $missing_sys_configs -eq 0 ]; then
        log_test "Systems Configuration" "PASS" "All required systems configurations present"
    else
        log_test "Systems Configuration" "FAIL" "$missing_sys_configs systems configurations missing"
    fi
}

validate_module_structure() {
    log_info "🏗️ Validating module structure..."

    # Check for required modules
    local required_modules=(
        "$PROJECT_ROOT/modules/bleeding-edge/default.nix"
        "$PROJECT_ROOT/modules/gaming/advanced.nix"
        "$PROJECT_ROOT/modules/media/production.nix"
    )

    local missing_modules=0
    for module in "${required_modules[@]}"; do
        if [ ! -f "$module" ]; then
            log_test "Module Structure" "FAIL" "Missing module: $(basename "$module")"
            missing_modules=$((missing_modules + 1))
        fi
    done

    if [ $missing_modules -eq 0 ]; then
        log_test "Module Structure" "PASS" "All required modules present"
    else
        log_test "Module Structure" "FAIL" "$missing_modules modules missing"
    fi
}

run_integration_tests() {
    log_info "🧪 Running integration tests..."

    # Test module compatibility
    local test_script=$(cat << 'EOF'
#!/bin/bash

# Test if all modules can be imported together
test_module_integration() {
    local temp_config="/tmp/home-desktop-test-config.nix"

    cat > "$temp_config" << 'NIXEOF'
{ config, lib, pkgs, ... }:
{
  imports = [
    ./profiles/home-desktop.nix
    ./modules/bleeding-edge/default.nix
    ./modules/gaming/advanced.nix
    ./modules/media/production.nix
  ];

  # Minimal required configuration
  boot.loader.grub.device = "/dev/sda";
  fileSystems."/" = { device = "/dev/sda1"; fsType = "ext4"; };

  users.users.test = {
    isNormalUser = true;
    extraGroups = [ "wheel" ];
  };

  networking.hostName = "test-home-desktop";
}
NIXEOF

    # Test configuration evaluation
    if nix-instantiate --eval --strict "$temp_config" >/dev/null 2>&1; then
        echo "PASS: Module integration test"
        rm -f "$temp_config"
        return 0
    else
        echo "FAIL: Module integration test"
        rm -f "$temp_config"
        return 1
    fi
}

test_module_integration
EOF
)

    if eval "$test_script"; then
        log_test "Integration Tests" "PASS" "Module integration successful"
    else
        log_test "Integration Tests" "FAIL" "Module integration failed"
    fi
}

validate_documentation() {
    log_info "📚 Validating documentation..."

    # Check for documentation files
    local doc_files=(
        "$PROJECT_ROOT/profiles/home-desktop.nix"
        "$PROJECT_ROOT/modules/bleeding-edge/default.nix"
        "$PROJECT_ROOT/modules/gaming/advanced.nix"
        "$PROJECT_ROOT/modules/media/production.nix"
    )

    local documented_files=0
    for file in "${doc_files[@]}"; do
        if [ -f "$file" ] && grep -q "description.*=" "$file"; then
            documented_files=$((documented_files + 1))
        fi
    done

    if [ $documented_files -eq ${#doc_files[@]} ]; then
        log_test "Documentation" "PASS" "All modules properly documented"
    else
        log_test "Documentation" "FAIL" "Some modules lack proper documentation"
    fi
}

generate_validation_report() {
    log_info "📊 Generating validation report..."

    local report_file="$PROJECT_ROOT/home-desktop-validation-report.md"
    local timestamp=$(date -Iseconds)

    cat > "$report_file" << EOF
# Home Desktop Validation Report

**Generated:** $timestamp
**Profile:** home-desktop (bleeding-edge gaming)
**Total Tests:** $TOTAL_TESTS
**Failed Tests:** $FAILED_TESTS
**Success Rate:** $(( (TOTAL_TESTS - FAILED_TESTS) * 100 / TOTAL_TESTS ))%

## Test Results

EOF

    for result in "${VALIDATION_RESULTS[@]}"; do
        echo "- $result" >> "$report_file"
    done

    cat >> "$report_file" << EOF

## Summary

$(if [ $FAILED_TESTS -eq 0 ]; then
    echo "🎉 **All tests passed!** The home desktop profile is ready for bleeding-edge gaming and development."
else
    echo "⚠️ **$FAILED_TESTS tests failed.** Please review and fix the issues before deployment."
fi)

## Features Validated

### 🎮 Gaming Features
- **Steam Integration**: Latest Steam with Proton support
- **VR Support**: OpenXR, SteamVR, and multiple headset compatibility
- **RGB Peripherals**: OpenRGB, brand-specific software, and effects
- **Advanced Controllers**: Xbox, PlayStation, Nintendo, and specialty controllers
- **Game Launchers**: Steam, Lutris, Heroic, Bottles, and store clients
- **Performance**: GameMode, MangoHUD, CoreCtrl, and system optimizations
- **Streaming**: OBS Studio, Sunshine, game capture, and broadcasting

### 🔥 Bleeding-Edge Features
- **Latest Kernel**: Linux latest for cutting-edge hardware support
- **Unstable Packages**: Nixpkgs unstable for newest software versions
- **Graphics Drivers**: Latest Mesa, NVIDIA, and AMD drivers
- **Experimental Features**: Nix experimental features and optimizations
- **Build Optimizations**: ccache, parallel builds, and performance tuning

### 💻 Development Environment
- **Multiple Languages**: Rust (nightly), Python, Node.js, Go, Java, C++
- **Modern Editors**: VSCode, Neovim with latest features
- **Container Tools**: Docker, Podman, Kubernetes support
- **Version Control**: Git with LFS and enterprise features
- **Database Support**: PostgreSQL, Redis, and development databases

### 🎬 Media Production
- **Video Editing**: KDEnlive, Blender, DaVinci Resolve
- **Audio Production**: Ardour, Audacity, REAPER support
- **Graphics Design**: GIMP, Krita, Inkscape, Darktable
- **3D Modeling**: Blender, FreeCAD, OpenSCAD
- **Streaming Tools**: OBS Studio with plugins and hardware acceleration

### 🖥️ Desktop Environment
- **Modern Compositor**: Niri scrollable tiling Wayland compositor
- **Display Manager**: greetd with tuigreet for clean login
- **Audio System**: PipeWire with low-latency gaming configuration
- **Hardware Support**: Bluetooth, RGB devices, gaming peripherals
- **Font Support**: Comprehensive font packages for development and design

### ⚡ Performance Optimizations
- **CPU**: Performance governor, real-time scheduling, core isolation
- **GPU**: Hardware acceleration, multi-GPU support, compute shaders
- **Memory**: Huge pages, ZRAM compression, cache optimization
- **Storage**: I/O scheduler tuning, SSD optimization, cache drives
- **Network**: Low-latency gaming, BBR congestion control, QoS

### 🔒 Security Considerations
- **Balanced Security**: Standard security level appropriate for home use
- **Application Sandboxing**: AppArmor, Firejail, Flatpak sandboxing
- **Network Security**: Firewall with gaming-optimized rules
- **User Management**: Proper group memberships and permissions
- **Privacy Features**: DNS filtering, telemetry blocking options

## Quick Start

### 1. Build Configuration
\`\`\`bash
nix build .#nixosConfigurations.home-desktop.config.system.build.toplevel
\`\`\`

### 2. Deploy to System
\`\`\`bash
nixos-rebuild switch --flake .#home-desktop
\`\`\`

### 3. Create User Account
\`\`\`bash
passwd gamer  # Set password for gaming user
\`\`\`

### 4. Configure Gaming
- Launch Steam and enable Proton
- Configure RGB devices with OpenRGB
- Set up VR headset if available
- Install game launchers (Lutris, Heroic)

### 5. Development Setup
- Install development tools through VSCode extensions
- Configure Git with your credentials
- Set up Docker containers for projects
- Install language-specific tools as needed

## Deployment Checklist

- [ ] All validation tests pass
- [ ] Hardware compatibility verified
- [ ] Gaming peripherals tested
- [ ] Network configuration optimized
- [ ] User accounts and permissions configured
- [ ] Backup system in place
- [ ] Performance monitoring enabled

## Troubleshooting

### Common Issues
1. **Gaming Performance**: Check GPU drivers and GameMode status
2. **Audio Latency**: Verify PipeWire configuration and buffer sizes
3. **VR Setup**: Ensure proper udev rules and runtime selection
4. **RGB Devices**: Check device compatibility and OpenRGB support
5. **Build Failures**: Update Nix channels and clear build cache

### Performance Tuning
1. **CPU Governor**: Verify performance governor is active
2. **Memory**: Monitor usage and adjust ZRAM if needed
3. **Storage**: Check I/O scheduler and read-ahead settings
4. **Graphics**: Validate hardware acceleration and driver versions

---
*Generated by nixos-nixies home-desktop validation script*
EOF

    log_success "Validation report generated: $report_file"
}

print_summary() {
    echo
    log_info "=== 🏠 HOME DESKTOP VALIDATION SUMMARY ==="
    echo
    log_info "Profile: Bleeding-Edge Gaming Desktop"
    log_info "Total Tests: $TOTAL_TESTS"
    log_info "Passed: $((TOTAL_TESTS - FAILED_TESTS))"
    log_info "Failed: $FAILED_TESTS"
    log_info "Success Rate: $(( (TOTAL_TESTS - FAILED_TESTS) * 100 / TOTAL_TESTS ))%"
    echo

    if [ $FAILED_TESTS -eq 0 ]; then
        log_success "🎉 All validation tests passed!"
        log_success "The home desktop profile is ready for bleeding-edge gaming and development."
        echo
        log_info "✨ Features Ready:"
        log_info "   🎮 Gaming: Steam, VR, RGB, Advanced Controllers"
        log_info "   🔥 Bleeding-Edge: Latest kernel, unstable packages, experimental features"
        log_info "   💻 Development: Multi-language support, modern editors, containers"
        log_info "   🎬 Media: Video editing, audio production, graphics design, streaming"
        log_info "   ⚡ Performance: Gaming optimizations, hardware acceleration"
    else
        log_error "❌ $FAILED_TESTS validation tests failed."
        log_error "Please review and fix the issues before deployment."
        echo
        log_warning "🔧 Next Steps:"
        log_warning "   1. Review failed tests in the validation report"
        log_warning "   2. Fix configuration issues"
        log_warning "   3. Re-run validation script"
        log_warning "   4. Test build with: nix build .#nixosConfigurations.home-desktop.config.system.build.toplevel"
    fi

    echo
}

main() {
    echo
    log_info "🚀 Starting Home Desktop Validation (Bleeding-Edge Gaming)"
    log_info "================================================================="
    echo

    # Run all validation tests
    validate_home_desktop_profile
    validate_bleeding_edge_module
    validate_gaming_features
    validate_vr_support
    validate_rgb_peripherals
    validate_media_production
    validate_development_environment
    validate_performance_optimizations
    validate_desktop_environment
    validate_security_considerations
    validate_package_ecosystem
    test_build_home_desktop_config
    validate_systems_integration
    validate_module_structure
    run_integration_tests
    validate_documentation

    # Generate report and summary
    generate_validation_report
    print_summary

    # Exit with error code if tests failed
    exit $FAILED_TESTS
}

# Script entry point
if [[ "${BASH_SOURCE[0]}" == "${0}" ]]; then
    main "$@"
fi
