# iniplus

An INI parser written in Nim with support for arrays. It's intended to be as performant as std/parsecfg but with a couple of nice-to-have features.

Documentation can be found [here](https://penguinite.github.io/iniplus/), you can also build it locally by running `nim doc --project src/iniplus.nim`

## Features

1. iniplus does not support triple quoted string literals or raw string literals like `std/parsecfg` does.
2. iniplus does not support nesting of sections.
3. iniplus supports arrays/sequences consisting of all supported data types.

## Status

Everything has been implemented, here is a short list of all the available features we have:

1. The config file parser has been implemented.
2. There are functions to retrieve data from config files.
3. There are also functions to dump/convert a table into plain-text
4. And there are functions to write data into a config table. (Not files)

Please create a new issue if there are any bugs or anything. The config file parser is a bit strict and prone to crashing, so please report an issue if it unexpectedly crashes.

## Copyright 

Copyright (c) penguinite 2023 <penguinite@tuta.io>
Licensed under the BSD 3-Clause license.
