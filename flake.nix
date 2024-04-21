{
  description = "Flake for going-merry";

  inputs = {
    nixpkgs.url = "github:nixos/nixpkgs?ref=nixos-23.11";
    nixpkgs-unstable.url = "github:nixos/nixpkgs?ref=nixos-unstable";
  };

  outputs = inputs @ { self, nixpkgs, nixpkgs-unstable }:
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

  in
  {
    nixosConfigurations = {
      going-merry = nixpkgs.lib.nixosSystem {
        specialArgs = { inherit system; inherit pkgs-unstable; inherit inputs; };
        modules = [
          ./nixos/going-merry/configuration.nix
        ];
      };

      thousand-sunny = nixpkgs.lib.nixosSystem {
        specialArgs = { inherit system; inherit pkgs-unstable; inherit inputs; };
        modules = [
          ./nixos/thousand-sunny/configuration.nix
        ];
      };
    };
  };
}
