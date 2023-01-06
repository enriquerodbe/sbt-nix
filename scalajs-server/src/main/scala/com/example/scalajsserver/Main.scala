package com.example.scalajsserver

import cats.effect.{ExitCode, IO, IOApp}
import com.example.scalajsserver.ScalaJsServerRoutes.helloWorldRoutes
import org.http4s.ember.server.EmberServerBuilder

object Main extends IOApp:
  def run(args: List[String]): IO[ExitCode] =
    val routes =
      helloWorldRoutes[IO](HelloWorld.impl[IO]).orNotFound
    val server =
      EmberServerBuilder
        .default[IO]
        .withHttpApp(routes)
        .build
    server
      .use(_ => IO.never)
      .as(ExitCode.Success)
