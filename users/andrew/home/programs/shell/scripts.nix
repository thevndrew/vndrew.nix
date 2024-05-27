{
  inputs,
  mylib,
  pkgs,
  other-pkgs,
  systemInfo,
  ...
}: let
  scriptsDir = "config/scripts";
  streamScriptsDir = "${scriptsDir}/stream_downloader";

  pathTo = mylib.relativeToRoot;
  readFile = path: builtins.readFile (pathTo path);

  inherit (other-pkgs) unstable;
in {
  home.packages = [
    (import ./scripts/update_input.nix {pkgs = unstable;})

    (import ./scripts/get_secrets_key.nix {pkgs = unstable;})

    (import ./scripts/remove_secrets_key.nix {pkgs = unstable;})

    (import ./scripts/clone_repos.nix {
      inherit mylib;
      inherit systemInfo;
      pkgs = unstable;
    })

    (pkgs.writeShellApplication {
      name = "zipcbz";
      runtimeInputs = with other-pkgs.unstable; [zip];
      text = ''
        set +o nounset
        ${readFile "${scriptsDir}/zipcbz.bash"}
      '';
    })

    (pkgs.writeShellApplication {
      name = "rip_streams";
      runtimeInputs = with other-pkgs.unstable; [yq];
      text = ''
        ${readFile "${streamScriptsDir}/rip_streams.sh"}
      '';
    })
    (pkgs.writeShellApplication {
      name = "rip_streams_stop";
      runtimeInputs = with other-pkgs.unstable; [yq];
      text = ''
        ${readFile "${streamScriptsDir}/rip_streams_stop.sh"}
      '';
    })
    (pkgs.writeShellApplication {
      name = "rip_stream_helper";
      runtimeInputs = with other-pkgs.unstable; [yq yt-dlp];
      text = ''
        ${readFile "${streamScriptsDir}/rip_stream_helper.sh"}
      '';
    })
  ];
}
