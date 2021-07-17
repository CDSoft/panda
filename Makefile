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

.PHONY: clean
.PHONY: distclean

clean:
	find $(BUILD) -maxdepth 1 ! -name $(BUILD) ! -name "*.jar" ! -name "*.css" -exec rm -rf {} \;

distclean:
	rm -rf $(BUILD)

.PHONY: install

install:
	install panda.lua $(INSTALL_PATH)/
	install panda $(INSTALL_PATH)/

.PHONY: install-all

install-all: install $(BUILD)/plantuml.jar $(BUILD)/ditaa.jar
	install $(BUILD)/plantuml.jar $(INSTALL_PATH)/
	install $(BUILD)/ditaa.jar $(INSTALL_PATH)/

.PHONY: test

test: $(BUILD)/test.md test/test_result.md
	diff $(BUILD)/test.md test/test_result.md
	# Well done

$(BUILD)/test.md: panda panda.lua test/test.md test/test_include.md test/test_include.c $(BUILD)/plantuml.jar $(BUILD)/ditaa.jar
	@mkdir -p $(BUILD) $(BUILD)/img
	build=$(BUILD) PANDA_CACHE=$(BUILD)/cache PANDA_TARGET=$@ PLANTUML=$(BUILD)/plantuml.jar ./panda --standalone test/test.md -o $(BUILD)/test.md

.PHONY: diff

diff: $(BUILD)/test.md test/test_result.md
	meld $^

.PHONY: doc

doc: $(BUILD)/panda.html

CSS = $(BUILD)/cdelord.css

$(BUILD)/panda.html: doc/panda.md doc/hello.dot $(CSS) panda panda.lua
	@mkdir -p $(BUILD) $(BUILD)/img
	doc=doc build=$(BUILD) PANDA_CACHE=$(BUILD)/cache PANDA_TARGET=$@ PLANTUML=$(BUILD)/plantuml.jar DITAA=$(BUILD)/ditaa.jar ./panda --to=html5 --standalone --self-contained --css=$(CSS) $< -o $@

$(CSS):
	@mkdir -p $(dir $@)
	wget http://cdelord.fr/cdelord.css -O $@

$(BUILD)/plantuml.jar:
	@mkdir -p $(BUILD)
	wget http://sourceforge.net/projects/plantuml/files/plantuml.jar/download -O $@

$(BUILD)/ditaa.jar:
	@mkdir -p $(BUILD)
	wget https://github.com/stathissideris/ditaa/releases/download/v0.11.0/ditaa-0.11.0-standalone.jar -O $@
