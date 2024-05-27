{
  config,
  lib,
  pkgs,
  systemInfo,
  ...
}: let
  inherit (builtins) getEnv;
  inherit (lib.modules) mkIf mkMerge;
  cfg = config.networking.samba;
in {
  options.networking.samba = let
    inherit (lib.options) mkEnableOption;
  in {
    sharing.enable = mkEnableOption "Samba: enable NixOS -> external file-transfer";
    receiving.enable = mkEnableOption "Samba: enable external -> NixOS file-transfer";
    storage.enable = mkEnableOption "Samba: Share ZFS storage";
  };

  config = mkMerge [
    (mkIf cfg.sharing.enable {
      users = {
        groups.samba-guest = {};
        users.samba-guest = {
          isSystemUser = true;
          description = "Residence of our Samba guest users";
          group = "samba-guest";
          home = "/var/empty";
          createHome = false;
          shell = pkgs.shadow;
        };
      };

      users.users.${systemInfo.user}.extraGroups = ["samba-guest"];

      services.samba-wsdd = {
        enable = true; # make shares visible for windows 10 clients
        openFirewall = false; # tailscale handles the connections
      };

      services.samba = {
        enable = true;
        openFirewall = false; # tailscale handles the connections
        extraConfig = ''
          server string = ${config.networking.hostName}
          netbios name = ${config.networking.hostName}
          workgroup = WORKGROUP
          security = user

          create mask = 0664
          force create mode = 0664
          directory mask = 0775
          force directory mode = 0775
          follow symlinks = yes

          # :NOTE| localhost is the ipv6 localhost ::1
          # hosts allow = 192.168.0.0/16 localhost
          # hosts deny = 0.0.0.0/0
          hosts allow = 0.0.0.0/0 # only tailscale can access this anyway
          guest account = nobody
          map to guest = bad user
        '';

        # :NOTE for Public| set sudo smbpasswd -a samba-guest -n
        # :NOTE for Private| set sudo smbpasswd -a $(whoami)
        shares = {
          public = {
            #path = (getEnv "HOME") + "/Public";
            #path = (getEnv "HOME");
            path = systemInfo.home;
            browseable = "yes";
            "read only" = "yes";
            "guest ok" = "yes";
            "force user" = systemInfo.user;
            "force group" = "samba-guest";
            "write list" = systemInfo.user;
          };
          private = {
            path = systemInfo.home;
            browseable = "yes";
            "read only" = "no";
            "guest ok" = "no";
            "force user" = systemInfo.user;
            "force group" = "users";
            "write list" = systemInfo.user;
            "valid users" = systemInfo.user;
          };
          storage = mkIf cfg.storage.enable {
            path = "/mnt/storage";
            browseable = "yes";
            "read only" = "yes";
            "guest ok" = "yes";
            "force user" = systemInfo.user;
            "force group" = "samba-guest";
            "write list" = systemInfo.user;
          };
          storage_write = mkIf cfg.storage.enable {
            path = "/mnt/storage";
            browseable = "yes";
            "read only" = "no";
            "guest ok" = "no";
            "force user" = systemInfo.user;
            "force group" = "users";
            "write list" = systemInfo.user;
            "valid users" = systemInfo.user;
          };
        };
      };
    })
  ];
}
