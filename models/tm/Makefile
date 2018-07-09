#!/usr/bin/make -f
# vim:noet:ts=3:nowrap

# @file Makefile
# @brief Dependencies to create Conditional Phrase Tables.
#
# @author Samuel Larkin
#
# Traitement multilingue de textes / Multilingual Text Processing
# Tech. de l'information et des communications / Information and Communications Tech.
# Conseil national de recherches Canada / National Research Council Canada
# Copyright 2008, 2012, 2015, Sa Majeste la Reine du Chef du Canada
# Copyright 2008, 2012, 2015, Her Majesty in Right of Canada

TM_DIR_PFX := $(dir $(lastword ${MAKEFILE_LIST}))
#$(info TM_DIR_PFX: ${TM_DIR_PFX})

# Variables we use from ../../Makefile.params:
# PT_TYPES indicates what type of phrase table we want to generate.

# Mandatory include: master config file.
include ${TM_DIR_PFX}../../Makefile.params

# Include and override parameters with user specific config file.
MAKEFILE_PARAMS ?= Makefile.params
-include ${TM_DIR_PFX}${MAKEFILE_PARAMS}

# Include the master toolkit.
include ${TM_DIR_PFX}../../Makefile.toolkit

# Include the toolkit for building Translation Models.
include ${TM_DIR_PFX}Makefile.toolkit

# What is this module's name.
MODULE_NAME ?= tm

# Where we can find the parallel corpora.
CORPORA_DIR ?= ${TM_DIR_PFX}../../corpora

# We need a dev set for tuning the mixture weights in a mixtm.
# TUNE_MIXTM is defined in the master Makefile.params.
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
vpath %${L1}  ${CORPORA_DIR}
vpath %${L2}  ${CORPORA_DIR}

# Where can we find the Word Alignment Models.
vpath  %${L1_GIVEN_L2X}  ${TM_DIR_PFX}../ibm/
vpath  %${L2_GIVEN_L1X}  ${TM_DIR_PFX}../ibm/

# Where can we find our Joint Phrase Tables.
vpath  jpt.%.${JOINTX}   ${TM_DIR_PFX}../jpt/
vpath  jpt.%.${RJOINTX}  ${TM_DIR_PFX}../jpt/

# Where can we find out Significance Pruned Joint Phrase Tables.
vpath  sig.%.${JOINTX}   ${TM_DIR_PFX}../sig/
vpath  sig.%.${RJOINTX}  ${TM_DIR_PFX}../sig/

# Where to look for built CPTs (cpts used for mixing are moved to mixtm).
vpath ${CPT_MODEL_PFX}%${L1_2_L2X}  ${TM_DIR_PFX}  ${TM_DIR_PFX}mixtm
vpath %.gz                          ${TM_DIR_PFX}  ${TM_DIR_PFX}mixtm


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

MAIN_TARGETS :=  all clean help

$(addsuffix _model, ${POSSIBLE_WORD_ALIGNMENT_MODELS} indicator mix merged pretrained):  %_model:  %_cpt
MODEL_TARGETS := $(sort $(addsuffix _model, ${POSSIBLE_WORD_ALIGNMENT_MODELS}))
MODEL_TARGETS += "\n " $(addsuffix _model, indicator mix merged pretrained)


########################################
# HELP OPTIONS
.PHONY: help
help: SHELL=${LOCAL_SHELL}
help:
	@echo "Train translation models."
	@echo
	@echo "To train the translation models, type: make all"
	${HELP_LIST_MAIN_TARGETS}
	@echo -e " " ${MODEL_TARGETS}
	${HELP_LIST_EXPECTED_FILES}


# What the user can expect from this module.
.PHONY: list_final_output
list_final_output: SHELL=${LOCAL_SHELL}
list_final_output:
	@echo "Expected final output(s):"
	@echo "${EXPECTED_FILES}"


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
	${RM} .Makefile*.deps

# Hide logs from user's view into .logs
hide.logs: SHELL=${LOCAL_SHELL}
hide.logs: hide_logs_sub


########################################
# Resources Summary
.PHONY: time-mem
time-mem: SHELL=${LOCAL_SHELL}
time-mem: resource_summary_sub

MAIN_TARGETS += time-mem


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
cpts:  SHELL=${LOCAL_SHELL}
cpts:  $(addsuffix _cpt, ibm2 hmm1 hmm2 hmm3 ibm4 pretrained merged mix indicator)

$(addsuffix _cpt, ibm2 hmm1 hmm2 hmm3 ibm4):  %_cpt:
	@true

define DEPS.PYSCRIPT
from __future__ import print_function

# Conditional Phrase Tables depend on a Word Alignment Model for Zens-Neys smoother.
# Conditional Phrase Tables depend on a Joint frequency Phrase Table which can be raw or significance pruned.
with open(".Makefile.cpt.deps", "w") as df:
   expectedFiles = set()

   # Write dependencies for how to create a cpt even for mix_cpt.
   wams = set("${POSSIBLE_WORD_ALIGNMENT_MODELS}".split())
   for corp in set("${ALL_TMS}".split()):
      for wam in wams:
         cptFileName = "${CPT_MODEL_PFX}.{m}${SMOOTHERS_DESCRIPTION}.{c}.${L1_2_L2X}".format(c=corp, m=wam)
         print("{cptFileName}:  {m}.{c}.${L2_GIVEN_L1X}  {m}.{c}.${L1_GIVEN_L2X}".format(c=corp, m=wam, cptFileName=cptFileName), file=df)
         print("{cptFileName}:  {j}.{m}.{c}.${JOINTX}".format(c=corp, m=wam, cptFileName=cptFileName, j="${${CPT_DEP_TAG}_MODEL_PFX}"), file=df)


   #############################################################################
   # META LEVEL TARGETS
   #####################################
   # { ibm1, ibm2, ibm4, hmm1, hmm2, hmm3, fast_align }_cpt
   wams = set("${POSSIBLE_WORD_ALIGNMENT_MODELS}".split())
   for corp in set("${TRAIN_TM}".split()):
      for wam in wams:
         filename = "${CPT_MODEL_PFX}.{m}${SMOOTHERS_DESCRIPTION}.{c}.${L1_2_L2X}".format(c=corp, m=wam)
         # Create meta-level dependencies between cpts and their jpts or sigs.
         print("{m}_cpt:  {filename}".format(m=wam, filename=filename), file=df)

   # Lets have a separate loop to build %_cpt_list, a list of cpt to convert to tppt.
   wams = set("$(filter ${PT_TYPES:_cpt=}, ${POSSIBLE_WORD_ALIGNMENT_MODELS})".split())
   for corp in set("${TRAIN_TM}".split()):
      for wam in wams:
         filename = "${CPT_MODEL_PFX}.{m}${SMOOTHERS_DESCRIPTION}.{c}.${L1_2_L2X}".format(c=corp, m=wam)
         print("{m}_cpt_list += {filename}".format(m=wam, filename=filename), file=df)
         expectedFiles.add(filename)

   print("EXPECTED_FILES :=", *sorted(expectedFiles), file=df)
endef

#$(info CPT: ${DEPS.PYSCRIPT})
$(shell python -c '${DEPS.PYSCRIPT}')
include .Makefile.cpt.deps


################################################################################
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
EXPECTED_FILES += ${pretrained_cpt_list}

# Target to create symbolic links to pre-trained conditional phrase tables.
.PHONY: pretrained_cpt
pretrained_cpt: $(foreach p, ${pretrained_cpt_list}, .$p.tstamp)

pretrained_cpt_paths = $(foreach f, ${TM_PRETRAINED_TMS}, $(call FIX_RELATIVE_PATH, ${TM_DIR_PFX}../.., $f))

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


################################################################################
# MERGED CONDITIONAL PHRASE TABLES
# requires: MERGED_CPT_ZN_MODEL & MERGED_CPT_JPT_TYPES to be properly defined.
MERGED_CPT_SMOOTHERS_DESCRIPTION ?= ${SMOOTHERS_DESCRIPTION}
MERGED_CPT_PREFIX ?= ${CPT_MODEL_PFX}.merged.${${MERGED_CPT_ZN_MODEL}_MODEL_PFX}${MERGED_CPT_SMOOTHERS_DESCRIPTION}
MERGED_CPT_ZN_MODEL ?= HMM3
MERGED_CPT_JPT_TYPES ?= IBM2 HMM3

# Let's define what are the merged cpt file names.
merged_cpt_list := $(foreach c, ${TRAIN_TM}, ${MERGED_CPT_PREFIX}.$c.${L1_2_L2X})
EXPECTED_FILES += $(if $(filter merged_cpt, ${PT_TYPES}), ${merged_cpt_list})

# Meta target that will create the merged conditional phrase tables.
.PHONY: merged_cpt
merged_cpt:  ${merged_cpt_list}


define DEPS.PYSCRIPT
from __future__ import print_function

mixWamCorpora = set("${TUNE_MIXTM_FINAL} ${MIXTM} ${MIXTM_TRAIN_MIX}".split())
def which_wam(c):
   if len("${MIXTM_USE_GLOBAL_WORD_ALIGNMENT_MODEL}") and c in mixWamCorpora:
      return "mixwam"
   return c

# Merged conditional phrase tables depends on a word model alignment for Zens-Neys smoother.
# Merged conditional phrase tables depends on either a merged jpt (normal scenario) or a merged sig (when using significance pruning).
# A merged jpt depends on user define type of joint frequency count file.
with open(".Makefile.merged_cpt.deps", "w") as df:
   for corp in set("${ALL_TMS}".split()):
      fileName = "${MERGED_CPT_PREFIX}.{c}.${L1_2_L2X}".format(c=corp)
      print("{fileName}:  {m}.{c}.${L2_GIVEN_L1X}  {m}.{c}.${L1_GIVEN_L2X}".format(m="${${MERGED_CPT_ZN_MODEL}_MODEL_PFX}", c=which_wam(corp), fileName=fileName), file=df)
      print("{fileName}:  {m}.{c}.${JOINTX}".format(m="${${CPT_DEP_TAG}_MERGED_PFX}", c=corp, fileName=fileName), file=df)
endef

#$(info MERGED CPT: ${DEPS.PYSCRIPT})
$(shell python -c '${DEPS.PYSCRIPT}')
include .Makefile.merged_cpt.deps


################################################################################
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
EXPECTED_FILES += $(if $(filter mix_cpt, ${PT_TYPES}), ${mix_cpt_list})

MIX_CPT_META_DEPS := $(filter-out mix_cpt, ${PT_TYPES})

# Meta target to create the mixture conditional phrase table in mixtm/.
.PHONY: mix_cpt
mix_cpt: SHELL=${LOCAL_SHELL}
mix_cpt:  | ${MIX_CPT_META_DEPS}
	mkdir --parents mixtm
	cd mixtm && ${MAKE} -f ../Makefile pretrained_cpt TM_PRETRAINED_TMS="${MIXTM_PRETRAINED_TMS}"
	cd mixtm && ${MAKE} -f ../Makefile ${mix_cpt_list}
	ln -sf $(addprefix mixtm/, ${mix_cpt_list}) .

# Let's define which merged cpt files we need to mix and the dev jpt file we need
# for calculating the weights for the mix.
MIX_OTHER_CPTS := $(foreach c, $(addsuffix _list, $(filter-out mix_cpt,${PT_TYPES})), ${$c})
#$(info MIX_OTHER_CPTS: ${MIX_OTHER_CPTS})

# Mixed Conditional Phrase Table
${CPT_MIX_PFX}.${L1_2_L2X}:  | ${MIX_CPT_META_DEPS}
${CPT_MIX_PFX}.${L1_2_L2X}:  $(foreach c, ${MIXTM}, ${MERGED_CPT_PREFIX}.$c.${L1_2_L2X}) \
                             $(foreach c, $(notdir ${MIXTM_PRETRAINED_TMS}), $c)
${CPT_MIX_PFX}.${L1_2_L2X}:  ${JPT_MERGED_PFX}.${TUNE_MIXTM_FINAL}.${JOINTX}

# Reversed Mixed Conditional Phrase Table
${CPT_MIX_PFX}.${L2_2_L1X}:  | ${MIX_CPT_META_DEPS}
${CPT_MIX_PFX}.${L2_2_L1X}:  $(foreach c, ${MIXTM}, ${MERGED_CPT_PREFIX}.$c.${L2_2_L1X}) \
                             $(foreach c, $(notdir ${MIXTM_PRETRAINED_TMS}), $c)
${CPT_MIX_PFX}.${L2_2_L1X}:  ${JPT_MERGED_PFX}.${TUNE_MIXTM_FINAL}.${JOINTX}


################################################################################
# INDICATOR FEATURE CONDITIONAL PHRASE TABLE
# Create JPT groups based on their word alignment type.
j2m j2mr:  SHELL=${LOCAL_SHELL}
j2m j2mr:
	mkdir --parents $@

j2m/%: SHELL=${LOCAL_SHELL}
j2m/%:  $(foreach c, ${ALL_TMS}, ${${CPT_DEP_TAG}_MODEL_PFX}.%.$c.${JOINTX})
	mkdir --parents $@
	cd $@ && for f in $+; do ln -fs ../../$$f `basename $${f/${${CPT_DEP_TAG}_MODEL_PFX}./${JPT_MODEL_PFX}.}`; done

j2mr/%: SHELL=${LOCAL_SHELL}
j2mr/%:  $(foreach c, ${ALL_TMS}, ${${CPT_DEP_TAG}_MODEL_PFX}.%.$c.${RJOINTX})
	mkdir --parents $@
	cd $@ && for f in $+; do ln -fs ../../$$f `basename $${f/${${CPT_DEP_TAG}_MODEL_PFX}./${JPT_MODEL_PFX}.}`; done

INDICATOR_MODEL_PFX = ${CPT_INDICATOR_PFX}${PI_SMOOTHERS_DESCRIPTION}.${${MERGED_CPT_ZN_MODEL}_MODEL_PFX}
INDICATOR_WORD_ALIGNMENT_MODELS ?= $(foreach c, ${MERGED_CPT_JPT_TYPES}, ${${c}_MODEL_PFX})
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
EXPECTED_FILES += $(if $(filter indicator_cpt, ${PT_TYPES}), ${indicator_cpt_list})

.PHONY: indicator_cpt
indicator_cpt:  ${indicator_cpt_list}


clean.content: clean.indicator

.PHONY: clean.indicator
clean.indicator: SHELL=${LOCAL_SHELL}
clean.indicator:
	${RM} -r j2m j2mr


################################################################################
# Let's do some validation when the user wants a merged_cpt.
ifeq ($(filter merged_cpt, ${PT_TYPES}),merged_cpt)
# Make sure there is only one MERGED_CPT_ZN_MODEL.
ifneq ($(words ${MERGED_CPT_ZN_MODEL}), 1)
$(error You must specify one and only one MERGED_CPT_ZN_MODEL!)
endif

# Make sure MERGED_CPT_ZN_MODEL is valid.
ifneq ($(filter-out FAST_ALIGN IBM4 HMM3 HMM2 HMM1 IBM2 IBM1, ${MERGED_CPT_ZN_MODEL}),)
$(error MERGED_CPT_ZN_MODEL must be one of IBM4, HMM3, HMM2, HMM1, IBM2 or IBM1 instead of ${MERGED_CPT_ZN_MODEL})
endif

# Make sure MERGED_CPT_JPT_TYPES are valid.
ifneq ($(filter-out FAST_ALIGN IBM4 HMM3 HMM2 HMM1 IBM2 IBM1, ${MERGED_CPT_JPT_TYPES}),)
$(error MERGED_CPT_JPT_TYPES must be one of IBM4, HMM3, HMM2, HMM1, IBM2 or IBM1 instead of ${MERGED_CPT_JPT_TYPES})
endif
endif


################################################################################
# HELPERS

# Let's have a target to print out the variables that contain the conditional phrase table file's name.
%_cpt_list: SHELL=${LOCAL_SHELL}
%_cpt_list: ; @echo ${$@}


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

MAIN_TARGETS += portageLive


# Add the unittest targets.
-include Makefile.unittests
