# Copyright (c) penguinite 2023 <penguinite@proton.me>
# Licensed under the BSD-3-Clause license
## This module provides the type definitions that are the foundation of this library.
import std/[tables, strutils]
export tables

type
  ## The kind of configuration value we are processing/storing, iniplus only supports Integers, Booleans, Strings and Sequences. (And I guess None, too.)
  ConfigValueKind* = enum
    CVNone, CVInt, CVBool, CVString, CVSequence

  ## This object is the actual configuration value. It's best to use the built-in functions when handling these, if you must implement your own logic at the low-level then always remember to check the `kind` field first.
  ConfigValue* = object of RootObj
    case kind*: ConfigValueKind
    of CVNone: nil
    of CVInt: intVal*: int
    of CVBool: boolVal*: bool
    of CVString: stringVal*: string
    of CVSequence: sequenceVal*: seq[ConfigValue]

  ## A "Condensed" configuration value is simply an configuration value with the actual section and key embedded into it. This is used to implement the `setBulkKeys` procedure in the writer module.
  CondensedConfigValue* = object of RootObj
    section*, key*: string
    value*: ConfigValue

  ## Simply a configuration table. The string part follows a format of `SECTION|KEY` so, if you had a key named `port` inside of the section `web` then the format would work out to `web|port`
  ConfigTable* = OrderedTable[string, ConfigValue]

proc isBoolean(raw: string): bool =
  if raw.toLower() == "true" or raw.toLower() == "false": return true
  else: return false

proc isOnlyDigits(raw: string): bool =
  for ch in raw:
    if ch notin {'1','2','3','4','5','6','7','8','9','0','-'}: return false
  return true

proc trimString*(raw: string): string =
  ## Trims any double and single quotes from a string.
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
  ## Converts a raw string into a configuration value, this is primarily used by the parser.
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
