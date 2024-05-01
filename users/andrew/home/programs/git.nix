{ systemInfo, other-pkgs, ... }:
{
  programs.git = {
    enable = true;
    userEmail = "69527486+thevndrew@users.noreply.github.com";
    userName = "andrew";
    aliases = {
      an = "commit --amend --no-edit";
      br = "branch";
      c  = "commit";
      co = "checkout";
      st = "status";
      wt = "worktree";
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
      user.signingkey = "${systemInfo.home}/.ssh/${systemInfo.hostname}.pub";
      user.gpgsign = true;
      commit.gpgsign = true;
    };
    ignores = [
      "*.swp"
    ];
  };

  programs.gh = {
    enable = true;
    package = other-pkgs.unstable.gh;
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
