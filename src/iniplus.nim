## Iniplus is a configuration file format and parser, it is simply an INI format with support for arrays.
runnableExamples "--run:off":
  import iniplus
  # Load configuration file
  var config = parseFile("app.ini")

  # Get string value
  config.getString("section","key")
  # Get boolean value
  config.getBool("section","key)
  # Get integer value
  config.getInt("section","key)
  # Get sequence value
  config.getArray("section","key)  
  # Note: The sequence that gets returned is comprised of ConfigValue objects.
  # You can also use getStringArray(), getBoolArray(), getIntArray() in order to get arrays of only one value.
  
## This file simply imports and exports the entirety of iniplus
import iniplus/[retrieve, objects, reader, writer]
import std/[tables, times]
export objects, reader, writer, tables, DateTime, retrieve
