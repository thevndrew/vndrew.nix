{other-pkgs, ...}: let
  inherit (other-pkgs) unstable;
in {
  programs.direnv =
    import ./settings/shell_integrations.nix
    // {
      enable = true;
      package = unstable.direnv;
      nix-direnv.enable = true;
    };
}
