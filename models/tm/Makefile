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
# Copyright 2008, 2012, Sa Majeste la Reine du Chef du Canada
# Copyright 2008, 2012, Her Majesty in Right of Canada

TM_DIR_PFX := $(dir $(lastword ${MAKEFILE_LIST}))

# Source file requirements.
# <PREFIX>_<LANGUAGE>.<LANGX>
 
# Variables we use from ../../Makefile.params:
# PT_TYPES indicates what type of phrase table we want to generate.

# Mandatory include: master config file.
include ${TM_DIR_PFX}../../Makefile.params

# Include and override parameters with user specific config file.
MAKEFILE_PARAMS ?= Makefile.params
-include ${TM_DIR_PFX}${MAKEFILE_PARAMS}

# This is the Makefile that contains all targets required to build Translation
# Models and some variable's defintion that might be used by the user in its
# Makefile.params.
include ${TM_DIR_PFX}Makefile.toolkit

# Lastly include the master toolkit
include ${TM_DIR_PFX}../../Makefile.toolkit

# GNU Make Standard Library
include ${TM_DIR_PFX}../../gmsl/gmsl   # functions: uc

# What is this module's name.
MODULE_NAME ?= tm

# Where we can find the parallel corpora.
CORPORA_DIR ?= ${TM_DIR_PFX}../../corpora

# What parallel corpora is to be used for creating the models.
TRAIN_TM ?= train

ALL_TMS ?= $(strip ${TRAIN_TM} ${MIXTM})

# This script might produce directory and we want to easily remove them.
RM := rm -rf

# After this Makefile, the following targets/files are precious.
FILES_TO_BE_LOCKED = ibm* hmm* jpt* cpt*



# Allows to search for alignment files in corpus.
vpath %${L1X} ${CORPORA_DIR}
vpath %${L2X} ${CORPORA_DIR}
vpath %${L1} ${CORPORA_DIR}
vpath %${L2} ${CORPORA_DIR}

# Where to look for built CPTs (cpts used for mixing are moved to mixtm).
vpath ${CPT_MODEL_PFX}%${L1_2_L2X} ${TM_DIR_PFX} ${TM_DIR_PFX}mixtm
vpath %.gz ${TM_DIR_PFX} ${TM_DIR_PFX}mixtm


.DEFAULT_GOAL := help
.DELETE_ON_ERROR:
.SUFFIXES:
.SECONDARY:


########################################
# ALL
# Define all the work to be done.
.PHONY: all
all: SHELL=${GUARD_SHELL}
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
clean.word_alignment_models:  SHELL=${GUARD_SHELL}
clean.word_alignment_models:
	${RM} $(addsuffix .*, ${POSSIBLE_WORD_ALIGNMENT_MODELS})

.PHONY: word_alignment_models  $(addsuffix _model, ${POSSIBLE_WORD_ALIGNMENT_MODELS})
word_alignment_models:  $(addsuffix _model, ${POSSIBLE_WORD_ALIGNMENT_MODELS})


# All word alignment models depend on ibm1 word alignment models except, of
# course, for ibm1 word alignment models, and also ibm4 since we use external
# software to create it.
$(foreach m, $(filter-out ${IBM1_MODEL_PFX} ${IBM4_MODEL_PFX}, ${POSSIBLE_WORD_ALIGNMENT_MODELS}), \
   $(eval ${m}_model:  ${IBM1_MODEL_PFX}_model) \
)

# the meta target for word alignment model depends on word alignment model files.
# both forward and backward word alignment models require source and target corpora.
$(foreach m, $(call uc, $(filter-out ${IBM4_MODEL_PFX}, ${POSSIBLE_WORD_ALIGNMENT_MODELS})), \
	$(foreach c, ${ALL_TMS}, \
		$(eval \
			$(call lc, ${m})_model:  ${${m}_MODEL_PFX}.$c.${L2_GIVEN_L1X}  ${${m}_MODEL_PFX}.$c.${L1_GIVEN_L2X}) \
		$(eval \
			${${m}_MODEL_PFX}.$c.${L2_GIVEN_L1X}:  $c${L1X} $c${L2X}) \
		$(eval \
			${${m}_MODEL_PFX}.$c.${L1_GIVEN_L2X}:  $c${L1X} $c${L2X}) \
	) \
	$(eval \
	   ${${m}_MODEL_PFX}.${L1_GIVEN_L2X}: $(foreach c, ${ALL_TMS}, $c${L1X} $c${L2X})) \
	$(eval \
	   ${${m}_MODEL_PFX}.${L2_GIVEN_L1X}: $(foreach c, ${ALL_TMS}, $c${L1X} $c${L2X})) \
)
${IBM4_MODEL_PFX}_model:  $(foreach c, ${ALL_TMS}, ${IBM4_MODEL_PFX}.$c.${L2_GIVEN_L1X} ${IBM4_MODEL_PFX}.$c.${L1_GIVEN_L2X})

########################################
# EXAMPLE of the resulting code generated previously:
#ibm1_model: ${IBM1_MODEL_PFX}.${TRAIN_TM}.${L2_GIVEN_L1X}
#ibm1_model: ${IBM1_MODEL_PFX}.${TRAIN_TM}.${L1_GIVEN_L2X}
#
#${IBM1_MODEL_PFX}.${TRAIN_TM}.${L2_GIVEN_L1X}:  ${TRAIN_TM}${L1X} ${TRAIN_TM}${L2X}
#${IBM1_MODEL_PFX}.${TRAIN_TM}.${L1_GIVEN_L2X}:  ${TRAIN_TM}${L1X} ${TRAIN_TM}${L2X}



########################################
# ALIGNMENT FILES.

clean.content: clean.alignment_files

.PHONY: clean.alignment_files
clean.alignment_files:  SHELL=${GUARD_SHELL}
clean.alignment_files:
	${RM} *.${L1_2_L2}.align.gz  *.${L2_2_L1}.align.gz

.PHONY: alignment_files  $(addsuffix _alignment, ${POSSIBLE_WORD_ALIGNMENT_MODELS})
alignment_files:  $(addsuffix _alignment, ${POSSIBLE_WORD_ALIGNMENT_MODELS})


$(foreach c, ${ALL_TMS}, \
	$(foreach m, $(call uc, $(filter-out ${IBM4_MODEL_PFX}, ${POSSIBLE_WORD_ALIGNMENT_MODELS})), \
		$(eval \
			$(call lc, $m)_alignment:  $c.${${m}_MODEL_PFX}.${L1_2_L2}.align.gz) \
		$(eval \
			$c.${${m}_MODEL_PFX}.${L1_2_L2}.align.gz:  $c${L1X} $c${L2X}) \
		$(eval \
			$c.${${m}_MODEL_PFX}.${L1_2_L2}.align.gz:  ${${m}_MODEL_PFX}.$c.${L2_GIVEN_L1X}  ${${m}_MODEL_PFX}.$c.${L1_GIVEN_L2X}) \
	) \
	$(eval \
		ibm4_alignment:  $c.${IBM4_MODEL_PFX}.${L1_2_L2}.align.gz) \
	$(eval \
		$c.${IBM4_MODEL_PFX}.${L1_2_L2}.align.gz:  $c/${SRC_LANG}.lc $c/${TGT_LANG}.lc) \
	$(eval \
		$c.${IBM4_MODEL_PFX}.${L1_2_L2}.align.gz:  $c/${L1_2_L2}.${IBM4_MODEL_PFX}.alignment.gz $c/${L2_2_L1}.${IBM4_MODEL_PFX}.alignment.gz) \
)

#${TRAIN_TM}.${IBM2_MODEL_PFX}.${L1_2_L2}.align.gz:  ${IBM2_MODEL_PFX}.${TRAIN_TM}.${L2_GIVEN_L1X}  ${IBM2_MODEL_PFX}.${TRAIN_TM}.${L1_GIVEN_L2X}
#${TRAIN_TM}.${IBM2_MODEL_PFX}.${L1_2_L2}.align.gz:  ${TRAIN_TM}${L1X} ${TRAIN_TM}${L2X}



################################################################################
# JOINT PHRASE TABLES

clean.content: clean.jpts

.PHONY: clean.jpts
clean.jpts: SHELL=${GUARD_SHELL}
clean.jpts:
	$(RM) ${JPT_MODEL_PFX}.*
	${RM} -r JPTPAR*

.PHONY: jpts  $(addsuffix _jpt, ${POSSIBLE_WORD_ALIGNMENT_MODELS})
jpts: SHELL=${GUARD_SHELL}
jpts: $(addsuffix _jpt, ${POSSIBLE_WORD_ALIGNMENT_MODELS})

# Definition of the generated makefile rules/targets:
# the meta target jpt have meta-dependency on a word alignment model,
# the meta target jpt have a dependency on jpt file.
# Defining a variable to hold the jpt file's prefix.
# jpts requires the word alignment models in both directions.
# jpts requires the source and target corpora.
$(foreach c, ${ALL_TMS}, \
	$(foreach m, $(call uc, $(filter-out ${IBM4_MODEL_PFX}, ${POSSIBLE_WORD_ALIGNMENT_MODELS})), \
		$(eval \
			JPT_${m}_MODEL_PFX ?= ${JPT_MODEL_PFX}.${${m}_MODEL_PFX}) \
		$(eval \
			$(call lc, ${m})_jpt:  $(call lc, ${m})_model) \
		$(eval \
			$(call lc, ${m})_jpt:  ${JPT_${m}_MODEL_PFX}.$c.${JOINTX}) \
		$(eval \
			${JPT_${m}_MODEL_PFX}.$c.${JOINTX}:  ${${m}_MODEL_PFX}.$c.${L2_GIVEN_L1X} ${${m}_MODEL_PFX}.$c.${L1_GIVEN_L2X}) \
		$(eval \
			${JPT_${m}_MODEL_PFX}.$c.${JOINTX}:  $c.${${m}_MODEL_PFX}.${L1_2_L2}.align.gz) \
		$(eval \
			${JPT_${m}_MODEL_PFX}.$c.${JOINTX}:  $c${L1X} $c${L2X}) \
	) \
)

JPT_IBM4_MODEL_PFX ?= ${JPT_MODEL_PFX}.${IBM4_MODEL_PFX}
${JPT_IBM4_MODEL_PFX}.%.${JOINTX}:  override L1X = ${SRC_LANG}.lc
${JPT_IBM4_MODEL_PFX}.%.${JOINTX}:  override L2X = ${TGT_LANG}.lc
$(foreach c, ${ALL_TMS}, \
	$(eval \
		ibm4_jpt:  ${JPT_IBM4_MODEL_PFX}.$c.${JOINTX}) \
	$(eval \
		${JPT_IBM4_MODEL_PFX}.$c.${JOINTX}:  ${IBM4_MODEL_PFX}.$c.${L2_GIVEN_L1X}  ${IBM4_MODEL_PFX}.$c.${L1_GIVEN_L2X}) \
	$(eval \
		${JPT_IBM4_MODEL_PFX}.$c.${JOINTX}:  $c.${IBM4_MODEL_PFX}.${L1_2_L2}.align.gz) \
	$(eval \
		${JPT_IBM4_MODEL_PFX}.$c.${JOINTX}:  $c/${SRC_LANG}.lc $c/${TGT_LANG}.lc) \
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
sigs: SHELL=${GUARD_SHELL}
sigs: $(addsuffix _sig, ${POSSIBLE_WORD_ALIGNMENT_MODELS})

# To create a sigpruned jpt we need an original jpt.
# To create a sigpruned jpt we need the source and target corpora.
# source language to target language
# m stands for model type
$(foreach c, ${ALL_TMS}, \
	$(foreach m, $(call uc, $(filter-out ${IBM4_MODEL_PFX}, ${POSSIBLE_WORD_ALIGNMENT_MODELS})), \
		$(eval \
			$(call lc, ${m})_sig: $(call lc, ${m})_jpt) \
		$(eval \
			$(call lc, ${m})_sig: ${SIG_${m}_MODEL_PFX}.$c.${JOINTX}) \
		$(eval \
			${SIG_${m}_MODEL_PFX}.$c.${JOINTX}:  ${JPT_${m}_MODEL_PFX}.$c.${JOINTX}) \
		$(eval \
			${SIG_${m}_MODEL_PFX}.$c.${JOINTX}:  $c${L1X} $c${L2X}) \
		$(eval \
			${SIG_${m}_MODEL_PFX}.$c.${RJOINTX}:  ${JPT_${m}_MODEL_PFX}.$c.${RJOINTX}) \
		$(eval \
			${SIG_${m}_MODEL_PFX}.$c.${RJOINTX}:  $c${L1X} $c${L2X}) \
	) \
)


# IBM4 sigpruning
${IBM4_MODEL_PFX}_sig: ${IBM4_MODEL_PFX}_jpt
${SIG_IBM4_MODEL_PFX}.%.${JOINTX}:  override L1X = ${SRC_LANG}.lc
${SIG_IBM4_MODEL_PFX}.%.${JOINTX}:  override L2X = ${TGT_LANG}.lc
$(foreach c, ${ALL_TMS}, \
	$(eval \
		${IBM4_MODEL_PFX}_sig: ${SIG_IBM4_MODEL_PFX}.$c.${JOINTX}) \
	$(eval \
		${SIG_IBM4_MODEL_PFX}.$c.${JOINTX}:  ${JPT_IBM4_MODEL_PFX}.$c.${JOINTX}) \
	$(eval \
		${SIG_IBM4_MODEL_PFX}.$c.${JOINTX}:  $c/${SRC_LANG}.lc $c/${TGT_LANG}.lc) \
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

.PHONY: cpts  $(addsuffix _cpt, ${POSSIBLE_WORD_ALIGNMENT_MODELS} merged)
cpts: SHELL=${GUARD_SHELL}
cpts: jpts
cpts: ibm2_cpt
cpts: hmm1_cpt
cpts: hmm2_cpt
cpts: hmm3_cpt
cpts: merged_cpt
cpts: ibm4_cpt


# Let's define a couple of variables.
IBM1_SMOOTHERS_DESCRIPTION ?= ${SMOOTHERS_DESCRIPTION}
IBM1_CPT_PREFIX ?= ${CPT_MODEL_PFX}.${IBM1_MODEL_PFX}${IBM1_SMOOTHERS_DESCRIPTION}

IBM2_SMOOTHERS_DESCRIPTION ?= ${SMOOTHERS_DESCRIPTION}
IBM2_CPT_PREFIX ?= ${CPT_MODEL_PFX}.${IBM2_MODEL_PFX}${IBM2_SMOOTHERS_DESCRIPTION}

HMM1_SMOOTHERS_DESCRIPTION ?= ${SMOOTHERS_DESCRIPTION}
HMM1_CPT_PREFIX ?= ${CPT_MODEL_PFX}.${HMM1_MODEL_PFX}${HMM1_SMOOTHERS_DESCRIPTION}

HMM2_SMOOTHERS_DESCRIPTION ?= ${SMOOTHERS_DESCRIPTION}
HMM2_CPT_PREFIX ?= ${CPT_MODEL_PFX}.${HMM2_MODEL_PFX}${HMM2_SMOOTHERS_DESCRIPTION}

HMM3_SMOOTHERS_DESCRIPTION ?= ${SMOOTHERS_DESCRIPTION}
HMM3_CPT_PREFIX ?= ${CPT_MODEL_PFX}.${HMM3_MODEL_PFX}${HMM3_SMOOTHERS_DESCRIPTION}

IBM4_SMOOTHERS_DESCRIPTION ?= ${SMOOTHERS_DESCRIPTION}
IBM4_CPT_PREFIX ?= ${CPT_MODEL_PFX}.${IBM4_MODEL_PFX}${IBM4_SMOOTHERS_DESCRIPTION}

# Create a variable to hold the conditional phrase table file's name e.i. hmm1_cpt_list.
# Create meta-level dependencies between cpts and their jpts or sigs.
# Create a meta-level target to generate cpts.
$(foreach c, ${ALL_TMS}, \
	$(foreach m, ${POSSIBLE_WORD_ALIGNMENT_MODELS}, \
		$(eval \
			${m}_cpt_list = ${$(call uc, ${m})_CPT_PREFIX}.$c.${L1_2_L2X}) \
		$(eval \
			${m}_cpt: ${m}_$(call lc, ${CPT_DEP_TAG})) \
		$(eval \
			${m}_cpt: ${${m}_cpt_list}) \
	) \
)

# Let's have a target to print out the variables that contain the conditional phrase table file's name.
%_cpt_list: SHELL=${GUARD_SHELL}
%_cpt_list: ; @echo ${$@}

# Creates dependencies for reversed Conditional Phrase Tables.
# Conditional Phrase Tables depend on a word alignment model for Zens-Ney's smoother.
# Conditional Phrase Tables depend on a joint frequency phrase table which can be raw or significance pruned (CPT_DEP_TAG).
$(foreach c, ${ALL_TMS}, \
	$(foreach m, $(call uc, ${POSSIBLE_WORD_ALIGNMENT_MODELS}), \
		$(eval \
			${${m}_CPT_PREFIX}.$c.${L2_2_L1X}:  ${${m}_MODEL_PFX}.$c.${L2_GIVEN_L1X} ${${m}_MODEL_PFX}.$c.${L1_GIVEN_L2X}) \
		$(eval \
			${${m}_CPT_PREFIX}.$c.${L2_2_L1X}:  ${${CPT_DEP_TAG}_${m}_MODEL_PFX}.$c.${RJOINTX}) \
	) \
)

# Creates dependencies for Conditional Phrase Tables.
# Conditional Phrase Tables depend on a word alignment model for Zens-Ney's smoother.
# Conditional Phrase Tables depend on a jpt which can be raw or significance pruned (CPT_DEP_TAG).
# NOTE: CPT_DEP_TAG is either JPT or SIG
$(foreach c, ${ALL_TMS}, \
	$(foreach m, $(call uc, ${POSSIBLE_WORD_ALIGNMENT_MODELS}), \
		$(eval \
			${${m}_CPT_PREFIX}.$c.${L1_2_L2X}:  ${${m}_MODEL_PFX}.$c.${L2_GIVEN_L1X} ${${m}_MODEL_PFX}.$c.${L1_GIVEN_L2X}) \
		$(eval \
			${${m}_CPT_PREFIX}.$c.${L1_2_L2X}:  ${${CPT_DEP_TAG}_${m}_MODEL_PFX}.$c.${JOINTX}) \
	) \
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
MERGED_CPT_SMOOTHERS_DESCRIPTION ?= ${SMOOTHERS_DESCRIPTION}
MERGED_CPT_PREFIX ?= ${CPT_MODEL_PFX}.merged.${${MERGED_CPT_ZN_MODEL}_MODEL_PFX}${MERGED_CPT_SMOOTHERS_DESCRIPTION}
MERGED_CPT_ZN_MODEL ?= HMM3
MERGED_CPT_JPT_TYPES ?= IBM2 HMM3

# We need to specify what's the type of the models for Zen-Ney's smoother.
${CPT_MODEL_PFX}.merged.${IBM1_MODEL_PFX}%:  WORD_MODEL_TYPE=-ibm 1
${CPT_MODEL_PFX}.merged.${IBM2_MODEL_PFX}%:  WORD_MODEL_TYPE=-ibm 2
${CPT_MODEL_PFX}.merged.hmm%:  WORD_MODEL_TYPE=-hmm
${CPT_MODEL_PFX}.merged.${IBM4_MODEL_PFX}%:  WORD_MODEL_TYPE=-ibm 1

# Let's define what are the merged cpt file names.
merged_cpt_list = $(foreach c, ${TRAIN_TM}, ${MERGED_CPT_PREFIX}.$c.${L1_2_L2X})

# Meta target that will create the merged conditional phrase tables.
merged_cpt: ${merged_cpt_list}

SIG_MERGED_PFX := ${SIG_MODEL_PFX}.merged
JPT_MERGED_PFX := ${JPT_MODEL_PFX}.merged


# Merged conditional phrase tables depends on a word model alignment for Zens-Ney's smoother.
# Merged conditional phrase tables depends on either a merged jpt (normal scenario) or a merged sig (when using significance pruning).
$(foreach c, ${ALL_TMS}, \
	$(eval \
		${MERGED_CPT_PREFIX}.$c.${L2_2_L1X}:  ${${MERGED_CPT_ZN_MODEL}_MODEL_PFX}.$c.${L2_GIVEN_L1X} ${${MERGED_CPT_ZN_MODEL}_MODEL_PFX}.$c.${L1_GIVEN_L2X}) \
	$(eval \
		${MERGED_CPT_PREFIX}.$c.${L2_2_L1X}:  ${${CPT_DEP_TAG}_MERGED_PFX}.$c.${RJOINTX}) \
	$(eval \
		${MERGED_CPT_PREFIX}.$c.${L1_2_L2X}:  ${${MERGED_CPT_ZN_MODEL}_MODEL_PFX}.$c.${L2_GIVEN_L1X} ${${MERGED_CPT_ZN_MODEL}_MODEL_PFX}.$c.${L1_GIVEN_L2X}) \
	$(eval \
		${MERGED_CPT_PREFIX}.$c.${L1_2_L2X}:  ${${CPT_DEP_TAG}_MERGED_PFX}.$c.${JOINTX}) \
)


# A merged jpt depends on user define type of joint frequency count file.
.INTERMEDIATE: $(foreach c, ${ALL_TMS}, ${JPT_MERGED_PFX}.$c.${RJOINTX} ${JPT_MERGED_PFX}.$c.${JOINTX})
$(foreach c, ${ALL_TMS}, \
	$(eval \
		${JPT_MERGED_PFX}.$c.${RJOINTX}:  $(foreach j, ${MERGED_CPT_JPT_TYPES}, ${JPT_${j}_MODEL_PFX}.$c.${RJOINTX})) \
	$(eval \
		${JPT_MERGED_PFX}.$c.${JOINTX}:   $(foreach j, ${MERGED_CPT_JPT_TYPES}, ${JPT_${j}_MODEL_PFX}.$c.${JOINTX})) \
)


# Significance pruning model depends on a "raw" joint frequency count file.
# Significance pruning model depends on the source and target corpora.
$(foreach c, ${ALL_TMS}, \
	$(eval \
		${SIG_MERGED_PFX}.$c.${RJOINTX}:  ${JPT_MERGED_PFX}.$c.${RJOINTX}) \
	$(eval \
		${SIG_MERGED_PFX}.$c.${RJOINTX}:  $c${L1X} $c${L2X}) \
	$(eval \
		${SIG_MERGED_PFX}.$c.${JOINTX}:  ${JPT_MERGED_PFX}.$c.${JOINTX}) \
	$(eval \
		${SIG_MERGED_PFX}.$c.${JOINTX}:  $c${L1X} $c${L2X}) \
)


########################################
# MIXTURE CONDITIONAL PHRASE TABLE
# Linear combination of MERGED CONDITIONAL PHRASE TABLES
# requires: MERGED_CPT_JPT_TYPES to be properly defined.

clean.content: clean.mix

.PHONY: clean.mix
clean.mix: SHELL=${GUARD_SHELL}
clean.mix:
	$(RM) ${CPT_MIX_PFX}.*
	${RM} -r mixtm

.PHONY: mix_cpt

mix_cpt_list = ${CPT_MIX_PFX}.${L1_2_L2X}

MIXING_CPTS = $(foreach c, $(filter-out ${TRAIN_TM}, ${MIXTM}), ${MERGED_CPT_PREFIX}.$c.${L1_2_L2X})

# Meta target to create the mixture conditional phrase table in mixtm/.
mix_cpt: SHELL=${GUARD_SHELL}
mix_cpt:
	mkdir -p mixtm
	cd mixtm && ${MAKE} -f ../Makefile ${mix_cpt_list}
	ln -sf $(addprefix mixtm/, ${mix_cpt_list}) .

# Let's define which merged cpt files we need to mix and the dev jpt file we need
# for calculating the weights for the mix.
${CPT_MIX_PFX}.${L1_2_L2X}:  $(foreach c, ${MIXTM}, ${MERGED_CPT_PREFIX}.$c.${L1_2_L2X})
${CPT_MIX_PFX}.${L1_2_L2X}:  ${JPT_MERGED_PFX}.${TUNE_DECODE}.${JOINTX}

${CPT_MIX_PFX}.${L2_2_L1X}:  $(foreach c, ${MIXTM}, ${MERGED_CPT_PREFIX}.$c.${L2_2_L1X})
${CPT_MIX_PFX}.${L2_2_L1X}:  ${JPT_MERGED_PFX}.${TUNE_DECODE}.${JOINTX}

#%.${TUNE_DECODE}.${JOINTX}: M=7
#%.${TUNE_DECODE}.${JOINTX}: JPT_EXTRAS=-d 6
%.${TUNE_DECODE}.${JOINTX}: JPT_PARALLELISM_LEVEL=1
%.${TUNE_DECODE}.${JOINTX}: GEN_JPT_PARALLEL_OPTIONS=
%.${TUNE_DECODE}.${JOINTX}: override L1X = _${SRC_LANG}${LANGX}
%.${TUNE_DECODE}.${JOINTX}: override L2X = _${TGT_LANG}${LANGX}
${TUNE_DECODE}.%.align.gz: override L1X = _${SRC_LANG}${LANGX}
${TUNE_DECODE}.%.align.gz: override L2X = _${TGT_LANG}${LANGX}

TM ?= $(firstword ${MIXTM})

$(foreach j, ${MERGED_CPT_JPT_TYPES}, \
	$(eval \
		${JPT_MERGED_PFX}.${TUNE_DECODE}.${JOINTX}:  ${JPT_${j}_MODEL_PFX}.${TUNE_DECODE}.${JOINTX}) \
	$(eval \
		${JPT_${j}_MODEL_PFX}.${TUNE_DECODE}.${JOINTX}:  ${TUNE_DECODE}.${${j}_MODEL_PFX}.${L1_2_L2}.align.gz) \
	$(eval \
		${JPT_${j}_MODEL_PFX}.${TUNE_DECODE}.${JOINTX}:  ${TUNE_DECODE}${L1} ${TUNE_DECODE}${L2}) \
	$(eval \
		${TUNE_DECODE}.${${j}_MODEL_PFX}.${L1_2_L2}.align.gz:  ${${j}_MODEL_PFX}.${TM}.${L2_GIVEN_L1X} ${${j}_MODEL_PFX}.${TM}.${L1_GIVEN_L2X}) \
	$(eval \
		${TUNE_DECODE}.${${j}_MODEL_PFX}.${L1_2_L2}.align.gz:  ${TUNE_DECODE}${L1} ${TUNE_DECODE}${L2}) \
)


########################################
clean.content: clean.ibm4

.PHONY: clean.ibm4
clean.ibm4: SHELL=${GUARD_SHELL}
clean.ibm4:
	${RM} ${IBM4_MODEL_PFX}.*
	${RM} ${TRAIN_TM}



########################################
# Joint 2 multi cpt.
# Create JPT groups based on their word alignment type.
j2m/%: SHELL=${GUARD_SHELL}
j2m/%:  $(foreach c, ${ALL_TMS}, ${JPT_MODEL_PFX}.%.$c.${JOINTX})
	mkdir -p $@
	cd $@ && ln -s -f $(addprefix ../../,$+) .

j2mr/%: SHELL=${GUARD_SHELL}
j2mr/%:  $(foreach c, ${ALL_TMS}, ${JPT_MODEL_PFX}.%.$c.${RJOINTX})
	mkdir -p $@
	cd $@ && ln -s -f $(addprefix ../../,$+) .

INDICATOR_MODEL_PFX = ${CPT_INDICATOR_PFX}${PI_SMOOTHERS_DESCRIPTION}.${${MERGED_CPT_ZN_MODEL}_MODEL_PFX}
INDICATOR_WORD_ALIGNMENT_MODELS ?= $(foreach c,${MERGED_CPT_JPT_TYPES},${$c_MODEL_PFX})
#INDICATOR_WORD_ALIGNMENT_MODELS ?= ${IBM4_MODEL_PFX} ${HMM3_MODEL_PFX} ${IBM2_MODEL_PFX}

# We need to group JPTs, for this we create a directory called j2m containing the proper grouping of JPTs.
${INDICATOR_MODEL_PFX}.${L1_2_L2X}:  | $(addprefix j2m/,  ${INDICATOR_WORD_ALIGNMENT_MODELS})
${INDICATOR_MODEL_PFX}.${L2_2_L1X}:  | $(addprefix j2mr/, ${INDICATOR_WORD_ALIGNMENT_MODELS})

ifeq ($(words ${TRAIN_TM}), 1)
# Don't create a global word alignment model using all corpora pairs if there is only one pair.
# Don't duplicate work already been done.
${INDICATOR_MODEL_PFX}.${L1_2_L2X}:  ${${MERGED_CPT_ZN_MODEL}_MODEL_PFX}.${TRAIN_TM}.${L2_GIVEN_L1X}  ${${MERGED_CPT_ZN_MODEL}_MODEL_PFX}.${TRAIN_TM}.${L1_GIVEN_L2X}
${INDICATOR_MODEL_PFX}.${L2_2_L1X}:  ${${MERGED_CPT_ZN_MODEL}_MODEL_PFX}.${TRAIN_TM}.${L2_GIVEN_L1X}  ${${MERGED_CPT_ZN_MODEL}_MODEL_PFX}.${TRAIN_TM}.${L1_GIVEN_L2X}
else
${INDICATOR_MODEL_PFX}.${L1_2_L2X}:  ${${MERGED_CPT_ZN_MODEL}_MODEL_PFX}.${L2_GIVEN_L1X}  ${${MERGED_CPT_ZN_MODEL}_MODEL_PFX}.${L1_GIVEN_L2X}
${INDICATOR_MODEL_PFX}.${L2_2_L1X}:  ${${MERGED_CPT_ZN_MODEL}_MODEL_PFX}.${L2_GIVEN_L1X}  ${${MERGED_CPT_ZN_MODEL}_MODEL_PFX}.${L1_GIVEN_L2X}
endif

.PHONY: indicator_cpt
indicator_cpt:  ${INDICATOR_MODEL_PFX}.${L1_2_L2X}



########################################
# Let's do some validation when the user wants a merged_cpt.
ifeq ($(filter merged_cpt, ${PT_TYPES}),merged_cpt)
# Make sure there is only one MERGED_CPT_ZN_MODEL.
ifneq ($(words ${MERGED_CPT_ZN_MODEL}), 1)
$(error You must specify one and only one MERGED_CPT_ZN_MODEL!)
endif

# Make sure MERGED_CPT_ZN_MODEL is valid.
ifneq ($(filter-out IBM4 HMM3 HMM2 HMM1 IBM2 IBM1, ${MERGED_CPT_ZN_MODEL}),)
$(error MERGED_CPT_ZN_MODEL must be one of IBM4, HMM3, HMM2, HMM1, IBM2 or IBM1 instead of ${MERGED_CPT_ZN_MODEL})
endif

# Make sure MERGED_CPT_JPT_TYPES are valid.
ifneq ($(filter-out IBM4 HMM3 HMM2 HMM1 IBM2 IBM1, ${MERGED_CPT_JPT_TYPES}),)
$(error MERGED_CPT_JPT_TYPES must be one of IBM4, HMM3, HMM2, HMM1, IBM2 or IBM1 instead of ${MERGED_CPT_JPT_TYPES})
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
tppt portageLive: SHELL=${GUARD_SHELL}
tppt portageLive: ${tppt_list}




################################################################################
# The test target is designed to be a unittest.  Its purpose is not to run
# commands but rather validate that all variables are properly expanded and
# that the resulting dependencies are all correct.
.PHONY: testsuite
testsuite:  unittest1
testsuite:  unittest2
testsuite:  unittest3
testsuite:  unittest4
testsuite:  unittest5
testsuite:  unittest6
testsuite:  unittest7
testsuite:  unittest8
testsuite:  unittest9
testsuite:  unittest10
testsuite:  unittest11


# These unittests look for clues that make was able to generate all
# dependencies.  Does not execute commands nor build models.
UNITTEST0_EXPECTED_NUM := $(words ${POSSIBLE_WORD_ALIGNMENT_MODELS})
UNITTEST0_FILTER = egrep -o '($(call merge,|,$1))\b' | sort | uniq -c | sed -e 's/^ *//' | cut -f 1 -d ' ' | tr '\n' ' '
.PHONY: unittest0
unittest0: unittest_word_alignment_models
unittest0: unittest_alignment_files
unittest0: unittest_jpts
unittest0: unittest_sigs
unittest0: unittest_cpts
unittest0: unittest_merged_cpt
unittest0: unittest_mix_cpt
unittest0: unittest_indicator_cpt

# 10 cat.sh
# 2 mgiza
# 2 train_ibm
unittest_word_alignment_models:
	[[ "`${MAKE} -Bn word_alignment_models | $(call UNITTEST0_FILTER, cat.sh mgiza train_ibm)`" =~ "10 2 2" ]]

# 6 align-words
# 10 cat.sh
# 2 mgiza
unittest_alignment_files:  unittest_word_alignment_models
	[[ "`${MAKE} -Bn alignment_files | $(call UNITTEST0_FILTER, align-words cat.sh mgiza train_ibm)`" =~ "6 10 2" ]]

# 6 align-words
# 10 cat.sh
# 6 gen-jpt-parallel.sh
# 2 mgiza
unittest_jpts:  unittest_alignment_files
	[[ "`${MAKE} -Bn jpts | $(call UNITTEST0_FILTER, align-words cat.sh gen-jpt-parallel.sh mgiza)`" =~ "6 10 6 2" ]]

# 6 align-words
# 10 cat.sh
# 6 gen-jpt-parallel.sh
# 2 mgiza
# 6 sigprune.sh
unittest_sigs:  unittest_jpts
	[[ "`${MAKE} -Bn sigs | $(call UNITTEST0_FILTER, align-words cat.sh gen-jpt-parallel.sh mgiza sigprune.sh)`" =~ "6 10 6 2 6" ]]

# 6 align-words
# 10 cat.sh
# 6 gen-jpt-parallel.sh
# 6 joint2cond_phrase_tables
# 2 mgiza
unittest_cpts:  unittest_jpts
	[[ "`${MAKE} -Bn cpts | $(call UNITTEST0_FILTER, align-words cat.sh gen-jpt-parallel.sh joint2cond_phrase_tables mgiza)`" =~ "6 10 6 6 2" ]]

# 2 align-words
# 6 cat.sh
# 2 gen-jpt-parallel.sh
# 1 joint2cond_phrase_tables
unittest_merged_cpt:  export MERGED_CPT_ZN_MODEL = HMM3
unittest_merged_cpt:  export MERGED_CPT_JPT_TYPES = IBM2 HMM3
unittest_merged_cpt:  unittest_jpts
	[[ "`${MAKE} -Bn merged_cpt | $(call UNITTEST0_FILTER, align-words cat.sh gen-jpt-parallel.sh joint2cond_phrase_tables)`" =~ "2 6 2 1" ]]

# 2 align-words
# 6 cat.sh
# 2 gen-jpt-parallel.sh
# 1 merge_counts
# 1 train_tm_mixture
unittest_mix_cpt:  unittest_jpts
	[[ "`${MAKE} -Bn mix_cpt | $(call UNITTEST0_FILTER, align-words cat.sh gen-jpt-parallel.sh merge_counts train_tm_mixture)`" =~ "2 6 2 1 1" ]]

# 3 align-words
# 6 cat.sh
# 3 gen-jpt-parallel.sh
# 1 joint2multi_cpt
# 3 ln
# 2 mgiza
unittest_indicator_cpt:  export INDICATOR_WORD_ALIGNMENT_MODELS = ${IBM4_MODEL_PFX} ${HMM3_MODEL_PFX} ${IBM2_MODEL_PFX}
unittest_indicator_cpt:  unittest_jpts
	[[ "`${MAKE} -Bn indicator_cpt | $(call UNITTEST0_FILTER, gen-jpt-parallel.sh joint2multi_cpt cat.sh align-words mgiza ln)`" =~ "3 6 3 1 3 2" ]]



# Verify that make is capable of generating all required targets for merged_cpt and some other cpt.
.PHONY: unittest1
unittest1: SHELL=${GUARD_SHELL}
unittest1:
	make -Bnj1 tppt PT_TYPES='ibm2_cpt hmm3_cpt merged_cpt' MERGED_CPT_JPT_TYPES='IBM2 HMM1 HMM3 HMM2 IBM1' MERGED_CPT_ZN_MODEL=IBM1

# Verify that make is capable of generating all required target for one cpt that has been significance pruned.
.PHONY: unittest2
unittest2: SHELL=${GUARD_SHELL}
unittest2:
	make -Bnj1 USE_SIGPRUNING=1 SIG_OPTS="-keep -sigopts '-par-driver fork'" ibm2_cpt

# Verify that make is capable of generating all required target for a merged cpt that has been significance pruned.
.PHONY: unittest3
unittest3: SHELL=${GUARD_SHELL}
unittest3:
	make -Bnj1 USE_SIGPRUNING=1 SIG_OPTS="-keep -sigopts '-par-driver fork'" merged_cpt


$(foreach a, a b, $(eval %.$a: ;echo $$@ $$*))


# UNITTEST for ZN-ADAPT.
.PHONY: unittest4 zn-adapt
unittest4:  zn-adapt
zn-adapt: export domain_files = tm-train_en.lc.gz tm-train_fr.lc.gz
zn-adapt: export other_files = sublm1_en.lc.gz sublm1_fr.lc.gz sublm2_en.lc.gz sublm2_fr.lc.gz sublm3_en.lc.gz sublm3_fr.lc.gz
zn-adapt:
	${MAKE} -f Makefile.zn-adapt all


# UNITTEST for Significance Pruning.
.PHONY: unittest5 sigprune
unittest5:  sigprune
sigprune:  export USE_SIGPRUNING = 1
sigprune:
	${MAKE} clean.cpts
	${MAKE} all
	[[ "`find -name sig.\*.merged.tm-train.\*.gz -size +21c | \wc -l`" -eq 1 ]] \
	|| ! echo "ERROR: Seems that no sig counts were produced." >&2


# Create a significance pruned conditional phrase table from IBM4 joint
# counts.
.PHONY: unittest6
unittest6:  export USE_SIGPRUNING = 1
unittest6:
	${MAKE} ibm4_cpt
	@[[ "`find -name ibm4.tm-train.\*_given_\*.gz -size +21c | \wc -l`" -eq 2 ]] \
	|| ! echo "ERROR: Can't find word alignment files for ibm4." >&2
	@[[ "`find -name jpt.ibm4.tm-train.en-fr.gz -size +21c | \wc -l`" -eq 1 ]] \
	|| ! echo "ERROR: can't find a jpt for ibm4." >&2
	@[[ "`find -name cpt.ibm4-kn3-zn.tm-train.en2fr.gz -size +21c | \wc -l`" -eq 1 ]] \
	|| ! echo "ERROR: can't find a jpt for ibm4." >&2


# Create a significance pruned conditional phrase table built with a lexical
# smoother based on ibm4 with joint frequency counts tallied from IBM2, HMM3 &
# IBM4.
.PHONY: unittest7
unittest7:  export USE_SIGPRUNING = 1
unittest7:  export MERGED_CPT_ZN_MODEL = IBM4
unittest7:  export MERGED_CPT_JPT_TYPES = IBM2 HMM3 IBM4
unittest7:
	${MAKE} clean.cpts  clean.sig
	${RM} ${JPT_MERGED_PFX}*
	${MAKE} merged_cpt
	@[[ "`find -name cpt.merged.ibm4-kn3-zn.tm-train.en2fr.gz -size +21c | \wc -l`" -eq 1 ]] \
	|| ! echo "ERROR: can't find conditional phrase table for ibm4." >&2


# Create multiple TMs.
.PHONY: unittest8 multiple_TMs
unittest8:  multiple_TMs
multiple_TMs:  export TRAIN_TM = sublm1 sublm2 sublm3
multiple_TMs:
	${MAKE} all


# Indicator Feature from one corpus.
.PHONY: unittest9 indicator1
unittest9:  indicator1
indicator1:  export INDICATOR_WORD_ALIGNMENT_MODELS = ${IBM4_MODEL_PFX} ${HMM3_MODEL_PFX} ${IBM2_MODEL_PFX}
indicator1:
	${RM} ${INDICATOR_MODEL_PFX}.${L1_2_L2X}
	${MAKE} indicator_cpt
	@[[ "`find -name ${INDICATOR_MODEL_PFX}.${L1_2_L2X} -size +21c | \wc -l`" -eq 1 ]] \
	|| ! echo "ERROR: can't find cpt with indicator_cpt" >&2
	@zcat ${INDICATOR_MODEL_PFX}.${L1_2_L2X} | grep -Em1 '( (1|0\.3)){3}$$' --quiet \
	|| ! echo "ERROR: Looks like there are no indicator_cpt feature in your cpt." >&2

# Inidcator Feature using several corpora.
.PHONY: unittest10 indicator2
unittest10:  indicator2
indicator2:  export TRAIN_TM=tm-train sublm1 sublm2 sublm3
indicator2:  export INDICATOR_WORD_ALIGNMENT_MODELS = ${IBM4_MODEL_PFX} ${HMM3_MODEL_PFX} ${IBM2_MODEL_PFX}
indicator2:
	${RM} ${INDICATOR_MODEL_PFX}.${L1_2_L2X}
	${MAKE} indicator_cpt
	@[[ "`find -name ${${MERGED_CPT_ZN_MODEL}_MODEL_PFX}.${L2_GIVEN_L1X} -size +21c | \wc -l`" -eq 1 ]] \
	|| ! echo "ERROR: Can't find global word alignment model." >&2
	@[[ "`find -name ${INDICATOR_MODEL_PFX}.${L1_2_L2X} -size +21c | \wc -l`" -eq 1 ]] \
	|| ! echo "ERROR: can't find cpt with indicator_cpt" >&2
	@zcat ${INDICATOR_MODEL_PFX}.${L1_2_L2X} | grep -Em1 '( (1|0\.3)){3}$$' --quiet \
	|| ! echo "ERROR: Looks like there are no indicator_cpt feature in your cpt." >&2


# MIXTURE TRANSLATION MODEL
.PHONY: unittest11 mixture
unittest11:  mixture
mixture:  export MIXTM = sublm1 sublm2 sublm3
mixture:
	${MAKE} mix_cpt
	@[[ "`find -name cpt.mix.en2fr.gz -size +21c -type l | \wc -l`" -eq 1 ]] \
	|| ! echo "ERROR: Can't find the mixture translation model." >&2

