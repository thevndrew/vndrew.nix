{ inputs, mylib, pkgs, other-pkgs, systemInfo, ... }:
let
  scriptsDir = "config/scripts";
  streamScriptsDir = "${scriptsDir}/stream_downloader";

  pathTo = mylib.relativeToRoot;
  readFile = path: builtins.readFile (pathTo path);

  inherit (other-pkgs) vndrew unstable nix-alien;
in
{
  home.packages = (with pkgs; [
    dig
    hddtemp
    iotop
    lsof
    ngrep
    nmap
    nvme-cli
    tdns-cli
    wakeonlan

    # Do install the docker CLI to talk to podman.
    # Not needed when virtualisation.docker.enable = true;
    docker-client

    docker-compose

    # # It is sometimes useful to fine-tune packages, for example, by applying
    # # overrides. You can do that directly here, just don't forget the
    # # parentheses. Maybe you want to install Nerd Fonts with a limited number of
    # # fonts?
    # (pkgs.nerdfonts.override { fonts = [ "FantasqueSansMono" ]; })
  ]) ++
  (with unstable; [
    btop
    cht-sh
    ctop
    fzf
    fd
    glow
    htop
    jq
    just
    lf
    ncdu
    nix-output-monitor
    nvd
    rclone
    rsync
    shellcheck
    shellharden
    sops
    ssh-to-age 
    tmux
    tree
    unar
    unzip
    wget
    yazi
    yq
    yt-dlp
    #bitwarden-cli
    #cosmopolitan
    #croc
    #gost
    #wormhole-william
    #rbw
    #pinentry # rbw dep

    nix-alien.nix-alien
  ]) ++
  (with vndrew; [
    bootdev
    megadl
  ]) ++
  ([
    (import ./shell/scripts/update_input.nix { pkgs = unstable; })

    (import ./shell/scripts/get_secrets_key.nix { pkgs = unstable; })

    (import ./shell/scripts/remove_secrets_key.nix { pkgs = unstable; })

    (import ./shell/scripts/clone_repos.nix { inherit mylib; inherit systemInfo; pkgs = unstable; })

    (pkgs.writeShellApplication {
      name = "rip_streams";
      runtimeInputs = with other-pkgs.unstable; [ yq ];
      text = ''
        ${readFile "${streamScriptsDir}/rip_streams.sh"}
      '';
    })
    (pkgs.writeShellApplication {
      name = "rip_streams_stop";
      runtimeInputs = with other-pkgs.unstable; [ yq ];
      text = ''
        ${readFile "${streamScriptsDir}/rip_streams_stop.sh"}
      '';
    })
    (pkgs.writeShellApplication {
      name = "rip_stream_helper";
      runtimeInputs = with other-pkgs.unstable; [ yq yt-dlp ];
      text = ''
        ${readFile "${streamScriptsDir}/rip_stream_helper.sh"}
      '';
    })
  ]);
}
