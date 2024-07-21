{
  config,
  inputs,
  lib,
  other-pkgs,
  pkgs,
  ...
}: let
  cfg = config.terminals;
  inherit (other-pkgs) unstable;
in {
  options = {
    terminals = {
      enable = lib.mkOption {
        type = lib.types.bool;
        default = false;
        example = true;
        description = "Install and configure terminals";
      };

      wezterm = lib.mkOption {
        type = lib.types.bool;
        default = true;
        example = false;
        description = "Install and configure wezterm";
      };

      alacritty = lib.mkOption {
        type = lib.types.bool;
        default = false;
        example = true;
        description = "Install and configure alacritty";
      };

      kitty = lib.mkOption {
        type = lib.types.bool;
        default = false;
        example = true;
        description = "Install and configure kitty";
      };
    };
  };

  config = lib.mkIf cfg.enable {
    programs.wezterm =
      {
        enable = cfg.wezterm;
        #package = inputs.wezterm.packages.${pkgs.system}.default;
        package = unstable.wezterm;
      }
      // import ../../settings/shell_integrations.nix;
    programs.alacritty = {
      enable = cfg.alacritty;
      package = unstable.alacritty;
    };
    programs.kitty = {
      enable = cfg.kitty;
      package = unstable.kitty;
    };
  };
}
