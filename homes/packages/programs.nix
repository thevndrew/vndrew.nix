{
  lib,
  config,
  hostname,
  inputs,
  pkgs,
  username,
  users,
  ...
}: let
  inherit (pkgs) unstable;
in {
  programs = {
    atuin = {
      enable = true;
      enableBashIntegration = true;
      enableZshIntegration = true;
      package = unstable.atuin;
      settings = {
        auto_sync = true;
        dialect = "us";
        filter_mode = "global";
        key_path = config.sops.secrets.atuin_key.path;
        search_mode = "fuzzy";
        secrets_filter = true;
        show_help = true;
        show_preview = true;
        show_tabs = true;
        store_failed = true;
        sync_address = "http://going-merry.ainu-kanyu.ts.net:9085";
        #sync_address = "https://atuin.local.vndrew.com";
        sync_frequency = "15m";
        update_check = true;

        sync = {
          records = true;
        };
      };
    };

    bat = {
      enable = true;
      package = unstable.bat;
      extraPackages = with pkgs.stable.bat-extras; [
        batdiff
        batgrep
        batman
        batpipe
        batwatch
        prettybat
      ];
    };

    broot = {
      enable = true;
      enableBashIntegration = true;
      enableZshIntegration = true;
      package = unstable.broot;
      settings = {
        modal = true;
      };
    };

    direnv = {
      enable = true;
      enableBashIntegration = true;
      enableZshIntegration = true;
      package = unstable.direnv;
      nix-direnv.enable = true;
    };

    fzf = {
      enable = true;
      enableBashIntegration = true;
      enableZshIntegration = true;
      package = unstable.fzf;
    };

    git =
      users.git.${username}
      // {
        enable = true;
        package = unstable.git;

        userEmail = "69527486+thevndrew@users.noreply.github.com";

        aliases = {
          an = "commit --amend --no-edit";
          br = "branch";
          bump = "commit --amend --no-edit --date=now";
          c = "commit";
          co = "checkout";
          wt = "worktree";
          ragequit = "!sh -c 'git commit -am wip && shutdown -h now'";
          tree = "log --all --graph --decorate --oneline";
          fix = "!f() { $EDITOR -p `git diff --name-only --diff-filter=U`; }; f";
          stsh = "stash --keep-index";
          staash = "stash --include-untracked"; # include untracked
          staaash = "stash --all"; # include staged
          which = "!git branch | grep -i"; # quick grep to find by ticket number
          lucky = "!sh -c 'git checkout $(git which $1 -m1)' - "; # checkout by ticket number
          revrt = "!sh -c 'git clean -df && git checkout -- '"; # undoes all local uncommitted changes
          clean = "gc --aggressive --prune";
          purge = "remote prune origin"; # looks at any remote branches deleted and asks to delete the related locals

          # Report all aliases.
          alias = "config --get-regexp alias\\\\.";

          # List info about all branches
          branches = "!git branch -a -vv | cut -c -119";

          # Used for other aliases. Determine the name of the current branch
          branch-name = "!git rev-parse --abbrev-ref @";

          # Concise status comment
          st = "status --short --branch";

          # List all known tags
          tags = "tag --list --format '%(refname:short)  %(align:18)%(\*authorname)%(end)  %(subject)'";

          # Display current feature branch status and commits relative to the parent (default "master") branch
          changes = lib.concatStrings [
            "!git status && echo -- "
            "&& (git log -n 1 --format=format:'   @\~0  \[%h\] %s' @) "
            "&& (git log --format=format:'\[%h\] %s' \${1-main}..@\~1 | cat -n) "
            "&& echo "
            "&& echo>/dev/null"
          ];

          # Print files in the tree that are not under source control
          ignored = "clean -ndX";

          # Show local branches that have been merged into main
          merged = "!git branch --all --merged origin/main | cut -c3- | grep -v main";

          # Pretty log format
          plog = "log --decorate --oneline --graph";

          # Show the overall shape of the repo branches through simplified graph
          shape = "log --decorate --all --graph --simplify-by-decoration --topo-order --date=short --format='%h \[%cd\]%d %s'";

          # Show status log with changed-files summary
          slog = "log --name-status";

          lg = "log --color --graph --pretty=format:'%Cred%h%Creset -%C(yellow)%d%Creset %s %Cgreen(%cr) %C(bold blue)<%an>%Creset' --abbrev-commit";
          sl = "stash list --pretty=format:'%C(red)%h%C(reset) - %C(yellow)(%gd%C(yellow))%C(reset) %<(70,trunc)%s %C(green)(%cr) %C(bold blue)<%an>%C(reset)'";
          rl = "reflog --pretty=format:'%Cred%h%Creset %C(yellow)%gd%C(reset) %C(auto)%gs%C(reset) %C(green)(%cr)%C(reset) %C(bold blue)<%an>%Creset' --abbrev-commit";
          diff-all = "!\"for name in $(git diff --name-only $1); do git difftool -y $1 $name & done\"";
          diff-changes = "diff --name-status -r";
          diff-stat = "diff --stat --ignore-space-change -r";
          diff-staged = "diff --cached";
          diff-upstream = "!git fetch origin && git diff main origin/main";
          fixup = "!git log --oneline --decorate @{u}.. | fzf | awk '{ print $1 }' | xargs -I{} git commit --fixup={}";
          fixup2 = "!f() { git commit --fixup \":/$1\"; }; f";
          bsort = ''
            !git branch --sort=-committerdate --format="%(committerdate:format:%Y-%m-%d %H:%M) %(refname:short)" | awk "{printf \"\033[32m%s %s \033[33m%s\033[0m\n\", \$1, \$2, \$3}"
          '';

          # ask politely
          please = "push --force-with-lease";

          # useful when leaving or starting a refactoring or before popping a stash
          wip = "commit --no-verify --message 'wip'";

          # work on last commit
          append = "commit --amend --no-edit";
          amend = "commit --amend --edit";
          unamend = "reset --soft \"HEAD@{1}\"";
          uncommit = "!f() { git log --format=%B -n 1; git reset --soft HEAD~1 ; }; f";

          # interactive rebase
          ir = "rebase --interactive";
          ic = "rebase --continue";
          ia = "rebase --abort";

          # patching
          padd = "add -p";
          prestore = "restore -p";
          preset = "reset -p";
          puncommit = "reset -p HEAD~1";

          discard = "reset HEAD --hard";
          discardchunk = "checkout -p";
          ol = "log --all --graph --pretty=format:'%Cred%h%Creset -%C(yellow)%d%Creset %s %Cgreen(%cr) %C(bold blue)<%an>%Creset' --abbrev-commit";
          others = "ls-files --others --ignored --exclude-from=.gitignore";
          rmuntracked = "clean -df";
          root = "rev-parse --show-toplevel";
          searchfiles = "log --name-status --source --all -S";
          searchtext = "!f() { git grep \"$*\" $(git rev-list --all); }; f";
          unstage = "reset HEAD --";
        };

        delta = {
          enable = true;
          options = {
            line-numbers = true;
            side-by-side = true;
            navigate = true;
          };
        };

        extraConfig = {
          branch.sort = "-committerdate";
          commit.gpgsign = true;
          column.ui = "auto";

          core = {
            editor = "vim";
            fsmonitor = true;
          };

          diff = {
            colorMoved = "default";
          };

          fetch = {
            prune = true;
            writeCommitGraph = true;
          };

          gpg.format = "ssh";
          init.defaultBranch = "main";

          merge = {
            conflictstyle = "diff3";
          };

          pull.rebase = true;
          push = {
            default = "current";
            autoSetupRemote = true;
          };

          rebase.updateRefs = true;
          rerere.enabled = true;

          help.autocorrect = true;

          user = {
            gpgsign = true;
            signingkey = "/home/${username}/.ssh/${hostname}.pub";
          };
        };

        ignores = [
          "*.swp"
        ];

        lfs = {
          enable = true;
        };
      };

    gh = {
      enable = true;
      package = unstable.gh;
      settings = {
        git_protocol = "ssh";
        #pager = "";
        aliases = {
          co = "pr checkout";
          pv = "pr view";
        };
      };
    };

    lf = {
      enable = true;
      package = unstable.lf;
    };

    lsd = {
      enable = true;
    };

    #nix-index-database.comma.enable = true;

    nix-index = {
      enableBashIntegration = true;
      enableZshIntegration = true;
      enable = true;
      package = unstable.nix-index;
    };

    nnn = {
      enable = true;
      package = unstable.nnn.override {withNerdIcons = true;};
      plugins = {
        mappings = {
          f = "finder";
          z = "autojump";
        };
        src = "${inputs.nnn}/plugins";
      };
    };

    ripgrep = {
      enable = true;
      package = unstable.ripgrep;
    };

    scmpuff = {
      enable = true;
      enableBashIntegration = true;
      enableZshIntegration = true;
      package = unstable.scmpuff;
    };

    ssh = {
      enable = true;
      extraConfig = ''
        Host github.com
            HostName github.com
            PreferredAuthentications publickey
            IdentityFile ~/.ssh/${hostname}
        Host gitea.local.vndrew.com
            HostName gitea.local.vndrew.com
            PreferredAuthentications publickey
            IdentityFile ~/.ssh/${hostname}
      '';
    };

    starship = {
      enable = true;
      enableBashIntegration = true;
      enableZshIntegration = true;
      package = unstable.starship;
      settings = {
        #palette = "gruvbox_dark";

        palettes.gruvbox_dark = {
          fg = "#fbf1c7";
          bg = "#3c3836";
          bg3 = "#665c54";
          blue = "#458588";
          aqua = "#689d6a";
          green = "#98971a";
          orange = "#d65d0e";
          purple = "#b16286";
          red = "#cc241d";
          yellow = "#d79921";
        };

        aws.disabled = true;
        directory.truncate_to_repo = false;
        directory.truncation_length = 8;
        direnv.disabled = false;
        gcloud.disabled = true;
        git_branch.style = "242";
        kubernetes.disabled = false;
        ruby.disabled = true;

        hostname.ssh_only = false;
      };
    };

    thefuck = {
      enable = true;
      enableBashIntegration = true;
      enableZshIntegration = true;
      package = unstable.thefuck;
    };

    yazi = {
      enableBashIntegration = true;
      enableZshIntegration = true;
      enable = true;
      package = unstable.yazi;
    };

    zellij = {
      enable = true;
      package = unstable.zellij;
      settings = {
        #theme = "gruvbox-dark";
        #theme = "custom"
        #themes.custom.fg = "#ffffff";
      };
    };

    zoxide = {
      enable = true;
      enableBashIntegration = true;
      enableZshIntegration = true;
      package = unstable.zoxide;
      options = ["--cmd cd"];
    };
  };
}
