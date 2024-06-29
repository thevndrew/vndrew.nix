{other-pkgs, ...}: let
  inherit (other-pkgs) unstable;
in {
  programs.lf = {
    enable = true;
    package = unstable.lf;
  };
}
