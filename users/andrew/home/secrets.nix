{ inputs, currentSystemHome, sopsKey, ... }:
{
  sops = {
    age.sshKeyPaths = [ "${sopsKey}" ];
    defaultSopsFile = "${inputs.mysecrets}/secrets/services_env.yaml";
    secrets.services_env = {
      sopsFile = "${inputs.mysecrets}/secrets/services_env.yaml";
      path = "${currentSystemHome}/.config/services.env"; 
    };
  };
}
