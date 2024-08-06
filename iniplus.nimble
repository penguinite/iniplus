# Package

version       = "0.3.0"
author        = "penguinite"
description   = "An INI parser written in Nim. It's main goal is to support more datatypes than std/parsecfg whilst still being just as performant as it."
license       = "BSD-3-Clause"
srcDir        = "src"

# Dependencies

requires "nim >= 2.0.0"

task docs, "Doc generation command":
  exec "nimble doc --index:on --project --git.commit=main --git.devel=main --git.url=\"https://github.com/penguinite/iniplus\" src/iniplus.nim"