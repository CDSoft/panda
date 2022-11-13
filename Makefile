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

INSTALL_PATH := $(firstword $(wildcard $(PREFIX) $(HOME)/.local/bin))
BUILD = .build

all: test doc

#############################################################################
# Clean
#############################################################################

.PHONY: clean
.PHONY: distclean

clean:
	find $(BUILD) -maxdepth 1 ! -name $(BUILD) ! -name "*.jar" ! -name "*.css" -exec rm -rf {} \;

distclean:
	rm -rf $(BUILD)

#############################################################################
# Installation
#############################################################################

.PHONY: install

install:
	install panda.lua $(INSTALL_PATH)/
	install panda $(INSTALL_PATH)/

.PHONY: install-all

install-all: install

$(INSTALL_PATH)/%.jar: $(BUILD)/%.jar
	install $< $(dir $@)

#############################################################################
# Tests
#############################################################################

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

#############################################################################
# Documentation
#############################################################################

.PHONY: doc

doc: $(BUILD)/panda.html

CSS = $(BUILD)/cdelord.css

$(BUILD)/panda.html: doc/panda.md doc/hello.dot $(CSS) panda panda.lua
	@mkdir -p $(BUILD) $(BUILD)/img
	doc=doc build=$(BUILD) PANDA_CACHE=$(BUILD)/cache PANDA_TARGET=$@ PLANTUML=$(BUILD)/plantuml.jar DITAA=$(BUILD)/ditaa.jar ./panda --to=html5 --standalone --embed-resources --css=$(CSS) $< -o $@

$(CSS):
	@mkdir -p $(dir $@)
	wget http://cdelord.fr/cdelord.css -O $@

#############################################################################
# PlantUML
#############################################################################

install-all: $(INSTALL_PATH)/plantuml.jar

PLANTUML_VERSION = 1.2022.12
PLANTUML_URL = https://github.com/plantuml/plantuml/releases/download/v$(PLANTUML_VERSION)/plantuml-$(PLANTUML_VERSION).jar

$(BUILD)/plantuml.jar:
	@mkdir -p $(BUILD)
	wget $(PLANTUML_URL) -O $@

#############################################################################
# Ditaa
#############################################################################

install-all: $(INSTALL_PATH)/ditaa.jar

DITAA_VERSION = 0.11.0
DITAA_URL = https://github.com/stathissideris/ditaa/releases/download/v$(DITAA_VERSION)/ditaa-$(DITAA_VERSION)-standalone.jar

$(BUILD)/ditaa.jar:
	@mkdir -p $(BUILD)
	wget $(DITAA_URL) -O $@
