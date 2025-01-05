{
  moduleNamespace,
  inputs,
  ...
}: {
  config,
  lib,
  pkgs,
  ...
}: let
  cfg = config.${moduleNamespace}.terminals;
  inherit (pkgs) unstable;
in {
  _file = ./default.nix;

  options = {
    ${moduleNamespace}.terminals = {
      enable = lib.mkOption {
        type = lib.types.bool;
        default = false;
        example = true;
        description = "Install and configure terminals";
      };

      wezterm = lib.mkOption {
        type = lib.types.bool;
        default = cfg.enable;
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
    programs.wezterm = {
      enable = cfg.wezterm;
      package = pkgs.wezterm;
      enableBashIntegration = true;
      enableZshIntegration = true;
      extraConfig = ''
        return {
          font = wezterm.font_with_fallback {
            'BerkeleyMono',
            { family = 'JetBrains Mono'},
          },
          -- font_size = 16.0,
          -- hide_tab_bar_if_only_one_tab = true,
          -- default_prog = { "zsh", "--login", "-c", "tmux attach -t dev || tmux new -s dev" },
          keys = {
            {key="n", mods="SHIFT|CTRL", action="ToggleFullScreen"},
          },
        }
      '';
    };

    programs.ghostty = {
      enable = cfg.enable;
      package = pkgs.ghostty;
    };

    programs.alacritty = {
      enable = cfg.alacritty;
    };

    programs.kitty = {
      enable = cfg.kitty;
      #font = {
      #  name = "";
      #  size = 12;
      #  package = ;
      #};
      shellIntegration = {
        enableBashIntegration = true;
        enableZshIntegration = true;
      };
    };
  };
}
