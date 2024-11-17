{pkgs, ...}: {
  vndrewMods = {
    terminals.enable = true;
    terminals.kitty = true;
    gui-home.enable = true;
    gui-home.wm.enable = true;
    gui-home.audio.enable = true;
  };

  home.packages = [
    # on WSL just use: winget install win32yank
    pkgs.unstable.wl-clipboard
  ];
}
