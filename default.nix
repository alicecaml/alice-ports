{
  alice,
  pkgs ? import <nixpkgs> { },
}:
let
  ports_set = import ./ports.nix { inherit alice pkgs; };
  ports = builtins.attrValues (ports_set);
  lines = builtins.map (
    {
      name_version,
      source,
      built,
      ...
    }:
    ''
      mkdir -p $out/${name_version}
      cp -r ${source} $out/${name_version}/source
      cp -r ${built} $out/${name_version}/built
    ''
  ) ports;
in
pkgs.stdenv.mkDerivation {
  name = "alice-ports";
  src = ./.;
  installPhase = pkgs.lib.strings.join "\n" ([ "mkdir -p $out" ] ++ lines);
}
