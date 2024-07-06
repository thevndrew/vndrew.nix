{
  inputs,
  lib,
  mylib,
  config,
  pkgs,
  ...
}: let
  cfg = config.gui;
  pkgs-unstable = inputs.hyprland.inputs.nixpkgs.legacyPackages.${pkgs.stdenv.hostPlatform.system};
in {
  imports = mylib.scanPaths ./.;

  options = {
    gui.enable = lib.mkOption {
      type = lib.types.bool;
      default = false;
      example = true;
      description = "enables GUI related system configurations";
    };
  };

  config = lib.mkIf cfg.enable {
    hello.enable = cfg.enable;
    programs.hyprland.enable = true;
    programs.hyprland.package = inputs.hyprland.packages.${pkgs.stdenv.hostPlatform.system}.hyprland;

    # Mesa version fix
    hardware.opengl = {
      package = pkgs-unstable.mesa.drivers;

      # if you also want 32-bit support (e.g for Steam)
      driSupport32Bit = true;
      package32 = pkgs-unstable.pkgsi686Linux.mesa.drivers;
    };
  };
}
