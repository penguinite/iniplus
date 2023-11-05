# iniplus

An extended INI parser for Nim. Intended to be as performant as `std/parsecfg` whilst being nearly as flexible with data types as TOML.

## Features

1. iniplus does not support triple quoted string literals or raw string literals like `std/parsecfg` does.
2. iniplus does not support nesting of sections.
3. iniplus supports tables consisting of strings and all supported data types.
4. iniplus supports arrays/sequences consisting of all supported data types.
5. iniplus supports timestamps when they are enclosed in a string (Format: `yyyy-MM-dd'T'HH:mm:sszzz`)

## Status

Reading and writing files is working, all data types except for arrays and tables are supported. Helper functions for retrieving data is available.

## Copyright 

Copyright (c) systemonia 2023 <systemonia@proton.me>
Licensed under the BSD 3-Clause license.