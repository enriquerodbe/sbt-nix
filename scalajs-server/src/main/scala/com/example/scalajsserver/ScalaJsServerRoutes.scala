package com.example.scalajsserver

import cats.effect.Sync
import cats.implicits.*
import org.http4s.HttpRoutes
import org.http4s.dsl.Http4sDsl

object ScalaJsServerRoutes:
  def helloWorldRoutes[F[_]: Sync](helloWorld: HelloWorld[F]): HttpRoutes[F] =
    val dsl = new Http4sDsl[F] {}
    import dsl.*
    HttpRoutes.of[F] { case GET -> Root / "hello" / name =>
      helloWorld.greet(name).flatMap(Ok(_))
    }
