{
  python3Packages,
  inputs,
  ...
}: let
  name = "yt-dlp-get-pot";
  version = "v0.2.0";
in
  with python3Packages;
    buildPythonApplication {
      inherit name version;
      src = inputs.yt-dlp-get-pot;
      format = "pyproject";
      propagatedBuildInputs = [hatchling];
    }
