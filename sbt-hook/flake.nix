{
  description = "Extend sbt with a hook to use dependencies from Nix";

  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs";
    flake-utils.url = "github:numtide/flake-utils";
    sbt-derivation = {
      url = "github:zaninime/sbt-derivation";
      inputs.nixpkgs.follows = "nixpkgs";
      inputs.flake-utils.follows = "flake-utils";
    };
  };

  outputs = {
    nixpkgs,
    flake-utils,
    sbt-derivation,
    ...
  }:
    flake-utils.lib.eachDefaultSystem (
      system: let
        pkgs = nixpkgs.legacyPackages.${system};
        sbt = pkgs.sbt;
        addHook = prev: {
          name = "${prev.name}-hook";
          setupHook = ./setup-hook.sh;
        };
        defaultInstallPhase = {
          # Provide a default install phase that matches the hook's path
          installPhase = ''
            mkdir -p $out/lib/ivy2
            SBT_OPTS="$SBT_OPTS -Dsbt.ivy.home=$out/lib/ivy2"
            sbt publishLocal
          '';
        };
      in {
        packages.default = pkgs.lib.overrideDerivation sbt addHook;

        mkSbtDerivation = params:
          sbt-derivation.mkSbtDerivation.${system} (defaultInstallPhase // params);

        formatter = pkgs.alejandra;
      }
    );
}
