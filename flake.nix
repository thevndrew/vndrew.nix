{
  description = "Flake for going-merry";

  inputs = {
    nixpkgs.url = "github:nixos/nixpkgs?ref=nixos-23.11";
    nixpkgs-unstable.url = "github:nixos/nixpkgs?ref=nixos-unstable";

    home-manager = {
      url = "github:nix-community/home-manager";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    # Build a custom WSL installer
    nixos-wsl.url = "github:nix-community/NixOS-WSL";
    nixos-wsl.inputs.nixpkgs.follows = "nixpkgs";

    # I think technically you're not supposed to override the nixpkgs
    # used by neovim but recently I had failures if I didn't pin to my
    # own. We can always try to remove that anytime.
    neovim-nightly-overlay = {
      url = "github:nix-community/neovim-nightly-overlay";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    # Other packages
    zig.url = "github:mitchellh/zig-overlay";

  };

  outputs = { self, nixpkgs, nixpkgs-unstable, home-manager, ... }@inputs:
  let
    system = "x86_64-linux";

    pkgs = import nixpkgs {
      inherit system;
      
      config = {
        allowUnfree = true;
      };
    };

    pkgs-unstable = import nixpkgs-unstable {
      inherit system;
      
      config = {
        allowUnfree = true;
      };
    };

    overlays = [
      #inputs.neovim-nightly-overlay.overlay
      inputs.zig.overlays.default
    ];

    mkSystem = import ./lib/mksystem.nix {
      inherit overlays nixpkgs nixpkgs-unstable inputs;
    };

  in
  {
    nixosConfigurations = {
      going-merry = nixpkgs.lib.nixosSystem {
        specialArgs = { inherit system; inherit pkgs-unstable; inherit inputs; };
        modules = [
          ./hosts/going-merry/configuration.nix
        ];
      };

      going-merry-hm = mkSystem "going-merry" rec {
        system = "x86_64-linux";
        user = "andrew";
      };

      thousand-sunny = nixpkgs.lib.nixosSystem {
        specialArgs = { inherit system; inherit pkgs-unstable; inherit inputs; };
        modules = [
          ./hosts/thousand-sunny/configuration.nix
        ];
      };
    };
  };
}

