# Copyright (c) systemonia 2023 <systemonia@proton.me>
# Licensed under the BSD-3-Clause license

import std/[tables, strutils]
export tables

type
  ConfigValueType* = enum
    None, Int, Bool, String, Sequence
  
  ConfigValue* = object of RootObj
    case kind*: ConfigValueType
    of None: nil
    of Int: intVal*: int
    of Bool: boolVal*: bool
    of String: stringVal*: string
    of Sequence: sequence*: seq[ConfigValue]

  ConfigTable* = OrderedTable[string, ConfigValue]

proc create*(kind: ConfigValueType): ConfigValue =
  ## TODO: Figure out how to turn off "Warning: Potential object case transition, instantiate new object instead"
  result.kind = kind
  return result

proc isBoolean(raw: string): bool =
  if raw.toLower() == "true" or raw.toLower() == "false": return true
  else: return false

proc isOnlyDigits(raw: string): bool =
  for ch in raw:
    if ch notin {'1','2','3','4','5','6','7','8','9','0','-'}: return false
  return true

proc trimString*(raw: string): string =
  if raw == "" or raw == "\"": return ""
  result = raw
  if raw.startsWith('"') or raw.startsWith('\''): result = result[1..^1]
  if raw.endsWith('"') or raw.endsWith('\''): result = result[0..^2]
  return result

proc getKind(raw: string): ConfigValueType =
  if isBoolean(raw): return Bool
  if isOnlyDigits(raw): return Int
  if raw.startsWith("["): return Sequence
  return String

proc splitByComma(ar: string): seq[string] =
  # "B", 100, "A"
  var
    value = ""
    inStr, backslash = false
  

  for ch in ar:
    if ch == '\\': backslash = true

    if ch == '"' and not backslash:
      if inStr: inStr = false
      else: inStr = true
    
    if backslash: backslash = false

    if ch == ',' and not inStr:
      result.add(strip(value))
      value = ""
      continue
    value.add(ch)
  
  if len(value) > 0:
    result.add(strip(value))

proc trimArrayString(raw: string): string =
  if raw == "" or raw == "[" or raw == "]": return ""
  result = raw
  if raw.startsWith('[') or raw.startsWith(']'): result = result[1..^1]
  if raw.endsWith('[') or raw.endsWith(']'): result = result[0..^2]
  return result

proc convertValue*(raw: string): ConfigValue =
  result = create(getKind(raw))

  case result.kind:
  of Bool: result.boolVal = parseBool(raw)
  of Int: result.intVal = parseInt(raw)
  of String: result.stringVal = trimString(raw)
  of Sequence:

    for item in splitByComma(trimArrayString(raw)):
      result.sequence.add(convertValue(item))
  else:
    return