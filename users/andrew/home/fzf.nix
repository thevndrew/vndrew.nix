{other-pkgs, ...}: {
  programs.fzf =
    import ./settings/shell_integrations.nix
    // {
      enable = true;
      package = other-pkgs.unstable.fzf;
    };
}
