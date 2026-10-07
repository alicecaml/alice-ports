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
      # sanity check that the package can be built
      cp -r ${built} $TMPDIR

      # copy the ported package source to the output
      cp -r ${source} $out/${name_version}
    ''
  ) ports;
in
pkgs.stdenv.mkDerivation {
  name = "alice-ports";
  src = ./.;
  installPhase = pkgs.lib.strings.join "\n" ([ "mkdir -p $out" ] ++ lines);
}
