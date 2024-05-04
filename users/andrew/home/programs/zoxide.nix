{ other-pkgs, ... }:
let
  unstable = other-pkgs.unstable;
in
{
  programs.zoxide = import ./integration_settings.nix // {
    enable = true;
    package = unstable.zoxide;
  };
}
