{
  systemInfo,
  other-pkgs,
  ...
}: let
  unstable = other-pkgs.unstable;
in {
  programs.git = {
    enable = true;
    package = unstable.git;

    userEmail = "69527486+thevndrew@users.noreply.github.com";
    userName = "andrew";

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
        editor = "nvim";
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
        signingkey = "${systemInfo.home}/.ssh/${systemInfo.hostname}.pub";
      };
    };

    ignores = [
      "*.swp"
    ];

    lfs = {
      enable = true;
    };
  };

  programs.gh = {
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
}
