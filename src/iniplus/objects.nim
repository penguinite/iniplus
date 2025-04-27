# Copyright (c) penguinite 2023 <penguinite@proton.me>
# Licensed under the BSD-3-Clause license
##
## This module provides the type definitions that are the foundation of this library.
## And also some helper functions for constructing those types.
## 
## You probably won't be using this unless you are writing something really low-level
## And also, good luck with that.
import std/[tables, sequtils]
export tables

type
  ## The kind of configuration value we are processing/storing, iniplus only supports Integers, Booleans, Strings and Sequences.
  ConfigValueKind* = enum
    CVNone, CVInt, CVBool, CVString, CVArray, CVTable

  ## This object is the actual configuration value. It's best to use the built-in functions when handling these, if you must implement your own logic at the low-level then always remember to check the `kind` field first.
  ConfigValue* = object
    case kind*: ConfigValueKind
    of CVInt: intVal*: int
    of CVBool: boolVal*: bool
    of CVString: stringVal*: string
    of CVArray: arrayVal*: seq[ConfigValue]
    of CVTable: tableVal*: OrderedTable[string, ConfigValue]
    else: discard
  
  ## Simply a configuration table.
  ConfigTable* = Table[(string, string), ConfigValue]

func newCValue*(value: string): ConfigValue =
  ## Creates a ConfigValue object of the `String` kind
  runnableExamples:
    import iniplus
    let c = parseString("fav_person=\"John\"")
    
    assert c.getValue("","fav_person") == newCValue("John")
  ConfigValue(kind: CVString, stringVal: value)

func newCValue*(value: int): ConfigValue =
  ## Creates a ConfigValue object of the `Int` kind
  runnableExamples:
    import iniplus
    let c = parseString("fav_number=9001")

    assert c.getValue("","fav_number") == newCValue(9001)
  ConfigValue(kind: CVInt, intVal: value)

func newCValue*(value: bool): ConfigValue =
  ## Creates a ConfigValue object of the `Boolean` kind. 
  runnableExamples:
    import iniplus
    let c = parseString("fav_bool=true")

    assert c.getValue("","fav_bool") == newCValue(true)
  ConfigValue(kind: CVBool, boolVal: value)

func newCValue*(value: varargs[ConfigValue]): ConfigValue =
  ## Creates a ConfigValue object of the `Sequence` kind.
  runnableExamples:
    import iniplus
    let
      c = parseString("favorites=[\"John\", \"Katie\", \"Isaac\"]")
      value = newCValue(
        newCValue("John"),
        newCValue("Katie"),
        newCValue("Isaac")
      )
    
    assert c.getArray("","favorites") == value
  ConfigValue(kind: CVArray, arrayVal: value.toSeq)

func newCValue*(value: seq[ConfigValue]): ConfigValue =
  ## Creates a ConfigValue object of the `Sequence` kind.
  ## 
  ## This function is similar to the varargs-based function,
  ## except it takes a sequence of ConfigValue objects as an argument
  runnableExamples:
    import iniplus
    let
      c = parseString("favorites=[\"John\", \"Katie\", true]")
      value = newCValue(
        @[
          newCValue("John"),
          newCValue("Katie"),
          newCValue(true)
        ]
      )
    
    assert c.getArray("","favorites") == value
  ConfigValue(kind: CVArray, arrayVal: value)

func newCValue*[T](val: openArray[T]): ConfigValue =
  ## Creates a ConfigValue object of the `Sequence` kind.
  ## 
  ## This function is similar to the varargs-based function,
  ## except it takes a sequence of ConfigValue objects.
  ## 
  ## It's not possible to mix and match different data types with this procedure.
  ## If you want to mix different data types into your array,
  ## then you must convert each item one-by-one using either varargs or a sequence·
  runnableExamples:
    import iniplus
    let
      c = parseString("my_favorite_people=[\"John\", \"Katie\", \"Mark\"]")
      value = newCValue(
        [
          "John",
          "Katie",
          "Mark"
        ]
      )
    assert c.getArray("","my_favorite_people") == value
  result = ConfigValue(kind: CVArray)
  for i in val:
    result.arrayVal.add(newCValue(i))

func `@=`*[T](val: T): ConfigValue =
  ## Used for bulk-setting configuration options.
  runnableExamples:
    import iniplus
    var values = {
      "company": {
        "name": @= "Acme Products Ltd.",
        "founder": @= "John & Katie",
        "founding_year": @= 2020,
        "defunct": @= false,
        "products": @= @[
          "Acme Product #1",
          "Acme Product #2",
          "Acme Product #3"
        ]
      }.toTable
    }
  newCValue(val)

func `$`*(k: ConfigValueKind): string =
  ## For convering config value types to strings.
  result = case k:
    of CVString: "string"
    of CVArray: "array"
    of CVTable: "table"
    of CVInt: "integer"
    of CVNone: "none"
    of CVBool: "boolean"