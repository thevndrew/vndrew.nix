{
  lib,
  mylib,
  config,
  pkgs,
  other-pkgs,
  ...
}: let
  cfg = config.gui;

  startupScript = pkgs.writeShellScriptBin "start" ''
    ${pkgs.waybar}/bin/waybar &
    ${pkgs.swww}/bin/swww init &
    sleep 1
    ${pkgs.swww}/bin/swww img ${mylib.relativeToRoot "config/wallpaper/sci-fi_wallpaper.webp"} &
  '';

  inherit (other-pkgs) unstable;
in {
  imports = mylib.scanPaths ./.;

  options = {
    gui = {
      enable = lib.mkOption {
        type = lib.types.bool;
        default = false;
        example = true;
        description = "enable GUI related configuration";
      };

      wm = lib.mkOption {
        type = lib.types.bool;
        default = false;
        example = true;
        description = "enable Window Manager related configuration";
      };

      audio = lib.mkOption {
        type = lib.types.bool;
        default = false;
        example = true;
        description = "enable sound relatded configuration";
      };
    };
  };

  config = lib.mkIf cfg.enable {
    home.packages = [unstable.wayvnc];

    terminals = {
      enable = true;
      alacritty = true;
    };

    home.pointerCursor = {
      gtk.enable = true;
      # x11.enable = true;
      package = unstable.bibata-cursors;
      name = "Bibata-Modern-Classic";
      size = 16;
    };

    gtk = {
      enable = true;

      theme = {
        package = unstable.flat-remix-gtk;
        name = "Flat-Remix-GTK-Grey-Darkest";
      };

      iconTheme = {
        package = unstable.gnome.adwaita-icon-theme;
        name = "Adwaita";
      };

      font = {
        name = "Sans";
        size = 11;
      };
    };

    wayland.windowManager.hyprland = {
      enable = cfg.wm;

      plugins = [
        #inputs.hyprland-plugins.packages.${pkgs.system}.borders-plus-plus
      ];

      #extraConfig = builtins.readFile (mylib.relativeToRoot "config/hyprland/config");

      systemd.variables = ["--all"];

      settings = {
        #"$terminal" = "wezterm";
        #monitor = "DP-1,2560x1440@60,0x0,1";
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
