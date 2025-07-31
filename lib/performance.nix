{lib}: {
  optimizePackages = packages: let
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
  lazyEvaluation = {
    conditionalPackages = condition: packages:
      if condition
      then packages
      else [];
    optionalGroup = enable: packages:
      lib.optionals enable packages;
    stagePackages = {
      essential = [];
      standard = [];
      extended = [];
    };
  };
  parallelBuild = {
    nixOptimization = {
      nix.settings = {
        max-jobs = "auto";
        cores = 0;
        sandbox = true;
        eval-cache = true;
        auto-optimise-store = true;
        http-connections = 128;
        connect-timeout = 5;
      };
    };
    serviceParallelization = services: let
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
  memoryOptimization = {
    packageCache = {
      nix.settings.narinfo-cache-positive-ttl = 3600;
      nix.settings.narinfo-cache-negative-ttl = 60;
      nix.settings.eval-cache = true;
    };
    efficientLoading = packages: let
      prioritizePackages = packages:
        lib.sort (a: b: (a.priority or 5) < (b.priority or 5)) packages;
    in
      prioritizePackages packages;
    gcOptimization = {
      nix.gc = {
        automatic = true;
        dates = "weekly";
        options = "--delete-older-than 30d";
        persistent = true;
      };
      nix.optimise = {
        automatic = true;
        dates = ["weekly"];
      };
    };
  };
  networkOptimization = {
    downloadOptimization = {
      nix.settings = {
        http-connections = 25;
        connect-timeout = 5;
        stalled-download-timeout = 300;
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
    networkTuning = {
      boot.kernel.sysctl = {
        "net.core.rmem_max" = 134217728;
        "net.core.wmem_max" = 134217728;
        "net.ipv4.tcp_rmem" = "4096 65536 134217728";
        "net.ipv4.tcp_wmem" = "4096 65536 134217728";
        "net.core.netdev_max_backlog" = 5000;
        "net.core.netdev_budget" = 600;
        "net.ipv4.tcp_congestion_control" = "bbr";
        "net.core.default_qdisc" = "fq";
      };
    };
  };
  diskOptimization = {
    filesystemTuning = {
      boot.tmp = {
        useTmpfs = true;
        tmpfsSize = "50%";
        cleanOnBoot = true;
      };
      boot.kernel.sysctl = {
        "vm.dirty_background_ratio" = 10;
        "vm.dirty_ratio" = 20;
        "vm.dirty_writeback_centisecs" = 500;
        "vm.dirty_expire_centisecs" = 3000;
      };
    };
    ssdOptimization = {
      services.fstrim.enable = true;
      fileSystems."/".options = ["noatime" "nodiratime"];
      boot.kernelParams = ["elevator=noop"];
    };
  };
  bootOptimization = {
    fastBoot = {
      boot.loader.timeout = 1;
      systemd.extraConfig = ''
        DefaultTimeoutStopSec=10s
        DefaultTimeoutStartSec=10s
      '';
      systemd.services.systemd-networkd-wait-online.enable = false;
      boot.kernelParams = [
        "quiet"
        "loglevel=3"
        "systemd.show_status=auto"
        "rd.udev.log_level=3"
      ];
    };
    bootMemoryOptimization = {
      boot.initrd.compressor = "zstd";
      boot.initrd.compressorArgs = ["-19" "-T0"];
      boot.kernelModules = [];
    };
  };
  performanceMonitoring = {
    monitoring = {
      services.sysstat.enable = true;
      environment.systemPackages = [
      ];
    };
    metrics = {
      bootTime = "systemd-analyze time";
      serviceAnalysis = "systemd-analyze blame";
      criticalChain = "systemd-analyze critical-chain";
      memoryUsage = "free -h";
      diskUsage = "df -h";
    };
  };
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
  benchmarkUtils = {
    buildBenchmark = config: {
      buildTime = "time nix build";
      evalTime = "time nix eval --json .#nixosConfigurations.${config}.config.system.build.toplevel";
      buildMemory = "time -v nix build";
    };
    runtimeBenchmark = {
      bootTime = "systemd-analyze";
      serviceTime = "systemd-analyze blame";
      memoryBench = "free -h && ps aux --sort=-%mem | head -20";
      cpuBench = "top -bn1 | grep 'Cpu(s)'";
    };
  };
}
