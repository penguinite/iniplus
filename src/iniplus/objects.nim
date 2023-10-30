# Copyright (c)
import tables
export tables

type
  ConfigValueType* = enum
    None, Int, Bool, String, Sequence, Table
  
  ConfigValue* = object of RootObj
    kind*: ConfigValueType
    intVal*: int
    boolVal*: bool
    stringVal*: string
    sequence*: seq[ConfigValue]
    table*: OrderedTable[string, ConfigValue]

  ConfigTable* = OrderedTable[string, ConfigValue]

  ConfigParserMode* = enum
    None, Section, Key, PreValue, Value, Sequence, Table