{
  other-pkgs,
  isWSL,
  ...
}: let
  unstable = other-pkgs.unstable;
in {
  services = {
    cockpit = {
      enable = !isWSL;
      package = unstable.cockpit;
      port = 8085;
    };
  };
  environment.systemPackages = [
    other-pkgs.vndrew.cockpit-podman
  ];
}
