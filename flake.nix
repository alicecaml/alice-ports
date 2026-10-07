{
  description = "Assemble a repository of Alice packages";

  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixos-unstable";
    alice.url = "github:alicecaml/alice";
  };

  outputs =
    {
      self,
      nixpkgs,
      alice,
    }:
    let
      systems = [
        "aarch64-darwin"
        "aarch64-linux"
        "x86_64-darwin"
        "x86_64-linux"
      ];
      forAllSystems =
        f:
        nixpkgs.lib.genAttrs systems (
          system:
          f {
            pkg = import ./default.nix {
              alice = alice.packages.${system}.default;
              pkgs = import nixpkgs { inherit system; };
            };
          }
        );

    in
    {
      packages = forAllSystems (
        { pkg, ... }:
        {
          default = pkg;
        }
      );
    };
}
