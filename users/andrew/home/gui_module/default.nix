{ inputs, lib, mylib, config, pkgs, other-pkgs, ... }:
let
  cfg = config.gui;
  startupScript = pkgs.writeShellScriptBin "start" ''
    ${pkgs.waybar}/bin/waybar &
    #${pkgs.swww}/bin/swww init &
    sleep 1
    #${pkgs.swww}/bin/swww img ''${./wallpaper.png} &
  '';
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
    home.packages = [ other-pkgs.unstable.wayvnc ];
 
    wayland.windowManager.hyprland = {
      enable = true;

      plugins = [
        inputs.hyprland-plugins.packages."${pkgs.system}".borders-plus-plus
      ];

      settings = {
        "plugin:borders-plus-plus" = {
          add_borders = 1; # 0 - 9

          # you can add up to 9 borders
          "col.border_1" = "rgb(ffffff)";
          "col.border_2" = "rgb(2222ff)";

          # -1 means "default" as in the one defined in general:border_size
          border_size_1 = 10;
          border_size_2 = -1;

          # makes outer edges match rounding of the parent. Turn on / off to better understand. Default = on.
          natural_rounding = "yes";
        };

        exec-once = ''${startupScript}/bin/start'';
      };
    };
  };
}
