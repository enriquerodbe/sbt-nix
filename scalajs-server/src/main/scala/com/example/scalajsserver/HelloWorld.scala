package com.example.scalajsserver

import cats.Applicative
import cats.implicits.*
import io.circe.{Encoder, Json}
import io.circe.syntax.*
import org.http4s.EntityEncoder
import org.http4s.circe.*

trait HelloWorld[F[_]]:
  def greet(n: String): F[HelloWorld.Greeting]

object HelloWorld:
  final case class Greeting(greeting: String) extends AnyVal
  private object Greeting:
    implicit val greetingEncoder: Encoder[Greeting] =
      g => Json.obj("message" := g.greeting)
    implicit def greetingEntityEncoder[F[_]]: EntityEncoder[F, Greeting] =
      jsonEncoderOf[F, Greeting]

  def impl[F[_]: Applicative]: HelloWorld[F] =
    name => Greeting(com.example.hello.HelloWorld.greet(name)).pure[F]
