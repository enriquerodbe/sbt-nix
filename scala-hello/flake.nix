{
  description = "Scala hello world with Nix";

  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs";
    utils.url = "github:numtide/flake-utils";
    sbt.url = "path:/Users/enrique/development/sbt-nix/sbt-hook";
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
          depsSha256 = "sha256-wLQI9d8KqLQl2vGVlTfy6NuN5iY+P3L4F6WnukP4noU=";
          src = builtins.path {
            path = ./.;
            name = "scala-hello";
          };
        };

        devShell = pkgs.mkShell {
          inputsFrom = [packages.default];
          packages = [pkgs.nodejs-18_x]; # To run tests
        };

        formatter = pkgs.alejandra;
      }
    );
}
