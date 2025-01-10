{python3Packages, ...}: let
  name = "crx-dl";
  version = "0.0.1";
in
  with python3Packages;
    buildPythonApplication {
      inherit name version;
      src = ./.;
    }
