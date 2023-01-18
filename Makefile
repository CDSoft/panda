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

## Test and generate Panda documentation
all: test doc

# include makex to install Panda test dependencies
include makex.mk

###############################################################################
# Help
###############################################################################

welcome:
	@echo '${CYAN}Panda${NORMAL}'

#############################################################################
# Clean
#############################################################################

.PHONY: clean
.PHONY: distclean

## Clean the build directory (keep the downloaded jar and css files)
clean:
	find $(BUILD) -maxdepth 1 ! -name $(BUILD) ! -name "*.jar" ! -name "*.css" -exec rm -rf {} \;

## Clean the build directory
distclean:
	rm -rf $(BUILD)

#############################################################################
# Installation
#############################################################################

.PHONY: install

## Install panda.lua and panda
install:
	install panda.lua $(INSTALL_PATH)/
	install panda $(INSTALL_PATH)/

.PHONY: install-all

## Install panda, panda.lua, PlantUML and ditaa
install-all: install

$(INSTALL_PATH)/%.jar: $(BUILD)/%.jar
	install $< $(dir $@)

#############################################################################
# Tests
#############################################################################

.PHONY: test

## Run Panda tests
test: $(BUILD)/test.md test/test_result.md
	diff $(BUILD)/test.md test/test_result.md
	# Well done

$(BUILD)/test.md: panda panda.lua test/test.md test/test_include.md test/test_include.c $(BUILD)/plantuml.jar $(BUILD)/ditaa.jar | $(PANDOC)
	@mkdir -p $(BUILD) $(BUILD)/img
	build=$(BUILD) PANDA_CACHE=$(BUILD)/cache PANDA_TARGET=$@ PLANTUML=$(BUILD)/plantuml.jar $(PANDOC) -L panda.lua --standalone test/test.md -o $(BUILD)/test.md

.PHONY: diff

## Compare test results
diff: $(BUILD)/test.md test/test_result.md
	meld $^

#############################################################################
# Documentation
#############################################################################

.PHONY: doc

## Generate Panda documentation
doc: $(BUILD)/panda.html

CSS = $(BUILD)/cdelord.css

$(BUILD)/panda.html: doc/panda.md doc/hello.dot $(CSS) panda panda.lua | $(PANDOC)
	@mkdir -p $(BUILD) $(BUILD)/img
	doc=doc build=$(BUILD) PANDA_CACHE=$(BUILD)/cache PANDA_TARGET=$@ PLANTUML=$(BUILD)/plantuml.jar DITAA=$(BUILD)/ditaa.jar $(PANDOC) -L panda.lua --to=html5 --standalone --embed-resources --css=$(CSS) $< -o $@

$(CSS):
	@mkdir -p $(dir $@)
	test -f $@ || wget http://cdelord.fr/cdelord.css -O $@

#############################################################################
# PlantUML
#############################################################################

install-all: $(INSTALL_PATH)/plantuml.jar

PLANTUML_VERSION = 1.2023.0
PLANTUML_URL = https://github.com/plantuml/plantuml/releases/download/v$(PLANTUML_VERSION)/plantuml-$(PLANTUML_VERSION).jar

$(BUILD)/plantuml.jar:
	@mkdir -p $(BUILD)
	test -f $@ || wget $(PLANTUML_URL) -O $@

#############################################################################
# Ditaa
#############################################################################

install-all: $(INSTALL_PATH)/ditaa.jar

DITAA_VERSION = 0.11.0
DITAA_URL = https://github.com/stathissideris/ditaa/releases/download/v$(DITAA_VERSION)/ditaa-$(DITAA_VERSION)-standalone.jar

$(BUILD)/ditaa.jar:
	@mkdir -p $(BUILD)
	test -f $@ || wget $(DITAA_URL) -O $@
