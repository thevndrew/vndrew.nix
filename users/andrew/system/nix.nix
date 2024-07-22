{inputs, ...}: {
  nix = {
    registry = {
      nixpkgs = {
        flake = inputs.nixpkgs;
      };
    };

    nixPath = [
      "nixpkgs=${inputs.nixpkgs.outPath}"
    ];

    optimise = {
      automatic = true;
      dates = ["daily"];
    };

    settings = {
      accept-flake-config = true;
      auto-optimise-store = true;
      builders-use-substitutes = true;

      experimental-features = ["nix-command" "flakes"];

      substituters = [
        "https://nix-community.cachix.org"
      ];

      trusted-public-keys = [
        "nix-community.cachix.org-1:mB9FSh9qf2dCimDSUo8Zy7bkq5CX+/rkCWyvRCYg3Fs="
      ];

      extra-substituters = [
        "https://anyrun.cachix.org"
        "https://hyprland.cachix.org"
      ];

      extra-trusted-public-keys = [
        "anyrun.cachix.org-1:pqBobmOjI7nKlsUMV25u9QHa9btJK65/C8vnO3p346s="
        "hyprland.cachix.org-1:a7pgxzMz7+chwVL3/pzj6jIBMioiJM7ypFP8PwtkuGc="
      ];

      warn-dirty = false;
    };

    gc = {
      automatic = false; # using nh clean instead
      dates = "weekly";
      options = "--delete-older-than 7d";
    };
  };
}
