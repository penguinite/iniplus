{.define: iniplusCheckmaps.}
import std/unittest, iniplus
suite "Checkmap tests":
  test "Creating simple CVType objects":
    assert @=(CVInt).kind == CVType
    assert @=(CVInt).child_t == CVNone
    assert @=(CVInt).t == CVInt
    assert @=(CVString).kind == CVType
    assert @=(CVString).child_t == CVNone
    assert @=(CVString).t == CVString
    assert @=(CVBool).kind == CVType
    assert @=(CVBool).child_t == CVNone
    assert @=(CVBool).t == CVBool
    
  test "Creating Array-based CVType objects":
    assert @=((CVArray, CVInt)).kind == CVType
    assert @=((CVArray, CVInt)).t == CVArray
    assert @=((CVArray, CVInt)).child_t == CVInt
    assert @=((CVArray, CVString)).kind == CVType
    assert @=((CVArray, CVString)).t == CVArray
    assert @=((CVArray, CVString)).child_t == CVString
    assert @=((CVArray, CVBool)).kind == CVType
    assert @=((CVArray, CVBool)).t == CVArray
    assert @=((CVArray, CVBool)).child_t == CVBool

  test "Creating Table-based CVType objects":
    assert @=((CVTable, CVInt)).kind == CVType
    assert @=((CVTable, CVInt)).t == CVTable
    assert @=((CVTable, CVInt)).child_t == CVInt
    assert @=((CVTable, CVString)).kind == CVType
    assert @=((CVTable, CVString)).t == CVTable
    assert @=((CVTable, CVString)).child_t == CVString
    assert @=((CVTable, CVBool)).kind == CVType
    assert @=((CVTable, CVBool)).t == CVTable
    assert @=((CVTable, CVBool)).child_t == CVBool
  
  test "Comphrensive require test":
    const required = {
      "db": {
        "password": @= CVString
      }.toTable,
      "instance": {
        "name": @= CVString,
        "summary": @= CVString,
        "description": @= CVString,
        "uri": @= CVString,
        "email": @= CVString
      }.toTable,
      "web": {
        "show_staff": @= CVBool,
        "port": @= CVInt
      }.toTable
    }

    let conf = parseString(
      """
[db]
password = "hunter2"
[instance]
name = "Amie's Amazing Avenue!"
summary = "A nice place to hangout!"
description = "For centuries, the free speech of Amie and Amiekind was suppressed in the name of preserving the global revolution. This is our headquarters where we fight for our rights! JOIN US OR PERISH!"
uri = "amies_encrypted_pothole_server.onion"
email = "amie@amiekind.com"
[web]
# We must hide our fellow revolutionaries!
show_staff=false
port=3500
      """,
      required)
    
    assert   conf.exists("db", "password") == true
    assert conf.getValue("db", "password").kind == CVString
    assert conf.getValue("db", "password").stringVal == "hunter2"
    assert   conf.exists("instance", "name") == true
    assert conf.getValue("instance", "name").kind == CVString
    assert conf.getValue("instance", "name").stringVal == "Amie's Amazing Avenue!"
    assert   conf.exists("instance", "summary") == true
    assert conf.getValue("instance", "summary").kind == CVString
    assert conf.getValue("instance", "summary").stringVal == "A nice place to hangout!"
    assert   conf.exists("instance", "description") == true
    assert conf.getValue("instance", "description").kind == CVString
    assert conf.getValue("instance", "description").stringVal == "For centuries, the free speech of Amie and Amiekind was suppressed in the name of preserving the global revolution. This is our headquarters where we fight for our rights! JOIN US OR PERISH!"
    assert   conf.exists("instance", "uri") == true
    assert conf.getValue("instance", "uri").kind == CVString
    assert conf.getValue("instance", "uri").stringVal == "amies_encrypted_pothole_server.onion"
    assert   conf.exists("instance", "email") == true
    assert conf.getValue("instance", "email").kind == CVString
    assert conf.getValue("instance", "email").stringVal == "amie@amiekind.com"
    assert   conf.exists("web", "show_staff") == true
    assert conf.getValue("web", "show_staff").kind == CVBool
    assert conf.getValue("web", "show_staff").boolVal == false
    assert   conf.exists("web", "port") == true
    assert conf.getValue("web", "port").kind == CVInt
    assert conf.getValue("web", "port").intVal == 3500

  test "Comphrensive optional test":
    const optional = {
      "db": {
        "host": @= "127.0.0.1:5432",
        "name": @= "pothole",
        "user": @= "pothole"
      }.toTable,
      "instance": {
        "rules": @= @[""],
        "languages": @= @["en"],
        "disguised_uri": @= "",
        "federated": @= true,
        "remote_size_limit": @= 30
      }.toTable,
      "web": {
        "show_staff": @= true,
        "show_version": @= true,
        "port": @= 3500,
        "endpoint": @= "/",
        "signin_link": @= "/auth/sign_in/",
        "signup_link": @= "/auth/sign_up/",
        "logout_link": @= "/auth/logout/",
        "whitelist_mode": @= false
      }.toTable,
      "storage": {
        "type": @= "flat",
        "uploads_folder": @= "uploads/",
        "upload_uri": @= "",
        "upload_server": @= "",
        "default_avatar_location": @= "default_avatar.webp",
        "upload_size_limit": @= 30
      }.toTable,
      "user": {
        "registrations_open": @= true,
        "require_approval": @= false,
        "require_verification": @= false,
        "max_attachments": @= 8,
        "max_chars": @= 2000,
        "max_poll_options": @= 20,
        "max_featured_tags": @= 10,
        "max_pins": @= 20
      }.toTable,
      "email": {
        "enabled": @= false,
        "host": @= "",
        "port": @= 0,
        "from": @= "",
        "ssl": @= true,
        "user": @= "",
        "pass": @= ""
      }.toTable,
      "mrf": {
        "active_builtin_policies": @= @["noop"],
        "active_custom_policies": @= @[""]
      }.toTable
    }
    let conf = parseString("", @[], optional)
    assert   conf.exists("db", "host") == true
    assert conf.getValue("db", "host").kind == CVString
    assert conf.getValue("db", "host").stringVal == "127.0.0.1:5432"
    assert   conf.exists("db", "name") == true
    assert conf.getValue("db", "name").kind == CVString
    assert conf.getValue("db", "name").stringVal == "pothole"
    assert   conf.exists("db", "user") == true
    assert conf.getValue("db", "user").kind == CVString
    assert conf.getValue("db", "user").stringVal == "pothole"

    assert   conf.exists("instance", "rules") == true
    assert conf.getValue("instance", "rules").kind == CVArray
    assert conf.getValue("instance", "rules").arrayVal == @[newCValue("")]
    assert   conf.exists("instance", "languages") == true
    assert conf.getValue("instance", "languages").kind == CVArray
    assert conf.getValue("instance", "languages").arrayVal == @[newCValue("en")]
    assert   conf.exists("instance", "disguised_uri") == true
    assert conf.getValue("instance", "disguised_uri").kind == CVString
    assert conf.getValue("instance", "disguised_uri").stringVal == ""
    assert   conf.exists("instance", "federated") == true
    assert conf.getValue("instance", "federated").kind == CVBool
    assert conf.getValue("instance", "federated").boolVal == true
    assert   conf.exists("instance", "remote_size_limit") == true
    assert conf.getValue("instance", "remote_size_limit").kind == CVInt
    assert conf.getValue("instance", "remote_size_limit").intVal == 30

    assert   conf.exists("web", "show_staff") == true
    assert conf.getValue("web", "show_staff").kind == CVBool
    assert conf.getValue("web", "show_staff").boolVal == true
    assert   conf.exists("web", "show_version") == true
    assert conf.getValue("web", "show_version").kind == CVBool
    assert conf.getValue("web", "show_version").boolVal == true
    assert   conf.exists("web", "port") == true
    assert conf.getValue("web", "port").kind == CVInt
    assert conf.getValue("web", "port").intVal == 3500
    assert   conf.exists("web", "endpoint") == true
    assert conf.getValue("web", "endpoint").kind == CVString
    assert conf.getValue("web", "endpoint").stringVal == "/"
    assert   conf.exists("web", "signin_link") == true
    assert conf.getValue("web", "signin_link").kind == CVString
    assert conf.getValue("web", "signin_link").stringVal == "/auth/sign_in/"
    assert   conf.exists("web", "signup_link") == true
    assert conf.getValue("web", "signup_link").kind == CVString
    assert conf.getValue("web", "signup_link").stringVal == "/auth/sign_up/"
    assert   conf.exists("web", "logout_link") == true
    assert conf.getValue("web", "logout_link").kind == CVString
    assert conf.getValue("web", "logout_link").stringVal == "/auth/logout/"
    assert   conf.exists("web", "whitelist_mode") == true
    assert conf.getValue("web", "whitelist_mode").kind == CVBool
    assert conf.getValue("web", "whitelist_mode").boolVal == false

    assert   conf.exists("storage", "type") == true
    assert conf.getValue("storage", "type").kind  == CVString
    assert conf.getValue("storage", "type").stringVal == "flat"
    assert   conf.exists("storage", "uploads_folder") == true
    assert conf.getValue("storage", "uploads_folder").kind  == CVString
    assert conf.getValue("storage", "uploads_folder").stringVal == "uploads/"
    assert   conf.exists("storage", "upload_uri") == true
    assert conf.getValue("storage", "upload_uri").kind  == CVString
    assert conf.getValue("storage", "upload_uri").stringVal == ""
    assert   conf.exists("storage", "upload_server") == true
    assert conf.getValue("storage", "upload_server").kind  == CVString
    assert conf.getValue("storage", "upload_server").stringVal == ""
    assert   conf.exists("storage", "default_avatar_location") == true
    assert conf.getValue("storage", "default_avatar_location").kind  == CVString
    assert conf.getValue("storage", "default_avatar_location").stringVal == "default_avatar.webp"
    assert   conf.exists("storage", "upload_size_limit") == true
    assert conf.getValue("storage", "upload_size_limit").kind  == CVInt
    assert conf.getValue("storage", "upload_size_limit").intVal == 30

    assert   conf.exists("user", "registrations_open") == true
    assert conf.getValue("user", "registrations_open").kind == CVBool
    assert conf.getValue("user", "registrations_open").boolVal == true
    assert   conf.exists("user", "require_approval") == true
    assert conf.getValue("user", "require_approval").kind == CVBool
    assert conf.getValue("user", "require_approval").boolVal == false
    assert   conf.exists("user", "require_verification") == true
    assert conf.getValue("user", "require_verification").kind == CVBool
    assert conf.getValue("user", "require_verification").boolVal == false
    assert   conf.exists("user", "max_attachments") == true
    assert conf.getValue("user", "max_attachments").kind == CVInt
    assert conf.getValue("user", "max_attachments").intVal == 8
    assert   conf.exists("user", "max_chars") == true
    assert conf.getValue("user", "max_chars").kind == CVInt
    assert conf.getValue("user", "max_chars").intVal == 2000
    assert   conf.exists("user", "max_poll_options") == true
    assert conf.getValue("user", "max_poll_options").kind == CVInt
    assert conf.getValue("user", "max_poll_options").intVal == 20
    assert   conf.exists("user", "max_featured_tags") == true
    assert conf.getValue("user", "max_featured_tags").kind == CVInt
    assert conf.getValue("user", "max_featured_tags").intVal == 10
    assert   conf.exists("user", "max_pins") == true
    assert conf.getValue("user", "max_pins").kind == CVInt
    assert conf.getValue("user", "max_pins").intVal == 20

    assert   conf.exists("email", "enabled") == true
    assert conf.getValue("email", "enabled").kind == CVBool
    assert conf.getValue("email", "enabled").boolVal == false
    assert   conf.exists("email", "host") == true
    assert conf.getValue("email", "host").kind == CVString
    assert conf.getValue("email", "host").stringVal == ""
    assert   conf.exists("email", "port") == true
    assert conf.getValue("email", "port").kind == CVInt
    assert conf.getValue("email", "port").intVal == 0
    assert   conf.exists("email", "from") == true
    assert conf.getValue("email", "from").kind == CVString
    assert conf.getValue("email", "from").stringVal == ""
    assert   conf.exists("email", "ssl") == true
    assert conf.getValue("email", "ssl").kind == CVBool
    assert conf.getValue("email", "ssl").boolVal == true
    assert   conf.exists("email", "user") == true
    assert conf.getValue("email", "user").kind == CVString
    assert conf.getValue("email", "user").stringVal == ""
    assert   conf.exists("email", "pass") == true
    assert conf.getValue("email", "pass").kind == CVString
    assert conf.getValue("email", "pass").stringVal == ""

    assert   conf.exists("mrf", "active_builtin_policies") == true
    assert conf.getValue("mrf", "active_builtin_policies").kind == CVArray
    assert conf.getValue("mrf", "active_builtin_policies").arrayVal == @[newCValue("noop")]
    assert   conf.exists("mrf", "active_custom_policies") == true
    assert conf.getValue("mrf", "active_custom_policies").kind == CVArray
    assert conf.getValue("mrf", "active_custom_policies").arrayVal == @[newCValue("")]
    
  test "Basic test!":
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

    let confA = parseString(
      """
    [instance]
    name = "Amie's Amazing Avenue"
    rules = ["No fun allowed", "Really... No fun allowed!"]
      """,
      required, optional
    )

    assert confA.exists("instance", "name") == true
    assert confA.getString("instance", "name") == "Amie's Amazing Avenue"

    assert confA.exists("instance", "rules") == true
    assert confA.getArray("instance", "rules").len() == 2
    assert confA.getArray("instance", "rules")[0].stringVal == "No fun allowed"
    assert confA.getArray("instance", "rules")[1].stringVal == "Really... No fun allowed!"
    assert confA.getStringArray("instance", "rules")[0] == "No fun allowed"
    assert confA.getStringArray("instance", "rules")[1] == "Really... No fun allowed!"

    assert confA.exists("instance", "description") == true
    assert confA.getString("instance", "description") == "A fun place to hang out! :D"

    assert confA.exists("instance", "staff_rules") == true
    assert confA.getArray("instance", "staff_rules").len() == 1
    assert confA.getArray("instance", "staff_rules")[0].stringVal == "Do whatever you want lol"
    assert confA.getStringArray("instance", "staff_rules")[0] == "Do whatever you want lol"

    assert confA.exists("instance", "coolness_level") == true
    assert confA.getInt("instance", "coolness_level") == 1000