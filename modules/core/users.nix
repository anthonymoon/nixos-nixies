{
  config,
  lib,
  pkgs,
  ...
}: {
  options.unified.core.users = with lib; {
    enable = mkEnableOption "unified user management" // {default = true;};
    defaultUser = {
      enable = mkEnableOption "create default user account";
      name = mkOption {
        type = types.str;
        default = "user";
        description = ''
          Default user account name.
          This user will be created with sudo privileges and NetworkManager access.
        '';
      };
      shell = mkOption {
        type = types.package;
        default = pkgs.bash;
        description = ''
          Default user shell.
          Common options: pkgs.bash, pkgs.zsh, pkgs.fish
        '';
      };
      extraGroups = mkOption {
        type = types.listOf types.str;
        default = ["wheel" "networkmanager"];
        description = ''
          Additional groups for default user.
          - wheel: sudo privileges
          - networkmanager: network configuration
          - audio: audio device access
          - video: video device access
        '';
      };
      homeDirectory = mkOption {
        type = types.str;
        default = "/home/user";
        description = ''
          Home directory path for default user.
          Should match the user name (e.g., /home/alice for user 'alice').
        '';
      };
    };
    security = {
      passwordPolicy = mkEnableOption "enforce strong password policy";
      sudoTimeout = mkOption {
        type = types.int;
        default = 15;
        description = ''
          Sudo timeout in minutes.
          After this period, sudo will require password re-entry.
          Lower values increase security but may reduce usability.
        '';
      };
      maxLoginTries = mkOption {
        type = types.int;
        default = 3;
        description = ''
          Maximum login attempts before lockout.
          This applies to both local and SSH login attempts.
          Default is 3 attempts for security.
        '';
      };
    };
    ssh = {
      enableForUsers = mkEnableOption "enable SSH access for users";
      keyBasedOnly = mkEnableOption "require SSH key authentication" // {default = true;};
      allowedUsers = mkOption {
        type = types.listOf types.str;
        default = [];
        description = ''
          Users allowed to access via SSH.
          If empty, all users can access SSH (subject to other restrictions).
          For security, consider limiting to specific users only.
        '';
      };
    };
  };
  config = lib.mkIf config.unified.core.users.enable {
    users = {
      mutableUsers = lib.mkOverride 1500 true;
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
        {
          root = {
            hashedPassword = lib.mkDefault "!";
          };
        }
      ];
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
    security = {
      sudo = {
        enable = true;
        wheelNeedsPassword = lib.mkDefault true;
        extraConfig = ''
          Defaults timestamp_timeout=${toString config.unified.core.users.security.sudoTimeout}
          Defaults lecture=never
          Defaults pwfeedback
        '';
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
      pam = {
        services = {
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
      loginDefs.settings = {
        FAIL_DELAY = 3;
        LOGIN_RETRIES = config.unified.core.users.security.maxLoginTries;
        LOGIN_TIMEOUT = 60;
        UMASK = "077";
      };
      protectKernelImage = lib.mkDefault true;
    };
    services.openssh = lib.mkIf config.unified.core.users.ssh.enableForUsers {
      enable = true;
      settings = {
        PasswordAuthentication = !config.unified.core.users.ssh.keyBasedOnly;
        PermitRootLogin = "no";
        PubkeyAuthentication = true;
        AuthenticationMethods = lib.mkIf config.unified.core.users.ssh.keyBasedOnly "publickey";
        ClientAliveInterval = 300;
        ClientAliveCountMax = 2;
        MaxAuthTries = config.unified.core.users.security.maxLoginTries;
        MaxSessions = 4;
        Protocol = 2;
        X11Forwarding = false;
        AllowTcpForwarding = "no";
        AllowAgentForwarding = "no";
        PermitTunnel = "no";
        AllowUsers =
          lib.mkIf (config.unified.core.users.ssh.allowedUsers != [])
          config.unified.core.users.ssh.allowedUsers;
      };
      extraConfig = ''
        KexAlgorithms curve25519-sha256@libssh.org,diffie-hellman-group16-sha512,diffie-hellman-group18-sha512
        Ciphers aes256-gcm@openssh.com,aes128-gcm@openssh.com,aes256-ctr,aes192-ctr,aes128-ctr
        MACs hmac-sha2-256-etm@openssh.com,hmac-sha2-512-etm@openssh.com,hmac-sha2-256,hmac-sha2-512
        DebianBanner no
        VersionAddendum none
      '';
    };
    programs = {
      bash = {
        completion.enable = true;
        enableLsColors = true;
      };
      command-not-found.enable = true;
      less.enable = true;
      nano.nanorc = ''
        set tabsize 2
        set autoindent
        set smooth
      '';
    };
    environment = {
      shells = with pkgs; [bash zsh fish];
      interactiveShellInit = ''
        if [ -z "$NIXOS_UNIFIED_MOTD_SHOWN" ]; then
        export NIXOS_UNIFIED_MOTD_SHOWN=1
        echo "Welcome to NixOS Unified System"
        echo ""
        echo "Managed by nixos-unified framework"
        echo "Documentation: https://github.com/nixos-unified"
        echo ""
        fi
      '';
      systemPackages = with pkgs; [
        coreutils
        findutils
        gnugrep
        gnused
        gawk
        curl
        wget
        which
        file
        tree
        nano
        vim
        htop
        iotop
        lsof
        psmisc
        procps
        iputils
        netcat
        rsync
        unzip
        gzip
        gnutar
      ];
      sessionVariables = {
        EDITOR = lib.mkDefault "nano";
        PAGER = "less";
        LESS = "-R";
      };
    };
    users.defaultUserShell = config.unified.core.users.defaultUser.shell;
    xdg = {
      autostart.enable = true;
      icons.enable = true;
      menus.enable = true;
      mime.enable = true;
      sounds.enable = true;
    };
  };
}
