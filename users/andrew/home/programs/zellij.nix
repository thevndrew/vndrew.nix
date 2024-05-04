{ other-pkgs, ... }:
let
  unstable = other-pkgs.unstable;
in
{
  programs.zellij = import ./integration_settings.nix // {
    enable = true;
    package = unstable.zellij;
  };
}
