## A bunch of functions for easily comparing different datatypes to and from configuration values.
## 
## You probably want to keep this enabled, but if you dislike it then use -d:iniplusNSCompare
## 
## There's no guarantee that iniplus will work without these however.

when not defined(iniplusNSCompare):
  from ../objects import ConfigValue, ConfigValueKind

  func `==`*(a: ConfigValue, b: string): bool =
    ## Disable this comparison operator with -d:iniplusNSCompare
    return a.stringVal == b

  func `==`*(a: string, b: ConfigValue): bool =
    ## Disable this comparison operator with -d:iniplusNSCompare
    return a == b.stringVal

  func `==`*(a: ConfigValue, b: int): bool =
    ## Disable this comparison operator with -d:iniplusNSCompare
    return a.intVal == b

  func `==`*(a: int, b: ConfigValue): bool =
    ## Disable this comparison operator with -d:iniplusNSCompare
    return a == b.intVal

  func `==`*(a: ConfigValue, b: bool): bool =
    ## Disable this comparison operator with -d:iniplusNSCompare
    return a.boolVal == b

  func `==`*(a: bool, b: ConfigValue): bool =
    ## Disable this comparison operator with -d:iniplusNSCompare
    return a == b.boolVal

  func `==`*[T](a: openArray[T], b: ConfigValue): bool =
    ## Disable this comparison operator with -d:iniplusNSCompare
    return a == b.arrayVal

  func `==`*[T](a: ConfigValue, b: openArray[T]): bool =
    ## Disable this comparison operator with -d:iniplusNSCompare
    return a.arrayVal == b

  func `>`*(a: int, b: ConfigValue): bool =
    ## Disable this comparison operator with -d:iniplusNSCompare
    return a > b.intVal

  func `<`*(a: int, b: ConfigValue): bool =
    ## Disable this comparison operator with -d:iniplusNSCompare
    return a < b.intVal

  func `>=`*(a: int, b: ConfigValue): bool =
    ## Disable this comparison operator with -d:iniplusNSCompare
    return a >= b.intVal

  func `<=`*(a: int, b: ConfigValue): bool =
    ## Disable this comparison operator with -d:iniplusNSCompare
    return a <= b.intVal

  func `>`*(a: ConfigValue, b: int): bool =
    ## Disable this comparison operator with -d:iniplusNSCompare
    return a.intVal > b

  func `<`*(a: ConfigValue, b: int): bool =
    ## Disable this comparison operator with -d:iniplusNSCompare
    return a.intVal < b

  func `>=`*(a: ConfigValue, b: int): bool =
    ## Disable this comparison operator with -d:iniplusNSCompare
    return a.intVal >= b

  func `<=`*(a: ConfigValue, b: int): bool =
    ## Disable this comparison operator with -d:iniplusNSCompare
    return a.intVal <= b

  func `>`*(a: SomeInteger, b: ConfigValue): bool =
    ## Disable this comparison operator with -d:iniplusNSCompare
    return a > b.intVal

  func `<`*(a: SomeInteger, b: ConfigValue): bool =
    ## Disable this comparison operator with -d:iniplusNSCompare
    return a < b.intVal

  func `>=`*(a: SomeInteger, b: ConfigValue): bool =
    ## Disable this comparison operator with -d:iniplusNSCompare
    return a >= b.intVal

  func `<=`*(a: SomeInteger, b: ConfigValue): bool =
    ## Disable this comparison operator with -d:iniplusNSCompare
    return a <= b.intVal

  func `>`*(a: ConfigValue, b: SomeInteger): bool =
    ## Disable this comparison operator with -d:iniplusNSCompare
    return a.intVal > b

  func `<`*(a: ConfigValue, b: SomeInteger): bool =
    ## Disable this comparison operator with -d:iniplusNSCompare
    return a.intVal < b

  func `>=`*(a: ConfigValue, b: SomeInteger): bool =
    ## Disable this comparison operator with -d:iniplusNSCompare
    return a.intVal >= b

  func `<=`*(a: ConfigValue, b: SomeInteger): bool =
    ## Disable this comparison operator with -d:iniplusNSCompare
    return a.intVal <= b

  func `!=`*(a: ConfigValue, b: string): bool =
    ## Disable this comparison operator with -d:iniplusNSCompare
    return a.stringVal != b

  func `!=`*(a: string, b: ConfigValue): bool =
    ## Disable this comparison operator with -d:iniplusNSCompare
    return a != b.stringVal

  func `!=`*(a: ConfigValue, b: int): bool =
    ## Disable this comparison operator with -d:iniplusNSCompare
    return a.intVal != b

  func `!=`*(a: int, b: ConfigValue): bool =
    ## Disable this comparison operator with -d:iniplusNSCompare
    return a != b.intVal

  func `!=`*(a: ConfigValue, b: bool): bool =
    ## Disable this comparison operator with -d:iniplusNSCompare
    return a.boolVal != b

  func `!=`*(a: bool, b: ConfigValue): bool =
    ## Disable this comparison operator with -d:iniplusNSCompare
    return a != b.boolVal

  func `!=`*[T](a: openArray[T], b: ConfigValue): bool =
    ## Disable this comparison operator with -d:iniplusNSCompare
    return a != b.arrayVal

  func `!=`*[T](a: ConfigValue, b: openArray[T]): bool =
    ## Disable this comparison operator with -d:iniplusNSCompare
    return a.arrayVal != b

  func `==`*(a,b: ConfigValue): bool =
    ## Disable this comparison operator with -d:iniplusNSCompare
    if a.kind != b.kind: return false
    # Both have the same kind now.
    case a.kind:
    of CVNone: return true # There is nothing to compare.
    of CVInt: return a.intVal == b.intVal
    of CVBool: return a.boolVal == b.boolVal
    of CVString: return a.stringVal == b.stringVal
    of CVArray: return a.arrayVal == b.arrayVal
    of CVTable: return a.tableVal == b.tableVal
    of CVType: return a.t == b.t and a.child_t == b.child_t

  func `!=`*(a,b: ConfigValue): bool =
    ## Disable this comparison operator with -d:iniplusNSCompare
    if a.kind == b.kind: return false
    # Both have the same kind now.
    case a.kind:
    of CVNone: return true # There is nothing to compare.
    of CVInt: return a.intVal != b.intVal
    of CVBool: return a.boolVal != b.boolVal
    of CVString: return a.stringVal != b.stringVal
    of CVArray: return a.arrayVal != b.arrayVal
    of CVTable: return a.tableVal != b.tableVal
    of CVType: return a.t != b.t and a.child_t != b.child_t