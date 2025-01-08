% Panda - Pandoc add-ons (Lua filters for Pandoc)
% Christophe Delord - <http://cdelord.fr/panda>
% 9th July 2024

[panda]: http://cdelord.fr/panda "Pandoc add-ons (Lua filters for Pandoc)"
[GraphViz]: http://graphviz.org/
[PlantUML]: http://plantuml.sourceforge.net/
[ditaa]: http://ditaa.sourceforge.net/
[blockdiag]: http://blockdiag.com/
[Asymptote]: http://asymptote.sourceforge.net/
[mermaid]: https://mermaidjs.github.io/
[R]: https://www.r-project.org/
[Pandoc]: http://pandoc.org/
[Pandoc Lua filter]: http://pandoc.org/lua-filters.html
[Python]: https://www.python.org/
[Lua]: http://www.lua.org/
[GitHub]: https://github.com/CDSoft/panda
[cdelord.fr]: http://cdelord.fr
[gnuplot]: http://www.gnuplot.info/
[lsvg]: http://cdelord.fr/lsvg/
[ypp]: http://cdelord.fr/ypp "Yet a PreProcessor"
[LuaX]: http://cdelord.fr/luax "Lua eXtended interpretor"

About panda
===========

Panda is a [Pandoc Lua filter] that works on internal Pandoc's AST.

It provides several interesting features:

- variable expansion (minimalistic templating)
- conditional blocks
- file inclusion (e.g. for source code examples)
- script execution (e.g. to include the result of a command)
- diagrams ([Graphviz], [PlantUML], [ditaa], [Asymptote], [blockdiag], [mermaid]...)

Panda is heavily inspired by [abp](http:/cdelord.fr/abp) reimplemented as a [Pandoc Lua filter].

If you need a more generic text preprocessor, [ypp] may be a better choice.

Open source
===========

[Panda] is an Open source software.
Anybody can contribute on [GitHub] to:

- suggest or add new features
- report or fix bugs
- improve the documentation
- add some nicer examples
- find new usages
- ...

If you like Panda (or LuaX) and are willing to support its development,
please consider donating via [Github](https://github.com/sponsors/CDSoft?o=esc)
or [Liberapay](https://liberapay.com/LuaX/donate).

Installation
============

1. Download the sources: `git clone https://github.com/CDSoft/panda`.
2. Run `ninja test` to run tests.
3. Run `ninja install` to install `panda` and `panda.lua` to `~/.local/bin`
   or `PREFIX=prefix ninja install` to install `panda` and `panda.lua` to `prefix/bin`

`panda` and `panda.lua` can also be installed anywhere. Nothing else is required (except from [Pandoc] obviously).

Usage
=====

`panda.lua` is a [Pandoc Lua filter] and is not meant to be called directly.
`panda` is just a shell script that calls `pandoc -L panda.lua ...`.

``` sh
$ pandoc -L panda.lua ...
```

or

``` sh
$ panda ...
```

A complete example is given as a Makefile in the doc directory.

Cheat sheet
===========

+-------------------+---------------+---------------------------+-----------------------------------------------+
| Syntactic item    | Class         | Attributes                | Description                                   |
+===================+===============+===========================+===============================================+
| any string        |               |                           | `{{var}}` is replaced by the value of `var`   |
|                   |               |                           | if it is defined (variables can be            |
|                   |               |                           | environment variables or Lua variables)       |
+-------------------+---------------+---------------------------+-----------------------------------------------+
| any block         | `comment`     |                           | commented block                               |
+-------------------+---------------+---------------------------+-----------------------------------------------+
| any block         |               | `include=file`            | replaces the div block with the content of    |
|                   |               |                           | `file` (rendered according to its format)     |
+-------------------+---------------+---------------------------+-----------------------------------------------+
| div block         |               | `doc=file`                | replaces the div block with text blocks from  |
|                   |               | `from=start_pattern`      | `file` (rendered according to its format).    |
|                   |               | `to=end_pattern`          | Blocks are separated by the patterns `from`   |
|                   |               |                           | and `to` (`@@@` is the default separator).    |
+-------------------+---------------+---------------------------+-----------------------------------------------+
| div block,        |               | `shift=n`                 | adds `n` to header levels in an imported      |
| code block        |               |                           | div block                                     |
+-------------------+---------------+---------------------------+-----------------------------------------------+
| div block,        |               | `pattern="Lua string      | applies a Lua string pattern to the content   |
| code block        |               | pattern"`                 | of the file. The emitted text is `format`.    |
|                   |               | `format="output           | `format` may contain captures from `pattern`. |
|                   |               | format"`                  |                                               |
+-------------------+---------------+---------------------------+-----------------------------------------------+
| code block        | `meta`        |                           | definitions for the string expansion          |
|                   |               |                           | (Lua script), defined in the code block       |
+-------------------+---------------+---------------------------+-----------------------------------------------+
| any block,        | `if`          | `name=val`                | block emitted only if `name`'s value is `val` |
| any inline        |               |                           |                                               |
+-------------------+---------------+---------------------------+-----------------------------------------------+
| code block,       |               | `include=file`            | replaces the code block content with the      |
| inline code       |               |                           | content of `file`                             |
+-------------------+---------------+---------------------------+-----------------------------------------------+
| code block,       |               | `fromline=n`              | includes a file from line number `n`          |
| inline code       |               | `from=n`                  |                                               |
+-------------------+---------------+---------------------------+-----------------------------------------------+
| code block,       |               | `toline=n`                | includes a file up to line number `n`         |
| inline code       |               | `to=n`                    |                                               |
+-------------------+---------------+---------------------------+-----------------------------------------------+
| code block,       |               | `cmd="shell command"`     | replaces the code block by the result of the  |
| inline code       |               | `icmd="shell command"`    | shell command. With`icmd` the code block      |
|                   |               |                           | content is parsed by Pandoc and included in a |
|                   |               |                           | Div block.                                    |
+-------------------+---------------+---------------------------+-----------------------------------------------+
| code block        |               | `render="command"`        | replaces the code block by a link to the      |
|                   |               |                           | image produced by the command (`%i` is the    |
|                   |               |                           | input file name, its content is the content   |
|                   |               |                           | of the code block, `%o` is the output file    |
|                   |               |                           | name)                                         |
+-------------------+---------------+---------------------------+-----------------------------------------------+

Commented blocks
================

Div blocks with the `comment` class are commented:

``` markdown
::: comment
This block is a comment and is discarded by panda.
:::
```

String expansion
================

`panda` stores variables in an environment used to expand strings.
Variables can be defined by a Lua script with the `meta` class.
The `include` attribute can also be used to point to an external file.
Variables can only contain inline elements, not blocks.

The initial environment contains:

- the environment variables
- the document metadata (title, author, date)
- `vars` alias of `PANDOC_WRITER_OPTIONS.variables`{.lua} to access pandoc variables given on the command line

Variable names are enclosed between double curly brackets.

E.g.:

~~~markdown
```meta
foo = "bar (note: this is parsed as **Markdown**)"
```

foo is {{foo}}.
~~~

~~~markdown
```{.meta include=foo.lua}
This text is ignored, definitions are in foo.lua.
```

foo is defined in `foo.lua` and is {{foo}}.
~~~

`meta` code blocks contain Lua code executed by the Pandoc Lua interpretor.
Panda also contains the [LuaX] modules reimplemented in Lua.
More details are available in the [Luax documentation].

Conditional blocks
==================

Blocks can be conditionally kept or omitted. The condition is described with attributes.

```markdown
:::{.if name="value"}
This block is emitted only if the value of the variable "name" is "value"
:::
```

Div inclusion
=============

Fragments of documents can be imported from external files.
The `include` attribute contains the name of the file to include.
The content of the file is parsed according to its format (deduced from its name)
and replaces the div block content.

~~~markdown
:::{include=file.md shift=n}
This text is optional and will be replaced by the content of file.md.
Section title levels are shifted by n (0 if not specified).
:::
~~~

The included file can be in a different format
(e.g. a markdown file can include a reStructuredText file).

If the block has an input format as a class, the file is parsed according to
this format.

Block inclusion
===============

Code examples can be imported from external files.
The `include` attribute contains the name of the file to include.
The content of the file replaces the code block content.

~~~markdown
```{.c include=foo.c fromline=3 toline=10 pattern="Lua string pattern" format="%1"}
This text is optional and will be replaced by the content of foo.c.
```
~~~

The optional `fromline` and `toline` defines the first and last lines to be included.

The optional pattern describes the part of the text that will be rendered.
The format uses the captures defined by the pattern to format the content of the block
(`"%1"` if not defined).

If the block has an input format as a class, its result is parsed according to
this format.

Documentation extraction
========================

Documentation fragments can be extracted from other source code files.
The `doc` attribute contains the name of the file where documentation is extracted.
All the documentation blocks are extracted, concatenated and parsed.
The result replaces the div block content.

~~~markdown
:::{doc=file.h shift=n from="@@@" to="@@@"}
This text is optional and will be replaced by the content of file.h
which is delimited by @@@.
Section title levels are shifted by n (0 if not specified).
:::
~~~

Scripts
=======

Scripts can be executed by inline or code blocks.
The `cmd` attribute defines the command to execute.
The content of the block is in a temporary file which name is added to the command.
If the command contains the `%s` char, it is replaced by the temporary file name.
If the command does not contain any `%s`, the file name is appended to the command.
The result replaces the content of the code block.

`icmd` can be used instead of `cmd` to let Pandoc parse the result of the command
and include it in the document as a Span or Div node.

An explicit file extension can be given after `%s` for languages that require
specific file extensions (e.g. `%s.fs` for F#).

+-------------------------------------------------------+-------------------------------------------------------+
| Source                                                | Result                                                |
+=======================================================+=======================================================+
| ~~~ markdown                                          |                                                       |
| ```{.python cmd=python}                               | ```{.python cmd=python}                               |
| print("Hello from Python!")                           | print("Hello from Python!")                           |
| ```                                                   | ```                                                   |
| ~~~                                                   |                                                       |
+-------------------------------------------------------+-------------------------------------------------------+
| ~~~ markdown                                          |                                                       |
| Lua says `print "Hello from Lua!"`{icmd=lua}          | Lua says `print "Hello from Lua!"`{icmd=lua}          |
| ~~~                                                   |                                                       |
+-------------------------------------------------------+-------------------------------------------------------+

Note: `{.python cmd=python}` is equivalent to `{.python cmd="python %s"}` and `{.python cmd="python %s.py"}`.

Diagrams
========

Code blocks containing diagrams are replaced with an image resulting from the diagram source code.

The render command is the `render` field.
The output image name is a hash computed from the diagram source code.

The description of the image is in the `caption` and `alt` fields.
`caption` is the caption of the diagram. `alt` is the alternative description of the diagram.
The optional `target` field is a URL pointed by the image.

In the `render` command, `%i` is replaced by the name of the input document
(generated from the content of the code block) and
`%o` by the name of the output image file.

Images are generated in a directory given by:

- the environment variable `PANDA_IMG` if it is defined
- the directory name of the output file if the Pandoc output is a file
- the `img` directory in the current directory

The file format (extension) must be in the `render` field,
after the `%o` tag (e.g.: `%o.png`).

If the program requires a specific input file extension, it can be specified in the `render` field,
after the `%i` tag (e.g.: `%i.xyz`).

Optional fields can be given to set some options:

- `name` defines the name of the image file.
  This can help distributing documents with user friendly image names.

```meta
_plantuml = "{{plantuml}}"
_build = "output_path"
```

+---------------------------------------+-------------------------------------------------+
| Source                                | Result                                          |
+=======================================+=================================================+
| ~~~ markdown                          |                                                 |
| ``` { render="{{_plantuml}}"          | ``` { render="{{plantuml}}" name=alice_and_bob  |
|       caption="Caption"               |       caption="Caption"                         |
|       alt="Alternative description" } |       alt="Alternative description" }           |
| @startuml                             | @startuml                                       |
| Alice -> Bob: hello                   | Alice -> Bob: hello                             |
| @enduml                               | @enduml                                         |
| ```                                   | ```                                             |
| ~~~                                   |                                                 |
+---------------------------------------+-------------------------------------------------+

Some render commands are predefined:

Diagram         Predefined variable     Render command
--------------- ----------------------- ---------------------
[GraphViz]      `dot`                   `{{dot}}`
                `dot.svg`               `{{dot.svg}}`
                `dot.png`               `{{dot.png}}`
                `dot.pdf`               `{{dot.pdf}}`
[PlantUML]      `plantuml`              `{{plantuml}}`
                `plantuml.svg`          `{{plantuml.svg}}`
                `plantuml.png`          `{{plantuml.png}}`
                `plantuml.pdf`          `{{plantuml.pdf}}`
[Asymptote]     `asy`                   `{{asy}}`
                `asy.svg`               `{{asy.svg}}`
                `asy.png`               `{{asy.png}}`
                `asy.pdf`               `{{asy.pdf}}`
[blockdiag]     `blockdiag`             `{{blockdiag}}`
                `blockdiag.svg`         `{{blockdiag.svg}}`
                `blockdiag.png`         `{{blockdiag.png}}`
                `blockdiag.pdf`         `{{blockdiag.pdf}}`
[mermaid]       `mmdc`                  `{{mmdc}}`
                `mmdc.svg`              `{{mmdc.svg}}`
                `mmdc.png`              `{{mmdc.png}}`
                `mmdc.pdf`              `{{mmdc.pdf}}`
[ditaa]         `ditaa`                 `{{ditaa}}`
                `ditaa.svg`             `{{ditaa.svg}}`
                `ditaa.png`             `{{ditaa.png}}`
[gnuplot]       `gnuplot`               `{{gnuplot}}`
                `gnuplot.svg`           `{{gnuplot.svg}}`
                `gnuplot.png`           `{{gnuplot.png}}`
                `gnuplot.pdf`           `{{gnuplot.pdf}}`
[lsvg]          `lsvg`                  `{{lsvg}}`
                `lsvg.svg`              `{{lsvg.svg}}`
                `lsvg.png`              `{{lsvg.png}}`
                `lsvg.pdf`              `{{lsvg.pdf}}`

Notes:

- `dot`: [GraphViz] support also includes `dot`, `neato`, `twopi`, `circo`, `fdp`, `sfdp`, `patchwork` and `osage`.

- `plantuml`: `PLANTUML` can be defined as an environment variable.
  Its default value is the directory of the `panda.lua` script appended with `"plantuml.jar"`.

- `ditaa`: `DITAA` can be defined as an environment variable.
  Its default value is the directory of the `panda.lua` script appended with `"ditaa.jar"`.

- `blockdiag`: [Blockdiag] support also includes `actdiag`, `blockdiag`, `nwdiag`, `packetdiag`, `rackdiag`
  and `seqdiag`.

- renderers without an explicit image format are built differently according to the output document format.

    - For PDF (LaTeX) documents, the default format is PDF
    - For other documents, the default format is SVG

E.g.:

```meta
_dot = "{{dot}}"
_gnuplot = "{{gnuplot}}"
```

+-------------------------------------------+-----------------------------------------------------+
| Source                                    | Result                                              |
+===========================================+=====================================================+
| ~~~ markdown                              |                                                     |
| ```{.dot render="{{_dot}}"}               | ```{.dot render="{{dot}}" name=panda}               |
| digraph {                                 | digraph {                                           |
|     rankdir=LR;                           |     rankdir=LR;                                     |
|     input -> pandoc -> output             |     input -> pandoc -> output                       |
|     pandoc -> panda -> {pandoc, diagrams} |     pandoc -> panda -> {pandoc, diagrams}           |
|     { rank=same; pandoc, panda }          |     { rank=same; pandoc, panda }                    |
|     { rank=same; diagrams, output }       |     { rank=same; diagrams, output }                 |
| }                                         | }                                                   |
| ```                                       | ```                                                 |
| ~~~                                       |                                                     |
+-------------------------------------------+-----------------------------------------------------+
| ~~~ markdown                              |                                                     |
| ```{ render="{{_gnuplot}}"}               | ```{ render="{{gnuplot}}" name=gnuplot}             |
| set xrange [-pi:pi]                       | set xrange [-2*pi:2*pi]                             |
| set yrange [-1.5:1.5]                     | set yrange [-1.5:1.5]                               |
| plot sin(x) lw 4, cos(x) lw 4             | plot sin(x) lw 4, cos(x) lw 4                       |
| ```                                       | ```                                                 |
| ~~~                                       |                                                     |
+-------------------------------------------+-----------------------------------------------------+

Filters can be combined. E.g.: a diagram can be stored in an external file, included and rendered by `panda`.

```meta
_doc = "path"
```

+-------------------------------------------+-------------------------------------------+
| Source                                    | Result                                    |
+===========================================+===========================================+
| ~~~ markdown                              |                                           |
| The file `hello.dot` contains:            | The file `hello.dot` contains:            |
|                                           |                                           |
| ```{.dot include="{{_doc}}/hello.dot"     | ```{.dot include="{{vars.doc}}/hello.dot" |
|          pattern="digraph%s*%b{}" }       |          pattern="digraph%s*%b{}" }       |
| ```                                       | ```                                       |
| ~~~                                       |                                           |
+-------------------------------------------+-------------------------------------------+
| ~~~ markdown                              |                                           |
| and is rendered as:                       | and is rendered as:                       |
|                                           |                                           |
| ```{ render="{{_dot}}"                    | ```{ render="{{dot}}" name=hello          |
|      include="{{_doc}}/hello.dot" }       |      include="{{vars.doc}}/hello.dot" }   |
| ```                                       | ```                                       |
| ~~~                                       |                                           |
+-------------------------------------------+-------------------------------------------+

Makefile dependencies
=====================

It is sometimes useful to build a dependency list on the fly.
`panda` can generate a dependency list for make, in the same vein than the gcc `-M` option.
The environment variable `PANDA_TARGET` must be defined with the target name.
`panda` will generate a file named `${PANDA_TARGET}.d`{.sh} containing the dependencies of `${PANDA_TARGET}`{.sh}.

The dependency filename can be redefined with the environment variable
`PANDA_DEP_FILE` (e.g. to save the dependency file in a different directory).

`PANDA_TARGET` and `PANDA_DEP_FILE` can also be defined by the pandoc variables `panda_target` and `panda_dep_file`
(e.g. `pandoc -Vpanda_target=... -Vpanda_dep_file=...`).

E.g.:

``` sh
PANDA_TARGET=index.html panda index.md -o index.html
```

This will produce a file named `index.html.d` containing `index.html: ...`.

Licenses
========

## Panda

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

Feedback
========

Your feedback and contributions are welcome.
You can contact me at [cdelord.fr].
