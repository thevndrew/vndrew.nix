{lib, ...}: {
  # use path relative to the root of the project
  relativeToRoot = lib.path.append ../.;

  scanPaths = path: let
    excludeDirs = [
      "scripts"
      "systemd"
    ];

    excludeNameSuffix = [
      "_settings"
      "_module"
    ];

    filterDir = path: builtins.all (dir: path != dir) excludeDirs;
    filterFileSuffix = path: builtins.all (suffix: !lib.strings.hasSuffix "${suffix}.nix" path) excludeNameSuffix;
  in
    builtins.map
    (f: (path + "/${f}"))
    (builtins.attrNames
      (lib.attrsets.filterAttrs
        (
          path: _type:
            (
              _type
              == "directory" # include directories
              && filterDir path # filter excluded dirs
            )
            || (
              (path != "default.nix") # ignore default.nix
              && (filterFileSuffix path) # ignore *settings.nix files
              && (lib.strings.hasSuffix ".nix" path) # include .nix files
            )
        )
        (builtins.readDir path)));
}
