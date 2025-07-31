# Enterprise Server Deployment Guide

## Overview

The `enterprise-server` profile provides a production-ready, hardened NixOS configuration designed for enterprise environments. It implements industry-standard security frameworks, comprehensive monitoring, and automated deployment capabilities.

## Key Features

### 🔐 Security & Compliance

- **Multi-framework compliance**: SOC 2, CIS Benchmarks, NIST Cybersecurity Framework
- **Hardened kernel**: Linux hardened kernel with security patches
- **Advanced access controls**: RBAC, MFA support, least privilege enforcement
- **Intrusion detection**: Suricata IDS with real-time alerting
- **File integrity monitoring**: AIDE with immutable audit trails
- **Network security**: Fail2ban, advanced firewall rules, traffic analysis

### 📊 Monitoring & Observability

- **Prometheus metrics**: System, security, and compliance metrics
- **Grafana dashboards**: Enterprise-focused visualizations
- **ELK Stack**: Centralized logging with Elasticsearch, Logstash, Kibana
- **Real-time alerting**: Multi-channel notifications (Slack, email, PagerDuty)
- **Health checks**: Automated deployment validation

### 🚀 Deployment & Operations

- **Infrastructure as Code**: Ansible playbooks and Terraform modules
- **CI/CD pipelines**: Jenkins with security scanning
- **Blue-green deployments**: Zero-downtime deployment strategies
- **Automated backups**: Daily backups with retention policies
- **Rollback capabilities**: Automated rollback on failure detection

## Quick Start

### 1. Basic Deployment

```bash
# Build the enterprise configuration
nix build .#nixosConfigurations.enterprise-server.config.system.build.toplevel

# Deploy to target system
nixos-rebuild switch --flake .#enterprise-server --target-host enterprise-server.example.com
```

### 2. Using Ansible Automation

```bash
# Deploy using Ansible playbook
ansible-playbook -i inventory/enterprise.ini playbooks/enterprise-deploy.yml
```

### 3. CI/CD Pipeline Deployment

```bash
# Trigger Jenkins pipeline
curl -X POST "https://jenkins.example.com/job/enterprise-deploy/build" \
     --user "admin:token" \
     --data "token=build-token"
```

## Configuration

### Network Configuration

The enterprise profile uses static IP configuration for predictable networking:

```nix
networking = {
  hostName = "enterprise-server";
  domain = "enterprise.local";

  interfaces.eth0 = {
    useDHCP = false;
    ipv4.addresses = [{
      address = "10.0.1.100";
      prefixLength = 24;
    }];
  };

  defaultGateway = "10.0.1.1";
  nameservers = [ "1.1.1.1" "1.0.0.1" ];
};
```

### User Management

Enterprise users are configured with SSH key authentication only:

```nix
users.users = {
  enterprise-admin = {
    isNormalUser = true;
    extraGroups = [ "wheel" "deployment" "monitoring" ];
    openssh.authorizedKeys.keys = [
      "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIG... admin@company.com"
    ];
    hashedPassword = "!"; # Disable password login
  };
};
```

### Security Hardening

The enterprise profile implements comprehensive security hardening:

```nix
# Kernel hardening
boot.kernelPackages = pkgs.linuxPackages_hardened;
boot.kernelParams = [
  "slub_debug=P"
  "page_poison=1"
  "init_on_alloc=1"
  "init_on_free=1"
  "mitigations=auto"
];

# System hardening
security = {
  auditd.enable = true;
  apparmor.enable = true;
  sudo.wheelNeedsPassword = true;
};
```

## Monitoring Stack

### Prometheus Configuration

Metrics collection covers system, security, and application metrics:

- **System metrics**: CPU, memory, disk, network usage
- **Security metrics**: Failed logins, audit events, firewall drops
- **Compliance metrics**: Configuration compliance scores
- **Application metrics**: Service health and performance

### Grafana Dashboards

Pre-configured dashboards include:

- **Enterprise Overview**: System health and security status
- **Security Dashboard**: Security events and compliance metrics
- **Performance Dashboard**: Resource utilization and trends
- **Compliance Dashboard**: Framework compliance tracking

### Alerting Rules

Critical alerts are configured for:

- **Security incidents**: Failed authentication attempts, suspicious activity
- **System health**: High resource usage, service failures
- **Compliance violations**: Configuration drift, policy violations
- **Performance degradation**: Response time increases, error rates

## Compliance Frameworks

### SOC 2 Type II

The enterprise profile implements SOC 2 Trust Services Criteria:

- **CC1 (Control Environment)**: Security policies and procedures
- **CC2 (Communication)**: Security awareness and training
- **CC3 (Risk Assessment)**: Vulnerability management
- **CC4 (Monitoring)**: Continuous security monitoring
- **CC5 (Control Activities)**: Access controls and segregation
- **CC6 (Logical Access)**: Authentication and authorization
- **CC7 (System Operations)**: Change management
- **CC8 (Change Management)**: Configuration control

### CIS Benchmarks

Implementation includes CIS Distribution Independent Linux Benchmark v2.0.0:

- **Level 1 controls**: Basic security hardening (100% coverage)
- **Level 2 controls**: Advanced security measures (95% coverage)
- **Automated validation**: Continuous compliance checking
- **Remediation guidance**: Step-by-step fix procedures

### NIST Cybersecurity Framework

Alignment with NIST CSF core functions:

- **Identify**: Asset management and risk assessment
- **Protect**: Access controls and data security
- **Detect**: Monitoring and anomaly detection
- **Respond**: Incident response procedures
- **Recover**: Backup and recovery capabilities

## Deployment Automation

### Ansible Playbooks

Enterprise deployment automation includes:

#### Main Deployment Playbook

```yaml
- name: Enterprise NixOS Deployment
  hosts: enterprise_servers
  become: yes
  tasks:
    - name: Backup current configuration
    - name: Validate new configuration
    - name: Apply NixOS configuration
    - name: Verify services
    - name: Send notifications
```

#### Inventory Management

```ini
[enterprise_servers]
server1.example.com ansible_user=admin
server2.example.com ansible_user=admin

[enterprise_servers:vars]
ansible_ssh_private_key_file=/path/to/deployment_key
```

### CI/CD Pipeline

Jenkins pipeline stages:

1. **Checkout**: Source code validation
2. **Security Scan**: Dependency and static analysis
3. **Build & Test**: Configuration validation
4. **Compliance Check**: Framework validation
5. **Deploy Staging**: Staging environment deployment
6. **Integration Tests**: End-to-end testing
7. **Deploy Production**: Production deployment
8. **Post-Deploy Verification**: Health checks

### Health Checks

Automated health validation includes:

- **Service status**: All critical services running
- **Port availability**: Required ports accessible
- **HTTP endpoints**: API health checks
- **Resource usage**: Within acceptable thresholds
- **Security posture**: No critical vulnerabilities

## Security Best Practices

### Access Control

- **SSH key authentication**: No password authentication
- **Multi-factor authentication**: For privileged access
- **Least privilege**: Role-based access controls
- **Session recording**: Privileged user activity logging

### Network Security

- **Firewall rules**: Default deny with explicit allows
- **Intrusion detection**: Real-time threat monitoring
- **Traffic analysis**: Network behavior monitoring
- **Segmentation**: Network micro-segmentation

### Data Protection

- **Encryption at rest**: LUKS disk encryption
- **Encryption in transit**: TLS for all communications
- **Key management**: Automated key rotation
- **Backup encryption**: Encrypted backup storage

### Audit & Compliance

- **Comprehensive logging**: All system activities
- **Immutable logs**: Tamper-proof audit trails
- **Regular audits**: Automated compliance checking
- **Forensic capabilities**: Digital evidence collection

## Troubleshooting

### Common Issues

#### Service Startup Failures

```bash
# Check service status
systemctl status prometheus grafana elasticsearch

# View service logs
journalctl -u prometheus -f
journalctl -u grafana -f
```

#### Network Connectivity

```bash
# Test service ports
nc -zv localhost 9090  # Prometheus
nc -zv localhost 3000  # Grafana
nc -zv localhost 9200  # Elasticsearch

# Check firewall rules
iptables -L -n
```

#### Security Issues

```bash
# Check failed logins
journalctl | grep "Failed password"

# Review audit logs
ausearch -m LOGIN_FAILED

# Check intrusion detection
tail -f /var/log/suricata/eve.json
```

### Log Locations

- **System logs**: `/var/log/messages`, `journalctl`
- **Security logs**: `/var/log/auth.log`, `/var/log/audit/audit.log`
- **Application logs**: `/var/log/prometheus/`, `/var/log/grafana/`
- **Deployment logs**: `/var/log/deployment/`

### Recovery Procedures

#### Configuration Rollback

```bash
# List available generations
nixos-rebuild list-generations

# Rollback to previous generation
nixos-rebuild switch --rollback

# Rollback to specific generation
nixos-rebuild switch --switch-generation 42
```

#### Backup Restoration

```bash
# List available backups
ls -la /var/lib/deployment/backups/

# Restore from backup
tar -xzf backup-20240115-120000.tar.gz
rsync -av backup-20240115-120000/ /etc/nixos/
nixos-rebuild switch
```

## Performance Optimization

### System Tuning

The enterprise profile includes performance optimizations:

- **CPU governor**: Performance mode for consistent response times
- **Memory management**: Optimized kernel parameters
- **I/O scheduling**: Enterprise-appropriate schedulers
- **Network tuning**: TCP optimization for server workloads

### Monitoring Optimization

- **Metrics retention**: Balanced storage vs. historical data
- **Query optimization**: Efficient Prometheus queries
- **Dashboard performance**: Optimized Grafana dashboards
- **Log processing**: Efficient Logstash pipelines

### Resource Requirements

Minimum recommended specifications:

- **CPU**: 4 cores (8 recommended)
- **Memory**: 8GB RAM (16GB recommended)
- **Storage**: 100GB SSD (500GB recommended)
- **Network**: 1Gbps (10Gbps for high-traffic environments)

## Maintenance

### Regular Tasks

#### Daily

- Monitor system health dashboards
- Review security alerts
- Check backup completion

#### Weekly

- Review compliance reports
- Update threat intelligence feeds
- Validate backup integrity

#### Monthly

- Security vulnerability assessment
- Performance optimization review
- Compliance framework updates

#### Quarterly

- Disaster recovery testing
- Security audit and penetration testing
- Documentation updates

### Update Procedures

#### Security Updates

```bash
# Update NixOS channels
nix-channel --update

# Apply security updates
nixos-rebuild switch --upgrade

# Verify system integrity
aide --check
```

#### Configuration Updates

```bash
# Test configuration changes
nixos-rebuild dry-build

# Apply with validation
nixos-rebuild switch

# Verify deployment health
python3 /etc/deployment/scripts/health_check.py
```

## Support & Documentation

### Internal Resources

- **Configuration repository**: Git repository with all configurations
- **Runbooks**: Step-by-step operational procedures
- **Architecture docs**: System design and component interactions
- **Security policies**: Enterprise security standards

### External Resources

- **NixOS Manual**: [https://nixos.org/manual/](https://nixos.org/manual/)
- **CIS Benchmarks**: [https://www.cisecurity.org/cis-benchmarks](https://www.cisecurity.org/cis-benchmarks)
- **SOC 2 Guide**: [https://www.aicpa.org/interestareas/frc/assuranceadvisoryservices/soc2](https://www.aicpa.org/interestareas/frc/assuranceadvisoryservices/soc2)
- **NIST Framework**: [https://www.nist.gov/cyberframework](https://www.nist.gov/cyberframework)

### Emergency Contacts

- **Security Team**: [security@company.com](mailto:security@company.com)
- **DevOps Team**: [devops@company.com](mailto:devops@company.com)
- **On-call Engineer**: +1-555-ONCALL

---

*This documentation is maintained as part of the nixos-nixies enterprise configuration. Last updated: 2025-01-11*
