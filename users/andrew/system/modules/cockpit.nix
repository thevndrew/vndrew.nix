{
  config,
  lib,
  other-pkgs,
  ...
}: let
  inherit (other-pkgs) unstable;
  cfg = config.cockpit;
in {
  options = {
    cockpit.enable = lib.mkOption {
      type = lib.types.bool;
      default = false;
      example = true;
      description = "Enable and configure Cockpit";
    };
  };

  config = lib.mkIf cfg.enable {
    services = {
      cockpit = {
        enable = true;
        package = unstable.cockpit;
        port = 8085;
      };
    };
    environment.systemPackages = [
      other-pkgs.vndrew.cockpit-podman
    ];
  };
}
