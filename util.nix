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
      built_artifacts_from_deps ? true,
      deps ? [ ],
      builtins_ ? [ ],
    }:
    let
      depLines = builtins.map (
        {
          name,
          built,
          ...
        }:
        "    ${name} path=\"${built}\""
      ) deps;
      depString = pkgs.lib.strings.join "\n" depLines;
      builtinsLines = builtins.map (name: "    ${name}") builtins_;
      builtinsString = pkgs.lib.strings.join "\n" builtinsLines;
    in
    rec {
      inherit name version;
      nameVersion = "${name}-${version}";

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
          builtins {
        ${builtinsString}
          }
        }
      '';

      # Stripped down Alice package source code. This derivation may port a
      # package in a non-Alice format into the format expected by Alice by
      # running the commands in the `prepare` argument, which is expected to
      # create an Alice-compatible "src" directory.
      source = pkgs.stdenv.mkDerivation {
        inherit src;
        name = nameVersion;
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
        name = "${nameVersion}-built";
        src = source;
        buildInputs = [
          alice
        ];
        buildPhase =
          let
            built_artifacts_from_deps_arg =
              if built_artifacts_from_deps then "--built-artifacts-from-deps" else "";
          in
          ''
            alice build ${built_artifacts_from_deps_arg} 2>&1 | tee log.txt
          '';
        installPhase = ''
          mkdir -p $out
          cp -r * $out
        '';
      };

      topLevelModuleName =
        let
          capitalizeFirst =
            s: pkgs.lib.toUpper (builtins.substring 0 1 s) + builtins.substring 1 (builtins.stringLength s) s;
        in
        capitalizeFirst name;
    };
}
