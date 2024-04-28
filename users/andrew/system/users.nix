{ pkgs, currentSystemUser, ... }:
{
  users = {
    mutableUsers = false;
    users.${currentSystemUser} = {
      initialPassword = "${currentSystemUser}";
      home = "/home/${currentSystemUser}";
      shell = pkgs.zsh;
      isNormalUser = true;
      openssh.authorizedKeys.keys = [ "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIHo+NCpecLu+vJrhgp0deaNXblILsmxxixpTg8pw+WAL" ];  
    };
    users.root.initialHashedPassword = "";
    users.root.openssh.authorizedKeys.keys = [ "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIHo+NCpecLu+vJrhgp0deaNXblILsmxxixpTg8pw+WAL" ];
  };
}
