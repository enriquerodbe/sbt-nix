# sbt-nix

This is an experimental project with the main goal of learning Nix.
To make something useful out of this project, I use Nix to both: build a Scala package, and use
it as a dependency from a consumer Scala project.

## Project layout

This repository is divided in 3 directories: `sbt-hook`, `scala-hello`, and `scalajs-server`.

### [sbt-hook](sbt-hook)

Provides `sbt` from `nixpkgs` together with a setup hook that searches all the Nix inputs that write
their output in `$out/lib/ivy2`, and adds them to the `SBT_PATH` environment variable. This is
inspired on [nodejs](https://github.com/NixOS/nixpkgs/tree/master/pkgs/development/web/nodejs),
which does exactly this but with `$out/lib/node_modules` and `NODE_PATH`.
For consistency and in order to centralize the place where this constant path is defined, it also
provides a function called `mkSbtDerivation` which in turn
calls [zaninime/sbt-derivation](https://github.com/zaninime/sbt-derivation) with the `installPhase`
already defined to install to `$out/lib/ivy2`. This internally uses `sbt publishLocal` so it will
write everything needed there, including docs, sources, and obviously binaries. All in ivy format.

### [scala-hello](scala-hello)

A simple "Hello world" in ScalaJS. It uses `sbt-hook` to make the derivation, so it will
automatically be written to `$out/lib/ivy2`.

### [scalajs-server](scalajs-server)

An HTTP server written in ScalaJS using `http4s` and `scala-hello`. `http4s` is pulled from the
default maven repository via `zaninime/sbt-derivation`, but `scala-hello` is passed as a Nix build
input and, with the help of `sbt-hook`, it's obtained from the Nix store.
The `scala-hello` dependency is resolved by:

1. Adding `sbt-hook` as a flake input, which sets `SBT_PATH` with the Nix store path for all the
   inputs that were built using `sbt-hook`. In this case `scala-hello`.
2. Adding one [resolver](https://www.scala-sbt.org/1.x/docs/Resolvers.html) per each path found
   in `SBT_PATH` (see [build.sbt](scalajs-server/build.sbt)).

## Alternative solution

Instead of using sbt resolvers, the dependencies could be added as
[unmanaged dependencies](https://www.scala-sbt.org/1.x/docs/Library-Dependencies.html#Unmanaged+dependencies).
To achieve this, the sbt hook could copy or link the dependencies in the local `lib` directory.
It would avoid the requirement for the Scala consumer code to manually add the resolvers, but
unmanaged dependencies come with their own drawbacks.

One drawback is keeping mutable state: although adding files to the `lib` directory can be correctly
solved and in theory shouldn't cause big problems, there could be cases where the dependencies are
corrupted or out of date.

The second and most important problem with unmanaged dependencies is managing transitive
dependencies. Because only jar files are added to the unmanaged dependencies, transitive
dependencies can't be resolved automatically by sbt. In contrast with resolvers which provide all
resolution features, it is a reason to discard unmanaged dependencies.

## Try it

1. Run the server:
   1. Locally from a clone of this repository:
      ```shell
      cd scalajs-server
      nix run
      ```
   2. Or from anywhere with Nix:
      ```shell
      nix run "github:enriquerodbe/sbt-nix?dir=scalajs-server"
      ```
2. Then, in another terminal, make a request:
   ```shell
   curl localhost:8080/hello/Nix
   ```
3. It should return an HTTP OK response with the following body:
   ```json
   {"message":"Hello, Nix!"}
   ```

## Bonus

Both Scala projects use ScalaJS. Notice that the HTTP server runs on Node.js!
