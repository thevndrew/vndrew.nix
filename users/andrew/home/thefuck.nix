{other-pkgs, ...}: let
  inherit (other-pkgs) unstable;
in {
  programs.thefuck =
    import ./settings/shell_integrations.nix
    // {
      enable = true;
      package = unstable.thefuck;
    };
}
