{ mylib, lib, config, inputs, pkgs, other-pkgs, systemInfo, isDesktop, ... }:
{
  imports = [
    ./files.nix
    ./secrets.nix 
    # ./systemd/clone_repos.nix
  ] ++
  (mylib.scanPaths ./programs) ++
  (mylib.scanPaths ./gui_module)
  ;

  #gui.enable = isDesktop;

  # Home Manager needs a bit of information about you and the paths it should
  # manage.
  home.username = "${systemInfo.user}";
  home.homeDirectory = "${systemInfo.home}";

  # This value determines the Home Manager release that your configuration is
  # compatible with. This helps avoid breakage when a new Home Manager release
  # introduces backwards incompatible changes.
  #
  # You should not change this value, even if you update Home Manager. If you do
  # want to update the value, then make sure to first check the Home Manager
  # release notes.
  home.stateVersion = "23.11"; # Please read the comment before changing.

  # Let Home Manager install and manage itself.
  programs.home-manager.enable = true;
}
