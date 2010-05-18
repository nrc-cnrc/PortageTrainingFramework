#!/usr/bin/make -f
# vim:noet:ts=3:nowrap
#
# $Id$
# @author Samuel Larkin
# @file Makefile
# @brief Trains a truecasing model.
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
MODULE_NAME ?= tc

# Let's make this usage on the cluster.
SHELL = ${FRAMEWORK_SHELL}

# Where to find the corpus' file.
CORPORA_DIR ?= ../../corpora

# Define LM_TOOLKIT=SRI if you want to use SRILM
# Define LM_TOOLKIT=MIT if you want to use MITLM
# Make sure all Makefile knows about it.
export LM_TOOLKIT

# Typical lms for truecasing are 3g.
export ORDER = 3

# For truecasing, we are going to use the same train_lm corpus but in its
# truecased form.  This can be done by simply tell lm/Makefile that our corpus
# extension is now .tc.gz.
TCX = .tc.gz
export CORPUS_EXT = ${TCX}

# After this Makefile, the following targets/files are precious.
FILES_TO_BE_LOCKED = ${TRUECASING_MAP} ${TRUECASING_LM} ${TRAIN_LM}*

# Resource monitoring.
TIME_MEM ?= time-mem


# Where can we find the corpora?
vpath %.tc.gz ${CORPORA_DIR}
vpath %${LANGXZ} ${CORPORA_DIR}



.DEFAULT_GOAL := help
.DELETE_ON_ERROR:
#.INTERMEDIATE: ${TRAIN_LM}_${TGT_LANG}.marked.gz



.PHONY: help
help: SHELL=${GUARD_SHELL}
help:
	@echo "Train a language model and a map for truecasing."
	@echo
	@echo "In Makefile.params, define LM_TOOLKIT=SRI, LM_TOOLKIT=MIT" \
	      "or LM_TOOLKIT=IRST to specify the LM toolkit to use."
	@echo "Your truecasing corpus is: ${TRAIN_LM}_${TGT_LANG}${TCX}"
	@echo
	@echo "To train your truecasing model, type: make all"
	@echo
	@echo "The main targets in this Makefile are:"
	@cat $(firstword $(MAKEFILE_LIST)) | egrep '^.PHONY:' | sed 's#^.PHONY: #   #'


.PHONY: all
ifdef DO_TRUECASING
all: ${TRUECASING_MAP}
all: ${TRUECASING_LM}
else
all:
	@echo "Nothing to do, user asked not to do truecasing." >&2
endif



# What the user can expect from this module.
.PHONY: list_final_output
list_final_output: SHELL=${GUARD_SHELL}
list_final_output:
	${MAKE} -sf ../lm/Makefile $@
	@echo "${TRUECASING_MAP}"



########################################
# Clean up targets
.PHONY: clean
clean: SHELL=${GUARD_SHELL}
clean:



.PHONY: clean.content clean.logs
clean: clean.content clean.logs
clean.logs: SHELL=${GUARD_SHELL}
clean.logs: %: lm-%
	${RM} log.* run-parallel-logs*

clean.content: SHELL=${GUARD_SHELL}
clean.content: %: lm-%
	${RM} -r *.map *.map.tppt vocabMap2tpt.*

lm-clean.content lm-clean.logs: lm-%:
	${MAKE} -f ../lm/Makefile $*



########################################
# Resources Summary
.PHONY: time-mem
time-mem: SHELL=${GUARD_SHELL}
time-mem: resource_summary_sub



########################################
# portageLive easy target.
PORTAGE_LIVE_DEST_DIR ?= ../portageLive/models/tc
.PHONY: portageLive
portageLive: SHELL=${GUARD_SHELL}
portageLive: ${TRUECASING_MAP}.tppt
portageLive: ${TRAIN_LM}_${TGT_LANG}-kn-3g.tplm
portageLive:
	mkdir -p ${PORTAGE_LIVE_DEST_DIR}
	${RM} -r ${PORTAGE_LIVE_DEST_DIR}/*
	cd ${PORTAGE_LIVE_DEST_DIR} && ln -fs ../../../tc/$(filter %.tppt, $+) tc-map.${TGT_LANG}.tppt
	cd ${PORTAGE_LIVE_DEST_DIR} && ln -fs ../../../tc/$(filter %.tplm, $+) tc-lm.${TGT_LANG}.tplm



########################################
# Build a truecased language model.
# Build the truecased lm model using the convinient Makefile from models/lm.
.PHONY: lm
lm: SHELL=${GUARD_SHELL}
lm: ${TRUECASING_LM}

%-kn-3g.binlm.gz: SHELL=${GUARD_SHELL}
%-kn-3g.binlm.gz:
	${MAKE} -f ../lm/Makefile $@

%.tplm: 
	${MAKE} -f ../lm/Makefile $@



########################################
# Build a map file.
.PHONY: map
map: SHELL=${GUARD_SHELL}
map: ${TRUECASING_MAP}

%.map:  SHELL=${FRAMEWORK_SHELL}
%.map:  %${TCX}  %${LANGXZ}
	${TIME_MEM} \
	compile_truecase_map $+ \
		> $@ \
		2> log.$@

%.map.tppt:  SHELL=${FRAMEWORK_SHELL}
%.map.tppt: %.map
	${TIME_MEM} \
	vocabMap2tpt.sh $< \
		2> log.$@



.PHONY: clean.map
clean.content: clean.map
clean.map: SHELL=${GUARD_SHELL}
clean.map:
	-${RM} ${TRUECASING_MAP}
