section [[
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
]]

local F = require "F"

help.name "Panda"
help.description "$name"

var "builddir" ".build"
clean.mrproper "$builddir"
clean "$builddir/src"
clean "$builddir/bin"

var "plantuml_version" "1.2023.10"
var "plantuml_url" "https://github.com/plantuml/plantuml/releases/download/v$plantuml_version/plantuml-$plantuml_version.jar"

var "ditaa_version" "0.11.0"
var "ditaa_url" "https://github.com/stathissideris/ditaa/releases/download/v$ditaa_version/ditaa-${ditaa_version}-standalone.jar"

---------------------------------------------------------------------
section "Compilation"
---------------------------------------------------------------------

local sources = F.flatten {
    ls "src/*.lua",
    "$builddir/src/_PANDA_VERSION.lua",
}

build "$builddir/src/_PANDA_VERSION.lua" {
    command = {
        "mkdir -p $builddir/src;",
        "(",
        "set -eu;",
        'echo "--@LOAD";',
        'echo "return [[$$(git describe --tags 2>/dev/null)]]";',
        ") > $out.tmp",
        "&& mv $out.tmp $out",
    },
    implicit_in = { ".git/refs/tags", ".git/index" }
}

install "bin" {

    build "$builddir/bin/panda.lua" { sources,
        command = "luax -q -o $out -t lua $in",
    },

    build "$builddir/bin/panda" { "src/panda",
        command = "cp $in $out",
    },

}

---------------------------------------------------------------------
section "Tests"
---------------------------------------------------------------------

rule "diff" { command = "diff $in && touch $out" }

build "$builddir/test/test.md.ok" { "diff", "$builddir/test/test.md", "test/test_result.md" }
build "$builddir/test/test.md.d.ok" { "diff", "$builddir/test/test.md.d", "test/test.md.d" }

build "$builddir/test/test.md" { "test/test.md",
    command = {
        "export PLANTUML=$builddir/plantuml.jar;",
        "export DITAA=$builddir/ditaa.jar;",
        "export LUA_PATH=test/?.lua;",
        "export PANDA_IMG=$builddir/img;",
        "pandoc",
            "-L $builddir/bin/panda.lua",
            "-Vpanda_target=$out",
            "-Vbuild=$builddir",
            "--standalone",
            "$in -o $out",
    },
    implicit_in = {
        "$builddir/plantuml.jar",
        "$builddir/ditaa.jar",
        "$builddir/bin/panda.lua",
    },
    implicit_out = {
        "$builddir/test/test.md.d",
    },
}

---------------------------------------------------------------------
section "PlantUML"
---------------------------------------------------------------------

build "$builddir/plantuml.jar" {
    command = {
        "test -f $out || wget $plantuml_url -O $out",
    },
}

---------------------------------------------------------------------
section "Ditaa"
---------------------------------------------------------------------

build "$builddir/ditaa.jar" {
    command = {
        "test -f $out || wget $ditaa_url -O $out",
    },
}

---------------------------------------------------------------------
section "Documentation"
---------------------------------------------------------------------

var "css" "$builddir/doc/cdelord.css"

build "README.md" { "doc/panda.md",
    command = {
        "export PLANTUML=$builddir/plantuml.jar;",
        "export DITAA=$builddir/ditaa.jar;",
        "pandoc",
            "-L", "$builddir/bin/panda.lua",
            "-Vpanda_target=$out",
            "-Vpanda_dep_file=$builddir/doc/$out.d",
            "-Vdoc=doc",
            "--to=gfm",
            "$in -o $out",
    },
    depfile = "$builddir/doc/$out.d",
    implicit_in =
    {
        "$builddir/bin/panda.lua",
        "$builddir/plantuml.jar",
        "$builddir/ditaa.jar",
    },
}

build "$builddir/doc/panda.html" { "doc/panda.md",
    command = {
        "export PLANTUML=$builddir/plantuml.jar;",
        "export DITAA=$builddir/ditaa.jar;",
        "pandoc",
            "-L", "$builddir/bin/panda.lua",
            "-Vpanda_target=$out",
            "-Vpanda_dep_file=$out.d",
            "-Vdoc=doc",
            "--to=html5",
            "--standalone --embed-resources",
            "--css=$css",
            "$in -o $out",
    },
    depfile = "$out.d",
    implicit_in =
    {
        "$builddir/bin/panda.lua",
        "$builddir/plantuml.jar",
        "$builddir/ditaa.jar",
        "$css",
    },
}

build "$css" {
    command = "test -f $out || wget http://cdelord.fr/cdelord.css -O $out",
}

---------------------------------------------------------------------
section "Shortcuts"
---------------------------------------------------------------------

help "compile" "Bundle $name into a single Lua script"
phony "compile" {
    "$builddir/bin/panda.lua",
    "$builddir/bin/panda",
}

help "all" "Compile, test and generate documentation"
phony "all" { "compile", "test", "doc" }

help "test" "Run $name tests"
phony "test" {
    "$builddir/test/test.md.ok",
    "$builddir/test/test.md.d.ok",
}

help "doc" "Generate $name documentation"
phony "doc" {
    "README.md",
    "$builddir/doc/panda.html",
}

default "compile"
