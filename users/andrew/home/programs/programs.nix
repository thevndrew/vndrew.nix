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
    sops
    ssh-to-age 
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
      name = "get_secrets_key";
      runtimeInputs = with other-pkgs.unstable; [ ssh-to-age ripgrep fzf ];
      text = ''
        set +o errexit

        key=$(find ~/.ssh -type f -printf "%f\n" | rg -v '^config$|^known_hosts$|.pub$' | fzf)
        ssh-to-age -private-key -i "$HOME/.ssh/$key" > "/tmp/$key".txt
        SOPS_AGE_KEY_FILE="/tmp/$key".txt
        export SOPS_AGE_KEY_FILE

        set +o nounset
        set +o pipefail
      '';
    })

    (pkgs.writeShellApplication {
      name = "remove_secrets_key";
      text = ''
        set +o errexit
	rm -v "$SOPS_AGE_KEY_FILE"
	unset SOPS_AGE_KEY_FILE
        set +o nounset
        set +o pipefail
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
