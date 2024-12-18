## Iniplus is a configuration file format and parser, it is simply an INI format with support for arrays.
## Iniplus aims to be as performant as std/parsecfg, yet more flexible and easier to use for new Nim developers.
## Plus, support for arrays is quite essential, and hacky work-arounds such as using strings aren't ideal.
## To get started with iniplus, you must install it via nimble and then import it
## To read configuration files, you can use the procedure `parseFile`
runnableExamples "--run:off":
  # Load configuration file
  var config = parseFile("app.ini")

## You can also parse configuration files from strings, using the `parseString` procedure.
runnableExamples:
  # Load configuration file from string
  var config = parseString("[section]\nkey=\"Hello World!\"")

## After reading and parsing your configuration, you will be left with a ConfigTable object.
## This is the actual configuration data, represented in a neat little table.
## And you can use it now to retrieve actual data, like so:
runnableExamples:
  # Ignore the long string, it's there to please
  # Nim's documentation generator.
  var config = parseString("""
  [section]
  string="Hello World!"
  int=5000
  bool=true
  array=["John", "Katie", true]

  stringArray=["John","Katie"]
  boolArray=[true,false]
  intArray=[5000,9001]
  """)

  # Always make sure to check if a value exists before retrieving it!
  # Iniplus will raise a defect if it finds non-existent value!
  if config.exists("section","key"):
    echo "Key value inside \"Section\" section exists!"
    # Do something with it.

  # Get string value
  assert config.getString("section","string") == "Hello World!"
  # Get boolean value
  assert config.getBool("section","bool") == true
  # Get integer value
  assert config.getInt("section","int") == 5000

  # The array that gets returned here consists of ConfigValue objects
  # You can use getStringArray(), getBoolArray(), getIntArray()
  # in order to get arrays of only one value type.

  # Get array value
  assert config.getArray("section","array").len() == 3 

   # Get array consisting of only strings
  assert config.getStringArray("section","stringArray")[0] == "John"
  # Get array consisting of only booleans
  assert config.getBoolArray("section","boolArray")[0] == true
  # Get array consisting of only integers
  assert config.getIntArray("section","intArray")[0] == 5000 

## There are also advanced features such as making your own tables, writing multiple keys with one call and converting your table into a string.
## These are too advanced to cover here, but I hope these will be easy for you to pick up.

## You can check out the modules separately below, here is a list over what each one does:
## 1. retrieve contains functions for retrieving data from config file
## 2. objects contains the object definitions that are the foundation of this library
## 3. reader contains the configuration file parser
## 4. writer contains the above-mentioned advanced features.

when defined(iniplusCheckmap):
  import iniplus/private/checkmap, iniplus/[objects, writer]
  import std/tables
  export tables, checkmap, objects, writer
else:
  import iniplus/[retrieve, objects, reader, writer]
  import std/[tables]
  export objects, reader, writer, tables, retrieve
