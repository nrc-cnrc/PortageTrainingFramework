#!/usr/bin/make -f
# vim:noet:ts=3:nowrap
#
# $Id$
# @author Samuel Larkin
# @file Makefile
# @brief Trains language model files.
#
# Technologies langagieres interactives / Interactive Language Technologies
# Inst. de technologie de l'information / Institute for Information Technology
# Conseil national de recherches Canada / National Research Council Canada
# Copyright 2008, Sa Majeste la Reine du Chef du Canada
# Copyright 2008, Her Majesty in Right of Canada


# Mandatory include: master config file.
include ../../Makefile.params

# Include the config file.
MAKEFILE_PARAMS ?= Makefile.params
-include ${MAKEFILE_PARAMS}

# Lastly include the master toolkit
include ../../Makefile.toolkit

# What is this module's name.
MODULE_NAME ?= lm

# Let's make this usage on the cluster.
SHELL = ${FRAMEWORK_SHELL}

# Defines the IRST environment variables.
# Where is IRSTLM located
IRSTLM ?= $(PORTAGE)/pkgs/irstlm
# Where are IRSTLM's binaries located
BIN_DIR ?= ${IRSTLM}/bin

# What is the level of parallelism.
PARALLELISM_LEVEL_LM ?= 5

# What is the order of the required lm.
ORDER ?= 5

# Most steps require to load all the lm in memory, how many cpus should those jobs use.
CPUS ?= 2

# What is the lm language.
LM_LANG ?= ${TGT_LANG}

# What type of lms to build
LM_TYPES ?= binlm

# What is the corpus' name, extension and what file defines this corpus.
# This is the corpus' name and looks like train_fr
CORPUS_NAME ?= $(addsuffix _${LM_LANG}, ${TRAIN_LM})

# This indicates the corpus extension and looks like .tok.al.gz
CORPUS_EXT  ?= ${LANGXZ}

LM_DESC ?= -${ORDER}g-kn
LM_NAME ?= $(addsuffix ${LM_DESC}, ${CORPUS_NAME})

# Where to find the corpus' file.
CORPORA_DIR ?= ../../corpora

# This is to test the perplexity of the language models.
PPX_TEST_SET ?= test.txt

# After this Makefile, the following targets/files are precious.
FILES_TO_BE_LOCKED = ${LM_NAME}*

# If you need to provide ngram-count some extra parameters.
EXTRA_NGRAM_COUNT_OPTIONS ?=

# Resource monitoring.
TIME_MEM ?= time-mem


# Tells make where to find the corpus' file and the marked file if need be.
vpath %${CORPUS_EXT} ${CORPORA_DIR}
vpath %.marked.gz    ${CORPORA_DIR}



.DEFAULT_GOAL := help
.DELETE_ON_ERROR:



# include the proper toolkit
# Create Language Model's dependencies based on the toolkit.
ifeq (${LM_TOOLKIT}, SRI)
include Makefile.toolkit.SRI

else ifeq (${LM_TOOLKIT}, MIT)
include Makefile.toolkit.MIT

else ifeq (${LM_TOOLKIT}, IRST)
ifndef IRSTLM
	$(error You must define IRSTLM.)
endif
include Makefile.toolkit.IRST

else
	$(error Invalid type for LM_TOOLKIT: ${LM_TOOLKIT})
endif

include Makefile.toolkit



########################################
.PHONY: help
help: SHELL=${GUARD_SHELL}
help:
ifeq (${LM_TOOLKIT},IRST)
	@echo "Please run the following in order for this framework to run properly:"
	@echo "   export PATH=${BIN_DIR}:\$$PATH"
	@echo "   export IRSTLM=${IRSTLM}"
	@echo
endif
	@echo "In Makefile.params, define LM_TOOLKIT=SRI, LM_TOOLKIT=MIT" \
	      "or LM_TOOLKIT=IRST to specify the LM toolkit to use."
	@echo
	@echo "To train your language models, type: make all"
	@echo
	@echo "The main targets in this Makefile are:"
	@cat $(firstword $(MAKEFILE_LIST)) | egrep '^.PHONY:' | sed 's#^.PHONY: #   #'
	@echo
	@echo "Note: you can build some other lm by defining TRAIN_LM=<corpora_prefix>."



########################################
.PHONY: all
all: ${LM_TYPES}



########################################
# What the user can expect from this module.
.PHONY: list_final_output
list_final_output: SHELL=${GUARD_SHELL}
list_final_output:
	@echo "Expected final output(s):"
	@echo "$(addsuffix .binlm.gz, ${LM_NAME})"



########################################
# Clean up
.PHONY: clean clean.content clean.logs hide.logs
clean: SHELL=${GUARD_SHELL}
clean: clean.content clean.logs

clean.content: SHELL=${GUARD_SHELL}

clean.logs: SHELL=${GUARD_SHELL}
clean.logs:
	${RM} log.*
	${RM} run-parallel-logs-*
	${RM} -r .logs

# Hide logs from user's view into .logs
hide.logs: SHELL=${GUARD_SHELL}
hide.logs: hide_logs_sub



########################################
# Resources Summary
.PHONY: time-mem
time-mem: SHELL=${GUARD_SHELL}
time-mem: resource_summary_sub



########################################
# Transform model for PortageLive
PORTAGE_LIVE_DEST_DIR ?= ../portageLive/models/lm
.PHONY: portageLive
portageLive: SHELL=${GUARD_SHELL}
portageLive: $(addsuffix .tplm, ${LM_NAME})
	mkdir -p ${PORTAGE_LIVE_DEST_DIR}
	${RM} -r ${PORTAGE_LIVE_DEST_DIR}/*
	cd ${PORTAGE_LIVE_DEST_DIR} && ln -fs $(addprefix ../../../lm/, $+) .



########################################
# arpa text compressed format
.PHONY: arpa
arpa: $(addsuffix .lm.gz, ${LM_NAME})

clean.content: clean.arpa

.PHONY: clean.arpa
clean.arpa: SHELL=${GUARD_SHELL}
clean.arpa:
	${RM} *.lm.gz



########################################
# Portage's bin lm format
.PHONY: binlm
binlm: $(addsuffix .binlm.gz, ${LM_NAME})



########################################
# Create Tightly Packed Language Model.
.PHONY: tplm
tplm: $(addsuffix .tplm, ${LM_NAME})




################################################################################
# The following targets are unmaintained and were used for initial testing of
# irstlm.
########################################
# PERPLEXITY
.PHONY: ppx
ppx: $(addprefix ppx., ${LM_NAME})
ppx.%: %.binlm.gz ${PPX_TEST_SET}
	lm_eval -v -limit $+

.PHONY: ppx.irstlm
ppx.irstlm: $(addprefix ppx.irstlm.${LM_NAME}, .lm.gz .blmt .qlm.gz .Qblmt)
ppx.irstlm.%: ${PPX_TEST_SET} %
	compile-lm $* --eval=$< >& $(basename $@)

