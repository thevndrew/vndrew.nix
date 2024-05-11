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
    bfs
    bottom # module avalible
    broot
    btop
    charm-freeze
    choose
    cht-sh
    ctop
    curlie
    dog
    duf
    dust
    eza
    fd
    fzf
    glow
    gping
    htop
    jq
    just
    lf
    ncdu
    nix-output-monitor
    nvd
    parallel
    procs
    rclone
    rsync
    sd
    shellcheck
    shellharden
    silver-searcher
    sops
    ssh-to-age 
    tmux
    tree
    unar
    unzip
    #vhs # only install on desktop
    wget
    xh
    yazi
    yq
    yt-dlp
    #bitwarden-cli
    #cosmopolitan
    #croc
    #gost
    #glances # python based
    #wormhole-william
    #rbw
    #pinentry # rbw dep

    nix-alien.nix-alien
  ]) ++
  (with vndrew; [
    bootdev
    megadl
  ]);
}
