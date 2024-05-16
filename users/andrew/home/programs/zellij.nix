{other-pkgs, ...}: let
  unstable = other-pkgs.unstable;
  shellAliases = {
    "zj" = "zellij";
  };
in {
  programs.zellij =
    import ./integration_settings.nix
    // {
      enable = true;
      package = unstable.zellij;
      settings = {
        theme = "gruvbox-dark";
        #theme = "custom"
        #themes.custom.fg = "#ffffff";
      };
    };

  home.shellAliases = shellAliases;
}
