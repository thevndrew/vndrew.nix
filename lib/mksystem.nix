{
  nixpkgs,
  overlays,
  inputs,
  ...
}: name: {
  system,
  user,
  wsl ? false,
  desktop ? false,
}: let
  # True if this is a WSL system.
  isWSL = wsl;

  # The config files for this system.
  machineConfig = ../hosts/${name}/configuration.nix;
  userOSConfig = ../users/${user}/system/default.nix;
  userHMConfig = ../users/${user}/home;

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
    nix-alien = inputs.nix-alien.packages.${pkgs.system};
    unstable = import inputs.nixpkgs-unstable {
      inherit system;
      config = {
        allowUnfree = true;
      };
    };
    vndrew = inputs.nixpkgs-vndrew.packages.${pkgs.system};
  };

  mylib = import ./mylib.nix {inherit (nixpkgs) lib;};

  systemInfo = {
    home = "/home/${user}";
    hostname = name;
    user = user;
    arch = system;
  };

  moduleArgs = {
    sopsKeys = builtins.map (name: "/home/${user}/.ssh/${name}") ["going-merry" "thousand-sunny" "polar-tang"];
    isDesktop = desktop;
    isWSL = isWSL;
    inherit inputs;
    inherit mylib;
    inherit other-pkgs;
    inherit systemInfo;
  };
in
  systemFunc {
    inherit system;

    specialArgs = moduleArgs;

    modules = [
      # Apply our overlays. Overlays are keyed by system type so we have
      # to go through and apply our system type. We do this first so
      # the overlays are available globally.
      {nixpkgs.overlays = overlays;}

      # Bring in WSL if this is a WSL build
      (
        if isWSL
        then inputs.nixos-wsl.nixosModules.default
        else {}
      )

      #stylix.stylix
      sops-nix.sops
      machineConfig
      userOSConfig
      home-manager.home-manager
      {
        home-manager.useGlobalPkgs = true;
        home-manager.useUserPackages = true;
        home-manager.extraSpecialArgs = moduleArgs;
        home-manager.sharedModules = [
          inputs.sops-nix.homeManagerModules.sops
          inputs.nix-index-database.hmModules.nix-index
        ];
        home-manager.users.${user} = import userHMConfig;
      }
    ];
  }
