{lib}: {
  # Package optimization utilities
  optimizePackages = packages: let
    # Group packages by category for lazy evaluation
    categorizePackages = packages: let
      categories = {
        development = ["git" "vim" "vscode" "nodejs" "python3"];
        media = ["mpv" "gimp" "inkscape" "obs-studio"];
        system = ["htop" "tree" "curl" "wget"];
        desktop = ["firefox" "nautilus" "foot"];
      };

      categorize = pkg: category:
        if lib.any (name: lib.hasInfix name (pkg.name or "")) categories.${category}
        then category
        else null;

      getCategoryForPackage = pkg:
        lib.findFirst (cat: categorize pkg cat != null) "other"
        (lib.attrNames categories);
    in
      lib.groupBy getCategoryForPackage packages;
  in
    categorizePackages packages;

  # Lazy evaluation patterns
  lazyEvaluation = {
    # Conditional package loading
    conditionalPackages = condition: packages:
      if condition
      then packages
      else [];

    # Optional package groups
    optionalGroup = enable: packages:
      lib.optionals enable packages;

    # Staged package loading
    stagePackages = {
      essential = []; # Always loaded
      standard = []; # Loaded for workstation profiles
      extended = []; # Loaded for development profiles
    };
  };

  # Build parallelization
  parallelBuild = {
    # Optimize Nix settings for parallel builds
    nixOptimization = {
      nix.settings = {
        max-jobs = "auto";
        cores = 0; # Use all available cores

        # Build isolation for better parallelization
        sandbox = true;

        # Faster evaluation
        eval-cache = true;

        # Optimize store operations
        auto-optimise-store = true;

        # Faster substitution
        http-connections = 128;
        connect-timeout = 5;
      };
    };

    # Service parallelization
    serviceParallelization = services: let
      # Group services by dependency
      parallelGroups = {
        network = ["systemd-networkd" "NetworkManager"];
        audio = ["pipewire" "pulseaudio"];
        display = ["greetd" "gdm" "sddm"];
        system = ["systemd-resolved" "dbus"];
      };
    in
      lib.mapAttrs
      (group: serviceList: {
        systemd.services = lib.genAttrs serviceList (service: {
          after = lib.mkForce [];
          wants = lib.mkForce [];
          wantedBy = ["multi-user.target"];
        });
      })
      parallelGroups;
  };

  # Memory optimization
  memoryOptimization = {
    # Optimize package cache
    packageCache = {
      # Enable package cache
      nix.settings.narinfo-cache-positive-ttl = 3600;
      nix.settings.narinfo-cache-negative-ttl = 60;

      # Optimize evaluation cache
      nix.settings.eval-cache = true;
    };

    # Memory-efficient package loading
    efficientLoading = packages: let
      # Sort packages by size/importance
      prioritizePackages = packages:
        lib.sort (a: b: (a.priority or 5) < (b.priority or 5)) packages;
    in
      prioritizePackages packages;

    # Garbage collection optimization
    gcOptimization = {
      nix.gc = {
        automatic = true;
        dates = "weekly";
        options = "--delete-older-than 30d";

        # Optimize GC performance
        persistent = true;
      };

      # Store optimization
      nix.optimise = {
        automatic = true;
        dates = ["weekly"];
      };
    };
  };

  # Network optimization
  networkOptimization = {
    # Faster package downloads
    downloadOptimization = {
      nix.settings = {
        # Multiple parallel downloads
        http-connections = 25;

        # Faster timeouts
        connect-timeout = 5;
        stalled-download-timeout = 300;

        # Better substituters
        substituters = [
          "https://cache.nixos.org"
          "https://nix-community.cachix.org"
        ];

        trusted-public-keys = [
          "cache.nixos.org-1:6NCHdD59X431o0gWypbMrAURkbJ16ZPMQFGspcDShjY="
          "nix-community.cachix.org-1:mB9FSh9qf2dCimDSUo8Zy7bkq5CX+/rkCWyvRCYg3Fs="
        ];
      };
    };

    # Network tuning for performance
    networkTuning = {
      boot.kernel.sysctl = {
        # TCP optimization
        "net.core.rmem_max" = 134217728;
        "net.core.wmem_max" = 134217728;
        "net.ipv4.tcp_rmem" = "4096 65536 134217728";
        "net.ipv4.tcp_wmem" = "4096 65536 134217728";

        # Network buffer optimization
        "net.core.netdev_max_backlog" = 5000;
        "net.core.netdev_budget" = 600;

        # TCP congestion control
        "net.ipv4.tcp_congestion_control" = "bbr";
        "net.core.default_qdisc" = "fq";
      };
    };
  };

  # Disk I/O optimization
  diskOptimization = {
    # Filesystem optimization
    filesystemTuning = {
      # Faster temporary files
      boot.tmp = {
        useTmpfs = true;
        tmpfsSize = "50%";
        cleanOnBoot = true;
      };

      # Optimize file operations
      boot.kernel.sysctl = {
        "vm.dirty_background_ratio" = 10;
        "vm.dirty_ratio" = 20;
        "vm.dirty_writeback_centisecs" = 500;
        "vm.dirty_expire_centisecs" = 3000;
      };
    };

    # SSD optimization
    ssdOptimization = {
      # Enable fstrim
      services.fstrim.enable = true;

      # SSD-specific mount options
      fileSystems."/".options = ["noatime" "nodiratime"];

      # Optimize I/O scheduler
      boot.kernelParams = ["elevator=noop"];
    };
  };

  # Boot optimization
  bootOptimization = {
    # Faster boot
    fastBoot = {
      # Reduce boot timeout
      boot.loader.timeout = 1;

      # Optimize systemd
      systemd.extraConfig = ''
        DefaultTimeoutStopSec=10s
        DefaultTimeoutStartSec=10s
      '';

      # Parallel service startup
      systemd.services.systemd-networkd-wait-online.enable = false;

      # Faster kernel parameters
      boot.kernelParams = [
        "quiet"
        "loglevel=3"
        "systemd.show_status=auto"
        "rd.udev.log_level=3"
      ];
    };

    # Memory optimization during boot
    bootMemoryOptimization = {
      # Reduce initrd size
      boot.initrd.compressor = "zstd";
      boot.initrd.compressorArgs = ["-19" "-T0"];

      # Optimize kernel modules
      boot.kernelModules = []; # Only load necessary modules
    };
  };

  # Performance monitoring
  performanceMonitoring = {
    # System monitoring
    monitoring = {
      # Enable system statistics
      services.sysstat.enable = true;

      # Performance tools
      environment.systemPackages = [
        # Will be resolved with actual pkgs in implementation
      ];
    };

    # Performance metrics
    metrics = {
      # Boot time measurement
      bootTime = "systemd-analyze time";

      # Service analysis
      serviceAnalysis = "systemd-analyze blame";

      # Critical chain analysis
      criticalChain = "systemd-analyze critical-chain";

      # Memory usage
      memoryUsage = "free -h";

      # Disk usage
      diskUsage = "df -h";
    };
  };

  # Performance profiles
  performanceProfiles = {
    minimal = {
      packages = "essential only";
      services = "core services only";
      optimization = "basic";
    };

    balanced = {
      packages = "standard package set";
      services = "common services";
      optimization = "standard optimizations";
    };

    performance = {
      packages = "full package set with optimization";
      services = "all services with tuning";
      optimization = "aggressive optimizations";
    };
  };

  # Benchmark utilities
  benchmarkUtils = {
    # Build time benchmarking
    buildBenchmark = config: {
      # Measure build time
      buildTime = "time nix build";

      # Measure evaluation time
      evalTime = "time nix eval --json .#nixosConfigurations.${config}";

      # Memory usage during build
      buildMemory = "time -v nix build";
    };

    # Runtime benchmarking
    runtimeBenchmark = {
      # Boot time
      bootTime = "systemd-analyze";

      # Service startup time
      serviceTime = "systemd-analyze blame";

      # Memory usage
      memoryBench = "free -h && ps aux --sort=-%mem | head -20";

      # CPU usage
      cpuBench = "top -bn1 | grep 'Cpu(s)'";
    };
  };
}
