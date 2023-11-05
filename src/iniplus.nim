# Copyright (c) systemonia 2023 <systemonia@proton.me>
# Licensed under the BSD-3-Clause license
import iniplus/[objects, reader, writer]
import std/[tables, times]
export objects, reader, writer, tables, DateTime

proc raiseValueError(kind: ConfigValueType, key, section: string) = raise (ref ValueError)(msg: "key \"" & key & "\" in section \"" & section & "\" has wrong type (" & $kind & ")")
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
    assert config.getValue("","name").kind == String
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
  if val.kind != String:
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
  if val.kind != Bool:
    raiseValueError(val.kind, section, key)
  return val.boolVal

proc getInt*(table: ConfigTable, section, key: string): int =
  ## Returns an integer from a table with the specified section and key.
  runnableExamples:
    let config = parseString("port = 8080")
    assert config.getInt("","port") == 8080

  let val = table.getValue(section, key)
  if val.kind != Int:
    raiseValueError(val.kind, section, key)
  return val.intVal

proc getArray*(table: ConfigTable, section, key: string): seq[ConfigValue] =
  ## Returns an array containing a set of ConfigValue objects from a table with the specified section and key.
  runnableExamples:
    let
      config = parseString("employees = [\"John\",\"Katie\",1000]")
      employees = config.getArray("","employees")

    assert employees[0].kind == String
    assert employees[1].kind == String
    assert employees[2].kind == Int

    assert employees[0].stringVal == "John"
    assert employees[1].stringVal == "Katie"
    assert employees[2].intVal == 1000
  let val = table.getValue(section, key)
  if val.kind != Sequence:
    raiseValueError(val.kind, section, key)
  return val.sequence

proc getTable*(table: ConfigTable, section, key: string): OrderedTable[string, ConfigValue] =
  ## Returns a table containing a set of strings and ConfigValue objects from a table with the specified section and key.
  runnableExamples:
    let config = parseString("""
    [legal]
    banned_customers = {
      "John Doe": "Insisted that a tomato was a vegetable.",
      "Jane Doe": ["Threw a hot cup of coffee at Katie", "Tried to steal money from the cash register"]
    }
    """)

    let table = config.getTable("legal","banned_customers")
    assert table.hasKey("John Doe") == true
    assert table["Jane Doe"][1] == "Tried to steal money from the cash register"
  let val = table.getValue(section, key)
  if val.kind != ConfigValueType.Table:
    raiseValueError(val.kind, section, key)
  return val.table

proc getDate*(table: ConfigTable, section, key: string): DateTime =
  ## Returns a date from a table with the specified section and key.
  runnableExamples:
    let config = parseString("""
    [maintenance]
    64bit_system_upgrade_time = "2023-01-19'T'03:14:07000"
    """)

    assert config.getDate("maintenance","64bit_system_upgrade_time").year == 2038

  return table.getString(section,key).parse("yyyy-MM-dd'T'HH:mm:sszzz", utc())