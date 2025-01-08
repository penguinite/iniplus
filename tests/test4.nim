# Checkmap test
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

var optional = {
  # Section
  "instance": {
    # Key: Default value
    "description": @= "A fun place to hang out! :D",
    "staff_rules": @= @["Do whatever you want lol"],
    "coolness_level": @= 1000
  }.toTable
}

let conf = parseString(
  """
[instance]
name = "Amie's Amazing Avenue"
rules = ["No fun allowed", "Really... No fun allowed!"]
  """,
  required, optional
)

assert conf.exists("instance", "name") == true
assert conf.getString("instance", "name") == "Amie's Amazing Avenue"

assert conf.exists("instance", "rules") == true
assert conf.getArray("instance", "rules").len() == 2
assert conf.getArray("instance", "rules")[0].stringVal == "No fun allowed"
assert conf.getArray("instance", "rules")[1].stringVal == "Really... No fun allowed!"
assert conf.getStringArray("instance", "rules")[0] == "No fun allowed"
assert conf.getStringArray("instance", "rules")[1] == "Really... No fun allowed!"

assert conf.exists("instance", "description") == true
assert conf.getString("instance", "description") == "A fun place to hang out! :D"

assert conf.exists("instance", "staff_rules") == true
assert conf.getArray("instance", "staff_rules").len() == 1
assert conf.getArray("instance", "staff_rules")[0].stringVal == "Do whatever you want lol"
assert conf.getStringArray("instance", "staff_rules")[0] == "Do whatever you want lol"

assert conf.exists("instance", "coolness_level") == true
assert conf.getInt("instance", "coolness_level") == 1000