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
  ## The kind of configuration value we are processing/storing, iniplus only supports Integers, Booleans, Strings and Sequences. (And I guess None, too.)
  ConfigValueKind* = enum
    CVNone, CVInt, CVBool, CVString, CVArray, CVTable, CVType

  ## This object is the actual configuration value. It's best to use the built-in functions when handling these, if you must implement your own logic at the low-level then always remember to check the `kind` field first.
  ConfigValue* = object
    case kind*: ConfigValueKind
    of CVNone: nil
    of CVInt: intVal*: int
    of CVBool: boolVal*: bool
    of CVString: stringVal*: string
    of CVArray: arrayVal*: seq[ConfigValue]
    of CVTable: tableVal*: OrderedTable[string, ConfigValue]
    of CVType: # used for checkmaps...
      t*: ConfigValueKind
      child_t*: ConfigValueKind
  
  ## Simply a configuration table.
  ConfigTable* = OrderedTable[(string, string), ConfigValue]

proc newCValue*(value: string): ConfigValue =
  ## Creates a ConfigValue object of the `String` kind
  runnableExamples:
    import iniplus
    let
      config = parseString("fav_person=\"John\"")
      value = newCValue("John")
    
    assert config.getValue("","fav_person") == value
  return ConfigValue(kind: CVString, stringVal: value)

proc newCValue*(value: int): ConfigValue =
  ## Creates a ConfigValue object of the `Int` kind
  runnableExamples:
    import iniplus
    let
      config = parseString("fav_number=9001")
      value = newCValue(9001)
    
    assert config.getValue("","fav_number") == value
  return ConfigValue(kind: CVInt, intVal: value)

proc newCValue*(value: bool): ConfigValue =
  ## Creates a ConfigValue object of the `Boolean` kind. 
  runnableExamples:
    import iniplus
    let
      config = parseString("fav_bool=true")
      value = newCValue(true)

    assert config.getValue("","fav_bool") == value
  return ConfigValue(kind: CVBool, boolVal: value)

proc newCValue*(value: varargs[ConfigValue]): ConfigValue =
  ## Creates a ConfigValue object of the `Sequence` kind.
  runnableExamples:
    import iniplus
    let
      config = parseString("favorites=[\"John\", \"Katie\", \"Isaac\"]")
      value = newCValue(
        newCValue("John"),
        newCValue("Katie"),
        newCValue("Isaac")
      )
    
    assert config.getStringArray("","favorites")[0] == value.arrayVal[0]
    assert config.getStringArray("","favorites")[1] == value.arrayVal[1]
    assert config.getStringArray("","favorites")[2] == value.arrayVal[2]
  return ConfigValue(kind: CVArray, arrayVal: value.toSeq)

proc newCValue*(value: seq[ConfigValue]): ConfigValue =
  ## Creates a ConfigValue object of the `Sequence` kind.
  ## 
  ## This function is similar to the varargs-based function,
  ## except it takes a sequence of ConfigValue objects as an argument
  runnableExamples:
    import iniplus
    let
      config = parseString("favorites=[\"John\", \"Katie\", true]")
      value = newValue(
        @[
          newCValue("John"),
          newCValue("Katie"),
          newCValue(true)
        ]
      )
    
    assert config.getArray("","favorites")[0] == value.arrayVal[0]
    assert config.getArray("","favorites")[1] == value.arrayVal[1]
    assert config.getArray("","favorites")[2] == value.arrayVal[2]
  return ConfigValue(kind: CVArray, arrayVal: value)

proc newCValue*[T](val: seq[T]): ConfigValue =
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
      config = parseString("my_favorite_people=[\"John\", \"Katie\", \"Mark\"]")
      value = newCValue(@[
          "John",
          "Katie",
          "Mark"
        ]
      )

    # Yes, this is a mess. Just use the regular getArray() procedure if you want an easier time dealing with arrays.
    assert config.getStringArray("","my_favorite_people")[0] == value.arrayVal[0].stringVal
    assert config.getStringArray("","my_favorite_people")[1] == value.arrayVal[1].stringVal
    assert config.getStringArray("","my_favorite_people")[2] == value.arrayVal[2].stringVal
  result = ConfigValue(kind: CVArray)
  for i in val:
    result.arrayVal.add(newCValue(i))
  return result