# Package

version       = "0.3.3"
author        = "penguinite"
description   = "An INI parser written in Nim. Has more features and datatypes than std/parsecfg while still being just as fast!"
license       = "BSD-3-Clause"
srcDir        = "src"

# Dependencies

requires "nim >= 2.0.0"

task docs, "Doc generation command":
  exec "nimble doc --index:on --project --git.commit=main --git.devel=main --git.url=\"https://github.com/penguinite/iniplus\" src/iniplus.nim"

task docsExp, "Doc generation command (Generates experimental API docs)":
  exec "nimble doc --define:iniplusCheckmaps --index:on --project --git.commit=main --git.devel=main --git.url=\"https://github.com/penguinite/iniplus\" src/iniplus.nim"