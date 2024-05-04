{ other-pkgs, ... }:
let
  unstable = other-pkgs.unstable;
in
{
  programs.starship = import ../integration_settings.nix // {
    enable = true;
    package = unstable.starship;
  };
}
