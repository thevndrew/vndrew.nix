# Arion works with Docker, but for NixOS-based containers, you need Podman
# since NixOS 21.05.
{moduleNamespace, ...}: {
  config,
  lib,
  pkgs,
  ...
}: let
  cfg = config.${moduleNamespace}.virtualisation;
in {
  _file = ./default.nix;
  options = {
    ${moduleNamespace}.virtualisation = {
      enable = lib.mkOption {
        type = lib.types.bool;
        default = true;
        example = false;
        description = "enable networking related configuration";
      };
    };
  };

  config = lib.mkIf cfg.enable {
    virtualisation = {
      libvirtd = {
        enable = true;
      };

      containers = {
        enable = true;
        containersConf = {
          settings = {
            network = {
              # Change dns port to allow running
              # so it doesn't conflict with
              # pihole container that I use for DNS
              dns_bind_port = 54;
            };
          };
        };
      };

      oci-containers.backend = "podman";

      docker = {
        enable = false;
      };

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

    environment.systemPackages = [
      # Do install the docker CLI to talk to podman.
      # Not needed when virtualisation.docker.enable = true;
      pkgs.docker-client
      pkgs.docker-compose
      pkgs.aardvark-dns
    ];
  };
}
