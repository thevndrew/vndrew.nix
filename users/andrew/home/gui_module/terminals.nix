{
  lib,
  config,
  other-pkgs,
  ...
}: let
  cfg = config.terminals;
  unstable = other-pkgs.unstable;
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
      // import ../programs/integration_settings.nix;
    programs.alacritty = {
      enable = cfg.alacritty;
      package = unstable.alacritty;
    };
  };
}
