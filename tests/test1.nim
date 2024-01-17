# This is just an example to get you started. You may wish to put all of your
# tests into a single file, or separate them into multiple `test1`, `test2`
# etc. files (better names are recommended, just make sure the name starts with
# the letter 't').
#
# To run these tests, simply execute `nimble test`.

import iniplus

const file = """
name ="Acme Gadgets LLC"
founder: "Jane Doe"

[products]
fromCountry="US"
shippingTo = [
    "US", "UK", "EU"
]

[products]
sort: "alphabetically"

[products.1]
id: 1
name: "Ultra Product #1"
price: 75
inStock: false
isDeprecated: true
newProductId: 2
; iniplus does not support timestamps.
; as a workaround, you can format your time to an ISO-compatible date
; and format it when you read it again
releaseDate: "2020-10-29T16:17:07Z"

[products.2]
id = 2
name = "Ultra Product #2"
price = 150 
inStock = true
isDeprecated = false
# iniplus does not support timestamps.
# as a workaround, you can format your time to an ISO-compatible date
# and format it when you read it again
releaseDate = "2023-10-29T16:17:07Z"
"""

var
  table = newConfigTable()
  # Creates a String ConfigValue object
  valueStr = newValue("Hello World!")
  # Creates a Sequence ConfigValue object
  valueArr = newValue(
    newValue("Hello World!"),
    newValue(1000)
  )
  value: ConfigValue
  config: ConfigTable
  
# Inserting a handmade string into a table
table.setKey("handmade","quote",valueStr)
assert table.getString("handmade","quote") == "Hello World!"

# Inserting a handmade array into a table
table.setKey("handmade","list",valueArr)
assert table.getArray("handmade", "list")[0].stringVal == "Hello World!"
assert table.getArray("handmade", "list")[1].intVal == 1000

table.setKeySingleVal("single","number","1000")
table.setKeySingleVal("single","quote","\"Hello World!\"")
table.setKeySingleVal("single","true_false","false")

assert table.getString("single","quote") == "Hello World!"
assert table.getInt("single","number") == 1000
assert table.getBool("single", "true_false") == false

table.setKeyMultiVal("multi","list","[\"Hello World!\",1000]")

assert table.getArray("multi","list")[0].stringVal == "Hello World!"
assert table.getArray("multi","list")[1].intVal == 1000

table = parseString("employees = [\"John\",\"Katie\",1000]")
var employees = table.getArray("","employees")

assert employees[0].kind == CVString
assert employees[1].kind == CVString
assert employees[2].kind == CVInt

assert employees[0].stringVal == "John"
assert employees[1].stringVal == "Katie"
assert employees[2].intVal == 1000

table = parseString("employees = [\"John\",\"Katie\",1000]")
var employees2 = table.getStringArray("","employees")
    
assert employees2[0] == "John"
assert employees2[1] == "Katie"
assert len(employees2) == 2

table = parseString("numbers = [1000, 2000, \"Michael\"]")
var number = table.getIntArray("","numbers")

assert number[0] == 1000
assert number[1] == 2000
assert len(number) == 2

table = parseString("[my_favorite]\nbooleans=[true, \"Jimmy\", false]")
var myFavoriteBooleans = table.getBoolArray("my_favorite","booleans")
    
assert myFavoriteBooleans[0] == true
assert myFavoriteBooleans[1] == false
assert len(myFavoriteBooleans) == 2

table = parseString("name = \"John Doe\"")
assert table.getValue("","name").kind == CVString
assert table.getValue("","name").stringVal == "John Doe"

table = parseString("""
[dialog]
info_text = "Insert some informational text here."
""")
assert table.getString("dialog","info_text") == "Insert some informational text here."
assert table.getStringOrDefault("dialog","help_text","Insert some helpful text here.") == "Insert some helpful text here."

table = parseString("enable_feature = true")
assert table.getBool("","enable_feature") == true

table = parseString("port = 8080")
assert table.getInt("","port") == 8080

table = parseString(file)
echo table.dump()

table = ConfigTable()

table.setBulkKeys(
  c("hello","world","!"), # Strings
  c("goodbye","world","!"), # Strings^2
  c("favorite","people", %("John"), %("Katie"), %(true)), # Sequences
  c("favorite","number", 9001), # Numbers
  c("favorite","boolean",true) # Booleans
)

assert table.getString("hello","world") == "!"
assert table.getString("goodbye","world") == "!"
assert table.getArray("favorite","people")[0].stringVal == "John"
assert table.getArray("favorite","people")[1].stringVal == "Katie"
assert table.getArray("favorite","people")[2].boolVal == true
assert table.getInt("favorite", "number") == 9001
assert table.getBool("favorite", "boolean") == true

let
  tableA = newConfigTable()
  tableB = ConfigTable()
    
assert tableA.len() == tableB.len()

config = parseString("my_favorite_people=[\"John\", \"Katie\", true]")

assert config.getArray("","my_favorite_people")[0].stringVal == "John"
assert config.getArray("","my_favorite_people")[1].stringVal == "Katie"
assert config.getArray("","my_favorite_people")[2].boolVal == true

config = parseString("my_favorite_people=[\"John\", \"Katie\", true]")
value = newValue(@[
    newValue("John"),
    newValue("Katie"),
    newValue(true)
  ]
)
assert config.getValue("","my_favorite_people").sequenceVal[0].stringVal == value.sequenceVal[0].stringVal
assert config.getValue("","my_favorite_people").sequenceVal[1].stringVal == value.sequenceVal[1].stringVal
assert config.getValue("","my_favorite_people").sequenceVal[2].boolVal == value.sequenceVal[2].boolVal

config = parseString("favorite_boolean=true")
value = newValue(true)
assert config.getValue("","favorite_boolean").boolVal == value.boolVal

config = parseString("favorite_number=9001")
value = newValue(9001)    
assert config.getValue("","favorite_number").intVal == value.intVal

config = parseString("favorite_person_number_one=\"John\"")
value = newValue("John")
assert config.getValue("","favorite_person_number_one").stringVal == value.stringVal

config = parseString("test_key=\"Hello\"")
echo toString(config)

value = newValue("John")
assert toString(value) == "\"John\""

var condensedValue = c("favorite","people", @[%"John", %"Katie"])
assert condensedValue.section == "favorite"
assert condensedValue.key == "people"
assert condensedValue.value.kind == CVSequence

condensedValue = c("favorite","people", %"John", %"Katie")
assert condensedValue.section == "favorite"
assert condensedValue.key == "people"
assert condensedValue.value.kind == CVSequence