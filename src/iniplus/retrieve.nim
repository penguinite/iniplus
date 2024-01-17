# Copyright (c) penguinite 2023 <penguinite@proton.me>
# Licensed under the BSD-3-Clause license
import objects
import std/[tables, times, strutils]
export tables, times

proc raiseValueError(kind: ConfigValueKind, section, key: string) = raise (ref ValueError)(msg: "key \"" & key & "\" in section \"" & section & "\" has wrong type (" & $kind & ")")
proc raiseIndexDefect(section, key: string) = raise (ref IndexDefect)(msg: "key \"" & key & "\" in section \"" & section & "\" does not exist")

proc exists*(table: ConfigTable, section, key: string): bool =
  ## Simply detects if a given key inside of a given section exists.
  ## Returns true if it does, false if it doesn't.
  runnableExamples:
    let config = parseString("name = \"John Doe\"")
    assert config.exists("","name") == true
    
    # This isn't in the config file, so it's false.
    assert config.exists("","age") == false
  if table.hasKey(section & '|' & key):
    return true
  return false

proc getValue*(table: ConfigTable, section, key: string): ConfigValue =
  ## Returns a pure ConfigValue object, typically this is only used for custom
  ## data types or for some other reason.
  runnableExamples:
    let config = parseString("name = \"John Doe\"")
    assert config.getValue("","name").kind == CVString
    assert config.getValue("","name").stringVal == "John Doe"

  if not table.exists(section, key):
    raiseIndexDefect(section, key)

  return table[section & '|' & key]

proc getString*(table: ConfigTable, section, key: string): string =
  ## Returns a string from a table with the specified section and key.
  runnableExamples:
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
    let config = parseString("""
    [dialog]
    info_text = "Insert some informational text here."
    """)
    # Since the first example is in the config file, it gets returned.
    assert config.getStringOrDefault("dialog","info_text","") == "Insert some informational text here."
    # This is not in the config file, so the procedure returns the `default` parameter.
    assert config.getStringOrDefault("dialog","help_text","Insert some helpful text here.") == "Insert some helpful text here."

  if not table.exists(section, key):
    return default
  return table.getString(section, key)

proc getBool*(table: ConfigTable, section, key: string): bool =
  ## Returns a boolean from a table with the specified section and key.
  runnableExamples:
    let config = parseString("enable_feature = true")
    assert config.getBool("","enable_feature") == true
  let val = table.getValue(section, key)
  case val.kind:
  of CVString: result = parseBool(val.stringVal)
  of CVBool: result = val.boolVal
  else: raiseValueError(val.kind, section, key)

proc getInt*(table: ConfigTable, section, key: string): int =
  ## Returns an integer from a table with the specified section and key.
  runnableExamples:
    let config = parseString("port = 8080")
    assert config.getInt("","port") == 8080

  let val = table.getValue(section, key)
  case val.kind:
  of CVString: result = parseInt(val.stringVal)
  of CVInt: result = val.intVal
  else: raiseValueError(val.kind, section, key)

proc getArray*(table: ConfigTable, section, key: string): seq[ConfigValue] =
  ## Returns an array containing a set of ConfigValue objects from a table with the specified section and key.
  runnableExamples:
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
  if val.kind != CVSequence:
    raiseValueError(val.kind, section, key)
  return val.sequenceVal

proc getStringArray*(table: ConfigTable, section, key: string): seq[string] =
  ## This procedure retrieves a string-only array from a table. It also throws out any non-string items
  runnableExamples:
    let
      config = parseString("employees = [\"John\",\"Katie\",1000]")
      employees = config.getStringArray("","employees")
    
    assert employees[0] == "John"
    assert employees[1] == "Katie"
    assert len(employees) == 2
    
  let val = table.getValue(section, key)
  if val.kind != CVSequence:
    raiseValueError(val.kind, section, key)
  for item in val.sequenceVal:
    if item.kind == CVString: result.add(item.stringVal)
  return result

proc getIntArray*(table: ConfigTable, section, key: string): seq[int] =
  ## This procedure retrieves a integer-only array from a table. It also throws out any non-integer items
  runnableExamples:
    let
      config = parseString("numbers = [1000, 2000, \"Michael\"]")
      number = config.getIntArray("","numbers")

    assert number[0] == 1000
    assert number[1] == 2000
    assert len(number) == 2

  let val = table.getValue(section, key)
  if val.kind != CVSequence:
    raiseValueError(val.kind, section, key)
  for item in val.sequenceVal:
    if item.kind == CVInt: result.add(item.intVal)
  return result

proc getBoolArray*(table: ConfigTable, section, key: string): seq[bool] =
  ## This procedure retrieves a boolean-only array from a table. It also throws out any non-boolean items
  runnableExamples:
    let
      config = parseString("[my_favorite]\nbooleans=[true, \"Jimmy\", false]")
      myFavoriteBooleans = config.getBoolArray("my_favorite","booleans")
    
    assert myFavoriteBooleans[0] == true
    assert myFavoriteBooleans[1] == false
    assert len(myFavoriteBooleans) == 2
  let val = table.getValue(section, key)
  if val.kind != CVSequence:
    raiseValueError(val.kind, section, key)
  for item in val.sequenceVal:
    if item.kind == CVBool: result.add(item.boolVal)
  return result

# No... I am not gonna make a getArrayArray()

proc unroll*(table: Table[string, ConfigValue]): Table[string, string] =
  ## Unrolls a configuration table into a string-only table.
  for key,val in table:
    if val.kind == CVString:
      result[key] = val.stringVal
    continue