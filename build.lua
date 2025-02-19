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
https://github.com/cdsoft/panda
]]

local F = require "F"
local sh = require "sh"

help.name "Panda"
help.description "$name"

var "builddir" ".build"
clean.mrproper "$builddir"
clean "$builddir/src"
clean "$builddir/bin"

var "plantuml_version" "1.2024.6"
var "plantuml_url" "https://github.com/plantuml/plantuml/releases/download/v$plantuml_version/plantuml-$plantuml_version.jar"

var "ditaa_version" "0.11.0"
var "ditaa_url" "https://github.com/stathissideris/ditaa/releases/download/v$ditaa_version/ditaa-${ditaa_version}-standalone.jar"

---------------------------------------------------------------------
section "Compilation"
---------------------------------------------------------------------

var "git_version" { sh "git describe --tags" }
generator { implicit_in = ".git/refs/tags" }

local sources = {
    ls "src/*.lua",
    build "$builddir/src/_PANDA_VERSION.lua" {
        description = "VERSION $out",
        command = [=[echo "return [[$git_version]] --@LOAD" > $out]=],
    },
}

build.luax.lua:add "flags" "-q"

local bins = {
    build.luax.lua "$builddir/bin/panda.lua" { sources },
    build.cp       "$builddir/bin/panda"     { "src/panda" },
}

phony "release" {
    build.tar "$builddir/release/${git_version}/panda-${git_version}.tar.gz" {
        base = "$builddir/release/.build",
        name = "panda-${git_version}",
        F.flatten(bins) : map(function(script)
            return build.cp("$builddir/release/.build/panda-${git_version}/bin"/script:basename()) { script }
        end),
    },
}

---------------------------------------------------------------------
section "Tests"
---------------------------------------------------------------------

rule "diff" {
    description = "DIFF $in",
    command = "diff $in > $out || (cat $out && false)",
}

local tests = {
    build "$builddir/test/test.md" { "test/test.md",
        description = "PANDOC $in",
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
        validations = F{
            { "$builddir/test/test.md",   "test/test_result.md" },
            { "$builddir/test/test.md.d", "test/test.md.d" },
        } : map(function(files)
            return build(files[1]..".diff") { "diff", files }
        end),
    }
}

---------------------------------------------------------------------
section "PlantUML"
---------------------------------------------------------------------

build "$builddir/plantuml.jar" {
    description = "WGET $out",
    command = "wget $plantuml_url -O $out",
}

---------------------------------------------------------------------
section "Ditaa"
---------------------------------------------------------------------

build "$builddir/ditaa.jar" {
    description = "WGET $out",
    command = "wget $ditaa_url -O $out",
}

---------------------------------------------------------------------
section "Documentation"
---------------------------------------------------------------------

var "css" "$builddir/doc/cdsoft.css"

local docs = {

    build "README.md" { "doc/panda.md",
        description = "PANDOC $out",
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
        description = "PANDOC $out",
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
    description = "WGET $out",
    command = "wget https://raw.githubusercontent.com/CDSoft/CDSoft.github.io/refs/heads/master/cdsoft.css -O $out",
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
