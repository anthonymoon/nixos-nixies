{
  config,
  lib,
  pkgs,
  ...
}: {
  # Nix package manager and system configuration
  options.unified.core.nix = with lib; {
    enable = mkEnableOption "unified Nix configuration" // {default = true;};
    
    flakes = mkEnableOption "enable Nix flakes" // {default = true;};
    
    autoUpgrade = {
      enable = mkEnableOption "automatic system upgrades";
      
      channel = mkOption {
        type = types.str;
        default = "nixos-unstable";
        description = "NixOS channel for automatic upgrades";
      };
      
      schedule = mkOption {
        type = types.str;
        default = "weekly";
        description = "When to run automatic upgrades";
      };
    };
    
    garbageCollection = {
      enable = mkEnableOption "automatic garbage collection" // {default = true;};
      
      schedule = mkOption {
        type = types.str;
        default = "weekly";
        description = "When to run garbage collection";
      };
      
      keepDays = mkOption {
        type = types.int;
        default = 7;
        description = "Days of history to keep";
      };
    };
    
    optimization = {
      enable = mkEnableOption "Nix store optimization" // {default = true;};
      
      autoOptimise = mkEnableOption "automatic store optimization" // {default = true;};
    };
    
    buildMachines = mkOption {
      type = types.listOf types.attrs;
      default = [];
      description = "Remote build machines configuration";
    };
    
    trustedUsers = mkOption {
      type = types.listOf types.str;
      default = ["root" "@wheel"];
      description = "Users trusted to use Nix daemon";
    };
  };

  config = lib.mkIf config.unified.core.nix.enable {
    # Nix configuration
    nix = {
      # Package and daemon settings
      package = pkgs.nixVersions.stable;
      
      # Flakes support
      settings = {
        # Flakes and new commands
        experimental-features = lib.mkIf config.unified.core.nix.flakes [
          "nix-command"
          "flakes"
        ];
        
        # Build settings
        max-jobs = "auto";
        cores = 0; # Use all available cores
        
        # Trusted users
        trusted-users = config.unified.core.nix.trustedUsers;
        
        # Substituters and caches
        substituters = [
          "https://cache.nixos.org/"
          "https://nix-community.cachix.org"
        ];
        
        trusted-public-keys = [
          "cache.nixos.org-1:6NCHdD59X431o0gWypbMrAURkbJ16ZPMQFGspcDShjY="
          "nix-community.cachix.org-1:mB9FSh9qf2dCimDSUo8Zy7bkq5CX+/rkCWyvRCYg3Fs="
        ];
        
        # Build sandbox
        sandbox = true;
        
        # Store optimization
        auto-optimise-store = config.unified.core.nix.optimization.autoOptimise;
        
        # Keep build logs
        keep-going = true;
        log-lines = 50;
        
        # Network settings
        connect-timeout = 10;
        download-attempts = 3;
        
        # Build isolation
        restrict-eval = false; # Allow evaluation of arbitrary expressions
        allowed-uris = [
          "https://github.com/"
          "https://gitlab.com/"
          "git+https://github.com/"
          "git+https://gitlab.com/"
        ];
      };
      
      # Remote builds
      buildMachines = config.unified.core.nix.buildMachines;
      distributedBuilds = config.unified.core.nix.buildMachines != [];
      
      # Garbage collection
      gc = lib.mkIf config.unified.core.nix.garbageCollection.enable {
        automatic = true;
        dates = config.unified.core.nix.garbageCollection.schedule;
        options = "--delete-older-than ${toString config.unified.core.nix.garbageCollection.keepDays}d";
        randomizedDelaySec = "1800"; # 30 minutes random delay
      };
      
      # Store optimization
      optimise = lib.mkIf config.unified.core.nix.optimization.enable {
        automatic = true;
        dates = ["weekly"];
      };
      
      # Additional Nix configuration
      extraOptions = ''
        # Build performance
        build-users-group = nixbld
        keep-outputs = true
        keep-derivations = true
        
        # Timeout settings
        stalled-download-timeout = 300
        timeout = 0
        
        # Logging
        warn-dirty = false
        show-trace = true
      '';
    };

    # Nixpkgs configuration
    nixpkgs = {
      config = {
        # Allow unfree packages (needed for some drivers/firmware)
        allowUnfree = lib.mkDefault true;
        
        # Allow broken packages in emergency
        allowBroken = lib.mkDefault false;
        
        # Allow insecure packages (be careful)
        allowInsecure = lib.mkDefault false;
        
        # Permissive license acceptance
        allowUnfreePredicate = pkg: builtins.elem (lib.getName pkg) [
          # Common unfree packages that are usually needed
          "steam"
          "steam-original"
          "steam-run"
          "nvidia-x11"
          "nvidia-settings"
          "cuda_cudart"
          "discord"
          "spotify"
          "zoom"
          "teams"
          "slack"
          "vscode"
        ];
      };
      
      # System overlays
      overlays = [
        # Performance overlay
        (final: prev: {
          # Optimized builds for common packages
          htop = prev.htop.override {
            sensorsSupport = true;
          };
        })
      ];
    };

    # Auto-upgrade configuration
    system.autoUpgrade = lib.mkIf config.unified.core.nix.autoUpgrade.enable {
      enable = true;
      channel = "https://nixos.org/channels/${config.unified.core.nix.autoUpgrade.channel}";
      dates = config.unified.core.nix.autoUpgrade.schedule;
      allowReboot = lib.mkDefault false; # Safety: don't auto-reboot
      randomizedDelaySec = "3600"; # 1 hour random delay
    };

    # Environment configuration
    environment = {
      # System packages for Nix usage
      systemPackages = with pkgs; [
        # Nix tools
        nix-tree
        nix-index
        nix-prefetch-git
        nixos-option
        
        # Development tools
        git
        curl
        wget
        jq
        
        # Build tools
        gcc
        gnumake
        pkg-config
        
        # Documentation
        man-pages
        man-pages-posix
      ];
      
      # Global Nix configuration
      etc = {
        # Nix channels for root
        "nix/channels".text = ''
          https://nixos.org/channels/nixos-unstable nixos
          https://nixos.org/channels/nixpkgs-unstable nixpkgs
        '';
      };
    };

    # Documentation
    documentation = {
      enable = true;
      nixos.enable = true;
      man.enable = true;
      info.enable = true;
      doc.enable = true;
      
      # Development documentation
      dev.enable = false; # Save space, enable if needed
    };

    # System state version
    system.stateVersion = lib.mkDefault "24.11";
    
    # System configuration
    system = {
      # Configuration revision tracking
      configurationRevision = lib.mkIf (config.system.nixos.revision != null) 
        config.system.nixos.revision;
      
      # Copy system configuration to /run/current-system
      copySystemConfiguration = true;
      
      # Additional system tools
      extraSystemBuilderCmds = ''
        # Create build info file
        cat > $out/build-info << EOF
        Build Date: $(date)
        Build Host: $(hostname)
        Build User: $(whoami)
        Nix Version: ${pkgs.nix.version}
        NixOS Version: ${config.system.nixos.release}
        EOF
      '';
    };

    # Performance tuning for Nix builds
    systemd = {
      services = {
        # Optimize Nix daemon
        nix-daemon = {
          serviceConfig = {
            # CPU and I/O priority
            CPUSchedulingPolicy = "batch";
            IOSchedulingClass = 2;
            IOSchedulingPriority = 6;
            
            # Memory limits (prevent OOM during large builds)
            MemoryMax = "80%";
            MemorySwapMax = "20%";
          };
        };
        
        # Garbage collection service improvements
        nix-gc = {
          serviceConfig = {
            IOSchedulingClass = 3; # Idle priority
            CPUSchedulingPolicy = "idle";
          };
        };
      };
      
      # Tmpfiles for Nix
      tmpfiles.rules = [
        # Ensure Nix directories exist with correct permissions
        "d /nix/var/nix/gcroots/per-user 0755 root root -"
        "d /nix/var/nix/profiles/per-user 0755 root root -"
      ];
    };
  };
}