{ mylib, systemInfo, ... }:
{
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
    "vim" = "nvim";
    "get_secrets" = "source $(which get_secrets_key)";
    "remove_secrets" = "source $(which remove_secrets_key)";
  };

  programs = {

    bash = {
      enable = true;
      enableCompletion = true;
      historyControl = [ "ignoredups" "ignorespace" ];
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
        # Nothing here for now...
      '';
    };
  
    zsh = {
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
        #''${builtins.readFile (mylib.relativeToRoot "config/zsh/load_p10k.zsh")}
        ${builtins.readFile (mylib.relativeToRoot "config/zsh/keybinds.zsh")}
        ${builtins.readFile (mylib.relativeToRoot "config/zsh/functions.zsh")}
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
        plugins = [ "git" ];
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
      ];
    };
  };
}
