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
  my-intel-vaapi-driver = pkgs-unstable.intel-vaapi-driver.override {enableHybridCodec = true;};
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

      sunshine = lib.mkOption {
        type = lib.types.bool;
        default = cfg.enable;
        example = true;
        description = "enable the sunshine server";
      };
    };
  };

  config = lib.mkIf cfg.enable {
    hello.enable = cfg.enable;

    programs.hyprland = {
      enable = cfg.enable;
      package = inputs.hyprland.packages.${pkgs.stdenv.hostPlatform.system}.hyprland;
      xwayland.enable = cfg.enable;
    };

    # Mesa version fix
    hardware.opengl = {
      package = pkgs-unstable.mesa.drivers;

      extraPackages = with pkgs-unstable; [
        intel-media-driver # LIBVA_DRIVER_NAME=iHD
        my-intel-vaapi-driver # LIBVA_DRIVER_NAME=i965 (older but works better for Firefox/Chromium)
        libvdpau-va-gl
      ];

      # if you also want 32-bit support (e.g for Steam)
      driSupport32Bit = true;
      package32 = pkgs-unstable.pkgsi686Linux.mesa.drivers;
    };

    environment.sessionVariables = {LIBVA_DRIVER_NAME = "iHD";}; # Force intel-media-driver

    xdg.portal = {
      enable = true;
      extraPortals = [pkgs.xdg-desktop-portal-gtk];
    };

    sound.enable = cfg.audio;

    services = {
      xserver.enable = true;
      displayManager = lib.mkIf cfg.displayManager {
        enable = true;
        sddm = {
          enable = true;
          #package = pkgs-unstable.kdePackages.sddm;
          #wayland = {
          #  enable = true;
          #  compositor = "weston";
          #};
        };
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

      sunshine = lib.mkIf cfg.sunshine {
        enable = true;
        package = pkgs-unstable.sunshine;
        autoStart = false;
        capSysAdmin = true;
      };
    };
  };
}
