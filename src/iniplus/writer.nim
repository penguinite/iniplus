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

func toString*(val: ConfigValue): string =
  ## Converts a single, individual configuration value into a loadable, human-readable string.
  runnableExamples:
    import iniplus
    let value = newCValue("John")
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

func `$`*(value: ConfigValue): string =
  ## Shorthand for `toString(value)`
  runnableExamples:
    import iniplus
    let value = newCValue("John")

    echo toString(value)
  toString(value)

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

func `$`*(table: ConfigTable): string =
  ## Shorthand for `toString(table)`
  runnableExamples:
    import iniplus
    let config = parseString("test_key=\"Hello\"")

    echo toString(config)
  toString(table)

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
  ConfigTable()

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

func setKeys*(table: var ConfigTable, data: openArray[(string, Table[string, ConfigValue])]) =
  ## The newer, better way to bulk set a bunch of keys in a config table.
  ## 
  ## If you want to return a table rather than mutate it then use the createTable func
  ## which uses the exact same format.
  runnableExamples:
    import iniplus
    var table = newConfigTable()
    var values = {
      "company": {
        "name": @= "Acme Products Ltd.",
        "founding_year": @= 2020,
        "defunct": @= false
      }.toTable
    }
    table.setKeys(values)

    assert table.getString("company", "name") == "Acme Products Ltd."
    assert table.getInt("company", "founding_year") == 2020
    assert table.getBool("company", "defunct") == false
  for section, list in data.items:
    for key, item in list.pairs:
      table[(section, key)] = item

func createTable*(data: openArray[(string, Table[string, ConfigValue])]): ConfigTable =
  ## Allows you to create a configuration table and set a bunch of its keys.
  ## This uses the exact same syntax as setKeys()
  runnableExamples:
    import iniplus
    var table = createTable(
      {
        "company": {
          "name": @= "Acme Products Ltd.",
          "founding_year": @= 2020,
          "defunct": @= false
        }.toTable
      }
    )

    assert table.getString("company", "name") == "Acme Products Ltd."
    assert table.getInt("company", "founding_year") == 2020
    assert table.getBool("company", "defunct") == false
  for section, list in data.items:
    for key, item in list.pairs:
      result[(section, key)] = item