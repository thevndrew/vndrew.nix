{ inputs, systemInfo, pkgs, ... }:
{
  programs.neovim = inputs.vndrew-nvim.lib.mkHomeManager { system = systemInfo.arch; } 
    // 
    {
      viAlias = true;
      vimAlias = true;
      vimdiffAlias = true;
    };
}
