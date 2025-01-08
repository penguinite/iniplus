## Please turn around while you can.

proc `==`*(a: ConfigValue, b: string): bool =
  ## Disable this comparison operator with -d:iniplusNSComp
  return a.stringVal == b
  
proc `==`*(a: string, b: ConfigValue): bool =
  ## Disable this comparison operator with -d:iniplusNSComp
  return a == b.stringVal
  
proc `==`*(a: ConfigValue, b: int): bool =
  ## Disable this comparison operator with -d:iniplusNSComp
  return a.intVal == b
  
proc `==`*(a: int, b: ConfigValue): bool =
  ## Disable this comparison operator with -d:iniplusNSComp
  return a == b.intVal
  
proc `==`*(a: ConfigValue, b: bool): bool =
  ## Disable this comparison operator with -d:iniplusNSComp
  return a.boolVal == b
  
proc `==`*(a: bool, b: ConfigValue): bool =
  ## Disable this comparison operator with -d:iniplusNSComp
  return a == b.boolVal
  
proc `==`*[T](a: openArray[T], b: ConfigValue): bool =
  ## Disable this comparison operator with -d:iniplusNSComp
  return a == b.arrayVal

proc `==`*[T](a: ConfigValue, b: openArray[T]): bool =
  ## Disable this comparison operator with -d:iniplusNSComp
  return a.arrayVal == b

proc `>`*(a: int, b: ConfigValue): bool =
  ## Disable this comparison operator with -d:iniplusNSComp
  return a > b.intVal

proc `<`*(a: int, b: ConfigValue): bool =
  ## Disable this comparison operator with -d:iniplusNSComp
  return a < b.intVal

proc `>=`*(a: int, b: ConfigValue): bool =
  ## Disable this comparison operator with -d:iniplusNSComp
  return a >= b.intVal

proc `<=`*(a: int, b: ConfigValue): bool =
  ## Disable this comparison operator with -d:iniplusNSComp
  return a <= b.intVal
  
proc `>`*(a: ConfigValue, b: int): bool =
  ## Disable this comparison operator with -d:iniplusNSComp
  return a.intVal > b

proc `<`*(a: ConfigValue, b: int): bool =
  ## Disable this comparison operator with -d:iniplusNSComp
  return a.intVal < b

proc `>=`*(a: ConfigValue, b: int): bool =
  ## Disable this comparison operator with -d:iniplusNSComp
  return a.intVal >= b

proc `<=`*(a: ConfigValue, b: int): bool =
  ## Disable this comparison operator with -d:iniplusNSComp
  return a.intVal <= b
  proc `>`*(a: SomeInteger, b: ConfigValue): bool =
  ## Disable this comparison operator with -d:iniplusNSComp
  return a > b.intVal
proc `<`*(a: SomeInteger, b: ConfigValue): bool =
  ## Disable this comparison operator with -d:iniplusNSComp
  return a < b.intVal
proc `>=`*(a: SomeInteger, b: ConfigValue): bool =
  ## Disable this comparison operator with -d:iniplusNSComp
  return a >= b.intVal
proc `<=`*(a: SomeInteger, b: ConfigValue): bool =
  ## Disable this comparison operator with -d:iniplusNSComp
  return a <= b.intVal

proc `>`*(a: ConfigValue, b: SomeInteger): bool =
  ## Disable this comparison operator with -d:iniplusNSComp
  return a.intVal > b
proc `<`*(a: ConfigValue, b: SomeInteger): bool =
  ## Disable this comparison operator with -d:iniplusNSComp
  return a.intVal < b
proc `>=`*(a: ConfigValue, b: SomeInteger): bool =
  ## Disable this comparison operator with -d:iniplusNSComp
  return a.intVal >= b
proc `<=`*(a: ConfigValue, b: SomeInteger): bool =
  ## Disable this comparison operator with -d:iniplusNSComp
  return a.intVal <= b

proc `!=`*(a: ConfigValue, b: string): bool =
  ## Disable this comparison operator with -d:iniplusNSComp
  return a.stringVal != b

proc `!=`*(a: string, b: ConfigValue): bool =
  ## Disable this comparison operator with -d:iniplusNSComp
  return a != b.stringVal

proc `!=`*(a: ConfigValue, b: int): bool =
  ## Disable this comparison operator with -d:iniplusNSComp
  return a.intVal != b

proc `!=`*(a: int, b: ConfigValue): bool =
  ## Disable this comparison operator with -d:iniplusNSComp
  return a != b.intVal

proc `!=`*(a: ConfigValue, b: bool): bool =
  ## Disable this comparison operator with -d:iniplusNSComp
  return a.boolVal != b

proc `!=`*(a: bool, b: ConfigValue): bool =
  ## Disable this comparison operator with -d:iniplusNSComp
  return a != b.boolVal

proc `!=`*[T](a: openArray[T], b: ConfigValue): bool =
  ## Disable this comparison operator with -d:iniplusNSComp
  return a != b.arrayVal

proc `!=`*[T](a: ConfigValue, b: openArray[T]): bool =
  ## Disable this comparison operator with -d:iniplusNSComp
  return a.arrayVal != b

proc `==`(a,b: ConfigValue): bool =
  if a.kind != b.kind: return false
  # Both have the same kind now.
  case a.kind:
  of CVNone: return true # There is nothing to compare.
  of CVInt: return a.intVal == b.intVal
  of CVBool: return a.boolVal == b.boolVal
  of CVString: return a.stringVal == b.stringVal
  of CVArray: return a.arrayVal == b.arrayVal
  of CVTable: return a.tableVal == b.tableVal

proc `!=`(a,b: ConfigValue): bool =
  if a.kind == b.kind: return false
  # Both have the same kind now.
  case a.kind:
  of CVNone: return true # There is nothing to compare.
  of CVInt: return a.intVal != b.intVal
  of CVBool: return a.boolVal != b.boolVal
  of CVString: return a.stringVal != b.stringVal
  of CVArray: return a.arrayVal != b.arrayVal
  of CVTable: return a.tableVal != b.tableVal


# We all *shut* down...