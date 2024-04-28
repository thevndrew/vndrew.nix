{ config, inputs, pkgs, currentSystemUser, currentSystemHome, sopsKey, ... }:
{
  sops = {
    defaultSopsFile = "${inputs.mysecrets}/secrets/nix.yaml";
    age.sshKeyPaths = [ "${sopsKey}" ];
    secrets."passwords/${currentSystemUser}" = {
      neededForUsers = true;
    };
  };

  users = {
    mutableUsers = false;
    users.${currentSystemUser} = {
      hashedPasswordFile = config.sops.secrets."passwords/${currentSystemUser}".path;
      #initialPassword = "${currentSystemUser}";
      home = "${currentSystemHome}";
      shell = pkgs.zsh;
      isNormalUser = true;
      openssh.authorizedKeys.keys = [ 
        "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIHo+NCpecLu+vJrhgp0deaNXblILsmxxixpTg8pw+WAL"
      ];  
    };
    users.root.hashedPasswordFile = config.sops.secrets."passwords/${currentSystemUser}".path;
    #users.root.hashedPasswordFile = "";
    users.root.openssh.authorizedKeys.keys = [
      "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIHo+NCpecLu+vJrhgp0deaNXblILsmxxixpTg8pw+WAL"
    ];
  };
}
