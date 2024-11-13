{
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
      extraPackages = with unstable.bat-extras; [
        #batdiff
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
          st = "status";
          wt = "worktree";
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

    nix-index-database.comma.enable = true;

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
