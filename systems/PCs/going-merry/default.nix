{
  lib,
  pkgs,
  username,
  system-modules,
  inputs,
  ...
}: let
    tailscale-cert-script = pkgs.writeShellScript "tailscale-cert-fetch.sh" ''
      #!/bin/bash
      set -e

      DOMAIN="going-merry.ainu-kanyu.ts.net"
      CERT_DIR="/var/lib/tailscale/certs"

      # Fetch certificates from Tailscale
      ${pkgs.unstable.tailscale}/bin/tailscale cert "$DOMAIN"

      echo "Certificates fetched"
    '';
in {
  # Disable the default module
  disabledModules = [
    "services/networking/tailscale-derper.nix"
  ];

  imports = with system-modules; [
    ../PCs.nix

    # Include the results of the hardware scan.
    ./hardware-configuration.nix

    "${inputs.nixpkgs-unstable}/nixos/modules/services/networking/tailscale-derper.nix"
  ];
  vndrewMods = {
    cockpit.enable = true;
    samba = {
      user = username;
      sharing.enable = true;
      home = "/home/${username}";
    };
    wol = {
      enable = true;
      wolCommand = "ethtool -s enp1s0 wol g && ethtool -s enp2s0 wol g";
    };
  };

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


  security.pki.certificateFiles = [
    ./rootCA.pem
  ];

  services.tailscale.derper = {
    enable = true;
    package = pkgs.unstable.tailscale.derper;
    domain = "going-merry.ainu-kanyu.ts.net";
    verifyClients = true;
    configureNginx = false;
  };

  services.nginx = {
    enable = true;
    virtualHosts."going-merry.ainu-kanyu.ts.net" = {
      addSSL = true;
      sslCertificate = "/var/lib/ssl/certs/going-merry.ainu-kanyu.ts.net.crt";
      sslCertificateKey = "/var/lib/ssl/private/going-merry.ainu-kanyu.ts.net.key";
      locations."/" = {
        proxyPass = "http://127.0.0.1:8010";
        proxyWebsockets = true;
        extraConfig = # nginx
          ''
            proxy_buffering off;
            proxy_read_timeout 3600s;
          '';
      };
    };
  };

  systemd.tmpfiles.rules = [
    # Create directory /var/lib/ssl/certs with 755 permissions, owned by root:nginx
    "d /var/lib/ssl/certs 0755 root nginx -"

    # Create directory /var/lib/ssl/private with 750 permissions, owned by root:nginx
    "d /var/lib/ssl/private 0750 root nginx -"

    # Copy file from source to destination with 644 permissions, owned by root:nginx
    "C /var/lib/ssl/certs/going-merry.ainu-kanyu.ts.net.crt 0644 root nginx - /var/lib/tailscale/certs/going-merry.ainu-kanyu.ts.net.crt"

    # Copy private key with 640 permissions (more restrictive)
    "C /var/lib/ssl/private/going-merry.ainu-kanyu.ts.net.key 0640 root nginx - /var/lib/tailscale/certs/going-merry.ainu-kanyu.ts.net.key"
  ];

  systemd.services.tailscale-cert-fetch = {
    description = "Fetch Tailscale certificates";
    after = [ "tailscaled.service" ];
    wants = [ "tailscaled.service" ];

    serviceConfig = {
      Type = "oneshot";
      ExecStart = "${tailscale-cert-script}/bin/tailscale-cert-fetch.sh";
      WorkingDirectory = "/var/lib/tailscale/certs";
      User = "root";
    };
  };

  systemd.timers.tailscale-cert-fetch = {
    description = "Refresh Tailscale certificates";
    wantedBy = [ "timers.target" ];
    timerConfig = {
      OnCalendar = "daily";
      RandomizedDelaySec = "1h";
    };
  };

  # Pick only one of the below networking options.
  # networking.wireless.enable = true;  # Enables wireless support via wpa_supplicant.
  # networking.networkmanager.enable = true;  # Easiest to use and most distros use this by default.

  # Enable CUPS to print documents.
  # services.printing.enable = true;

  # Enable sound.
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
}
