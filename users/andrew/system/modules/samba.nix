{
  config,
  lib,
  pkgs,
  systemInfo,
  isWSL,
  ...
}: let
  # inherit (builtins) getEnv;
  inherit (lib.modules) mkIf mkMerge;

  cfg = config.networking.samba;

  mkShare = {
    path,
    user,
  }: {
    inherit path;
    browseable = "yes";
    "read only" = "yes";
    "guest ok" = "no";
    "force user" = user;
    "force group" = "users";
    "valid users" = user;
  };

  mkWriteShare = {
    path,
    user,
  }: {
    inherit path;
    browseable = "yes";
    "read only" = "no";
    "guest ok" = "no";
    "force user" = user;
    "force group" = "users";
    "write list" = user;
    "valid users" = user;
  };
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
          ${
            if isWSL
            then "smb ports = 3330 3335"
            else ""
          }
        '';

        # :NOTE for Public| set sudo smbpasswd -a samba-guest -n
        # :NOTE for others| set sudo smbpasswd -a $(whoami)
        shares = {
          # Basic shared folder example
          public = {
            #path = (getEnv "HOME") + "/Public";
            path = systemInfo.home + "/public";
            browseable = "yes";
            "read only" = "yes";
            "guest ok" = "yes";
            "force user" = systemInfo.user;
            "force group" = "samba-guest";
            "write list" = systemInfo.user;
          };

          home = mkShare {
            path = systemInfo.home;
            inherit (systemInfo) user;
          };
          home_write = mkWriteShare {
            path = systemInfo.home;
            inherit (systemInfo) user;
          };

          storage = mkIf cfg.storage.enable (mkShare {
            path = "/mnt/storage";
            inherit (systemInfo) user;
          });
          storage_write = mkIf cfg.storage.enable (mkWriteShare {
            path = "/mnt/storage";
            inherit (systemInfo) user;
          });

          c_drive = mkIf isWSL (mkShare {
            path = "/mnt/c/Users/AJ-XPS/";
            inherit (systemInfo) user;
          });
          c_drive_write = mkIf isWSL (mkWriteShare {
            path = "/mnt/c/Users/AJ-XPS/";
            inherit (systemInfo) user;
          });
        };
      };
    })
  ];
}
