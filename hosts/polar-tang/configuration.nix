{systemInfo, ...}: {
  imports = [];

  users.users.${systemInfo.user}.extraGroups = ["wheel" "docker"];
  users.extraGroups.docker.members = ["${systemInfo.user}"];

  networking = {
    hostName = "polar-tang";
  };

  system.stateVersion = "23.11"; # Did you read the comment?
}
