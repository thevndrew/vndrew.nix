{ other-pkgs, ... }:
let
  unstable = other-pkgs.unstable;
  shellAliases = {
    "zj" = "zellij";
    "tmux" = "zellij";
  };
in
{
  programs.zellij = import ./integration_settings.nix // {
    enable = true;
    package = unstable.zellij;
  };

  home.shellAliases = shellAliases;
}
