{
  lib,
  inputs,
  system,
  buildGoModule,
  ...
}: let
  filterSystem = s:
    {
      "x86_64-linux" = {
        sha256 = "${lib.fakeHash}";
        system = "linux_amd64";
      };
    }
    .${s}
    or (throw "Unsupported system: ${s}");
  metadata = filterSystem system;
  name = "bootdev";
  version = "v0.0.1";
in
  buildGoModule rec {
    inherit name version;
    src = inputs.bootdev;
    vendorHash = "sha256-jhRoPXgfntDauInD+F7koCaJlX4XDj+jQSe/uEEYIMM=";
  }
