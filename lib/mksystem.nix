# This function creates a NixOS system based on our VM setup for a
# particular architecture.
{ nixpkgs, nixpkgs-unstable, overlays, inputs }:

name:
{
  system,
  user,
  wsl ? false,
  desktop ? false
}:

let
  # True if this is a WSL system.
  isWSL = wsl;

  # The config files for this system.
  machineConfig = ../hosts/${name}/configuration.nix;
  userOSConfig = ../users/${user}/nixos${if desktop then "-desktop" else ""}.nix;
  userHMConfig = ../users/${user}/home/home-manager.nix;

  systemFunc = nixpkgs.lib.nixosSystem;
  home-manager = inputs.home-manager.nixosModules;
  sops-nix = inputs.sops-nix.nixosModules;

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

  mylib = import ./mylib.nix { inherit (nixpkgs) lib; };

  moduleArgs = {
     currentSystemUser = user;
     inherit inputs;
     inherit mylib;
     inherit pkgs-unstable;
     inherit system;
  };

in systemFunc rec {
  inherit system;

  specialArgs = moduleArgs;

  modules = [
    # Apply our overlays. Overlays are keyed by system type so we have
    # to go through and apply our system type. We do this first so
    # the overlays are available globally.
    { nixpkgs.overlays = overlays; }

    # Bring in WSL if this is a WSL build
    (if isWSL then inputs.nixos-wsl.nixosModules.wsl else {})

    sops-nix.sops
    machineConfig
    userOSConfig
    home-manager.home-manager {
      home-manager.useGlobalPkgs = true;
      home-manager.useUserPackages = true;
      home-manager.extraSpecialArgs = moduleArgs;
      home-manager.users.${user} = import userHMConfig {
        isDesktop = desktop;
        isWSL = isWSL;
      };
    }

    # We expose some extra arguments so that our modules can parameterize
    # better based on these values.
    {
      config._module.args = {
        currentSystemName = name;
        currentSystem = system;
        currentSystemUser = user;
        inputs = inputs;
        isDesktop = desktop;
        isWSL = isWSL;
      };
    }
  ];
}

