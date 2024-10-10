{
  lib,
  inputs,
  systemInfo,
  sopsKeys,
  isWSL,
  ...
}: {
  sops = {
    age.sshKeyPaths = sopsKeys;
    defaultSopsFile = "${inputs.mysecrets}/secrets/services.yaml";

    secrets = {
      "services/env" = {
        sopsFile = "${inputs.mysecrets}/secrets/services.yaml";
        path = "${systemInfo.home}/.config/services/services.env";
      };

      "services/${systemInfo.hostname}" = lib.mkIf (!isWSL) {
        sopsFile = "${inputs.mysecrets}/secrets/services.yaml";
        path = "${systemInfo.home}/.config/services/${systemInfo.hostname}.yaml";
      };

      "atuin_key" = {
        sopsFile = "${inputs.mysecrets}/secrets/atuin.yaml";
      };
    };
  };
}
