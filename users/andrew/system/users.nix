{
  lib,
  config,
  inputs,
  pkgs,
  systemInfo,
  sopsKeys,
  isWSL,
  ...
}: let
  keys = [
    "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIHo+NCpecLu+vJrhgp0deaNXblILsmxxixpTg8pw+WAL WSL"
    "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIDhkI3pjA6Wlpqg/cycwov3VXXbivbBMXDzUyxIyYwJF polar-tang"
    "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIKjhR4i/ce5HZ/W2tEJsbEJL2754R5H24bPD3cBxdWEP thousand-sunny"
    "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAINGqG13rubr95t6Yepq745+TxYtyqR50BZhR33eDtlUX going-merry"
  ];
  wslPass = "$6$90MQYhLKTQJ71Zw9$WrsMNytjnVmZcKNwuWg3grXPsfC2LTw5wt7QGcHc9A5fJUIhskOhJd1L0s.E.VRgpzeuckuEgrojxqqkch51V0";
in {
  sops = lib.mkIf (!isWSL) {
    defaultSopsFile = "${inputs.mysecrets}/secrets/nix.yaml";
    age.sshKeyPaths = sopsKeys;
    secrets."passwords/${systemInfo.user}" = {
      neededForUsers = true;
    };
  };

  users = {
    mutableUsers = false;
    users.${systemInfo.user} =
      {
        home = "${systemInfo.home}";
        shell = pkgs.zsh;
        isNormalUser = true;
        openssh.authorizedKeys.keys = keys;
      }
      // lib.optionalAttrs (!isWSL) {
        hashedPasswordFile = config.sops.secrets."passwords/${systemInfo.user}".path;
      }
      // lib.optionalAttrs isWSL {
        initialHashedPassword = wslPass;
      };

    users.root =
      {
        openssh.authorizedKeys.keys = keys;
      }
      // lib.optionalAttrs (!isWSL) {
        hashedPasswordFile = config.sops.secrets."passwords/${systemInfo.user}".path;
      }
      // lib.optionalAttrs isWSL {
        initialHashedPassword = wslPass;
      };
  };
}
