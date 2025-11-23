{pkgs, ...}: let
  gallerydl-config = builtins.fromJSON (builtins.readFile ./gallery-dl.json);
in {
  vndrewMods = {
    terminals.enable = true;
    terminals.kitty = true;
    gui-home.enable = true;
    gui-home.wm.enable = true;
    gui-home.audio.enable = true;
  };

  home.packages = [
    # on WSL just use: winget install win32yank
    pkgs.wl-clipboard
  ];

  programs.gallery-dl = {
    enable = true;
    settings = gallerydl-config;
  };

}
