# Copyright (c) systemonia 2023 <systemonia@proton.me>
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
  ## Converts a configuration value into a loadable, human-readable string.
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
  ## Converts a configuration table into a loadable, human-readable string.
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
  result = create(objects.String)
  result.stringVal = value

proc newValue*(value: int): ConfigValue =
  result = create(objects.Int)
  result.intVal = value

proc newValue*(value: bool): ConfigValue =
  result = create(objects.Bool)
  result.boolVal = value

proc newValue*(value: seq[ConfigValue]): ConfigValue =
  result = create(objects.Sequence)
  result.sequence = value

proc newValue*(value: varargs[ConfigValue]): ConfigValue =
  result = create(objects.Sequence)
  var i: seq[ConfigValue] = @[]
  for x in value:
    i.add(x)
  result.sequence = i

proc newConfigTable*(): ConfigTable =
  ## Simply returns a new, empty, ConfigTable object.
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

    assert table.getArray("multi","list")[0] == "Hello World!"
    assert table.getArray("multi","list")[1] == 1000

  table[section & '|' & key] = convertValue(value)

proc writeToFile*(filename: string, table: ConfigTable): bool =
  try:
    writeFile(filename,toString(table))
    return true
  except:
    return false