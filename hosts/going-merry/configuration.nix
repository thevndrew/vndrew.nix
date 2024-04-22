{ config, lib, pkgs, pkgs-unstable, inputs, ... }:
{

  disabledModules = [ "programs/nh.nix" ];

  imports =
    [ # Include the results of the hardware scan.
      ./hardware-configuration.nix
      #inputs.home-manager.nixosModules.default
      "${inputs.nixpkgs-unstable}/nixos/modules/programs/nh.nix"
    ];

  # Use the systemd-boot EFI boot loader.
  boot.loader.systemd-boot.enable = true;
  boot.loader.efi.canTouchEfiVariables = true;
  boot.kernel.sysctl = {
    "net.ipv4.ip_forward" = 1;
    "net.ipv6.conf.all.forwarding" = 1;
  };

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
    #cron = {
    #  enable = true;
    #  systemCronJobs = [
    #    "*/30 * * * *  andrew  /home/andrew/services/qbittorrent/restart.sh >> /tmp/qbittorrent_restart.log"
    #  ];
    #};

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

    resolved = {
      enable = false;
      fallbackDns = [
        "100.100.100.100"
        "10.89.0.1"
        "9.9.9.9"
      ];
      domains = [
        "ainu-kanyu.ts.net"
        "dns.podman"
      ];
    };
  };

  environment.variables = {
    EDITOR = "nvim";
    HISTSIZE = "";
    HISTFILESIZE = "";
    HISTCONTROL = "ignoreboth";
    HISTTIMEFORMAT = "[%F %T] ";
    HISTFILE = "/home/andrew/.bash_eternal_history";
    PROMPT_COMMAND = "history -a; $PROMPT_COMMAND";
  };

  users.mutableUsers = false;
  users.users.andrew = {
    extraGroups = [ "wheel" "podman" ];
    #extraGroups = [ "wheel" "docker" ];
    initialPassword = "andrew";
    home = "/home/andrew";
    isNormalUser = true;
    openssh.authorizedKeys.keys = [ "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIHo+NCpecLu+vJrhgp0deaNXblILsmxxixpTg8pw+WAL" ];  
  };

  users.users.root.initialHashedPassword = "";
  users.users.root.openssh.authorizedKeys.keys = [ "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIHo+NCpecLu+vJrhgp0deaNXblILsmxxixpTg8pw+WAL" ];

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
    hostName = "going-merry";
    # enableIPv6  = false;
    firewall = {
      # enable the firewall
      enable = true;
      
      interfaces."podman+".allowedUDPPorts = [ 53 ];

      # always allow traffic from your Tailscale network
      trustedInterfaces = [ "tailscale0" ];

      # allow the Tailscale UDP port through the firewall
      allowedUDPPorts = [ config.services.tailscale.port ];

      # allow you to SSH in over the public internet
      allowedTCPPorts = [ 22 2222 ];
    };
    nameservers = [
      "100.100.100.100"
      "9.9.9.9"
      "10.89.0.1"
    ];
    search = [
      "ainu-kanyu.ts.net"
      "dns.podman"
    ];
  };

  # Arion works with Docker, but for NixOS-based containers, you need Podman
  # since NixOS 21.05.
  virtualisation = {
    containers = {
      enable = true;
      containersConf = {
        settings = {
          network = {
            dns_bind_port = 54;
          };
          engine = {
            network_cmd_options = [
              "mtu=1280"
              "outbound_addr=tailscale0"
              "outbound_addr6=tailscale0"
            ];
          };
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
      ExecStart = "/bin/sh -c '/home/andrew/services/qbittorrent/restart.sh'";
      User = "andrew";
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

