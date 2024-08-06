# Package

version       = "0.2.2"
author        = "penguinite"
description   = "An INI parser written in Nim with support for arrays. It's intended to be as performant as std/parsecfg but with a couple of nice-to-have features."
license       = "BSD-3-Clause"
srcDir        = "src"

# Dependencies

requires "nim >= 2.0.0"

task docs, "Doc generation command":
  exec "nimble doc --index:on --project --git.commit=main --git.devel=main --git.url=\"https://github.com/penguinite/iniplus\" src/iniplus.nim"