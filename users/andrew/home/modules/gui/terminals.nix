{
  lib,
  config,
  other-pkgs,
  ...
}: let
  cfg = config.terminals;
  inherit (other-pkgs) unstable;
in {
  options = {
    terminals.enable = lib.mkOption {
      type = lib.types.bool;
      default = false;
      example = true;
      description = "Install and configure terminals";
    };

    terminals.wezterm = lib.mkOption {
      type = lib.types.bool;
      default = true;
      example = false;
      description = "Install and configure wezterm";
    };

    terminals.alacritty = lib.mkOption {
      type = lib.types.bool;
      default = false;
      example = true;
      description = "Install and configure alacritty";
    };
  };

  config = lib.mkIf cfg.enable {
    programs.wezterm =
      {
        enable = cfg.wezterm;
        package = unstable.wezterm;
      }
      // import ../../settings/shell_integrations.nix;
    programs.alacritty = {
      enable = cfg.alacritty;
      package = unstable.alacritty;
    };
  };
}
