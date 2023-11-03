# Copyright (c) systemonia 2023 <systemonia@proton.me>
# Licensed under the BSD-3-Clause license

import tables
export tables

type
  ConfigValueType* = enum
    None, Int, Bool, String, Sequence, Table
  
  ConfigValue* = object of RootObj
    case kind*: ConfigValueType
    of None: nil
    of Int: intVal*: int
    of Bool: boolVal*: bool
    of String: stringVal*: string
    of Sequence: sequence*: seq[ConfigValue]
    of Table: table*: OrderedTable[string, ConfigValue]

  ConfigTable* = OrderedTable[string, ConfigValue]

  ConfigParserMode* = enum
    None, Section, Key, PreValue, Single, Multi
