{
  lib,
  pkgs,
  username,
  system-modules,
  ...
}: {
  imports = with system-modules; [
    ../PCs.nix

    # Include the results of the hardware scan.
    ./hardware-configuration.nix
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
