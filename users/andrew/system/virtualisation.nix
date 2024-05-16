# Arion works with Docker, but for NixOS-based containers, you need Podman
# since NixOS 21.05.
{pkgs, ...}: {
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
    oci-containers.backend = "podman";
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
}
