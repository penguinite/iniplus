import iniplus

let conf = parseString("""
I_like_to = live # dangerously
I_love_to = "live # dangerously"

Id_like_to = "live "#dangerously
#Id_hate_to = live # safely

###aa=aa
##f=e
##d=e
#b=c
#a=b

""")

assert conf.getString("","I_like_to") == "live"
assert conf.getString("","I_love_to") == "live # dangerously"
assert conf.getString("","Id_like_to") == "live "


assert conf.exists("","Id_hate_to") != true
assert conf.exists("","aa") != true
assert conf.exists("","f") != true
assert conf.exists("","d") != true
assert conf.exists("","b") != true
assert conf.exists("","a") != true
assert conf.exists("","c") != true