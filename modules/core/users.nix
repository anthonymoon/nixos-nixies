{
  config,
  lib,
  pkgs,
  ...
}: {
  # User management and authentication configuration
  options.unified.core.users = with lib; {
    enable = mkEnableOption "unified user management" // {default = true;};
    
    defaultUser = {
      enable = mkEnableOption "create default user account";
      
      name = mkOption {
        type = types.str;
        default = "user";
        description = "Default user account name";
      };
      
      shell = mkOption {
        type = types.package;
        default = pkgs.bash;
        description = "Default user shell";
      };
      
      extraGroups = mkOption {
        type = types.listOf types.str;
        default = ["wheel" "networkmanager"];
        description = "Additional groups for default user";
      };
      
      homeDirectory = mkOption {
        type = types.str;
        default = "/home/user";
        description = "Home directory path for default user";
      };
    };
    
    security = {
      passwordPolicy = mkEnableOption "enforce strong password policy";
      
      sudoTimeout = mkOption {
        type = types.int;
        default = 15;
        description = "Sudo timeout in minutes";
      };
      
      maxLoginTries = mkOption {
        type = types.int;
        default = 3;
        description = "Maximum login attempts before lockout";
      };
    };
    
    ssh = {
      enableForUsers = mkEnableOption "enable SSH access for users";
      
      keyBasedOnly = mkEnableOption "require SSH key authentication" // {default = true;};
      
      allowedUsers = mkOption {
        type = types.listOf types.str;
        default = [];
        description = "Users allowed to access via SSH";
      };
    };
  };

  config = lib.mkIf config.unified.core.users.enable {
    # User account configuration
    users = {
      # Mutable users for flexibility
      mutableUsers = lib.mkDefault true;
      
      # Default user creation
      users = lib.mkMerge [
        (lib.mkIf config.unified.core.users.defaultUser.enable {
          ${config.unified.core.users.defaultUser.name} = {
            isNormalUser = true;
            home = config.unified.core.users.defaultUser.homeDirectory;
            shell = config.unified.core.users.defaultUser.shell;
            extraGroups = config.unified.core.users.defaultUser.extraGroups;
            description = "Default system user";
          };
        })
        
        # Root account security
        {
          root = {
            hashedPassword = lib.mkDefault "!"; # Disable root password by default
          };
        }
      ];
      
      # Default groups
      groups = {
        users = {};
        wheel = {};
        networkmanager = {};
        audio = {};
        video = {};
        input = {};
        plugdev = {};
      };
    };

    # Security configuration
    security = {
      # Sudo configuration
      sudo = {
        enable = true;
        wheelNeedsPassword = lib.mkDefault true;
        
        # Sudo timeout
        extraConfig = ''
          Defaults timestamp_timeout=${toString config.unified.core.users.security.sudoTimeout}
          Defaults lecture=never
          Defaults pwfeedback
        '';
        
        # Additional security rules
        extraRules = [
          {
            groups = ["wheel"];
            commands = [
              {
                command = "${pkgs.systemd}/bin/systemctl";
                options = ["NOPASSWD"];
              }
              {
                command = "${pkgs.systemd}/bin/journalctl";
                options = ["NOPASSWD"];
              }
            ];
          }
        ];
      };
      
      # PAM configuration
      pam = {
        # Login delays after failed attempts
        failDelay = {
          enable = true;
          delay = 2000000; # 2 seconds in microseconds
        };
        
        # Additional PAM security
        services = {
          login.failCountInterval = lib.mkDefault 900; # 15 minutes
          passwd.limits = lib.mkIf config.unified.core.users.security.passwordPolicy [
            {
              domain = "*";
              type = "hard";
              item = "maxlogins";
              value = "4";
            }
          ];
        };
      };
      
      # Login attempt limiting
      loginDefs.settings = {
        FAIL_DELAY = 3;
        LOGIN_RETRIES = config.unified.core.users.security.maxLoginTries;
        LOGIN_TIMEOUT = 60;
        UMASK = "077";
      };
      
      # Additional security
      protectKernelImage = lib.mkDefault true;
    };

    # SSH configuration
    services.openssh = lib.mkIf config.unified.core.users.ssh.enableForUsers {
      enable = true;
      
      settings = {
        # Authentication
        PasswordAuthentication = !config.unified.core.users.ssh.keyBasedOnly;
        PermitRootLogin = "no";
        PubkeyAuthentication = true;
        AuthenticationMethods = lib.mkIf config.unified.core.users.ssh.keyBasedOnly "publickey";
        
        # Connection settings
        ClientAliveInterval = 300;
        ClientAliveCountMax = 2;
        MaxAuthTries = config.unified.core.users.security.maxLoginTries;
        MaxSessions = 4;
        
        # Security
        Protocol = 2;
        X11Forwarding = false;
        AllowTcpForwarding = "no";
        AllowAgentForwarding = "no";
        PermitTunnel = "no";
        
        # User restrictions
        AllowUsers = lib.mkIf (config.unified.core.users.ssh.allowedUsers != [])
          config.unified.core.users.ssh.allowedUsers;
      };
      
      # Key exchange and crypto
      extraConfig = ''
        # Strong cryptography
        KexAlgorithms curve25519-sha256@libssh.org,diffie-hellman-group16-sha512,diffie-hellman-group18-sha512
        Ciphers aes256-gcm@openssh.com,aes128-gcm@openssh.com,aes256-ctr,aes192-ctr,aes128-ctr
        MACs hmac-sha2-256-etm@openssh.com,hmac-sha2-512-etm@openssh.com,hmac-sha2-256,hmac-sha2-512
        
        # Additional security
        DebianBanner no
        VersionAddendum none
      '';
    };

    # Shell configuration
    programs = {
      # Bash improvements
      bash = {
        enableCompletion = true;
        enableLsColors = true;
      };
      
      # Command-not-found
      command-not-found.enable = true;
      
      # Less pager
      less.enable = true;
      
      # Default editor
      nano.nanorc = ''
        set tabsize 2
        set autoindent
        set smooth
      '';
    };

    # Environment
    environment = {
      # Default shell settings
      shells = with pkgs; [bash zsh fish];
      
      # Login shell message
      motd = ''
        Welcome to NixOS Unified System
        
        Managed by nixos-unified framework
        Documentation: https://github.com/nixos-unified
      '';
      
      # Default packages for all users
      systemPackages = with pkgs; [
        # Basic utilities
        coreutils
        findutils
        grep
        sed
        awk
        curl
        wget
        which
        file
        tree
        
        # Text editors
        nano
        vim
        
        # System tools
        htop
        iotop
        lsof
        psmisc
        procps
        
        # Network tools
        iputils
        netcat
        
        # File management
        rsync
        unzip
        gzip
        tar
      ];
      
      # Session variables
      sessionVariables = {
        EDITOR = lib.mkDefault "nano";
        PAGER = "less";
        LESS = "-R";
      };
    };

    # Home directory management
    users.defaultUserShell = config.unified.core.users.defaultUser.shell;
    
    # XDG configuration
    xdg = {
      autostart.enable = true;
      icons.enable = true;
      menus.enable = true;
      mime.enable = true;
      sounds.enable = true;
    };
  };
}