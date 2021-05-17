% Panda - Pandoc add-ons (Lua filters for Pandoc)
% Christophe Delord - <http://cdelord.fr/panda>
% 30th April 2021

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
[UPP]: http://cdelord.fr/upp "Universal PreProcessor"

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

If you need a more generic text preprocessor, [UPP] may be a better choice.

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

Installation
============

1. Download the sources: `git clone https://github.com/CDSoft/panda`.
2. Run `make test` to run tests.
3. Run `make install` to install `panda` and `panda.lua` to `~/.local/bin` (see `INSTALL_PATH` in `Makefile`).

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

+-------------------+---------------+-----------------------+-----------------------------------------------+
| Syntactic item    | Class         | Attributes            | Description                                   |
+===================+===============+=======================+===============================================+
| any string        |               |                       | `{{var}}` is replaced by the value of `var`   |
|                   |               |                       | if it is defined (variables can be            |
|                   |               |                       | environment variables or Lua variables)       |
+-------------------+---------------+-----------------------+-----------------------------------------------+
| div block         | `comment`     |                       | commented block                               |
+-------------------+---------------+-----------------------+-----------------------------------------------+
| div block         |               | `include=file`        | replaces the div block with the content of    |
|                   |               |                       | `file` (rendered according to its format)     |
+-------------------+---------------+-----------------------+-----------------------------------------------+
| div block         |               | `shift=n`             | adds `n` to header levels in an imported      |
|                   |               |                       | div block                                     |
+-------------------+---------------+-----------------------+-----------------------------------------------+
| div block,        |               | `pattern="Lua string  | applies a Lua string pattern to the content   |
| code block        |               | pattern"`             | of the file. The emitted text is `format`.    |
|                   |               | `format="output       | `format` may contain captures from `pattern`. |
|                   |               | format"`              |                                               |
+-------------------+---------------+-----------------------+-----------------------------------------------+
| code block        | `meta`        |                       | definitions for the string expansion          |
|                   |               |                       | (Lua script), defined in the code block       |
+-------------------+---------------+-----------------------+-----------------------------------------------+
| any block         |               | `ifdef=name`          | block emitted only if `name` is defined       |
+-------------------+---------------+-----------------------+-----------------------------------------------+
| any block         |               | `ifdef=name value=val`| block emitted only if `name` is defined and   |
|                   |               |                       | its value is `value`                          |
+-------------------+---------------+-----------------------+-----------------------------------------------+
| any block         |               | `ifndef=name`         | block emitted only if `name` is not defined   |
+-------------------+---------------+-----------------------+-----------------------------------------------+
| code block,       |               | `include=file`        | replaces the code block content with the      |
| inline code       |               |                       | content of `file`                             |
+-------------------+---------------+-----------------------+-----------------------------------------------+
| code block,       |               | `fromline=n`          | includes a file from line number `n`          |
| inline code       |               |                       |                                               |
+-------------------+---------------+-----------------------+-----------------------------------------------+
| code block,       |               | `toline=n`            | includes a file up to line number `n`         |
| inline code       |               |                       |                                               |
+-------------------+---------------+-----------------------+-----------------------------------------------+
| code block,       |               | `cmd="shell command"` | replaces the code block by the result of the  |
| inline code       |               |                       | shell command                                 |
+-------------------+---------------+-----------------------+-----------------------------------------------+
| code block        |               | `render="command"`    | replaces the code block by a link to the      |
|                   |               |                       | image produced by the command (`%i` is the    |
|                   |               |                       | input file name, its content is the content   |
|                   |               |                       | of the code block, `%o` is the output file    |
|                   |               |                       | name)                                         |
+-------------------+---------------+-----------------------+-----------------------------------------------+
| code block        |               | `img="image path"`    | URL of the image produced by `render`         |
|                   |               |                       | (optional, the default value is a generated   |
|                   |               |                       | name in the `./.panda` directory).            |
+-------------------+---------------+-----------------------+-----------------------------------------------+
| code block        |               | `out="image path"`    | path of the image produced by `render`        |
|                   |               |                       | (optional, the default value is `img`)        |
+-------------------+---------------+-----------------------+-----------------------------------------------+

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

Conditional blocks
==================

Blocks can be conditionally kept or omitted. The condition is described with attributes.

```markdown
:::{ifdef="name" value="value"}
This block is emitted only if the variable "name" is defined
and its value is "value"
:::
```

```markdown
:::{ifdef="name"}
This block is emitted only if the variable "name" is defined
(whatever its value)
:::
```

```markdown
:::{ifndef="name"}
This block is emitted only if the variable "name" is **not** defined
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

Scripts
=======

Scripts can be executed by inline or code blocks.
The `cmd` attribute defines the command to execute.
The content of the block is in a temporary file which name is added to the command.
If the command contains the `%s` char, it is replaced by the temporary file name.
If the command does not contain any `%s`, the file name is appended to the command.
The result replaces the content of the code block.

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
| Python says `print("Hello from Python!")`{cmd=python} | Python says `print("Hello from Python!")`{cmd=python} |
| ~~~                                                   |                                                       |
+-------------------------------------------------------+-------------------------------------------------------+

Diagrams
========

Code blocks containing diagrams are replaced with an image resulting from the diagram source code.

The render command is the `render` field.
The output image can be a hash computed from the diagram source code or the value of the `img` field.
The optional `out` field overloads `img` to change the output directory when rendering the diagram.

In the `render` command, `%i` is replaced by the name of the input document
(generated from the content of the code block) and
`%o` by the name of the output image file (generated from the `img` field).

The `img` field is optional. The default value is a name generated in the directory given by the
environment variable `PANDA_CACHE` (`.panda` if `PANDA_CACHE` is not defined).

If `img` contains `%h`, it is replaced by a hash computed from the diagram source.

The file format (extension) must be in the `render` field,
after the `%o` tag (e.g.: `%o.png`), not in the `img` field.

```meta
_plantuml = "{{plantuml}}"
_build = "{{build}}"
```

+---------------------------------------+-------------------------------------------------+
| Source                                | Result                                          |
+=======================================+=================================================+
| ~~~ markdown                          |                                                 |
| ``` { render="{{_plantuml}}"          | ``` { render="{{plantuml}}"                     |
|       img="img/panda_plantuml_demo"   |       img="{{build}}/img/panda_plantuml_demo"   |
|       out="{{_build}}/img" }          |       out="{{build}}/img" }                     |
| @startuml                             | @startuml                                       |
| Alice -> Bob: hello                   | Alice -> Bob: test                              |
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

Notes:

- `dot`: [GraphViz] support also includes `dot`, `neato`, `twopi`, `circo`, `fdp`, `sfdp`, `patchwork` and `osage`.

- `plantuml`: `PLANTUML` can be defined as an environment variable.
  Its default value is the directory of the `panda.lua` script appended with `"plantuml.jar"`.

- `ditaa`: `DITAA` can be defined as an environment variable.
  Its default value is the directory of the `panda.lua` script appended with `"ditaa.jar"`.

- `blockdiag`: [Blockdiag] support also includes `actdiag`, `blockdiag`, `nwdiag`, `packetdiag`, `rackdiag`
  and `seqdiag`.

- renderers without an explicit image format are built differently according to the output document format.

    - For PDF (LaTeX) documents, the default format is PNG
    - For other documents, the default format is SVG
    - The file extension is added to the `img` field

E.g.:

+-------------------------------------------+-----------------------------------------------------+
| Source                                    | Result                                              |
+===========================================+=====================================================+
| ~~~ markdown                              |                                                     |
| ```{.dot render="{{dot}}"                 | ```{.dot render="{{dot}}"                           |
|          img="img/panda_diagram_example"  |          img="{{build}}/img/panda_diagram_example"  |
|          out="{{build}}/img" }            |          out="{{build}}/img" }                      |
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
| ```{ render="{{gnuplot}}"                 | ```{ render="{{gnuplot}}"                           |
|      img="img/panda_gnuplot_example"      |      img="{{build}}/img/panda_gnuplot_example"      |
|      out="{{build}}/img" }                |      out="{{build}}/img" height=192 }               |
| set xrange [-pi:pi]                       | set xrange [-2*pi:2*pi]                             |
| set yrange [-1.5:1.5]                     | set yrange [-1.5:1.5]                               |
| plot sin(x) lw 4, cos(x) lw 4             | plot sin(x) lw 4, cos(x) lw 4                       |
| ```                                       | ```                                                 |
| ~~~                                       |                                                     |
+-------------------------------------------+-----------------------------------------------------+

Filters can be combined. E.g.: a diagram can be stored in an external file, included and rendered by `panda`.

+-------------------------------------------+-------------------------------------------+
| Source                                    | Result                                    |
+===========================================+===========================================+
| ~~~ markdown                              |                                           |
| The file `hello.dot` contains:            | The file `hello.dot` contains:            |
|                                           |                                           |
| ```{.dot include="{{doc}}/hello.dot"      | ```{.dot include="{{doc}}/hello.dot"      |
|          pattern="digraph%s*%b{}" }       |          pattern="digraph%s*%b{}" }       |
| ```                                       | ```                                       |
| ~~~                                       |                                           |
+-------------------------------------------+-------------------------------------------+
| ~~~ markdown                              |                                           |
| and is rendered as:                       | and is rendered as:                       |
|                                           |                                           |
| ```{ render="{{dot}}"                     | ```{ render="{{dot}}"                     |
|      img="img/hello"                      |      img="{{build}}/img/hello"            |
|      out="{{build}}/img"                  |      out="{{build}}/img"                  |
|      include="{{doc}}/hello.dot" }        |      include="{{doc}}/hello.dot" }        |
| ```                                       | ```                                       |
| ~~~                                       |                                           |
+-------------------------------------------+-------------------------------------------+

Makefile dependencies
=====================

It is sometimes useful to build a dependency list on the fly.
`panda` can generate a dependency list for make, in the same vein than the gcc `-M` option.
The environment variable `PANDA_TARGET` must be defined with the target name.
`panda` will generate a file named `${PANDA_TARGET}.d`{.sh} containing the dependencies of `${PANDA_TARGET}`{.sh}.

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
