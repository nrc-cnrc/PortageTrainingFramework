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

# List of all possible word alignment models in the framework.
# These must be ordered from most reliable to least reliable, because of the
# fill-up procedure.
POSSIBLE_WORD_ALIGNMENT_MODELS := ibm4 hmm3 hmm2 hmm1 ibm2 ibm1

# Function to sort a list of models from arbitrary order to best-first order.
sort_aligners = $(filter $1, ${POSSIBLE_WORD_ALIGNMENT_MODELS})

# Find out what the word alignment models the user asked for are,
# based on the type of conditional phrase tables that was specified.
TMP_AVAILABLE_WORD_ALIGNMENT_MODELS := $(filter-out merged indicator mix, $(PT_TYPES:_cpt=))
ifneq ($(filter merged indicator mix, $(PT_TYPES:_cpt=)),)
TMP_AVAILABLE_WORD_ALIGNMENT_MODELS += $(call lc, ${MERGED_CPT_ZN_MODEL} ${MERGED_CPT_JPT_TYPES})
else
ifeq (${PT_TYPES},)
TMP_AVAILABLE_WORD_ALIGNMENT_MODELS += $(call lc, ${MERGED_CPT_ZN_MODEL} ${MERGED_CPT_JPT_TYPES})
endif
endif
AVAILABLE_WORD_ALIGNMENT_MODELS := $(call sort_aligners,${TMP_AVAILABLE_WORD_ALIGNMENT_MODELS})

# What will we use for the LDM's name.
LDM_NAME ?= $(call merge,+,$(call sort_aligners,${AVAILABLE_WORD_ALIGNMENT_MODELS}))

# For the lock target, let's specify what file we want to put read-only.
FILES_TO_BE_LOCKED = *${COUNTSX} ${LDM_MODEL_PFX}* ${HLDM_MODEL_PFX}*



.DEFAULT_GOAL := help
.DELETE_ON_ERROR:
.SUFFIXES:
.SECONDARY:

.PHONY:  all
all:



########################################
# LEXICALIZED COUNTS.
# list of all lexicalized distortion count files required.
LDM_COUNT_FILES := $(foreach m, ${AVAILABLE_WORD_ALIGNMENT_MODELS}, ${LDM_MODEL_PFX}.$m${COUNTSX})

.PHONY:  ldm.counts
ldm.counts:  ${LDM_COUNT_FILES}

########################################
# HIERARCHICAL LEXICALIZED COUNTS.
# list of all hierarchical lexicalized distortion count files required.
HLDM_COUNT_FILES := $(foreach m, ${AVAILABLE_WORD_ALIGNMENT_MODELS}, ${HLDM_MODEL_PFX}.$m${COUNTSX})

.PHONY:  hldm.counts
hldm.counts:  ${HLDM_COUNT_FILES}



########################################
# Auto-generate all dependencies for all possible word alignment models
# To generate (h)ldm count files we need word alignment models in both directions.
$(foreach m, ${POSSIBLE_WORD_ALIGNMENT_MODELS}, \
   $(eval \
	   ${LDM_MODEL_PFX}.$m${COUNTSX}:  $(addsuffix .$m.${SRC_2_TGT}.align.gz,${TRAIN_LDM})) \
   $(eval \
	   ${HLDM_MODEL_PFX}.$m${COUNTSX}:  $(addsuffix .$m.${SRC_2_TGT}.align.gz,${TRAIN_HLDM})) \
)
# We need to make sure the ibm1 models are built first (for make -j to work correctly)
$(foreach m, $(filter-out ${IBM4_MODEL_PFX}, ${POSSIBLE_WORD_ALIGNMENT_MODELS}), \
   $(foreach c, $(sort ${TRAIN_LDM} ${TRAIN_HLDM}), \
      $(eval \
	   $c.$m.${SRC_2_TGT}.align.gz: ${IBM1_MODEL_PFX}.$c.${TGT_GIVEN_SRCX} ${IBM1_MODEL_PFX}.$c.${SRC_GIVEN_TGTX}) \
   ) \
)
# To generate (h)ldm count files we need the source corpus and the target corpus
# NOTE: IBM4 models require filtered corpora thus we need to write a separate rule.
$(foreach m, $(filter-out ibm4, ${POSSIBLE_WORD_ALIGNMENT_MODELS}), \
   $(eval \
	   ${LDM_MODEL_PFX}.$m${COUNTSX}:  $(addsuffix ${SRCXZ},${TRAIN_LDM}) $(addsuffix ${TGTXZ},${TRAIN_LDM})) \
   $(eval \
	   ${HLDM_MODEL_PFX}.$m${COUNTSX}:  $(addsuffix ${SRCXZ},${TRAIN_HLDM}) $(addsuffix ${TGTXZ},${TRAIN_HLDM})) \
)
# Pick up filtered corpora for (h)ldm models based on IBM4.
%.ibm4${COUNTSX}:  SRCXZ=${SRC_LANG}.lc
%.ibm4${COUNTSX}:  TGTXZ=${TGT_LANG}.lc
${LDM_MODEL_PFX}.ibm4${COUNTSX}:   $(foreach c,${TRAIN_LDM}, ../tm/$c/${SRC_LANG}.lc ../tm/$c/${TGT_LANG}.lc)
${HLDM_MODEL_PFX}.ibm4${COUNTSX}:  $(foreach c,${TRAIN_HLDM}, ../tm/$c/${SRC_LANG}.lc ../tm/$c/${TGT_LANG}.lc)



########################################
# LEXICALIZED DISTORTION MODEL.
# Lexicalized distortion model file name.
LDM_FILE := ${LDM_MODEL_PFX}.${LDM_NAME}.${SRC_2_TGTX}

ifdef USE_LDM
all: ldm
endif

.PHONY:  ldm
ldm:  ${LDM_FILE}

# We will build a Lexicalized Distortion Model based on all available word alignment models.
${LDM_FILE}:  ${LDM_COUNT_FILES}


# Filtering LDMs.
ifdef LDM_FILTER_SINGLETONS
${LDM_FILE}:  LDM_FILTER_CMD=egrep -v '\|( 0)* 1( 0)* 1( 0)*$$'
endif



########################################
# HIERARCHICAL LEXICALIZED DISTORTION MODEL.
# Hirarchical Lexicalized distortion model file name.
HLDM_FILE := ${HLDM_MODEL_PFX}.${LDM_NAME}.${SRC_2_TGTX}

ifdef USE_HLDM
all:  hldm
endif

.PHONY:  hldm
hldm:  ${HLDM_FILE}

# We will build a Lexicalized Distortion Model based on all available word alignment models.
${HLDM_FILE}:  ${HLDM_COUNT_FILES}


# Filtering HLDMs.
ifdef HLDM_FILTER_SINGLETONS
${HLDM_FILE}:  LDM_FILTER_CMD=egrep -v '\|( 0)* 1( 0)* 1( 0)*$$'
endif



########################################
# TIGHTLY PACKED LEXICALIZED DISTORTION MODEL.
.PHONY:  tpldm
tpldm:  ${LDM_FILE:.gz=.tpldm}
tpldm:  ${HLDM_FILE:.gz=.tpldm}

# Build a tpldm requires the .gz version.
${LDM_FILE:.gz=.tpldm}:  %.tpldm:  %.gz
${HLDM_FILE:.gz=.tpldm}:  %.tpldm:  %.gz







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
.PHONY:  help
help: SHELL=${GUARD_SHELL}
help:
	@echo "Train a lexicalized distortion model."
	@echo
	@echo "To train your distortion model, type: make all"
	@echo
	@echo "Have a look at Makefile.params in the current directory to enable custom tweaks."
	@echo
	@echo "The main targets in this Makefile are:"
	@cat $(firstword $(MAKEFILE_LIST)) | egrep '^.PHONY:' | sed 's#^.PHONY: #   #'



########################################
# Clean up
.PHONY:  clean clean.content clean.logs hide.logs
clean: SHELL=${GUARD_SHELL}
clean: clean.content clean.logs

clean.content: SHELL=${GUARD_SHELL}
clean.content:
	${RM} *${COUNTSX} *${SRC_2_TGTX} *.bkoff
	${RM} -r parallelize.pl.*

clean.logs: SHELL=${GUARD_SHELL}
clean.logs:
	$(RM) run-parallel-log* log.* run-p.*

# Hide logs from user's view into .logs
hide.logs: SHELL=${GUARD_SHELL}
hide.logs: hide_logs_sub



########################################
# Resources Summary
.PHONY:  time-mem
time-mem: SHELL=${GUARD_SHELL}
time-mem: resource_summary_sub



########################################
# What is needed for PortageLive.
PORTAGE_LIVE_DEST_DIR ?= ../portageLive/models/ldm

.PHONY:  portageLive
ifneq ("", "${USE_LDM}${USE_HLDM}")
portageLive:  $(and ${USE_LDM}, ${LDM_FILE:.gz=.tpldm})
portageLive:  $(and ${USE_HLDM}, ${HLDM_FILE:.gz=.tpldm})
portageLive:
	mkdir -p ${PORTAGE_LIVE_DEST_DIR}
	${RM} -r ${PORTAGE_LIVE_DEST_DIR}/*
	cd ${PORTAGE_LIVE_DEST_DIR} && ln -fs $(addprefix ../../../ldm/, $+) .
else
portageLive:
	@echo "Not using a lexicalized distortion model." >&2
endif








################################################################################
# UNITTESTS.

########################################
# Creating Lexicalized Distortion Models with IBM4 models require special
# attention to which corpora get picked up.  Make sure we pick up the proper
# filtered corpora and that the count file is properly created.
.PHONY: unittest1
unittest1: export PT_TYPES=ibm4_cpt
unittest1: export USE_LDM=1
unittest1: export AVAILABLE_WORD_ALIGNMENT_MODELS=ibm4
unittest1: export TRAIN_LDM=tm-train sublm1
unittest1:
	${MAKE} -C ../../corpora all
	${MAKE} -C ../tm ibm4_model ibm4_alignment
	${MAKE} all
	@ [[ `find -name ${LDM_MODEL_PFX}.${LDM_NAME}${COUNTSX} -size +21c` ]] \
	|| ! echo "ERROR: failed to generate count file." >&2
	@ [[ `find -name ${LDM_MODEL_PFX}.${LDM_NAME}.${SRC_2_TGTX} -size +21c` ]] \
	|| ! echo "ERROR: failed to generate lexicalized distortion model file." >&2

