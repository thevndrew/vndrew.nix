{ ... }:
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
      user.signingkey = "~/.ssh/github.pub";
      user.gpgsign = true;
      commit.gpgsign = true;
    };
    ignores = [
      "*.swp"
    ];
  };
}
