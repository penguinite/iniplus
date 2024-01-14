# Copyright (c) penguinite 2023 <penguinite@proton.me>
# Licensed under the BSD-3-Clause license
## This module contains functions for writing config files or converting config
## tables to string representations that are human-readable, loadable or both.
import objects
import std/strutils
export objects

proc dump*(table: ConfigTable): string =
  ## Converts a config table into a human-readable format similar to JSON.
  ## This should only ever be used for debugging, if you want to convert a config
  ## table to a string you can load again then use the `toString()` procedure.
  runnableExamples:
    let config = parseString("test_key=\"String\"")
    echo dump(config)

  for key,val in table.pairs:
    let list = key.split('|')
    result.add("\t")
    if list[0] != "":
      result.add("[" & list[0] & "] ") # Section
    result.add("\"" & list[1] & "\": ") # Key
    result.add($val & "\n") # Value
  result = result[0..^2] # Remove last newline char
  return "{\n" & result & "\n}" # Add curly brackets

proc toString*(val: ConfigValue): string =
  ## Converts a single, individual configuration value into a loadable, human-readable string.
  runnableExamples:
    let value = newValue("John")
    echo toString(config)
  case val.kind:
  of CVNone: return ""
  of CVString: result = "\"" & val.stringVal & "\""
  of CVInt: result = $(val.intVal)
  of CVBool: result = $(val.boolVal)
  of CVSequence:
    result = ""
    if len(val.sequenceVal) > 0:
      for item in val.sequenceVal:
        result.add("\t" & toString(item) & ",\n")
      result = "\n" & result[0..^2] & "\n"
    result = "[" & result & "]"
  return result

proc toString*(table: ConfigTable): string =
  ## Converts a whole configuration table into a loadable, human-readable string.
  runnableExamples:
    let config = parseString("test_key=\"Hello\"")

    assert toString(config).startsWith("test_key=\"Hello\"")
  var
    tmpTable: Table[string, string]

  for tmp,val in table.pairs:
    let
      list = tmp.split('|')
      section = list[0] 
      key = list[1]

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

proc newValue*(value: string): ConfigValue =
  ## Creates an individual string ConfigValue object.
  # This example cannot be ran due to its dependence on functions elsewhere.
  # It would create a circular dependency
  runnableExamples "--run:off":
    let
      config = parseString("favorite_person_number_one=\"John\"")
      value = newValue("John")
    
    assert config.getValue("","favorite_person_number_one").stringVal == value.stringVal
  result = ConfigValue(kind: CVString)
  result.stringVal = value

proc newValue*(value: int): ConfigValue =
  # This example cannot be ran due to its dependence on functions elsewhere.
  # It would create a circular dependency
  runnableExamples "--run:off":
    let
      config = parseString("favorite_number=9001")
      value = newValue(9001)
    
    assert config.getValue("","favorite_number").intVal == value.intVal
  result = ConfigValue(kind: CVInt)
  result.intVal = value

proc newValue*(value: bool): ConfigValue =
  # This example cannot be ran due to its dependence on functions elsewhere.
  # It would create a circular dependency
  runnableExamples "--run:off":
    let
      config = parseString("favorite_boolean=true")
      value = newValue(true)

    assert config.getValue("","favorite_boolean").boolVal == value.boolVal
  result = ConfigValue(kind: CVBool)
  result.boolVal = value

proc newValue*(value: seq[ConfigValue]): ConfigValue =
  ## Creates a Sequence-like ConfigValue object. This function is similar to the varargs-based function, except it takes a sequence of ConfigValue objects.
  # This example cannot be ran due to its dependence on functions elsewhere.
  # It would create a circular dependency
  runnableExamples "--run:off":
    let
      config = parseString["my_favorite_people=[\"John\", \"Katie\", true]"]
      value = newValue(@[
          newValue("John"),
          newValue("Katie"),
          newValue(true)
        ]
      )

    # Yes, this is a mess. Just use the regular getArray() procedure if you want an easier time dealing with arrays.
    assert config.getValue("","my_favorite_people").sequenceVal[0].stringVal == value.sequenceVal[0].stringVal
    assert config.getValue("","my_favorite_people").sequenceVal[1].stringVal == value.sequenceVal[1].stringVal
    assert config.getValue("","my_favorite_people").sequenceVal[2].boolVal == value.sequenceVal[2].boolVal
  result = ConfigValue(kind: CVSequence)
  result.sequenceVal = value

proc newValue*(value: varargs[ConfigValue]): ConfigValue =
  ## Creates a Sequence-like ConfigValue object.
  # This example cannot be ran due to its dependence on functions elsewhere.
  # It would create a circular dependency
  runnableExamples "--run:off":
    let
      config = parseString("my_favorite_people=[\"John\", \"Katie\", true]")
      value = newValue(
        newValue("John"),
        newValue("Katie"),
        newValue(true)
      )
    
    # Yes, this is a mess. Just use the regular getArray() procedure if you want an easier time dealing with arrays.
    assert config.getValue("","my_favorite_people").sequenceVal[0].stringVal == value.sequenceVal[0].stringVal
    assert config.getValue("","my_favorite_people").sequenceVal[1].stringVal == value.sequenceVal[1].stringVal
    assert config.getValue("","my_favorite_people").sequenceVal[2].boolVal == value.sequenceVal[2].boolVal
  result = ConfigValue(kind: CVSequence)
  var i: seq[ConfigValue] = @[]
  for x in value:
    i.add(x)
  result.sequenceVal = i

proc newConfigTable*(): ConfigTable =
  ## Simply returns a new, empty, ConfigTable object.
  runnableExamples:
    let
      tableA = newConfigTable()
      tableB = ConfigTable()
    
    assert tableA == tableB
  return result

proc setKey*(table: var ConfigTable, section, key: string, value: ConfigValue) =
  ## Changes a key of a section inside of a table to a specific value
  # This example cannot be ran due to its dependence on functions elsewhere.
  # It would create a circular dependency
  runnableExamples "--run:off":
    var
      table = newConfigTable()
      # Creates a String ConfigValue object
      valueStr = newValue("Hello World!")
      # Creates a Sequence ConfigValue object
      valueArr = newValue(
        newValue("Hello World!"),
        newValue(1000)
      )

    # Inserting a handmade string into a table
    table.setKey("handmade","quote",valueStr)
    assert table.getString("handmade","quote") == "Hello World!"

    # Inserting a handmade array into a table
    table.setKey("handmade","list",valueArr)
    assert table.getArray("handmade", "list")[0].stringVal == "Hello World!"
    assert table.getArray("handmade", "list")[1].intVal == 1000

  table[section & '|' & key] = value

proc setKeySingleVal*(table: var ConfigTable, section, key: string, value: string) =
  ## Sets a value in a table to a single value (string, bool or int)
  # This example cannot be ran due to its dependence on functions elsewhere.
  # It would create a circular dependency
  runnableExamples "--run:off":
    var table = newConfigTable()

    table.setKeySingleVal("single","number","1000")
    table.setKeySingleVal("single","quote","\"Hello World!\"")
    table.setKeySingleVal("single","true_false","false")

    assert table.getString("single","quote") == "Hello World!"
    assert table.getInt("single","number") == 1000
    assert table.getBool("single", "true_false") == false

  table[section & '|' & key] = convertValue(value)

proc setKeyMultiVal*(table: var ConfigTable, section, key: string, value: string) =
  ## Sets a value in a table to a multi value (array)
  runnableExamples "--run:off":
    var table = newTable()

    table.setKeyMultiVal("multi","list","[\"Hello World!\",1000]")

    assert table.getArray("multi","list")[0].stringVal == "Hello World!"
    assert table.getArray("multi","list")[1].intVal == 1000

  table[section & '|' & key] = convertValue(value)

template semiCondense(section, key: string, value: untyped): untyped {.dirty.} = 
  result.section = section
  result.key = key
  result.value = newValue(value)

proc setBulkKeys*(table: var ConfigTable, vals: varargs[CondensedConfigValue]) =
  ## Allows you to set multiple keys, similar to how std/json's % macro does.
  ## But with procedures instead! Since I don't know meta-programming
  ## the `c` proc is neccessary, I tried also using the `%` for it but it didn't work for some reason.
  runnableExamples "--run:off":
    var table = ConfigTable()
    table.setBulkKeys(
      c("hello","world","!"), # Strings
      c("goodbye","world","!"), # Strings^2
      c("favorite","people", %("John"), %("Katie"), %(true)), # Sequences
      c("favorite","number", 9001), # Numbers
      c("favorite","boolean",true), # Booleans
    )

    assert table.getString("hello","world") == "!"
    assert table.getString("goodbye","world") == "!"
    assert table.getArray("favorite","people")[0].stringVal == "John"
    assert table.getArray("favorite","people")[1].stringVal == "Katie"
    assert table.getArray("favorite","people")[2].boolVal == true
    assert table.getInt("favorite", "number") == 9001
    assert table.getBool("favorite", "boolean") == true
  for val in vals:
    table.setKey(val.section, val.key, val.value)

proc c*(section,key: string, value: bool): CondensedConfigValue = semiCondense(section, key, value)
proc c*(section,key: string, value: string): CondensedConfigValue = semiCondense(section, key, value)
proc c*(section,key: string, value: int): CondensedConfigValue = semiCondense(section, key, value)
proc c*(section,key: string, value: seq[ConfigValue]): CondensedConfigValue = semiCondense(section, key, value)
proc c*(section,key: string, value: varargs[ConfigValue]): CondensedConfigValue = semiCondense(section, key, value)
proc `%`*(value: string): ConfigValue =
  ## Shorthand for newValue(value), useful for when you have to use setBulkKeys
  newValue(value)
proc `%`*(value: seq[ConfigValue]): ConfigValue =
  ## Shorthand for newValue(value), useful for when you have to use setBulkKeys
  newValue(value)
proc `%`*(value: int): ConfigValue =
  ## Shorthand for newValue(value), useful for when you have to use setBulkKeys
  newValue(value)
proc `%`*(value: bool): ConfigValue =
  ## Shorthand for newValue(value), useful for when you have to use setBulkKeys
  newValue(value)

proc writeToFile*(filename: string, table: ConfigTable): bool =
  try:
    writeFile(filename,toString(table))
    return true
  except:
    return false