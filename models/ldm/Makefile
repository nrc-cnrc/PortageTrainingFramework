#!/usr/bin/make -f
# vim:noet:ts=3:nowrap
# $Id$
#
# @author Samuel Larkin
# @file Makefile.dm
# @brief Train Lexicalized Distortion Models.
#        In this file we only state the dependencies.
#
# Technologies langagieres interactives / Interactive Language Technologies
# Inst. de technologie de l'information / Institute for Information Technology
# Conseil national de recherches Canada / National Research Council Canada
# Copyright 2010, Sa Majeste la Reine du Chef du Canada
# Copyright 2010, Her Majesty in Right of Canada


# User specific configuration.
MAKEFILE_PARAMS ?= Makefile.params
-include ${MAKEFILE_PARAMS}

# Mandatory include: master config file.
include ../../Makefile.params

# Default toolkit.
include ../../Makefile.toolkit

# Always include the toolkit last.
include Makefile.toolkit

# GNU Make Standard Library
include ../../gmsl/gmsl


# What is this module's name.
MODULE_NAME ?= ldm

# Find out about what are the word alignment models the user asked for by
# based on the type of conditional phrase tables that was specified.
TMP_AVAILABLE_WORD_ALIGNMENT_MODELS := $(filter-out merged, $(PT_TYPES:_cpt=))
ifneq ($(filter merged, $(PT_TYPES:_cpt=)),)
TMP_AVAILABLE_WORD_ALIGNMENT_MODELS += $(call lc, ${MERGED_CPT_ZN_MODEL} ${MERGED_CPT_JPT_TYPES})
endif
AVAILABLE_WORD_ALIGNMENT_MODELS := $(sort ${TMP_AVAILABLE_WORD_ALIGNMENT_MODELS})

# List of all possible word alignment models in the framework.
POSSIBLE_WORD_ALIGNMENT_MODELS := ibm2 hmm1 hmm2 hmm3

# Hack to be able to substitute spaces.
EMPTY :=

# What will we use for the LDM's name.
LDM_NAME ?= $(subst ${EMPTY} ${EMPTY},+,$(sort ${AVAILABLE_WORD_ALIGNMENT_MODELS}))

# For the lock target, let's specify what file we want to put read-only.
FILES_TO_BE_LOCKED = ${LDM_COUNTS_PFX}* ${LDM_MODEL_PFX}*



.DEFAULT_GOAL := help
.DELETE_ON_ERROR:
.SUFFIXES:
.SECONDARY:

.PHONY: all
all: ldm



########################################
# LEXICALIZED COUNTS.
# list of all lexicalized distortion count files required.
LDM_COUNT_FILES := $(foreach m, ${AVAILABLE_WORD_ALIGNMENT_MODELS}, ${LDM_COUNTS_PFX}.$m.gz)

.PHONY: ldm.counts
ldm.counts: ${LDM_COUNT_FILES}

# Auto-generate all dependencies for all possible word alignment models
# To generate ldm count files we need the source corpus and the target corpus
# To generate ldm coutn files we need word alignment models in both directions.
$(foreach m, ${POSSIBLE_WORD_ALIGNMENT_MODELS}, \
   $(eval \
	   ${LDM_COUNTS_PFX}.$m.gz:  ${TRAIN_TM}${SRCXZ} ${TRAIN_TM}${TGTXZ}) \
   $(eval \
	   ${LDM_COUNTS_PFX}.$m.gz:  $m.${TRAIN_TM}.${TGT_GIVEN_SRCX} $m.${TRAIN_TM}.${SRC_GIVEN_TGTX}) \
)



########################################
# LEXICALIZED DISTORTION MODEL.
# Lexicalized distortion model file name.
LDM_FILE := ${LDM_MODEL_PFX}.${LDM_NAME}.${SRC_2_TGTX}

.PHONY: ldm
ldm: ${LDM_FILE}

# We will build a Lexicalized Distortion Model based on all available word alignment models.
${LDM_FILE}:  ${LDM_COUNT_FILES}



########################################
# FILTERING OF LDMs
ifdef LDM_FILTER_SINGLETONS
LDM_FILTER_CMD=egrep -v '\|( 0)* 1( 0)* 1( 0)*$$'
else
LDM_FILTER_CMD=cat
endif



########################################
# TIGHTLY PACKED LEXICAZILED DISTORTION MODEL.
.PHONY: tpldm
tpldm: ${LDM_MODEL_PFX}.${LDM_NAME}.${SRC_2_TGT}.tpldm

${LDM_MODEL_PFX}.${LDM_NAME}.${SRC_2_TGT}.tpldm: ${LDM_MODEL_PFX}.${LDM_NAME}.${SRC_2_TGTX}



################################################################################
# HELPERS.
########################################
# Word alignment models.
# These targets will most likely not be called since the framework should have
# taken care of creating those models in the first place.
# They are here to be to try make -n before running the framework.
# Disabled because it breaks the building of ldm.counts if actually invoked.
#%${TGT_GIVEN_SRCX} %${SRC_GIVEN_TGTX}:
#	[[ -f "../tm/$@" ]] || ${MAKE} -C ../tm $@



########################################
# HELP OPTIONS
.PHONY: help
help: SHELL=${GUARD_SHELL}
help:
	@echo "Train a lexicalized distortion model."
	@echo
	@echo "To train your distortion model, type: make all"
	@echo
	@echo "The main targets in this Makefile are:"
	@cat $(firstword $(MAKEFILE_LIST)) | egrep '^.PHONY:' | sed 's#^.PHONY: #   #'



########################################
# Clean up
.PHONY: clean clean.content clean.logs hide.logs
clean: SHELL=${GUARD_SHELL}
clean: clean.content clean.logs

clean.content: SHELL=${GUARD_SHELL}
clean.content:
	${RM} -r ${LDM_COUNTS_PFX}* ${LDM_MODEL_PFX}*
	${RM} -r parallelize.pl.*

clean.logs: SHELL=${GUARD_SHELL}
clean.logs:
	$(RM) run-parallel-log* log.* run-p.*

# Hide logs from user's view into .logs
hide.logs: SHELL=${GUARD_SHELL}
hide.logs: hide_logs_sub



########################################
# Resources Summary
.PHONY: time-mem
time-mem: SHELL=${GUARD_SHELL}
time-mem: resource_summary_sub



########################################
# What is needed for PortageLive.
PORTAGE_LIVE_DEST_DIR ?= ../portageLive/models/ldm

.PHONY: portageLive
portageLive: SHELL=${GUARD_SHELL}
ifdef USE_LDM
portageLive: ${LDM_MODEL_PFX}.${LDM_NAME}.${SRC_2_TGT}.tpldm
	mkdir -p ${PORTAGE_LIVE_DEST_DIR}
	${RM} -r ${PORTAGE_LIVE_DEST_DIR}/*
	cd ${PORTAGE_LIVE_DEST_DIR} && ln -fs ../../../ldm/$< .
else
portageLive:
	@echo "Not using a lexicalized distortion model." >&2
endif

