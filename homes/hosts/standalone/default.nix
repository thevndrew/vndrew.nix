{pkgs, ...}: {
  home.packages = with pkgs.unstable; [
    nh
  ];
}
