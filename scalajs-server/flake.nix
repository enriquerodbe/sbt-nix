{
  description = "An http server written in Scala running on Nodejs";

  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs";
    utils.url = "github:numtide/flake-utils";
    sbt.url = "github:enriquerodbe/sbt-nix?dir=sbt-hook";
    hello.url = "github:enriquerodbe/sbt-nix?dir=scala-hello";
  };

  outputs = {
    nixpkgs,
    utils,
    sbt,
    hello,
    ...
  }:
    utils.lib.eachDefaultSystem (
      system: let
        pkgs = nixpkgs.legacyPackages.${system};
        nodejs = pkgs.nodejs-18_x;
        helloPkg = hello.packages.${system}.default;
        sbtPkg = sbt.packages.${system}.default;
      in rec {
        packages.default = sbt.mkSbtDerivation.${system} {
          pname = "scalajs-server";
          version = "0.0.1";
          depsSha256 = "sha256-3wxI5tmqCOKjR97w8/15cQ49hkCKTQD8mEFhE0F7jUI=";
          src = builtins.path {
            path = ./.;
            name = "scalajs-server";
          };

          buildPhase = ''
            sbt fullLinkJS
          '';

          installPhase = ''
            mkdir $out
            cp target/scala-3.2.1/scalajs-server-opt/main.mjs $out
            echo "${nodejs}/bin/node $out/main.mjs" >> $out/app
            chmod +x $out/app
          '';

          buildInputs = [
            helloPkg # Normal dependency
            sbtPkg # Provides hook to load SBT_PATH
          ];
        };

        devShell = pkgs.mkShell {
          inputsFrom = [packages.default];
          packages = [nodejs]; # To run tests
        };

        defaultApp = {
          type = "app";
          program = "${packages.default}/app";
        };

        formatter = pkgs.alejandra;
      }
    );
}
