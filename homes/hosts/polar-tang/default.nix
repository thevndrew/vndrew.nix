{pkgs, ...}: {
  vndrewMods = {
  };

  home.packages = with pkgs; [
    # Do install the docker CLI to talk to podman.
    # Not needed when virtualisation.docker.enable = true;
    docker-client
    docker-compose

    pkgs.unstable.wl-clipboard # on WSL just use: winget install win32yank
  ];

  home.shellAliases = {
    pbcopy = "/mnt/c/Windows/System32/clip.exe";
    pbpaste = "/mnt/c/Windows/System32/WindowsPowerShell/v1.0/powershell.exe -command 'Get-Clipboard'";
    explorer = "/mnt/c/Windows/explorer.exe";
  };
}
