{ inputs, other-pkgs, ... }:
let
  unstable = other-pkgs.unstable;
in
{
  programs.nnn = {
    enable = true;
    package = unstable.nnn.override ({ withNerdIcons = true; });
    plugins = {
      mappings = {
        f = "finder";
	z = "autojump";
      };
      src = "${inputs.nnn}/plugins";
    };
  };
}
