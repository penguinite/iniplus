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
import std/[tables, times]
when not defined(iniplusCheckmaps):
  import std/strutils
export tables, times

func raiseValueError(kind: ConfigValueKind, section, key: string) = raise (ref ValueError)(msg: "key \"" & key & "\" in section \"" & section & "\" has wrong type (" & $kind & ")")
func raiseIndexDefect(section, key: string) = raise (ref IndexDefect)(msg: "key \"" & key & "\" in section \"" & section & "\" does not exist")

func exists*(table: ConfigTable, section, key: string): bool =
  ## Simply detects if a given key inside of a given section exists.
  ## Returns true if it does, false if it doesn't.
  runnableExamples:
    import iniplus
    let config = parseString("name = \"John Doe\"")
    assert config.exists("","name") == true
    
    # This isn't in the config file, so it's false.
    assert config.exists("","age") == false
  
  when defined(iniplusCheckmaps):
    # Checks have already been done when the table was parsed.
    # And if the key doesn't exist, then it's the application's fault
    # for not using the feature properly...
    return true 
  else:
    return table.hasKey((section, key))

func getValue*(table: ConfigTable, section, key: string): ConfigValue =
  ## Returns a pure ConfigValue object, typically this is only used for low-level retrieval.
  runnableExamples:
    import iniplus
    let config = parseString("name = \"John Doe\"")
    assert config.getValue("","name").kind == CVString
    assert config.getValue("","name").stringVal == "John Doe"

  when defined(iniplusCheckmaps):
    return table[(section, key)]
  else:
    if not table.exists(section, key):
      raiseIndexDefect(section, key)
    return table[(section, key)]

func getString*(table: ConfigTable, section, key: string): string =
  ## Returns a string from a table with the specified section and key.
  runnableExamples:
    import iniplus
    let config = parseString("""
    [dialog]
    info_text = "Insert some informational text here."
    """)
    assert config.getString("dialog","info_text") == "Insert some informational text here."

  when defined(iniplusCheckmaps):
    return table[(section, key)].stringVal
  else:
    let val = table.getValue(section, key)
    if val.kind != CVString:
      raiseValueError(val.kind, section, key)
    return val.stringVal

func getStringOrDefault*(table: ConfigTable, section, key, default: string): string =
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

  when defined(iniplusCheckmaps):
    # If the application uses checkmaps properly
    # then we can just pass the key as-is
    # if the key didn't exist when parsing
    # then iniplus would have added used its default value.
    return table[(section, key)].stringVal
  else:
    if table.exists(section, key):
      return table.getString(section, key)
    return default

func getBool*(table: ConfigTable, section, key: string): bool =
  ## Returns a boolean from a table with the specified section and key.
  runnableExamples:
    import iniplus
    let config = parseString("enable_feature = true")
    assert config.getBool("","enable_feature") == true
  
  when defined(iniplusCheckmaps):
    return table[(section, key)].boolVal
  else:
    let val = table.getValue(section, key)
    case val.kind:
    of CVString: return parseBool(val.stringVal)
    of CVBool: return val.boolVal
    else: raiseValueError(val.kind, section, key)

func getBoolOrDefault*(table: ConfigTable, section, key: string, default: bool): bool =
  ## Either returns the provided boolean in a table or a default value.
  runnableExamples:
    import iniplus
    let table = parseString("enabled = false")
    assert table.getBoolOrDefault("", "enabled", false) == false
    assert table.getBoolOrDefault("", "enabled", true) == false

    let table2 = parseString("")
    assert table2.getBoolOrDefault("", "enabled", false) == false
    assert table2.getBoolOrDefault("", "enabled", true) == true
  
  when defined(iniplusCheckmaps):
    return table[(section, key)].boolVal
  else:
    if table.exists(section, key):
      return table.getBool(section, key)
    return default

func getInt*(table: ConfigTable, section, key: string): int =
  ## Returns an integer from a table with the specified section and key.
  runnableExamples:
    import iniplus
    let config = parseString("port = 8080")
    assert config.getInt("","port") == 8080

  when defined(iniplusCheckmaps):
    return table[(section, key)].intVal
  else:
    let val = table.getValue(section, key)
    case val.kind:
    of CVString: return parseInt(val.stringVal)
    of CVInt: return val.intVal
    else: raiseValueError(val.kind, section, key)

func getIntOrDefault*(table: ConfigTable, section, key: string, default: int): int =
  ## Either returns the provided integer in a table or a default value.
  runnableExamples:
    import iniplus
    let table = parseString("port = 1000")
    assert table.getIntOrDefault("", "port", 1000) == 1000
    assert table.getIntOrDefault("", "port", 1010) == 1000

    let table2 = parseString("")
    assert table2.getIntOrDefault("", "port", 1000) == 1000
    assert table2.getIntOrDefault("", "port", 1010) == 1010
  when defined(iniplusCheckmaps):
    return table[(section, key)].intVal
  else:
    if table.exists(section, key):
      return table.getInt(section, key)
    return default

func getArray*(table: ConfigTable, section, key: string): seq[ConfigValue] =
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
  
  when defined(iniplusCheckmaps):
    return table[(section, key)].arrayVal
  else:
    let val = table.getValue(section, key)
    if val.kind != CVArray:
      raiseValueError(val.kind, section, key)
    return val.arrayVal

func getStringArray*(table: ConfigTable, section, key: string): seq[string] =
  ## This procedure retrieves a string-only array from a table. It also throws out any non-string items
  runnableExamples:
    import iniplus
    let
      config = parseString("employees = [\"John\",\"Katie\",1000]")
      employees = config.getStringArray("","employees")
    
    assert employees[0] == "John"
    assert employees[1] == "Katie"
    assert len(employees) == 2

  when defined(iniplusCheckmaps):
    for i in table[(section, key)].arrayVal:
      case i.kind:
      of CVString: result.add(i.stringVal)
      else: discard
    return result
  else:
    for i in table.getArray(section, key):
      case i.kind:
      of CVString: result.add(i.stringVal)
      else: discard
    return result

func getStringArrayOrDefault*(table: ConfigTable, section, key: string, default: seq[string]): seq[string] =
  ## Either returns the provided string array in a table or a default value.
  runnableExamples:
    import iniplus
    let table = parseString("users = [\"Kate\", \"John\", \"Alex\"]")
    assert table.getStringArrayOrDefault("", "users", @["Kate", "John", "Alex"]) == @["Kate", "John", "Alex"]
    assert table.getStringArrayOrDefault("", "users", @[]) == @["Kate", "John", "Alex"]

    let table2 = parseString("")
    assert table2.getStringArrayOrDefault("", "users", @["John"]) == @["John"]
    assert table2.getStringArrayOrDefault("", "users", @[]) == @[]
  
  when defined(iniplusCheckmaps):
    return table.getStringArray(section, key)
  else:
    if table.exists(section, key):
      return table.getStringArray(section, key)
    return default

func getIntArray*(table: ConfigTable, section, key: string): seq[int] =
  ## This procedure retrieves a integer-only array from a table. It also throws out any non-integer items
  runnableExamples:
    import iniplus
    let
      config = parseString("numbers = [1000, 2000, \"Michael\"]")
      number = config.getIntArray("","numbers")

    assert number[0] == 1000
    assert number[1] == 2000
    assert len(number) == 2
  when defined(iniplusCheckmaps):
    for i in table[(section, key)].arrayVal:
      case i.kind:
      of CVInt: result.add(i.intVal)
      else: discard
    return result
  else:
    for i in table.getArray(section, key):
      case i.kind:
      of CVInt: result.add(i.intVal)
      else: discard
    return result

func getIntArrayOrDefault*(table: ConfigTable, section, key: string, default: seq[int]): seq[int] =
  ## Either returns the provided int array in a table or a default value.
  runnableExamples:
    import iniplus
    let table = parseString("users = [\"Kate\", \"John\", \"Alex\"]")
    assert table.getStringArrayOrDefault("", "users", @["Kate", "John", "Alex"]) == @["Kate", "John", "Alex"]
    assert table.getStringArrayOrDefault("", "users", @[]) == @["Kate", "John", "Alex"]

    let table2 = parseString("")
    assert table2.getStringArrayOrDefault("", "users", @["John"]) == @["John"]
    assert table2.getStringArrayOrDefault("", "users", @[]) == @[]
  if not table.hasKey((section,key)):
    return default

  when defined(iniplusCheckmaps):
    return table.getIntArray(section, key)
  else:
    if table.exists(section, key):
      return table.getIntArray(section, key)
    return default

func getBoolArray*(table: ConfigTable, section, key: string): seq[bool] =
  ## This procedure retrieves a boolean-only array from a table. It also throws out any non-boolean items
  runnableExamples:
    import iniplus 
    let
      config = parseString("[my_favorite]\nbooleans=[true, \"Jimmy\", false]")
      myFavoriteBooleans = config.getBoolArray("my_favorite","booleans")
    
    assert myFavoriteBooleans[0] == true
    assert myFavoriteBooleans[1] == false
    assert len(myFavoriteBooleans) == 2
  when defined(iniplusCheckmaps):
    for i in table[(section, key)].arrayVal:
      case i.kind:
      of CVBool: result.add(i.boolVal)
      else: discard
    return result
  else:
    for i in table.getArray(section,key):
      case i.kind:
      of CVBool: result.add(i.boolVal)
      else: discard
    return result

func getBoolArrayOrDefault*(table: ConfigTable, section, key: string, default: seq[bool]): seq[bool] =
  ## Either returns the provided bool array in a table or a default value.
  runnableExamples:
    import iniplus
    let table = parseString("users = [\"Kate\", \"John\", \"Alex\"]")
    assert table.getStringArrayOrDefault("", "users", @["Kate", "John", "Alex"]) == @["Kate", "John", "Alex"]
    assert table.getStringArrayOrDefault("", "users", @[]) == @["Kate", "John", "Alex"]

    let table2 = parseString("")
  when defined(iniplusCheckmaps):
    return table.getBoolArray(section, key)
  else:
    if table.exists(section, key):
      return table.getBoolArray(section, key)
    return default

func getTable*(table: ConfigTable, section, key: string): OrderedTable[string, ConfigValue] =
  ## Returns a table from a configuration table with the specified section and key.
  runnableExamples:
    import iniplus
    let config = parseString("names_and_age = {\"John\": 21, \"Kate\": 22}")
    assert config.getTable("","names_and_age").len() == 2
  when defined(iniplusCheckmaps):
    return table[(section, key)].tableVal
  else:
    let val = table.getValue(section, key)
    if val.kind != CVTable:
      raiseValueError(val.kind, section, key)
    return val.tableVal

proc getStringTable*(table: ConfigTable, section, key: string): OrderedTable[string, string] =
  ## Returns a string-only table from a configuration table with the specified section and key.
  runnableExamples:
    import iniplus
    let config = parseString("names_and_likes = {\"John\": \"Dogs\", \"Kate\": \"Cats\"}")
  when defined(iniplusCheckmaps):
    for key,val in table[(section, key)].tableVal.pairs:
      case val.kind:
      of CVString: result[key] = val.stringVal
      else: discard
    return result
  else:
    for key,val in table.getTable(section, key).pairs:
      case val.kind:
      of CVString: result[key] = val.stringVal
      else: discard
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
  
  when defined(iniplusCheckmaps):
    for key,val in table[(section, key)].tableVal.pairs:
      case val.kind:
      of CVBool: result[key] = val.boolVal
      else: discard
    return result
  else:
    for key,val in table.getTable(section, key).pairs:
      case val.kind:
      of CVBool: result[key] = val.boolVal
      else: discard
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
  
  when defined(iniplusCheckmaps):
    for key,val in table[(section, key)].tableVal.pairs:
      case val.kind:
      of CVInt: result[key] = val.intVal
      else: discard
    return result
  else:
    for key,val in table.getTable(section, key).pairs:
      case val.kind:
      of CVInt: result[key] = val.intVal
      else: discard
    return result