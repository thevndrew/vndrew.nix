{
  inputs,
  hostname,
  username,
  pkgs,
  ...
}: {
  vndrewMods = {
  };

  home.packages = [
    # on WSL just use: winget install win32yank
    pkgs.wl-clipboard
  ];

  sops = {
    secrets = {
      "services/${hostname}" = {
        sopsFile = "${inputs.mysecrets}/secrets/services.yaml";
        path = "/home/${username}/.config/services/${hostname}.yaml";
      };
    };
  };
}
