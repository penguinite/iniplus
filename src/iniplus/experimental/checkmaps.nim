## *Warning:* This API is experimental, meaning that there *won't be any guaranteed compatability at all...* Use at your own risk.
## 
## A checkmap is a way to basically validate a config table at run-time.
## 
## The main benefits we get out of this is performance and safety.
## Performance will take a hit when loading a file, but retrieval will be way faster now.
import ../[objects, reader, writer], std/strutils

proc `@=`*(t: ConfigValueKind): ConfigValue =
  return ConfigValue(kind: CVType, t: t, child_t: CVNone)

proc `@=`*(t: (ConfigValueKind, ConfigValueKind)): ConfigValue =
  return ConfigValue(kind: CVType, t: t[0], child_t: t[1])

proc `@=`*[T](val: T): ConfigValue =
  return newCValue(val)

## The syntax for required config items looks like this:
runnableExamples:
  {.define: iniplusCheckmaps.}
  import iniplus
  var required = {
    # Section
    "instance": {
      # Key: Type
      "name": @= CVString,
      # If the type is an array or table
      # a "sub-type" must be specified.
      # Like so: key: (Type, Child_Type)
      "rules": @= (CVArray, CVString)
    }.toTable
  }

## The syntax for optional config items looks like this:
runnableExamples:
  {.define: iniplusCheckmaps.}
  import iniplus
  var optional = {
    # Section
    "instance": {
      # Key: Default value
      "name": @= "Amie's Amazing Avenue",
      "defunct": @= true,
      "coolness_level": @= 1000
    }.toTable
  }

func `$`(k: ConfigValueKind): string =
  case k:
  of CVString: return "string"
  of CVArray: return "array"
  of CVTable: return "table"
  of CVInt: return "integer"
  of CVNone: return "none"
  of CVBool: return "boolean"
  of CVType: return "type"

template raiseTableValueError(actual_kind, expected_kind: ConfigValueKind, section, key: string) = raise (ref ValueError)(msg: "key \"" & key & "\" in section \"" & section & "\" is a table and the nested items have the wrong type (Should be a " & $expected_kind & " but it's actually a " & $actual_kind & ")")
template raiseArrayValueError(actual_kind, expected_kind: ConfigValueKind, section, key: string) = raise (ref ValueError)(msg: "key \"" & key & "\" in section \"" & section & "\" is an array and the nested items have the wrong type (Should be a " & $expected_kind & " but it's actually a " & $actual_kind & ")")
template raiseValueError(actual_kind, expected_kind: ConfigValueKind, section, key: string) = raise (ref ValueError)(msg: "key \"" & key & "\" in section \"" & section & "\" has wrong type (Should be a " & $expected_kind & " but it's actually a " & $actual_kind & ")")
template raiseIndexDefect(section, key: string) = raise (ref IndexDefect)(msg: "key \"" & key & "\" in section \"" & section & "\" does not exist")


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

type Checkmap* = openArray[(string, Table[string, ConfigValue])]
proc parseString*(input: string, required: Checkmap = @[], optional: Checkmap = @[]): ConfigTable =
  result = reader.parseString(input)

  # Check required options first
  for section, list in required.items:
    for key, item in list.pairs:

      # Check if the key exists, throw an error if not
      if not result.hasKey((section, key)):
        raiseIndexDefect(section, key)
      
      let config = result[(section, key)]

      # Check if the key matches the type/kind, throw an error if not.
      if config.kind != item.t:
        raiseValueError(config.kind, item.t, section, key)
      
      case config.kind:
      of CVArray:
        # For arrays, check if the inner children match the specified child type
        # Throw an error if it doesn't.
        for i in config.arrayVal:
          if i.kind != item.child_t:
            raiseArrayValueError(i.kind, item.child_t, section, key)
      of CVTable:
        # Same with tables
        for i  in config.tableVal.values:
          if i.kind != item.child_t:
            raiseTableValueError(i.kind, item.child_t, section, key)
      else: discard
  
  # Then check the optional stuff
  for section, list in optional.items:
    for key, val in list.pairs:

      # Check if the key exists, then skip it and use default
      if not result.hasKey((section, key)):
        result[(section, key)] = val
        continue 
      
      let config = result[(section, key)]

      # Check if the key matches the type/kind, throw an error if not.
      if config.kind != val.t:
        raiseValueError(config.kind, val.t, section, key)
      
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

## Retrieve procs that work better/faster with the new checkmap config tables.

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