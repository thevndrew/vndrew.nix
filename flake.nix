{
  description = "Flake for going-merry";

  inputs = {
    nixpkgs.url = "github:nixos/nixpkgs?ref=nixos-23.11";
    nixpkgs-unstable.url = "github:nixos/nixpkgs?ref=nixos-unstable";
    nixpkgs-vndrew.url = "git+ssh://git@github.com/thevndrew/nix-packages.git";
    vndrew-nvim.url = "git+ssh://git@github.com/thevndrew/vndrew.nvim";

    # Weekly Updated nix-index database
    nix-index-database = {
      url = "github:nix-community/nix-index-database";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    home-manager = {
      url = "github:nix-community/home-manager";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    # Manage secrets with sops
    sops-nix = {
      url = "github:Mic92/sops-nix";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    # Use ssh protocol to authenticate via ssh-agent/ssh-key, and shallow clone
    mysecrets = { 
      url = "git+ssh://git@github.com/thevndrew/nix-secrets.git?shallow=1";
      flake = false;
    };

    # Build a custom WSL installer
    nixos-wsl = {
      url = "github:nix-community/NixOS-WSL";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    # I think technically you're not supposed to override the nixpkgs
    # used by neovim but recently I had failures if I didn't pin to my
    # own. We can always try to remove that anytime.
    neovim-nightly-overlay = {
      url = "github:nix-community/neovim-nightly-overlay";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    # Other packages
    zig.url = "github:mitchellh/zig-overlay";

    nnn = {
      url = "github:jarun/nnn";
      flake = false;
    };
  };

  outputs = { self, nixpkgs, nixpkgs-unstable, home-manager, ... }@inputs:
  let
    system = "x86_64-linux";

    overlays = [
      #inputs.neovim-nightly-overlay.overlay
      inputs.zig.overlays.default
    ];

    mkSystem = import ./lib/mksystem.nix {
      inherit nixpkgs overlays inputs;
    };

    homeManagerSetup = { hostname, user }: (
      let
        specialArgs = inputs // {
          inherit hostname user;
          impurePaths = {
            workingDir = "/home/${user}/.config/nix";
          };
        };
      in
      home-manager.lib.homeManagerConfiguration {
        pkgs = import nixpkgs { inherit system; };
        modules = [
	  inputs.sops-nix.homeManagerModules.sops
	  ./users/${user}/home-manager.nix
	];
        extraSpecialArgs = specialArgs;
      }
    );

  in
  {
    nixosConfigurations = {

      going-merry = mkSystem "going-merry" rec {
	inherit system;
        user = "andrew";
      };

      thousand-sunny = mkSystem "thousand-sunny" rec {
	inherit system;
        user = "andrew";
      };

    };

    homeConfigurations = {
      ubuntu = homeManagerSetup {
        hostname = "ubuntu-host";
        user = "andrew";
      };
    };
  };
}

