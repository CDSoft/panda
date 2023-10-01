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

var "plantuml_version" "1.2023.11"
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
    command = [=[echo "return [[$$(git describe --tags)]] --@LOAD" > $out]=],
    implicit_in = { ".git/refs/tags", ".git/index" }
}

local bins = {
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

rule "diff" { command = "diff $in > $out || (cat $out && false)" }

local tests = {
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
        validations = {
            build "$builddir/test/test.md.diff" { "diff", "$builddir/test/test.md", "test/test_result.md" },
            build "$builddir/test/test.md.d.diff" { "diff", "$builddir/test/test.md.d", "test/test.md.d" },
        },
    }
}

---------------------------------------------------------------------
section "PlantUML"
---------------------------------------------------------------------

build "$builddir/plantuml.jar" {
    command = "wget $plantuml_url -O $out",
}

---------------------------------------------------------------------
section "Ditaa"
---------------------------------------------------------------------

build "$builddir/ditaa.jar" {
    command = "wget $ditaa_url -O $out",
}

---------------------------------------------------------------------
section "Documentation"
---------------------------------------------------------------------

var "css" "$builddir/doc/cdelord.css"

local docs = {

    build "README.md" { "doc/panda.md",
        command = {
            "export PLANTUML=$builddir/plantuml.jar;",
            "export DITAA=$builddir/ditaa.jar;",
            "pandoc",
                "-L", "$builddir/bin/panda.lua",
                "-Vpanda_target=$out",
                "-Vpanda_dep_file=$depfile",
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
    },

    build "$builddir/doc/panda.html" { "doc/panda.md",
        command = {
            "export PLANTUML=$builddir/plantuml.jar;",
            "export DITAA=$builddir/ditaa.jar;",
            "pandoc",
                "-L", "$builddir/bin/panda.lua",
                "-Vpanda_target=$out",
                "-Vpanda_dep_file=$depfile",
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
    },

}

build "$css" {
    command = "wget http://cdelord.fr/cdelord.css -O $out",
}

---------------------------------------------------------------------
section "Shortcuts"
---------------------------------------------------------------------

help "compile" "Bundle $name into a single Lua script"
phony "compile" (bins)
install "bin" (bins)

help "all" "Compile, test and generate documentation"
phony "all" { "compile", "test", "doc" }

help "test" "Run $name tests"
phony "test" (tests)

help "doc" "Generate $name documentation"
phony "doc" (docs)

default "compile"
