{ mylib, pkgs, other-pkgs, ... }:
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

    #(pkgs.writeShellScriptBin "dl_all_streams" ''
    #  ${mylib.relativeToRoot "config/scripts/dl_all_streams.sh"}
    #'')
    #(pkgs.writeShellScriptBin "dl_stream" ''
    #  ${mylib.relativeToRoot "config/scripts/dl_stream.sh"}
    #'')
    #(pkgs.writeShellScriptBin "kill_stream_dls" ''
    #  ${mylib.relativeToRoot "config/scripts/kill_stream_dls.sh"}
    #'')
    #(pkgs.writeShellScriptBin "select_kill_stream_dl" ''
    #  ${mylib.relativeToRoot "config/scripts/select_kill_stream_dl.sh"}
    #'')
    #(pkgs.writeShellScriptBin "select_stream_dl" ''
    #  ${mylib.relativeToRoot "config/scripts/select_stream_dl.sh"}
    #'')
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
  ]);
}
