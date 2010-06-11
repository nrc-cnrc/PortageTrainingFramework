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
	${RM} $(addsuffix .*,${WA_MODEL_PREFIXES})

.PHONY: word_alignment_models
word_alignment_models: ibm1_model
word_alignment_models: ibm2_model
word_alignment_models: hmm1_model
word_alignment_models: hmm2_model
word_alignment_models: hmm3_model


########################################
# TRAINING THE IBM1 MODELS
WA_MODEL_PREFIXES += ${IBM1_MODEL_PFX}

.PHONY:  ibm1_model
ibm1_model: ${IBM1_MODEL_PFX}.${TRAIN_TM}.${L2_GIVEN_L1X}
ibm1_model: ${IBM1_MODEL_PFX}.${TRAIN_TM}.${L1_GIVEN_L2X}

${IBM1_MODEL_PFX}.${TRAIN_TM}.${L2_GIVEN_L1X}:  ${TRAIN_TM}${L1X} ${TRAIN_TM}${L2X}
${IBM1_MODEL_PFX}.${TRAIN_TM}.${L1_GIVEN_L2X}:  ${TRAIN_TM}${L1X} ${TRAIN_TM}${L2X}


########################################
# TRAINING THE IBM2 MODELS
# requires: source and target corpora and ibm1 models.
WA_MODEL_PREFIXES += ${IBM2_MODEL_PFX}

.PHONY:  ibm2_model
ibm2_model: ibm1_model
ibm2_model: ${IBM2_MODEL_PFX}.${TRAIN_TM}.${L2_GIVEN_L1X}
ibm2_model: ${IBM2_MODEL_PFX}.${TRAIN_TM}.${L1_GIVEN_L2X}

${IBM2_MODEL_PFX}.${TRAIN_TM}.${L2_GIVEN_L1X}:  ${TRAIN_TM}${L1X} ${TRAIN_TM}${L2X}
${IBM2_MODEL_PFX}.${TRAIN_TM}.${L1_GIVEN_L2X}:  ${TRAIN_TM}${L1X} ${TRAIN_TM}${L2X}


########################################
# TRAINING THE HMM1 MODELS => He-lex
# requires: source and target corpora and ibm1 models.
WA_MODEL_PREFIXES += ${HMM1_MODEL_PFX}

.PHONY:  hmm1_model
hmm1_model: ibm1_model
hmm1_model: ${HMM1_MODEL_PFX}.${TRAIN_TM}.${L2_GIVEN_L1X}
hmm1_model: ${HMM1_MODEL_PFX}.${TRAIN_TM}.${L1_GIVEN_L2X}

${HMM1_MODEL_PFX}.${TRAIN_TM}.${L2_GIVEN_L1X}:  ${TRAIN_TM}${L1X} ${TRAIN_TM}${L2X}
${HMM1_MODEL_PFX}.${TRAIN_TM}.${L1_GIVEN_L2X}:  ${TRAIN_TM}${L1X} ${TRAIN_TM}${L2X}


########################################
# TRAINING THE HMM2 MODELS => liang variant
# requires: source and target corpora and ibm1 models.
WA_MODEL_PREFIXES += ${HMM2_MODEL_PFX}

.PHONY:  hmm2_model
hmm2_model: ibm1_model
hmm2_model: ${HMM2_MODEL_PFX}.${TRAIN_TM}.${L2_GIVEN_L1X}
hmm2_model: ${HMM2_MODEL_PFX}.${TRAIN_TM}.${L1_GIVEN_L2X}

${HMM2_MODEL_PFX}.${TRAIN_TM}.${L2_GIVEN_L1X}:  ${TRAIN_TM}${L1X} ${TRAIN_TM}${L2X}
${HMM2_MODEL_PFX}.${TRAIN_TM}.${L1_GIVEN_L2X}:  ${TRAIN_TM}${L1X} ${TRAIN_TM}${L2X}


########################################
# TRAINING THE HMM3 MODELS => liang variant
# requires: source and target corpora and ibm1 models.
WA_MODEL_PREFIXES += ${HMM3_MODEL_PFX}

.PHONY:  hmm3_model
hmm3_model: ibm1_model
hmm3_model: ${HMM3_MODEL_PFX}.${TRAIN_TM}.${L2_GIVEN_L1X}
hmm3_model: ${HMM3_MODEL_PFX}.${TRAIN_TM}.${L1_GIVEN_L2X}

#Note: We use "-end-dist" instead of "-start-dist -final-dist -anchor" because
#      PORTAGEshared lacks "-start-dist"
${HMM3_MODEL_PFX}.${TRAIN_TM}.${L2_GIVEN_L1X}:  ${TRAIN_TM}${L1X} ${TRAIN_TM}${L2X}
${HMM3_MODEL_PFX}.${TRAIN_TM}.${L1_GIVEN_L2X}:  ${TRAIN_TM}${L1X} ${TRAIN_TM}${L2X}



################################################################################
# JOINT PHRASE TABLES

clean.content: clean.jpts

.PHONY: clean.jpts
clean.jpts: SHELL=${GUARD_SHELL}
clean.jpts:
	$(RM) jpt.*
	${RM} -r JPTPAR*

.PHONY: jpts
jpts: ibm2_jpt
jpts: hmm1_jpt
jpts: hmm2_jpt
jpts: hmm3_jpt


########################################
# IBM2 JOINT PHRASE TABLES
# requires: ibm2 models, source and target corpora.
.PHONY:  ibm2_jpt
ibm2_jpt: ibm2_model
#ibm2_jpt: $(foreach t, ${TRAIN_TM}, ${IBM2_JPT_PREFIX}.$t.${JOINTX})
ibm2_jpt: ${JPT_MODEL_PFX}.${IBM2_MODEL_PFX}.${TRAIN_TM}.${JOINTX}

JPT_IBM2_MODEL_PFX ?= ${JPT_MODEL_PFX}.${IBM2_MODEL_PFX}
${JPT_IBM2_MODEL_PFX}.${TRAIN_TM}.${JOINTX}:  ${IBM2_MODEL_PFX}.${TRAIN_TM}.${L2_GIVEN_L1X} ${IBM2_MODEL_PFX}.${TRAIN_TM}.${L1_GIVEN_L2X}  ${TRAIN_TM}${L1X} ${TRAIN_TM}${L2X}


########################################
# HMM1 JOINT PHRASE TABLES => He's lexical variant
# requires: hmm models, source and target corpora.
.PHONY:  hmm1_jpt
hmm1_jpt: hmm1_model
#hmm1_jpt: $(foreach t, ${TRAIN_TM}, ${HMM1_JPT_PREFIX}.$t.${JOINTX})
hmm1_jpt: ${JPT_MODEL_PFX}.${HMM1_MODEL_PFX}.${TRAIN_TM}.${JOINTX}

JPT_HMM1_MODEL_PFX ?= ${JPT_MODEL_PFX}.${HMM1_MODEL_PFX}
${JPT_HMM1_MODEL_PFX}.${TRAIN_TM}.${JOINTX}:  ${HMM1_MODEL_PFX}.${TRAIN_TM}.${L2_GIVEN_L1X} ${HMM1_MODEL_PFX}.${TRAIN_TM}.${L1_GIVEN_L2X}  ${TRAIN_TM}${L1X} ${TRAIN_TM}${L2X}


########################################
# HMM2 JOINT PHRASE TABLES => Liang's variant
# requires: hmm2 models, source and target corpora.
.PHONY:  hmm2_jpt
hmm2_jpt: hmm2_model
#hmm2_jpt: $(foreach t, ${TRAIN_TM}, ${HMM2_JPT_PREFIX}.$t.${JOINTX})
hmm2_jpt: ${JPT_MODEL_PFX}.${HMM2_MODEL_PFX}.${TRAIN_TM}.${JOINTX}

JPT_HMM2_MODEL_PFX ?= ${JPT_MODEL_PFX}.${HMM2_MODEL_PFX}
${JPT_HMM2_MODEL_PFX}.${TRAIN_TM}.${JOINTX}:  ${HMM2_MODEL_PFX}.${TRAIN_TM}.${L2_GIVEN_L1X} ${HMM2_MODEL_PFX}.${TRAIN_TM}.${L1_GIVEN_L2X}  ${TRAIN_TM}${L1X} ${TRAIN_TM}${L2X}


########################################
# HMM3 JOINT PHRASE TABLES => Liang's variant
# requires: hmm3 models, source and target corpora.
.PHONY:  hmm3_jpt
hmm3_jpt: hmm3_model
#hmm3_jpt: $(foreach t, ${TRAIN_TM}, ${HMM3_JPT_PREFIX}.$t.${JOINTX})
hmm3_jpt: ${JPT_MODEL_PFX}.${HMM3_MODEL_PFX}.${TRAIN_TM}.${JOINTX}

JPT_HMM3_MODEL_PFX ?= ${JPT_MODEL_PFX}.${HMM3_MODEL_PFX}
${JPT_HMM3_MODEL_PFX}.${TRAIN_TM}.${JOINTX}:  ${HMM3_MODEL_PFX}.${TRAIN_TM}.${L2_GIVEN_L1X} ${HMM3_MODEL_PFX}.${TRAIN_TM}.${L1_GIVEN_L2X}  ${TRAIN_TM}${L1X} ${TRAIN_TM}${L2X}



################################################################################
# CONDITIONAL PHRASE TABLES

clean.content: clean.cpts

.PHONY: clean.cpts
clean.cpts: SHELL=${GUARD_SHELL}
clean.cpts:
	$(RM) cpt.*

.PHONY: cpts
cpts: jpts
cpts: ibm2_cpt
cpts: hmm1_cpt
cpts: hmm2_cpt
cpts: hmm3_cpt


########################################
# IBM CONDITIONAL PHRASE TABLES
# requires: ibm2 models and ibm2 JOINT frequency phrase table.
IBM2_SMOOTHERS_DESCRIPTION ?= -rf-zn
IBM2_CPT_PREFIX ?= ${CPT_MODEL_PFX}.${IBM2_MODEL_PFX}${IBM2_SMOOTHERS_DESCRIPTION}

ibm2_cpt_list = ${IBM2_CPT_PREFIX}.${TRAIN_TM}.${L1_2_L2X}
ibm2_cpt_list: SHELL=${GUARD_SHELL}
ibm2_cpt_list:
	@echo ${ibm2_cpt_list}

.PHONY:  ibm2_cpt
ibm2_cpt: ibm2_jpt
ibm2_cpt: ${ibm2_cpt_list}

${IBM2_CPT_PREFIX}.${TRAIN_TM}.${L2_2_L1X}:  ${IBM2_MODEL_PFX}.${TRAIN_TM}.${L2_GIVEN_L1X} ${IBM2_MODEL_PFX}.${TRAIN_TM}.${L1_GIVEN_L2X} ${JPT_IBM2_MODEL_PFX}.${TRAIN_TM}.${RJOINTX}
${IBM2_CPT_PREFIX}.${TRAIN_TM}.${L1_2_L2X}:  ${IBM2_MODEL_PFX}.${TRAIN_TM}.${L2_GIVEN_L1X} ${IBM2_MODEL_PFX}.${TRAIN_TM}.${L1_GIVEN_L2X} ${JPT_IBM2_MODEL_PFX}.${TRAIN_TM}.${JOINTX}


########################################
# HMM1 CONDITIONAL PHRASE TABLES => He-lex
# requires: hmm1 models and ibm2 JOINT frequency phrase table.
HMM1_SMOOTHERS_DESCRIPTION ?= -rf-zn
HMM1_CPT_PREFIX ?= ${CPT_MODEL_PFX}.${HMM1_MODEL_PFX}${HMM1_SMOOTHERS_DESCRIPTION}

hmm1_cpt_list = ${HMM1_CPT_PREFIX}.${TRAIN_TM}.${L1_2_L2X}
hmm1_cpt_list: SHELL=${GUARD_SHELL}
hmm1_cpt_list:
	@echo ${hmm1_cpt_list}

.PHONY:  hmm1_cpt
hmm1_cpt: hmm1_jpt
hmm1_cpt: ${hmm1_cpt_list}

${HMM1_CPT_PREFIX}.${TRAIN_TM}.${L2_2_L1X}:  ${HMM1_MODEL_PFX}.${TRAIN_TM}.${L2_GIVEN_L1X} ${HMM1_MODEL_PFX}.${TRAIN_TM}.${L1_GIVEN_L2X} ${JPT_HMM1_MODEL_PFX}.${TRAIN_TM}.${RJOINTX}
${HMM1_CPT_PREFIX}.${TRAIN_TM}.${L1_2_L2X}:  ${HMM1_MODEL_PFX}.${TRAIN_TM}.${L2_GIVEN_L1X} ${HMM1_MODEL_PFX}.${TRAIN_TM}.${L1_GIVEN_L2X} ${JPT_HMM1_MODEL_PFX}.${TRAIN_TM}.${JOINTX}


########################################
# HMM2 CONDITIONAL PHRASE TABLES => liang
# requires: hmm2 models and ibm2 JOINT frequency phrase table.
HMM2_SMOOTHERS_DESCRIPTION ?= -rf-zn
HMM2_CPT_PREFIX ?= ${CPT_MODEL_PFX}.${HMM2_MODEL_PFX}${HMM2_SMOOTHERS_DESCRIPTION}

hmm2_cpt_list = ${HMM2_CPT_PREFIX}.${TRAIN_TM}.${L1_2_L2X}
hmm2_cpt_list: SHELL=${GUARD_SHELL}
hmm2_cpt_list:
	@echo ${hmm2_cpt_list}

.PHONY:  hmm2_cpt
hmm2_cpt: hmm2_jpt
hmm2_cpt: ${hmm2_cpt_list}

${HMM2_CPT_PREFIX}.${TRAIN_TM}.${L2_2_L1X}:  ${HMM2_MODEL_PFX}.${TRAIN_TM}.${L2_GIVEN_L1X} ${HMM2_MODEL_PFX}.${TRAIN_TM}.${L1_GIVEN_L2X} ${JPT_HMM2_MODEL_PFX}.${TRAIN_TM}.${RJOINTX}
${HMM2_CPT_PREFIX}.${TRAIN_TM}.${L1_2_L2X}:  ${HMM2_MODEL_PFX}.${TRAIN_TM}.${L2_GIVEN_L1X} ${HMM2_MODEL_PFX}.${TRAIN_TM}.${L1_GIVEN_L2X} ${JPT_HMM2_MODEL_PFX}.${TRAIN_TM}.${JOINTX}


########################################
# HMM3 CONDITIONAL PHRASE TABLES => liang
# requires: hmm3 models and ibm2 JOINT frequency phrase table.
HMM3_SMOOTHERS_DESCRIPTION ?= -rf-zn
HMM3_CPT_PREFIX ?= ${CPT_MODEL_PFX}.${HMM3_MODEL_PFX}${HMM3_SMOOTHERS_DESCRIPTION}

hmm3_cpt_list = ${HMM3_CPT_PREFIX}.${TRAIN_TM}.${L1_2_L2X}
hmm3_cpt_list: SHELL=${GUARD_SHELL}
hmm3_cpt_list:
	@echo ${hmm3_cpt_list}

.PHONY:  hmm3_cpt
hmm3_cpt: hmm3_jpt
hmm3_cpt: ${hmm3_cpt_list}

${HMM3_CPT_PREFIX}.${TRAIN_TM}.${L2_2_L1X}:  ${HMM3_MODEL_PFX}.${TRAIN_TM}.${L2_GIVEN_L1X} ${HMM3_MODEL_PFX}.${TRAIN_TM}.${L1_GIVEN_L2X} ${JPT_HMM3_MODEL_PFX}.${TRAIN_TM}.${RJOINTX}
${HMM3_CPT_PREFIX}.${TRAIN_TM}.${L1_2_L2X}:  ${HMM3_MODEL_PFX}.${TRAIN_TM}.${L2_GIVEN_L1X} ${HMM3_MODEL_PFX}.${TRAIN_TM}.${L1_GIVEN_L2X} ${JPT_HMM3_MODEL_PFX}.${TRAIN_TM}.${JOINTX}



################################################################################
# Tightly Packed Phrase Table.
# We need the full file name to be able to trigger all tppt.
# PT_TYPE is what the user asked for so we need to change ibm2_cpt =>
# ibm2_cpt_list and evaluate its content which will be the text phrase table
# file name.  Then we only need to change the text file name to tightly packed
# file name.
tppt_list = $(addsuffix .tppt, $(basename $(foreach a, $(PT_TYPES:=_list), ${$a})))

.PHONY: tppt
tppt: ${tppt_list}



################################################################################
# Transform model for PortageLive
PORTAGE_LIVE_DEST_DIR ?= ../portageLive/models/tm
.PHONY: portageLive
portageLive: SHELL=${GUARD_SHELL}
portageLive: ${tppt_list}
	mkdir -p ${PORTAGE_LIVE_DEST_DIR}
	${RM} -r ${PORTAGE_LIVE_DEST_DIR}/*
	cd ${PORTAGE_LIVE_DEST_DIR} && ln -fs $(addprefix ../../../tm/, $+) .

