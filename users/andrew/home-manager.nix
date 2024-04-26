{ isWSL, inputs, currentSystemUser, ...}:

{ config, pkgs, pkgs-unstable, ... }:
let
  configTheme = ../../config/zsh/p10k.zsh;
  configThemeLean = ../../config/zsh/p10k_lean.zsh;
in
{
  # Home Manager needs a bit of information about you and the paths it should
  # manage.
  home.username = "${currentSystemUser}";
  home.homeDirectory = "/home/${currentSystemUser}";

  # This value determines the Home Manager release that your configuration is
  # compatible with. This helps avoid breakage when a new Home Manager release
  # introduces backwards incompatible changes.
  #
  # You should not change this value, even if you update Home Manager. If you do
  # want to update the value, then make sure to first check the Home Manager
  # release notes.
  home.stateVersion = "23.11"; # Please read the comment before changing.

  programs.bash = {
    enable = true;
    enableCompletion = true;
    historyControl = [ "ignoredups" "ignorespace" ];
    historyFile = "/home/${currentSystemUser}/.bash_eternal_history";
    historyFileSize = -1;
    historySize = -1;
    bashrcExtra = ''
      # No Extras for now
    '';
    shellOptions = [
      #"checkjobs"
      #"checkwinsize"
      #"histappend"
      "dotglob"
      "extglob"
      "globstar"
    ];
    sessionVariables = {
      #HISTSIZE = "";
      #HISTFILESIZE = "";
      #HISTCONTROL = "ignoreboth";
      #HISTFILE = "/home/${currentSystemUser}/.bash_eternal_history";
      EDITOR = "nvim";
      HISTTIMEFORMAT = "[%F %T] ";
      PROMPT_COMMAND = "history -a; $PROMPT_COMMAND";
    };
    initExtra = ''
      # Nothing here for now...
    '';
  };

  programs.zsh = {
    enable = true;
    enableAutosuggestions = true;
    enableCompletion = true;
    dotDir = ".config/zsh";
    history = {
      extended = true;
      ignoreDups = true;
      ignoreSpace = true;
      save = 1000000000;
      size = 1000000000;
      #path = "$HOME/.config/zsh/.zsh_history";
      path = "$ZDOTDIR/.zsh_history";
    };
    initExtra = ''
      ##{builtins.readFile ../config/zsh/functions.zsh}

      [[ ! -f ${configTheme} ]] || source ${configTheme}

      # Unload p10k and use starship
      function basic() {
        powerlevel10k_plugin_unload
        eval "$(starship init zsh)"
      }

      # Use p10k lean theme
      function lean() {
        [[ ! -f ${configThemeLean} ]] || source ${configThemeLean}
      }
      bindkey "\e[1~" beginning-of-line
      bindkey "\e[4~" end-of-line
      bindkey "^[[3~" delete-char
      bindkey -e
    '';
    historySubstringSearch = {
      enable = true;
      searchDownKey = [
        "^[[B"
      ];
      searchUpKey = [
        "^[[A"
      ];
    };
    #initExtraBeforeCompInit
    #initExtraFirst
    #localVariables
    plugins = [
      {
        name = "powerlevel10k";
        src = pkgs.zsh-powerlevel10k;
        file = "share/zsh-powerlevel10k/powerlevel10k.zsh-theme";
      }
    ];
    shellAliases = {
      "reload_p10k"="[[ ! -f ${configTheme} ]] || source ~/.config/zsh/.zshrc";
      "c" = "clear";
      "ks" = "tmux kill-server";
    };
  };

  programs.starship = {
    enable = true;
    enableBashIntegration = true;
    enableZshIntegration = true;
  };

  programs.ssh = {
    enable = true;
    extraConfig = ''
      ${builtins.readFile ../../config/ssh/config}
    '';
  };

  programs.git = {
    enable = true;
    userEmail = "69527486+thevndrew@users.noreply.github.com";
    userName = "andrew";
    aliases = {
      br = "branch";
      co = "checkout";
      st = "status";
      wt = "worktree";
      an = "commit --amend --no-edit";
    };
    lfs = {
      enable = true;
    };
    delta.enable = true;
    extraConfig = {
      branch.sort = "-committerdate";
      column.ui = "auto";
      core = {
        editor = "nvim";
        fsmonitor = true;
      };
      fetch = {
        prune = true;
        writeCommitGraph = true;
      };
      gpg.format = "ssh";
      init.defaultBranch = "main";
      pull.rebase = true;
      rebase.updateRefs = true;
      rerere.enabled = true;
      user.signingkey = "~/.ssh/github.pub";
      user.gpgsign = true;
      commit.gpgsign = true;
    };
  };

  home.packages = with pkgs; [
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
    vim
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
  ];

  xdg = {
    enable = true;
    configFile = {
      # Nothing here for now...
    };
  };

  # Home Manager is pretty good at managing dotfiles. The primary way to manage
  # plain files is through 'home.file'.
  home.file = {
    # # Building this configuration will create a copy of 'dotfiles/screenrc' in
    # # the Nix store. Activating the configuration will then make '~/.screenrc' a
    # # symlink to the Nix store copy.
    # ".screenrc".source = dotfiles/screenrc;

    # # You can also set the file content immediately.
    # ".gradle/gradle.properties".text = ''
    #   org.gradle.console=verbose
    #   org.gradle.daemon.idletimeout=3600000
    # '';
  };

  # Home Manager can also manage your environment variables through
  # 'home.sessionVariables'. If you don't want to manage your shell through Home
  # Manager then you have to manually source 'hm-session-vars.sh' located at
  # either
  #
  #  ~/.nix-profile/etc/profile.d/hm-session-vars.sh
  #
  # or
  #
  #  ~/.local/state/nix/profiles/profile/etc/profile.d/hm-session-vars.sh
  #
  # or
  #
  #  /etc/profiles/per-user/andrew/etc/profile.d/hm-session-vars.sh
  #
  home.sessionVariables = {
    # EDITOR = "emacs";
  };

  # Let Home Manager install and manage itself.
  programs.home-manager.enable = true;
}
