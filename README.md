# iniplus

An INI parser written in Nim with support for extra datatypes such as arrays and tables. It's intended to be as performant as std/parsecfg but with a way friendly interface and design.

Documentation can be found [here](https://penguinite.github.io/iniplus/), you can also build the documentation locally by running `nimble docs` if you clone this repository

A simple `requires "iniplus ^= VERSION"` in your `.nimble` file and a `nimble ` (To download dependencies) is enough to import the project.

## Features/Drawbacks

1. iniplus does not support triple quoted string literals or raw string literals like `std/parsecfg` does.
2. iniplus does not support nesting sections.
3. iniplus supports arrays/sequences consisting of all the primitive data types.
4. iniplus supports tables consisting of strings, integers or booleans. But it does **not** support nested tables or arrays inside tables.
5. Mixing/nesting arrays and tables are a terrible idea. Don't do it. (I do want to fix this issue in the future.)

## Status

Everything has been implemented, here is a short list of all the available features we have:

1. The config file parser has been implemented.
2. There are functions to retrieve data from config files.
3. There are also functions to dump/convert a table into plain-text (Which can then be loaded again, convenient for saving tables you've modified. Be aware that saving config files will not save the comments associated with them.)
4. And there are functions to write data into and modify config tables.

Please create a new issue if there are any bugs or anything. The config file parser has been recently re-written and may have some edge cases that aren't yet accounted for, so please report an issue if it there is one.

It shouldn't crash when encountering unknown data, but if it does, then please report it and thank you. This library *has* been rigorously tested and has a comprehensive test suite but still, there might be edge cases.

## Compatability breaks

When using third-party modules such as this one in your codebase, it's a terrible idea to just download whatever the latest version happens to be.
Many README files for packages suggest using the `>=` operator for importing packages, which is a terrible, terrible idea!
If you use `>=` or `>` or whatever other operator then you're basically asking for pain (in the form of software breakage)

I try to not break iniplus, and I try to document moments whenever I do break iniplus, but it is unrealistic for me to stick with the same broken API for the rest of time.
(Table support and bulk value set support was basically a hack, and I want to give iniplus something nicer lol)

TL;DR iniplus **can** break compatability, if you don't like this then use one of the following methods to import iniplus.

(`0.3.3` is a placeholder, plate it with your own version obviously.)

```nim
requires "iniplus ^= 0.3.3" # This is the recommended way to import iniplus

requires "iniplus == 0.3.3" # Not bad, but also, you could use the semver-compatible operator and get compatible bug fixes.
requires "iniplus@0.3.3" # Same exact thing

requires "iniplus < 0.3.3"  # No minimum version but it's ok if u know what you're doing.
requires "iniplus <= 0.3.3" # Same thing here
```

And do NOT use one of these methods!

```nim
requires "iniplus >= 0.3.3" # Suspectible to breakage, no maximum limit.
requires "iniplus > 0.3.3" # Same thing

requires "iniplus" # Horrible! No minimum or maximum version!
requires "iniplus@head" # This is technically worse since HEAD could contain WIP commits.
```

Will iniplus 100% guarantee no breakage at all if you do as i say? Not 100%, as there are probably so many edge cases.

But the moral of the story is that you shouldn't blindly install whatever the latest version of iniplus is, especially not a existing codebase that is well-adapted to one specific version of it.

Also, if you are really serious about not getting broken dependencies then consider [locking your dependencies](https://nim-lang.github.io/nimble/workflow.html#nimble-lock)

## Copyright 

Copyright (c) penguinite 2023-2024 <penguinite@tuta.io>
Licensed under the BSD 3-Clause license.
