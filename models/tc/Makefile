#!/usr/bin/make -f
# vim:noet:ts=3
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
P_RES_MON ?= p-res-mon.sh -t


# Where can we find the corpora?
vpath %.tc.gz ${CORPORA_DIR}
vpath %${LANGXZ} ${CORPORA_DIR}



.DELETE_ON_ERROR:
#.INTERMEDIATE: ${TRAIN_LM}_${TGT_LANG}.marked.gz



.PHONY:
help: SHELL=${GUARD_SHELL}
help:
	@echo "This script build a language model and a map for truecasing."
	@echo "Define LM_TOOLKIT=SRI or LM_TOOLKIT=MIT if you have and want to use SRILM or MITLM instead of IRSTLM."
	@echo "Your corpora: ${TRAIN_LM}.${TCX}"
	@echo "type: make all"


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
clean.content clean.logs : SHELL=${GUARD_SHELL}
clean.content clean.logs : %:
	${MAKE} -f ../lm/Makefile $@



########################################
# resources summary
.PHONY: summary
summary: resource_summary_sub



########################################
# Hide logs.
.PHONY: hide
hide: SHELL=${GUARD_SHELL}
hide:
	mkdir -p .logs
	-ls log.* >& /dev/null && mv log.* .logs
	-ls run-parallel-logs-* >& /dev/null && mv run-parallel-logs-* .logs


########################################
# portageLive easy target.
.PHONY: portageLive
portageLive: ${TRUECASING_MAP}.tppt
portageLive: ${TRAIN_LM}_${TGT_LANG}-kn-3g.tplm



########################################
# PORTAGEsharedLive easy target.
.PHONY: PORTAGEsharedLive
PORTAGEsharedLive: all



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

%.map:  %${TCX}  %${LANGXZ}
	${P_RES_MON} \
	compile_truecase_map $+ \
		> $@ \
		2> log.$@

%.map.tppt: %.map
	${P_RES_MON} \
	vocabMap2tpt.sh $< \
		2> log.$@



.PHONY: clean.map
clean.content: clean.map
clean.map:
	-${RM} ${TRUECASING_MAP}
