# Package

version       = "0.1.0"
author        = "systemonia"
description   = "An extended INI parser for Nim."
license       = "BSD-3-Clause"
srcDir        = "src"

# Figure out how to work around this issue without relying
# on a slowly-deprecating switch.
switch("define","nimOldCaseObjects")
# Dependencies

requires "nim >= 2.0.0"
