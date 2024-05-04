{ other-pkgs, ... }:
let
  unstable = other-pkgs.unstable;
in
{
  programs.direnv = import ../integration_settings.nix // {
    enable = true;
    package = unstable.direnv;
    nix-direnv.enable = true;
  };
}
