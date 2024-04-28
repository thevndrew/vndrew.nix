{ config, pkgs, pkgs-unstable, inputs, currentSystemUser, ... }:

let
  homeDir = "/home/${currentSystemUser}";
in
{
  disabledModules = [ "programs/nh.nix" ];

  imports = [ 
    "${inputs.nixpkgs-unstable}/nixos/modules/programs/nh.nix"
    ./system
  ];

  security.sudo.enable = true;
  security.sudo.wheelNeedsPassword = false;

  time.timeZone = "America/New_York";

  programs = {
    zsh.enable = true;

    nh = {
      enable = true;
      package = pkgs-unstable.nh;
      #clean.enable = true;
      #clean.extraArgs = "--keep-since 4d --keep 3";
      flake = "/home/${currentSystemUser}/nix-config";
    };
  };

  #nixpkgs.overlays = import ../../lib/overlays.nix ++ [
  #  (import ./vim.nix { inherit inputs; })
  #];
}
