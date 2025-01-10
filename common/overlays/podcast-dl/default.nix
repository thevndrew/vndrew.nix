{pkgs, ...}: let
  dep_pkgs = with pkgs; [yt-dlp];

  py_pkgs = with pkgs.python3Packages; [
    pyyaml
  ];

  name = "podcast-dl.py";
  version = "0.0.1";
in
  pkgs.python3Packages.buildPythonApplication {
    inherit name version;

    dependencies = dep_pkgs ++ py_pkgs;

    src = ./.;
  }
