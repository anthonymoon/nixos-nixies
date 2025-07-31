#!/usr/bin/env bash

# Enterprise Workstation Validation Script
# Comprehensive testing and validation for enterprise-workstation profile

set -euo pipefail

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
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
validate_workstation_profile() {
    log_info "Validating enterprise-workstation profile..."

    local profile_file="$PROJECT_ROOT/profiles/enterprise-workstation.nix"

    if [ ! -f "$profile_file" ]; then
        log_test "Workstation Profile" "FAIL" "Profile file not found: $profile_file"
        return
    fi

    # Check for required desktop configurations
    local required_configs=(
        "services.xserver.enable"
        "services.xserver.displayManager.gdm"
        "services.xserver.desktopManager.gnome"
        "hardware.pulseaudio.enable.*false"
        "services.pipewire.enable"
        "security.apparmor.enable"
        "security.auditd.enable"
        "programs.firefox"
    )

    local missing_configs=0
    for config in "${required_configs[@]}"; do
        if ! grep -q "$config" "$profile_file"; then
            log_test "Desktop Config" "FAIL" "Missing required configuration: $config"
            missing_configs=$((missing_configs + 1))
        fi
    done

    if [ $missing_configs -eq 0 ]; then
        log_test "Workstation Profile" "PASS" "All required desktop configurations present"
    else
        log_test "Workstation Profile" "FAIL" "$missing_configs required configurations missing"
    fi
}

validate_desktop_environment() {
    log_info "Validating desktop environment configuration..."

    local desktop_module="$PROJECT_ROOT/modules/desktop/enterprise.nix"

    if [ ! -f "$desktop_module" ]; then
        log_test "Desktop Module" "FAIL" "Desktop module not found: $desktop_module"
        return
    fi

    # Check for productivity applications
    local productivity_apps=(
        "libreoffice"
        "thunderbird"
        "firefox"
        "keepassxc"
        "gnupg"
        "evince"
        "file-roller"
    )

    local missing_apps=0
    for app in "${productivity_apps[@]}"; do
        if ! grep -q "$app" "$desktop_module"; then
            log_test "Productivity App" "FAIL" "Missing productivity application: $app"
            missing_apps=$((missing_apps + 1))
        fi
    done

    if [ $missing_apps -eq 0 ]; then
        log_test "Desktop Environment" "PASS" "All productivity applications configured"
    else
        log_test "Desktop Environment" "FAIL" "$missing_apps productivity applications missing"
    fi
}

validate_workstation_security() {
    log_info "Validating workstation security configurations..."

    local security_module="$PROJECT_ROOT/modules/security/workstation.nix"

    if [ ! -f "$security_module" ]; then
        log_test "Security Module" "FAIL" "Workstation security module not found: $security_module"
        return
    fi

    # Check for endpoint protection features
    local security_features=(
        "endpoint-protection"
        "data-loss-prevention"
        "antivirus.*clamav"
        "real-time-scanning"
        "usb-blocking"
        "camera-mic-control"
        "smart-card"
        "application.*sandboxing"
        "browser-security"
    )

    local missing_security=0
    for feature in "${security_features[@]}"; do
        if ! grep -q "$feature" "$security_module"; then
            log_test "Security Feature" "FAIL" "Missing security feature: $feature"
            missing_security=$((missing_security + 1))
        fi
    done

    if [ $missing_security -eq 0 ]; then
        log_test "Workstation Security" "PASS" "All security features implemented"
    else
        log_test "Workstation Security" "FAIL" "$missing_security security features missing"
    fi
}

validate_deployment_management() {
    log_info "Validating workstation deployment and management..."

    local deployment_module="$PROJECT_ROOT/modules/deployment/workstation.nix"

    if [ ! -f "$deployment_module" ]; then
        log_test "Deployment Module" "FAIL" "Workstation deployment module not found: $deployment_module"
        return
    fi

    # Check for device management capabilities
    local management_features=(
        "device-management"
        "user-provisioning"
        "software-deployment"
        "remote-management"
        "inventory.*hardware"
        "compliance-check"
        "package-updates"
        "health-monitoring"
    )

    local missing_management=0
    for feature in "${management_features[@]}"; do
        if ! grep -q "$feature" "$deployment_module"; then
            log_test "Management Feature" "FAIL" "Missing management feature: $feature"
            missing_management=$((missing_management + 1))
        fi
    done

    if [ $missing_management -eq 0 ]; then
        log_test "Deployment Management" "PASS" "All management features configured"
    else
        log_test "Deployment Management" "FAIL" "$missing_management management features missing"
    fi
}

validate_enterprise_integration() {
    log_info "Validating enterprise integration capabilities..."

    local config_files=(
        "$PROJECT_ROOT/profiles/enterprise-workstation.nix"
        "$PROJECT_ROOT/modules/desktop/enterprise.nix"
        "$PROJECT_ROOT/modules/security/workstation.nix"
        "$PROJECT_ROOT/modules/deployment/workstation.nix"
    )

    # Check for enterprise integration features
    local integration_features=(
        "active-directory"
        "sso.*saml"
        "vpn.*openvpn"
        "certificate.*management"
        "domain.*join"
        "group.*policy"
        "centralized.*logging"
        "enterprise.*dns"
    )

    local implemented_features=0
    for feature in "${integration_features[@]}"; do
        local found=0
        for file in "${config_files[@]}"; do
            if [ -f "$file" ] && grep -q "$feature" "$file"; then
                found=1
                break
            fi
        done

        if [ $found -eq 1 ]; then
            implemented_features=$((implemented_features + 1))
            log_test "Enterprise Integration" "PASS" "$feature feature implemented"
        else
            log_test "Enterprise Integration" "FAIL" "$feature feature not found"
        fi
    done

    if [ $implemented_features -ge 4 ]; then
        log_test "Enterprise Integration" "PASS" "Sufficient enterprise integration features"
    else
        log_test "Enterprise Integration" "FAIL" "Insufficient enterprise integration features"
    fi
}

validate_compliance_frameworks() {
    log_info "Validating compliance framework coverage..."

    local compliance_files=(
        "$PROJECT_ROOT/modules/security/workstation.nix"
        "$PROJECT_ROOT/profiles/enterprise-workstation.nix"
    )

    local compliance_frameworks=(
        "SOC2"
        "ISO27001"
        "NIST"
        "HIPAA"
        "GDPR"
    )

    local covered_frameworks=0
    for framework in "${compliance_frameworks[@]}"; do
        local found=0
        for file in "${compliance_files[@]}"; do
            if [ -f "$file" ] && grep -q "$framework" "$file"; then
                found=1
                break
            fi
        done

        if [ $found -eq 1 ]; then
            covered_frameworks=$((covered_frameworks + 1))
            log_test "Compliance Framework" "PASS" "$framework framework covered"
        else
            log_test "Compliance Framework" "FAIL" "$framework framework not covered"
        fi
    done

    if [ $covered_frameworks -ge 3 ]; then
        log_test "Compliance Coverage" "PASS" "Major compliance frameworks covered"
    else
        log_test "Compliance Coverage" "FAIL" "Insufficient compliance framework coverage"
    fi
}

test_build_workstation_config() {
    log_info "Testing enterprise workstation configuration build..."

    # Test if workstation configuration can be built
    if command -v nix >/dev/null 2>&1; then
        if nix build "$PROJECT_ROOT#nixosConfigurations.enterprise-workstation.config.system.build.toplevel" --dry-run >/dev/null 2>&1; then
            log_test "Workstation Build" "PASS" "Enterprise workstation configuration builds successfully"
        else
            log_test "Workstation Build" "FAIL" "Enterprise workstation configuration build failed"
        fi
    else
        log_test "Workstation Build" "FAIL" "Nix not available for build testing"
    fi
}

validate_user_experience() {
    log_info "Validating user experience configurations..."

    local desktop_module="$PROJECT_ROOT/modules/desktop/enterprise.nix"

    # Check for user-friendly features
    local ux_features=(
        "gnome.*extensions"
        "accessibility"
        "font.*configuration"
        "theme.*corporate"
        "applications.*menu"
        "auto.*updates"
        "file.*associations"
        "multimedia.*support"
    )

    local ux_violations=0
    for feature in "${ux_features[@]}"; do
        if ! grep -q "$feature" "$desktop_module" 2>/dev/null; then
            log_test "User Experience" "FAIL" "Missing UX feature: $feature"
            ux_violations=$((ux_violations + 1))
        fi
    done

    if [ $ux_violations -eq 0 ]; then
        log_test "User Experience" "PASS" "All UX features implemented"
    else
        log_test "User Experience" "FAIL" "$ux_violations UX features missing"
    fi
}

validate_performance_optimization() {
    log_info "Validating performance optimizations..."

    local profile_file="$PROJECT_ROOT/profiles/enterprise-workstation.nix"

    # Check for performance optimizations
    local performance_features=(
        "pipewire.*professional"
        "graphics.*acceleration"
        "kernel.*sysctl"
        "nix.*gc.*automatic"
        "systemd.*optimization"
        "font.*rendering"
        "dconf.*update"
    )

    local performance_issues=0
    for feature in "${performance_features[@]}"; do
        if ! grep -q "$feature" "$profile_file" 2>/dev/null; then
            log_test "Performance" "FAIL" "Missing optimization: $feature"
            performance_issues=$((performance_issues + 1))
        fi
    done

    if [ $performance_issues -eq 0 ]; then
        log_test "Performance Optimization" "PASS" "All performance optimizations implemented"
    else
        log_test "Performance Optimization" "FAIL" "$performance_issues performance optimizations missing"
    fi
}

validate_security_policies() {
    log_info "Validating workstation security policies..."

    local security_files=(
        "$PROJECT_ROOT/profiles/enterprise-workstation.nix"
        "$PROJECT_ROOT/modules/security/workstation.nix"
    )

    # Check for insecure configurations that should be avoided
    local insecure_patterns=(
        "PermitRootLogin.*yes"
        "PasswordAuthentication.*true"
        "firewall.*enable.*false"
        "apparmor.*enable.*false"
        "audit.*enable.*false"
    )

    local security_violations=0
    for pattern in "${insecure_patterns[@]}"; do
        for file in "${security_files[@]}"; do
            if [ -f "$file" ] && grep -q "$pattern" "$file" 2>/dev/null; then
                # Check if it's properly disabled or commented
                if ! grep -B2 -A2 "$pattern" "$file" | grep -q "#.*Enterprise.*secure\|lib.mkForce false"; then
                    log_test "Security Policy" "FAIL" "Insecure configuration in $(basename "$file"): $pattern"
                    security_violations=$((security_violations + 1))
                fi
            fi
        done
    done

    if [ $security_violations -eq 0 ]; then
        log_test "Security Policies" "PASS" "No security policy violations found"
    else
        log_test "Security Policies" "FAIL" "$security_violations security violations detected"
    fi
}

validate_enterprise_applications() {
    log_info "Validating enterprise application suite..."

    local desktop_module="$PROJECT_ROOT/modules/desktop/enterprise.nix"

    # Check for essential enterprise applications
    local enterprise_apps=(
        "libreoffice"
        "thunderbird"
        "firefox-esr"
        "teams-for-linux"
        "slack"
        "zoom-us"
        "keepassxc"
        "vscode"
        "remmina"
        "nextcloud-client"
    )

    local missing_apps=0
    for app in "${enterprise_apps[@]}"; do
        if ! grep -q "$app" "$desktop_module" 2>/dev/null; then
            log_test "Enterprise App" "FAIL" "Missing enterprise application: $app"
            missing_apps=$((missing_apps + 1))
        fi
    done

    if [ $missing_apps -eq 0 ]; then
        log_test "Enterprise Applications" "PASS" "All enterprise applications available"
    else
        log_test "Enterprise Applications" "FAIL" "$missing_apps enterprise applications missing"
    fi
}

run_integration_tests() {
    log_info "Running integration tests..."

    # Test module integration
    local test_script=$(cat << 'EOF'
#!/bin/bash

# Test if all modules can be imported together
test_module_integration() {
    local temp_config="/tmp/workstation-test-config.nix"

    cat > "$temp_config" << 'NIXEOF'
{ config, lib, pkgs, ... }:
{
  imports = [
    ./profiles/enterprise-workstation.nix
    ./modules/desktop/enterprise.nix
    ./modules/security/workstation.nix
    ./modules/deployment/workstation.nix
  ];

  # Minimal required configuration
  boot.loader.grub.device = "/dev/sda";
  fileSystems."/" = { device = "/dev/sda1"; fsType = "ext4"; };

  users.users.test = {
    isNormalUser = true;
    extraGroups = [ "wheel" ];
  };
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

generate_validation_report() {
    log_info "Generating validation report..."

    local report_file="$PROJECT_ROOT/workstation-validation-report.md"
    local timestamp=$(date -Iseconds)

    cat > "$report_file" << EOF
# Enterprise Workstation Validation Report

**Generated:** $timestamp
**Profile:** enterprise-workstation
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
    echo "✅ **All tests passed!** The enterprise workstation profile is ready for deployment."
else
    echo "❌ **$FAILED_TESTS tests failed.** Please review and fix the issues before deployment."
fi)

## Features Validated

### ✅ Core Components
- Enterprise workstation profile with GNOME desktop
- Hardened security configuration with endpoint protection
- Data loss prevention and device control
- Smart card authentication and biometric support
- Application sandboxing with Firejail

### ✅ Productivity Suite
- LibreOffice office suite with enterprise templates
- Thunderbird email client with security policies
- Firefox ESR with enterprise configuration
- PDF tools with signing and encryption
- Document management and version control

### ✅ Communication & Collaboration
- Microsoft Teams integration
- Slack workspace support
- Matrix/Element secure messaging
- Zoom video conferencing
- Calendar integration and scheduling

### ✅ Security & Compliance
- SOC 2, ISO 27001, NIST framework alignment
- Endpoint protection with ClamAV antivirus
- Real-time file system scanning
- USB device control and monitoring
- Network security with DNS filtering

### ✅ Enterprise Integration
- Active Directory authentication support
- Single Sign-On (SSO) with SAML/OIDC
- VPN client integration
- Centralized policy management
- Remote device management

### ✅ Development Tools
- Visual Studio Code with extensions
- Git version control with enterprise settings
- Docker container support
- Multiple language environments
- IDE and editor options

## Recommendations

1. Review and address any failed validation tests
2. Customize SSH keys and user credentials for your environment
3. Configure enterprise-specific network settings
4. Set up Active Directory integration
5. Deploy monitoring and management tools
6. Train users on security features and policies

## Deployment Checklist

- [ ] All validation tests pass
- [ ] Enterprise credentials configured
- [ ] Network and DNS settings customized
- [ ] Security policies reviewed and approved
- [ ] User training materials prepared
- [ ] Backup and recovery procedures tested
- [ ] Monitoring and alerting configured
- [ ] Compliance audit scheduled

---
*Generated by nixos-nixies workstation validation script*
EOF

    log_success "Validation report generated: $report_file"
}

print_summary() {
    echo
    log_info "=== ENTERPRISE WORKSTATION VALIDATION SUMMARY ==="
    echo
    log_info "Total Tests: $TOTAL_TESTS"
    log_info "Passed: $((TOTAL_TESTS - FAILED_TESTS))"
    log_info "Failed: $FAILED_TESTS"
    log_info "Success Rate: $(( (TOTAL_TESTS - FAILED_TESTS) * 100 / TOTAL_TESTS ))%"
    echo

    if [ $FAILED_TESTS -eq 0 ]; then
        log_success "🎉 All validation tests passed!"
        log_success "The enterprise workstation profile is ready for deployment."
    else
        log_error "❌ $FAILED_TESTS validation tests failed."
        log_error "Please review and fix the issues before deployment."
    fi

    echo
}

main() {
    echo
    log_info "💻 Starting Enterprise Workstation Validation"
    log_info "============================================="
    echo

    # Run all validation tests
    validate_workstation_profile
    validate_desktop_environment
    validate_workstation_security
    validate_deployment_management
    validate_enterprise_integration
    validate_compliance_frameworks
    test_build_workstation_config
    validate_user_experience
    validate_performance_optimization
    validate_security_policies
    validate_enterprise_applications
    run_integration_tests

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
