{other-pkgs, ...}: let
  inherit (other-pkgs) unstable;
in {
  programs.starship =
    import ./settings/shell_integrations.nix
    // {
      enable = true;
      package = unstable.starship;
      settings = {
        #palette = "gruvbox_dark";

        palettes.gruvbox_dark = {
          fg = "#fbf1c7";
          bg = "#3c3836";
          bg3 = "#665c54";
          blue = "#458588";
          aqua = "#689d6a";
          green = "#98971a";
          orange = "#d65d0e";
          purple = "#b16286";
          red = "#cc241d";
          yellow = "#d79921";
        };

        aws.disabled = true;
        directory.truncate_to_repo = false;
        directory.truncation_length = 8;
        direnv.disabled = false;
        gcloud.disabled = true;
        git_branch.style = "242";
        kubernetes.disabled = false;
        ruby.disabled = true;

        hostname.ssh_only = false;
      };
    };
}
