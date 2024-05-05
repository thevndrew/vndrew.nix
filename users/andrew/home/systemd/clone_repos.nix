{ mylib, lib, pkgs, systemInfo, ... }:
let
  repoList = mylib.relativeToRoot "config/repos/repos.yml";
in
{
  systemd.user.services.clone_repos = {
    Unit = {
      Description = "Clone repos to current system";
    };
    Install = {
      WantedBy = [ "default.target" ];
    };
    Service = {
      ExecStart = "${pkgs.writeShellScript "clone_repos" ''
        #!/bin/bash

        # Add yq to path
        PATH=$PATH:${lib.makeBinPath [ pkgs.yq ]}

        # Function to clone a repository if it doesn't already exist
        clone_if_not_exists() {
            local REPO_URL="$1"
            local CLONE_DIR="$2"
        
            [ ! -d "$CLONE_DIR" ] && git clone "$REPO_URL" "$CLONE_DIR" || echo "Directory '$CLONE_DIR' already exists. Skipping clone."
        }

        mkdir_if_not_exists() {
            local DIR=$(dirname "$1")

            [ ! -d "$DIR" ] && mkdir -pv "$DIR"
        }

        REPOS=($(yq -r '.repo_list | keys[]' "${repoList}"))

        for REPO in ''${REPOS[@]};
        do
            REPO_DIR=$(yq -r ".repo_list.$REPO.directory" "${repoList}")
            REPO_URL=$(yq -r ".repo_list.$REPO.url" "${repoList}")
            mkdir_if_not_exists "${systemInfo.home}/$REPO_DIR"
            clone_if_not_exists "$REPO_URL" "${systemInfo.home}/$REPO_DIR"
        done 
      ''}";
    };
  };
}
