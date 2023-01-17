{
  description = "Scala hello world with Nix";

  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs";
    utils.url = "github:numtide/flake-utils";
    sbt.url = "github:enriquerodbe/sbt-nix?dir=sbt-hook";
  };

  outputs = {
    nixpkgs,
    utils,
    sbt,
    ...
  }:
    utils.lib.eachDefaultSystem (
      system: let
        pkgs = nixpkgs.legacyPackages.${system};
      in rec {
        packages.default = sbt.mkSbtDerivation.${system} {
          pname = "scala-hello";
          version = "0.0.1";
          depsSha256 = "sha256-102cw9huax1LHUQawIphj6tCeGtqlV9h4XtO8NGVESM=";
          src = builtins.path {
            path = ./.;
            name = "scala-hello";
          };
        };

        devShells.default = pkgs.mkShell {
          inputsFrom = [packages.default];
          packages = [pkgs.nodejs-18_x]; # To run tests
        };

        formatter = pkgs.alejandra;
      }
    );
}
