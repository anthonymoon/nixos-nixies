#!/usr/bin/env bash

# Package Sets Validation Script
# Tests the modular package sets system for functionality and performance

set -euo pipefail

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

# Counters
TOTAL_TESTS=0
PASSED_TESTS=0
FAILED_TESTS=0

# Test results array
declare -a TEST_RESULTS=()

print_header() {
    echo -e "${BLUE}======================================${NC}"
    echo -e "${BLUE}Package Sets System Validation${NC}"
    echo -e "${BLUE}======================================${NC}"
    echo
}

print_test() {
    local test_name="$1"
    echo -e "${YELLOW}Testing: ${test_name}${NC}"
}

print_success() {
    local message="$1"
    echo -e "  ${GREEN}✓ ${message}${NC}"
    ((PASSED_TESTS++))
    TEST_RESULTS+=("PASS: $message")
}

print_failure() {
    local message="$1"
    echo -e "  ${RED}✗ ${message}${NC}"
    ((FAILED_TESTS++))
    TEST_RESULTS+=("FAIL: $message")
}

print_summary() {
    echo
    echo -e "${BLUE}======================================${NC}"
    echo -e "${BLUE}Validation Summary${NC}"
    echo -e "${BLUE}======================================${NC}"
    echo -e "Total Tests: ${TOTAL_TESTS}"
    echo -e "${GREEN}Passed: ${PASSED_TESTS}${NC}"
    echo -e "${RED}Failed: ${FAILED_TESTS}${NC}"

    local success_rate=$(( (PASSED_TESTS * 100) / TOTAL_TESTS ))
    echo -e "Success Rate: ${success_rate}%"

    if [ $success_rate -ge 90 ]; then
        echo -e "${GREEN}✓ Validation EXCELLENT${NC}"
    elif [ $success_rate -ge 80 ]; then
        echo -e "${GREEN}✓ Validation PASSED${NC}"
    elif [ $success_rate -ge 60 ]; then
        echo -e "${YELLOW}⚠ Validation PARTIAL${NC}"
    else
        echo -e "${RED}✗ Validation FAILED${NC}"
    fi

    echo
    echo "Detailed Results:"
    for result in "${TEST_RESULTS[@]}"; do
        if [[ $result == PASS:* ]]; then
            echo -e "  ${GREEN}${result}${NC}"
        else
            echo -e "  ${RED}${result}${NC}"
        fi
    done
}

test_file_exists() {
    local file="$1"
    local description="$2"
    ((TOTAL_TESTS++))

    if [ -f "$file" ]; then
        print_success "$description exists"
    else
        print_failure "$description missing"
    fi
}

test_file_contains() {
    local file="$1"
    local pattern="$2"
    local description="$3"
    ((TOTAL_TESTS++))

    if [ -f "$file" ] && grep -q "$pattern" "$file"; then
        print_success "$description"
    else
        print_failure "$description"
    fi
}

test_package_set_structure() {
    local set_name="$1"
    local file="modules/packages/sets/${set_name}.nix"

    print_test "Package Set: $set_name"

    # Test file exists
    test_file_exists "$file" "$set_name package set file"

    # Test basic structure
    test_file_contains "$file" "nixies-lib.mkUnifiedModule" "$set_name uses unified module structure"
    test_file_contains "$file" "packages-$set_name" "$set_name has correct module name"
    test_file_contains "$file" "options.*with lib" "$set_name defines options"
    test_file_contains "$file" "config.*lib.mkIf.*enable" "$set_name has conditional config"
    test_file_contains "$file" "environment.systemPackages" "$set_name installs packages"
    test_file_contains "$file" "dependencies.*=.*\\[" "$set_name declares dependencies"
}

# Main validation function
main() {
    print_header

    # Test main package sets module
    print_test "Package Sets Module Structure"
    test_file_exists "modules/packages/default.nix" "Main packages module"
    test_file_contains "modules/packages/default.nix" "packages" "Module name is packages"
    test_file_contains "modules/packages/default.nix" "modular package sets system" "Module description present"
    test_file_contains "modules/packages/default.nix" "sets.*=" "Package sets configuration"
    test_file_contains "modules/packages/default.nix" "management.*=" "Package management options"
    test_file_contains "modules/packages/default.nix" "resolution.*=" "Package resolution options"
    test_file_contains "modules/packages/default.nix" "optimization.*=" "Performance optimization options"

    # Test imports structure\n    test_file_contains "modules/packages/default.nix" "imports.*=.*\\[" "Imports section present"\n    test_file_contains "modules/packages/default.nix" "./sets/core.nix" "Core set imported"\n    test_file_contains "modules/packages/default.nix" "./sets/desktop.nix" "Desktop set imported"\n    test_file_contains "modules/packages/default.nix" "./sets/gaming.nix" "Gaming set imported"\n    test_file_contains "modules/packages/default.nix" "./sets/multimedia.nix" "Multimedia set imported"\n    test_file_contains "modules/packages/default.nix" "./sets/drivers.nix" "Drivers set imported"\n    test_file_contains "modules/packages/default.nix" "./sets/server.nix" "Server set imported"\n    test_file_contains "modules/packages/default.nix" "./sets/browsers.nix" "Browsers set imported"\n    test_file_contains "modules/packages/default.nix" "./sets/vm.nix" "VM set imported"

    # Test individual package sets
    test_package_set_structure "core"
    test_package_set_structure "desktop"
    test_package_set_structure "gaming"
    test_package_set_structure "multimedia"
    test_package_set_structure "drivers"
    test_package_set_structure "server"
    test_package_set_structure "browsers"
    test_package_set_structure "vm"

    # Test package set content and features
    print_test "Core Package Set Features"
    test_file_contains "modules/packages/sets/core.nix" "git.*vscode-insiders.*zed" "Core packages specified"
    test_file_contains "modules/packages/sets/core.nix" "development.*=" "Development tools category"
    test_file_contains "modules/packages/sets/core.nix" "shells.*=" "Shell environments category"
    test_file_contains "modules/packages/sets/core.nix" "utilities.*=" "System utilities category"
    test_file_contains "modules/packages/sets/core.nix" "modern-alternatives" "Modern tool alternatives"

    print_test "Desktop Package Set Features"
    test_file_contains "modules/packages/sets/desktop.nix" "niri.*hyprland.*plasma6" "Desktop environments specified"
    test_file_contains "modules/packages/sets/desktop.nix" "window-managers.*=" "Window managers category"
    test_file_contains "modules/packages/sets/desktop.nix" "display-managers.*=" "Display managers category"
    test_file_contains "modules/packages/sets/desktop.nix" "greetd.*tuigreet" "Display manager options"
    test_file_contains "modules/packages/sets/desktop.nix" "wayland.*=" "Wayland ecosystem support"
    test_file_contains "modules/packages/sets/desktop.nix" "theming.*=" "Theming and customization"

    print_test "Gaming Package Set Features"
    test_file_contains "modules/packages/sets/gaming.nix" "steam.*gamemode.*gamescope" "Gaming packages specified"
    test_file_contains "modules/packages/sets/gaming.nix" "controllers.*=" "Controller support"
    test_file_contains "modules/packages/sets/gaming.nix" "ps5.*xbox.*nintendo" "Controller types"
    test_file_contains "modules/packages/sets/gaming.nix" "performance.*=" "Gaming performance optimization"
    test_file_contains "modules/packages/sets/gaming.nix" "emulation.*=" "Game emulation support"
    test_file_contains "modules/packages/sets/gaming.nix" "wine.*=" "Windows compatibility"

    print_test "Multimedia Package Set Features"
    test_file_contains "modules/packages/sets/multimedia.nix" "mpv.*ffmpeg.*cava" "Multimedia packages specified"
    test_file_contains "modules/packages/sets/multimedia.nix" "audio.*=" "Audio production category"
    test_file_contains "modules/packages/sets/multimedia.nix" "video.*=" "Video production category"
    test_file_contains "modules/packages/sets/multimedia.nix" "graphics.*=" "Graphics editing category"
    test_file_contains "modules/packages/sets/multimedia.nix" "rnnoise.*noise-torch" "Audio enhancement tools"
    test_file_contains "modules/packages/sets/multimedia.nix" "hardware-acceleration" "Hardware acceleration support"

    print_test "Drivers Package Set Features"
    test_file_contains "modules/packages/sets/drivers.nix" "amdgpu.*nvidia.*vulkan" "Driver packages specified"
    test_file_contains "modules/packages/sets/drivers.nix" "graphics.*=" "Graphics drivers category"
    test_file_contains "modules/packages/sets/drivers.nix" "acceleration.*=" "Hardware acceleration"
    test_file_contains "modules/packages/sets/drivers.nix" "dxvk.*libva.*av1" "Compatibility and codec support"
    test_file_contains "modules/packages/sets/drivers.nix" "vulkan.*=" "Vulkan API support"
    test_file_contains "modules/packages/sets/drivers.nix" "vaapi.*=" "VA-API acceleration"

    print_test "Server Package Set Features"
    test_file_contains "modules/packages/sets/server.nix" "docker.*libvirtd.*qbittorrent" "Server packages specified"
    test_file_contains "modules/packages/sets/server.nix" "containers.*=" "Container platforms"
    test_file_contains "modules/packages/sets/server.nix" "virtualization.*=" "Virtualization support"
    test_file_contains "modules/packages/sets/server.nix" "smb.*wsdd.*arr-stack" "File sharing and media"
    test_file_contains "modules/packages/sets/server.nix" "web-services.*=" "Web server support"
    test_file_contains "modules/packages/sets/server.nix" "monitoring.*=" "Server monitoring"

    print_test "Browsers Package Set Features"
    test_file_contains "modules/packages/sets/browsers.nix" "zen-browser.*tor-browser.*qutebrowser" "Browser packages specified"
    test_file_contains "modules/packages/sets/browsers.nix" "mainstream.*=" "Mainstream browsers"
    test_file_contains "modules/packages/sets/browsers.nix" "privacy-focused.*=" "Privacy-focused browsers"
    test_file_contains "modules/packages/sets/browsers.nix" "specialized.*=" "Specialized browsers"
    test_file_contains "modules/packages/sets/browsers.nix" "security-features.*=" "Browser security"
    test_file_contains "modules/packages/sets/browsers.nix" "extensions.*=" "Browser extensions"

    print_test "VM Package Set Features"
    test_file_contains "modules/packages/sets/vm.nix" "virtio.*kvm-guest" "VM packages specified"
    test_file_contains "modules/packages/sets/vm.nix" "guest-tools.*=" "VM guest tools"
    test_file_contains "modules/packages/sets/vm.nix" "host-tools.*=" "VM host tools"
    test_file_contains "modules/packages/sets/vm.nix" "performance.*=" "VM performance optimization"
    test_file_contains "modules/packages/sets/vm.nix" "security.*=" "VM security features"
    test_file_contains "modules/packages/sets/vm.nix" "development.*=" "VM development tools"

    # Test integration and advanced features
    print_test "Package Set Integration"
    test_file_contains "modules/packages/default.nix" "nixies.packages" "Integration with unified system"
    test_file_contains "modules/packages/default.nix" "nixpkgs.config" "Package configuration management"
    test_file_contains "modules/packages/default.nix" "packageOverrides" "Package override system"
    test_file_contains "modules/packages/default.nix" "validatePackageSets" "Package validation system"

    # Test performance and optimization features
    print_test "Performance and Optimization"
    test_file_contains "modules/packages/default.nix" "lazy-loading" "Lazy loading optimization"
    test_file_contains "modules/packages/default.nix" "cache-package-info" "Package caching"
    test_file_contains "modules/packages/default.nix" "parallel-evaluation" "Parallel evaluation"
    test_file_contains "modules/packages/default.nix" "auto-resolve" "Automatic conflict resolution"

    # Test package resolution strategies
    print_test "Package Resolution"
    test_file_contains "modules/packages/default.nix" "resolution.*strategy" "Resolution strategy options"
    test_file_contains "modules/packages/default.nix" "prefer-source" "Source preference options"
    test_file_contains "modules/packages/default.nix" "override-conflicts" "Conflict override options"
    test_file_contains "modules/packages/default.nix" "strict.*permissive.*smart" "Resolution strategies"

    # Test specific package specifications from build command
    print_test "Build Command Package Specifications"

    # Core packages: git, vscode-insiders, zed, thorium, neovim, zsh, fish
    test_file_contains "modules/packages/sets/core.nix" "git" "Git version control"
    test_file_contains "modules/packages/sets/core.nix" "vscode-insiders" "VS Code Insiders"
    test_file_contains "modules/packages/sets/core.nix" "zed" "Zed editor"
    test_file_contains "modules/packages/sets/core.nix" "thorium" "Thorium browser"
    test_file_contains "modules/packages/sets/core.nix" "neovim" "Neovim editor"
    test_file_contains "modules/packages/sets/core.nix" "zsh" "Z Shell"
    test_file_contains "modules/packages/sets/core.nix" "fish" "Fish shell"

    # Desktop packages: niri, hyprland, plasma6, greetd, tuigreet
    test_file_contains "modules/packages/sets/desktop.nix" "niri" "Niri compositor"
    test_file_contains "modules/packages/sets/desktop.nix" "hyprland" "Hyprland compositor"
    test_file_contains "modules/packages/sets/desktop.nix" "plasma6" "KDE Plasma 6"
    test_file_contains "modules/packages/sets/desktop.nix" "greetd" "greetd display manager"
    test_file_contains "modules/packages/sets/desktop.nix" "tuigreet" "TUI greeter"

    # Gaming packages: steam, gamemode, gamescope, ps5-controller, xbox-controller
    test_file_contains "modules/packages/sets/gaming.nix" "steam" "Steam gaming platform"
    test_file_contains "modules/packages/sets/gaming.nix" "gamemode" "GameMode optimization"
    test_file_contains "modules/packages/sets/gaming.nix" "gamescope" "Gamescope compositor"
    test_file_contains "modules/packages/sets/gaming.nix" "ps5" "PlayStation 5 controller"
    test_file_contains "modules/packages/sets/gaming.nix" "xbox" "Xbox controller"

    # Multimedia packages: mpv, ffmpeg, cava, pulseaudio, rnnoise, noise-torch
    test_file_contains "modules/packages/sets/multimedia.nix" "mpv" "MPV media player"
    test_file_contains "modules/packages/sets/multimedia.nix" "ffmpeg" "FFmpeg framework"
    test_file_contains "modules/packages/sets/multimedia.nix" "cava" "Cava visualizer"
    test_file_contains "modules/packages/sets/multimedia.nix" "pulseaudio" "PulseAudio system"
    test_file_contains "modules/packages/sets/multimedia.nix" "rnnoise" "RNNoise suppression"
    test_file_contains "modules/packages/sets/multimedia.nix" "noise-torch" "NoiseTorch GUI"

    # Driver packages: amdgpu, nvidia, vulkan, dxvk, libva, av1
    test_file_contains "modules/packages/sets/drivers.nix" "amdgpu" "AMD GPU drivers"
    test_file_contains "modules/packages/sets/drivers.nix" "nvidia" "NVIDIA drivers"
    test_file_contains "modules/packages/sets/drivers.nix" "vulkan" "Vulkan API"
    test_file_contains "modules/packages/sets/drivers.nix" "dxvk" "DXVK translation"
    test_file_contains "modules/packages/sets/drivers.nix" "libva" "libva acceleration"
    test_file_contains "modules/packages/sets/drivers.nix" "av1" "AV1 codec"

    # Server packages: docker, libvirtd, qbittorrent, smb, wsdd, arr-stack
    test_file_contains "modules/packages/sets/server.nix" "docker" "Docker containers"
    test_file_contains "modules/packages/sets/server.nix" "libvirtd" "libvirt virtualization"
    test_file_contains "modules/packages/sets/server.nix" "qbittorrent" "qBittorrent client"
    test_file_contains "modules/packages/sets/server.nix" "smb" "SMB file sharing"
    test_file_contains "modules/packages/sets/server.nix" "wsdd" "Windows Service Discovery"
    test_file_contains "modules/packages/sets/server.nix" "arr-stack" "*arr automation stack"

    # Browser packages: zen-browser, tor-browser, qutebrowser
    test_file_contains "modules/packages/sets/browsers.nix" "zen-browser" "Zen Browser"
    test_file_contains "modules/packages/sets/browsers.nix" "tor-browser" "Tor Browser"
    test_file_contains "modules/packages/sets/browsers.nix" "qutebrowser" "qutebrowser"

    # VM packages: virtio, kvm-guest
    test_file_contains "modules/packages/sets/vm.nix" "virtio" "VirtIO drivers"
    test_file_contains "modules/packages/sets/vm.nix" "kvm-guest" "KVM guest tools"

    print_summary

    # Exit with error code if validation failed
    if [ $FAILED_TESTS -gt 0 ]; then
        exit 1
    fi
}

# Check if running from correct directory
if [ ! -f "flake.nix" ]; then
    echo -e "${RED}Error: Please run this script from the nixos-nixies root directory${NC}"
    exit 1
fi

# Run main validation
main "$@"
