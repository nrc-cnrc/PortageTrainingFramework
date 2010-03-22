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

# Find out about what are the word alignment models the user asked for.
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
# TIGHTLY PACKED LEXICAZILED DISTORTION MODEL.
.PHONY: tpldm
tpldm: ${LDM_MODEL_PFX}.hmm3+ibm2.${SRC_2_TGT}.tpldm

${LDM_MODEL_PFX}.hmm3+ibm2.${SRC_2_TGT}.tpldm: ${LDM_MODEL_PFX}.hmm3+ibm2.${SRC_2_TGTX}



################################################################################
# HELPERS.
########################################
# HELP OPTIONS
.PHONY: help
help: SHELL=${GUARD_SHELL}
help:
	@echo "Available targets are: ldm tpldm"



########################################
# CLEAN-UP
.PHONY: clean
clean: SHELL=${GUARD_SHELL}

.PHONY: clean.content
clean: clean.content
clean.content: SHELL=${GUARD_SHELL}
clean.content:
	${RM} -r ${LDM_COUNTS_PFX}* ${LDM_MODEL_PFX}*
	-${RM} -r parallelize.pl.*



.PHONY: clean.logs
clean: clean.logs
clean.logs: SHELL=${GUARD_SHELL}
clean.logs:
	$(RM) run-parallel-log* log.* run-p.*



########################################
# resources summary
.PHONY: summary
summary: resource_summary_sub



########################################
# What is needed for PortageLive.
.PHONY: portageLive
portageLive: tpldm

