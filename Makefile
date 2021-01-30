# This file is part of Panda.
#
# Panda is free software: you can redistribute it and/or modify
# it under the terms of the GNU General Public License as published by
# the Free Software Foundation, either version 3 of the License, or
# (at your option) any later version.
#
# Panda is distributed in the hope that it will be useful,
# but WITHOUT ANY WARRANTY; without even the implied warranty of
# MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
# GNU General Public License for more details.
#
# You should have received a copy of the GNU General Public License
# along with Panda.  If not, see <https://www.gnu.org/licenses/>.
#
# For further information about Panda you can visit
# http://cdelord.fr/panda

INSTALL_PATH = $(HOME)/.local/bin
BUILD = .build

all: test doc

.PHONY: install

install:
	install panda.lua ${INSTALL_PATH}/
	install panda ${INSTALL_PATH}/

.PHONY: install-all

install-all: install plantuml.jar ditaa.jar
	install plantuml.jar ${INSTALL_PATH}/
	install ditaa.jar ${INSTALL_PATH}/

.PHONY: test

test: ${BUILD}/test.md test_result.md
	diff ${BUILD}/test.md test_result.md
	# Well done

${BUILD}/test.md: panda panda.lua test.md test_include.md test_include.c plantuml.jar ditaa.jar
	@mkdir -p ${BUILD}
	PANDA_TARGET=$@ ./panda --standalone test.md -o ${BUILD}/test.md

.PHONY: diff

diff: ${BUILD}/test.md test_result.md
	meld $^

.PHONY: doc

doc: ${BUILD}/panda.html

CSS = cdelord.css

${BUILD}/panda.html: doc/panda.md doc/hello.dot $(CSS) panda panda.lua
	@mkdir -p ${BUILD} img
	doc=doc build=$(BUILD) PANDA_TARGET=$@ ./panda --to=html5 --standalone --self-contained --css=$(CSS) $< -o $@

cdelord.css:
	wget http://cdelord.fr/cdelord.css -O cdelord.css

plantuml.jar:
	wget http://sourceforge.net/projects/plantuml/files/plantuml.jar/download -O $@

ditaa.jar:
	wget https://github.com/stathissideris/ditaa/releases/download/v0.11.0/ditaa-0.11.0-standalone.jar -O $@
