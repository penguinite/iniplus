# Copyright (c) penguinite 2023 <penguinite@proton.me>
# Licensed under the BSD-3-Clause license
## This module contains functions for writing config files or converting config
## tables to string representations that are human-readable, loadable or both.
## It also provides the ability to set multiple keys with one procedure.
import objects, std/strutils
export objects

proc dump*(table: ConfigTable): string =
  ## Converts a config table into a human-readable format.
  ## This should only ever be used for debugging, the output cannot be loaded or passed onto parseString()
  ## If you want a re-loadable string then use the `toString()` procedure or the dollar sign (`$`)
  runnableExamples:
    import iniplus
    let config = parseString("test_key=\"String\"")
    echo dump(config)

  for key,val in table.pairs:
    result.add("\t")
    if key[0] != "":
      result.add("[" & key[0] & "] ") # Section
    result.add("\"" & key[1] & "\": ") # Key
    result.add($val & "\n") # Value
  if result.len() > 0:
    result = result[0..^2] # Remove last newline char
  return "{\n" & result & "\n}" # Add curly brackets

func escapeQuote(i: string): string =
  for ch in i:
    case ch:
    of '"': result.add("\\\"")
    else: result.add(ch)
  return result

func dumpCommentsNim*(comments: seq[(int, string)]): string =
  ## Converts a comment sequence into loadable Nim code. Useful for writing tests and whatnot.
  ## 
  ## Note: If you want to *load* a file with only comments, then use the parseComments() procedure from reader.nim
  result = "@[\n"
  for comment in comments:
    result.add("  (" & $(comment[0]) & ", \"" & escapeQuote(comment[1]) & "\"),\n")
  result = result[0..^3]
  result.add("\n]")

func toString*(val: ConfigValue): string =
  ## Converts a single, individual configuration value into a loadable, human-readable string.
  runnableExamples:
    import iniplus
    let value = newValue("John")
    echo toString(value)
  case val.kind:
  of CVNone, CVType: return "" # CVNone and CVType don't have string representation.
  of CVString: result = "\"" & val.stringVal & "\""
  of CVInt: result = $(val.intVal)
  of CVBool: result = $(val.boolVal)
  of CVArray:
    result = ""
    if len(val.arrayVal) > 0:
      for item in val.arrayVal:
        result.add("\t" & toString(item) & ",\n")
      result = "\n" & result[0..^2] & "\n"
    result = "[" & result & "]"
  of CVTable:
    result = ""
    if len(val.tableVal) > 0:
      for key,val in val.tableVal.pairs:
        result.add("\t \"" & key & "\": " & toString(val) & ",\n")
      result = "\n" & result[0..^2] & "\n"
    result = "{" & result & "}"
  return result

func `$`*(value: ConfigValue): string =
  ## Shorthand for `toString(value)`
  runnableExamples:
    import iniplus
    let value = newCValue("John")

    echo toString(value)
  return toString(value)

func toString*(table: ConfigTable): string =
  ## Converts a whole configuration table into a string that can be loaded again through parseString().
  runnableExamples:
    import iniplus
    let config = parseString("test_key=\"Hello\"")

    echo toString(config)

  var
    tmpTable: Table[string, string]

  for tmp,val in table.pairs:
    let
      section = tmp[0]
      key = tmp[1]

    # Add section if it doesnt exist.
    if not tmpTable.hasKey(section):
      tmpTable[section] = "$1 = $2\n" % [key, toString(val)]
    else:
      # Or add it to the rest of the section.
      tmpTable[section] = tmpTable[section] & $("$1 = $2\n" % [key, toString(val)])
  
  for key,val in tmpTable.pairs:
    if key != "":
      result.add("\n[" & key & "]\n")
    else:
      result.add("" & key & "\n")
    result.add(val)

  return result

func `$`*(table: ConfigTable): string =
  ## Shorthand for `toString(table)`
  runnableExamples:
    import iniplus
    let config = parseString("test_key=\"Hello\"")

    echo toString(config)

  return toString(table)

func newConfigTable*(): ConfigTable =
  ## Simply returns a new, empty, ConfigTable object.
  runnableExamples:
    import iniplus
    let
      tableA = newConfigTable()
      tableB = parseString("")
    
    assert tableA.len() == tableB.len()
    assert tableA.len() == 0
    assert tableB.len() == 0
  return result

func setKey*[T](table: var ConfigTable, section, key: string, value: T) =
  ## Allows you to set a key of a section in a table to a specific value.
  runnableExamples:
    import iniplus
    var table = newConfigTable()
    ## Here we set key "person" inside section "favorite" to a single string "John"
    table.setKey(
      "favorite", # Section
      "person", # Key
      "John" # Value
    )
    assert table.getString("favorite","person") == "John"

    ## Here we set key "boolean" inside section "favorite" to a single boolean true
    table.setKey(
      "favorite", # Section
      "boolean", # Key
      true # Value
    )
    assert table.getBool("favorite","boolean") == true

  table[(section, key)] = newCValue(value)

func setKey*(table: var ConfigTable, section, key: string, value: ConfigValue) =
  runnableExamples:
    import iniplus
    var
      table = newConfigTable()
      # Creates a String ConfigValue object
      valueStr = newCValue("Hello World!")
      # Creates a Sequence ConfigValue object
      valueArr = newCValue(
        newCValue("Hello World!"),
        newCValue(1000)
      )

    # Inserting a handmade string into a table
    table.setKey("handmade","quote",valueStr)
    assert table.getString("handmade","quote") == "Hello World!"

    # Inserting a handmade array into a table
    table.setKey("handmade","list",valueArr)
    assert table.getArray("handmade", "list")[0].stringVal == "Hello World!"
    assert table.getArray("handmade", "list")[1].intVal == 1000

  table[(section, key)] = value

#! All of the stuff below is deprecated and will be removed soon.

proc newValue*(value: string): ConfigValue
  {.deprecated: "Use newCValue from iniplus/objects".} =
  ## Creates a ConfigValue object of the `String` kind
  runnableExamples:
    import iniplus
    let
      config = parseString("favorite_person_number_one=\"John\"")
      value = newValue("John")
    
    assert config.getValue("","favorite_person_number_one").stringVal == value.stringVal
  return ConfigValue(kind: CVString, stringVal: value)

proc newValue*(value: int): ConfigValue
  {.deprecated: "Use newCValue from iniplus/objects".} =
  ## Creates a ConfigValue object of the `Int` kind
  runnableExamples:
    import iniplus
    let
      config = parseString("favorite_number=9001")
      value = newValue(9001)
    
    assert config.getValue("","favorite_number").intVal == value.intVal
  return ConfigValue(kind: CVInt, intVal: value)

proc newValue*(value: bool): ConfigValue
  {.deprecated: "Use newCValue from iniplus/objects".} =
  ## Creates a ConfigValue object of the `Boolean` kind. 
  runnableExamples:
    import iniplus
    let
      config = parseString("favorite_boolean=true")
      value = newValue(true)

    assert config.getValue("","favorite_boolean").boolVal == value.boolVal
  return ConfigValue(kind: CVBool, boolVal: value)

proc newValue*(value: varargs[ConfigValue]): ConfigValue
  {.deprecated: "Use newCValue from iniplus/objects".} =
  ## Creates a ConfigValue object of the `Sequence` kind.
  runnableExamples:
    import iniplus
    let
      config = parseString("my_favorite_people=[\"John\", \"Katie\", true]")
      value = newValue(
        newValue("John"),
        newValue("Katie"),
        newValue(true)
      )
    
    # Yes, this is a mess. Just use the regular getArray() procedure if you want an easier time dealing with arrays.
    assert config.getValue("","my_favorite_people").arrayVal[0].stringVal == value.arrayVal[0].stringVal
    assert config.getValue("","my_favorite_people").arrayVal[1].stringVal == value.arrayVal[1].stringVal
    assert config.getValue("","my_favorite_people").arrayVal[2].boolVal == value.arrayVal[2].boolVal
  result = ConfigValue(kind: CVArray)
  for x in value:
    result.arrayVal.add(x)
  return result

proc newValue*(value: seq[ConfigValue]): ConfigValue
  {.deprecated: "Use newCValue from iniplus/objects".} =
  ## Creates a ConfigValue object of the `Sequence` kind. This function is similar to the varargs-based function, except it takes a sequence of ConfigValue objects.
  runnableExamples:
    import iniplus
    let
      config = parseString("my_favorite_people=[\"John\", \"Katie\",true]")
      value = newValue(@[
          newValue("John"),
          newValue("Katie"),
          newValue(true)
        ]
      )

    # Yes, this is a mess. Just use the regular getArray() procedure if you want an easier time dealing with arrays.
    assert config.getValue("","my_favorite_people").arrayVal[0].stringVal == value.arrayVal[0].stringVal
    assert config.getValue("","my_favorite_people").arrayVal[1].stringVal == value.arrayVal[1].stringVal
    assert config.getValue("","my_favorite_people").arrayVal[2].boolVal == value.arrayVal[2].boolVal
  return ConfigValue(kind: CVArray, arrayVal: value)

proc newValue*[T](val: seq[T]): ConfigValue
  {.deprecated: "Use newCValue from iniplus/objects".} =
  ## Creates a ConfigValue object of the `Sequence` kind. This function is similar to the varargs-based function, except it takes a sequence of ConfigValue objects.
  ## It's not possible to mix and match different data types with this procedure. Please use the one where you explicitly convert every value instead.
  runnableExamples:
    import iniplus
    let
      config = parseString("my_favorite_people=[\"John\", \"Katie\", \"Mark\"]")
      value = newValue(@[
          "John",
          "Katie",
          "Mark"
        ]
      )

    # Yes, this is a mess. Just use the regular getArray() procedure if you want an easier time dealing with arrays.
    assert config.getValue("","my_favorite_people").arrayVal[0].stringVal == value.arrayVal[0].stringVal
    assert config.getValue("","my_favorite_people").arrayVal[1].stringVal == value.arrayVal[1].stringVal
    assert config.getValue("","my_favorite_people").arrayVal[2].stringVal == value.arrayVal[2].stringVal
  result = ConfigValue(kind: CVArray)
  for i in val:
    result.arrayVal.add(newValue(i))
  return result