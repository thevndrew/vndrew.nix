{other-pkgs, ...}: let
  inherit (other-pkgs) unstable;
in {
  programs.yazi =
    import ../settings/shell_integrations.nix
    // {
      enable = true;
      package = unstable.yazi;
    };
}
