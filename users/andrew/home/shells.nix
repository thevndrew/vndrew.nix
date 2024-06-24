{
  inputs,
  mylib,
  other-pkgs,
  systemInfo,
  ...
}: let
  unstable = other-pkgs.unstable;
in {
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
    EDITOR = "nvim";
    FLAKE = "${systemInfo.home}/nix-config";
    _ZO_ECHO = "1";
  };

  home.shellAliases = {
    "cat" = "bat";
    "c" = "clear";
    "ks" = "tmux kill-server";
    "nb" = "nix build --json --no-link --print-build-logs";
    "get_secrets" = "source $(which get_secrets_key)";
    "remove_secrets" = "source $(which remove_secrets_key)";
  };

  programs = {
    bash = {
      enable = true;
      enableCompletion = true;
      historyControl = ["ignoredups" "ignorespace"];
      historyFile = "${systemInfo.home}/.bash_eternal_history";
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
        # Bootdev completions
        source ${mylib.relativeToRoot "config/bash/bootdev.bash"}
      '';
    };

    zsh = {
      enable = true;
      enableAutosuggestions = true;
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
        # Bootdev completions
        source ${mylib.relativeToRoot "config/zsh/bootdev.zsh"}

        ${builtins.readFile (mylib.relativeToRoot "config/zsh/keybinds.zsh")}
        ${builtins.readFile (mylib.relativeToRoot "config/zsh/functions.zsh")}
        ${builtins.readFile (mylib.relativeToRoot "config/zsh/config.zsh")}
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
        enable = true;
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
  };
}
