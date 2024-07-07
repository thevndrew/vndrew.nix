{
  inputs,
  lib,
  mylib,
  config,
  pkgs,
  ...
}: let
  cfg = config.gui;
  pkgs-unstable = inputs.hyprland.inputs.nixpkgs.legacyPackages.${pkgs.stdenv.hostPlatform.system};
in {
  imports = mylib.scanPaths ./.;

  options = {
    gui = {
      enable = lib.mkOption {
        type = lib.types.bool;
        default = false;
        example = true;
        description = "enables GUI related system configurations";
      };

      audio = lib.mkOption {
        type = lib.types.bool;
        default = cfg.enable;
        example = true;
        description = "enable sound relatded configuration";
      };

      displayManager = lib.mkOption {
        type = lib.types.bool;
        default = cfg.enable;
        example = true;
        description = "enable the sddm display manager";
      };
    };
  };

  config = lib.mkIf cfg.enable {
    hello.enable = cfg.enable;
    programs.hyprland.enable = true;
    programs.hyprland.package = inputs.hyprland.packages.${pkgs.stdenv.hostPlatform.system}.hyprland;

    # Mesa version fix
    hardware.opengl = {
      package = pkgs-unstable.mesa.drivers;

      # if you also want 32-bit support (e.g for Steam)
      driSupport32Bit = true;
      package32 = pkgs-unstable.pkgsi686Linux.mesa.drivers;
    };

    sound.enable = cfg.audio;

    services = {
      xserver = lib.mkIf cfg.displayManager {
        displayManager.sddm.enable = true;
        displayManager.sddm.wayland.enable = true;
      };

      pipewire = lib.mkIf cfg.audio {
        enable = true;
        audio.enable = true;
        pulse.enable = true;
        alsa = {
          enable = true;
          support32Bit = true;
        };
        jack.enable = true;
      };
    };
  };
}
