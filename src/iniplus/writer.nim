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
  of None: return ""
  of String: result = "\"" & val.stringVal & "\""
  of Int: result = $(val.intVal)
  of Bool: result = $(val.boolVal)
  of Sequence:
    for item in val.sequence:
      result.add(toString(item) & ", ")
    result = result[0..^2]
    result = "[\n" & result & "\n]"
  of Table:
    for key,val in val.table:
      result.add("\"" & key & "\": " & toString(val) & ";\n")
    result = "{\n" & result & "\n}"
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

proc writeToFile*(filename: string, table: ConfigTable): bool =
  try:
    writeFile(filename,toString(table))
    return true
  except:
    return false