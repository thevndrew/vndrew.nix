{
  description = ''
    Andrew's system. common/default.nix handles passing modules
    and config files to home and the system.

    flake.nix contains only inputs,
    the outputs function are in ./default.nix

    Shoutout to BirdeeHub, my config was heavly based on
    their config at https://github.com/BirdeeHub/birdeeSystems/
  '';

  # TODO: setup personal binary cache
  # nixConfig = {
  #   extra-substituters = [
  #   ];
  #   extra-trusted-public-keys = [
  #   ];
  # };

  inputs = {
    nixpkgs.url = "github:nixos/nixpkgs?ref=nixos-25.05";
    nixpkgs-stable.url = "github:nixos/nixpkgs?ref=nixos-25.05";
    nixpkgs-unstable.url = "github:nixos/nixpkgs?ref=nixos-unstable";
    nur.url = "github:nix-community/NUR";

    home-manager = {
      url = "github:nix-community/home-manager?ref=release-25.05";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    home-manager-unstable = {
      url = "github:nix-community/home-manager";
      inputs.nixpkgs.follows = "nixpkgs-unstable";
    };

    # Build a custom WSL installer
    nixos-wsl = {
      url = "github:nix-community/NixOS-WSL";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    alacritty-theme.url = "github:alexghr/alacritty-theme.nix";
    devenv.url = "github:cachix/devenv";
    disko = {
      url = "github:nix-community/disko";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    flake-parts.url = "github:hercules-ci/flake-parts";
    flake-utils.url = "github:numtide/flake-utils";
    manix = {
      url = "github:nix-community/manix";
      inputs = {
        flake-utils.follows = "flake-utils";
        nixpkgs.follows = "nixpkgs";
      };
    };
    minesweeper = {
      url = "github:BirdeeHub/minesweeper";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    nix-appimage.url = "github:ralismark/nix-appimage";
    nixos-hardware.url = "github:NixOS/nixos-hardware";
    nixToLua.url = "github:BirdeeHub/nixtoLua";
    nsearch = {
      url = "github:niksingh710/nsearch";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    templ.url = "github:a-h/templ";
    zig.url = "github:mitchellh/zig-overlay";

    # Window Manager/Desktop Environment stuff
    ags.url = "github:Aylur/ags";
    anyrun = {
      url = "github:anyrun-org/anyrun";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    hyprland.url = "git+https://github.com/hyprwm/Hyprland?submodules=1";
    hyprland-plugins = {
      url = "github:hyprwm/hyprland-plugins";
      inputs.hyprland.follows = "hyprland";
    };
    wezterm.url = "github:wez/wezterm?dir=nix";
    ghostty.url = "github:ghostty-org/ghostty";
    zen-browser.url = "github:MarceColl/zen-browser-flake";

    # Tool to run unpatched binaries
    nix-alien.url = "github:thiagokokada/nix-alien";

    # Weekly Updated nix-index database
    nix-index-database = {
      url = "github:nix-community/nix-index-database";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    # Non-flake inputs
    nnn = {
      url = "github:jarun/nnn";
      flake = false;
    };
    zsh-completions = {
      url = "github:zsh-users/zsh-completions";
      flake = false;
    };
    fzf-tab = {
      url = "github:Aloxaf/fzf-tab";
      flake = false;
    };

    # My private package repo and neovim config
    nixpkgs-private = {
      url = "git+ssh://git@github.com/thevndrew/private-pkgs.nix.git";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    vndrew-nvim = {
      url = "git+ssh://git@github.com/thevndrew/vndrew.nvim";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    # sops and sops encrypted secrets
    sops-nix = {
      url = "github:Mic92/sops-nix";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    # Use ssh protocol to authenticate via ssh-agent/ssh-key, and shallow clone
    mysecrets = {
      url = "git+ssh://git@github.com/thevndrew/secrets.nix.git?shallow=1";
      flake = false;
    };

    bootdev = {
      url = "github:bootdotdev/bootdev";
      flake = false;
    };

    yt-dlp-youtube-oauth2 = {
      url = "github:coletdjnz/yt-dlp-youtube-oauth2";
      flake = false;
    };

    yt-dlp-get-pot = {
      url = "github:coletdjnz/yt-dlp-get-pot";
      flake = false;
    };

    tailscale = {
      flake = false;
      url = "github:tailscale/tailscale";
    };
  };

  outputs = inputs: import ./. inputs;
}
