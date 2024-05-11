{ pkgs }:
  pkgs.writeShellApplication {
    name = "get_secrets_key";
    runtimeInputs = with pkgs; [ ssh-to-age ripgrep fzf ];
    text = ''
      set +o errexit

      key=$(find ~/.ssh -type f -printf "%f\n" | rg -v '^config$|^known_hosts$|.pub$' | fzf)
      ssh-to-age -private-key -i "$HOME/.ssh/$key" > "/tmp/$key".txt
      SOPS_AGE_KEY_FILE="/tmp/$key".txt
      export SOPS_AGE_KEY_FILE

      set +o nounset
      set +o pipefail
    '';
  }
