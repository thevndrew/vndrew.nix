{
  description = "Flake for going-merry";

  inputs = {
    nixpkgs.url = "github:nixos/nixpkgs?ref=nixos-23.11";
    nixpkgs-unstable.url = "github:nixos/nixpkgs?ref=nixos-unstable";
  };

  outputs = { self, nixpkgs, nixpkgs-unstable }:
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
        specialArgs = { inherit system; inherit pkgs-unstable; };
        modules = [
          ./nixos/configuration.nix
        ];
      };
    };
  };
}
