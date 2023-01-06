import org.scalajs.jsenv.nodejs.NodeJSEnv
import org.scalajs.linker.interface.OutputPatterns
import Resolver.ivyStylePatterns

organization := "com.example"
name := "scalajs-server"
version := "0.0.1"

scalaVersion := "3.2.1"
enablePlugins(ScalaJSPlugin)
scalacOptions += "-scalajs"

resolvers ++=
  sys.env
    .getOrElse("SBT_PATH", "")
    .split(":")
    .map(file)
    .zipWithIndex
    .map { case (baseDir, index) =>
      Resolver.file(s"nix-repository-$index", baseDir)(ivyStylePatterns)
    }
    .toSeq

val Http4sVersion = "0.23.16"
val CirceVersion = "0.14.3"
val MunitVersion = "0.7.29"
val LogbackVersion = "1.2.11"
val scalaHelloVersion = "0.0.1"
val MunitCatsEffectVersion = "1.0.7"
libraryDependencies ++= Seq(
  "org.http4s" %%% "http4s-ember-server" % Http4sVersion,
  "org.http4s" %%% "http4s-circe" % Http4sVersion,
  "org.http4s" %%% "http4s-dsl" % Http4sVersion,
  "com.example" %%% "scala-hello" % scalaHelloVersion,
  "org.scalameta" %%% "munit" % MunitVersion % Test,
  "org.typelevel" %%% "munit-cats-effect-3" % MunitCatsEffectVersion % Test,
)

jsEnv := new NodeJSEnv(
  NodeJSEnv.Config().withArgs(List("--experimental-specifier-resolution=node"))
)
scalaJSLinkerConfig ~= {
  _.withModuleKind(ModuleKind.ESModule)
    .withOutputPatterns(OutputPatterns.fromJSFile("%s.mjs"))
}
scalaJSUseMainModuleInitializer := true
