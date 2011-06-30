#!/usr/bin/make -f
# vim:noet:ts=3:nowrap
# $Id$
#
# @author Samuel Larkin
# @file Makefile
# @brief Trains ibm models, hmm models, joint frequency counts models and phrase tables.
#
# Technologies langagieres interactives / Interactive Language Technologies
# Inst. de technologie de l'information / Institute for Information Technology
# Conseil national de recherches Canada / National Research Council Canada
# Copyright 2008, Sa Majeste la Reine du Chef du Canada
# Copyright 2008, Her Majesty in Right of Canada


# Source file requirements.
# <PREFIX>_<LANGUAGE>.<LANGX>
 
# Variables we use from ../../Makefile.params:
# PT_TYPES indicates what type of phrase table we want to generate.

# Mandatory include: master config file.
include ../../Makefile.params

# This is the Makefile that contains all targets required to build Translation
# Models and some variable's defintion that might be used by the user in its
# Makefile.params.
include Makefile.toolkit

# Lastly include the master toolkit
include ../../Makefile.toolkit

# GNU Make Standard Library
include ../../gmsl/gmsl   # functions: uc

# Include and override parameters with user specific config file.
MAKEFILE_PARAMS ?= Makefile.params
-include ${MAKEFILE_PARAMS}



# What is this module's name.
MODULE_NAME ?= tm

# TODO: Make sure this Makefile works for Portage's cluster.
# This will require that run-parallel.sh -c RP_OPTS be functional.
SHELL = ${FRAMEWORK_SHELL}

# Where we can find the parallel corpora.
CORPORA_DIR ?= ../../corpora

# What parallel corpora is to be used for creating the models.
TRAIN_TM ?= train

# This script might produce directory and we want to easily remove them.
RM = rm -rf

# After this Makefile, the following targets/files are precious.
FILES_TO_BE_LOCKED = ibm* hmm* jpt* cpt*



# Allows to search for alignment files in corpus.
vpath %${L1X} ${CORPORA_DIR}
vpath %${L2X} ${CORPORA_DIR}


.DEFAULT_GOAL := help
.DELETE_ON_ERROR:
.SUFFIXES:
.SECONDARY:


########################################
# ALL
# Define all the work to be done.
.PHONY: all
all: ${PT_TYPES}



########################################
# HELP OPTIONS
.PHONY: help
help: SHELL=${GUARD_SHELL}
help:
	@echo "Train translation models."
	@echo
	@echo "To train your models, type: make all"
	@echo
	@echo "The main targets in this Makefile are:"
	@cat $(firstword $(MAKEFILE_LIST)) | egrep '^.PHONY:' | sed 's#^.PHONY: #   #'



# What the user can expect from this module.
.PHONY: list_final_output
list_final_output: SHELL=${GUARD_SHELL}
list_final_output: $(addsuffix _list,${PT_TYPES})
	@echo "are the expected final outputs."



########################################
# Clean up
.PHONY: clean clean.content clean.logs hide.logs
clean: SHELL=${GUARD_SHELL}
clean: clean.content clean.logs

clean.content: SHELL=${GUARD_SHELL}

clean.logs: SHELL=${GUARD_SHELL}
clean.logs:
	${RM} run-parallel-log* log.* run-p.*
	${RM} -r .logs

# Hide logs from user's view into .logs
hide.logs: SHELL=${GUARD_SHELL}
hide.logs: hide_logs_sub



########################################
# Resources Summary
.PHONY: time-mem
time-mem: SHELL=${GUARD_SHELL}
time-mem: resource_summary_sub



################################################################################
# WORD ALIGNMENT MODELS.

clean.content: clean.word_alignment_models

.PHONY: clean.word_alignment_models
clean.word_alignment_models: SHELL=${GUARD_SHELL}
clean.word_alignment_models:
	${RM} $(addsuffix .*, ${POSSIBLE_WORD_ALIGNMENT_MODELS})

.PHONY: word_alignment_models  $(addsuffix _model, ${POSSIBLE_WORD_ALIGNMENT_MODELS})
word_alignment_models: $(addsuffix _model, ${POSSIBLE_WORD_ALIGNMENT_MODELS})


# All word alignment models depend on ibm1 word alignment models except, of course, for ibm1 word alignment models.
$(foreach m, $(filter-out ${IBM1_MODEL_PFX}, ${POSSIBLE_WORD_ALIGNMENT_MODELS}), \
   $(eval ${m}_model: ibm1_model) \
)

# the meta target for word alignment model depends on word alignment model files.
# both forward and backward word alignment models require source and target corpora.
$(foreach m, $(call uc, ${POSSIBLE_WORD_ALIGNMENT_MODELS}), \
   $(eval \
		$(call lc, ${m})_model:  ${${m}_MODEL_PFX}.${TRAIN_TM}.${L2_GIVEN_L1X}  ${${m}_MODEL_PFX}.${TRAIN_TM}.${L1_GIVEN_L2X}) \
   $(eval \
		${${m}_MODEL_PFX}.${TRAIN_TM}.${L2_GIVEN_L1X}:  ${TRAIN_TM}${L1X} ${TRAIN_TM}${L2X}) \
   $(eval \
		${${m}_MODEL_PFX}.${TRAIN_TM}.${L1_GIVEN_L2X}:  ${TRAIN_TM}${L1X} ${TRAIN_TM}${L2X}) \
)

########################################
# EXAMPLE of the resulting code generated previously:
#ibm1_model: ${IBM1_MODEL_PFX}.${TRAIN_TM}.${L2_GIVEN_L1X}
#ibm1_model: ${IBM1_MODEL_PFX}.${TRAIN_TM}.${L1_GIVEN_L2X}
#
#${IBM1_MODEL_PFX}.${TRAIN_TM}.${L2_GIVEN_L1X}:  ${TRAIN_TM}${L1X} ${TRAIN_TM}${L2X}
#${IBM1_MODEL_PFX}.${TRAIN_TM}.${L1_GIVEN_L2X}:  ${TRAIN_TM}${L1X} ${TRAIN_TM}${L2X}



################################################################################
# JOINT PHRASE TABLES

clean.content: clean.jpts

.PHONY: clean.jpts
clean.jpts: SHELL=${GUARD_SHELL}
clean.jpts:
	$(RM) ${JPT_MODEL_PFX}.*
	${RM} -r JPTPAR*

.PHONY: jpts  $(addsuffix _jpt, ${POSSIBLE_WORD_ALIGNMENT_MODELS})
jpts: $(addsuffix _jpt, ${POSSIBLE_WORD_ALIGNMENT_MODELS})

# Definition of the generated makefile rules/targets:
# the meta target jpt have meta-dependency on a word alignment model,
# the meta target jpt have a dependency on jpt file.
# Defining a variable to hold the jpt file's prefix.
# jpts requires the word alignment models in both directions.
# jpts requires the source and target corpora.
$(foreach m, $(call uc, ${POSSIBLE_WORD_ALIGNMENT_MODELS}), \
   $(eval \
	   JPT_${m}_MODEL_PFX ?= ${JPT_MODEL_PFX}.${${m}_MODEL_PFX}) \
   $(eval \
	   $(call lc, ${m})_jpt: $(call lc, ${m})_model) \
   $(eval \
	   $(call lc, ${m})_jpt: ${JPT_${m}_MODEL_PFX}.${TRAIN_TM}.${JOINTX}) \
   $(eval \
		${JPT_${m}_MODEL_PFX}.${TRAIN_TM}.${JOINTX}:  ${${m}_MODEL_PFX}.${TRAIN_TM}.${L2_GIVEN_L1X} ${${m}_MODEL_PFX}.${TRAIN_TM}.${L1_GIVEN_L2X}) \
   $(eval \
		${JPT_${m}_MODEL_PFX}.${TRAIN_TM}.${JOINTX}:  ${TRAIN_TM}${L1X} ${TRAIN_TM}${L2X}) \
)

# EXAMPLE of the resulting code generated previously:
#JPT_HMM3_MODEL_PFX ?= ${JPT_MODEL_PFX}.${HMM3_MODEL_PFX}
#
#hmm3_jpt: hmm3_model
#hmm3_jpt: ${JPT_HMM3_MODEL_PFX}.${TRAIN_TM}.${JOINTX}
#
#${JPT_HMM3_MODEL_PFX}.${TRAIN_TM}.${JOINTX}:  ${HMM3_MODEL_PFX}.${TRAIN_TM}.${L2_GIVEN_L1X} ${HMM3_MODEL_PFX}.${TRAIN_TM}.${L1_GIVEN_L2X}
#${JPT_HMM3_MODEL_PFX}.${TRAIN_TM}.${JOINTX}:  ${TRAIN_TM}${L1X} ${TRAIN_TM}${L2X}



################################################################################
# SIGNIFICANCE PRUNING JOINT PHRASE TABLES

clean.content: clean.sig

.PHONY: clean.sig
clean.sig: SHELL=${GUARD_SHELL}
clean.sig:
	$(RM) ${SIG_MODEL_PFX}.*  cnts.${JPT_MODEL_PFX}.*
	${RM} -r JPTPAR*
	${RM} -r work_directory

.PHONY: sigs  $(addsuffix _sig, ${POSSIBLE_WORD_ALIGNMENT_MODELS})
sigs: $(addsuffix _sig, ${POSSIBLE_WORD_ALIGNMENT_MODELS})

# To create a sigpruned jpt we need an original jpt.
# To create a sigpruned jpt we need the source and target corpora.
# source language to target language
# m stands for model type
$(foreach m, $(call uc, ${POSSIBLE_WORD_ALIGNMENT_MODELS}), \
   $(eval \
	   $(call lc, ${m})_sig: $(call lc, ${m})_jpt) \
   $(eval \
	   $(call lc, ${m})_sig: ${SIG_${m}_MODEL_PFX}.${TRAIN_TM}.${JOINTX}) \
   $(eval \
		${SIG_${m}_MODEL_PFX}.${TRAIN_TM}.${JOINTX}:  ${JPT_${m}_MODEL_PFX}.${TRAIN_TM}.${JOINTX}) \
   $(eval \
		${SIG_${m}_MODEL_PFX}.${TRAIN_TM}.${JOINTX}:  ${TRAIN_TM}${L1X} ${TRAIN_TM}${L2X}) \
)


# target language to source language
$(foreach m, $(call uc, ${POSSIBLE_WORD_ALIGNMENT_MODELS}), \
   $(eval \
		${SIG_${m}_MODEL_PFX}.${TRAIN_TM}.${RJOINTX}:  ${JPT_${m}_MODEL_PFX}.${TRAIN_TM}.${RJOINTX}) \
   $(eval \
		${SIG_${m}_MODEL_PFX}.${TRAIN_TM}.${RJOINTX}:  ${TRAIN_TM}${L1X} ${TRAIN_TM}${L2X}) \
)



################################################################################
# CONDITIONAL PHRASE TABLES
# HMM1 => He-lex
# HMM2 => liang
# HMM3 => liang

clean.content: clean.cpts

.PHONY: clean.cpts
clean.cpts: SHELL=${GUARD_SHELL}
clean.cpts:
	$(RM) ${CPT_MODEL_PFX}.*

.PHONY: cpts  $(addsuffix _cpt, ${POSSIBLE_WORD_ALIGNMENT_MODELS}) merged_cpt
cpts: jpts
cpts: ibm2_cpt
cpts: hmm1_cpt
cpts: hmm2_cpt
cpts: hmm3_cpt
cpts: merged_cpt


# Let's define a couple of variables.
IBM2_SMOOTHERS_DESCRIPTION ?= -rf-zn
IBM2_CPT_PREFIX ?= ${CPT_MODEL_PFX}.${IBM2_MODEL_PFX}${IBM2_SMOOTHERS_DESCRIPTION}

HMM1_SMOOTHERS_DESCRIPTION ?= -rf-zn
HMM1_CPT_PREFIX ?= ${CPT_MODEL_PFX}.${HMM1_MODEL_PFX}${HMM1_SMOOTHERS_DESCRIPTION}

HMM2_SMOOTHERS_DESCRIPTION ?= -rf-zn
HMM2_CPT_PREFIX ?= ${CPT_MODEL_PFX}.${HMM2_MODEL_PFX}${HMM2_SMOOTHERS_DESCRIPTION}

HMM3_SMOOTHERS_DESCRIPTION ?= -rf-zn
HMM3_CPT_PREFIX ?= ${CPT_MODEL_PFX}.${HMM3_MODEL_PFX}${HMM3_SMOOTHERS_DESCRIPTION}

# Create a variable to hold the conditional phrase table file's name e.i. hmm1_cpt_list.
# Create meta-level dependencies between cpts and their jpts or sigs.
# Create a meta-level target to generate cpts.
$(foreach m, ${POSSIBLE_WORD_ALIGNMENT_MODELS}, \
   $(eval \
		${m}_cpt_list = ${$(call uc, ${m})_CPT_PREFIX}.${TRAIN_TM}.${L1_2_L2X}) \
   $(eval \
		${m}_cpt: ${m}_$(call lc, ${CPT_DEP_TAG})) \
   $(eval \
		${m}_cpt: ${${m}_cpt_list}) \
)

# Let's have a target to print out the variables that contain the conditional phrase table file's name.
%_cpt_list: SHELL=${GUARD_SHELL}
%_cpt_list: ; @echo ${$@}

# Creates dependencies for reversed Conditional Phrase Tables.
# Conditional Phrase Tables depend on a word alignment model for Zens-Ney's smoother.
# Conditional Phrase Tables depend on a joint frequency phrase table which can be raw or significance pruned (CPT_DEP_TAG).
$(foreach m, $(call uc, ${POSSIBLE_WORD_ALIGNMENT_MODELS}), \
   $(eval \
		${${m}_CPT_PREFIX}.${TRAIN_TM}.${L2_2_L1X}:  ${${m}_MODEL_PFX}.${TRAIN_TM}.${L2_GIVEN_L1X} ${${m}_MODEL_PFX}.${TRAIN_TM}.${L1_GIVEN_L2X}) \
   $(eval \
		${${m}_CPT_PREFIX}.${TRAIN_TM}.${L2_2_L1X}:  ${${CPT_DEP_TAG}_${m}_MODEL_PFX}.${TRAIN_TM}.${RJOINTX}) \
)

# Creates dependencies for Conditional Phrase Tables.
# Conditional Phrase Tables depend on a word alignment model for Zens-Ney's smoother.
# Conditional Phrase Tables depend on a jpt which can be raw or significance pruned (CPT_DEP_TAG).
# NOTE: CPT_DEP_TAG is either JPT or SIG
$(foreach m, $(call uc, ${POSSIBLE_WORD_ALIGNMENT_MODELS}), \
   $(eval \
		${${m}_CPT_PREFIX}.${TRAIN_TM}.${L1_2_L2X}:  ${${m}_MODEL_PFX}.${TRAIN_TM}.${L2_GIVEN_L1X} ${${m}_MODEL_PFX}.${TRAIN_TM}.${L1_GIVEN_L2X}) \
   $(eval \
		${${m}_CPT_PREFIX}.${TRAIN_TM}.${L1_2_L2X}:  ${${CPT_DEP_TAG}_${m}_MODEL_PFX}.${TRAIN_TM}.${JOINTX}) \
)

# EXAMPLE of the resulting code generated previously:
#hmm2_cpt_list = ${HMM2_CPT_PREFIX}.${TRAIN_TM}.${L1_2_L2X}
#hmm2_cpt_list: SHELL=${GUARD_SHELL}
#hmm2_cpt_list: ; @echo ${hmm2_cpt_list}
#
#.PHONY:  hmm2_cpt
#hmm2_cpt: hmm2_jpt
#hmm2_cpt: ${hmm2_cpt_list}
#
#${HMM2_CPT_PREFIX}.${TRAIN_TM}.${L2_2_L1X}:  ${HMM2_MODEL_PFX}.${TRAIN_TM}.${L2_GIVEN_L1X} ${HMM2_MODEL_PFX}.${TRAIN_TM}.${L1_GIVEN_L2X}
#${HMM2_CPT_PREFIX}.${TRAIN_TM}.${L1_2_L2X}:  ${HMM2_MODEL_PFX}.${TRAIN_TM}.${L2_GIVEN_L1X} ${HMM2_MODEL_PFX}.${TRAIN_TM}.${L1_GIVEN_L2X}
#
#${HMM2_CPT_PREFIX}.${TRAIN_TM}.${L2_2_L1X}:  ${${CPT_DEP_TAG}_HMM2_MODEL_PFX}.${TRAIN_TM}.${RJOINTX}
#${HMM2_CPT_PREFIX}.${TRAIN_TM}.${L1_2_L2X}:  ${${CPT_DEP_TAG}_HMM2_MODEL_PFX}.${TRAIN_TM}.${JOINTX}


########################################
# MERGED CONDITIONAL PHRASE TABLES
# requires: MERGED_CPT_ZN_MODEL & MERGED_CPT_JPT_TYPES to be properly defined.
MERGED_CPT_SMOOTHERS_DESCRIPTION ?= -rf-zn
MERGED_CPT_PREFIX ?= ${CPT_MODEL_PFX}.merged.${${MERGED_CPT_ZN_MODEL}_MODEL_PFX}${MERGED_CPT_SMOOTHERS_DESCRIPTION}
MERGED_CPT_ZN_MODEL ?= HMM3
MERGED_CPT_JPT_TYPES ?= IBM2 HMM3

# We need to specify what's the type of the models for Zen-Ney's smoother.
${CPT_MODEL_PFX}.merged.${IBM1_MODEL_PFX}%: WORD_MODEL_TYPE=-ibm 1
${CPT_MODEL_PFX}.merged.${IBM2_MODEL_PFX}%: WORD_MODEL_TYPE=-ibm 2
${CPT_MODEL_PFX}.merged.hmm%: WORD_MODEL_TYPE=-hmm

# Let's define what are the merged cpt file names.
merged_cpt_list = ${MERGED_CPT_PREFIX}.${TRAIN_TM}.${L1_2_L2X}

# Meta target that will create the merged conditional phrase tables.
merged_cpt: ${merged_cpt_list}

SIG_MERGED_PFX := ${SIG_MODEL_PFX}.merged
JPT_MERGED_PFX := ${JPT_MODEL_PFX}.merged


# Merged conditional phrase tables depends on a word model alignment for Zens-Ney's smoother.
# Merged conditional phrase tables depends on either a merged jpt (normal scenario) or a merged sig (when using significance pruning).
${MERGED_CPT_PREFIX}.${TRAIN_TM}.${L2_2_L1X}:  ${${MERGED_CPT_ZN_MODEL}_MODEL_PFX}.${TRAIN_TM}.${L2_GIVEN_L1X} ${${MERGED_CPT_ZN_MODEL}_MODEL_PFX}.${TRAIN_TM}.${L1_GIVEN_L2X}
${MERGED_CPT_PREFIX}.${TRAIN_TM}.${L2_2_L1X}:  ${${CPT_DEP_TAG}_MERGED_PFX}.${TRAIN_TM}.${RJOINTX}

${MERGED_CPT_PREFIX}.${TRAIN_TM}.${L1_2_L2X}:  ${${MERGED_CPT_ZN_MODEL}_MODEL_PFX}.${TRAIN_TM}.${L2_GIVEN_L1X} ${${MERGED_CPT_ZN_MODEL}_MODEL_PFX}.${TRAIN_TM}.${L1_GIVEN_L2X}
${MERGED_CPT_PREFIX}.${TRAIN_TM}.${L1_2_L2X}:  ${${CPT_DEP_TAG}_MERGED_PFX}.${TRAIN_TM}.${JOINTX}


# A merged jpt depends on user define type of joint frequency count file.
.INTERMEDIATE: ${JPT_MERGED_PFX}.${TRAIN_TM}.${RJOINTX} ${JPT_MERGED_PFX}.${TRAIN_TM}.${JOINTX}
${JPT_MERGED_PFX}.${TRAIN_TM}.${RJOINTX}:  $(foreach j, ${MERGED_CPT_JPT_TYPES}, ${JPT_${j}_MODEL_PFX}.${TRAIN_TM}.${RJOINTX})
${JPT_MERGED_PFX}.${TRAIN_TM}.${JOINTX}:   $(foreach j, ${MERGED_CPT_JPT_TYPES}, ${JPT_${j}_MODEL_PFX}.${TRAIN_TM}.${JOINTX})


# Significance pruning model depends on a "raw" joint frequency count file.
# Significance pruning model depends on the source and target corpora.
${SIG_MERGED_PFX}.${TRAIN_TM}.${RJOINTX}:  ${JPT_MERGED_PFX}.${TRAIN_TM}.${RJOINTX}
${SIG_MERGED_PFX}.${TRAIN_TM}.${RJOINTX}:  ${TRAIN_TM}${L1X} ${TRAIN_TM}${L2X}

${SIG_MERGED_PFX}.${TRAIN_TM}.${JOINTX}:  ${JPT_MERGED_PFX}.${TRAIN_TM}.${JOINTX}
${SIG_MERGED_PFX}.${TRAIN_TM}.${JOINTX}:  ${TRAIN_TM}${L1X} ${TRAIN_TM}${L2X}


########################################
# Let's do some validation when the user wants a merged_cpt.
ifeq ($(filter merged_cpt, ${PT_TYPES}),merged_cpt)
# Make sure there is only one MERGED_CPT_ZN_MODEL.
ifneq ($(words ${MERGED_CPT_ZN_MODEL}), 1)
$(error You must specify one and only one MERGED_CPT_ZN_MODEL!)
endif

# Make sure MERGED_CPT_ZN_MODEL is valid.
ifneq ($(filter-out HMM3 HMM2 HMM1 IBM2 IBM1, ${MERGED_CPT_ZN_MODEL}),)
$(error MERGED_CPT_ZN_MODEL must be one of HMM3, HMM2, HMM1, IBM2 or IBM1 instead of ${MERGED_CPT_ZN_MODEL})
endif

# Make sure MERGED_CPT_JPT_TYPES are valid.
ifneq ($(filter-out HMM3 HMM2 HMM1 IBM2 IBM1, ${MERGED_CPT_JPT_TYPES}),)
$(error MERGED_CPT_JPT_TYPES must be one of HMM3, HMM2, HMM1, IBM2 or IBM1 instead of ${MERGED_CPT_JPT_TYPES})
endif
else
ifdef USE_SIGPRUNING
$(error Significance pruning and merged_cpt is not yet implemented!!!)
endif
endif



################################################################################
# Tightly Packed Phrase Tables.
# We need the full file names to be able to trigger all tppt.
# PT_TYPE is what the user asked for so we need to change ibm2_cpt =>
# ibm2_cpt_list and evaluate its content which will be the text phrase table
# file name.  Then we only need to change the text file name to tightly packed
# file name.
tppt_list := $(addsuffix .tppt, $(basename $(foreach a, $(PT_TYPES:=_list), ${$a})))

.PHONY: tppt
tppt portageLive: ${tppt_list}




################################################################################
# The test target is designed to be a unittest.  Its purpose is not to run
# commands but rather validate that all variables are properly expanded and
# that the resulting dependencies are all correct.

# Verify that make is capable of generating all required targets for merged_cpt and some other cpt.
.PHONY: unittest1
unittest1:
	make -Bnj1 tppt PT_TYPES='ibm2_cpt hmm3_cpt merged_cpt' MERGED_CPT_JPT_TYPES='IBM2 HMM1 HMM3 HMM2 IBM1' MERGED_CPT_ZN_MODEL=IBM1

# Verify that make is capable of generating all required target for one cpt that has been significance pruned.
.PHONY: unittest2
unittest2:
	make -Bnj1 USE_SIGPRUNING=1 SIG_OPTS="-keep -sigopts '-par-driver fork'" ibm2_cpt

# Verify that make is capable of generating all required target for a merged cpt that has been significance pruned.
.PHONY: unittest3
unittest3:
	make -Bnj1 USE_SIGPRUNING=1 SIG_OPTS="-keep -sigopts '-par-driver fork'" merged_cpt


$(foreach a, a b, $(eval %.$a: ;echo $$@ $$*))

