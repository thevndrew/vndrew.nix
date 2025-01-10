{
  python3Packages,
  pkgs,
  ...
}: let
  name = "megadl";
  version = "0.0.1";
  inherit (python3Packages) buildPythonApplication requests;
in
  buildPythonApplication {
    inherit name version;
    propagatedBuildInputs = with pkgs; [megatools requests];
    src = ./.;
  }
