{
  pkgs,
  other-pkgs,
  ...
}: let
  unstable = other-pkgs.unstable;
in {
  programs = {
    ripgrep = {
      enable = true;
      package = other-pkgs.unstable.ripgrep;
    };

    broot =
      import ./integration_settings.nix
      // {
        enable = true;
        #package = unstable.zoxide;
        settings = {
          modal = true;
        };
      };

    bat = {
      enable = true;
      #package = unstable.bat;
      extraPackages = with pkgs.bat-extras; [
        batdiff
        batgrep
        batman
        batpipe
        batwatch
        prettybat
      ];
    };
  };
}
