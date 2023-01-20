{
  description = "An http server written in Scala running on Nodejs";

  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs";
    flake-utils.url = "github:numtide/flake-utils";
    sbt = {
      url = "github:enriquerodbe/sbt-nix?dir=sbt-hook";
      inputs.nixpkgs.follows = "nixpkgs";
      inputs.flake-utils.follows = "flake-utils";
    };
    hello = {
      url = "github:enriquerodbe/sbt-nix?dir=scala-hello";
      inputs.nixpkgs.follows = "nixpkgs";
      inputs.flake-utils.follows = "flake-utils";
      inputs.sbt.follows = "sbt";
    };
  };

  outputs = {
    nixpkgs,
    flake-utils,
    sbt,
    hello,
    ...
  }:
    flake-utils.lib.eachDefaultSystem (
      system: let
        pkgs = nixpkgs.legacyPackages.${system};
        nodejs = pkgs.nodejs-18_x;
        helloPkg = hello.packages.${system}.default;
        sbtPkg = sbt.packages.${system}.default;
      in rec {
        packages.default = sbt.mkSbtDerivation.${system} {
          pname = "scalajs-server";
          version = "0.0.1";
          depsSha256 = "sha256-isgCStaS/UmN5yc9TBkshX+Vf4yXGetpGUer0qlVCjI=";
          src = builtins.path {
            path = ./.;
            name = "scalajs-server";
          };

          buildInputs = [nodejs]; # To run tests

          # Ensure that Scala.js linker is added
          # to the dependencies derivation
          depsWarmupCommand = ''
            sbt fastLinkJS
          '';

          buildPhase = ''
            sbt test fullLinkJS
          '';

          installPhase = ''
            mkdir $out
            cp target/scala-3.2.1/scalajs-server-opt/main.mjs $out
            echo "${nodejs}/bin/node $out/main.mjs" >> $out/app
            chmod +x $out/app
          '';

          nativeBuildInputs = [
            helloPkg # Normal dependency
            sbtPkg # Provides hook to load SBT_PATH
          ];
        };

        devShells.default = pkgs.mkShell {
          inputsFrom = [packages.default];
        };

        apps.default = {
          type = "app";
          program = "${packages.default}/app";
        };

        formatter = pkgs.alejandra;
      }
    );
}
