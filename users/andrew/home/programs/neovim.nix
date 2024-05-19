{
  inputs,
  systemInfo,
  pkgs,
  other-pkgs,
  ...
}: {
  programs.neovim =
    inputs.vndrew-nvim.lib.mkHomeManager {system = systemInfo.arch;}
    // {
      package = other-pkgs.unstable.neovim-unwrapped;
      #package = pkgs.neovim-nightly;
      viAlias = true;
      vimAlias = true;
      vimdiffAlias = true;
    };
}
