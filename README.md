# Alice Ports

[![test](https://github.com/alicecaml/alice-ports/actions/workflows/test.yml/badge.svg)](https://github.com/alicecaml/alice-ports/actions/workflows/test.yml)

Nix derivations for porting OCaml projects to build with [Alice](https://alicecaml.org).

## Usage

By default this flake creates a zip archive containing all the ports:
```
$ nix build
$ ls result
alice-ports.zip
```

Other outputs:
- `.#repo` creates a directory containing each package source directory
- `.#packages.<package>` (e.g. `.#packages.climate_0_9_0`) creates the package's source directory
- `.#debug.dependOn.<package>` creates a package depending on the given package and builds it
- `.#debug.dependOnAll` creates a pcakage depending on all packages and builds it
