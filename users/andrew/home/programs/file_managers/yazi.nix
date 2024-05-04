{ other-pkgs, ... }:
let
  unstable = other-pkgs.unstable;
in
{
  programs.yazi = import ../integration_settings.nix // {
    enable = true;
    package = unstable.yazi;
  };
}
