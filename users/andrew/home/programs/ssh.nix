{ systemInfo, ... }:
{
  programs.ssh = {
    enable = true;
    extraConfig = ''
    Host github.com
        HostName github.com
        PreferredAuthentications publickey
        IdentityFile ~/.ssh/${systemInfo.hostname}
    '';
    #extraConfig = ''${builtins.readFile (mylib.relativeToRoot "config/ssh/config")}'';
  };
}
