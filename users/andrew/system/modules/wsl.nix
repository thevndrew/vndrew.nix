{
  config,
  inputs,
  lib,
  pkgs,
  systemInfo,
  ...
}: let
  cfg = config.wsl-cfg;
in {
  imports = [
    inputs.nixos-wsl.nixosModules.default
  ];

  options = {
    wsl-cfg.enable = lib.mkOption {
      type = lib.types.bool;
      default = false;
      example = true;
      description = "Configure defaults for WSL-based systems";
    };
  };

  config = lib.mkIf cfg.enable {
    my-networking.enable = false;
    my-virtualisation.enable = false;
    wsl = {
      enable = true;

      defaultUser = systemInfo.user;
      docker-desktop.enable = true;

      extraBin = with pkgs; [
        # Binaries for Docker Desktop wsl-distro-proxy
        {src = "${coreutils}/bin/mkdir";}
        {src = "${coreutils}/bin/cat";}
        {src = "${coreutils}/bin/whoami";}
        {src = "${coreutils}/bin/ls";}
        {src = "${busybox}/bin/addgroup";}
        {src = "${su}/bin/groupadd";}
        {src = "${su}/bin/usermod";}
      ];

      startMenuLaunchers = true;

      wslConf = {
        automount.root = "/mnt";
        interop.appendWindowsPath = false;
        network.generateHosts = false;
      };
    };
  };
}
