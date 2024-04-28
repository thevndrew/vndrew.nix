{ config, pkgs, pkgs-unstable, inputs, currentSystemUser, ... }:

let
  homeDir = "/home/${currentSystemUser}";
  repoList = ../../config/repos/repos.yml;

in
{
  disabledModules = [ "programs/nh.nix" ];

  imports = [ "${inputs.nixpkgs-unstable}/nixos/modules/programs/nh.nix" ];

  environment.systemPackages = with pkgs; [
    mergerfs
    tmux
    neovim
    git
    ethtool
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

  #systemd.user.services.clone_repos = {
  #  path = [ pkgs.yq ];
  #  unitConfig = {
  #    Description = "Clone repos to system";
  #  };
  #  serviceConfig = {
  #      ExecStart = "${pkgs.writeShellScript "clone_repos" ''
  #        #!/bin/bash
  #
  #        # Function to clone a repository if it doesn't already exist
  #        clone_if_not_exists() {
  #            local REPO_URL="$1"
  #            local CLONE_DIR="$2"
  #        
  #            [ ! -d "$CLONE_DIR" ] && git clone "$REPO_URL" "$CLONE_DIR" || echo "Directory '$CLONE_DIR' already exists. Skipping clone."
  #        }
  #
  #        mkdir_if_not_exists() {
  #            local DIR=$(dirname "$1")
  #
  #            [ ! -d "$DIR" ] && mkdir -pv "$DIR"
  #        }
  #
  #        REPOS=($(yq -r '.repo_list | keys[]' "${repoList}"))
  #
  #        for REPO in ''${REPOS[@]};
  #        do
  #            REPO_DIR=$(yq -r ".repo_list.$REPO.directory" "${repoList}")
  #            REPO_URL=$(yq -r ".repo_list.$REPO.url" "${repoList}")
  #            mkdir_if_not_exists "${homeDir}/$REPO_DIR"
  #            clone_if_not_exists "$REPO_URL" "${homeDir}/$REPO_DIR"
  #        done 
  #      ''}";
  #    };
  #  wantedBy = [ "default.target" ];
  #};

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
      #package = pkgs-unstable.tailscale;
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

  users.mutableUsers = false;
  users.users.${currentSystemUser} = {
    initialPassword = "${currentSystemUser}";
    home = "/home/${currentSystemUser}";
    shell = pkgs.zsh;
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

  programs = {
    zsh.enable = true;
  };

  environment = {
    # Add ~/.local/bin to PATH
    localBinInPath = true;

    pathsToLink = [ 
      "/share/bash-completion"
      "/share/zsh"
    ];
   
    shells = [ pkgs.zsh pkgs.nushell ];
  };

  #nixpkgs.overlays = import ../../lib/overlays.nix ++ [
  #  (import ./vim.nix { inherit inputs; })
  #];
}
