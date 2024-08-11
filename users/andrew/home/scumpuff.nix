{other-pkgs, ...}: let
  inherit (other-pkgs) unstable;
in {
  programs.scmpuff =
    import ./settings/shell_integrations.nix
    // {
      enable = true;
      package = unstable.scmpuff;
    };
}
