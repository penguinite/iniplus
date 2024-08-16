# iniplus

An INI parser written in Nim with support for arrays and tables. It's intended to be as performant as std/parsecfg but with a way nicer interface and design.

Documentation can be found [here](https://penguinite.github.io/iniplus/), you can also build it locally by running `nim doc --project src/iniplus.nim` if you clone this repository

## Features/Drawbacks

1. iniplus does not support triple quoted string literals or raw string literals like `std/parsecfg` does.
2. iniplus does not support nesting of sections.
3. iniplus supports arrays/sequences consisting of all supported data types. (Except for tables)
4. iniplus supports tables consistig of strings, integers or booleans. But it does **not** support nested tables or arrays inside tables.
5. Mixing arrays and tables are a terrible idea. Don't do it.

## Status

Everything has been implemented, here is a short list of all the available features we have:

1. The config file parser has been implemented.
2. There are functions to retrieve data from config files.
3. There are also functions to dump/convert a table into plain-text
4. And there are functions to write data into a config table. (Not files)

Please create a new issue if there are any bugs or anything. The config file parser has been recently re-written and may have some edge cases that aren't yet accounted for, so please report an issue if it there is one.

It shouldn't crash when encountering unknown data, but if it does, then please report it and thank you. This library *has* been rigorously tested and has a comprehensive 

## Copyright 

Copyright (c) penguinite 2023-2024 <penguinite@tuta.io>
Licensed under the BSD 3-Clause license.
