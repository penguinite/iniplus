# iniplus

An INI parser written in Nim with support for extra datatypes such as arrays and tables. It's intended to be as performant as std/parsecfg but with a way friendly interface and design.

Documentation can be found [here](https://penguinite.github.io/iniplus/), you can also build the documentation locally by running `nimble docs` if you clone this repository

## Features/Drawbacks

1. iniplus does not support triple quoted string literals or raw string literals like `std/parsecfg` does.
2. iniplus does not support nesting sections.
3. iniplus supports arrays/sequences consisting of all supported data types. (Except for tables)
4. iniplus supports tables consisting of strings, integers or booleans. But it does **not** support nested tables or arrays inside tables.
5. Mixing arrays and tables are a terrible idea. Don't do it.

## Status

Everything has been implemented, here is a short list of all the available features we have:

1. The config file parser has been implemented.
2. There are functions to retrieve data from config files.
3. There are also functions to dump/convert a table into plain-text (Which can then be loaded again, convenient for saving tables you've modified. Be aware that saving config files will not save the comments associated with them.)
4. And there are functions to write data into and modify config tables.

Please create a new issue if there are any bugs or anything. The config file parser has been recently re-written and may have some edge cases that aren't yet accounted for, so please report an issue if it there is one.

It shouldn't crash when encountering unknown data, but if it does, then please report it and thank you. This library *has* been rigorously tested and has a comprehensive test suite but still, there might be edge cases.

## Copyright 

Copyright (c) penguinite 2023-2024 <penguinite@tuta.io>
Licensed under the BSD 3-Clause license.
