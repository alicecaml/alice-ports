{
  alice,
  pkgs ? import <nixpkgs> { },
}:
{
  mkAlicePkg =
    {
      name,
      version,
      src,
      prepare,
      deps,
    }:
    let
      depLines = builtins.map (
        {
          name,
          source,
          ...
        }:
        "    ${name} path=\"${source}\""
      ) deps;
      depString = pkgs.lib.strings.join "\n" depLines;
    in
    rec {
      inherit name version;
      name_version = "${name}-${version}";

      # KDL manifest file for the package. Dependencies are currently specified
      # by absolute path though this will need to change in order to publish
      # these packages.
      manifest = pkgs.writeText "${name}-${version}-Alice.kdl" ''
        package {
          name ${name}
          version "${version}"
          dependencies {
        ${depString}
          }
        }
      '';

      # Stripped down Alice package source code. This derivation may port a
      # package in a non-Alice format into the format expected by Alice by
      # running the commands in the `prepare` argument, which is expected to
      # create an Alice-compatible "src" directory.
      source = pkgs.stdenv.mkDerivation {
        inherit src;
        name = name_version;
        dontUnpack = true;
        buildPhase = ''
          ${prepare}
          cp ${manifest} Alice.kdl
        '';
        installPhase = ''
          mkdir -p $out
          cp -r Alice.kdl src $out
        '';
      };

      # A derivation that builds the package along with its dependencies as a
      # sanity check.
      built = pkgs.stdenv.mkDerivation {
        name = "${name_version}-built";
        src = source;
        buildInputs = [
          alice
        ];
        buildPhase = ''
          alice build
        '';
        installPhase = ''
          mkdir -p $out
          cp -r * $out
        '';
      };
    };
}
