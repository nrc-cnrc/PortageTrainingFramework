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


# What is this module's name.
MODULE_NAME ?= ldm

# Find out about what are the word alignment models the user asked for by
# stripping out the _cpt suffix.
AVAILABLE_WORD_ALIGNMENT_MODELS := $(PT_TYPES:_cpt=)

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
.PHONY: ldm.counts
ldm.counts: ${LDM_COUNTS_PFX}.ibm2.gz ${LDM_COUNTS_PFX}.hmm3.gz

${LDM_COUNTS_PFX}.ibm2.gz: ${TRAIN_TM}${SRCXZ} ${TRAIN_TM}${TGTXZ}
${LDM_COUNTS_PFX}.ibm2.gz: ibm2.${TRAIN_TM}.${TGT_GIVEN_SRCX} ibm2.${TRAIN_TM}.${SRC_GIVEN_TGTX}

${LDM_COUNTS_PFX}.hmm1.gz: ${TRAIN_TM}${SRCXZ} ${TRAIN_TM}${TGTXZ}
${LDM_COUNTS_PFX}.hmm1.gz: hmm1.${TRAIN_TM}.${TGT_GIVEN_SRCX} hmm1.${TRAIN_TM}.${SRC_GIVEN_TGTX}

${LDM_COUNTS_PFX}.hmm2.gz: ${TRAIN_TM}${SRCXZ} ${TRAIN_TM}${TGTXZ}
${LDM_COUNTS_PFX}.hmm2.gz: hmm2.${TRAIN_TM}.${TGT_GIVEN_SRCX} hmm2.${TRAIN_TM}.${SRC_GIVEN_TGTX}

${LDM_COUNTS_PFX}.hmm3.gz: ${TRAIN_TM}${SRCXZ} ${TRAIN_TM}${TGTXZ}
${LDM_COUNTS_PFX}.hmm3.gz: hmm3.${TRAIN_TM}.${TGT_GIVEN_SRCX} hmm3.${TRAIN_TM}.${SRC_GIVEN_TGTX}



########################################
# LEXICALIZED DISTORTION MODEL.
.PHONY: ldm
ldm: ${LDM_MODEL_PFX}.${LDM_NAME}.${SRC_2_TGTX}

# We will build a Lexicalized Distortion Model based on all available word alignment models.
${LDM_MODEL_PFX}.${LDM_NAME}.${SRC_2_TGTX}: $(addsuffix .gz,$(addprefix ${LDM_COUNTS_PFX}., ${AVAILABLE_WORD_ALIGNMENT_MODELS}))


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

