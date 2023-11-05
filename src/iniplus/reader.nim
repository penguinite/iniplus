# Copyright (c) systemonia 2023 <systemonia@proton.me>
# Licensed under the BSD-3-Clause license

import objects, strutils

proc isBoolean*(str: string): bool =
  case str.toLower():
  of "true","false":
    return true
  else:
    return false

proc isOnlyDigits*(str: string): bool =
  for ch in str:
    if ch notin {'1','2','3','4','5','6','7','8','9','0','-'}: return false
  return true

proc convertToBool*(str: string): bool =
  case str.toLower():
  of "true": return true
  of "false": return false

proc convertToInt*(str: string): int = return str.parseInt()

proc cleanString*(str: string): string =
  if len(str) < 0 or str.isEmptyOrWhitespace():
    return ""

  const chset = {' ', '\t', '\v', '\r', '\l', '\f', '"'}
  var
    beginning = 0
    ending = high(str)
  
  while high(str) >= beginning and str[beginning] in chset: inc(beginning) 
  while ending > beginning and str[ending] in chset: dec(ending)

  if str[ending] == '\\':
    dec(ending)

  return str[beginning .. ending]

proc convertFromRaw*(raw: string, mode: ConfigParserMode): ConfigValue =
  if mode == Single:
    if raw.isBoolean():
      result.kind = Bool
    elif raw.isOnlyDigits():
      result.kind = Int
    else:
      result.kind = String

  
  if mode == Multi and len(raw) > 0:
    case raw[0]:
    of '[': result.kind = Sequence
    of '{': result.kind = Table
    else: result.kind = String

  case result.kind:
  of Bool: result.boolVal = convertToBool(raw)
  of Int: result.intVal = convertToInt(raw)
  of String: result.stringVal = raw
  else:
    return

  return result

proc parseString*(str: string): ConfigTable =
  var
    mode: ConfigParserMode
    section, key, value: string = ""
    inStr, backslash: bool = false

  for line in str.splitLines:
    if line.isEmptyOrWhitespace or line.startsWith("#") or line.startsWith(";"):
      continue
    
    if mode == Single:
      result[section & '|' & key] = convertFromRaw(cleanString(value), mode)
      key = ""
      value = ""
      mode = None

    for ch in line:
      when defined(iniPlusDebug):
        echo "[", section, "]: ", key, " : \"", value, "\""
        echo "Mode: ", mode
        echo "ch: ", ch
      if ch == '\\':
        backslash = true
        continue
        
      if ch == '"' and not backslash:
        if inStr: inStr = false
        else: inStr = true

      if backslash:
        backslash = false
      
      case mode:
      of None:
        if ch == '[' and not inStr:
          section = ""
          mode = Section
          continue
        if ch == '=' or ch == ':' and not inStr:
          key = key.cleanString()
          mode = PreValue
          continue
        key.add(ch)
      of Section:
        if ch == ']' and not inStr:
          section = section.cleanString()
          mode = None
          continue
        section.add(ch)
      of PreValue:
        case ch:
        of '[','{': mode = Multi
        of ' ': continue
        else:
          value.add(ch)
          mode = Single
      of Single:
        value.add(ch)
      else:
        continue

  if mode == Single:
      result[section & "|" & key] = convertFromRaw(cleanString(value), mode)

proc splitTableItem*(str: string): seq[string] =
  var tmp = ""
  for ch in str:
    if ch == '|':
      result.add(tmp)
      tmp = ""
      continue
    tmp.add(ch)
  result.add(tmp)


proc dump*(table: ConfigTable): string =
  for key,val in table.pairs:
    let list = splitTableItem(key)
    result.add("\t")
    if list[0] != "":
      result.add("[" & list[0] & "] ") # Section
    result.add("\"" & list[1] & "\": ") # Key
    result.add($val & "\n") # Value
  result = result[0..^2] # Remove last newline char
  return "{\n" & result & "\n}" # Add curly brackets