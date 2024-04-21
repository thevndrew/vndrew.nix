# Edit this configuration file to define what should be installed on
# your system. Help is available in the configuration.nix(5) man page, on
# https://search.nixos.org/options and in the NixOS manual (`nixos-help`).

{ config, inputs, lib, pkgs, pkgs-unstable, ... }:

{
  disabledModules = [ "programs/nh.nix" ];

  imports =
    [ # Include the results of the hardware scan.
      ./hardware-configuration.nix
      "${inputs.nixpkgs-unstable}/nixos/modules/programs/nh.nix"
    ];

  # Use the systemd-boot EFI boot loader.
  boot.loader.systemd-boot.enable = true;
  boot.loader.efi.canTouchEfiVariables = true;
  boot.loader.efi.efiSysMountPoint = "/boot/efi";

  boot.kernelParams = ["xhci_hcd.quirks=270336"];
  #boot.kernel.sysctl = { "xhci_hcd.quirks" = 270336; };
  boot.supportedFilesystems = [ "zfs" ];
  boot.zfs = {
    forceImportRoot = false;
    extraPools = [ "tank00" "tank01" "tank02" ];
  };

  services.zfs.autoScrub = {
    enable = true;
    interval = "monthly";
  };

  fileSystems."/mnt/storage" = {
    fsType = "fuse.mergerfs";
    device = "/mnt/tank00/storage:/mnt/tank01/storage:/mnt/tank02/storage";
    options = ["cache.files=off" "dropcacheonclose=true" "category.create=mfs" "moveonenospc=true" "minfreespace=250G" "fsname=mergerfs" ];
  };

  hardware.sensor.hddtemp = {
    enable = true;
    drives = [
      "/dev/disk/by-id/ata-ST18000NM000J-2TV103_ZR5CR6Z2"
      "/dev/disk/by-id/ata-ST18000NM000J-2TV103_ZR5DT8NB"
      "/dev/disk/by-id/ata-ST20000NM007D-3DJ103_ZVT5F6LH"
      "/dev/disk/by-id/ata-ST20000NM007D-3DJ103_ZVT5HSG7"
      "/dev/disk/by-id/ata-ST20000NM007D-3DJ103_ZVT5JS1S"
      "/dev/disk/by-id/ata-ST20000NM007D-3DJ103_ZVT5KD96"
    ];
    unit = "C";
  };

  powerManagement.cpuFreqGovernor = "powersave";
  powerManagement.powertop.enable = true;
  powerManagement.cpufreq.min = 800000; # 800 Mhz
  powerManagement.cpufreq.max = 4400000; # 4.4 Ghz

  nix = {
    settings = {
        experimental-features = [ "nix-command" "flakes" ];
        warn-dirty = false;
    };
    gc = {
      automatic = true;
      dates = "weekly";
      options = "--delete-older-than 7d";
    };
  };

  security.sudo.enable = true;
  security.sudo.wheelNeedsPassword = false;

  services = {
    openssh = {
      enable = true;
      settings.PasswordAuthentication = false;
      settings.PermitRootLogin = "yes";
      ports = [ 22 2222 ];
    };

    tailscale = {
      enable = true;
      useRoutingFeatures = "both";
    };

    vnstat.enable = true;
  };

  users.groups.storage = {};

  users.mutableUsers = false;
  users.users.andrew = {
    extraGroups = [ "wheel" "podman" "storage" ];
    initialPassword = "andrew";
    home = "/home/andrew";
    isNormalUser = true;
    openssh.authorizedKeys.keys = [ "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIHo+NCpecLu+vJrhgp0deaNXblILsmxxixpTg8pw+WAL" ];  
  };

  users.users.root.initialHashedPassword = "";
  users.users.root.openssh.authorizedKeys.keys = [ "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIHo+NCpecLu+vJrhgp0deaNXblILsmxxixpTg8pw+WAL" ];
  users.users.root.extraGroups = [ "storage" ];

  environment.variables = {
    EDITOR = "nvim";
    HISTSIZE = "";
    HISTFILESIZE = "";
    HISTCONTROL = "ignoreboth";
    HISTTIMEFORMAT = "[%F %T] ";
    HISTFILE = "/home/andrew/.bash_eternal_history";
    PROMPT_COMMAND = "history -a; $PROMPT_COMMAND";
  };

  programs.bash.interactiveShellInit = ''
    shopt -s dotglob
    shopt -s extglob
  '';

  time.timeZone = "America/New_York";

  environment.systemPackages = with pkgs; [
    docker-compose
    htop
    hddtemp
    iotop
    mergerfs
    ncdu
    nmap
    nvme-cli
    tailscale
    tdns-cli
    tmux
    tree
    vim
    neovim
    wget
    git
    ethtool
    jq
    nnn
    rclone
    rsync
    lsof
    dig
    btop
    cht-sh
    ngrep
    starship

    # Do install the docker CLI to talk to podman.
    # Not needed when virtualisation.docker.enable = true;
    docker-client
  ];

  environment.sessionVariables = {
    FLAKE = "/home/andrew/nix-config";
  };

  programs.nh = {
    enable = true;
    package = pkgs-unstable.nh;
    #clean.enable = true;
    #clean.extraArgs = "--keep-since 4d --keep 3";
    flake = "/home/andrew/nix-config";
  };

  networking = {
    hostName = "thousand-sunny";
    hostId = "4a219e7f";

    firewall = {
      # enable the firewall
      enable = true;

      # always allow traffic from your Tailscale network
      trustedInterfaces = [ "tailscale0" ];

      # allow the Tailscale UDP port through the firewall
      allowedUDPPorts = [ config.services.tailscale.port ];

      # allow you to SSH in over the public internet
      allowedTCPPorts = [ 22 2222 ];
    };

    nameservers = [ "100.100.100.100" "9.9.9.9" ];
    search = [ "ainu-kanyu.ts.net" ];
  };

  # Arion works with Docker, but for NixOS-based containers, you need Podman
  # since NixOS 21.05.
  virtualisation = {
    containers = {
      enable = true;
      containersConf = {
        settings.network = {
          dns_bind_port = 54;
        };
      };
    };
    #oci-containers.backend = "podman";
    docker.enable = false;
    podman = {
      enable = true;
      autoPrune = {
        enable = true;
        dates = "weekly";
      };
      dockerSocket.enable = true;
      defaultNetwork.settings.dns_enable = true;
      # extraPackages = [ pkgs.zfs ]; # Required if the host is running ZFS
    };
  };

  systemd.services.wol = {
    enable = true;
    description = "Wake-on-LAN service";
    after = [ "network.target" ];
    requires = [ "network.target" ];
    unitConfig = {
      Type = "oneshot";
    };
    serviceConfig = {
      ExecStart = "/bin/sh -c '${pkgs.ethtool}/sbin/ethtool -s eno1 wol g'";
    };
    wantedBy = [ "multi-user.target" ];
  };

  system.stateVersion = "23.11"; # Did you read the comment?
}
