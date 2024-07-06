{other-pkgs, ...}: let
  inherit (other-pkgs) unstable;

  zja = {pkgs}:
    pkgs.writeShellApplication {
      name = "zja";
      runtimeInputs = with pkgs; [skim ripgrep];
      text = ''
        set +o errexit
        set +o nounset
        set +o pipefail

        ZJ_SESSIONS=$(zellij list-sessions  | \
                      rg -v EXITED\|current | \
                      cut -d" " -f1         | \
                      sed -r 's/[\x1B\x9B][][()#;?]*(([a-zA-Z0-9;]*\x07)|([0-9;]*[0-9A-PRZcf-ntqry=><~]))//g')
        CURRENT_SESSION=$(zellij list-sessions | \
                          rg "(current)"    | \
                          cut -d" " -f1        | \
                          sed -r 's/[\x1B\x9B][][()#;?]*(([a-zA-Z0-9;]*\x07)|([0-9;]*[0-9A-PRZcf-ntqry=><~]))//g')
        NO_SESSIONS=$(echo "''${ZJ_SESSIONS}" | wc -l)

        if [ "''${NO_SESSIONS}" -ge 2 ]; then
            zellij attach \
            "$(echo "''${ZJ_SESSIONS}" | sk)"
        elif [ -n "''${CURRENT_SESSION}" ]; then
            echo "You're currently in session $CURRENT_SESSION!!"
        else
            zellij attach -c
        fi
      '';
    };
in {
  programs.zellij = {
    enable = true;
    package = unstable.zellij;
    settings = {
      #theme = "gruvbox-dark";
      #theme = "custom"
      #themes.custom.fg = "#ffffff";
    };
  };

  home.packages = [
    (zja {pkgs = unstable;})
  ];

  home.shellAliases = {
    "zj" = "zellij";
  };
}
