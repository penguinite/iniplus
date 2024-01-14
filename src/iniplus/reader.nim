# Copyright (c) systemonia 2023 <systemonia@proton.me>
# Licensed under the BSD-3-Clause license

import objects, strutils, tables
export objects

type
  ConfigParserMode = enum
    None, Section, PreValue, Single, Multi

proc parseString*(input: string): ConfigTable =
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
  return parseString(filename.readFile())