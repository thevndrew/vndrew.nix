/*
This file imports overlays defined in the following format.
*/
{inputs, ...}: let
  overlaySetPre = {
    dep-tree = import ./dep-tree;
    nops = import ./nops;

    # # work in progress?
    # tmux = import ./tmux;
    # alakazam = import ./alakitty;
    # wezterm = import ./wezterm;
    # foot = import ./foot;
  };
  overlaySetMapped = builtins.mapAttrs (name: value: (value name inputs)) overlaySetPre;

  get_pkg = importName: (self: super: let
    pkgs = import inputs.nixpkgs {inherit (self) system;};
  in {
    ${importName} = pkgs.callPackage ./${importName} {inherit inputs;};
  });

  get_pkgs = pkg_list: map (name: { name = name; value = get_pkg name; }) pkg_list |> builtins.listToAttrs;

  pkg_set = get_pkgs [
      "bootdev"
      "chrome-wrapper"
      "clone_repos"
      "cockpit-podman"
      "crx-dl"
      "megadl"
      "podcast-dl"
      "run_commands_py"
      "run_commands_sh"
      "sops_secrets_key"
      "update_input"
      "yt-dlp-get-pot"
      "yt-dlp-youtube-oauth2"
  ];

  overlaySet =
    overlaySetMapped
    //
    pkg_set;
in
  overlaySet
