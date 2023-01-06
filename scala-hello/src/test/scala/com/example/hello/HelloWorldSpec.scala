package com.example.hello

import munit.FunSuite

class HelloWorldSpec extends FunSuite:
  test("Say hello to someone") {
    assertEquals(
      HelloWorld.greet("someone"),
      "Hello, someone!",
    )
  }
