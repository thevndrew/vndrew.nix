{
  config,
  inputs,
  pkgs,
  systemInfo,
  sopsKey,
  ...
}: {
  sops = {
    defaultSopsFile = "${inputs.mysecrets}/secrets/nix.yaml";
    age.sshKeyPaths = ["${sopsKey}"];
    secrets."passwords/${systemInfo.user}" = {
      neededForUsers = true;
    };
  };

  users = {
    mutableUsers = false;
    users.${systemInfo.user} = {
      hashedPasswordFile = config.sops.secrets."passwords/${systemInfo.user}".path;
      #initialPassword = "${systemInfo.user}";
      home = "${systemInfo.home}";
      shell = pkgs.zsh;
      isNormalUser = true;
      openssh.authorizedKeys.keys = [
        "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIHo+NCpecLu+vJrhgp0deaNXblILsmxxixpTg8pw+WAL WSL"
        "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIDhkI3pjA6Wlpqg/cycwov3VXXbivbBMXDzUyxIyYwJF polar-tang"
        "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIKjhR4i/ce5HZ/W2tEJsbEJL2754R5H24bPD3cBxdWEP thousand-sunny"
        "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAINGqG13rubr95t6Yepq745+TxYtyqR50BZhR33eDtlUX going-merry"
      ];
    };
    users.root.hashedPasswordFile = config.sops.secrets."passwords/${systemInfo.user}".path;
    #users.root.hashedPasswordFile = "";
    users.root.openssh.authorizedKeys.keys = [
      "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIHo+NCpecLu+vJrhgp0deaNXblILsmxxixpTg8pw+WAL"
      "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIDhkI3pjA6Wlpqg/cycwov3VXXbivbBMXDzUyxIyYwJF polar-tang"
      "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIKjhR4i/ce5HZ/W2tEJsbEJL2754R5H24bPD3cBxdWEP thousand-sunny"
      "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAINGqG13rubr95t6Yepq745+TxYtyqR50BZhR33eDtlUX going-merry"
    ];
  };
}
