import iniplus, std/unittest

let conf = parseString("""
I_like_to = live # dangerously
I_love_to = "live # dangerously"

Id_like_to = live#dangerously
Id_love_to = "live "#dangerously
#Id_hate_to = live # safely

###aa=aa
##f=e
##d=e
#b=c
#a=b

""")

suite "Strange syntax":
  test "Inline comment":
    assert conf.getString("","I_like_to") == "live"

  test "Inline comment quoted":
    assert conf.getString("","I_love_to") == "live # dangerously"
  
  test "Inline comment compact":
    assert conf.getString("","Id_like_to") == "live"
  
  test "Inline comment compact quoted":
    assert conf.getString("","Id_love_to") == "live "
  
  test "Inline comment in a comment":
    assert conf.exists("","Id_hate_to") != true
  
  test "Triple commented line":
    assert conf.exists("","aa") != true
  
  test "Double commented line":
    assert conf.exists("","f") != true

  test "Double commented line #2":
    assert conf.exists("","d") != true

  test "Single comment line":
    assert conf.exists("","a") != true

  test "Single comment line #2":
    assert conf.exists("","b") != true
  
  test "Nonexistent key-val pair":
    assert conf.exists("","c") != true
  
