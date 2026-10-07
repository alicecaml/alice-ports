# Ports of various packages to Alice
{
  alice,
  pkgs ? import <nixpkgs> { },
}:
let
  util = import ./util.nix { inherit alice pkgs; };
  pkg = util.mkAlicePkg;
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
    deps = [ ];
    prepare = ''
      cp -r $src/src src
    '';
  };
  ordering_3_20_2 = pkg {
    name = "ordering";
    version = "3.20.2";
    src = pkgs.fetchgit {
      url = "https://github.com/ocaml/dune";
      tag = "3.20.2";
      hash = "sha256-JL2RG3JK8SE8AgOm6HEVFVGs9rR0Au4c6LpzziWIkvw=";
    };
    deps = [ ];
    prepare = ''
      mkdir src
      cp $src/otherlibs/ordering/ordering.ml src/lib.ml
      cp $src/otherlibs/ordering/ordering.mli src/lib.mli
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
    deps = [ ];
    prepare = ''
      mkdir src
      cp $src/src/pp.ml src/lib.ml
      cp $src/src/pp.mli src/lib.mli
    '';
  };
  dyn_3_20_2 = pkg {
    name = "dyn";
    version = "3.20.2";
    src = pkgs.fetchgit {
      url = "https://github.com/ocaml/dune";
      tag = "3.20.2";
      hash = "sha256-JL2RG3JK8SE8AgOm6HEVFVGs9rR0Au4c6LpzziWIkvw=";
    };
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
}
