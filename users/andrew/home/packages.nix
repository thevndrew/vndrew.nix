{
  isStandalone,
  isWSL,
  lib,
  other-pkgs,
  pkgs,
  ...
}: let
  inherit (other-pkgs) vndrew unstable nix-alien;

  stable-pkgs = with pkgs;
    [
      dig
      hddtemp
      iotop
      lsof
      ngrep
      nmap
      nvme-cli
      tdns-cli
      wakeonlan

      nix-du
    ]
    ++ (lib.optionals (!isWSL) [
      # Do install the docker CLI to talk to podman.
      # Not needed when virtualisation.docker.enable = true;
      pkgs.docker-client
      pkgs.docker-compose

      unstable.wl-clipboard # on WSL just use: winget install win32yank
    ]);

  unstable-pkgs = with unstable; [
    # pueue
    # pprof
    # perf
    # buf
    # srgn
    bfs
    bottom # module avalible
    btop
    charm-freeze
    choose
    cht-sh
    coreutils
    ctop
    curlie
    distrobox
    dog
    dotenvx
    duf
    dust
    eza
    fd
    fx
    gitleaks
    glow
    gping
    htop
    jq
    killall
    lf
    ncdu
    nix-output-monitor
    nix-tree
    nomino
    nvd
    parallel
    plocate
    procs
    rclone
    rnr
    rsync
    sd
    shellcheck
    shellharden
    shfmt
    silver-searcher
    skim
    sops
    ssh-to-age
    teller
    # termscp
    tmux
    tokei
    tree
    trufflehog
    unar
    unzip
    uutils-coreutils
    #uutils-coreutils-noprefix
    wget
    xh
    yazi
    yq
    yt-dlp
    zip

    #findutils
    #mkcert
    #vhs # only install on desktop
    #bitwarden-cli
    #cosmopolitan
    #croc
    #gost
    #glances # python based
    #wormhole-william
    #rbw
    #pinentry # rbw dep

    nix-alien.nix-alien
  ];

  vndrew-pkgs = with vndrew; [
    bootdev
    megadl
    yt-dlp-youtube-oauth2
    yt-dlp-get-pot
  ];

  standalone = with unstable; [
    nh
  ];
in {
  home.packages = stable-pkgs ++ unstable-pkgs ++ vndrew-pkgs ++ (lib.optionals isStandalone standalone);
}
