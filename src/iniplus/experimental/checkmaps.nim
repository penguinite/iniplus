## *Warning:* This API is experimental, meaning that there *won't be any guaranteed compatability at all...* Use at your own risk.
## 
## A checkmap is a way to basically validate a config table at run-time.
## 
## The main benefits we get out of this is performance and safety.
## Performance will take a hit when loading a file, but retrieval will be way faster now.

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