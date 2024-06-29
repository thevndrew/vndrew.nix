{lib, ...}: rec {
  # use path relative to the root of the project
  relativeToRoot = lib.path.append ../.;

  # Get a list of .nix files in the directory "path"
  scanPaths = path: let
    excludeDirs = [
      #"modules"
      "packages"
      "pkgs"
      "scripts"
      "settings"
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

  operateOnFiles = path: op:
    builtins.map
    (f: (op (path + "/${f}")))
    (builtins.attrNames
      (
        lib.attrsets.filterAttrs
        (
          _path: _type: (
            _type
            != "directory"
          )
        )
        (builtins.readDir path)
      ));

  # Get a list of strings containing the contents of each file
  # in a directory
  readFiles = path: operateOnFiles path (f: builtins.readFile f);

  sourceFiles = path: operateOnFiles path (f: "source ${f}");

  # merge list of strings using a seperator
  writeLines = {
    lines,
    sep ? "\n",
  }:
    lib.concatStringsSep sep lines;
}
