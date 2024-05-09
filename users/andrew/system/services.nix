{ pkgs, other-pkgs, ... }:
{
  services = {
    openssh = {
      enable = true;
      settings.PasswordAuthentication = false;
      settings.PermitRootLogin = "yes";
      ports = [ 22 2222 ];
    };
  
    tailscale = {
      enable = true;
      package = other-pkgs.unstable.tailscale;
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
}
