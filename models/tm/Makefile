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


# Source file requirements
# <PREFIX>_<LANGUAGE>.<LANGX>
 
# Variables we use from ../../Makefile.params:
# PT_TYPES indicates what type of phrase table we want to generate.

# Mandatory include: master config file.
include ../../Makefile.params

# Lastly include the master toolkit
include ../../Makefile.toolkit

# Include the config file.
MAKEFILE_PARAMS ?= Makefile.params
-include ${MAKEFILE_PARAMS}

# Lets rename the language identifiers for the toolkit.
lang1 = ${SRC_LANG}
lang2 = ${TGT_LANG}

L1X = _${SRC_LANG}${LANGXZ}
L2X = _${TGT_LANG}${LANGXZ}

include Makefile.toolkit


# What is this module's name.
MODULE_NAME ?= tm

# TODO: Make sure this Makefile works for Portage's cluster.
# This will require that run-parallel.sh -c RP_OPTS be functional.
SHELL = ${FRAMEWORK_SHELL}

# Where we can find the parallel corpora
CORPORA_DIR ?= ../../corpora

# Already defined in the master config file.
#SRC_LANG ?= en
#TGT_LANG ?= fr
#LANGX    ?= .lc
#LANGXZ   ?= ${langx}.gz

## Map source and target language to shorter variable name.
#SRC  ?= ${SRC_LANG}
#TGT  ?= ${TGT_LANG}
#SRCX ?= _${SRC}${LANGXZ}
#TGTX ?= _${TGT}${LANGXZ}
#
## IBM / HMM models extension
#SRC_GIVEN_TGT  = ${SRC}_given_${TGT}
#TGT_GIVEN_SRC  = ${TGT}_given_${SRC}
#SRC_GIVEN_TGTX = ${SRC_GIVEN_TGT}.gz
#TGT_GIVEN_SRCX = ${TGT_GIVEN_SRC}.gz
#
## conditional phrase table extension
#SRC_2_TGT  = ${SRC}2${TGT}
#TGT_2_SRC  = ${TGT}2${SRC}
#SRC_2_TGTX = ${SRC_2_TGT}.gz
#TGT_2_SRCX = ${TGT_2_SRC}.gz

# What parallel corpora is to be used for creating the models
TRAIN_TM ?= train

# This script might produce directory and we want to easily remove them.
RM = rm -rf

# After this Makefile, the following targets/files are precious.
FILES_TO_BE_LOCKED = ibm* hmm* jpt* cpt*



# Allows to search for alignment files in corpus
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
	@echo "Available targets are:"
	@cat $(firstword $(MAKEFILE_LIST)) | egrep '^.PHONY:' | sed 's#^.PHONY: ##'



# What the user can expect from this module.
.PHONY: list_final_output
list_final_output: SHELL=${GUARD_SHELL}
list_final_output: $(addsuffix _list,${PT_TYPES})
	@echo "are the expected final output."



########################################
# CLEAN-UP
.PHONY: clean
clean: SHELL=${GUARD_SHELL}

.PHONY: clean.content
clean: clean.content
clean.content: SHELL=${GUARD_SHELL}



.PHONY: clean.logs
clean: clean.logs
clean.logs: SHELL=${GUARD_SHELL}
clean.logs:
	${RM} run-parallel-log* log.* run-p.*
	${RM} -r .logs



########################################
# resources summary
.PHONY: summary
summary: resource_summary_sub



################################################################################
# WORD ALIGNMENT MODELS.
.PHONY: word_alignment_models
word_alignment_models: ibm1_model
word_alignment_models: ibm2_model
word_alignment_models: hmm1_model
word_alignment_models: hmm2_model
word_alignment_models: hmm3_model



########################################
# TRAINING THE IBM1 MODELS
.PHONY:  ibm1_model
ibm1_model: ${IBM1_MODEL_PFX}.${TRAIN_TM}.${L2_GIVEN_L1X}
ibm1_model: ${IBM1_MODEL_PFX}.${TRAIN_TM}.${L1_GIVEN_L2X}

${IBM1_MODEL_PFX}.${TRAIN_TM}.${L2_GIVEN_L1X}:  ${TRAIN_TM}${L1X} ${TRAIN_TM}${L2X}
${IBM1_MODEL_PFX}.${TRAIN_TM}.${L1_GIVEN_L2X}:  ${TRAIN_TM}${L1X} ${TRAIN_TM}${L2X}

clean.content: clean.ibm1

.PHONY: clean.ibm1
clean.ibm1: SHELL=${GUARD_SHELL}
clean.ibm1:
	$(RM) ${IBM1_MODEL_PFX}.*



########################################
# TRAINING THE IBM2 MODELS
# requires: source and target corpora and ibm1 models.
.PHONY:  ibm2_model
ibm2_model: ibm1_model
ibm2_model: ${IBM2_MODEL_PFX}.${TRAIN_TM}.${L2_GIVEN_L1X}
ibm2_model: ${IBM2_MODEL_PFX}.${TRAIN_TM}.${L1_GIVEN_L2X}

${IBM2_MODEL_PFX}.${TRAIN_TM}.${L2_GIVEN_L1X}:  ${TRAIN_TM}${L1X} ${TRAIN_TM}${L2X}
${IBM2_MODEL_PFX}.${TRAIN_TM}.${L1_GIVEN_L2X}:  ${TRAIN_TM}${L1X} ${TRAIN_TM}${L2X}

clean.content: clean.ibm2

.PHONY: clean.ibm2
clean.ibm2: SHELL=${GUARD_SHELL}
clean.ibm2:
	$(RM) ${IBM2_MODEL_PFX}.*



########################################
# TRAINING THE HMM1 MODELS => He-lex
# requires: source and target corpora and ibm1 models.
.PHONY:  hmm1_model
hmm1_model: ibm1_model
hmm1_model: ${HMM1_MODEL_PFX}.${TRAIN_TM}.${L2_GIVEN_L1X}
hmm1_model: ${HMM1_MODEL_PFX}.${TRAIN_TM}.${L1_GIVEN_L2X}

${HMM1_MODEL_PFX}.${TRAIN_TM}.${L2_GIVEN_L1X}:  ${TRAIN_TM}${L1X} ${TRAIN_TM}${L2X}
${HMM1_MODEL_PFX}.${TRAIN_TM}.${L1_GIVEN_L2X}:  ${TRAIN_TM}${L1X} ${TRAIN_TM}${L2X}

clean.content: clean.hmm1

.PHONY: clean.hmm1
clean.hmm1: SHELL=${GUARD_SHELL}
clean.hmm1:
	$(RM) ${HMM1_MODEL_PFX}.*



########################################
# TRAINING THE HMM2 MODELS => liang variant
# requires: source and target corpora and ibm1 models.
.PHONY:  hmm2_model
hmm2_model: ibm1_model
hmm2_model: ${HMM2_MODEL_PFX}.${TRAIN_TM}.${L2_GIVEN_L1X}
hmm2_model: ${HMM2_MODEL_PFX}.${TRAIN_TM}.${L1_GIVEN_L2X}

${HMM2_MODEL_PFX}.${TRAIN_TM}.${L2_GIVEN_L1X}:  ${TRAIN_TM}${L1X} ${TRAIN_TM}${L2X}
${HMM2_MODEL_PFX}.${TRAIN_TM}.${L1_GIVEN_L2X}:  ${TRAIN_TM}${L1X} ${TRAIN_TM}${L2X}

clean.content: clean.hmm2

.PHONY: clean.hmm2
clean.hmm2: SHELL=${GUARD_SHELL}
clean.hmm2:
	$(RM) ${HMM2_MODEL_PFX}.*



########################################
# TRAINING THE HMM3 MODELS => liang variant
# requires: source and target corpora and ibm1 models.
.PHONY:  hmm3_model
hmm3_model: ibm1_model
hmm3_model: ${HMM3_MODEL_PFX}.${TRAIN_TM}.${L2_GIVEN_L1X}
hmm3_model: ${HMM3_MODEL_PFX}.${TRAIN_TM}.${L1_GIVEN_L2X}

#Note: We use "-end-dist" instead of "-start-dist -final-dist -anchor" because
#      PORTAGEshared lacks "-start-dist"
${HMM3_MODEL_PFX}.${TRAIN_TM}.${L2_GIVEN_L1X}:  ${TRAIN_TM}${L1X} ${TRAIN_TM}${L2X}
${HMM3_MODEL_PFX}.${TRAIN_TM}.${L1_GIVEN_L2X}:  ${TRAIN_TM}${L1X} ${TRAIN_TM}${L2X}

clean.content: clean.hmm3

.PHONY: clean.hmm3
clean.hmm3: SHELL=${GUARD_SHELL}
clean.hmm3:
	$(RM) ${HMM3_MODEL_PFX}.*



################################################################################
# JOINT PHRASE TABLES
.PHONY: jpts
jpts: ibm2_jpt
jpts: hmm1_jpt
jpts: hmm2_jpt
jpts: hmm3_jpt

clean.content: clean.jpts

.PHONY: clean.jpts
clean.jpts: SHELL=${GUARD_SHELL}
clean.jpts:
	$(RM) jpt.*
	${RM} -r JPTPAR*


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
.PHONY: cpts
cpts: jpts
cpts: ibm2_cpt
cpts: hmm1_cpt
cpts: hmm2_cpt
cpts: hmm3_cpt

clean.content: clean.cpts

.PHONY: clean.cpts
clean.cpts: SHELL=${GUARD_SHELL}
clean.cpts:
	$(RM) cpt.*

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

