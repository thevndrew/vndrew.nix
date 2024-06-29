{
  lib,
  config,
  other-pkgs,
  ...
}: let
  cfg = config.hello;
  unstable = other-pkgs.unstable;
in {
  options = {
    hello.enable = lib.mkOption {
      type = lib.types.bool;
      default = false;
      example = true;
      description = "Installs GUI related packages with Home Manager";
    };
  };

  config = lib.mkIf cfg.enable {
    home.packages = with unstable; [
      hello
    ];
  };
}
