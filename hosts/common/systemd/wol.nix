{wolCommand}: {
  config,
  pkgs,
  ...
}: {
  systemd.services.wol = {
    enable = true;
    description = "Wake-on-LAN service";
    path = [pkgs.ethtool];
    after = ["network.target"];
    requires = ["network.target"];
    unitConfig = {
      Type = "oneshot";
    };
    serviceConfig = {
      ExecStart = "/bin/sh -c '${wolCommand}'";
    };
    wantedBy = ["multi-user.target"];
  };
}
