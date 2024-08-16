# Copyright (c) penguinite 2023 <penguinite@proton.me>
# Licensed under the BSD-3-Clause license
## This module contains the parser for the extended INI configuration format.
## It provides only two procedures, `parseFile` which takes a string as a filename.
runnableExamples "--run:off":
  discard parseFile("app.ini")
## and `parseString` which expects configuration data in its string input.
runnableExamples:
  discard parseString("key=\"value\"")

import objects, strutils
import private/utils
export objects

proc parseString*(input: string): ConfigTable =
  ## This procedure takes a string of some kind as its input and returns a parsed ConfigTable object.
  runnableExamples:
    import iniplus
    let config = parseString("my_favorite_key=\"My Favorite Value\"\n")
    assert config.getString("","my_favorite_key") == "My Favorite Value"

  var
    quoted, backSlash, commented = false
    tokens: seq[Token] = @[]
    tmp = ""

  proc add(k: TokenKind, i = "") =
    case k:
    of Literal, Quoted:
      if not tmp.isEmptyOrWhitespace():
        tokens.add(Token(kind: k, inner: strip(i)))
      tmp = ""
    else:
      if len(tmp) > 0:
        if quoted: add Quoted, tmp
        else: add Literal, tmp
        tmp = ""
      tokens.add(Token(kind: k))

  for ch in input:
    # Deal with comments right off the bat
    if commented:
      if ch == '\n':
        commented = false
      continue

    # And then deal with quotes
    if quoted:
      case ch:
      of '\\':
        # Pretty basic backslash handling.
        # If there are 2 backslashes in a row, then just insert a backslash into tmp.
        # Otherwise, flip the backslash boolean to true.
        if backslash:
          tmp.add('\\')
          backslash = false
        else:
          backslash = true
      of '"':
        # If there has been a backslash, then add a double quote into tmp
        # And disable backslash
        if backSlash:
          tmp.add('"')
          backSlash = false
          continue

        # Otherwise, disable quote flag.
        if len(tmp) > 0:
          add Quoted, tmp
        quoted = false
      else:
        tmp.add(ch)
      continue

    case ch:
    of '"':
      # If we see a double quote then turn on the quote flag
      if len(tmp) > 0:
        add Literal, tmp
      quoted = true
    # The above quote handling stuff means we can just
    # call add to add these and nothing else.
    # How clean...
    of '[': add SquareOpen
    of ']': add SquareClose
    of '=': add EqualSign
    of '{': add CurlyOpen
    of '}': add CurlyClose
    of ':': add Colon
    of ',': add Comma
    of '#': commented = true
    of '\n': add Newline
    else: tmp.add(ch)

  # One last check
  # To see if tmp is empty or not
  if quoted: add Quoted, tmp
  else: add Literal, tmp

  when defined(iniplusDebug):
    for token in tokens:
      echo "K: ", token.kind
      case token.kind:
      of Literal, Quoted:
        echo "I: \"", token.inner, "\""
      else: discard
      echo "---"

  var
    state = None
    section, key = ""
    tmpSeq: seq[string]

  for token in tokens:
    case token.kind:
    of SquareOpen:
      # If we haven't yet seen an equal sign then
      # this is most likely a section.
      case state:
      of None:
        state = Section
        # Although, we do have to clear the section variable.
        # Lest we royally mess up.
        section = ""
      of Val: state = Array
      else: discard

    of SquareClose:
      # If we are currently parsing an array then
      # y'know, parse an array... Otherwise assume it's a section
      # and just close the section.
      case state:
      of Section: state = None
      of Array:
        state = None
        result[(section, key)] = conv(tmpSeq)
        tmpSeq = @[]
      else: discard

    of EqualSign:
      # If we haven't yet seen anything and we have already added a key
      # then just start parsing the next tokens as values
      if state == None and len(key) > 0:
        state = Val

    of CurlyOpen:
      # If we are parsing values then just start parsing the next tokens
      # as a table.
      if state == Val:
        state = CTable

    of CurlyClose:
      # If we're parsing tables then y'know, parse the table and add it to the result
      if state == CTable:
        state = None
        result[(section, key)] = conv(tmpSeq, true)
        tmpSeq = @[]

    of Newline:
      # If we're parsing a single-value key and we suddenly see a newline
      # without seeing any literals or whatever, then we just leave that key alone
      # and reset the state.
      if state == Val:
        state = None
        key = ""

    of Literal, Quoted:
      # Do a range of stuff depending on our current state
      case state:
      # Just copy it as the section
      of Section: section.add(token.inner)
      # If we aren't parsing anything then use it as the key
      of None: key = token.inner
      # If we are parsing something then use it as the value
      # and add it to the table.
      # But DO keep the quotes. They'll be trimmed later anyway
      of Val:
        if token.kind == Quoted:
          result[(section, key)] = conv("\"" & token.inner & "\"")
        else:
          result[(section, key)] = conv(token.inner)
        state = None
      # If we are parsing arrays/tables then just add it to the tmpseq where it will be handled later
      of Array, CTable: tmpSeq.add(token.inner)
    else: discard # We don't use comma or colon, but y'know, we parse them so they are kept out of the Literal and Quotes tokens.
  
proc parseFile*(filename: string): ConfigTable =
  ## Opens a file, reads the entirety of it and returns a configuration table.
  runnableExamples "--run:off":
    let config = parseFile("app.ini")
  return parseString(filename.readFile())
