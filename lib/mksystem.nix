{ nixpkgs, overlays, inputs, ... }:

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

  other-pkgs = {
    unstable = import inputs.nixpkgs-unstable {
      inherit system;
      config = {
        allowUnfree = true;
      };
    };
    vndrew = inputs.nixpkgs-vndrew.packages.${pkgs.system};
  };

  mylib = import ./mylib.nix { inherit (nixpkgs) lib; };

  systemInfo = {
    home = "/home/${user}";
    hostname = name;
    user = user;
    arch = system;
  };

  moduleArgs = {
     sopsKey = "/home/${user}/.ssh/${name}";
     inherit inputs;
     inherit mylib;
     inherit other-pkgs;
     inherit systemInfo;
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
      home-manager.sharedModules = [
        inputs.sops-nix.homeManagerModules.sops
      ];
      home-manager.users.${user} = import userHMConfig {
        isDesktop = desktop;
        isWSL = isWSL;
      };
    }

    # We expose some extra arguments so that our modules can parameterize
    # better based on these values.
    {
      config._module.args = {
        inputs = inputs;
        isDesktop = desktop;
        isWSL = isWSL;
	systemInfo = systemInfo;
      };
    }
  ];
}

