#!/usr/bin/env bash

# Home Server Profile Validation Script
# Tests the bleeding-edge home server configuration with comprehensive services

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
    echo -e "${BLUE}================================${NC}"
    echo -e "${BLUE}Home Server Profile Validation${NC}"
    echo -e "${BLUE}================================${NC}"
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
    echo -e "${BLUE}================================${NC}"
    echo -e "${BLUE}Validation Summary${NC}"
    echo -e "${BLUE}================================${NC}"
    echo -e "Total Tests: ${TOTAL_TESTS}"
    echo -e "${GREEN}Passed: ${PASSED_TESTS}${NC}"
    echo -e "${RED}Failed: ${FAILED_TESTS}${NC}"

    local success_rate=$(( (PASSED_TESTS * 100) / TOTAL_TESTS ))
    echo -e "Success Rate: ${success_rate}%"

    if [ $success_rate -ge 80 ]; then
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

test_directory_exists() {
    local dir="$1"
    local description="$2"
    ((TOTAL_TESTS++))

    if [ -d "$dir" ]; then
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

test_nix_syntax() {
    local file="$1"
    local description="$2"
    ((TOTAL_TESTS++))

    if nix-instantiate --parse "$file" >/dev/null 2>&1; then
        print_success "$description has valid Nix syntax"
    else
        print_failure "$description has invalid Nix syntax"
    fi
}

# Main validation function
main() {
    print_header

    # Test profile structure
    print_test "Profile Structure"
    test_file_exists "profiles/home-server.nix" "Home server profile"
    test_file_exists "modules/services/self-hosting.nix" "Self-hosting services module"
    test_file_exists "flake-modules/systems.nix" "Systems configuration"

    # Test Nix syntax
    print_test "Nix Syntax Validation"
    test_nix_syntax "profiles/home-server.nix" "Home server profile"
    test_nix_syntax "modules/services/self-hosting.nix" "Self-hosting module"
    test_nix_syntax "flake-modules/systems.nix" "Systems configuration"

    # Test profile configuration
    print_test "Profile Configuration"
    test_file_contains "profiles/home-server.nix" "home-server" "Profile name configured"
    test_file_contains "profiles/home-server.nix" "bleeding-edge" "Bleeding-edge channel configured"
    test_file_contains "profiles/home-server.nix" "services.*enable = true" "Services enabled"
    test_file_contains "profiles/home-server.nix" "containers" "Container support configured"
    test_file_contains "profiles/home-server.nix" "security.level.*balanced" "Balanced security configured"

    # Test services configuration
    print_test "Services Configuration"
    test_file_contains "profiles/home-server.nix" "jellyfin = true" "Jellyfin media server enabled"
    test_file_contains "profiles/home-server.nix" "immich = true" "Immich photo management enabled"
    test_file_contains "profiles/home-server.nix" "navidrome = true" "Navidrome music server enabled"
    test_file_contains "profiles/home-server.nix" "nextcloud = true" "Nextcloud cloud storage enabled"
    test_file_contains "profiles/home-server.nix" "vaultwarden = true" "Vaultwarden password manager enabled"
    test_file_contains "profiles/home-server.nix" "home-assistant = true" "Home Assistant automation enabled"
    test_file_contains "profiles/home-server.nix" "gitea = true" "Gitea Git hosting enabled"
    test_file_contains "profiles/home-server.nix" "prometheus = true" "Prometheus monitoring enabled"
    test_file_contains "profiles/home-server.nix" "grafana = true" "Grafana dashboards enabled"

    # Test self-hosting module
    print_test "Self-Hosting Module"
    test_file_contains "modules/services/self-hosting.nix" "reverse-proxy" "Reverse proxy configuration"
    test_file_contains "modules/services/self-hosting.nix" "ssl" "SSL/TLS configuration"
    test_file_contains "modules/services/self-hosting.nix" "media.*jellyfin" "Media services configuration"
    test_file_contains "modules/services/self-hosting.nix" "cloud.*nextcloud" "Cloud services configuration"
    test_file_contains "modules/services/self-hosting.nix" "automation.*home-assistant" "Automation services configuration"
    test_file_contains "modules/services/self-hosting.nix" "monitoring.*prometheus" "Monitoring services configuration"

    # Test bleeding-edge configuration
    print_test "Bleeding-Edge Configuration"
    test_file_contains "profiles/home-server.nix" "nixpkgs-unstable" "Unstable packages source"
    test_file_contains "profiles/home-server.nix" "kernel.version.*latest" "Latest kernel configured"
    test_file_contains "profiles/home-server.nix" "allow-unfree.*true" "Unfree packages allowed"
    test_file_contains "profiles/home-server.nix" "experimental.*enable = true" "Experimental features enabled"

    # Test container configuration
    print_test "Container Configuration"
    test_file_contains "profiles/home-server.nix" "runtime.*podman" "Podman runtime configured"
    test_file_contains "profiles/home-server.nix" "kubernetes.*enable = true" "Kubernetes enabled"
    test_file_contains "profiles/home-server.nix" "k3s" "K3s distribution configured"
    test_file_contains "profiles/home-server.nix" "docker-compatibility" "Docker compatibility enabled"
    test_file_contains "profiles/home-server.nix" "registry = true" "Container registry enabled"

    # Test systems integration
    print_test "Systems Integration"
    test_file_contains "flake-modules/systems.nix" "home-server.*nixies-lib.mkSystem" "Home server system defined"
    test_file_contains "flake-modules/systems.nix" "hostname.*home-server" "Hostname configured"
    test_file_contains "flake-modules/systems.nix" "profiles.*home-server" "Profile reference configured"
    test_file_contains "flake-modules/systems.nix" "homeserver.*isNormalUser" "Server user configured"
    test_file_contains "flake-modules/systems.nix" "media.*isSystemUser" "Media user configured"
    test_file_contains "flake-modules/systems.nix" "openssh.*enable = true" "SSH service enabled"
    test_file_contains "flake-modules/systems.nix" "fail2ban.*enable = true" "Fail2ban security enabled"
    test_file_contains "flake-modules/systems.nix" "podman.*enable = true" "Podman virtualization enabled"

    # Test networking configuration
    print_test "Networking Configuration"
    test_file_contains "flake-modules/systems.nix" "firewall.*enable = true" "Firewall enabled"
    test_file_contains "flake-modules/systems.nix" "allowedTCPPorts" "TCP ports configured"
    test_file_contains "flake-modules/systems.nix" "22.*SSH" "SSH port open"
    test_file_contains "flake-modules/systems.nix" "80.*HTTP" "HTTP port open"
    test_file_contains "flake-modules/systems.nix" "443.*HTTPS" "HTTPS port open"
    test_file_contains "flake-modules/systems.nix" "8096.*Jellyfin" "Jellyfin port open"
    test_file_contains "flake-modules/systems.nix" "8123.*Home Assistant" "Home Assistant port open"

    # Test security configuration
    print_test "Security Configuration"
    test_file_contains "flake-modules/systems.nix" "PasswordAuthentication.*false" "Password authentication disabled"
    test_file_contains "flake-modules/systems.nix" "PermitRootLogin.*no" "Root login disabled"
    test_file_contains "flake-modules/systems.nix" "MaxAuthTries.*3" "Auth attempts limited"
    test_file_contains "flake-modules/systems.nix" "AllowUsers.*homeserver" "User access restricted"

    # Test system optimization
    print_test "System Optimization"
    test_file_contains "flake-modules/systems.nix" "cpuFreqGovernor.*ondemand" "CPU governor optimized"
    test_file_contains "flake-modules/systems.nix" "noatime.*nodiratime" "Filesystem optimized"
    test_file_contains "flake-modules/systems.nix" "net.core.rmem_max" "Network buffers optimized"
    test_file_contains "flake-modules/systems.nix" "vm.dirty_ratio" "Memory management optimized"

    # Test package installation
    print_test "Package Installation"
    test_file_contains "flake-modules/systems.nix" "environment.systemPackages" "System packages configured"
    test_file_contains "flake-modules/systems.nix" "podman" "Podman container runtime"
    test_file_contains "flake-modules/systems.nix" "htop" "System monitoring tools"
    test_file_contains "flake-modules/systems.nix" "restic" "Backup tools"
    test_file_contains "flake-modules/systems.nix" "ffmpeg" "Media processing tools"
    test_file_contains "flake-modules/systems.nix" "wireguard-tools" "VPN tools"

    # Test directory structure
    print_test "Directory Structure"
    test_file_contains "flake-modules/systems.nix" "/var/lib/media" "Media directory configured"
    test_file_contains "flake-modules/systems.nix" "/var/lib/backup" "Backup directory configured"
    test_file_contains "flake-modules/systems.nix" "/var/lib/monitoring" "Monitoring directory configured"
    test_file_contains "flake-modules/systems.nix" "/var/lib/automation" "Automation directory configured"
    test_file_contains "flake-modules/systems.nix" "/var/lib/containers" "Container directory configured"

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
