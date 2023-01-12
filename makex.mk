# This file is part of makex.
#
# makex is free software: you can redistribute it and/or modify
# it under the terms of the GNU General Public License as published by
# the Free Software Foundation, either version 3 of the License, or
# (at your option) any later version.
#
# makex is distributed in the hope that it will be useful,
# but WITHOUT ANY WARRANTY; without even the implied warranty of
# MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
# GNU General Public License for more details.
#
# You should have received a copy of the GNU General Public License
# along with makex.  If not, see <https://www.gnu.org/licenses/>.
#
# For further information about makex you can visit
# http://cdelord.fr/makex

# Warning: this is a reduced version of makex.mk to install only Panda test
# dependencies.

###########################################################################
# Configuration
###########################################################################

#{{{
# makex defines some make variable that can be used to execute makex tools:
#
# PANDOC
#     path to the pandoc executable (see https://pandoc.org)
# PANDOC_LATEX_TEMPLATE
#     path to a LaTeX template
#     (see https://github.com/Wandmalfarbe/pandoc-latex-template.git)
# PANAM_CSS
#     path to a CSS file (see https://benjam.info/panam)
#
# It also adds some targets:
#
# makex-clean
#     remove all makex tools
# help
#     runs the `welcome` target (user defined)
#     and lists the targets with their documentation

# The project configuration variables can be defined before including
# makex.mk.

# MAKEX_INSTALL_PATH defines the path where tools are installed
MAKEX_INSTALL_PATH ?= /var/tmp/makex

# MAKEX_CACHE is the path where makex tools sources are stored and built
MAKEX_CACHE ?= /var/tmp/makex/cache

# MAKEX_HELP_TARGET_MAX_LEN is the maximal size of target names
# used to format the help message
MAKEX_HELP_TARGET_MAX_LEN ?= 20

# PANDOC_VERSION is the version number of pandoc
PANDOC_VERSION ?= 2.19.2

# PANDOC_LATEX_TEMPLATE_VERSION is a tag or branch name in the
# pandoc-latex-template repository
PANDOC_LATEX_TEMPLATE_VERSION = master

# PANDOC_LETTER_VERSION is a tag or branch name in the
# pandoc-letter repository
PANDOC_LETTER_VERSION = master

#}}}

###########################################################################
# Help
###########################################################################

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
MAKEX_COLOR  := ${BLACK}${BG_CYAN}

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
	        printf "  ${TARGET_COLOR}%-$(MAKEX_HELP_TARGET_MAX_LEN)s${NORMAL} ${TEXT_COLOR}%s${NORMAL}\n", helpCommand, helpMessage; \
	    } \
	} \
	{ lastLine = $$0 }' $(MAKEFILE_LIST)

.SECONDARY:

###########################################################################
# Cleaning makex directories
###########################################################################

makex-clean:
	@echo "$(MAKEX_COLOR)[MAKEX]$(NORMAL) $(TEXT_COLOR)clean$(NORMAL)"
	rm -rf $(MAKEX_INSTALL_PATH) $(MAKEX_CACHE)

###########################################################################
# makex directories
###########################################################################

$(MAKEX_CACHE) $(MAKEX_INSTALL_PATH):
	@mkdir -p $@

###########################################################################
# Host detection
###########################################################################

MAKEX_ARCH := $(shell uname -m)
MAKEX_OS := $(shell uname -s)

###########################################################################
# Pandoc LaTeX template
###########################################################################

PANDOC_LATEX_TEMPLATE_URL = https://github.com/Wandmalfarbe/pandoc-latex-template.git
PANDOC_LATEX_TEMPLATE = $(MAKEX_INSTALL_PATH)/pandoc/pandoc-latex-template/eisvogel.tex

$(dir $(PANDOC_LATEX_TEMPLATE)):
	@mkdir -p $@

$(PANDOC_LATEX_TEMPLATE): | $(MAKEX_CACHE) $(dir $(PANDOC_LATEX_TEMPLATE))
	@echo "$(MAKEX_COLOR)[MAKEX]$(NORMAL) $(TEXT_COLOR)install Pandoc LaTeX Template$(NORMAL)"
	@test -f $(@) \
	|| \
	(   (   test -d $(MAKEX_CACHE)/pandoc-latex-template \
	        && ( cd $(MAKEX_CACHE)/pandoc-latex-template && git pull ) \
	        || git clone $(PANDOC_LATEX_TEMPLATE_URL) $(MAKEX_CACHE)/pandoc-latex-template \
	    ) \
	    && cd $(MAKEX_CACHE)/pandoc-latex-template \
	    && git checkout $(PANDOC_LATEX_TEMPLATE_VERSION) \
	    && cp $(MAKEX_CACHE)/pandoc-latex-template/eisvogel.tex $@ \
	)

###########################################################################
# Pandoc Letter
###########################################################################

PANDOC_LETTER_URL = https://github.com/aaronwolen/pandoc-letter.git
PANDOC_LETTER = $(MAKEX_INSTALL_PATH)/pandoc/pandoc-letter/template-letter.tex

$(dir $(PANDOC_LETTER)):
	@mkdir -p $@

$(PANDOC_LETTER): | $(MAKEX_CACHE) $(dir $(PANDOC_LETTER))
	@echo "$(MAKEX_COLOR)[MAKEX]$(NORMAL) $(TEXT_COLOR)install Pandoc Letter$(NORMAL)"
	@test -f $(@) \
	|| \
	(   (   test -d $(MAKEX_CACHE)/pandoc-letter \
	        && ( cd $(MAKEX_CACHE)/pandoc-letter && git pull ) \
	        || git clone $(PANDOC_LETTER_URL) $(MAKEX_CACHE)/pandoc-letter \
	    ) \
	    && cd $(MAKEX_CACHE)/pandoc-letter \
	    && git checkout $(PANDOC_LETTER_VERSION) \
	    && cp $(MAKEX_CACHE)/pandoc-letter/template-letter.tex $@ \
	)

###########################################################################
# Pandoc Panam CSS
###########################################################################

PANAM_URL = https://benjam.info/panam/styling.css
PANAM_CSS = $(MAKEX_INSTALL_PATH)/pandoc/panam/styling.css

$(dir $(PANAM_CSS)):
	@mkdir -p $@

$(PANAM_CSS): | $(MAKEX_CACHE) $(dir $(PANAM_CSS))
	@echo "$(MAKEX_COLOR)[MAKEX]$(NORMAL) $(TEXT_COLOR)install Pandoc Pan Am CSS$(NORMAL)"
	@test -f $(@) \
	|| \
	wget -c $(PANAM_URL) -O $@

###########################################################################
# Pandoc
###########################################################################

ifeq ($(MAKEX_OS)-$(MAKEX_ARCH),Linux-x86_64)
PANDOC_ARCHIVE = pandoc-$(PANDOC_VERSION)-linux-amd64.tar.gz
endif

ifeq ($(PANDOC_ARCHIVE),)
$(error $(MAKEX_OS)-$(MAKEX_ARCH): Unknown archivecture, can not install pandoc)
endif

PANDOC_URL = https://github.com/jgm/pandoc/releases/download/$(PANDOC_VERSION)/$(PANDOC_ARCHIVE)
PANDOC = $(MAKEX_INSTALL_PATH)/pandoc/$(PANDOC_VERSION)/pandoc

export PATH := $(dir $(PANDOC)):$(PATH)

$(dir $(PANDOC)) $(MAKEX_CACHE)/pandoc:
	@mkdir -p $@

$(PANDOC): | $(MAKEX_CACHE) $(MAKEX_CACHE)/pandoc $(dir $(PANDOC)) $(PANDOC_LATEX_TEMPLATE) $(PANDOC_LETTER) $(PANAM_CSS)
	@echo "$(MAKEX_COLOR)[MAKEX]$(NORMAL) $(TEXT_COLOR)install Pandoc$(NORMAL)"
	@test -f $(@) \
	|| \
	(   wget -c $(PANDOC_URL) -O $(MAKEX_CACHE)/pandoc/$(notdir $(PANDOC_URL)) \
	    && tar -C $(MAKEX_CACHE)/pandoc -xzf $(MAKEX_CACHE)/pandoc/$(notdir $(PANDOC_URL)) \
	    && cp -P $(MAKEX_CACHE)/pandoc/pandoc-$(PANDOC_VERSION)/bin/* $(dir $@) \
	)

makex-install: makex-install-pandoc
makex-install-pandoc: $(PANDOC)
