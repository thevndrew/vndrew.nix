{other-pkgs, ...}: let
  inherit (other-pkgs) unstable;
in {
  programs.nix-index-database.comma.enable = true;
  programs.nix-index =
    {
      enable = true;
      package = unstable.nix-index;
    }
    // import ./settings/shell_integrations.nix;
}
