import iniplus, std/unittest

let data = """
# An example configuration file for Pothole
# Use this as a base for your deployed configuration.

# Note: If you have any double quotes (") in your values then please escape them by backslashing them.

# Warning: Make sure to configure your postgres to have standard_conforming_strings DISABLED
# Otherwise, you will be vulnerable to SQL injections. See https://github.com/nim-lang/db_connector/issues/19
# Ultimately, its up to the nim-lang team to fix this, but I might submit a PR someday.
[db]

# This is the default value
# Using a Unix socket is way faster but that
# maybe requires configuring postgres.
# Just add the unix socket to the host key as-is
# if you want to go that route.
#
# Be aware that potholectl dev db and pothole db docker
# were explicitly designed with TCP/IP in mind, so using unix sockets
# might not be supported for those two commands.
host="127.0.0.1:5432"

# Database name
name="pothole"

# Database user login
user="pothole"

# Database user password
# You should avoid passwords with double quotes.
password="SOMETHING_SECRET"

## Instance specific settings

[instance]
# The name of your instance.
# This can be anything (Fx. Church of Penguin)
name="The Penguin Bazaar"

# Your instance's description. There are no specific requirements
# But it is a wise idea to keep it short.
summary="Explore a place of calm, beauty and true social communications."

description="Explore a place of calm, beauty and true social communications. The Penguin Bazaar contains many friendly people to chat with, merchants, customers, sorcerers, witches and many more!"

# This is the domain name that Pothole is running on.
# you should NEVER change it once it's set.
uri="localhost"

# This controls whether or not to enable "federation"
# Federation means to share posts with other servers that speak the same protocol (ActivityPub)
# Disabling this means that posts will not automatically be shared with other servers,
# and that other servers cannot share posts with you or your users.
#
# It is highly recommended that you leave this enabled, unless you're using Pothole
# to serve a private community (such as a forum)
# The default value is true.
federated=true

# This is the uri that outgoing ActivityPub JSON payloads will be disguised with.
# If you set this, do not change it, otherwise you will break quite a load of stuff.
# Assuming you set this up correctly, this feature will allow you to host a Pothole instance
# on a subdomain, but somehow let you disguise your posts as coming from whatever other
# subdomain you want.
# For example, you can set up your server on ph.example.com and make it so 
# your posts look like they come from @example.com
# 
# This is still unused however.
disguised_uri="example.com"


# The instance's email address
# If this is not set then it will just show up empty in MastoAPI
# Note: This option does *not* give people admin privileges.
# It simply provides a way for people to contact you (DMCA, abuse reports and so on.)
email="god@example.gov"

# The instance rules.
# You can add whatever you want here.
# If you leave this out then everything related to rules will show up empty
rules=[
    "You may not purchase or offer plastic bags.",
    "Humans are welcome (They are weird looking penguins after all)",
    "No seals, orcas, sea lions, sharks, armadillos, tasmanian devils, skuas, falcons, sheathbills, or petrels! Y'all suck!",
]
#rules=[]

# The logo for the instance.
# This can be left out, it is not required.
# Point it to a file in the static folder.
# So fx. if you have a logo stored as logo.webp then change this to
# static/logo.webp
logo=""

# TODO: There is another bug with iniplus and parsing keys with empty strings.... Damn it...

# Instance languages
# By default this is ["en"] for English
# But it can be replaced with nothing at all.
languages=[
    "en"
]

# If this is not present then upload_size_limit will be used.
# This controls the maximum upload size for remote posts.
# Anything higher will be dropped.
# The size is in megabytes
remote_size_limit=30

[web]
# By default Pothole will show instance staff in its website.
# You can disable this to hide it.
show_staff=true

# By default Pothole will show its version in its website.
# You can disable this to hide it.
show_version=true

# Specify which port the web server will
# run on. This is optional and Pothole
# will use 3500 by default
port=3500

# This controls where precisely the Pothole endpoint is.
# For example, if you have a webserver configured to serve https://example.com as a normal page
# and https://example.com/ph/ to Pothole, then you can change this to "/ph/"
# So the API stuff isn't all messed up.
# By default, this is "/"
#
# Oh and, if you don't understand what any of that was, then don't change it :P
endpoint="/"

# This controls how many posts will be rendered per page for a user profile
# 20 is a reasonable substitute and it's the default.
# You can set this to 0 to show all of a user's posts, but this isn't recommended since it will utterly destroy your database performance.
max_posts_per_page=20

# Changes the login link to point to somewhere else.
# This is useful for when you have a custom frontend and you want your users to easily log in.
# Default: "/auth/sign_in/"
signin_link="/auth/sign_in/"

# Changes the sign up link to point to somewhere else
# This is useful for when you have a custom frontend (that supports signing up) and you want users to easily log in.
# Default: "/auth/sign_up/"
signup_link="/auth/sign_up/"

# Changes the log out link to point to somewhere else
# This is useful for when you have a custom frontend (that supports signing up) and you want users to easily log in.
# Default: "/auth/logout/"
logout_link="/auth/logout/"

[storage]

# The static folder is used to store static files.
# Do not store user-generated content here.
static="static/"
# Templates is used to store Pothole's templates.
templates="templates/"

# Unused config options

# Pothole supports 2 different storage mechanisms.
# Flat storage: Uploads are handled by Pothole's web server, and copied to the folder configured in storage:upload_folder. Set this to "flat" to enable this.
# Remote proxy: Uploads are magically sent to whatever S3-compatible server you configure. (Incomplete) Set this to "remote" and configure the server to enable this feature.
# Which one is better? Well if it's a server only for you then consider setting up Flat storage *SECURELY*
# If it's for a large server or you wanna join a "media proxy collection" then set up Remote proxy.
type="flat"

# The user uploads directory. Any files uploaded by users will be available here.
# Provided that the storage type is set to flat
upload_folder="uploads/"

# If you have implemented a system such as the one described here: https://webb.spiderden.org/2023/05/26/pleroma-mitigation/
# then you can set this url to the "media server" you have. 
# Pothole will simply append the media it seeks to the end of whatever URL to add here, so:
# https://media.example.com/pothole/ turns into https://media.example.com/pothole/user_id/media_filename/
# If this is not set, then under a default config, Pothole will use the instance:uri option + /media/ like so:
# https://ph.example.com/media/user_id/media_filename/
upload_uri=""

#type="remote"
#upload_server="uh, idk s3?"
# TODO: Finish the S3 stuff.

# This will be appended on top of upload_uri (or instance:uri + "/media/")
# By default it is default_avatar.webp
default_avatar_location="default_avatar.webp"

# Controls the size limit for user uploads
# Anything higher than this size will be rejected with an error message.
# The size is in megabytes.
# Videos: 
upload_size_limit=10

[user]
# This option controls whether to enable or disable new user registrations
# This is on by default
registrations_open=true

# This option controls whether to require administrator approval for new
# user registrations.
# This is off by default.
require_approval=false

## The following feature is not completely implemented yet.
## I am just establishing a blueprint of what it will look like.

# Maximum number of media attachments for a post
# The default number is 8, this can be left out.
max_attachments=8

# How many characters are users allowed to write in a post.
# It is highly recommended to set this number to something above or equal to 2000.
# Note: Posts over this limit will not be federated.
# You can set it to 0 to disable. (Not recommended)
max_chars=2000

# Controls the maximum amount of choices that a user can have in a poll.
# The default is 20.
max_poll_options=20

# Controls the maximum amount of featured tags a user can insert in their profile
# The default is 10
max_featured_tags=10

# Controls how many posts a user can pin to the top of their profiles
# The default is 20
max_pins=20

[mrf]
# Built-in MRF policies to enable (Array of strings)
# Please read the documentation if you are confused at what each
# policy does.
active_builtin_policies=[
# noop is a simple "dummy" policy that does no rewriting whatsoever.
    "noop" 
]

active_custom_policies=[]

# If you have a large MRF policy set then it might make more sense
# to put it in a separate file. So that Pothole does not allocate
# too much memory for MRF policies on every web server thread.
config=""

[mrf.simple]
# Accept *only* from these instances.
# Aka. whitelisting/allowlisting.
# Note: If something comes from a server that *isn't* on this list then it will be rejected.
accept={}

# Reject everything from these instances.
reject={}

# Reject only posts if they originate from these instances
reject_post= {}

# Reject only users if they originate from these instances
reject_user={}

# Reject only activities (such as Likes, Boosts and so on) if they originate from these instances
reject_activity={}

# Hide posts away from the federated timeline if they originate from these instances
quarantine={}

# Mark media NSFW if it originates from these instances.
media_nsfw={}

# Remove all media originating from these instances
media_removal={}

# Remove avatars from users originating from these instances
avatar_removal={}

# Remove headers from users originating from these instances
header_removal={}

[misc]

# TODO: Document undocumented config options
# like template_obj_pool_size or whatever
"""

let conf = parseString(data)

suite "Pothole config file test":
  test "Section db":
    assert conf.exists("db", "host") == true
    assert conf.getValue("db", "host").kind == CVString
    assert conf.getValue("db", "host").stringVal == "127.0.0.1:5432"
    assert conf.exists("db", "name") == true
    assert conf.getValue("db", "name").kind == CVString
    assert conf.getValue("db", "name").stringVal == "pothole"
    assert conf.exists("db", "user") == true
    assert conf.getValue("db", "user").kind == CVString
    assert conf.getValue("db", "user").stringVal == "pothole"
    assert conf.exists("db", "password") == true
    assert conf.getValue("db", "password").kind == CVString
    assert conf.getValue("db", "password").stringVal == "SOMETHING_SECRET"
  test "Section instance":
    assert conf.exists("instance", "name") == true
    assert conf.getValue("instance", "name").kind == CVString
    assert conf.getValue("instance", "name").stringVal == "The Penguin Bazaar"
    assert conf.exists("instance", "summary") == true
    assert conf.getValue("instance", "summary").kind == CVString
    assert conf.getValue("instance", "summary").stringVal == "Explore a place of calm, beauty and true social communications."
    assert conf.exists("instance", "description") == true
    assert conf.getValue("instance", "description").kind == CVString
    assert conf.getValue("instance", "description").stringVal == "Explore a place of calm, beauty and true social communications. The Penguin Bazaar contains many friendly people to chat with, merchants, customers, sorcerers, witches and many more!"
    assert conf.exists("instance", "uri") == true
    assert conf.getValue("instance", "uri").kind == CVString
    assert conf.getValue("instance", "uri").stringVal == "localhost"
    assert conf.exists("instance", "federated") == true
    assert conf.getValue("instance", "federated").kind == CVBool
    assert conf.getValue("instance", "federated").boolVal == true
    assert conf.exists("instance", "disguised_uri") == true
    assert conf.getValue("instance", "disguised_uri").kind == CVString
    assert conf.getValue("instance", "disguised_uri").stringVal == "example.com"
    assert conf.exists("instance", "email") == true
    assert conf.getValue("instance", "email").kind == CVString
    assert conf.getValue("instance", "email").stringVal == "god@example.gov"
    assert conf.exists("instance", "rules") == true
    assert conf.getValue("instance", "rules").kind == CVArray
    assert conf.getValue("instance", "rules").arrayVal.len() == 3
    assert conf.getValue("instance", "rules").arrayVal[0].kind == CVString
    assert conf.getValue("instance", "rules").arrayVal[0].stringVal == "You may not purchase or offer plastic bags."
    assert conf.getValue("instance", "rules").arrayVal[1].kind == CVString
    assert conf.getValue("instance", "rules").arrayVal[1].stringVal == "Humans are welcome (They are weird looking penguins after all)"
    assert conf.getValue("instance", "rules").arrayVal[2].kind == CVString
    assert conf.getValue("instance", "rules").arrayVal[2].stringVal == "No seals, orcas, sea lions, sharks, armadillos, tasmanian devils, skuas, falcons, sheathbills, or petrels! Y'all suck!"
    assert conf.exists("instance", "logo") != true
    assert conf.exists("instance", "languages") == true
    assert conf.getValue("instance", "languages").kind == CVArray
    assert conf.getValue("instance", "languages").arrayVal.len() == 1
    assert conf.getValue("instance", "languages").arrayVal[0].kind == CVString
    assert conf.getValue("instance", "languages").arrayVal[0].stringVal == "en"
    assert conf.exists("instance", "remote_size_limit") == true
    assert conf.getValue("instance", "remote_size_limit").kind == CVInt
    assert conf.getValue("instance", "remote_size_limit").intVal == 30
  test "Section web":
    assert conf.exists("web", "show_staff") == true
    assert conf.getValue("web", "show_staff").kind == CVBool
    assert conf.getValue("web", "show_staff").boolVal == true
    assert conf.exists("web", "show_version") == true
    assert conf.getValue("web", "show_version").kind == CVBool
    assert conf.getValue("web", "show_version").boolVal == true
    assert conf.exists("web", "port") == true
    assert conf.getValue("web", "port").kind == CVInt
    assert conf.getValue("web", "port").intVal == 3500
    assert conf.exists("web", "endpoint") == true
    assert conf.getValue("web", "endpoint").kind == CVString
    assert conf.getValue("web", "endpoint").stringVal == "/"
    assert conf.exists("web", "max_posts_per_page") == true
    assert conf.getValue("web", "max_posts_per_page").kind == CVInt
    assert conf.getValue("web", "max_posts_per_page").intVal == 20
    assert conf.exists("web", "signin_link") == true
    assert conf.getValue("web", "signin_link").kind == CVString
    assert conf.getValue("web", "signin_link").stringVal == "/auth/sign_in/"
    assert conf.exists("web", "signup_link") == true
    assert conf.getValue("web", "signup_link").kind == CVString
    assert conf.getValue("web", "signup_link").stringVal == "/auth/sign_up/"
    assert conf.exists("web", "logout_link") == true
    assert conf.getValue("web", "logout_link").kind == CVString
    assert conf.getValue("web", "logout_link").stringVal == "/auth/logout/"
  test "Section storage":
    assert conf.exists("storage", "static") == true
    assert conf.getValue("storage", "static").kind == CVString
    assert conf.getValue("storage", "static").stringVal == "static/"
    assert conf.exists("storage", "templates") == true
    assert conf.getValue("storage", "templates").kind == CVString
    assert conf.getValue("storage", "templates").stringVal == "templates/"
    assert conf.exists("storage", "type") == true
    assert conf.getValue("storage", "type").kind == CVString
    assert conf.getValue("storage", "type").stringVal == "flat"
    assert conf.exists("storage", "upload_folder") == true
    assert conf.getValue("storage", "upload_folder").kind == CVString
    assert conf.getValue("storage", "upload_folder").stringVal == "uploads/"
    assert conf.exists("storage", "upload_uri") != true
    assert conf.exists("storage", "default_avatar_location") == true
    assert conf.getValue("storage", "default_avatar_location").kind == CVString
    assert conf.getValue("storage", "default_avatar_location").stringVal == "default_avatar.webp"
    assert conf.exists("storage", "upload_size_limit") == true
    assert conf.getValue("storage", "upload_size_limit").kind == CVInt
    assert conf.getValue("storage", "upload_size_limit").intVal == 10
  test "Section user":
    assert conf.exists("user", "registrations_open") == true
    assert conf.getValue("user", "registrations_open").kind == CVBool
    assert conf.getValue("user", "registrations_open").boolVal == true
    assert conf.exists("user", "require_approval") == true
    assert conf.getValue("user", "require_approval").kind == CVBool
    assert conf.getValue("user", "require_approval").boolVal == false
    assert conf.exists("user", "max_attachments") == true
    assert conf.getValue("user", "max_attachments").kind == CVInt
    assert conf.getValue("user", "max_attachments").intVal == 8
    assert conf.exists("user", "max_chars") == true
    assert conf.getValue("user", "max_chars").kind == CVInt
    assert conf.getValue("user", "max_chars").intVal == 2000
    assert conf.exists("user", "max_poll_options") == true
    assert conf.getValue("user", "max_poll_options").kind == CVInt
    assert conf.getValue("user", "max_poll_options").intVal == 20
    assert conf.exists("user", "max_featured_tags") == true
    assert conf.getValue("user", "max_featured_tags").kind == CVInt
    assert conf.getValue("user", "max_featured_tags").intVal == 10
    assert conf.exists("user", "max_pins") == true
    assert conf.getValue("user", "max_pins").kind == CVInt
    assert conf.getValue("user", "max_pins").intVal == 20
  test "Section mrf":
    assert conf.exists("mrf", "active_builtin_policies") == true
    assert conf.getValue("mrf", "active_builtin_policies").kind == CVArray
    assert conf.getArray("mrf", "active_builtin_policies").len() > 0
    assert conf.getArray("mrf", "active_builtin_policies")[0].kind == CVString
    assert conf.getArray("mrf", "active_builtin_policies")[0].stringVal == "noop"
    assert conf.exists("mrf", "active_custom_policies") == true
    assert conf.exists("mrf", "config") != true
  test "Section mrf.simple":
    assert conf.exists("mrf.simple", "accept") == true
    assert conf.getTable("mrf.simple", "accept").len() == 0
    assert conf.exists("mrf.simple", "reject") == true
    assert conf.getTable("mrf.simple", "reject").len() == 0
    assert conf.exists("mrf.simple", "reject_post") == true
    assert conf.getTable("mrf.simple", "reject_post").len() == 0
    assert conf.exists("mrf.simple", "reject_user") == true
    assert conf.getTable("mrf.simple", "reject_user").len() == 0
    assert conf.exists("mrf.simple", "reject_activity") == true
    assert conf.getTable("mrf.simple", "reject_activity").len() == 0
    assert conf.exists("mrf.simple", "quarantine") == true
    assert conf.getTable("mrf.simple", "quarantine").len() == 0
    assert conf.exists("mrf.simple", "media_nsfw") == true
    assert conf.getTable("mrf.simple", "media_nsfw").len() == 0
    assert conf.exists("mrf.simple", "media_removal") == true
    assert conf.getTable("mrf.simple", "media_removal").len() == 0
    assert conf.exists("mrf.simple", "avatar_removal") == true
    assert conf.getTable("mrf.simple", "avatar_removal").len() == 0
    assert conf.exists("mrf.simple", "header_removal") == true
    assert conf.getTable("mrf.simple", "header_removal").len() == 0
