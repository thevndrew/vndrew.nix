{ config, ... }:
{
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
}
