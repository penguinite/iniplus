# Copyright (c) penguinite 2023 <penguinite@proton.me>
# Licensed under the BSD-3-Clause license

import std/[tables, strutils]
export tables

type
  ConfigValueKind* = enum
    CVNone, CVInt, CVBool, CVString, CVSequence


  ConfigValue* = object of RootObj
    case kind*: ConfigValueKind
    of CVNone: nil
    of CVInt: intVal*: int
    of CVBool: boolVal*: bool
    of CVString: stringVal*: string
    of CVSequence: sequenceVal*: seq[ConfigValue]

  CondensedConfigValue* = object of RootObj
    section*, key*: string
    value*: ConfigValue

  ConfigTable* = OrderedTable[string, ConfigValue]

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

proc getKind(raw: string): ConfigValueKind =
  if isBoolean(raw): return CVBool
  if isOnlyDigits(raw): return CVInt
  if raw.startsWith("["): return CVSequence
  return CVString

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
  let kind = getKind(raw)
  result = ConfigValue(kind: kind)

  case kind:
  of CVBool: result.boolVal = parseBool(raw)
  of CVInt: result.intVal = parseInt(raw)
  of CVString: result.stringVal = trimString(raw)
  of CVSequence:
    for item in splitByComma(trimArrayString(raw)):
      result.sequenceVal.add(convertValue(item))
  else:
    return

  return result

template log*(str: varargs[string,`$`]) =
  echo("[iniplus:" & instantiationInfo().filename & ":" & $(instantiationInfo().line) & "]: " & str.join())