{
  description = "Andrew's nix configuration flake";

  inputs = {
    nixpkgs.url = "github:nixos/nixpkgs?ref=nixos-24.05";
    nixpkgs-unstable.url = "github:nixos/nixpkgs?ref=nixos-unstable";

    nur.url = "github:nix-community/NUR";

    # Window Manager
    hyprland.url = "git+https://github.com/hyprwm/Hyprland?submodules=1";
    hyprland-plugins = {
      url = "github:hyprwm/hyprland-plugins";
      inputs.hyprland.follows = "hyprland";
    };

    # Tool to run unpatched binaries
    nix-alien.url = "github:thiagokokada/nix-alien";

    # Weekly Updated nix-index database
    nix-index-database = {
      url = "github:nix-community/nix-index-database";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    # Styling
    #stylix.url = "github:danth/stylix?ref=release-24.05";

    home-manager = {
      url = "github:nix-community/home-manager?ref=release-24.05";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    # Manage secrets with sops
    sops-nix = {
      url = "github:Mic92/sops-nix";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    # My package repo and neovim config
    nixpkgs-vndrew.url = "git+ssh://git@github.com/thevndrew/nix-packages.git";
    vndrew-nvim.url = "git+ssh://git@github.com/thevndrew/vndrew.nvim";

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

    neovim-nightly-overlay = {
      url = "github:nix-community/neovim-nightly-overlay";
      #inputs.nixpkgs.follows = "nixpkgs";
    };

    #my-neovim-nightly-overlay = {
    #  url = "github:thevndrew/nix-neovim-overlay";
    #};

    # Other packages
    zig.url = "github:mitchellh/zig-overlay";

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
  };

  outputs = {
    self,
    nixpkgs,
    nixpkgs-unstable,
    home-manager,
    ...
  } @ inputs: let
    system = "x86_64-linux";

    overlays = [
      #inputs.neovim-nightly-overlay.overlay
      inputs.nur.overlay
      inputs.zig.overlays.default
    ];

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

    mylib = import ./lib/mylib.nix {inherit (nixpkgs) lib;};

    mkSystem = import ./lib/mksystem.nix {
      inherit nixpkgs overlays inputs pkgs other-pkgs mylib;
    };

    homeManagerSetup = {
      hostname,
      user,
    }: (
      let
        systemInfo = {
          home = "/home/${user}";
          hostname = hostname;
          inherit user;
          arch = system;
        };

        moduleArgs = {
          isDesktop = false;
          isWSL = true;
          sopsKeys = mylib.getSopsKeys user;
          inherit inputs;
          inherit mylib;
          inherit other-pkgs;
          inherit systemInfo;
        };
      in
        home-manager.lib.homeManagerConfiguration {
          inherit pkgs;
          extraSpecialArgs = moduleArgs;
          modules = [
            inputs.nix-index-database.hmModules.nix-index
            inputs.sops-nix.homeManagerModules.sops
            ./users/${user}/home
          ];
        }
    );
  in {
    nixosConfigurations = {
      going-merry = mkSystem "going-merry" {
        inherit system;
        user = "andrew";
      };

      thousand-sunny = mkSystem "thousand-sunny" {
        inherit system;
        user = "andrew";
        desktop = true;
      };

      polar-tang = mkSystem "polar-tang" {
        inherit system;
        user = "andrew";
        wsl = true;
      };
    };

    formatter.${system} = nixpkgs.legacyPackages.${system}.alejandra;

    homeConfigurations = {
      andrew = homeManagerSetup {
        hostname = "polar-tang";
        user = "andrew";
      };
    };
  };
}
