# Due to the use of nix variables this will need
# to be copied to the zsh shellInit attr to work

[[ ! -f ${configTheme} ]] || source ${configTheme}

# Use p10k lean theme
function lean() {
  [[ ! -f ${configThemeLean} ]] || source ${configThemeLean}
}

# Unload p10k and use starship
function basic() {
  powerlevel10k_plugin_unload
  eval "$(starship init zsh)"
}

alias reload_p10k="[[ ! -f ${configTheme} ]] || source ~/.config/zsh/.zshrc";
