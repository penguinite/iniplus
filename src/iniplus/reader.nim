# Copyright (c) penguinite 2023 <penguinite@proton.me>
# Licensed under the BSD-3-Clause license
## This module contains the parser for the extended INI configuration format.
## It provides only two procedures, `parseFile` which takes a string as a filename.
runnableExamples "--run:off":
  discard parseFile("app.ini")
## and `parseString` which expects configuration data in its string input.
runnableExamples:
  discard parseString("key=\"value\"")

import objects, strutils, tables
export objects

type
  ConfigParserMode = enum
    None, Section, PreValue, Single, Multi


template log(str: varargs[string,`$`]) =
  echo("[iniplus:" & instantiationInfo().filename & ":" & $(instantiationInfo().line) & "]: " & str.join())

proc parseString*(input: string): ConfigTable =
  ## This procedure takes a string of some kind as its input and returns a parsed ConfigTable object.
  runnableExamples:
    import iniplus
    let config = parseString("my_favorite_key=\"My Favorite Value\"\n")
    assert config.getString("","my_favorite_key") == "My Favorite Value"
  var
    section, key, value = ""
    mode: ConfigParserMode = None
    inQuote, backslash, forceInsert = false

  for line in input.splitLines:
    if line.isEmptyOrWhitespace() or line.startsWith("#") or line.startsWith(";") and mode != Multi:
      continue # Skip since line is either comment or mostly empty
    
    if forceInsert or mode == Single:
      # Clean the key and value beforehand so the code is slightly prettier
      key = strip(key)
      value = strip(value)
      result[section & '|' & key] = convertValue(value)
      key = ""
      value = ""
      inQuote = false
      mode = None
      forceInsert = false

    for ch in line:
      #echo "[$#, $#, $#]" % [$ch, $mode, value]
      if ch == '\\': backslash = true

      if ch == '"' and not backslash:
        if inQuote: inQuote = false
        else: inQuote = true
      
      if backslash: backslash = false

      case mode:
      of None:
        if not inQuote:
          if ch == '[':
            section = ""
            mode = Section
            continue
          
          if ch == '=' or ch == ':':
            mode = PreValue
            key = key.trimString()
            continue
        key.add(ch)

      of Section:
        if ch == ']' and not inQuote:
          mode = None
          section = section.strip()
          continue

        if ch == '|':
          log "| cannot be used inside sections! Replacing with _"            
          section.add("_")
          continue

        section.add(ch)
      of PreValue:
        if ch in Whitespace: continue
        
        if not inQuote: value.add(ch)
        
        if ch == '[': mode = Multi
        else: mode = Single
      of Single:
        value.add(ch)
      of Multi:
        if ch == ']' and not inQuote:
          mode = Single
          forceInsert = true
        value.add(ch)
  
  if forceInsert or mode == Single:
    # Clean the key and value beforehand so the code is slightly prettier
    key = strip(key)
    value = strip(value)
    result[section & '|' & key] = convertValue(value)
  
  
proc parseFile*(filename: string): ConfigTable =
  ## Opens a file, reads the entirety of it and returns a configuration table.
  runnableExamples "--run:off":
    let config = parseFile("app.ini")
  return parseString(filename.readFile())
