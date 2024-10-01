{pkgs, ...}: {
  environment = {
    enableAllTerminfo = true;

    # Add ~/.local/bin to PATH
    localBinInPath = true;

    pathsToLink = [
      "/share/bash-completion"
      "/share/zsh"
    ];

    shells = [pkgs.zsh];

    systemPackages = with pkgs; [
      mergerfs
      tmux
      neovim
      git
      ethtool
    ];
  };
}
