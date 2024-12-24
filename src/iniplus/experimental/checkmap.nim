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
    required = `@`[
      # required(SectionName, KeyName, ConfigValueKind)
      # For tables/arrays: # required(SectionName, KeyName, ConfigValueKind, child_kind = ChildrenKind)
      required("company", "name", CVString)
    ],
    optional = `@`[

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

proc `@`*(value: string): ConfigValue = return ConfigValue(kind: CVString, stringVal: value)
proc `@`*(value: int): ConfigValue = return ConfigValue(kind: CVInt, intVal: value)
proc `@`*(value: bool): ConfigValue = return ConfigValue(kind: CVBool, boolVal: value)
proc `@`*(value: seq[ConfigValue]): ConfigValue = return ConfigValue(kind: CVArray, arrayVal: value)

proc `@`*(value: varargs[ConfigValue]): ConfigValue =
  result = ConfigValue(kind: CVArray)
  for x in value:
    result.arrayVal.add(x)
  return result

proc `@`*[T](val: seq[T]): ConfigValue =
  result = ConfigValue(kind: CVArray)
  for i in val:
    result.arrayVal.add(`@`(i))
  return result


## NEW SYNTAX, optional arguments are like so:
runnableExamples:
  var optional = {
    # SECTION: {
    #   KEY: @ DEFAULT_VALUE
    # }
    "instance": {
      "name": @ "Hello",
      "federated": @ true
    }
  }

type
  ReqObj = object
    case kind*: ConfigValueKind
    of CVArray, CVTable: child_kind*: ConfigValueKind
    else: discard
  
  RequiredList* = openArray[(string, seq[(string, ReqObj)])]
  OptionalList* = openArray[(string, seq[(string, ConfigValue)])]

proc detectChildKind*(c: ConfigValue): ConfigValueKind =
  var ctable: CountTable[ConfigValueKind]
  case c.kind:
  of CVArray:
    for i in c.arrayVal:
      ctable.inc(i.kind)
  of CVTable:
    for i in c.tableVal.values:
      ctable.inc(i.kind)
  else: discard
  return ctable.largest[0]

proc `@!`*(t: ConfigValueKind, t2: ConfigValueKind = CVNone): ReqObj =
  result =  ReqObj(kind: t)
  case t:
  of CVArray, CVTable: result.child_kind = t2
  else: discard
  return result

proc `@!`*(t: (ConfigValueKind, ConfigValueKind)): ReqObj =
  result =  ReqObj(kind: t[0])
  case t[0]:
  of CVArray, CVTable: result.child_kind = t[1]
  else: discard
  return result

## NEW SYNTAX, required arguments are like so:
runnableExamples:
  var required = {
    "instance": @[
      ("name", @! CVString),
      ("users", @! (CVArray, CVString)),
      ("rights", @! (CVTable, CVString))
    ]
  }

func `$`(k: ConfigValueKind): string =
  case k:
  of CVString: return "string"
  of CVArray: return "array"
  of CVTable: return "table"
  of CVInt: return "integer"
  of CVNone: return "none"
  of CVBool: return "boolean"

template raiseTableValueError(actual_kind, expected_kind: ConfigValueKind, section, key: string) = raise (ref ValueError)(msg: "key \"" & key & "\" in section \"" & section & "\" is a table and the nested items have the wrong type (Should be a " & $expected_kind & " but it's actually a " & $actual_kind & ")")
template raiseArrayValueError(actual_kind, expected_kind: ConfigValueKind, section, key: string) = raise (ref ValueError)(msg: "key \"" & key & "\" in section \"" & section & "\" is an array and the nested items have the wrong type (Should be a " & $expected_kind & " but it's actually a " & $actual_kind & ")")
template raiseValueError(actual_kind, expected_kind: ConfigValueKind, section, key: string) = raise (ref ValueError)(msg: "key \"" & key & "\" in section \"" & section & "\" has wrong type (Should be a " & $expected_kind & " but it's actually a " & $actual_kind & ")")
template raiseIndexDefect(section, key: string) = raise (ref IndexDefect)(msg: "key \"" & key & "\" in section \"" & section & "\" does not exist")

proc parseString*(input: string, required: RequiredList = @[], optional: OptionalList = @[]): ConfigTable =
  result = reader.parseString(input)

  # Check required options first
  for section, list in required.items:
    for key, opt in list.items:

      # Check if the key exists, throw an error if not
      if result.hasKey((section, key)):
        raiseIndexDefect(section, key)
      
      let config = result[(section, key)]

      # Check if the key matches the type/kind, throw an error if not.
      if config.kind != opt.kind:
        raiseValueError(config.kind, opt.kind, section, key)
      
      case config.kind:
      of CVArray:
        # For arrays, check if the inner children match the specified child type
        # Throw an error if it doesn't.
        for i in config.arrayVal:
          if i.kind != opt.child_kind:
            raiseArrayValueError(i.kind, opt.child_kind, section, key)
      of CVTable:
        # Same with tables
        for i  in config.tableVal.values:
          if i.kind != opt.child_kind:
            raiseTableValueError(i.kind, opt.child_kind, section, key)
      else: discard
  
  # Then check the optional stuff
  for section, list in optional.items:
    for key, val in list.items:

      # Check if the key exists, then skip it and use default
      if result.hasKey((section, key)):
        result[(section, key)] = val
        continue 
      
      let config = result[(section, key)]

      # Check if the key matches the type/kind, throw an error if not.
      if config.kind != val.kind:
        raiseValueError(config.kind, val.kind, section, key)
      
      case config.kind:
      of CVArray:
        # For arrays, check if the inner children match the specified child type
        # Throw an error if it doesn't.
        let childKind = detectChildKind(val)
        for i in config.arrayVal:
          if i.kind != childKind:
            raiseArrayValueError(i.kind, childKind, section, key)
      of CVTable:
        # Same with tables
        let childKind = detectChildKind(val)
        for i  in config.tableVal.values:
          if i.kind != childKind:
            raiseTableValueError(i.kind, childKind, section, key)
      else: discard
  return result

## Retrieve procs that work better/faster with the new checkmap'd config tables.

proc exists*(table: ConfigTable, section, key: string): bool = return true
proc getValue*(table: ConfigTable, section, key: string): ConfigValue = return table[(section, key)]
proc getString*(table: ConfigTable, section, key: string): string = return table[(section, key)].stringVal
proc getArray*(table: ConfigTable, section, key: string): seq[ConfigValue] = return table[(section, key)].arrayVal
proc getTable*(table: ConfigTable, section, key: string): OrderedTable[string, ConfigValue] = return table[(section, key)].tableVal

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
  for i in table[(section, key)].arrayVal:
    case i.kind:
    of CVString: result.add(i.stringVal)
    else: discard
  return result

proc getIntArray*(table: ConfigTable, section, key: string): seq[int] =
  for i in table[(section, key)].arrayVal:
    case i.kind:
    of CVInt: result.add(i.intVal)
    else: discard
  return result

proc getBoolArray*(table: ConfigTable, section, key: string): seq[bool] =
  for i in table[(section, key)].arrayVal:
    case i.kind:
    of CVInt: result.add(i.boolVal)
    else: discard
  return result

proc getStringTable*(table: ConfigTable, section, key: string): OrderedTable[string, string] =
  for key,val in table[(section, key)].tableVal.pairs:
    case val.kind:
    of CVString: result[key] = val.stringVal
    else: discard
  return result

proc getBoolTable*(table: ConfigTable, section, key: string): OrderedTable[string, bool] =
  for key,val in table[(section, key)].tableVal.pairs:
    case val.kind:
    of CVBool: result[key] = val.boolVal
    else: discard
  return result

proc getIntTable*(table: ConfigTable, section, key: string): OrderedTable[string, int] =
  for key,val in table[(section, key)].tableVal.pairs:
    case val.kind:
    of CVInt: result[key] = val.intVal
    else: discard
  return result

# "*OrDefault" procs are not a neccessary thing when using checkmaps.
# let's warn the client then by using deprecations.
proc getStringOrDefault*(config: ConfigTable, section, key, default: string): string =
  #{.deprecated: "getStringOrDefault is not neccessary when using a checkmap. Just supply a default value to the optional list.".}
  return config[(section, key)].stringVal

proc getBoolOrDefault*(config: ConfigTable, section, key: string, default: bool): bool =
  #{.deprecated: "getBoolOrDefault is not neccessary when using a checkmap. Just supply a default value to the optional list.".}
  return config[(section, key)].boolVal

proc getIntOrDefault*(config: ConfigTable, section, key: string, default: int): int =
  #{.deprecated: "getIntOrDefault is not neccessary when using a checkmap. Just supply a default value to the optional list.".}
  return config[(section, key)].intVal

proc getStringArrayOrDefault*(config: ConfigTable, section, key: string, default: seq[string]): seq[string] =
  #{.deprecated: "getStringArrayOrDefault is not neccessary when using a checkmap. Just supply a default value to the optional list.".}
  return config.getStringArray(section, key)
