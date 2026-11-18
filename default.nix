{
  alice,
  pkgs ? import <nixpkgs> { },
  package ? null,
}:
let

  util = import ./util.nix { inherit alice pkgs; };
  packages = import ./packages.nix { inherit alice pkgs; };

  repo =
    # A repo with a directory for each package.
    pkgs.stdenv.mkDerivation {
      name = "alice-ports";
      dontUnpack = true;
      installPhase = pkgs.lib.strings.join "\n" (
        [ "mkdir $out" ]
        ++ builtins.map ({ nameVersion, source, ... }: ''
          cp -r ${source} $out/${nameVersion}
        '') (builtins.attrValues packages)
      );
    };

  repo_zip = pkgs.stdenv.mkDerivation {
    name = "repo.zip";
    buildInputs = with pkgs; [ zip ];
    dontUnpack = true;
    installPhase = ''
      mkdir $out
      cp -r ${repo} alice-ports

      # This will allow users to run `alice build` inside one of the ports to build it.
      chmod -R u+w alice-ports

      zip -r $out/alice-ports.zip alice-ports
    '';
  };

  mkTestPackage =
    # Make a derivation that crafts a package depending on a list of packages
    # and then builds it.
    { name, deps }:
    pkgs.stdenv.mkDerivation {
      inherit name;
      buildInputs = [ alice ];
      dontUnpack = true;
      installPhase =
        let
          module_alias_src = pkgs.lib.strings.join "\n" (
            builtins.map ({ topLevelModuleName, ... }: "module ${topLevelModuleName} = ${topLevelModuleName}") (
              deps
            )
          );
          main_ml = pkgs.writeText "main.ml" ''
            ${module_alias_src}
          '';
          alice_kdl =
            let
              dependencies = util.mkBlock {
                name = "dependencies";
                lines = builtins.map (
                  {
                    name,
                    nameVersion,
                    ...
                  }:
                  "    ${name} path=\"${repo}/${nameVersion}\""
                ) deps;
              };
            in
            pkgs.writeText "Alice.kdl" ''
              package {
                name ${name}
                version "0.1.0"${dependencies}
              }
            '';
        in
        ''
          mkdir -p $out/src
          cp ${main_ml} $out/src/main.ml
          cp ${alice_kdl} $out/Alice.kdl
          cd $out
          alice build 2>&1 | tee log.txt
        '';
    };

in
{
  inherit repo repo_zip;

  debug = {
    dependOn = builtins.mapAttrs (
      _:
      (
        package:
        mkTestPackage {
          name = "depend_on_${package.name}";
          deps = [ package ];
        }
      )
    ) packages;

    dependOnAll = mkTestPackage {
      name = "depend_on_all";
      deps = builtins.attrValues packages;
    };
  };

  # A derivation for the source of each package so a single package can be examined.
  packages = builtins.mapAttrs (_: ({ source, ... }: source)) packages;
}
