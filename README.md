# iniplus

An INI parser written in Nim with support for arrays. It's intended to be as performant as std/parsecfg but with a couple of nice-to-have features.

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

## How to use

TODO. Documentation.

To use iniplus, you can import the entire library *or* only the features you want.
```nim

# Imports the entire library
import iniplus

# Import writing feature only
import iniplus/writer

# Import data-retrieving functions only
import iniplus/retrieve

# Import config parser only
import iniplus/reader

# Import type definitions only
import iniplus/objects
```

*Note*: `iniplus/objects` will nearly always be imported no matter what since it has the actual type definitions for the config tables and config values

To read a config file, you can do the following:
```nim
import iniplus

let table = parseFile("config_file.conf")
# OR, to read a string as a config table.
let table = parseString("name = \"John Doe\"")
```
You can then retrieve various data types.

```nim
assert table.getString("", "name") == "John Doe"

# This functions sees if a specified key is available, if it is then it returns it.
# If not then it returns whatever you have specified in the third parameter
assert table.getStringOrDefault("config","thing","..") == ".."
```

## Copyright 

Copyright (c) penguinite 2023 <penguinite@proton.me>
Licensed under the BSD 3-Clause license.
