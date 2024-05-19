{lib, ...}: {
  # use path relative to the root of the project
  relativeToRoot = lib.path.append ../.;

  scanPaths = path: let
    excludeDirs = [
      "scripts"
      "systemd"
    ];

    excludeNamePrefix = [
      "_"
    ];

    excludeNameSuffix = [
      "_settings"
      "_module"
    ];

    filterDir = path: builtins.all (dir: path != dir) excludeDirs;
    filterFileSuffix = path: builtins.all (suffix: !lib.strings.hasSuffix "${suffix}.nix" path) excludeNameSuffix;
    filterFilePrefix = path: builtins.all (prefix: !lib.strings.hasPrefix "${prefix}" path) excludeNamePrefix;
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
              && (filterFilePrefix path) # ignore files starting with exluded prefixes
              && (lib.strings.hasSuffix ".nix" path) # include .nix files
            )
        )
        (builtins.readDir path)));
}
