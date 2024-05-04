{ other-pkgs, ... }:
let
  unstable = other-pkgs.unstable;
in
{
  programs.lf = {
    enable = true;
    package = unstable.lf;
  };
}
