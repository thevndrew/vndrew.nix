# Edit this configuration file to define what should be installed on
# your system. Help is available in the configuration.nix(5) man page, on
# https://search.nixos.org/options and in the NixOS manual (`nixos-help`).

{ config, inputs, lib, pkgs, pkgs-unstable, ... }:

{
  imports = [ 
    # Include the results of the hardware scan.
    ./hardware-configuration.nix
  ];

  # Use the systemd-boot EFI boot loader.
  boot = {
    loader = {
      systemd-boot.enable = true;
      efi = {
        canTouchEfiVariables = true;
        efiSysMountPoint = "/boot/efi";
      };
    };

    kernelParams = ["xhci_hcd.quirks=270336"];
    #kernel.sysctl = { "xhci_hcd.quirks" = 270336; };
    supportedFilesystems = [ "zfs" ];
    zfs = {
      forceImportRoot = false;
      extraPools = [
        "tank00" 
        "tank01"
        "tank02"
      ];
    };
  };

  services.zfs.autoScrub = {
    enable = true;
    interval = "monthly";
  };

  fileSystems."/mnt/storage" = {
    fsType = "fuse.mergerfs";
    device = "/mnt/tank00/storage:/mnt/tank01/storage:/mnt/tank02/storage";
    options = [
      "cache.files=off"
      "dropcacheonclose=true"
      "category.create=mfs"
      "moveonenospc=true"
      "minfreespace=250G"
      "fsname=mergerfs"
    ];
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

  powerManagement = {
    cpuFreqGovernor = "powersave";
    powertop.enable = true;
    cpufreq.min = 800000; # 800 Mhz
    cpufreq.max = 4400000; # 4.4 Ghz
  };

  users.groups.storage = {};
  users.users.andrew.extraGroups = [ "wheel" "podman" "storage" ];

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
    pkgs-unstable.nix-output-monitor
    pkgs-unstable.nvd

    # Do install the docker CLI to talk to podman.
    # Not needed when virtualisation.docker.enable = true;
    docker-client
  ];

  networking = {
    hostName = "thousand-sunny";
    hostId = "4a219e7f";
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
