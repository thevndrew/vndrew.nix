{ inputs, mylib, pkgs, other-pkgs, systemInfo, ... }:
let
  scriptsDir = "config/scripts";
  streamScriptsDir = "${scriptsDir}/stream_downloader";
  repoList = mylib.relativeToRoot "config/repos/repos.yml";

  pathTo = mylib.relativeToRoot;
  readFile = path: builtins.readFile (pathTo path);

  inherit (other-pkgs) vndrew unstable;
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
  ]) ++
  (with vndrew; [
    bootdev
    megadl
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
      name = "clone_repos";
      runtimeInputs = with other-pkgs.unstable; [ yq git ];
      text = ''
        set +o errexit

        # Function to clone a repository if it doesn't already exist
        clone_if_not_exists() {
            local REPO_URL="$1"
            local CLONE_DIR="$2"

            [ ! -d "$CLONE_DIR" ] && git clone "$REPO_URL" "$CLONE_DIR" || echo "Directory '$CLONE_DIR' already exists. Skipping clone."
        }

        mkdir_if_not_exists() {
            local DIR
            DIR=$(dirname "$1")

            [ ! -d "$DIR" ] && mkdir -pv "$DIR"
        }

        REPOS=()
        while IFS='''''' read -r line;
        do
            REPOS+=("$line");
        done < <(yq -r '.repo_list | keys[]' "${repoList}")

        for REPO in "''${REPOS[@]}";
        do
            REPO_DIR=$(yq -r ".repo_list.$REPO.directory" "${repoList}")
            REPO_URL=$(yq -r ".repo_list.$REPO.url" "${repoList}")
            mkdir_if_not_exists "${systemInfo.home}/$REPO_DIR"
            clone_if_not_exists "$REPO_URL" "${systemInfo.home}/$REPO_DIR"
        done 

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
