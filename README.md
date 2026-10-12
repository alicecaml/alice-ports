# Alice Ports

[![test](https://github.com/alicecaml/alice-ports/actions/workflows/test.yml/badge.svg)](https://github.com/alicecaml/alice-ports/actions/workflows/test.yml)

Nix derivations for porting OCaml projects to build with [Alice](https://alicecaml.org).

## Usage

Assemble and build the ports with [Nix Flakes](https://nixos.wiki/wiki/flakes) by running:
```
$ nix build
```

The port for each package can be accessed via the `result` symlink.
