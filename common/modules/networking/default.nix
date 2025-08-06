{moduleNamespace, ...}: {
  config,
  lib,
  ...
}: let
  cfg = config.${moduleNamespace}.networking;
in {
  _file = ./default.nix;
  options = {
    ${moduleNamespace}.networking = {
      enable = lib.mkOption {
        type = lib.types.bool;
        default = true;
        example = false;
        description = "enable networking related configuration";
      };
    };
  };

  config = lib.mkIf cfg.enable {
    networking = {
      enableIPv6 = true;

      firewall = {
        # enable the firewall
        enable = true;

        # always allow traffic from your Tailscale network
        trustedInterfaces = ["tailscale0"];

        # allow you to SSH in over the public internet
        allowedTCPPorts = [
          22
          2222
        ];
      };
      nameservers = [
        "9.9.9.9"              # Quad9 malware blocking
        "1.1.1.1"              # Cloudflare
        "1.1.1.2"              # Cloudflare with malware blocking
        "1.0.0.2"              # Cloudflare with malware blocking
        "194.242.2.2"       # Mullvad no filtering
        "2620:fe::fe"          # Quad9 IPv6
        "2606:4700:4700::1112" # Cloudflare IPV6 with malware blocking
        "2606:4700:4700::1002" # Cloudflare IPV6 with malware blocking
        "2a07:e340::2"      # Mullvad IPv6
      ];
    };
  };
}
