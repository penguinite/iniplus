# Copyright (c) penguinite 2023 <penguinite@proton.me>
# Licensed under the BSD-3-Clause license
## This module provides the most commonly-used features and procedures.
## Namely the ability to retrieve data from already-parsed config tables.
## Iniplus only supports 4 types:
## 1. Strings contain simple single-line strings.
## 2. Integers contain simple single-line integers.
## 3. Booleans contain simple single-line boolean.
## 4. Arrays contain a multi-line or single-line array that can consist of any combination of the above three types.
##
## Arrays, due to their flexibility, get retrieved as `seq[ConfigValue]`, which may be difficult to process.
## Thankfully, iniplus also provides a couple of procedures to get arrays that consist of only one value type. (`getStringArray`, `getIntArray`, `getBoolArray`)
## These procedures will throw out anything that doesn't fit the type.
import objects
import std/[tables, times, strutils]
export tables, times

proc raiseValueError(kind: ConfigValueKind, section, key: string) = raise (ref ValueError)(msg: "key \"" & key & "\" in section \"" & section & "\" has wrong type (" & $kind & ")")
proc raiseIndexDefect(section, key: string) = raise (ref IndexDefect)(msg: "key \"" & key & "\" in section \"" & section & "\" does not exist")

proc exists*(table: ConfigTable, section, key: string): bool =
  ## Simply detects if a given key inside of a given section exists.
  ## Returns true if it does, false if it doesn't.
  runnableExamples:
    import iniplus
    let config = parseString("name = \"John Doe\"")
    assert config.exists("","name") == true
    
    # This isn't in the config file, so it's false.
    assert config.exists("","age") == false
  if table.hasKey((section, key)):
    return true
  return false

proc getValue*(table: ConfigTable, section, key: string): ConfigValue =
  ## Returns a pure ConfigValue object, typically this is only used for low-level retrieval.
  runnableExamples:
    import iniplus
    let config = parseString("name = \"John Doe\"")
    assert config.getValue("","name").kind == CVString
    assert config.getValue("","name").stringVal == "John Doe"

  if not table.exists(section, key):
    raiseIndexDefect(section, key)

  return table[(section, key)]

proc getString*(table: ConfigTable, section, key: string): string =
  ## Returns a string from a table with the specified section and key.
  runnableExamples:
    import iniplus
    let config = parseString("""
    [dialog]
    info_text = "Insert some informational text here."
    """)
    assert config.getString("dialog","info_text") == "Insert some informational text here."
  let val = table.getValue(section, key)
  if val.kind != CVString:
    raiseValueError(val.kind, section, key)
  return val.stringVal

proc getStringOrDefault*(table: ConfigTable, section, key, default: string): string =
  ## Returns a string from a table with the specified section and key, *or* if the key does
  ## not exist, it returns whatever the third parameter `default` has been set to.
  runnableExamples:
    import iniplus
    let config = parseString("""
    [dialog]
    info = "Informational text"
    """)
    # Since the first example is in the config file, it gets returned.
    assert config.getStringOrDefault("dialog","info","") == "Informational text"
    # This is not in the config file, so the procedure returns the `default` parameter.
    assert config.getStringOrDefault("dialog","help","Helpful text") == "Helpful text"

  if not table.exists(section, key):
    return default
  return table.getString(section, key)

proc getBool*(table: ConfigTable, section, key: string): bool =
  ## Returns a boolean from a table with the specified section and key.
  runnableExamples:
    import iniplus
    let config = parseString("enable_feature = true")
    assert config.getBool("","enable_feature") == true
  let val = table.getValue(section, key)
  case val.kind:
  of CVString: result = parseBool(val.stringVal)
  of CVBool: result = val.boolVal
  else: raiseValueError(val.kind, section, key)

proc getBoolOrDefault*(config: ConfigTable, section, key: string, default: bool): bool =
  ## Either returns the provided boolean in a table or a default value.
  runnableExamples:
    import iniplus
    let table = parseString("enabled = false")
    assert table.getBoolOrDefault("", "enabled", false) == false
    assert table.getBoolOrDefault("", "enabled", true) == false

    let table2 = parseString("")
    assert table2.getBoolOrDefault("", "enabled", false) == false
    assert table2.getBoolOrDefault("", "enabled", true) == true
  if config.exists(section, key):
    return config.getBool(section, key)
  return default

proc getInt*(table: ConfigTable, section, key: string): int =
  ## Returns an integer from a table with the specified section and key.
  runnableExamples:
    import iniplus
    let config = parseString("port = 8080")
    assert config.getInt("","port") == 8080

  let val = table.getValue(section, key)
  case val.kind:
  of CVString: result = parseInt(val.stringVal)
  of CVInt: result = val.intVal
  else: raiseValueError(val.kind, section, key)

proc getIntOrDefault*(config: ConfigTable, section, key: string, default: int): int =
  ## Either returns the provided integer in a table or a default value.
  runnableExamples:
    import iniplus
    let table = parseString("port = 1000")
    assert table.getIntOrDefault("", "port", 1000) == 1000
    assert table.getIntOrDefault("", "port", 1010) == 1000

    let table2 = parseString("")
    assert table2.getIntOrDefault("", "port", 1000) == 1000
    assert table2.getIntOrDefault("", "port", 1010) == 1010
  if config.exists(section, key):
    return config.getInt(section, key)
  return default

proc getArray*(table: ConfigTable, section, key: string): seq[ConfigValue] =
  ## Returns an array containing a set of ConfigValue objects from a table with the specified section and key.
  runnableExamples:
    import iniplus
    let
      config = parseString("employees = [\"John\",\"Katie\",1000]")
      employees = config.getArray("","employees")

    assert employees[0].kind == CVString
    assert employees[1].kind == CVString
    assert employees[2].kind == CVInt

    assert employees[0].stringVal == "John"
    assert employees[1].stringVal == "Katie"
    assert employees[2].intVal == 1000
  let val = table.getValue(section, key)
  if val.kind != CVArray:
    raiseValueError(val.kind, section, key)
  return val.arrayVal

proc getStringArray*(table: ConfigTable, section, key: string): seq[string] =
  ## This procedure retrieves a string-only array from a table. It also throws out any non-string items
  runnableExamples:
    import iniplus
    let
      config = parseString("employees = [\"John\",\"Katie\",1000]")
      employees = config.getStringArray("","employees")
    
    assert employees[0] == "John"
    assert employees[1] == "Katie"
    assert len(employees) == 2
    
  let val = table.getValue(section, key)
  if val.kind != CVArray:
    raiseValueError(val.kind, section, key)
  for item in val.arrayVal:
    if item.kind == CVString: result.add(item.stringVal)
  return result

proc getStringArrayOrDefault*(config: ConfigTable, section, key: string, default: seq[string]): seq[string] =
  ## Either returns the provided string array in a table or a default value.
  runnableExamples:
    import iniplus
    let table = parseString("users = [\"Kate\", \"John\", \"Alex\"]")
    assert table.getStringArrayOrDefault("", "users", @["Kate", "John", "Alex"]) == @["Kate", "John", "Alex"]
    assert table.getStringArrayOrDefault("", "users", @[]) == @["Kate", "John", "Alex"]

    let table2 = parseString("")
    assert table2.getStringArrayOrDefault("", "users", @["John"]) == @["John"]
    assert table2.getStringArrayOrDefault("", "users", @[]) == @[]
  if config.exists(section, key):
    return config.getStringArray(section, key)
  return default

proc getIntArray*(table: ConfigTable, section, key: string): seq[int] =
  ## This procedure retrieves a integer-only array from a table. It also throws out any non-integer items
  runnableExamples:
    import iniplus
    let
      config = parseString("numbers = [1000, 2000, \"Michael\"]")
      number = config.getIntArray("","numbers")

    assert number[0] == 1000
    assert number[1] == 2000
    assert len(number) == 2

  let val = table.getValue(section, key)
  if val.kind != CVArray:
    raiseValueError(val.kind, section, key)
  for item in val.arrayVal:
    if item.kind == CVInt: result.add(item.intVal)
  return result

proc getBoolArray*(table: ConfigTable, section, key: string): seq[bool] =
  ## This procedure retrieves a boolean-only array from a table. It also throws out any non-boolean items
  runnableExamples:
    import iniplus 
    let
      config = parseString("[my_favorite]\nbooleans=[true, \"Jimmy\", false]")
      myFavoriteBooleans = config.getBoolArray("my_favorite","booleans")
    
    assert myFavoriteBooleans[0] == true
    assert myFavoriteBooleans[1] == false
    assert len(myFavoriteBooleans) == 2
  let val = table.getValue(section, key)
  if val.kind != CVArray:
    raiseValueError(val.kind, section, key)
  for item in val.arrayVal:
    if item.kind == CVBool: result.add(item.boolVal)
  return result

# No... I am not gonna make a getArrayArray()

proc getTable*(table: ConfigTable, section, key: string): OrderedTable[string, ConfigValue] =
  ## Returns a table from a configuration table with the specified section and key.
  runnableExamples:
    import iniplus
    let config = parseString("names_and_age = {\"John\": 21, \"Kate\": 22}")
    assert config.getTable("","names_and_age").len() == 2
  let val = table.getValue(section, key)
  if val.kind != CVTable:
    raiseValueError(val.kind, section, key)
  return val.tableVal

proc getStringTable*(table: ConfigTable, section, key: string): OrderedTable[string, string] =
  ## Returns a string-only table from a configuration table with the specified section and key.
  runnableExamples:
    import iniplus
    let config = parseString("names_and_likes = {\"John\": \"Dogs\", \"Kate\": \"Cats\"}")
    assert config.getTable("","names_and_likes").len() == 2
  let val = table.getValue(section, key)
  if val.kind != CVTable:
    raiseValueError(val.kind, section, key)
  
  for key,val2 in val.tableVal.pairs:
    if val2.kind == CVString:
      result[key] = val2.stringVal
  return result

proc getBoolTable*(table: ConfigTable, section, key: string): OrderedTable[string, bool] =
  ## Returns a boolean-only table from a configuration table with the specified section and key.
  runnableExamples:
    import iniplus
    let config = parseString("names_and_adopted = {\"John\": true, \"Kate\": false}")
    assert config.getTable("","names_and_adopted").len() == 2
  let val = table.getValue(section, key)
  if val.kind != CVTable:
    raiseValueError(val.kind, section, key)
  
  for key,val2 in val.tableVal.pairs:
    if val2.kind == CVBool:
      result[key] = val2.boolVal
  return result

proc getIntTable*(table: ConfigTable, section, key: string): OrderedTable[string, int] =
  ## Returns a integer-only table from a configuration table with the specified section and key.
  runnableExamples:
    import iniplus
    let config = parseString("names_and_age = {\"John\": 21, \"Kate\": 22}")
    assert config.getTable("","names_and_age").len() == 2
  let val = table.getValue(section, key)
  if val.kind != CVTable:
    raiseValueError(val.kind, section, key)
  
  for key,val2 in val.tableVal.pairs:
    if val2.kind == CVInt:
      result[key] = val2.intVal
  return result