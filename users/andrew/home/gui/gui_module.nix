{ lib, mylib, config, pkgs, ... }:
let
  cfg = config.gui;
in
{
  imports = mylib.scanPaths ./.;

  options = {
    gui.enable = lib.mkOption {
      type = lib.types.bool;
      default = false;
      example = true;
      description = "enables GUI related configuration";
    };
  };

  config = lib.mkIf cfg.enable {
    hello.enable = cfg.enable;
  };
}
