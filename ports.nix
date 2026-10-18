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
      cp -r $src/src/* src
    '';
  };
  ordering_3_20_2 = pkg {
    name = "ordering";
    version = "3.20.2";
    src = dune_3_20_0_git;
    prepare = ''
      cp $src/otherlibs/ordering/ordering.ml src/lib.ml
      cp $src/otherlibs/ordering/ordering.mli src/lib.mli
    '';
  };
  xdg_3_20_2 = pkg {
    name = "xdg";
    version = "3.20.2";
    src = dune_3_20_0_git;
    prepare = ''
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
        lib_ml = util.mkTopLevelModuleSource [
          "CommonPath"
          "FilePath"
          "FilePath_type"
          "FileStringExt"
          "FileUtil"
          "FileUtilCHMOD"
          "FileUtilCMP"
          "FileUtilCP"
          "FileUtilDU"
          "FileUtilFIND"
          "FileUtilLS"
          "FileUtilMKDIR"
          "FileUtilMV"
          "FileUtilMisc"
          "FileUtilMode"
          "FileUtilPWD"
          "FileUtilPermission"
          "FileUtilREADLINK"
          "FileUtilRM"
          "FileUtilSTAT"
          "FileUtilSize"
          "FileUtilTEST"
          "FileUtilTOUCH"
          "FileUtilTypes"
          "FileUtilUMASK"
          "FileUtilWHICH"
          "FileUtilStr"
        ];
      in
      ''
        cp $src/src/lib/fileutils/{,str/}*.ml{,i} src
        cp ${lib_ml} src/lib.ml
      '';
  };
  sha_1_15_4 = pkg {
    name = "sha";
    version = "1.15.4";
    src = pkgs.fetchzip {
      url = "https://github.com/djs55/ocaml-sha/releases/download/v1.15.4/sha-1.15.4.tbz";
      hash = "sha256-Fovw5ch3b0vm6I9IvfmhgTNeXLCury7HXyg0RFc0U0g=";
    };
    prepare =
      let
        lib_ml = util.mkTopLevelModuleSource [
          "Sha1"
          "Sha256"
          "Sha512"
        ];
      in
      ''
        cp $src/*.{ml,mli,c,h} src
        cp ${lib_ml} src/lib.ml
      '';
  };
  sexplib0_0_17_0 = pkg {
    name = "sexplib0";
    version = "0.17.0";
    src = pkgs.fetchgit {
      url = "https://github.com/janestreet/sexplib0";
      tag = "v0.17.0";
      hash = "sha256-Q53wEhRet/Ou9Kr0TZNTyXT5ASQpsVLPz5n/I+Fhy+g=";
    };
    prepare = ''
      cp $src/src/*.ml{,i} src
      mv src/{sexplib0,lib}.ml
    '';
  };
  csexp_1_5_2 = pkg {
    name = "csexp";
    version = "1.5.2";
    src = pkgs.fetchgit {
      url = "https://github.com/ocaml-dune/csexp";
      tag = "1.5.2";
      hash = "sha256-pJWk3H73cQZMYhEH7ak9P10oT0LsxLruZoMw3rmWalw=";
    };
    prepare = ''
      cp $src/src/csexp.ml src/lib.ml
      cp $src/src/csexp.mli src/lib.mli
    '';
  };
}
