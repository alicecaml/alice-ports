# Ports of various packages to Alice
{
  alice,
  pkgs ? import <nixpkgs> { },
}:
let
  util = import ./util.nix { inherit alice pkgs; };
  pkg = util.mkAlicePkg;
  dune_3_20_0_git =
    # The dune repo contains several packages.
    pkgs.fetchgit {
      url = "https://github.com/ocaml/dune";
      tag = "3.20.2";
      hash = "sha256-JL2RG3JK8SE8AgOm6HEVFVGs9rR0Au4c6LpzziWIkvw=";
    };

in
rec {
  climate_0_9_0 = pkg {
    name = "climate";
    version = "0.9.0";
    src = pkgs.fetchgit {
      url = "https://github.com/gridbugs/climate";
      tag = "0.9.0";
      hash = "sha256-WRhWNWQ4iTUVpJlp7isJs3+0n/D0gYXTxRcCTJZ1o8U=";
    };
    prepare = ''
      cp -r $src/src src
    '';
  };
  ordering_3_20_2 = pkg {
    name = "ordering";
    version = "3.20.2";
    src = dune_3_20_0_git;
    prepare = ''
      mkdir src
      cp $src/otherlibs/ordering/ordering.ml src/lib.ml
      cp $src/otherlibs/ordering/ordering.mli src/lib.mli
    '';
  };
  xdg_3_20_2 = pkg {
    name = "xdg";
    version = "3.20.2";
    src = dune_3_20_0_git;
    prepare = ''
      mkdir src
      cp $src/otherlibs/xdg/xdg.ml src/lib.ml
      cp $src/otherlibs/xdg/xdg.mli src/lib.mli
      cp $src/otherlibs/xdg/xdg_stubs.c src/
    '';
  };
  re_1_14_0 = pkg {
    name = "re";
    version = "1.14.0";
    src = pkgs.fetchgit {
      url = "https://github.com/ocaml/ocaml-re";
      tag = "1.14.0";
      hash = "sha256-E9iNRecytQ5fLSQxYbbKMfcjs+GSl/YO19MqLiePfog=";
    };
    prepare = ''
      mkdir src
      cp $src/lib/*.ml{,i} src
      mv src/{re,lib}.ml
    '';
  };
  pp_2_0_0 = pkg {
    name = "pp";
    version = "2.0.0";
    src = pkgs.fetchgit {
      url = "https://github.com/ocaml-dune/pp";
      tag = "2.0.0";
      hash = "sha256-Wnv78en87nuAVkgZqZbdoJOiu6Pwi03K+jgMsDI0zb0=";
    };
    prepare = ''
      mkdir src
      cp $src/src/pp.ml src/lib.ml
      cp $src/src/pp.mli src/lib.mli
    '';
  };
  dyn_3_20_2 = pkg {
    name = "dyn";
    version = "3.20.2";
    src = dune_3_20_0_git;
    deps = [
      ordering_3_20_2
      pp_2_0_0
    ];
    prepare = ''
      mkdir src
      cp $src/otherlibs/dyn/dyn.ml src/lib.ml
      cp $src/otherlibs/dyn/dyn.mli src/lib.mli
    '';
  };
  fileutils_0_6_6 = pkg {
    name = "fileutils";
    version = "0.6.6";
    src = pkgs.fetchgit {
      url = "https://github.com/gildor478/ocaml-fileutils";
      tag = "v0.6.6";
      hash = "sha256-zZO7aBP7IlyEOOnlDCfv4DfOwUuNQD2C3yQ4Yz0qpos=";
    };
    builtins_ = [
      "str"
      "unix"
    ];
    prepare =
      let
        lib_ml =
          # Make a top level module exposing all the modules in this package.
          # The dune config for fileutils has "(wrapped false)" so all the
          # internal modules are intended to be exposed, and there's no
          # top-level module built into the upstream package.
          pkgs.writeText "lib.ml" ''
            module CommonPath = CommonPath
            module FilePath = FilePath
            module FilePath_type = FilePath_type
            module FileStringExt = FileStringExt
            module FileUtil = FileUtil
            module FileUtilCHMOD = FileUtilCHMOD
            module FileUtilCMP = FileUtilCMP
            module FileUtilCP = FileUtilCP
            module FileUtilDU = FileUtilDU
            module FileUtilFIND = FileUtilFIND
            module FileUtilLS = FileUtilLS
            module FileUtilMKDIR = FileUtilMKDIR
            module FileUtilMV = FileUtilMV
            module FileUtilMisc = FileUtilMisc
            module FileUtilMode = FileUtilMode
            module FileUtilPWD = FileUtilPWD
            module FileUtilPermission = FileUtilPermission
            module FileUtilREADLINK = FileUtilREADLINK
            module FileUtilRM = FileUtilRM
            module FileUtilSTAT = FileUtilSTAT
            module FileUtilSize = FileUtilSize
            module FileUtilTEST = FileUtilTEST
            module FileUtilTOUCH = FileUtilTOUCH
            module FileUtilTypes = FileUtilTypes
            module FileUtilUMASK = FileUtilUMASK
            module FileUtilWHICH = FileUtilWHICH
            module FileUtilStr = FileUtilStr
          '';
      in
      ''
        mkdir src
        cp $src/src/lib/fileutils/{,str/}*.ml{,i} src
        cp ${lib_ml} src/lib.ml
      '';
  };
}
