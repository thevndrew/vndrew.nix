{ config, pkgs, pkgs-unstable, inputs, currentSystemUser, ... }:

{
  disabledModules = [ "programs/nh.nix" ];

  imports = [ "${inputs.nixpkgs-unstable}/nixos/modules/programs/nh.nix" ];

  environment.sessionVariables = {
    FLAKE = "/home/${currentSystemUser}/nix-config";
  };

  environment.systemPackages = with pkgs; [
    mergerfs
    tmux
    vim
    git
    ethtool
    pkgs-unstable.nix-output-monitor
    pkgs-unstable.nvd
  ];

  programs.nh = {
    enable = true;
    package = pkgs-unstable.nh;
    #clean.enable = true;
    #clean.extraArgs = "--keep-since 4d --keep 3";
    flake = "/home/${currentSystemUser}/nix-config";
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
    HISTFILE = "/home/${currentSystemUser}/.bash_eternal_history";
    PROMPT_COMMAND = "history -a; $PROMPT_COMMAND";
  };

  programs.bash.interactiveShellInit = ''
    shopt -s dotglob
    shopt -s extglob
  '';

  users.mutableUsers = false;
  users.users.${currentSystemUser} = {
    initialPassword = "${currentSystemUser}";
    home = "/home/${currentSystemUser}";
    isNormalUser = true;
    openssh.authorizedKeys.keys = [ "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIHo+NCpecLu+vJrhgp0deaNXblILsmxxixpTg8pw+WAL" ];  
  };

  users.users.root.initialHashedPassword = "";
  users.users.root.openssh.authorizedKeys.keys = [ "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIHo+NCpecLu+vJrhgp0deaNXblILsmxxixpTg8pw+WAL" ];

  time.timeZone = "America/New_York";

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

  networking = {
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

  # Add ~/.local/bin to PATH
  environment.localBinInPath = true;

  #nixpkgs.overlays = import ../../lib/overlays.nix ++ [
  #  (import ./vim.nix { inherit inputs; })
  #];
}
