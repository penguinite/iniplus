# Copyright (c) penguinite 2023 <penguinite@proton.me>
# Licensed under the BSD-3-Clause license
## This module provides the type definitions that are the foundation of this library.
import std/[tables, strutils]
export tables

type
  ## The kind of configuration value we are processing/storing, iniplus only supports Integers, Booleans, Strings and Sequences. (And I guess None, too.)
  ConfigValueKind* = enum
    CVNone, CVInt, CVBool, CVString, CVSequence

  ## This object is the actual configuration value. It's best to use the built-in functions when handling these, if you must implement your own logic at the low-level then always remember to check the `kind` field first.
  ConfigValue* = object of RootObj
    case kind*: ConfigValueKind
    of CVNone: nil
    of CVInt: intVal*: int
    of CVBool: boolVal*: bool
    of CVString: stringVal*: string
    of CVSequence: sequenceVal*: seq[ConfigValue]

  ## A "Condensed" configuration value is simply an configuration value with the actual section and key embedded into it. This is used to implement the `setBulkKeys` procedure in the writer module.
  CondensedConfigValue* = object of RootObj
    section*, key*: string
    value*: ConfigValue
  ## Simply a configuration table.
