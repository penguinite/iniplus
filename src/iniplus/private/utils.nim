import std/strutils
import ../objects

type
  TokenKind* = enum
    SquareOpen, SquareClose, EqualSign, CurlyOpen, CurlyClose, Colon, Comma, Literal, Quoted, Newline

  Token* = object
    case kind*: TokenKind
    of Literal, Quoted: inner*: string
    else: discard

func tl(s: string): string =
  for ch in s:
    case ch:
    of 'A','B','C','D','E','F','G','H','I','J','K','L','M','N','O','P','Q','R','S','T','U','V','W','X','Y','Z':
      result.add(char(uint8(ch) xor 0b0010_0000'u8))
    else:
      result.add(ch)

proc isBoolean*(raw: string): bool =
  case raw.tl():
  of "true", "false": return true
  else: return false

proc isOnlyDigits*(raw: string): bool =
  for ch in raw:
    case ch:
    of '1','2','3','4','5','6','7','8','9','0','-': continue
    else: return false
  return true

proc trimString*(raw: string): string =
  ## Trims any double and single quotes from a string.
  case raw:
  of "", " ", "\"": return ""
  else:
    result = raw
    if raw.startsWith('"'):
      result = result[1..^1]
    if raw.endsWith('"'):
      result = result[0..^2]
  return result

proc getKind(raw: string): ConfigValueKind =
  if isBoolean(raw): return CVBool
  if isOnlyDigits(raw): return CVInt
  return CVString

proc conv*(v: string): ConfigValue =
  ## Converts a raw string into a configuration value, this is primarily used by the parser.
  let kind = getKind(v)
  result = ConfigValue(kind: kind)

  case kind:
  of CVBool: result.boolVal = parseBool(v)
  of CVInt: result.intVal = parseInt(v)
  of CVString: result.stringVal = trimString(v)
  else: return

  return result

proc conv*(v: seq[string], table = false): ConfigValue =
  if table:
    result = ConfigValue(kind: CVTable)
    # Quick and dirty "pairs"
    var tmp2 = ""
    for item in v:
      if tmp2 != "":
        result.tableVal[tmp2] = conv(item)
        tmp2 = ""
      else:
        tmp2 = item
  else:
    result = ConfigValue(kind: CVArray)
    result.arrayVal = @[]
    for item in v:
      result.arrayVal.add(conv(item))

type
  State* = enum
    None, Section, Val, Array, CTable