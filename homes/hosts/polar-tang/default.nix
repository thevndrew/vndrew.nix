{pkgs, ...}: {
  vndrewMods = {
  };

  home.shellAliases = {
    pbcopy = "/mnt/c/Windows/System32/clip.exe";
    pbpaste = "/mnt/c/Windows/System32/WindowsPowerShell/v1.0/powershell.exe -command 'Get-Clipboard'";
    explorer = "/mnt/c/Windows/explorer.exe";
  };

  sops = {
    age.sshKeyPaths = ["/mnt/c/Users/AJ-XPS/.ssh"];
  };
}
