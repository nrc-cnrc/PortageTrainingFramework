#!/usr/bin/make -f
# vim:noet:ts=3:nowrap

# @file Makefile
# @brief Train word classes for use by other modules
#
# @author Darlene Stewart
#
# Word classes are used by coarse LMs, coarse BiLMs, coarse TMs, and others.
#
# Traitement multilingue de textes / Multilingual Text Processing
# Tech. de l'information et des communications / Information and Communications Tech.
# Conseil national de recherches Canada / National Research Council Canada
# Copyright 2015, Sa Majeste la Reine du Chef du Canada
# Copyright 2015, Her Majesty in Right of Canada


# Mandatory include: master config file.
include ../../Makefile.params

# Include and override parameters with user specific config file.
MAKEFILE_PARAMS ?= Makefile.params
-include ${MAKEFILE_PARAMS}

# Include the master toolkit.
include ../../Makefile.toolkit

# Include the WCL toolkit.
include Makefile.toolkit

# What is this module's name?
MODULE_NAME ?= wcl

# What granularities should be trained?
# Multiple granularites may be trained. For example, typical choices are
# 200 & 800 for a coarse LM combo, or 400 for a single coarse LM or coarse BiLM.
WCL_NCLS_LIST ?=

# This indicates the corpus extension and looks like .tok.al.gz
CORPUS_EXT  ?= ${LANGXZ}

# Where to find the corpus' file.
CORPORA_DIR ?= ../../corpora

# After this Makefile, the following targets/files are precious.
FILES_TO_BE_LOCKED = $(addsuffix *, ${LM_NAMES})

# Where can we find the corpus' file?
vpath %${CORPUS_EXT} ${CORPORA_DIR}


.DEFAULT_GOAL := help
#.SECONDARY:
.SUFFIXES:
.DELETE_ON_ERROR:


MAIN_TARGETS :=  all clean help

########################################
.PHONY: help
help: SHELL=${LOCAL_SHELL}
help:
	@echo "To train word classes, type: make all"
	${HELP_LIST_MAIN_TARGETS}
	${HELP_LIST_EXPECTED_FILES}


########################################
.PHONY: all
all: SHELL=${LOCAL_SHELL}

# Validate that the WCL_NCLS_LIST contains numeric values
ifneq ($(shell echo ${WCL_NCLS_LIST} | egrep -v "^[0-9 ]+$$"),)
$(error Non-integer value found in WCL_NCLS_LIST: ${WCL_NCLS_LIST})
endif

# Validate that TRAIN_WCL is defined
ifeq ($(filter all, ${MAKECMDGOALS}),all)
ifeq ($(and ${TRAIN_WCL},${WCL_NCLS_LIST}),)
$(error TRAIN_WCL and WCL_NCLS_LIST must both be defined to train word classes)
endif
endif

define DEPS.PYSCRIPT
from __future__ import print_function

with open(".Makefile.deps", "w") as df:
   expected_files = []
   def writeDependencies(n, l, corpora):
      target = "{l}.{n}.classes".format(l=l, n=n)
      expected_files.append(target)
      print("{l}.{n}.classes:  WCL_NCLS := {n}".format(l=l, n=n), file=df)
      print("{l}.{n}.classes:  WCL_LANG := {l}".format(l=l, n=n), file=df)
      for c in corpora:
         print("{l}.{n}.classes:  {c}_{l}${CORPUS_EXT}".format(c=c, l=l, n=n), file=df)

   wcl_ncls_list = set("${WCL_NCLS_LIST}".strip().split())
   languages = set("${SRC_LANG} ${TGT_LANG}".strip().split())
   corpora = set("${TRAIN_WCL}".strip().split())
   for n in wcl_ncls_list:
      for l in languages:
         writeDependencies(n, l, corpora)

   print("EXPECTED_FILES := {}".format(" ".join(expected_files)), file=df)
endef

#$(info  WCL_DEPS: ${DEPS.PYSCRIPT})
$(shell python -c '${DEPS.PYSCRIPT}')
include .Makefile.deps

#$(info WCL_NCLS_LIST: ${WCL_NCLS_LIST})
#$(info LANGUAGES: ${SRC_LANG} ${TGT_LANG})
#$(info CORPORA: ${TRAIN_WCL})
#$(info TARGETS: ${EXPECTED_FILES})

all:  ${EXPECTED_FILES}

########################################
# What the user can expect from this module.
.PHONY: list_final_output
list_final_output: SHELL=${LOCAL_SHELL}
list_final_output:
	@echo "Expected final output(s):"
	@echo ${EXPECTED_FILES}


########################################
# Clean up
.PHONY: clean clean.content clean.logs hide.logs
clean: SHELL=${LOCAL_SHELL}
clean: clean.content clean.logs

clean.content: SHELL=${LOCAL_SHELL}
clean.content:
	${RM} *.classes *.classes.cats


clean.logs: SHELL=${LOCAL_SHELL}
clean.logs:
	${RM} log.* core*
	${RM} run-parallel-logs-*
	${RM} -r .logs run-p.*

# Hide logs from user's view into .logs
hide.logs: SHELL=${LOCAL_SHELL}
hide.logs: hide_logs_sub


########################################
# Resources Summary
.PHONY: time-mem
time-mem: SHELL=${LOCAL_SHELL}
time-mem: resource_summary_sub

MAIN_TARGETS += time-mem


########################################
# Transform the WCL model for PortageLive
PORTAGE_LIVE_DEST_DIR ?= ../portageLive/models/wcl

${PORTAGE_LIVE_DEST_DIR}:  SHELL=${LOCAL_SHELL}
${PORTAGE_LIVE_DEST_DIR}:
	mkdir -p $@


.PHONY:  portageLive
portageLive:  SHELL=${LOCAL_SHELL}

MAIN_TARGETS += portageLive

clean.content:  clean.portageLive
.PHONY:  clean.portageLive
clean.portageLive:  SHELL=${LOCAL_SHELL}
clean.portageLive:
	${RM} ${EXPECTED_FILES:.classes=.mmcls}

ifneq (${TRAIN_WCL},)
portageLive:  | ${PORTAGE_LIVE_DEST_DIR}
portageLive:  ${EXPECTED_FILES:.classes=.mmcls}
	${RM} -r ${PORTAGE_LIVE_DEST_DIR}/*
	cd ${PORTAGE_LIVE_DEST_DIR} && ln -fs $(addprefix ../../../wcl/, $+) .
else
portageLive:
	@echo "No word classes defined, so nothing to do for portageLive." >&2
endif
