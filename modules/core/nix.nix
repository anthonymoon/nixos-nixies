{
  config,
  lib,
  pkgs,
  ...
}: {
  options.nixies.core.nix = with lib; {
    enable = mkEnableOption "nixies Nix configuration" // {default = true;};
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
  config = lib.mkIf config.nixies.core.nix.enable {
    nix = {
      package = pkgs.nixVersions.stable;
      settings = {
        experimental-features = lib.mkIf config.nixies.core.nix.flakes [
          "nix-command"
          "flakes"
        ];
        max-jobs = "auto";
        cores = 0;
        trusted-users = config.nixies.core.nix.trustedUsers;
        substituters = [
          "https://cache.nixos.org/"
        ];
        trusted-public-keys = [
          "cache.nixos.org-1:6NCHdD59X431o0gWypbMrAURkbJ16ZPMQFGspcDShjY="
        ];
        sandbox = true;
        auto-optimise-store = config.nixies.core.nix.optimization.autoOptimise;
        keep-going = true;
        log-lines = 50;
        connect-timeout = 10;
        download-attempts = 3;
        restrict-eval = false;
        allowed-uris = [
          "https://github.com/"
          "https://gitlab.com/"
          "git+https://github.com/"
          "git+https://gitlab.com/"
        ];
      };
      buildMachines = config.nixies.core.nix.buildMachines;
      distributedBuilds = config.nixies.core.nix.buildMachines != [];
      gc = lib.mkIf config.nixies.core.nix.garbageCollection.enable {
        automatic = true;
        dates = config.nixies.core.nix.garbageCollection.schedule;
        options = "--delete-older-than ${toString config.nixies.core.nix.garbageCollection.keepDays}d";
        randomizedDelaySec = "1800";
      };
      optimise = lib.mkIf config.nixies.core.nix.optimization.enable {
        automatic = true;
        dates = ["weekly"];
      };
      extraOptions = ''
        build-users-group = nixbld
        keep-outputs = true
        keep-derivations = true
        stalled-download-timeout = 300
        timeout = 0
        warn-dirty = false
        show-trace = true
      '';
    };
    nixpkgs = {
      config = {
        allowUnfree = lib.mkDefault true;
        allowBroken = lib.mkDefault false;
        allowInsecure = lib.mkDefault false;
        allowUnfreePredicate = pkg:
          builtins.elem (lib.getName pkg) [
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
      overlays = [
        (final: prev: {
          htop = prev.htop.override {
            sensorsSupport = true;
          };
        })
      ];
    };
    system.autoUpgrade = lib.mkIf config.nixies.core.nix.autoUpgrade.enable {
      enable = true;
      channel = "https://nixos.org/channels/${config.nixies.core.nix.autoUpgrade.channel}";
      dates = config.nixies.core.nix.autoUpgrade.schedule;
      allowReboot = lib.mkDefault false;
      randomizedDelaySec = "3600";
    };
    environment = {
      systemPackages = with pkgs; [
        nix-tree
        nix-index
        nix-prefetch-git
        nixos-option
        git
        curl
        wget
        jq
        gcc
        gnumake
        pkg-config
        man-pages
        man-pages-posix
      ];
      etc = {
        "nix/channels".text = ''
          https://nixos.org/channels/nixos-unstable nixos
          https://nixos.org/channels/nixpkgs-unstable nixpkgs
        '';
      };
    };
    documentation = {
      enable = true;
      nixos.enable = true;
      man.enable = true;
      info.enable = true;
      doc.enable = true;
      dev.enable = false;
    };
    system.stateVersion = lib.mkDefault "24.11";
    system = {
      configurationRevision =
        lib.mkIf (config.system.nixos.revision != null)
        config.system.nixos.revision;
      extraSystemBuilderCmds = ''
        cat > $out/build-info << EOF
        Build Date: $(date)
        Build Host: $(hostname)
        Build User: $(whoami)
        Nix Version: ${pkgs.nix.version}
        NixOS Version: ${config.system.nixos.release}
        EOF
      '';
    };
    systemd = {
      services = {
        nix-daemon = {
          serviceConfig = {
            CPUSchedulingPolicy = lib.mkDefault "batch";
            IOSchedulingClass = lib.mkDefault 2;
            IOSchedulingPriority = lib.mkDefault 6;
            MemoryMax = "80%";
            MemorySwapMax = "20%";
          };
        };
        nix-gc = {
          serviceConfig = {
            IOSchedulingClass = 3;
            CPUSchedulingPolicy = "idle";
          };
        };
      };
      tmpfiles.rules = [
        "d /nix/var/nix/gcroots/per-user 0755 root root -"
        "d /nix/var/nix/profiles/per-user 0755 root root -"
      ];
    };
  };
}
