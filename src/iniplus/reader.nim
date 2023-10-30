import objects, strutils

proc isOnlyDigits*(str: string): bool =
  for ch in str:
    if ch notin {'1','2','3','4','5','6','7','8','9','0','-'}: return false
  return true
    

proc parseString*(str: string): ConfigTable =
  var
    mode: ConfigParserMode
    value: ConfigValue
    section, key: string = ""
    inStr: bool = false
    lineNum, charNum: int = -1

  for line in str.splitLines:
    inc(lineNum)
    if line.isEmptyOrWhitespace or line.startsWith("#") or line.startsWith(";"):
      continue
  
    for ch in line:
      inc(charNum)
      if ch == '"':
        if inStr: inStr = false
        else: inStr = true
      
      if not inStr:
        case mode:
        of None:
          if ch == '[':
            section = ""
            mode = Section
          else:
            mode = Key
        of Section:
          if ch == ']':
            mode = None
            continue
          section.add(ch)
        of Key:
          if ch == '=':
            mode = Value
            continue
          key.add(ch)
        of PreValue:
          if not inStr:
            case ch:
            of '[': mode = Sequence
            of '{': mode = Table        
            else: mode = Value
        of Value:
          value.
        else:
          continue
    