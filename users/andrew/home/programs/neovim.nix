{
  inputs,
  systemInfo,
  pkgs,
  ...
}: {
  programs.neovim =
    inputs.vndrew-nvim.lib.mkHomeManager {system = systemInfo.arch;}
    // {
      package = pkgs.neovim-unwrapped;
      viAlias = true;
      vimAlias = true;
      vimdiffAlias = true;
    };
}
