{
  moduleNamespace,
  inputs,
  my-utils,
  ...
}: {
  config,
  lib,
  pkgs,
  ...
}: let
  cfg = config.${moduleNamespace}.gui-system;
in {
  _file = ./default.nix;

  options = {
    ${moduleNamespace}.gui-system = {
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
    programs.hyprland = {
      enable = cfg.enable;
      package = pkgs.hyprland;
      xwayland.enable = cfg.enable;
    };

    environment.systemPackages = [
      pkgs.hyprland-pkgs.mesa
    ];

    # Mesa version fix
    hardware.graphics = {
      package = pkgs.hyprland-pkgs.mesa.drivers;

      extraPackages = with pkgs.hyprland-pkgs; [
        intel-media-driver # LIBVA_DRIVER_NAME=iHD
        # LIBVA_DRIVER_NAME=i965 (older but works better for Firefox/Chromium)
        (intel-vaapi-driver.override {enableHybridCodec = true;})
        libvdpau-va-gl
      ];

      # if you also want 32-bit support (e.g for Steam)
      enable32Bit = true;
      package32 = pkgs.hyprland-pkgs.pkgsi686Linux.mesa.drivers;
    };

    environment.sessionVariables = {LIBVA_DRIVER_NAME = "iHD";}; # Force intel-media-driver

    fonts = {
      packages = with pkgs.nerd-fonts; [
        fira-code
        droid-sans-mono
        jetbrains-mono
        # for all fonts
        # font.packages = [ ... ] ++ builtins.filter lib.attrsets.isDerivation (builtins.attrValues pkgs.nerd-fonts)
        pkgs.secret.berkeley-mono
      ];
      fontconfig = {
        defaultFonts = {
          serif = ["Liberation Serif" "Vazirmatn"];
          sansSerif = ["Ubuntu" "Vazirmatn"];
          monospace = ["Ubuntu Mono"];
        };
      };
    };

    xdg.portal = {
      enable = true;
      extraPortals = [pkgs.xdg-desktop-portal-gtk];
    };

    services = {
      xserver.enable = true;
      displayManager = lib.mkIf cfg.displayManager {
        enable = true;
        sddm = {
          enable = true;
          #package = pkgs.kdePackages.sddm;
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
        package = pkgs.sunshine;
        autoStart = false;
        capSysAdmin = true;
      };
    };
  };
}
# # Enable sound with pipewire.
# hardware.pulseaudio.enable = false;
# hardware.pulseaudio.package = pkgs.pulseaudioFull;
# security.rtkit.enable = true;
# services.pipewire = {
#   enable = true;
#   alsa.enable = true;
#   alsa.support32Bit = true;
#   pulse.enable = true;
#   # If you want to use JACK applications, uncomment this
#   # jack.enable = true;
#
#   # use the example session manager (no others are packaged yet so this is enabled by default,
#   # no need to redefine it in your config for now)
#   #media-session.enable = true;
# };
#
# fonts.packages = with pkgs; [
#   fira-code
#   openmoji-color
#   noto-fonts-emoji
#   (nerdfonts.override {fonts = ["FiraMono" "Go-Mono"];})
# ];
# fonts.fontconfig = {
#   enable = true;
#   defaultFonts = {
#     serif = ["GoMono Nerd Font Mono" "FiraCode"];
#     sansSerif = ["FiraCode Nerd Font Mono" "FiraCode"];
#     monospace = ["FiraCode Nerd Font Mono" "FiraCode"];
#     emoji = ["OpenMoji Color" "OpenMoji" "Noto Color Emoji"];
#   };
# };
# fonts.fontDir.enable = true;
# documentation.dev.enable = true;

