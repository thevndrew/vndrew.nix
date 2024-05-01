{ inputs, systemInfo, sopsKey, ... }:
{
  sops = {
    age.sshKeyPaths = [ "${sopsKey}" ];
    defaultSopsFile = "${inputs.mysecrets}/secrets/services_env.yaml";
    secrets.services_env = {
      sopsFile = "${inputs.mysecrets}/secrets/services_env.yaml";
      path = "${systemInfo.home}/.config/services.env"; 
    };
  };
}
