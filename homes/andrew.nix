{
  config,
  pkgs,
  lib,
  self,
  inputs,
  flake-path,
  users,
  username,
  stateVersion,
  home-modules,
  hostname,
  my-utils,
  ...
} @ args: let
  inherit (pkgs) unstable;

  zsh_config = my-utils.writeLines {lines = my-utils.readFiles ./zsh;};
  bash_config = my-utils.writeLines {lines = my-utils.readFiles ./bash;};

  config-path = ./hosts/${hostname}/default.nix;

  host-config =
    if lib.pathExists config-path
    then [config-path]
    else [];
in {
  imports = with home-modules;
    host-config
    ++ [
      # alacritty
      # tmux
      # shell.bash
      # shell.zsh
      # shell.fish
      # firefox
      vndrew-nvim
      # ranger
      # thunar
      gui-home
      terminals
      ./packages
    ];

  nvim = {
    enable = true;
    packageNames = ["nvim-nightly"];
  };

  vndrewMods = {
    # zsh.enable = true;
    # bash.enable = true;
    # alacritty.enable = true;
    # tmux.enable = true;
    # firefox.enable = true;
    # thunar.enable = true;
  };

  nix.registry = {
    # nixpkgs.flake = inputs.nixpkgs;
    home-manager.flake = inputs.home-manager;
    gomod2nix.to = {
      type = "github";
      owner = "nix-community";
      repo = "gomod2nix";
    };
  };

  xdg = {
    enable = true;
    userDirs = {
      enable = true;
      desktop = "${config.home.homeDirectory}/desktop";
      documents = "${config.home.homeDirectory}/documents";
      download = "${config.home.homeDirectory}/downloads";
      music = "${config.home.homeDirectory}/music";
      pictures = "${config.home.homeDirectory}/pictures";
      publicShare = "${config.home.homeDirectory}/public";
      templates = "${config.home.homeDirectory}/templates";
      videos = "${config.home.homeDirectory}/videos";
      extraConfig = {
        XDG_MISC_DIR = "${config.home.homeDirectory}/misc";
      };
    };
    configFile = {
      # Nothing here for now...
    };
    mimeApps.defaultApplications = {
      "application/pdf" = ["firefox.desktop" "draw.desktop" "gimp.desktop"];
    };
  };

  # This value determines the Home Manager release that your configuration is
  # compatible with. This helps avoid breakage when a new Home Manager release
  # introduces backwards incompatible changes.
  #
  # You should not change this value, even if you update Home Manager. If you do
  # want to update the value, then make sure to first check the Home Manager
  # release notes.
  home.stateVersion = stateVersion; # Please read the comment before changing.

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

  # Home Manager needs a bit of information about you and the paths it should
  # manage.
  home.username = username;
  home.homeDirectory = lib.mkDefault users.homeManager.${username}.homeDirectory;

  # Let Home Manager install and manage itself.
  programs.home-manager.enable = true;

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
    EDITOR = "vim";
    FLAKE = "/home/${username}/nix-config";
    _ZO_ECHO = "1";
    NIXOS_OZONE_WL = "1"; # This variable fixes electron apps in wayland
    # WLR_NO_HARDWARE_CURSORS = "1"; # if cursor becomes invisible
    XDG_DATA_DIRS = "$XDG_DATA_DIRS:/usr/share:/var/lib/flatpak/exports/share:$HOME/.local/share/flatpak/exports/share";
    # JAVA_HOME = "${pkgs.jdk}";
  };

  home.shellAliases = {
    zj = "zellij";
    cat = "bat --paging never --theme DarkNeon --style plain";
    c = "clear";
    fzfp = "alias fzfp='fzf --preview \"bat --style numbers --color always {}\"'";
    gc = "nix-collect-garbage --delete-old";
    ks = "tmux kill-server";
    nb = "nix build --json --no-link --print-build-logs";
    top_used = "fc -ln 0 | sort | uniq -c | sort -nr | head -20";
    dugood = ''${unstable.writeShellScript "dugood" ''du -hd1 $@ | sort -hr''}'';
    get_secrets = "source ${pkgs.sops_secrets_key}/bin/get_sops_key";
    remove_secrets = "source ${pkgs.sops_secrets_key}/bin/remove_sops_key";

    flakeUpAndAddem = ''${pkgs.writeShellScript "flakeUpAndAddem.sh"
        /*
        bash
        */
        ''
          target=""; [[ $# > 0 ]] && target=".#$1" && shift 1;
          git add . && nix flake update && nom build --show-trace $target && git add .; $@
        ''}'';
    autorepl = ''${pkgs.writeShellScript "autorepl" ''
        exec nix repl --show-trace --expr '{ pkgs = import ${inputs.nixpkgs.outPath} { system = "${pkgs.system}"; config.allowUnfree = true; }; }'
      ''}'';
    yolo = ''git add . && git commit -m "$(curl -fsSL https://whatthecommit.com/index.txt)" -m '(auto-msg whatthecommit.com)' -m "$(git status)" && git push'';
    scratch = ''export OGDIR="$(realpath .)" && export SCRATCHDIR="$(mktemp -d)" && cd "$SCRATCHDIR"'';
    exitscratch = ''cd "$OGDIR" && rm -rf "$SCRATCHDIR"'';
    lsnc = "lsd --color=never";
    la = "lsd -a";
    ll = "lsd -lh";
    l = "lsd -alh";
    yeet = "rm -rf";
    run = "nohup xdg-open";

    me-build-system = ''${pkgs.writeShellScript "me-build-system" ''
        export FLAKE="${flake-path}";
        exec ${self}/scripts/system "$@"
      ''}'';
    me-build-home = ''${pkgs.writeShellScript "me-build-home" ''
        export FLAKE="${flake-path}";
        exec ${self}/scripts/home "$@"
      ''}'';
    me-build-both = ''${pkgs.writeShellScript "me-build-both" ''
        export FLAKE="${flake-path}";
        exec ${self}/scripts/both "$@"
      ''}'';
  };

  programs = {
    bash = {
      enable = true;
      enableCompletion = true;
      historyControl = ["ignoredups" "ignorespace"];
      historyFile = "/home/${username}/.bash_eternal_history";
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
        HISTTIMEFORMAT = "[%F %T] ";
        PROMPT_COMMAND = "history -a; $PROMPT_COMMAND";
      };
      initExtra = ''
        ${bash_config}
      '';
    };

    zsh = {
      enable = true;
      autosuggestion.enable = true;
      enableCompletion = true;
      syntaxHighlighting.enable = true;
      defaultKeymap = "emacs";
      dotDir = ".config/zsh";

      history = {
        extended = true;
        ignoreDups = true;
        ignoreSpace = true;
        save = 1000000000;
        size = 1000000000;
        path = "$ZDOTDIR/.zsh_history";
      };

      initExtra = ''
        #$${zsh_defs}
        ${zsh_config}
      '';

      historySubstringSearch = {
        enable = true;
        searchDownKey = [
          "^[[B"
          "^[OB"
        ];
        searchUpKey = [
          "^[[A"
          "^[OA"
        ];
      };

      oh-my-zsh = {
        enable = false;
        plugins = [
          "command-not-found"
          "git"
          "kubectl"
          "kubectx"
          "sudo"
        ];
        theme = "robbyrussell";
      };

      #initExtraBeforeCompInit
      #initExtraFirst
      #localVariables
      plugins = [
        #{
        #  name = "powerlevel10k";
        #  src = pkgs.zsh-powerlevel10k;
        #  file = "share/zsh-powerlevel10k/powerlevel10k.zsh-theme";
        #}
        {
          name = "zsh-completions";
          src = inputs.zsh-completions;
        }
        {
          name = "fzf-tab";
          src = inputs.fzf-tab;
        }
      ];
    };

    nushell = {
      enable = true;
      package = unstable.nushell;
    };
  };

  sops = {
    age.sshKeyPaths = ["/home/${username}/.ssh/${hostname}"];
    defaultSopsFile = "${inputs.mysecrets}/secrets/services.yaml";

    secrets = {
      "services/env" = {
        sopsFile = "${inputs.mysecrets}/secrets/services.yaml";
        path = "/home/${username}/.config/services/services.env";
      };

      "atuin_key" = {
        sopsFile = "${inputs.mysecrets}/secrets/atuin.yaml";
      };
    };
  };
}
