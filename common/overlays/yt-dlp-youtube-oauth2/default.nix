{
  python3Packages,
  inputs,
  ...
}: let
  name = "yt-dlp-youtube-oauth2";
  version = "v2024.9.29";
in
  with python3Packages;
    buildPythonApplication {
      inherit name version;
      src = inputs.yt-dlp-youtube-oauth2;
      format = "pyproject";
      propagatedBuildInputs = [hatchling];
    }
