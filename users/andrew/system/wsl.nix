{
  config,
  inputs,
  lib,
  ...
}: let
  cfg = config.wsl-cfg;
in {
  imports = [
    inputs.nixos-wsl.nixosModules.default
  ];

  options = {
    wsl-cfg.enable = lib.mkOption {
      type = lib.types.bool;
      default = false;
      example = true;
      description = "Configure defaults for WSL-based systems";
    };
  };

  config = lib.mkIf cfg.enable {
    my-networking.enable = false;
    my-virtualisation.enable = false;
    wsl.enable = true;
    wsl.docker-desktop.enable = true;
  };
}
