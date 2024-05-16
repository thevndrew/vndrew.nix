{
  config,
  pkgs,
  other-pkgs,
  inputs,
  systemInfo,
  isDesktop,
  ...
}: {
  disabledModules = ["programs/nh.nix"];

  imports = [
    "${inputs.nixpkgs-unstable}/nixos/modules/programs/nh.nix"
  ];

  gui.enable = isDesktop;

  security.sudo.enable = true;
  security.sudo.wheelNeedsPassword = false;

  time.timeZone = "America/New_York";

  programs = {
    zsh.enable = true;

    nh = {
      enable = true;
      package = other-pkgs.unstable.nh;
      #clean.enable = true;
      #clean.extraArgs = "--keep-since 4d --keep 3";
      flake = "${systemInfo.home}/nix-config";
    };
  };

  #nixpkgs.overlays = import ../../lib/overlays.nix ++ [
  #  (import ./vim.nix { inherit inputs; })
  #];
}
