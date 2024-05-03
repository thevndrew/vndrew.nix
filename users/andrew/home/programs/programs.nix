{ mylib, pkgs, other-pkgs, ... }:
let
  streamScriptsDir = "config/scripts/stream_downloader";
  pathTo = mylib.relativeToRoot;
  readFile = path: builtins.readFile (pathTo path);
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
  (with other-pkgs.unstable; [
    btop
    cht-sh
    ctop
    fzf
    glow
    htop
    jq
    just
    ncdu
    neovim
    nix-output-monitor
    nnn
    nvd
    rclone
    rsync
    shellcheck
    shellharden
    tmux
    tree
    unar
    unzip
    wget
    yq
    yt-dlp
    #bitwarden-cli
    #cosmopolitan
    #croc
    #gost
    #wormhole-william
    #rbw
    #pinentry # rbw dep
  ]) ++
  ([
    (pkgs.writeShellApplication {
      name = "update_input";
      runtimeInputs = with other-pkgs.unstable; [ fzf jq ];
      text = ''
        input=$(nix flake metadata --json                \
             | jq -r ".locks.nodes.root.inputs | keys[]" \
             | fzf)
        nix flake lock --update-input "$input"
      '';
    })
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
