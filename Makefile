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

PREFIX := $(firstword $(wildcard $(PREFIX) $(HOME)/.local))
BUILD = .build

## Test and generate Panda documentation
all: compile test doc

###############################################################################
# Help
###############################################################################

.PHONY: help welcome

BLACK     := $(shell tput -Txterm setaf 0)
RED       := $(shell tput -Txterm setaf 1)
GREEN     := $(shell tput -Txterm setaf 2)
YELLOW    := $(shell tput -Txterm setaf 3)
BLUE      := $(shell tput -Txterm setaf 4)
PURPLE    := $(shell tput -Txterm setaf 5)
CYAN      := $(shell tput -Txterm setaf 6)
WHITE     := $(shell tput -Txterm setaf 7)
BG_BLACK  := $(shell tput -Txterm setab 0)
BG_RED    := $(shell tput -Txterm setab 1)
BG_GREEN  := $(shell tput -Txterm setab 2)
BG_YELLOW := $(shell tput -Txterm setab 3)
BG_BLUE   := $(shell tput -Txterm setab 4)
BG_PURPLE := $(shell tput -Txterm setab 5)
BG_CYAN   := $(shell tput -Txterm setab 6)
BG_WHITE  := $(shell tput -Txterm setab 7)
NORMAL    := $(shell tput -Txterm sgr0)

CMD_COLOR    := ${YELLOW}
TARGET_COLOR := ${GREEN}
TEXT_COLOR   := ${CYAN}
TARGET_MAX_LEN := 16

## show this help massage
help: welcome
	@echo ''
	@echo 'Usage:'
	@echo '  ${CMD_COLOR}make${NORMAL} ${TARGET_COLOR}<target>${NORMAL}'
	@echo ''
	@echo 'Targets:'
	@awk '/^[a-zA-Z\-_0-9]+:/ { \
	    helpMessage = match(lastLine, /^## (.*)/); \
	    if (helpMessage) { \
	        helpCommand = substr($$1, 0, index($$1, ":")-1); \
	        helpMessage = substr(lastLine, RSTART + 3, RLENGTH); \
	        printf "  ${TARGET_COLOR}%-$(TARGET_MAX_LEN)s${NORMAL} ${TEXT_COLOR}%s${NORMAL}\n", helpCommand, helpMessage; \
	    } \
	} \
	{ lastLine = $$0 }' $(MAKEFILE_LIST)

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
# Compilation
#############################################################################

.PHONY: compile

compile: $(BUILD)/panda.lua
compile: $(BUILD)/panda

SOURCES = $(sort $(wildcard src/*.lua))
SOURCES += $(BUILD)/src/_PANDA_VERSION.lua

PANDA_VERSION := $(shell git describe --tags 2>/dev/null || echo 0.0)

$(BUILD)/panda.lua: $(SOURCES)
	@mkdir -p $(dir $@)
	luax -q -o $@ -t lua $^

$(BUILD)/panda: src/panda
	@mkdir -p $(dir $@)
	cp $< $@

$(BUILD)/src/_PANDA_VERSION.lua: $(wildcard .git/refs/tags) $(wildcard .git/index)
	@mkdir -p $(dir $@)
	@(  set -eu;                                                \
	    echo "--@LOAD";                                         \
	    echo "return [[$(PANDA_VERSION)]]";                     \
	) > $@.tmp
	@mv $@.tmp $@

#############################################################################
# Installation
#############################################################################

.PHONY: install

## Install panda.lua and panda
install: $(BUILD)/panda.lua $(BUILD)/panda
	@test -n "$(PREFIX)" || (echo "No installation path found" && false)
	@mkdir -p $(PREFIX)/bin
	install $(BUILD)/panda.lua $(PREFIX)/bin
	install $(BUILD)/panda $(PREFIX)/bin

.PHONY: install-all

## Install panda, panda.lua, PlantUML and ditaa
install-all: install

$(PREFIX)/bin/%.jar: $(BUILD)/%.jar
	@test -n "$(PREFIX)" || (echo "No installation path found" && false)
	@mkdir -p $(PREFIX)/bin
	install $< $(dir $@)

#############################################################################
# Tests
#############################################################################

.PHONY: test

## Run Panda tests
test: $(BUILD)/test.md test/test_result.md
	diff $(BUILD)/test.md test/test_result.md
	# Well done

export PLANTUML := $(BUILD)/plantuml.jar
export DITAA := $(BUILD)/ditaa.jar

$(BUILD)/test.md: $(BUILD)/panda $(BUILD)/panda.lua test/test.md $(BUILD)/plantuml.jar $(BUILD)/ditaa.jar Makefile
	@mkdir -p $(BUILD) $(BUILD)/img
	PANDA_IMG="[$(BUILD)]img" pandoc -L $(BUILD)/panda.lua -Vpanda_target=$@ -Vbuild=$(BUILD) --standalone test/test.md -o $(BUILD)/test.md

-include $(BUILD)/*.d

.PHONY: diff

## Compare test results
diff: $(BUILD)/test.md test/test_result.md
	meld $^

#############################################################################
# Documentation
#############################################################################

.PHONY: doc

## Generate Panda documentation
doc: $(BUILD)/panda.html README.md

CSS = $(BUILD)/cdelord.css

README.md: doc/panda.md $(CSS) $(BUILD)/panda $(BUILD)/panda.lua
	pandoc -L $(BUILD)/panda.lua -Vpanda_target=$@ -Vpanda_dep_file=$(BUILD)/$@.d -Vdoc=doc --to=gfm $< -o $@

$(BUILD)/panda.html: doc/panda.md $(CSS) $(BUILD)/panda $(BUILD)/panda.lua
	@mkdir -p $(BUILD)
	pandoc -L $(BUILD)/panda.lua -Vpanda_target=$@ -Vdoc=doc --to=html5 --standalone --embed-resources --css=$(CSS) $< -o $@

$(CSS):
	@mkdir -p $(dir $@)
	test -f $@ || wget http://cdelord.fr/cdelord.css -O $@

#############################################################################
# PlantUML
#############################################################################

install-all: $(PREFIX)/bin/plantuml.jar

PLANTUML_VERSION = 1.2023.9
PLANTUML_URL = https://github.com/plantuml/plantuml/releases/download/v$(PLANTUML_VERSION)/plantuml-$(PLANTUML_VERSION).jar

$(BUILD)/plantuml.jar:
	@mkdir -p $(BUILD)
	test -f $@ || wget $(PLANTUML_URL) -O $@

#############################################################################
# Ditaa
#############################################################################

install-all: $(PREFIX)/bin/ditaa.jar

DITAA_VERSION = 0.11.0
DITAA_URL = https://github.com/stathissideris/ditaa/releases/download/v$(DITAA_VERSION)/ditaa-$(DITAA_VERSION)-standalone.jar

$(BUILD)/ditaa.jar:
	@mkdir -p $(BUILD)
	test -f $@ || wget $(DITAA_URL) -O $@
