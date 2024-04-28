{ isDesktop, isWSL }:

{ mylib, lib, config, inputs, pkgs, pkgs-unstable, currentSystemUser, currentSystemHome, ... }:
{
  imports = [
    ./files.nix
    ./secrets.nix 
    ./systemd/clone_repos.nix
  ] ++ 
  (mylib.scanPaths ./programs)
  ;

  # Home Manager needs a bit of information about you and the paths it should
  # manage.
  home.username = "${currentSystemUser}";
  home.homeDirectory = "${currentSystemHome}";

  # This value determines the Home Manager release that your configuration is
  # compatible with. This helps avoid breakage when a new Home Manager release
  # introduces backwards incompatible changes.
  #
  # You should not change this value, even if you update Home Manager. If you do
  # want to update the value, then make sure to first check the Home Manager
  # release notes.
  home.stateVersion = "23.11"; # Please read the comment before changing.

  programs.ssh = {
    enable = true;
    #extraConfig = ''
    #  ${builtins.readFile (mylib.relativeToRoot "config/ssh/config")}
    #'';
    extraConfig = ''${builtins.readFile (mylib.relativeToRoot "config/ssh/config")}'';
  };

  home.packages = (with pkgs; [
    #bitwarden-cli
    btop
    cht-sh
    #croc
    ctop
    dig
    docker-compose
    glow
    #gost
    hddtemp
    htop
    iotop
    jq
    lsof
    ncdu
    neovim
    ngrep
    nmap
    nnn
    nvme-cli
    rclone
    rsync
    shellcheck
    #shellharden
    tdns-cli
    tmux
    tree
    unar
    unzip
    wakeonlan
    wget
    #wormhole-william
    yq
    yt-dlp
    #cosmopolitan
    #pkgs-unstable.rbw
    #pinentry # rbw dep

    # Do install the docker CLI to talk to podman.
    # Not needed when virtualisation.docker.enable = true;
    docker-client

    # # It is sometimes useful to fine-tune packages, for example, by applying
    # # overrides. You can do that directly here, just don't forget the
    # # parentheses. Maybe you want to install Nerd Fonts with a limited number of
    # # fonts?
    # (pkgs.nerdfonts.override { fonts = [ "FantasqueSansMono" ]; })

    # # You can also create simple shell scripts directly inside your
    # # configuration. For example, this adds a command 'my-hello' to your
    # # environment:
    # (pkgs.writeShellScriptBin "my-hello" ''
    #   echo "Hello, ${config.home.username}!"
    # '')
  ]) ++
  (with pkgs-unstable; [
    just
    nix-output-monitor
    nvd
  ]);

  # Let Home Manager install and manage itself.
  programs.home-manager.enable = true;
}
