{
  inputs,
  lib,
  ...
}: {pkgs}: let
  username = "andrew";

  keys = [
    "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIDhkI3pjA6Wlpqg/cycwov3VXXbivbBMXDzUyxIyYwJF polar-tang"
    "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIKjhR4i/ce5HZ/W2tEJsbEJL2754R5H24bPD3cBxdWEP thousand-sunny"
    "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAINGqG13rubr95t6Yepq745+TxYtyqR50BZhR33eDtlUX going-merry"
  ];

  gitea-shell = pkgs.writeShellScriptBin "gitea-shell" ''
    ${pkgs.docker-client}/bin/docker exec -i --env SSH_ORIGINAL_COMMAND="$SSH_ORIGINAL_COMMAND" gitea sh "$@"
  '';
in rec {
  mutableUsers = false;

  users = {
    ${username} = {
      name = username;
      shell = pkgs.zsh;
      isNormalUser = true;
      extraGroups = ["networkmanager" "wheel" "podman" "storage" "docker" "vboxusers" "input"];
      # this is packages for nixOS user config.
      # packages = []; # empty because that is managed by home-manager
      uid = 1001;
      openssh.authorizedKeys.keys = keys;
    };

    root = {
      openssh.authorizedKeys.keys = keys;
    };

    git = {
      extraGroups = ["podman" "docker"];
      isNormalUser = true;
      openssh.authorizedKeys.keys = keys;
      shell = "${gitea-shell}/bin/gitea-shell";
    };
  };

  groups = {
    users.gid = 100;
    #storage.gid = ???;
    ${username} = {};
  };

  git = {
    ${username} = {
      extraConfig = {
        core = {
          autoSetupRemote = "true";
          fsmonitor = "true";
        };
      };
      userName = username;
    };
  };

  homeManager = {
    ${username} = mkHMdir username;
  };

  mkHMdir = username: let
    homeDirPrefix =
      if pkgs.stdenv.hostPlatform.isDarwin
      then "Users"
      else "home";
    homeDirectory = "/${homeDirPrefix}/${username}";
  in {
    inherit username homeDirectory;
  };
}
