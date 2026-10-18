{
  alice,
  pkgs ? import <nixpkgs> { },
}:
let
  util = import ./util.nix { inherit alice pkgs; };
  portsSet = import ./ports.nix { inherit alice pkgs; };
  ports = builtins.attrValues (portsSet);

  # A package which depends on all other packages. Build-system or packaging
  # bugs sometimes only manifest when linking executables that depend on
  # libraries that were incorrectly built.
  packageDependingOnAllPorts = util.mkAlicePkg {
    name = "depend_on_all_ports";
    version = "0.1.0";
    src = pkgs.runCommand "empty" { } "mkdir -p  $out";
    deps = ports;
    prepare = ''
      mkdir src
      touch src/main.ml
    '';
    built_artifacts_from_deps = false;
  };

  # Commands to copy each package port into a single directory.
  installEachPort = builtins.map (
    {
      name_version,
      source,
      built,
      ...
    }:
    ''
      mkdir -p $out/ports/${name_version}
      cp -r ${source} $out/ports/${name_version}/source
      cp -r ${built} $out/ports/${name_version}/built
    ''
  ) (ports ++ [ packageDependingOnAllPorts ]);
in
pkgs.stdenv.mkDerivation {
  name = "alice-ports";
  src = ./.;
  installPhase =
    let
      installPorts = pkgs.lib.strings.join "\n" installEachPort;
    in
    ''
      mkdir -p $out
      ${installPorts}
      mv $out/ports/${packageDependingOnAllPorts.name_version} $out/package-depending-on-all-ports
    '';
}
