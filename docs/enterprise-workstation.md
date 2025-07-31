# Enterprise Workstation Deployment Guide

## Overview

The `enterprise-workstation` profile provides a comprehensive, secure, and user-friendly NixOS desktop configuration designed for enterprise environments. It combines productivity tools, security hardening, and enterprise integration capabilities while maintaining usability for end users.

## Key Features

### 🖥️ Desktop Environment

- **GNOME Desktop**: Enterprise-friendly with locked settings and corporate branding
- **Professional Applications**: LibreOffice, Thunderbird, Firefox ESR, VS Code
- **Accessibility Support**: Screen reader, magnification, high contrast themes
- **Multi-language Support**: International fonts and input methods

### 🔐 Security & Compliance

- **Endpoint Protection**: ClamAV antivirus with real-time scanning
- **Data Loss Prevention**: USB blocking, file monitoring, content inspection
- **Application Security**: Sandboxing with Firejail, code signing verification
- **Multi-factor Authentication**: Smart card, biometric, and U2F support
- **Compliance Frameworks**: SOC 2, ISO 27001, NIST alignment

### 🏢 Enterprise Integration

- **Identity Management**: Active Directory, Azure AD, LDAP integration
- **Single Sign-On**: SAML, OIDC, OAuth2 support
- **VPN Integration**: OpenVPN, OpenConnect, WireGuard clients
- **Remote Management**: SSH, VNC, RDP access with monitoring
- **Device Management**: Automated provisioning and policy enforcement

### 💼 Productivity Suite

- **Office Applications**: LibreOffice with enterprise templates
- **Communication Tools**: Teams, Slack, Element, Zoom integration
- **PDF Management**: Editing, signing, encryption capabilities
- **Development Tools**: VSCode, Git, Docker, multiple language support
- **Remote Work**: File sync, time tracking, collaboration tools

## Quick Start

### 1. Basic Workstation Deployment

```bash
# Build the enterprise workstation configuration
nix build .#nixosConfigurations.enterprise-workstation.config.system.build.toplevel

# Deploy to target workstation
nixos-rebuild switch --flake .#enterprise-workstation --target-host workstation.example.com
```

### 2. Mass Deployment with Ansible

```bash
# Deploy to multiple workstations
ansible-playbook -i inventory/workstations.ini playbooks/workstation-deploy.yml
```

### 3. Image-based Deployment

```bash
# Create workstation image
nix build .#workstation-image

# Deploy image using enterprise imaging tools
dd if=./result/nixos-workstation.img of=/dev/sdb bs=4M status=progress
```

## Configuration

### Desktop Environment

The workstation uses GNOME with enterprise customizations:

```nix
services.xserver = {
  enable = true;
  displayManager.gdm = {
    enable = true;
    wayland = true;
    banner = "Enterprise Workstation - Authorized Users Only";
  };
  desktopManager.gnome.enable = true;
};
```

### Corporate Branding

Desktop themes and settings are locked for consistency:

```nix
environment.etc."dconf/db/site.d/00-enterprise-theme".text = ''
  [org/gnome/desktop/interface]
  gtk-theme='Adwaita-dark'

  [org/gnome/desktop/background]
  picture-uri='file:///etc/enterprise/wallpaper.jpg'

  [org/gnome/shell]
  favorite-apps=['firefox.desktop', 'thunderbird.desktop', 'libreoffice-writer.desktop']
'';
```

### User Management

Enterprise users are configured with SSH key authentication:

```nix
users.users = {
  enterprise-user = {
    isNormalUser = true;
    extraGroups = [ "wheel" "networkmanager" "audio" "video" "input" ];
    openssh.authorizedKeys.keys = [
      "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIG... user@company.com"
    ];
    hashedPassword = "!"; # SSH key authentication only
  };
};
```

### Security Configuration

Comprehensive security hardening includes:

```nix
security = {
  # Multi-layered access control
  sudo.wheelNeedsPassword = true;
  apparmor.enable = true;
  auditd.enable = true;

  # Smart card support
  pam.u2f.enable = true;

  # TPM integration
  tpm2.enable = true;
};
```

## Security Features

### Endpoint Protection

#### ClamAV Antivirus

- **Real-time scanning**: Monitors file system changes
- **Scheduled scans**: Daily full system scans
- **Quarantine system**: Automatic threat isolation
- **Update management**: Regular signature updates

```bash
# Check antivirus status
systemctl status clamav-daemon
systemctl status clamav-realtime

# Manual scan
clamdscan /path/to/scan

# View quarantine
ls -la /var/lib/clamav/quarantine/
```

#### Data Loss Prevention

- **USB device control**: Configurable device whitelisting
- **File monitoring**: Sensitive data detection
- **Screen capture protection**: Prevents unauthorized screenshots
- **Camera/microphone access**: Controlled via Polkit policies

```bash
# Check USB device policy
cat /etc/udev/rules.d/99-usb-policy.rules

# Monitor sensitive files
journalctl -u sensitive-file-monitor -f

# View DLP events
tail -f /var/log/dlp-events.log
```

### Application Security

#### Sandboxing with Firejail

Applications run in isolated environments:

```bash
# Check sandboxed applications
firejail --list

# Run application in sandbox
firejail firefox

# View sandbox profiles
ls /etc/firejail/
```

#### Browser Security

- **Firefox ESR**: Enterprise security policies
- **Extension control**: Managed extension installation
- **Safe browsing**: Enhanced phishing protection
- **Certificate management**: Enterprise CA integration

### Network Security

#### DNS Filtering

```nix
networking.nameservers = [
  "1.1.1.2"    # Cloudflare for Families
  "1.0.0.2"
  "208.67.222.123"  # OpenDNS FamilyShield
];
```

#### Firewall Configuration

```nix
networking.firewall = {
  enable = true;
  allowedTCPPorts = [ ]; # No open ports by default
  extraCommands = ''
    # Allow enterprise network access
    iptables -A OUTPUT -d 10.0.0.0/8 -j ACCEPT
    iptables -A OUTPUT -d 172.16.0.0/12 -j ACCEPT
    iptables -A OUTPUT -d 192.168.0.0/16 -j ACCEPT
  '';
};
```

## Enterprise Integration

### Identity Management

#### Active Directory Integration

```nix
# Kerberos configuration
krb5 = {
  enable = true;
  realms = {
    "ENTERPRISE.COM" = {
      admin_server = "ad.enterprise.com";
      kdc = [ "ad.enterprise.com" ];
    };
  };
};

# SSSD configuration
services.sssd = {
  enable = true;
  config = ''
    [sssd]
    domains = enterprise.com

    [domain/enterprise.com]
    id_provider = ad
    auth_provider = ad
    chpass_provider = ad
    access_provider = simple
  '';
};
```

#### Single Sign-On (SSO)

Support for multiple SSO protocols:

- **SAML 2.0**: Industry standard for enterprise SSO
- **OpenID Connect**: Modern authentication protocol
- **OAuth 2.0**: API authentication and authorization
- **Kerberos**: Windows domain integration

### VPN Integration

Multiple VPN clients are pre-configured:

```bash
# OpenVPN connection
nmcli connection import type openvpn file company.ovpn

# OpenConnect (Cisco AnyConnect)
openconnect --user=username vpn.company.com

# WireGuard
wg-quick up company-vpn
```

### Remote Management

#### SSH Configuration

```nix
services.openssh = {
  enable = true;
  settings = {
    PermitRootLogin = "no";
    PasswordAuthentication = false;
    PubkeyAuthentication = true;
    MaxAuthTries = 3;
    ClientAliveInterval = 300;
  };
};
```

#### Device Monitoring

```bash
# View device inventory
cat /var/lib/workstation-manager/inventory/$(hostname)-$(date +%Y%m%d).json

# Check compliance status
systemctl status compliance-check

# View health metrics
cat /var/lib/workstation-manager/health/health-latest.json
```

## Productivity Applications

### Office Suite

#### LibreOffice Configuration

- **Enterprise templates**: Company letterheads and documents
- **Security settings**: Macro restrictions and document protection
- **Format support**: Microsoft Office compatibility
- **Collaboration**: Document sharing and version control

```bash
# Open specific document types
libreoffice --writer document.docx
libreoffice --calc spreadsheet.xlsx
libreoffice --impress presentation.pptx
```

#### PDF Tools

- **Editing**: Master PDF Editor for document modification
- **Signing**: Digital signatures with smart cards
- **Forms**: PDF form filling and submission
- **Encryption**: Password protection and certificate encryption

### Communication Tools

#### Email Configuration

Thunderbird with enterprise security:

```json
{
  "policies": {
    "Preferences": {
      "mail.phishing.detection.enabled": true,
      "mailnews.message_display.disable_remote_image": true,
      "security.tls.version.min": 3
    },
    "Certificates": {
      "ImportEnterpriseRoots": true
    }
  }
}
```

#### Messaging Platforms

- **Microsoft Teams**: Native Linux client with full features
- **Slack**: Workspace integration with SSO
- **Element**: Matrix protocol for secure messaging
- **Signal**: End-to-end encrypted communication

### Development Tools

#### Visual Studio Code

Pre-configured with enterprise extensions:

```bash
# Install enterprise extensions
code --install-extension ms-vscode.cpptools
code --install-extension ms-python.python
code --install-extension ms-vscode.vscode-typescript-next

# Configure enterprise settings
code --user-data-dir /etc/enterprise/vscode-config
```

#### Git Configuration

Enterprise-ready version control:

```nix
programs.git = {
  enable = true;
  config = {
    user.name = "Enterprise Developer";
    user.email = "developer@enterprise.local";
    commit.gpgsign = true;
    tag.gpgsign = true;
    transfer.fsckobjects = true;
  };
};
```

## Device Management

### Automated Provisioning

#### Zero-Touch Deployment

```bash
# Create deployment image
./scripts/create-deployment-image.sh --profile enterprise-workstation

# Configure PXE boot
cp deployment-image.iso /srv/tftp/nixos-workstation.iso

# Deploy via network boot
dhcp-option 67 "nixos-workstation.iso"
```

#### User Provisioning

```bash
# Sync user profile from AD
rsync -av "ldap://ad.enterprise.com/profiles/$USERNAME/" "/home/$USERNAME/"

# Apply group policies
./scripts/apply-group-policies.sh --user "$USERNAME"

# Configure user applications
./scripts/setup-user-apps.sh --profile enterprise-user
```

### Software Deployment

#### Package Management

```bash
# Install enterprise applications
nix-env -iA nixos.libreoffice-fresh
nix-env -iA nixos.thunderbird
nix-env -iA nixos.teams-for-linux

# Update all packages
nixos-rebuild switch --upgrade

# Rollback if needed
nixos-rebuild switch --rollback
```

#### Application Catalog

```bash
# View available applications
cat /var/lib/workstation-manager/app-catalog/catalog.json

# Request application installation
curl -X POST http://app-catalog.enterprise.local/request \
  -d '{"application": "vscode", "justification": "development work"}'
```

### Compliance Monitoring

#### Automated Checks

```bash
# Run compliance assessment
systemctl start compliance-check

# View compliance report
cat /var/lib/workstation-manager/compliance/$(hostname)-$(date +%Y%m%d).json

# Check compliance score
jq '.compliance_score' /var/lib/workstation-manager/compliance/latest.json
```

#### Audit Logging

```bash
# View audit events
ausearch -m LOGIN_FAILED
ausearch -m USER_AUTH
ausearch -m SYSCALL -k file_access

# Monitor real-time events
auditctl -w /etc/passwd -p wa -k identity_changes
```

## Troubleshooting

### Common Issues

#### Desktop Environment Problems

```bash
# Restart GNOME Shell
killall gnome-shell

# Reset user settings
dconf reset -f /org/gnome/

# Check display manager
systemctl status gdm
journalctl -u gdm -f
```

#### Security Service Issues

```bash
# Check antivirus status
systemctl status clamav-daemon
journalctl -u clamav-daemon -f

# Verify firewall rules
iptables -L -n
systemctl status iptables

# Test smart card
pkcs11-tool --list-slots
```

#### Network Connectivity

```bash
# Check VPN status
nmcli connection show --active
systemctl status openvpn@company

# Test DNS resolution
nslookup company.com
dig @1.1.1.2 company.com

# Verify network policy
ip route show
ip addr show
```

### Log Analysis

#### System Logs

```bash
# View system events
journalctl --since "1 hour ago" | grep -i error

# Monitor authentication
journalctl -u sshd -f
tail -f /var/log/auth.log

# Check service status
systemctl --failed
systemctl list-units --type=service --state=failed
```

#### Security Events

```bash
# Failed login attempts
grep "Failed password" /var/log/auth.log

# USB device events
journalctl -t usb-monitor

# File access monitoring
journalctl -t sensitive-file-monitor

# Network security events
journalctl -t security-monitor
```

### Performance Optimization

#### Resource Monitoring

```bash
# System performance
htop
iotop
nethogs

# Disk usage
df -h
du -sh /home/*

# Memory usage
free -h
cat /proc/meminfo
```

#### Application Performance

```bash
# Browser performance
firefox --safe-mode

# Office suite optimization
libreoffice --headless --convert-to pdf document.docx

# Development tools
code --disable-extensions
```

## Maintenance

### Regular Tasks

#### Daily

- Monitor security alerts and notifications
- Check system health dashboards
- Review failed login attempts

#### Weekly

- Update antivirus signatures
- Review compliance reports
- Check disk space and cleanup
- Validate backup integrity

#### Monthly

- Security patch assessment
- User training updates
- Policy compliance review
- Performance optimization

#### Quarterly

- Full security audit
- Compliance framework updates
- Disaster recovery testing
- User satisfaction survey

### Update Procedures

#### System Updates

```bash
# Check for updates
nix-channel --update
nixos-rebuild dry-build

# Apply updates with backup
nixos-rebuild switch --upgrade

# Verify system health
systemctl is-system-running
./scripts/workstation-validation.sh
```

#### Security Updates

```bash
# Update antivirus signatures
freshclam

# Update security policies
git pull origin main
nixos-rebuild switch

# Refresh certificates
update-ca-certificates
```

## Deployment Scenarios

### Small Office (< 50 users)

- Manual deployment with Ansible playbooks
- Shared credentials management
- Basic monitoring and logging
- Weekly maintenance windows

### Medium Enterprise (50-500 users)

- Automated provisioning with PXE boot
- Active Directory integration
- Centralized monitoring and alerting
- Daily update cycles with testing

### Large Corporation (500+ users)

- Zero-touch deployment infrastructure
- Advanced device management (MDM)
- SIEM integration for security monitoring
- Continuous deployment and testing

## Support Resources

### Documentation

- **User Guides**: End-user documentation for applications
- **Admin Guides**: System administration procedures
- **Security Policies**: Enterprise security requirements
- **Troubleshooting**: Common issues and solutions

### Training Materials

- **Security Awareness**: Phishing, malware, data protection
- **Application Training**: Office suite, communication tools
- **Remote Work**: VPN, collaboration, security practices
- **Incident Response**: Reporting procedures and contacts

### Support Contacts

- **Help Desk**: <internal-help@company.com>
- **Security Team**: <security@company.com>
- **IT Operations**: <itops@company.com>
- **Emergency**: +1-555-IT-HELP

---

*This documentation is maintained as part of the nixos-nixies enterprise workstation configuration. Last updated: 2025-01-11*
