{
  description = "Nix flake packaging TMOG (Task Manager OG) for NixOS";

  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixos-unstable";
    flake-utils.url = "github:numtide/flake-utils";
  };

  outputs = { self, nixpkgs, flake-utils }:
    flake-utils.lib.eachDefaultSystem (system:
      let
        pkgs = import nixpkgs {
          inherit system;
          config.allowUnfree = true;
        };
      in
      {
        packages.tmog = pkgs.callPackage ./package.nix { };
        packages.default = self.packages.${system}.tmog;

        devShells.default = pkgs.mkShell {
          buildInputs = [ pkgs.nix-prefetch ];
        };
      });
}
