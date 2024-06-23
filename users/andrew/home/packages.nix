{
  lib,
  pkgs,
  other-pkgs,
  isWSL,
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

      # # It is sometimes useful to fine-tune packages, for example, by applying
      # # overrides. You can do that directly here, just don't forget the
      # # parentheses. Maybe you want to install Nerd Fonts with a limited number of
      # # fonts?
      # (pkgs.nerdfonts.override { fonts = [ "FantasqueSansMono" ]; })
    ]
    ++ (lib.optionals (!isWSL) [
      # Do install the docker CLI to talk to podman.
      # Not needed when virtualisation.docker.enable = true;
      pkgs.docker-client
      pkgs.docker-compose

      pkgs.distrobox
      unstable.wl-clipboard # on WSL just use: winget install win32yank
    ]);

  unstable-pkgs = with unstable; [
    bfs
    bottom # module avalible
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
    nomino
    nvd
    gitleaks
    parallel
    procs
    rclone
    rnr
    rsync
    sd
    shellcheck
    shellharden
    silver-searcher
    skim
    sops
    ssh-to-age
    tmux
    tokei
    tree
    unar
    unzip
    wget
    xh
    yazi
    yq
    yt-dlp
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
  ];
in {
  home.packages = stable-pkgs ++ unstable-pkgs ++ vndrew-pkgs;
}
