## A checkmap is a way to basically validate a config table at run-time.
## 
## In theory, it means safer coder since potential errors are caught earlier
## and it also means more performant retrieval (Since we don't have to double-check an items type or its existence all the time)
## 
## Right now, these are experimental and the API probably will change a bit. (It's a wobbly mess basically.)
## And also no support or documentation will be made available for it.
## 
## If you *really* do want to use it tho, then start by import iniplus with `iniplusCheckmap` defined.
## And then well... figure it out yourself lol :P
## Here is an example, feel free to adapt it:
runnableExamples "-r:off":
  # Importing iniplus with the checkmap option.
  {.define: iniplusCheckmap.}
  import iniplus

  # Parsing a config file
  let config = parseString(
    config_file,
    required = @[
      # required(SectionName, KeyName, ConfigValueKind)
      # For tables/arrays: # required(SectionName, KeyName, ConfigValueKind, child_kind = ChildrenKind)
      required("company", "name", CVString)
    ],
    optional = @[

    ]

  )

## In technical terms, Checkmap is an extended version of the parseString proc, 
## it's extended with 2 more parameters, one labelled required and one labelled optional.
## Both are sequences of the Checkmap object.
## 
## A Checkmap object consists of a section (string), key (also string)
## and for the "optional" sequence, it also consists of a default value. (A ConfigValue object)
## And then, a ConfigValueKind field for validating the type.
## And lastly, if the field is an array or a table (CVArray or CVTable) then there's an extra field for validating the inner items.
## 
## Creating Checkmap objects can be somewhat of a nuisance manually, so you should either use required() or optional()
## 
## Use required() for when the object is absolutely required, iniplus will throw an error if it doesn't exist or if it doesn't match the checkmap.
## 
## Use optional() for when the object has a reasonable default value, 
## iniplus will use the default for when it doesn't exist and 
## it will throw an error if a user-provided option doesn't match.
## 
## You should already by now know everything you need to use this experimental interface.
## I'll try to not break it but, no promises ;)

import ../[objects, reader, writer], std/strutils

type
  Checkmap* = object
    section*: string
    key*: string
    default*: ConfigValue
    case kind*: ConfigValueKind
    of CVArray, CVTable:
      child_kind*: ConfigValueKind
    else: discard

proc required*(section, key: string, kind: ConfigValueKind, child_kind = CVNone): Checkmap =
  result = Checkmap(kind: kind)
  result.section = section
  result.key = key
  case kind:
  of CVArray: result.child_kind = child_kind
  else: discard

proc optional*[T](section, key: string, kind: ConfigValueKind, default: T, child_kind = CVNone): Checkmap =
  result = Checkmap(kind: kind)
  result.section = section
  result.key = key
  result.default = newValue(T)
  case kind:
  of CVArray: result.child_kind = child_kind
  else: discard


func `$`(k: ConfigValueKind): string =
  case k:
  of CVString: return "string"
  of CVArray: return "array"
  of CVTable: return "table"
  of CVInt: return "integer"
  of CVNone: return "none"
  of CVBool: return "boolean"


proc raiseTableValueError(actual_kind, expected_kind: ConfigValueKind, section, key: string) = raise (ref ValueError)(msg: "key \"" & key & "\" in section \"" & section & "\" is a table and the nested items have the wrong type (Should be a " & $expected_kind & " but it's actually a " & $actual_kind & ")")
proc raiseArrayValueError(actual_kind, expected_kind: ConfigValueKind, section, key: string) = raise (ref ValueError)(msg: "key \"" & key & "\" in section \"" & section & "\" is an array and the nested items have the wrong type (Should be a " & $expected_kind & " but it's actually a " & $actual_kind & ")")
proc raiseValueError(actual_kind, expected_kind: ConfigValueKind, section, key: string) = raise (ref ValueError)(msg: "key \"" & key & "\" in section \"" & section & "\" has wrong type (Should be a " & $expected_kind & " but it's actually a " & $actual_kind & ")")
proc raiseIndexDefect(section, key: string) = raise (ref IndexDefect)(msg: "key \"" & key & "\" in section \"" & section & "\" does not exist")

proc parseString*(input: string, required: seq[Checkmap], optional: seq[Checkmap] = @[]): ConfigTable =
  result = reader.parseString(input)

  for item in required:
    # Check if key exists, throw an error if not.
    if not result.hasKey((item.section, item.key)):
      raiseIndexDefect(item.section, item.key)
    
    # Check if key matches given value, throw an error if not.
    if result[(item.section, item.key)].kind != item.kind:
      raiseValueError(result[(item.section, item.key)].kind, item.kind, item.section, item.key)

    if result[(item.section, item.key)].kind == CVArray:
      # Additionally, check if an array's elements are all the same type
      for i in result[(item.section, item.key)].arrayVal:
        if i.kind != item.child_kind:
          raiseArrayValueError(i.kind, item.child_kind, item.section, item.key)
    
    if result[(item.section, item.key)].kind == CVTable:
      for val in result[(item.section, item.key)].tableVal.values:
        if val.kind != item.child_kind:
          raiseTableValueError(val.kind, item.child_kind, item.section, item.key)
  
  for item in optional:
    # Check if key exists, use the default value if it doesn't.
    if not result.hasKey((item.section, item.key)):
      result[(item.section, item.key)] = item.default
      continue # We can just skip on to the rest.
    
    # Check if key matches given value, throw an error if not.
    if result[(item.section, item.key)].kind != item.kind:
      raiseValueError(result[(item.section, item.key)].kind, item.kind, item.section, item.key)

    if result[(item.section, item.key)].kind == CVArray:
      # Additionally, check if an array's elements are all the same type
      for i in result[(item.section, item.key)].arrayVal:
        if i.kind != item.child_kind:
          raiseArrayValueError(i.kind, item.child_kind, item.section, item.key)
    
    if result[(item.section, item.key)].kind == CVTable:
      for val in result[(item.section, item.key)].tableVal.values:
        if val.kind != item.child_kind:
          raiseTableValueError(val.kind, item.child_kind, item.section, item.key)
  
  return result

## Retrieve procs that work better/faster with the new checkmap'd config tables.

template exists*(table: ConfigTable, section, key: string): bool = return true
template getValue*(table: ConfigTable, section, key: string): ConfigValue = return table[(section, key)]
template getString*(table: ConfigTable, section, key: string): string = return table[(section, key)].stringVal
template getStringOrDefault*(table: ConfigTable, section, key, default: string): string = return table[(section, key)].stringVal
template getArray*(table: ConfigTable, section, key: string): seq[ConfigValue] = return table[(section, key)].arrayVal
template getTable*(table: ConfigTable, section, key: string): OrderedTable[string, ConfigValue] = return table[(section, key)].tableVal

proc getBool*(table: ConfigTable, section, key: string): bool =
  let v = table[(section, key)]
  case v.kind:
  of CVString: return parseBool(v.stringVal)
  of CVBool: return v.boolVal
  else: discard

proc getInt*(table: ConfigTable, section, key: string): int =
  let v = table[(section, key)]
  case v.kind:
  of CVString: return parseInt(v.stringVal)
  of CVInt: return v.intVal
  else: discard

proc getStringArray*(table: ConfigTable, section, key: string): seq[string] =
  for i in table[(section, key)].arrayVal: result.add(i.stringVal)
  return result

proc getIntArray*(table: ConfigTable, section, key: string): seq[int] =
  for i in table[(section, key)].arrayVal: result.add(i.intVal)
  return result

proc getBoolArray*(table: ConfigTable, section, key: string): seq[bool] =
  for i in table[(section, key)].arrayVal: result.add(i.boolVal)
  return result

proc getStringTable*(table: ConfigTable, section, key: string): OrderedTable[string, string] =
  for key,val in table[(section, key)].tableVal.pairs:
    result[key] = val.stringVal
  return result

proc getBoolTable*(table: ConfigTable, section, key: string): OrderedTable[string, bool] =
  for key,val in table[(section, key)].tableVal.pairs:
    result[key] = val.boolVal
  return result

proc getIntTable*(table: ConfigTable, section, key: string): OrderedTable[string, int] =
  for key,val in table[(section, key)].tableVal.pairs:
    result[key] = val.intVal
  return result