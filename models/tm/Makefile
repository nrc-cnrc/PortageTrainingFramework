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

# We need a dev set for tuning the mixture weights in a mixtm.
#TUNE_MIXTM ?= ${TUNE_DECODE}

# This script might produce directory and we want to easily remove them.
RM := rm -rf

# After this Makefile, the following targets/files are precious.
FILES_TO_BE_LOCKED = ibm* hmm* jpt* cpt*

# Global alignment symmetrization options.
ALIGNMENT_SYMMETRIZATION_OPTIONS ?= -a "IBMOchAligner 3"


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
all: SHELL=${LOCAL_SHELL}
all: pretrained_cpt ${PT_TYPES}



########################################
# HELP OPTIONS
.PHONY: help
help: SHELL=${LOCAL_SHELL}
help:
	@echo "Train translation models."
	@echo
	@echo "To train your models, type: make all"
	@echo
	@echo "The main targets in this Makefile are:"
	@cat $(firstword $(MAKEFILE_LIST)) | egrep '^.PHONY:' | sed 's#^.PHONY: #   #'



# What the user can expect from this module.
.PHONY: list_final_output
list_final_output: SHELL=${LOCAL_SHELL}
list_final_output: $(addsuffix _list,${PT_TYPES})
	@echo "are the expected final outputs."



########################################
# Clean up
.PHONY: clean clean.content clean.logs hide.logs
clean: SHELL=${LOCAL_SHELL}
clean: clean.content clean.logs

clean.content: SHELL=${LOCAL_SHELL}

clean.logs: SHELL=${LOCAL_SHELL}
clean.logs:
	${RM} run-parallel-log* log.* run-p.*
	${RM} -r .logs

# Hide logs from user's view into .logs
hide.logs: SHELL=${LOCAL_SHELL}
hide.logs: hide_logs_sub



########################################
# Resources Summary
.PHONY: time-mem
time-mem: SHELL=${LOCAL_SHELL}
time-mem: resource_summary_sub



################################################################################
# WORD ALIGNMENT MODELS.

clean.content: clean.word_alignment_models

.PHONY: clean.word_alignment_models
clean.word_alignment_models:  SHELL=${LOCAL_SHELL}
clean.word_alignment_models:
	${RM} $(addsuffix .*, ${POSSIBLE_WORD_ALIGNMENT_MODELS})

.PHONY: word_alignment_models  $(addsuffix _model, ${POSSIBLE_WORD_ALIGNMENT_MODELS})
word_alignment_models:  $(addsuffix _model, ${POSSIBLE_WORD_ALIGNMENT_MODELS})

# $(call which_wam,<wam-stem>)
# Returns 1wam or <wam-stem> depending on whether 1wam is appropriate.
# We only use 1wam for MIXTM corpora
which_wam = $(strip $(if ${MIXTM_USE_GLOBAL_WORD_ALIGNMENT_MODEL},\
                         $(if $(filter $1, ${MIXTM} {MIXTM_TRAIN_MIX}),1wam,$1),$1))

# All word alignment models depend on ibm1 word alignment models except, of
# course, for ibm1 word alignment models, and also ibm4 since we use external
# software to create it.
$(foreach m, $(filter-out ${IBM1_MODEL_PFX} ${IBM4_MODEL_PFX}, ${POSSIBLE_WORD_ALIGNMENT_MODELS}), \
   $(eval ${m}_model:  ${IBM1_MODEL_PFX}_model) \
)

# the meta target for word alignment model depends on word alignment model files.
# both forward and backward word alignment models require source and target corpora.
$(foreach m, $(call uc, $(filter-out ${IBM4_MODEL_PFX}, ${POSSIBLE_WORD_ALIGNMENT_MODELS})), \
	$(foreach c, $(filter-out 1wam, ${ALL_WAMS}), \
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
${IBM4_MODEL_PFX}_model:  $(foreach c, ${ALL_WAMS}, ${IBM4_MODEL_PFX}.$c.${L2_GIVEN_L1X} ${IBM4_MODEL_PFX}.$c.${L1_GIVEN_L2X})

# For 1wam we want only the MIXTM corpora.  We also deliberately exclude ibm4 models.
ifdef MIXTM_USE_GLOBAL_WORD_ALIGNMENT_MODEL
$(foreach m, $(call uc, $(filter-out ${IBM4_MODEL_PFX}, ${POSSIBLE_WORD_ALIGNMENT_MODELS})), \
	$(foreach c, ${MIXTM}, \
		$(eval \
			${${m}_MODEL_PFX}.1wam.${L1_GIVEN_L2X}: $c${L1X} $c${L2X}) \
		$(eval \
			${${m}_MODEL_PFX}.1wam.${L2_GIVEN_L1X}: $c${L1X} $c${L2X}) \
))
endif

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
clean.alignment_files:  SHELL=${LOCAL_SHELL}
clean.alignment_files:
	${RM} *.${L1_2_L2}.align.gz  *.${L2_2_L1}.align.gz

.PHONY: alignment_files  $(addsuffix _alignment, ${POSSIBLE_WORD_ALIGNMENT_MODELS})
alignment_files:  $(addsuffix _alignment, ${POSSIBLE_WORD_ALIGNMENT_MODELS})


$(foreach c, ${ALL_WAMS}, $(foreach w, $(call which_wam, $c), \
	$(foreach m, $(call uc, $(filter-out ${IBM4_MODEL_PFX}, ${POSSIBLE_WORD_ALIGNMENT_MODELS})), \
		$(eval \
			$(call lc, $m)_alignment:  $c.${${m}_MODEL_PFX}.${L1_2_L2}.align.gz) \
		$(eval \
			$c.${${m}_MODEL_PFX}.${L1_2_L2}.align.gz:  $c${L1X} $c${L2X}) \
		$(eval \
			$c.${${m}_MODEL_PFX}.${L1_2_L2}.align.gz:  ${${m}_MODEL_PFX}.$w.${L2_GIVEN_L1X}  ${${m}_MODEL_PFX}.$w.${L1_GIVEN_L2X}) \
	) \
))

$(foreach c, ${ALL_WAMS}, \
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
clean.jpts: SHELL=${LOCAL_SHELL}
clean.jpts:
	$(RM) ${JPT_MODEL_PFX}.*
	${RM} -r JPTPAR*

.PHONY: jpts  $(addsuffix _jpt, ${POSSIBLE_WORD_ALIGNMENT_MODELS})
jpts: SHELL=${LOCAL_SHELL}
jpts: $(addsuffix _jpt, ${POSSIBLE_WORD_ALIGNMENT_MODELS})

# Definition of the generated makefile rules/targets:
# the meta target jpt have meta-dependency on a word alignment model,
# the meta target jpt have a dependency on jpt file.
# Defining a variable to hold the jpt file's prefix.
# jpts requires the word alignment models in both directions.
# jpts requires the source and target corpora.
$(foreach c, ${ALL_TMS}, $(foreach w, $(call which_wam, $c), \
	$(foreach m, $(call uc, $(filter-out ${IBM4_MODEL_PFX}, ${POSSIBLE_WORD_ALIGNMENT_MODELS})), \
		$(eval \
			$(call lc, ${m})_jpt:  $(call lc, ${m})_model) \
		$(eval \
			$(call lc, ${m})_jpt:  ${JPT_${m}_MODEL_PFX}.$c.${JOINTX}) \
		$(eval \
			${JPT_${m}_MODEL_PFX}.$c.${JOINTX}:  ${${m}_MODEL_PFX}.$w.${L2_GIVEN_L1X} ${${m}_MODEL_PFX}.$w.${L1_GIVEN_L2X}) \
		$(eval \
			${JPT_${m}_MODEL_PFX}.$c.${JOINTX}:  $c.${${m}_MODEL_PFX}.${L1_2_L2}.align.gz) \
		$(eval \
			${JPT_${m}_MODEL_PFX}.$c.${JOINTX}:  $c${L1X} $c${L2X}) \
	) \
))

${JPT_IBM4_MODEL_PFX}.%.${JOINTX}:  override L1X = ${SRC_LANG}.lc
${JPT_IBM4_MODEL_PFX}.%.${JOINTX}:  override L2X = ${TGT_LANG}.lc
$(foreach c, ${ALL_TMS}, $(foreach w, $(call which_wam, $c), \
	$(eval \
		ibm4_jpt:  ${JPT_IBM4_MODEL_PFX}.$c.${JOINTX}) \
	$(eval \
		${JPT_IBM4_MODEL_PFX}.$c.${JOINTX}:  ${IBM4_MODEL_PFX}.$w.${L2_GIVEN_L1X}  ${IBM4_MODEL_PFX}.$w.${L1_GIVEN_L2X}) \
	$(eval \
		${JPT_IBM4_MODEL_PFX}.$c.${JOINTX}:  $c.${IBM4_MODEL_PFX}.${L1_2_L2}.align.gz) \
	$(eval \
		${JPT_IBM4_MODEL_PFX}.$c.${JOINTX}:  $c/${SRC_LANG}.lc $c/${TGT_LANG}.lc) \
))

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
clean.sig: SHELL=${LOCAL_SHELL}
clean.sig:
	$(RM) ${SIG_MODEL_PFX}.*  sig.cnts.${JPT_MODEL_PFX}.*
	${RM} -r JPTPAR*
	${RM} -r work_directory

.PHONY: sigs  $(addsuffix _sig, ${POSSIBLE_WORD_ALIGNMENT_MODELS})
sigs: SHELL=${LOCAL_SHELL}
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
clean.cpts: SHELL=${LOCAL_SHELL}
clean.cpts:
	$(RM) ${CPT_MODEL_PFX}.*

.PHONY: cpts  $(addsuffix _cpt, ${POSSIBLE_WORD_ALIGNMENT_MODELS})
cpts: SHELL=${LOCAL_SHELL}
cpts: jpts
cpts: ibm2_cpt
cpts: hmm1_cpt
cpts: hmm2_cpt
cpts: hmm3_cpt
cpts: ibm4_cpt
cpts: pretrained_cpt
cpts: merged_cpt
cpts: mix_cpt


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
%_cpt_list: SHELL=${LOCAL_SHELL}
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
#hmm2_cpt_list: SHELL=${LOCAL_SHELL}
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
# PRETRAINED CONDITIONAL PHRASE TABLES

clean.content: clean.pretrained

.PHONY: clean.pretrained
clean.pretrained: SHELL=${LOCAL_SHELL}
clean.pretrained:
	${RM} ${pretrained_cpt_list} .*.tstamp mixtm/.*.tstamp

# Trigger updating of the symbolic links to pre-trained models by deleting
# the hidden .tstamp files.
.PHONY: trigger.update.pretrained.links
trigger.update.pretrained.links: SHELL=${LOCAL_SHELL}
trigger.update.pretrained.links:
	${RM} .*.tstamp mixtm/.*.tstamp

pretrained_cpt_list = $(notdir ${TM_PRETRAINED_TMS})

# Target to create symbolic links to pre-trained conditional phrase tables.
.PHONY: pretrained_cpt
pretrained_cpt: $(foreach p, ${pretrained_cpt_list}, .$p.tstamp)

fix_path = $(strip $(if $(filter /, $(firstword $(subst /,/ ,$(1)))), $(1), $(addprefix ${TM_DIR_PFX}../../, $(1))))

pretrained_cpt_paths = $(foreach f, ${TM_PRETRAINED_TMS}, $(call fix_path, $f))

$(foreach f, ${pretrained_cpt_paths}, \
	$(eval \
		.$(notdir $f).tstamp:  $f) \
)

# The hidden .tstamp files exist to allow us to ensure that symbolic links
# to pre-trained models are recreated once and only once during the build.
$(foreach p, ${pretrained_cpt_list}, .$p.tstamp): SHELL=${LOCAL_SHELL}
$(foreach p, ${pretrained_cpt_list}, .$p.tstamp): .%.tstamp:
	@[[ ! -e $* ]] || [[ -L $* ]] || ! echo "ERROR: TM $* already exists as a normal file."
	@$(if $(filter-out cpt.%, $*),! echo "ERROR: Name of pre-trained TM file must start with cpt.: $<")
	ln -sf $< .
	[[ ! -d ${<:.gz=.tppt} ]] || ln -sf ${<:.gz=.tppt} .
	touch $@

${pretrained_cpt_paths}: SHELL=${LOCAL_SHELL}
${pretrained_cpt_paths}: %:
	@! echo "ERROR: Pre-trained TM file $@ does not exist."



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
.PHONY: merged_cpt
merged_cpt: ${merged_cpt_list}

SIG_MERGED_PFX := ${SIG_MODEL_PFX}.merged
JPT_MERGED_PFX := ${JPT_MODEL_PFX}.merged


# Merged conditional phrase tables depends on a word model alignment for Zens-Ney's smoother.
# Merged conditional phrase tables depends on either a merged jpt (normal scenario) or a merged sig (when using significance pruning).
$(foreach c, ${ALL_TMS}, $(foreach w, $(call which_wam, $c), \
	$(eval \
		${MERGED_CPT_PREFIX}.$c.${L2_2_L1X}:  ${${MERGED_CPT_ZN_MODEL}_MODEL_PFX}.$w.${L2_GIVEN_L1X} ${${MERGED_CPT_ZN_MODEL}_MODEL_PFX}.$w.${L1_GIVEN_L2X}) \
	$(eval \
		${MERGED_CPT_PREFIX}.$c.${L2_2_L1X}:  ${${CPT_DEP_TAG}_MERGED_PFX}.$c.${RJOINTX}) \
	$(eval \
		${MERGED_CPT_PREFIX}.$c.${L1_2_L2X}:  ${${MERGED_CPT_ZN_MODEL}_MODEL_PFX}.$w.${L2_GIVEN_L1X} ${${MERGED_CPT_ZN_MODEL}_MODEL_PFX}.$w.${L1_GIVEN_L2X}) \
	$(eval \
		${MERGED_CPT_PREFIX}.$c.${L1_2_L2X}:  ${${CPT_DEP_TAG}_MERGED_PFX}.$c.${JOINTX}) \
))


# A merged jpt depends on user define type of joint frequency count file.
.INTERMEDIATE: $(foreach c, ${ALL_TMS}, ${JPT_MERGED_PFX}.$c.${RJOINTX} ${JPT_MERGED_PFX}.$c.${JOINTX})
$(foreach c, ${ALL_TMS}, \
	$(foreach m, $(call uc, ${MERGED_CPT_JPT_TYPES}), \
		$(eval \
			${JPT_MERGED_PFX}.$c.${RJOINTX}:  ${JPT_${m}_MODEL_PFX}.$c.${RJOINTX}) \
		$(eval \
			${JPT_MERGED_PFX}.$c.${JOINTX}:  ${JPT_${m}_MODEL_PFX}.$c.${JOINTX}) \
		$(eval \
			${SIG_MERGED_PFX}.$c.${RJOINTX}:  ${SIG_${m}_MODEL_PFX}.$c.${RJOINTX}) \
		$(eval \
			${SIG_MERGED_PFX}.$c.${JOINTX}:  ${SIG_${m}_MODEL_PFX}.$c.${JOINTX}) \
))



########################################
# MIXTURE CONDITIONAL PHRASE TABLE
# Linear combination of MERGED CONDITIONAL PHRASE TABLES
# requires: MERGED_CPT_JPT_TYPES to be properly defined.

clean.content: clean.mix

.PHONY: clean.mix
clean.mix: SHELL=${LOCAL_SHELL}
clean.mix:
	$(RM) ${CPT_MIX_PFX}.*
	${RM} -r mixtm

mix_cpt_list = ${CPT_MIX_PFX}.${L1_2_L2X}

# Meta target to create the mixture conditional phrase table in mixtm/.
.PHONY: mix_cpt
mix_cpt: SHELL=${LOCAL_SHELL}
ifdef USE_MIXTM
mix_cpt:  | $(filter-out mix_cpt, ${PT_TYPES})
	mkdir -p mixtm
	cd mixtm && ${MAKE} -f ../Makefile pretrained_cpt TM_PRETRAINED_TMS="${MIXTM_PRETRAINED_TMS}"
	cd mixtm && ${MAKE} -f ../Makefile ${mix_cpt_list}
	ln -sf $(addprefix mixtm/, ${mix_cpt_list}) .

# Let's define which merged cpt files we need to mix and the dev jpt file we need
# for calculating the weights for the mix.
MIX_OTHER_CPTS := $(foreach c, $(addsuffix _list, $(filter-out mix_cpt,${PT_TYPES})), ${$c})
${CPT_MIX_PFX}.${L1_2_L2X}:  | ${MIX_OTHER_CPTS}
${CPT_MIX_PFX}.${L1_2_L2X}:  $(foreach c, ${MIXTM}, ${MERGED_CPT_PREFIX}.$c.${L1_2_L2X}) \
                             $(foreach c, $(notdir ${MIXTM_PRETRAINED_TMS}), $c)
${CPT_MIX_PFX}.${L1_2_L2X}:  ${JPT_MERGED_PFX}.${TUNE_MIXTM_FINAL}.${JOINTX}

${CPT_MIX_PFX}.${L2_2_L1X}:  | ${MIX_OTHER_CPTS}
${CPT_MIX_PFX}.${L2_2_L1X}:  $(foreach c, ${MIXTM}, ${MERGED_CPT_PREFIX}.$c.${L2_2_L1X}) \
                             $(foreach c, $(notdir ${MIXTM_PRETRAINED_TMS}), $c)
${CPT_MIX_PFX}.${L2_2_L1X}:  ${JPT_MERGED_PFX}.${TUNE_MIXTM_FINAL}.${JOINTX}

%.${TUNE_MIXTM_FINAL}.${JOINTX}: JPT_PARALLELISM_LEVEL=1
%.${TUNE_MIXTM_FINAL}.${JOINTX}: GEN_JPT_PARALLEL_OPTIONS=
%.${TUNE_MIXTM_FINAL}.${JOINTX}: JPT_MODEL_TYPE=

$(foreach j, ${MERGED_CPT_JPT_TYPES}, \
	$(eval \
		${JPT_MERGED_PFX}.${TUNE_MIXTM_FINAL}.${JOINTX}:  ${JPT_${j}_MODEL_PFX}.${TUNE_MIXTM_FINAL}.${JOINTX}) \
	$(eval \
		${JPT_${j}_MODEL_PFX}.${TUNE_MIXTM_FINAL}.${JOINTX}:  ${TUNE_MIXTM_FINAL}.${${j}_MODEL_PFX}.${L1_2_L2}.align.gz) \
)

$(foreach j, $(filter-out IBM4, ${MERGED_CPT_JPT_TYPES}), $(foreach w, $(call which_wam, ${MIXTM_TRAIN_MIX}), \
	$(eval \
		${JPT_${j}_MODEL_PFX}.${TUNE_MIXTM_FINAL}.${JOINTX}:  ${TUNE_MIXTM_FINAL}${L1} ${TUNE_MIXTM_FINAL}${L2}) \
	$(eval \
		${TUNE_MIXTM_FINAL}.${${j}_MODEL_PFX}.${L1_2_L2}.align.gz:  ${${j}_MODEL_PFX}.$w.${L2_GIVEN_L1X} ${${j}_MODEL_PFX}.$w.${L1_GIVEN_L2X}) \
	$(eval \
		${TUNE_MIXTM_FINAL}.${${j}_MODEL_PFX}.${L1_2_L2}.align.gz:  ${TUNE_MIXTM_FINAL}${L1} ${TUNE_MIXTM_FINAL}${L2}) \
))

# FORCED ALIGNING tune mixtm with IBM4 models.
${JPT_IBM4_MODEL_PFX}.${TUNE_MIXTM_FINAL}.${JOINTX}:  ${TUNE_MIXTM_FINAL}/${SRC_LANG}.lc ${TUNE_MIXTM_FINAL}/${TGT_LANG}.lc
${TUNE_MIXTM_FINAL}.${IBM4_MODEL_PFX}.${L1_2_L2}.align.gz:  ${TUNE_MIXTM_FINAL}/${SRC_LANG}.lc ${TUNE_MIXTM_FINAL}/${TGT_LANG}.lc
${TUNE_MIXTM_FINAL}.${IBM4_MODEL_PFX}.${L1_2_L2}.align.gz:  ${TUNE_MIXTM_FINAL}/${L1_2_L2}.${IBM4_MODEL_PFX}.alignment.gz ${TUNE_MIXTM_FINAL}/${L2_2_L1}.${IBM4_MODEL_PFX}.alignment.gz

endif  # ifdef USE_MIXTM



########################################
clean.content: clean.ibm4

.PHONY: clean.ibm4
clean.ibm4: SHELL=${LOCAL_SHELL}
clean.ibm4:
	${RM} ${IBM4_MODEL_PFX}.*
	${RM} ${TRAIN_TM}



########################################
# INDICATOR FEATURE CONDITIONAL PHRASE TABLE
# Create JPT groups based on their word alignment type.
j2m/%: SHELL=${LOCAL_SHELL}
j2m/%:  $(foreach c, ${ALL_TMS}, ${${CPT_DEP_TAG}_MODEL_PFX}.%.$c.${JOINTX})
	mkdir -p $@
	cd $@ && for f in $+; do ln -fs ../../$$f ${JPT_MODEL_PFX}.$${f##${${CPT_DEP_TAG}_MODEL_PFX}.}; done

j2mr/%: SHELL=${LOCAL_SHELL}
j2mr/%:  $(foreach c, ${ALL_TMS}, ${${CPT_DEP_TAG}_MODEL_PFX}.%.$c.${RJOINTX})
	mkdir -p $@
	cd $@ && for f in $+; do ln -fs ../../$$f ${JPT_MODEL_PFX}.$${f##${${CPT_DEP_TAG}_MODEL_PFX}.}; done

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

# Let's define what are the indicator cpt file names.
indicator_cpt_list = ${INDICATOR_MODEL_PFX}.${L1_2_L2X}

.PHONY: indicator_cpt
indicator_cpt:  ${indicator_cpt_list}


clean.content: clean.indicator

.PHONY: clean.indicator
clean.indicator: SHELL=${LOCAL_SHELL}
clean.indicator:
	${RM} -r j2m j2mr



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
# PT_TYPES is what the user asked for so we need to change ibm2_cpt =>
# ibm2_cpt_list and evaluate its content which will be the text phrase table
# file name.  Then we only need to change the text file name to tightly packed
# file name.
tppt_list := $(addsuffix .tppt, $(basename $(foreach a, $(PT_TYPES:=_list) pretrained_cpt_list, ${$a})))

.PHONY: tppt
tppt portageLive: SHELL=${LOCAL_SHELL}
tppt portageLive: ${tppt_list}




# Add the unittest targets.
-include Makefile.unittests

