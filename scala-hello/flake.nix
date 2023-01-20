{
  description = "Scala hello world with Nix";

  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs";
    flake-utils.url = "github:numtide/flake-utils";
    sbt = {
      url = "github:enriquerodbe/sbt-nix?dir=sbt-hook";
      inputs.nixpkgs.follows = "nixpkgs";
      inputs.flake-utils.follows = "flake-utils";
    };
  };

  outputs = {
    nixpkgs,
    flake-utils,
    sbt,
    ...
  }:
    flake-utils.lib.eachDefaultSystem (
      system: let
        pkgs = nixpkgs.legacyPackages.${system};
      in rec {
        packages.default = sbt.mkSbtDerivation.${system} {
          pname = "scala-hello";
          version = "0.0.1";
          depsSha256 = "sha256-aYliG1t86Yd21VEt069kSdJ4VT6LYXwQ3BNEghfHVUg=";
          src = builtins.path {
            path = ./.;
            name = "scala-hello";
          };

          buildInputs = [pkgs.nodejs-18_x]; # To run tests

          # Ensure that Scala.js linker is added
          # to the dependencies derivation
          depsWarmupCommand = ''
            sbt fastLinkJS
          '';

          buildPhase = ''
            sbt test
          '';
        };

        devShells.default = pkgs.mkShell {
          inputsFrom = [packages.default];
        };

        formatter = pkgs.alejandra;
      }
    );
}
