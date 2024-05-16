{
  inputs,
  lib,
  mylib,
  config,
  pkgs,
  ...
}: let
  cfg = config.gui;
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
    programs.hyprland.package = inputs.hyprland.packages."${pkgs.system}".hyprland;
  };
}
