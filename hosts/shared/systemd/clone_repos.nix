# Currently not using this, using a home manager systemd service instead.
# This is just here for reference on a nix systemd service.
{ homeDir }:
{ mylib, config, pkgs, ... }:
let
  repoList = mylib.relativeToRoot "config/repos/repos.yml";
in
{
  systemd.user.services.clone_repos = {
    path = [ pkgs.yq ];
    unitConfig = {
      Description = "Clone repos to system";
    };
    serviceConfig = {
        ExecStart = "${pkgs.writeShellScript "clone_repos" ''
          #!/bin/bash
  
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
              mkdir_if_not_exists "${homeDir}/$REPO_DIR"
              clone_if_not_exists "$REPO_URL" "${homeDir}/$REPO_DIR"
          done 
        ''}";
      };
    wantedBy = [ "default.target" ];
  };
}
