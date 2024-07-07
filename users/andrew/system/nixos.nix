{
  isDesktop,
  isWSL,
  other-pkgs,
  systemInfo,
  ...
}: {
  disabledModules = [];

  imports = [
    # "${inputs.nixpkgs-unstable}/nixos/modules/..."
  ];

  cockpit.enable = !isWSL;
  gui.enable = isDesktop;
  wsl-cfg.enable = isWSL;

  networking.samba.sharing.enable = !isWSL;
  networking.samba.storage.enable = systemInfo.hostname == "thousand-sunny";

  security.sudo.enable = true;
  security.sudo.wheelNeedsPassword = false;

  time.timeZone = "America/New_York";

  fonts.enableDefaultPackages = true;

  programs = {
    zsh.enable = true;

    nh = {
      enable = true;
      package = other-pkgs.unstable.nh;
      clean = {
        enable = true;
        dates = "weekly";
        extraArgs = "--keep 3 --keep-since 7d";
      };
      flake = "${systemInfo.home}/nix-config";
    };
  };

  #nixpkgs.overlays = import ../../lib/overlays.nix ++ [
  #  (import ./vim.nix { inherit inputs; })
  #];
}
