# Panda - Pandoc add-ons (Lua filters for Pandoc)

Panda is a [Pandoc Lua filter](https://pandoc.org/lua-filters.html) that works on internal Pandoc's AST.

It provides several interesting features:

- variable expansion (minimalistic templating)
- conditional blocks
- file inclusion (e.g. for source code examples)
- script execution (e.g. to include the result of a command)
- diagrams (Graphviz, PlantUML, Asymptote, blockdiag, mermaid...)

Panda is heavily inspired by [abp](http:/cdelord.fr/abp) reimplemented as a Pandoc Lua filter.

# Installation

## Prerequisites

- [Pandoc](https://pandoc.org/installing.html)

## Installation from source

``` sh
$ git clone https://github.com/CDSoft/panda.git
$ cd panda
$ make install          # install panda and panda.lua in ~/.local/bin
```

## Test

``` sh
$ make test
```

## Usage

``` sh
$ pandoc -L panda.lua ...
```

or

``` sh
$ panda ...
```

# Documentation

The full documentation is in [doc/panda.md](doc/panda.md).
The rendered version of the documentation is here: <http://cdelord.fr/panda>.

# License

    This file is part of Panda.

    Panda is free software: you can redistribute it and/or modify
    it under the terms of the GNU General Public License as published by
    the Free Software Foundation, either version 3 of the License, or
    (at your option) any later version.

    Panda is distributed in the hope that it will be useful,
    but WITHOUT ANY WARRANTY; without even the implied warranty of
    MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
    GNU General Public License for more details.

    You should have received a copy of the GNU General Public License
    along with Panda.  If not, see <https://www.gnu.org/licenses/>.

    For further information about Panda you can visit
    http://cdelord.fr/panda
