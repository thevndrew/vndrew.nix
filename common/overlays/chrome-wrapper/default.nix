{pkgs, ...}: let
  name = "google-chrome";
in
  pkgs.writeShellScriptBin name ''
    #! ${pkgs.stdenv.shell}
    exec -a $0 ${pkgs.ungoogled-chromium}/bin/chromium $@
  ''
