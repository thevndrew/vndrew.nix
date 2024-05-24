{
  config,
  inputs,
  mylib,
  lib,
  pkgs,
  systemInfo,
  ...
}: {
  imports = [];

  users.users.${systemInfo.user}.extraGroups = ["wheel"];

  networking = {
    hostName = "polar-tang";
  };

  system.stateVersion = "23.11"; # Did you read the comment?
}
