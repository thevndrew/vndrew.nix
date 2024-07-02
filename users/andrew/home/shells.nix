{
  inputs,
  isWSL,
  lib,
  mylib,
  systemInfo,
  ...
}: let
  #zsh_defs = mylib.writeLines {lines = mylib.sourceFiles (mylib.relativeToRoot "config/zsh/source");};
  zsh_config = mylib.writeLines {lines = mylib.readFiles (mylib.relativeToRoot "config/zsh");};
  bash_config = mylib.writeLines {lines = mylib.readFiles (mylib.relativeToRoot "config/bash");};
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

  home.shellAliases =
    {
      cat = "bat";
      c = "clear";
      gc = "nix-collect-garbage --delete-old";
      ks = "tmux kill-server";
      nb = "nix build --json --no-link --print-build-logs";
    }
    // lib.optionalAttrs isWSL {
      pbcopy = "/mnt/c/Windows/System32/clip.exe";
      pbpaste = "/mnt/c/Windows/System32/WindowsPowerShell/v1.0/powershell.exe -command 'Get-Clipboard'";
      explorer = "/mnt/c/Windows/explorer.exe";
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
        ${bash_config}
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
