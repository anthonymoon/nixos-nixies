#!/usr/bin/env bash

# Enterprise Profile Validation Script
# Comprehensive testing and validation for enterprise-server profile

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
validate_nix_syntax() {
    log_info "Validating Nix syntax..."

    local nix_files
    mapfile -t nix_files < <(find "$PROJECT_ROOT" -name "*.nix" -type f)

    local syntax_errors=0
    for file in "${nix_files[@]}"; do
        if ! nix-instantiate --parse "$file" >/dev/null 2>&1; then
            log_test "Nix Syntax" "FAIL" "Syntax error in $file"
            syntax_errors=$((syntax_errors + 1))
        fi
    done

    if [ $syntax_errors -eq 0 ]; then
        log_test "Nix Syntax" "PASS" "All ${#nix_files[@]} Nix files have valid syntax"
    else
        log_test "Nix Syntax" "FAIL" "$syntax_errors files have syntax errors"
    fi
}

validate_enterprise_profile() {
    log_info "Validating enterprise-server profile..."

    local profile_file="$PROJECT_ROOT/profiles/enterprise-server.nix"

    if [ ! -f "$profile_file" ]; then
        log_test "Enterprise Profile" "FAIL" "Profile file not found: $profile_file"
        return
    fi

    # Check for required security configurations
    local required_configs=(
        "security.auditd.enable"
        "security.apparmor.enable"
        "services.fail2ban.enable"
        "services.openssh.enable"
        "networking.firewall.enable"
        "boot.kernelPackages.*hardened"
    )

    local missing_configs=0
    for config in "${required_configs[@]}"; do
        if ! grep -q "$config" "$profile_file"; then
            log_test "Security Config" "FAIL" "Missing required configuration: $config"
            missing_configs=$((missing_configs + 1))
        fi
    done

    if [ $missing_configs -eq 0 ]; then
        log_test "Enterprise Profile" "PASS" "All required security configurations present"
    else
        log_test "Enterprise Profile" "FAIL" "$missing_configs required configurations missing"
    fi
}

validate_security_hardening() {
    log_info "Validating security hardening configurations..."

    local security_module="$PROJECT_ROOT/modules/security/enterprise.nix"

    if [ ! -f "$security_module" ]; then
        log_test "Security Module" "FAIL" "Security module not found: $security_module"
        return
    fi

    # Check for CIS benchmark compliance
    local cis_controls=(
        "kernel.kptr_restrict.*2"
        "kernel.dmesg_restrict.*1"
        "net.ipv4.conf.all.accept_source_route.*0"
        "net.ipv4.conf.all.accept_redirects.*0"
        "net.ipv4.tcp_syncookies.*1"
        "fs.protected_hardlinks.*1"
        "fs.protected_symlinks.*1"
    )

    local missing_hardening=0
    for control in "${cis_controls[@]}"; do
        if ! grep -q "$control" "$security_module"; then
            log_test "CIS Hardening" "FAIL" "Missing CIS control: $control"
            missing_hardening=$((missing_hardening + 1))
        fi
    done

    if [ $missing_hardening -eq 0 ]; then
        log_test "Security Hardening" "PASS" "All CIS benchmark controls implemented"
    else
        log_test "Security Hardening" "FAIL" "$missing_hardening CIS controls missing"
    fi
}

validate_monitoring_stack() {
    log_info "Validating monitoring and logging stack..."

    local monitoring_module="$PROJECT_ROOT/modules/monitoring/enterprise.nix"

    if [ ! -f "$monitoring_module" ]; then
        log_test "Monitoring Module" "FAIL" "Monitoring module not found: $monitoring_module"
        return
    fi

    # Check for required monitoring components
    local monitoring_components=(
        "services.prometheus"
        "services.grafana"
        "services.elasticsearch"
        "services.logstash"
        "services.kibana"
        "prometheus.alertmanager"
    )

    local missing_monitoring=0
    for component in "${monitoring_components[@]}"; do
        if ! grep -q "$component" "$monitoring_module"; then
            log_test "Monitoring Component" "FAIL" "Missing component: $component"
            missing_monitoring=$((missing_monitoring + 1))
        fi
    done

    if [ $missing_monitoring -eq 0 ]; then
        log_test "Monitoring Stack" "PASS" "All monitoring components configured"
    else
        log_test "Monitoring Stack" "FAIL" "$missing_monitoring monitoring components missing"
    fi
}

validate_deployment_automation() {
    log_info "Validating deployment automation..."

    local deployment_module="$PROJECT_ROOT/modules/deployment/enterprise.nix"

    if [ ! -f "$deployment_module" ]; then
        log_test "Deployment Module" "FAIL" "Deployment module not found: $deployment_module"
        return
    fi

    # Check for deployment capabilities
    local deployment_features=(
        "ansible"
        "health-checks"
        "rollback"
        "backup"
        "ci-cd"
    )

    local missing_deployment=0
    for feature in "${deployment_features[@]}"; do
        if ! grep -q "$feature" "$deployment_module"; then
            log_test "Deployment Feature" "FAIL" "Missing feature: $feature"
            missing_deployment=$((missing_deployment + 1))
        fi
    done

    if [ $missing_deployment -eq 0 ]; then
        log_test "Deployment Automation" "PASS" "All deployment features configured"
    else
        log_test "Deployment Automation" "FAIL" "$missing_deployment deployment features missing"
    fi
}

validate_compliance_frameworks() {
    log_info "Validating compliance framework implementations..."

    local compliance_files=(
        "$PROJECT_ROOT/modules/security/enterprise.nix"
        "$PROJECT_ROOT/profiles/enterprise-server.nix"
    )

    local compliance_frameworks=(
        "SOC2"
        "CIS"
        "NIST"
    )

    local implemented_frameworks=0
    for framework in "${compliance_frameworks[@]}"; do
        local found=0
        for file in "${compliance_files[@]}"; do
            if [ -f "$file" ] && grep -q "$framework" "$file"; then
                found=1
                break
            fi
        done

        if [ $found -eq 1 ]; then
            implemented_frameworks=$((implemented_frameworks + 1))
            log_test "Compliance Framework" "PASS" "$framework framework implemented"
        else
            log_test "Compliance Framework" "FAIL" "$framework framework not found"
        fi
    done

    if [ $implemented_frameworks -eq ${#compliance_frameworks[@]} ]; then
        log_test "Compliance Coverage" "PASS" "All major compliance frameworks covered"
    else
        log_test "Compliance Coverage" "FAIL" "Missing compliance framework implementations"
    fi
}

test_build_enterprise_config() {
    log_info "Testing enterprise configuration build..."

    # Test if enterprise configuration can be built
    if command -v nix >/dev/null 2>&1; then
        if nix build "$PROJECT_ROOT#nixosConfigurations.enterprise-server.config.system.build.toplevel" --dry-run >/dev/null 2>&1; then
            log_test "Enterprise Build" "PASS" "Enterprise configuration builds successfully"
        else
            log_test "Enterprise Build" "FAIL" "Enterprise configuration build failed"
        fi
    else
        log_test "Enterprise Build" "FAIL" "Nix not available for build testing"
    fi
}

validate_security_policies() {
    log_info "Validating security policies..."

    local profile_file="$PROJECT_ROOT/profiles/enterprise-server.nix"

    # Check for insecure configurations
    local insecure_patterns=(
        "PermitRootLogin.*yes"
        "PasswordAuthentication.*true"
        "allowUnfree.*true"
        "security.*false"
        "firewall.*false.*#.*not.*enterprise"
    )

    local security_violations=0
    for pattern in "${insecure_patterns[@]}"; do
        if grep -q "$pattern" "$profile_file" 2>/dev/null; then
            # Check if it's properly commented or in an acceptable context
            if ! grep -B2 -A2 "$pattern" "$profile_file" | grep -q "# Enterprise.*acceptable\|# VM.*only\|lib.mkForce false"; then
                log_test "Security Policy" "FAIL" "Potentially insecure configuration: $pattern"
                security_violations=$((security_violations + 1))
            fi
        fi
    done

    if [ $security_violations -eq 0 ]; then
        log_test "Security Policies" "PASS" "No security policy violations found"
    else
        log_test "Security Policies" "FAIL" "$security_violations security violations detected"
    fi
}

validate_documentation() {
    log_info "Validating enterprise documentation..."

    local doc_files=(
        "$PROJECT_ROOT/docs/enterprise-deployment.md"
        "$PROJECT_ROOT/docs/security-hardening.md"
        "$PROJECT_ROOT/docs/compliance-guide.md"
    )

    local missing_docs=0
    for doc in "${doc_files[@]}"; do
        if [ ! -f "$doc" ]; then
            missing_docs=$((missing_docs + 1))
        fi
    done

    if [ $missing_docs -eq 0 ]; then
        log_test "Documentation" "PASS" "All required documentation present"
    else
        log_test "Documentation" "FAIL" "$missing_docs documentation files missing"
    fi
}

validate_module_dependencies() {
    log_info "Validating module dependencies..."

    local enterprise_modules=(
        "$PROJECT_ROOT/modules/security/enterprise.nix"
        "$PROJECT_ROOT/modules/monitoring/enterprise.nix"
        "$PROJECT_ROOT/modules/deployment/enterprise.nix"
    )

    local dependency_errors=0
    for module in "${enterprise_modules[@]}"; do
        if [ -f "$module" ]; then
            # Check if dependencies are properly declared
            if ! grep -q "dependencies.*=.*\[" "$module"; then
                log_test "Module Dependencies" "FAIL" "Module $(basename "$module") missing dependency declaration"
                dependency_errors=$((dependency_errors + 1))
            fi
        fi
    done

    if [ $dependency_errors -eq 0 ]; then
        log_test "Module Dependencies" "PASS" "All modules have proper dependency declarations"
    else
        log_test "Module Dependencies" "FAIL" "$dependency_errors modules have dependency issues"
    fi
}

run_security_audit() {
    log_info "Running security audit..."

    if command -v lynis >/dev/null 2>&1; then
        # Run Lynis security audit (if available)
        local audit_output
        audit_output=$(lynis audit system --quiet --no-colors 2>/dev/null | grep "Hardening index" | tail -1)

        if [ -n "$audit_output" ]; then
            local hardening_score
            hardening_score=$(echo "$audit_output" | grep -o '[0-9]\+' | head -1)

            if [ "$hardening_score" -ge 80 ]; then
                log_test "Security Audit" "PASS" "Hardening score: $hardening_score/100"
            else
                log_test "Security Audit" "FAIL" "Hardening score too low: $hardening_score/100"
            fi
        else
            log_test "Security Audit" "FAIL" "Unable to run security audit"
        fi
    else
        log_test "Security Audit" "FAIL" "Lynis not available for security audit"
    fi
}

generate_validation_report() {
    log_info "Generating validation report..."

    local report_file="$PROJECT_ROOT/validation-report.md"
    local timestamp=$(date -Iseconds)

    cat > "$report_file" << EOF
# Enterprise Profile Validation Report

**Generated:** $timestamp
**Profile:** enterprise-server
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
    echo "✅ **All tests passed!** The enterprise profile is ready for production deployment."
else
    echo "❌ **$FAILED_TESTS tests failed.** Please review and fix the issues before deployment."
fi)

## Recommendations

1. Address all failed tests before deploying to production
2. Review security configurations regularly
3. Keep compliance frameworks up to date
4. Monitor deployment metrics and health checks
5. Maintain documentation and training materials

## Next Steps

1. Fix any failed validation tests
2. Run integration tests in staging environment
3. Perform penetration testing
4. Conduct compliance audit
5. Deploy to production with monitoring

---
*Generated by nixos-nixies enterprise validation script*
EOF

    log_success "Validation report generated: $report_file"
}

print_summary() {
    echo
    log_info "=== ENTERPRISE VALIDATION SUMMARY ==="
    echo
    log_info "Total Tests: $TOTAL_TESTS"
    log_info "Passed: $((TOTAL_TESTS - FAILED_TESTS))"
    log_info "Failed: $FAILED_TESTS"
    log_info "Success Rate: $(( (TOTAL_TESTS - FAILED_TESTS) * 100 / TOTAL_TESTS ))%"
    echo

    if [ $FAILED_TESTS -eq 0 ]; then
        log_success "🎉 All validation tests passed!"
        log_success "The enterprise profile is ready for production deployment."
    else
        log_error "❌ $FAILED_TESTS validation tests failed."
        log_error "Please review and fix the issues before deployment."
    fi

    echo
}

main() {
    echo
    log_info "🏢 Starting Enterprise Profile Validation"
    log_info "========================================"
    echo

    # Run all validation tests
    validate_nix_syntax
    validate_enterprise_profile
    validate_security_hardening
    validate_monitoring_stack
    validate_deployment_automation
    validate_compliance_frameworks
    test_build_enterprise_config
    validate_security_policies
    validate_documentation
    validate_module_dependencies
    run_security_audit

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
