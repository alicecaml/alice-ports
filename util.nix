{
  alice,
  pkgs ? import <nixpkgs> { },
}:
rec {
  mkBlock =
    # Return a string with a block like the dependencies or builtins block
    # or the empty string if the list of lines is empty.
    { name, lines }:
    if builtins.length lines == 0 then
      ""
    else
      ''

          ${name} {
        ${pkgs.lib.strings.join "\n" lines}
          }'';

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
      depString = mkBlock {
        name = "dependencies";
        lines = builtins.map (
          {
            name,
            nameVersion,
            ...
          }:
          # Use a relative path as the location of the dependency.
          "    ${name} path=\"../${nameVersion}\""
        ) deps;
      };
      builtinsString = mkBlock {
        name = "builtins";
        lines = builtins.map (name: "    ${name}") builtins_;
      };
    in
    rec {
      inherit name version;
      nameVersion = "${name}-${version}";

      # KDL manifest file for the package. Dependencies are currently specified
      # by relative path as if each package directory were neighbours.
      manifest = pkgs.writeText "${name}-${version}-Alice.kdl" ''
        package {
          name ${name}
          version "${version}"${depString}${builtinsString}
        }
      '';

      # Stripped down Alice package source code. This derivation may port a
      # package in a non-Alice format into the format expected by Alice by
      # running the commands in the `prepare` argument, which is expected to
      # create an Alice-compatible "src" directory.
      source = pkgs.stdenv.mkDerivation {
        inherit src;
        name = nameVersion;
        sourceRoot = ".";
        buildPhase = ''
          mkdir -p $TMPDIR/prepare/src
          cd $TMPDIR/prepare
          ${prepare}
          cp ${manifest} Alice.kdl
        '';
        installPhase = ''
          mkdir -p $out
          cp -r $TMPDIR/prepare/* $out
        '';
      };

      topLevelModuleName =
        let
          capitalizeFirst =
            s: pkgs.lib.toUpper (builtins.substring 0 1 s) + builtins.substring 1 (builtins.stringLength s) s;
        in
        capitalizeFirst name;
    };

  # Make a top level module exposing all the modules in this package.
  # When the dune config for a project has "(wrapped false)" all the
  # internal modules are intended to be exposed. This function is intended to
  # help in these cases by turning a list of module names into a top level
  # module.
  mkTopLevelModuleSource =
    modules:
    let
      text = pkgs.lib.strings.join "\n" (builtins.map (module: "module ${module} = ${module}") modules);
    in
    pkgs.writeText "lib.ml" text;
}
