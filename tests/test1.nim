import iniplus, std/unittest

var
  table = newConfigTable()
  value: ConfigValue
  config: ConfigTable

suite "Basic tests":
  test "Inserting custom values into table":
    table.setKey("mamas_homemade_organic", "str", newCValue("Hi!"))
    assert table.getString("mamas_homemade_organic","str") == "Hi!"

  test "Inserting custom integer into table":
    table.setKey("mamas_homemade_organic", "int", newCValue(1000))
    assert table.getInt("mamas_homemade_organic","int") == 1000

  test "Inserting custom boolean into table":
    table.setKey("mamas_homemade_organic", "bool", newCValue(true))
    assert table.getBool("mamas_homemade_organic","bool") == true

  test "Inserting a custom array into a table":
    table.setKey("mamas_homemade_organic","array", newCValue(
      newCValue("Hello World!"),
      newCValue(1000),
      newCValue(true)
    ))
    assert table.getArray("mamas_homemade_organic", "array")[0].stringVal == "Hello World!"
    assert table.getArray("mamas_homemade_organic", "array")[1].intVal == 1000
    assert table.getArray("mamas_homemade_organic", "array")[2].boolVal == true

  test "getStringArray with array of single type":
    table = parseString("employees = [\"John\",\"Katie\",\"Anne\"]")
    assert table.getStringArray("", "employees") == @["John", "Katie", "Anne"]
    assert table.getStringArray("", "employees").len() == 3

  test "getStringArray with array of multiple types":
    table = parseString("employees = [\"John\",\"Katie\",1000]")
    var employees = table.getStringArray("","employees")
    assert employees[0] == "John"
    assert employees[1] == "Katie"
    assert len(employees) == 2

  test "getIntArray with array of single type":
    table = parseString("numbers = [1000, 2000, 3000]")
    var number = table.getIntArray("","numbers")

    assert number[0] == 1000
    assert number[1] == 2000
    assert number[2] == 3000
    assert len(number) == 3

  test "getIntArray with array of multiple types":
    table = parseString("numbers = [1000, 2000, \"Michael\"]")
    var number = table.getIntArray("","numbers")

    assert number[0] == 1000
    assert number[1] == 2000
    assert len(number) == 2
  
  test "getBoolArray with arrays of single type":
    table = parseString("[my_favorite]\nbooleans=[true, false]")
    var myFavoriteBooleans = table.getBoolArray("my_favorite","booleans")
        
    assert myFavoriteBooleans[0] == true
    assert myFavoriteBooleans[1] == false
    assert len(myFavoriteBooleans) == 2

  test "getBoolArray with arrays of multiple types":
    table = parseString("[my_favorite]\nbooleans=[true, \"Jimmy\", false]")
    var myFavoriteBooleans = table.getBoolArray("my_favorite","booleans")
        
    assert myFavoriteBooleans[0] == true
    assert myFavoriteBooleans[1] == false
    assert len(myFavoriteBooleans) == 2
  
  test "Parsing arrays of single type":
    table = parseString("employees = [\"John\",\"Katie\",\"Anne\"]")

    var employees = table.getArray("","employees")

    assert employees[0].kind == CVString
    assert employees[1].kind == CVString
    assert employees[2].kind == CVString

  test "Parsing arrays of multiple types":
    table = parseString("my_favorite_things = [1000, \"Katie\", true]")
    assert table.exists("", "my_favorite_things") == true

    var number = table.getArray("","my_favorite_things")
    assert number[0].intVal == 1000
    assert number[1].stringVal == "Katie"
    assert number[2].boolVal == true
    assert len(number) == 3
  
  test "Parsing strings":
    table = parseString("name = \"John Doe\"")
    assert   table.exists("","name") == true
    assert table.getValue("","name").kind == CVString
    assert table.getValue("","name").stringVal == "John Doe"
  
  test "Parsing integers":
    table = parseString("port = 1984")
    assert   table.exists("","port") == true
    assert table.getValue("","port").kind == CVInt
    assert table.getValue("","port").intVal == 1984

  test "Parsing booleans":
    table = parseString("enable_feature = false")
    assert   table.exists("","enable_feature") == true
    assert table.getValue("","enable_feature").kind == CVBool
    assert table.getValue("","enable_feature").boolVal == false

  test "getStringOrDefault":
    table = parseString("""
[dialog]
info_text = "Insert some informational text here."
    """)
    assert table.getString("dialog","info_text") == "Insert some informational text here."
    assert table.getStringOrDefault("dialog","help_text","Insert some helpful text here.") == "Insert some helpful text here."
  
  test "Creating custom arrays":
    config = parseString("my_favorite_people=[\"John\", \"Katie\", true]")

    assert config.getArray("","my_favorite_people")[0].stringVal == "John"
    assert config.getArray("","my_favorite_people")[1].stringVal == "Katie"
    assert config.getArray("","my_favorite_people")[2].boolVal == true

    config = parseString("my_favorite_people=[\"John\", \"Katie\", true]")
    value = newCValue(@[
        newCValue("John"),
        newCValue("Katie"),
        newCValue(true)
      ]
    )
    assert config.getValue("","my_favorite_people").arrayVal[0].stringVal == value.arrayVal[0].stringVal
    assert config.getValue("","my_favorite_people").arrayVal[1].stringVal == value.arrayVal[1].stringVal
    assert config.getValue("","my_favorite_people").arrayVal[2].boolVal == value.arrayVal[2].boolVal

  test "Creating custom booleans":
    config = parseString("favorite_boolean=true")
    value = newCValue(true)
    assert config.getValue("","favorite_boolean").boolVal == value.boolVal

  test "Creating custom integers":
    config = parseString("favorite_number=9001")
    value = newCValue(9001)    
    assert config.getValue("","favorite_number").intVal == value.intVal

  test "Creating custom strings":
    config = parseString("favorite_person_number_one=\"John\"")
    value = newCValue("John")
    assert config.getValue("","favorite_person_number_one").stringVal == value.stringVal

  test "toString with config table.":
    assert toString(parseString("test_key=\"Hello\"")) == "\ntest_key = \"Hello\"\n"

  test "toString with an individual value":
    assert toString(newCValue("John")) == "\"John\""

  test "setKey":
    table = newConfigTable()
    table.setKey(
      "favorite", # Section
      "person", # Key
      "John" # Value
    )
    assert table.getString("favorite","person") == "John"

  test "setKey bool":
    table = newConfigTable()
    table.setKey(
      "favorite", # Section
      "boolean", # Key
      true # Value
    )
    assert table.getBool("favorite","boolean") == true