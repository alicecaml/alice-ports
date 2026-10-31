{
  alice,
  pkgs ? import <nixpkgs> { },
}:
let
  # name-version of packages to exclude (e.g. xdg-3.20.2)
  skip = [ ];

  util = import ./util.nix { inherit alice pkgs; };
  portsSet = import ./ports.nix { inherit alice pkgs; };
  ports = builtins.filter ({ nameVersion, ... }: !(builtins.elem nameVersion skip)) (
    builtins.attrValues (portsSet)
  );

  # A package which depends on all other packages. Build-system or packaging
  # bugs sometimes only manifest when linking executables that depend on
  # libraries that were incorrectly built.
  packageDependingOnAllPorts = util.mkAlicePkg {
    name = "depend_on_all_ports";
    version = "0.1.0";
    src = pkgs.runCommand "empty" { } "mkdir -p  $out";
    deps = ports;
    prepare =
      let
        module_alias_src = pkgs.lib.strings.join "\n" (
          builtins.map (
            { topLevelModuleName, ... }: "module ${topLevelModuleName} = ${topLevelModuleName}"
          ) ports
        );
        main_ml = pkgs.writeText "main.ml" ''
          ${module_alias_src}
        '';
      in
      ''
        cp ${main_ml} src/main.ml
      '';
    built_artifacts_from_deps = false;
  };

  # Commands to copy each package port into a single directory.
  installEachPort = builtins.map (
    {
      nameVersion,
      source,
      built,
      ...
    }:
    ''
      mkdir -p ports
      cp -r ${source} ports/${nameVersion}
      cp -r ${built} debug/built-ports/${nameVersion}
    ''
  ) ports;
in
pkgs.stdenv.mkDerivation {
  name = "alice-ports";
  src = ./.;
  buildPhase =
    let
      installPorts = pkgs.lib.strings.join "\n" installEachPort;
    in
    ''
      mkdir -p debug/built-ports

      ${installPorts}

      cp -r ${packageDependingOnAllPorts.built} debug/built-package-depending-on-all-ports
    '';
  installPhase = ''
    mkdir -p $out
    cp -r ports $out/ports
    cp -r debug $out/debug
  '';
}
