{ other-pkgs, ... }:
let
  unstable = other-pkgs.unstable;
in
{
  programs.starship = import ../integration_settings.nix // {
    enable = true;
    package = unstable.starship;
    settings = {
      palette = "gruvbox_dark";

      palettes.gruvbox_dark = {
        fg = "#fbf1c7";
        bg = "#3c3836";
        bg3 = "#665c54";
        blue = "#458588";
        aqua = "#689d6a";
        green = "#98971a";
        orange = "#d65d0e";
        purple = "#b16286";
        red = "#cc241d";
        yellow = "#d79921";
      };

      direnv = {
        disabled = false;
      };
    };
  };
}
