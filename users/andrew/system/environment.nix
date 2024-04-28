{ pkgs, ... }:
{
  environment = {
    # Add ~/.local/bin to PATH
    localBinInPath = true;

    pathsToLink = [ 
      "/share/bash-completion"
      "/share/zsh"
    ];
 
    shells = [ pkgs.zsh pkgs.nushell ];
    systemPackages = with pkgs; [
      mergerfs
      tmux
      neovim
      git
      ethtool
    ];
  };
}
