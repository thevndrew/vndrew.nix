{
  inputs,
  hostname,
  username,
  ...
}: {
  vndrewMods = {
  };

  sops = {
    secrets = {
      "services/${hostname}" = {
        sopsFile = "${inputs.mysecrets}/secrets/services.yaml";
        path = "/home/${username}/.config/services/${hostname}.yaml";
      };
    };
  };
}
