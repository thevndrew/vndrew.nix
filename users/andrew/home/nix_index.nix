{other-pkgs, ...}: let
  unstable = other-pkgs.unstable;
in {
  programs.nix-index-database.comma.enable = true;
  programs.nix-index =
    {
      enable = true;
      package = unstable.nix-index;
    }
    // import ./settings/shell_integrations.nix;
}
