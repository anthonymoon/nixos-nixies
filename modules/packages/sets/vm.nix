{
  config,
  lib,
  pkgs,
  inputs,
  ...
}: let
  nixies-lib = import ../../../lib {inherit inputs lib;};
in
  (nixies-lib.mkUnifiedModule {
    name = "packages-vm";
    description = "Virtualization and guest tools packages for running in virtual machines or providing VM services";
    category = "packages";
    options = with lib; {
      enable = mkEnableOption "VM and virtualization package set";
      guest-tools = {
        enable = mkEnableOption "virtual machine guest tools and optimizations" // {default = true;};
        virtio = {
          enable = mkEnableOption "VirtIO drivers and tools" // {default = true;};
          drivers = {
            disk = mkEnableOption "VirtIO disk drivers" // {default = true;};
            network = mkEnableOption "VirtIO network drivers" // {default = true;};
            gpu = mkEnableOption "VirtIO GPU drivers";
            input = mkEnableOption "VirtIO input drivers" // {default = true;};
            serial = mkEnableOption "VirtIO serial console support";
          };
          optimizations = mkEnableOption "VirtIO performance optimizations" // {default = true;};
        };
        kvm-guest = {
          enable = mkEnableOption "KVM guest optimizations" // {default = true;};
          tools = mkEnableOption "KVM guest tools and utilities";
          clock-sync = mkEnableOption "KVM guest clock synchronization" // {default = true;};
          memory-ballooning = mkEnableOption "KVM memory ballooning support";
        };
        vmware = {
          enable = mkEnableOption "VMware guest tools";
          open-vm-tools = mkEnableOption "Open VM Tools";
          vmware-tools = mkEnableOption "Official VMware Tools";
          graphics = mkEnableOption "VMware graphics optimization";
          shared-folders = mkEnableOption "VMware shared folders support";
        };
        virtualbox = {
          enable = mkEnableOption "VirtualBox guest additions";
          graphics = mkEnableOption "VirtualBox graphics drivers";
          shared-folders = mkEnableOption "VirtualBox shared folders";
          clipboard = mkEnableOption "VirtualBox clipboard integration";
          drag-and-drop = mkEnableOption "VirtualBox drag and drop";
        };
        xen = {
          enable = mkEnableOption "Xen guest tools";
          pv-drivers = mkEnableOption "Xen paravirtualized drivers";
          hvm-drivers = mkEnableOption "Xen HVM drivers";
        };
        hyper-v = {
          enable = mkEnableOption "Hyper-V guest integration";
          services = mkEnableOption "Hyper-V integration services";
          kvp = mkEnableOption "Hyper-V Key-Value Pair exchange";
          vss = mkEnableOption "Hyper-V Volume Shadow Copy";
        };
      };
      host-tools = {
        enable = mkEnableOption "virtualization host tools and management";
        qemu = {
          enable = mkEnableOption "QEMU virtualization platform";
          kvm = mkEnableOption "KVM hardware acceleration" // {default = true;};
          user-networking = mkEnableOption "QEMU user networking";
          system-emulation = mkEnableOption "QEMU system emulation" // {default = true;};
          tools = mkEnableOption "QEMU management tools";
        };
        libvirt = {
          enable = mkEnableOption "libvirt virtualization management";
          qemu-support = mkEnableOption "libvirt QEMU/KVM support" // {default = true;};
          networking = mkEnableOption "libvirt virtual networking";
          storage = mkEnableOption "libvirt storage management";
          gui-tools = mkEnableOption "libvirt GUI management tools";
        };
        docker = {
          enable = mkEnableOption "Docker containerization platform";
          compose = mkEnableOption "Docker Compose orchestration";
          machine = mkEnableOption "Docker Machine provisioning";
        };
        podman = {
          enable = mkEnableOption "Podman rootless containers";
          compose = mkEnableOption "Podman Compose compatibility";
          buildah = mkEnableOption "Buildah container building";
        };
      };
      performance = {
        enable = mkEnableOption "virtualization performance optimizations" // {default = true;};
        cpu = {
          host-passthrough = mkEnableOption "CPU host passthrough for VMs";
          numa-optimization = mkEnableOption "NUMA topology optimization";
          cpu-pinning = mkEnableOption "CPU core pinning support";
        };
        memory = {
          huge-pages = mkEnableOption "huge pages support for VMs";
          memory-overcommit = mkEnableOption "memory overcommit optimization";
          ksm = mkEnableOption "Kernel Same-page Merging";
        };
        storage = {
          virtio-scsi = mkEnableOption "VirtIO SCSI optimization";
          io-threads = mkEnableOption "I/O thread optimization";
          cache-optimization = mkEnableOption "disk cache optimization";
        };
        network = {
          virtio-net = mkEnableOption "VirtIO network optimization";
          sr-iov = mkEnableOption "SR-IOV network virtualization";
          bridge-optimization = mkEnableOption "network bridge optimization";
        };
      };
      security = {
        enable = mkEnableOption "virtualization security features";
        isolation = {
          selinux = mkEnableOption "SELinux virtualization policies";
          apparmor = mkEnableOption "AppArmor virtualization profiles";
          seccomp = mkEnableOption "seccomp filtering for containers";
        };
        encryption = {
          luks = mkEnableOption "LUKS disk encryption for VMs";
          tpm = mkEnableOption "TPM (Trusted Platform Module) support";
          secure-boot = mkEnableOption "UEFI Secure Boot support";
        };
      };
      development = {
        enable = mkEnableOption "virtualization development tools";
        vagrant = mkEnableOption "Vagrant development environments";
        packer = mkEnableOption "Packer image building";
        terraform = mkEnableOption "Terraform infrastructure provisioning";
        testing = {
          testcontainers = mkEnableOption "Testcontainers testing framework";
          molecule = mkEnableOption "Molecule testing for Ansible";
        };
      };
    };
    config = {
      cfg,
      config,
      lib,
      pkgs,
    }:
      lib.mkIf cfg.enable {
        environment.systemPackages = with pkgs;
          lib.flatten [
            (lib.optionals cfg.guest-tools.virtio.enable [
              pciutils
              usbutils
            ])
            (lib.optionals cfg.guest-tools.vmware.open-vm-tools [
              open-vm-tools
            ])
            (lib.optionals cfg.guest-tools.virtualbox.enable [
              virtualbox-guest-additions
            ])
            (lib.optionals cfg.guest-tools.kvm-guest.tools [
              qemu-guest-agent
            ])
            (lib.optionals cfg.host-tools.qemu.enable [
              qemu
              qemu_kvm
            ])
            (lib.optionals cfg.host-tools.qemu.tools [
              qemu-utils
              qemu-img
            ])
            (lib.optionals cfg.host-tools.libvirt.enable [
              libvirt
              libvirt-glib
            ])
            (lib.optionals cfg.host-tools.libvirt.gui-tools [
              virt-manager
              virt-viewer
              virt-top
            ])
            (lib.optionals cfg.host-tools.docker.enable [
              docker
            ])
            (lib.optionals cfg.host-tools.docker.compose [
              docker-compose
            ])
            (lib.optionals cfg.host-tools.podman.enable [
              podman
              podman-compose
            ])
            (lib.optionals cfg.host-tools.podman.buildah [
              buildah
              skopeo
            ])
            (lib.optionals cfg.development.vagrant [
              vagrant
            ])
            (lib.optionals cfg.development.packer [
              packer
            ])
            (lib.optionals cfg.development.terraform [
              terraform
            ])
            (lib.optionals cfg.performance.enable [
              htop
              iotop
              sysstat
              numactl
            ])
            [
              bridge-utils
              iptables
              dnsmasq
              dmidecode
              lscpu
              lsblk
              iproute2
              nettools
            ]
          ];
        virtualisation = lib.mkMerge [
          (lib.mkIf cfg.host-tools.libvirt.enable {
            libvirtd = {
              enable = true;
              qemu = lib.mkIf cfg.host-tools.libvirt.qemu-support {
                package = pkgs.qemu_kvm;
                runAsRoot = false;
                swtpm.enable = cfg.security.encryption.tpm;
                ovmf.enable = true;
                ovmf.packages = [pkgs.OVMF.fd];
              };
              onBoot = "ignore";
              onShutdown = "shutdown";
            };
          })
          (lib.mkIf cfg.host-tools.docker.enable {
            docker = {
              enable = true;
              enableOnBoot = true;
              autoPrune = {
                enable = true;
                dates = "weekly";
                flags = ["--all"];
              };
              extraOptions = lib.concatStringsSep " " [
                "--default-runtime=runc"
                "--log-driver=journald"
                "--live-restore"
              ];
            };
          })
          (lib.mkIf cfg.host-tools.podman.enable {
            virtualisation = {
              podman = {
                enable = true;
                dockerCompat = true;
                defaultNetwork.settings.dns_enabled = true;
                autoPrune = {
                  enable = true;
                  dates = "weekly";
                };
              };
              containers.enable = true;
            };
          })
        ];
        services = lib.mkMerge [
          (lib.mkIf cfg.guest-tools.kvm-guest.enable {
            qemuGuest.enable = true;
          })
          (lib.mkIf cfg.guest-tools.vmware.open-vm-tools {
            open-vm-tools.enable = true;
          })
          (lib.mkIf cfg.guest-tools.enable {
            spice-vdagentd.enable = true;
          })
          (lib.mkIf cfg.guest-tools.kvm-guest.clock-sync {
            chrony = {
              enable = true;
              servers = ["pool.ntp.org"];
              extraConfig = ''
                makestep 1.0 3
                rtcsync
              '';
            };
          })
        ];
        boot = {
          kernelModules = lib.flatten [
            (lib.optionals cfg.host-tools.qemu.kvm [
              "kvm-intel"
              "kvm-amd"
            ])
            (lib.optionals cfg.guest-tools.virtio.enable [
              "virtio_pci"
              "virtio_blk"
              "virtio_net"
              "virtio_console"
            ])
            (lib.optionals cfg.guest-tools.virtio.drivers.gpu [
              "virtio_gpu"
            ])
            (lib.optionals (cfg.host-tools.docker.enable || cfg.host-tools.podman.enable) [
              "overlay"
              "br_netfilter"
            ])
            (lib.optionals cfg.host-tools.libvirt.networking [
              "bridge"
              "veth"
            ])
          ];
          initrd.kernelModules = lib.flatten [
            (lib.optionals cfg.guest-tools.virtio.enable [
              "virtio_pci"
              "virtio_blk"
              "virtio_net"
            ])
            (lib.optionals cfg.guest-tools.vmware.enable [
              "vmw_pvscsi"
              "vmxnet3"
            ])
          ];
          kernelParams = lib.flatten [
            (lib.optionals cfg.performance.cpu.host-passthrough [
              "kvm.ignore_msrs=1"
            ])
            (lib.optionals cfg.performance.memory.huge-pages [
              "hugepagesz=1G"
              "hugepages=4"
            ])
            (lib.optionals cfg.performance.storage.virtio-scsi [
              "virtio_scsi.cmd_per_lun=128"
            ])
          ];
          kernel.sysctl = lib.mkMerge [
            (lib.mkIf (cfg.host-tools.docker.enable || cfg.host-tools.podman.enable) {
              "net.bridge.bridge-nf-call-iptables" = 1;
              "net.bridge.bridge-nf-call-ip6tables" = 1;
              "net.ipv4.ip_forward" = 1;
            })
            (lib.mkIf cfg.host-tools.libvirt.networking {
              "net.ipv4.ip_forward" = 1;
              "net.ipv6.conf.all.forwarding" = 1;
            })
            (lib.mkIf cfg.performance.memory.ksm {
              "kernel.shmmax" = 134217728;
              "kernel.shmall" = 2097152;
            })
          ];
        };
        hardware = {
          cpu.intel.updateMicrocode = lib.mkDefault true;
          cpu.amd.updateMicrocode = lib.mkDefault true;
          enableAllFirmware = true;
          enableRedistributableFirmware = true;
          opengl = lib.mkIf (cfg.guest-tools.vmware.graphics || cfg.guest-tools.virtualbox.graphics) {
            enable = true;
            driSupport = true;
            driSupport32Bit = true;
          };
        };
        security = lib.mkMerge [
          {
            polkit.extraConfig = ''
              polkit.addRule(function(action, subject) {
              if (action.id == "org.libvirt.unix.manage" &&
              subject.isInGroup("libvirtd")) {
              return polkit.Result.YES;
              }
              });
              polkit.addRule(function(action, subject) {
              if (action.id.indexOf("org.freedesktop.machine1.") == 0 &&
              subject.isInGroup("wheel")) {
              return polkit.Result.YES;
              }
              });
            '';
          }
          (lib.mkIf cfg.security.isolation.apparmor {
            apparmor = {
              enable = true;
              packages = with pkgs; [
                apparmor-profiles
              ];
            };
          })
        ];
        users.extraGroups = lib.mkMerge [
          (lib.mkIf cfg.host-tools.libvirt.enable {
            libvirtd = {};
            kvm = {};
          })
          (lib.mkIf cfg.host-tools.docker.enable {
            docker = {};
          })
          (lib.mkIf cfg.host-tools.qemu.enable {
            qemu-libvirtd = {};
          })
        ];
        environment.variables = lib.mkMerge [
          {
            VIRTUALIZATION_GUEST =
              if cfg.guest-tools.kvm-guest.enable
              then "kvm"
              else if cfg.guest-tools.vmware.enable
              then "vmware"
              else if cfg.guest-tools.virtualbox.enable
              then "virtualbox"
              else "none";
            VIRTUALIZATION_HOST =
              if cfg.host-tools.libvirt.enable
              then "libvirt"
              else if cfg.host-tools.docker.enable
              then "docker"
              else if cfg.host-tools.podman.enable
              then "podman"
              else "none";
          }
          (lib.mkIf cfg.host-tools.docker.enable {
            DOCKER_HOST = "unix:///var/run/docker.sock";
          })
          (lib.mkIf cfg.host-tools.libvirt.enable {
            LIBVIRT_DEFAULT_URI = "qemu:///system";
          })
        ];
        networking = {
          enableIPv6 = true;
          firewall = {
            checkReversePath = false;
            trustedInterfaces = lib.flatten [
              (lib.optionals cfg.host-tools.libvirt.networking ["virbr+"])
              (lib.optionals cfg.host-tools.docker.enable ["docker+"])
              (lib.optionals cfg.host-tools.podman.enable ["podman+"])
            ];
            allowedTCPPorts = lib.flatten [
              (lib.optionals cfg.host-tools.libvirt.enable [5900 5901 5902])
            ];
          };
        };
        systemd.tmpfiles.rules = [
          "d /tmp/libvirt 0755 root root 30d"
          "d /var/lib/libvirt/images 0755 root root -"
          "d /var/lib/containers 0755 root root -"
        ];
      };
    dependencies = ["core" "hardware"];
  }) {
    inherit config lib pkgs inputs;
  }
