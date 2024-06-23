{other-pkgs, ...}: let
  unstable = other-pkgs.unstable;
in {
  programs.direnv =
    import ./settings/shell_integrations.nix
    // {
      enable = true;
      package = unstable.direnv;
      nix-direnv.enable = true;
    };
}
