{pkgs}:
pkgs.writeShellApplication {
  name = "remove_secrets_key";
  text = ''
    set +o errexit
    rm -v "$SOPS_AGE_KEY_FILE"
    unset SOPS_AGE_KEY_FILE
    set +o nounset
    set +o pipefail
  '';
}
