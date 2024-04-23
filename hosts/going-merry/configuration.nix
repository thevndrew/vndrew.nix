{ config, lib, pkgs, pkgs-unstable, inputs, currentSystemUser, ... }:
{
  imports = [ 
      # Include the results of the hardware scan.
      ./hardware-configuration.nix
  ];

  # Use the systemd-boot EFI boot loader.
  boot = {
    loader = {
      systemd-boot.enable = true;
      efi.canTouchEfiVariables = true;
    };
    kernel.sysctl = {
      "net.ipv4.ip_forward" = 1;
      "net.ipv6.conf.all.forwarding" = 1;
    };
  };

  users.users."${currentSystemUser}".extraGroups = [ "wheel" "podman" ];
  #extraGroups = [ "wheel" "docker" ];

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
    yq
    nnn
    rclone
    btop
    rsync
    dig
    lsof
    cht-sh
    unar
    unzip
    wakeonlan
    pkgs-unstable.rbw
    pinentry # rbw dep
    bitwarden-cli
    yt-dlp
    ctop
    croc
    wormhole-william
    starship
    shellcheck
    # shellharden
    pkgs-unstable.nix-output-monitor
    pkgs-unstable.nvd
    #gost

    # Do install the docker CLI to talk to podman.
    # Not needed when virtualisation.docker.enable = true;
    docker-client
  ];

  networking = {
    hostName = "going-merry";
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
      ExecStart = "/bin/sh -c '${pkgs.ethtool}/sbin/ethtool -s enp1s0 wol g; ${pkgs.ethtool}/sbin/ethtool -s enp2s0 wol g'";
    };
    wantedBy = [ "multi-user.target" ];
  };

  systemd.services."qbittorrent-restart" = {
    enable = true;
    description = "qbittorrent automatic restart";
    path = [ pkgs.docker-client ];
    unitConfig = {
      Type = "oneshot";
    };
    serviceConfig = {
      ExecStart = "/bin/sh -c '/home/${currentSystemUser}/services/qbittorrent/restart.sh'";
      User = "${currentSystemUser}";
      Group = "users";
    };
    startAt = "hourly";
    wantedBy = [ "multi-user.target" ];
  };

  # Pick only one of the below networking options.
  # networking.wireless.enable = true;  # Enables wireless support via wpa_supplicant.
  # networking.networkmanager.enable = true;  # Easiest to use and most distros use this by default.

  # Enable CUPS to print documents.
  # services.printing.enable = true;

  # Enable sound.
  # sound.enable = true;
  # hardware.pulseaudio.enable = true;

  # Enable touchpad support (enabled default in most desktopManager).
  # services.xserver.libinput.enable = true;

  # Some programs need SUID wrappers, can be configured further or are
  # started in user sessions.
  # programs.mtr.enable = true;
  # programs.gnupg.agent = {
  #   enable = true;
  #   enableSSHSupport = true;
  # };

  # This option defines the first version of NixOS you have installed on this particular machine,
  # and is used to maintain compatibility with application data (e.g. databases) created on older NixOS versions.
  #
  # Most users should NEVER change this value after the initial install, for any reason,
  # even if you've upgraded your system to a new NixOS release.
  #
  # This value does NOT affect the Nixpkgs version your packages and OS are pulled from,
  # so changing it will NOT upgrade your system.
  #
  # This value being lower than the current NixOS release does NOT mean your system is
  # out of date, out of support, or vulnerable.
  #
  # Do NOT change this value unless you have manually inspected all the changes it would make to your configuration,
  # and migrated your data accordingly.
  #
  # For more information, see `man configuration.nix` or https://nixos.org/manual/nixos/stable/options#opt-system.stateVersion .
  system.stateVersion = "23.11"; # Did you read the comment?

}

