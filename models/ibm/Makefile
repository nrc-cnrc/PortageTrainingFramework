#!/usr/bin/make -f
# vim:noet:ts=3:nowrap:filetype=make

# @file Makefile
# @brief Dependencies to create Word Alignment Models.
#
# @author Samuel Larkin
#
# Traitement multilingue de textes / Multilingual Text Processing
# Tech. de l'information et des communications / Information and Communications Tech.
# Conseil national de recherches Canada / National Research Council Canada
# Copyright 2015, Sa Majeste la Reine du Chef du Canada
# Copyright 2015, Her Majesty in Right of Canada

IBM_DIR_PFX := $(dir $(lastword ${MAKEFILE_LIST}))

# Mandatory include: master config file.
include ${IBM_DIR_PFX}../../Makefile.params

# Include and override parameters with user specific config file.
MAKEFILE_PARAMS ?= Makefile.params
-include ${IBM_DIR_PFX}${MAKEFILE_PARAMS}

# Include the master toolkit.
include ${IBM_DIR_PFX}../../Makefile.toolkit

# Include the toolkit for building Phrase Alignment Models.
include ${IBM_DIR_PFX}Makefile.toolkit

# What is this module's name.
MODULE_NAME ?= ibm

# Where we can find the parallel corpora.
CORPORA_DIR ?= ${IBM_DIR_PFX}../../corpora

# This script might produce directory and we want to easily remove them.
RM := rm -rf

# After this Makefile, the following targets/files are precious.
FILES_TO_BE_LOCKED = ibm* hmm*

# Allows to search for alignment files in corpus.
vpath %${L1X} ${CORPORA_DIR}
vpath %${L2X} ${CORPORA_DIR}
vpath %${L1}  ${CORPORA_DIR}
vpath %${L2}  ${CORPORA_DIR}


.DEFAULT_GOAL := help
.DELETE_ON_ERROR:
.SUFFIXES:
.SECONDARY:


########################################
# ALL
# Define all the work to be done.
.PHONY: all
all:  SHELL=${LOCAL_SHELL}
all:  ${PT_TYPES:_cpt=_wam}
all:  $(and ${USE_LDM}, ldm_wam)
all:  $(and ${USE_HLDM}, hldm_wam)
all:  $(and ${USE_BILM}, bilm_wam)


########################################
# HELP OPTIONS
.PHONY: help
help: SHELL=${LOCAL_SHELL}
help:
	@echo "Train word alignment models."
	@echo
	@echo "To train your models, type: make all"
	@echo
	@echo "The main targets in this Makefile are:"
	@echo ${MAIN_TARGETS}
	@echo
	@echo "Expected output files are:"
	@sed -e 's/  */\n/g' <<< "${EXPECTED_FILES}"


MAIN_TARGETS :=  all  clean  help  $(addsuffix _model, ${POSSIBLE_WORD_ALIGNMENT_MODELS} indicator mix merged pretrained)
$(addsuffix _model, ${POSSIBLE_WORD_ALIGNMENT_MODELS} indicator mix merged pretrained):  %_model:  %_wam

# Nothing to be done for pretrained models.
pretrained_wam:

merged_wam:  $(addsuffix _wam, ${EXPECTED_MODEL_TYPES_PFX})

mix_wam:  # Dependencies are defined in the python code.

indicator_wam:  # Dependencies for sub cpt are defined in the python code.
# Indicator cpt require a single word alignment model.
ifeq ($(words ${TRAIN_TM}), 1)
# Don't create a global word alignment model using all corpora pairs if there is only one pair.
indicator_wam:  ${${MERGED_CPT_ZN_MODEL}_MODEL_PFX}.${TRAIN_TM}.${L2_GIVEN_L1X}  ${${MERGED_CPT_ZN_MODEL}_MODEL_PFX}.${TRAIN_TM}.${L1_GIVEN_L2X}
indicator_wam:  ${${MERGED_CPT_ZN_MODEL}_MODEL_PFX}.${TRAIN_TM}.${L2_GIVEN_L1X}  ${${MERGED_CPT_ZN_MODEL}_MODEL_PFX}.${TRAIN_TM}.${L1_GIVEN_L2X}
else
# TODO: Should these wams be ALL_TMS?
indicator_wam:  ${${MERGED_CPT_ZN_MODEL}_MODEL_PFX}.${L2_GIVEN_L1X}  ${${MERGED_CPT_ZN_MODEL}_MODEL_PFX}.${L1_GIVEN_L2X}
indicator_wam:  ${${MERGED_CPT_ZN_MODEL}_MODEL_PFX}.${L2_GIVEN_L1X}  ${${MERGED_CPT_ZN_MODEL}_MODEL_PFX}.${L1_GIVEN_L2X}
endif

fast_align_wam:  # Dependencies for sub cpt are defined in the python code.


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
	${RM} ${ALL_WAMS}  #  This is for ibm4 models.
	${RM} -r ${FAST_ALIGN_MODEL_PFX}

.PHONY: word_alignment_models  $(addsuffix _model, ${POSSIBLE_WORD_ALIGNMENT_MODELS})
word_alignment_models:  $(addsuffix _model, ${POSSIBLE_WORD_ALIGNMENT_MODELS})
word_alignment_models:  $(addsuffix .mixwam.${L2_GIVEN_L1X}, ${POSSIBLE_WORD_ALIGNMENT_MODELS})
word_alignment_models:  $(addsuffix .mixwam.${L1_GIVEN_L2X}, ${POSSIBLE_WORD_ALIGNMENT_MODELS})

define DEPS.PYSCRIPT
from __future__ import print_function

mixWamCorpora = set("${TUNE_MIXTM_FINAL} ${MIXTM} ${MIXTM_TRAIN_MIX}".strip().split())
def which_wam(c):
   if len("${MIXTM_USE_GLOBAL_WORD_ALIGNMENT_MODEL}"):
      if c in mixWamCorpora:
         return "mixwam"
      else:
         return c
   else:
      return c

def modelName(corpora, wam, direction):
   return "{m}.{c}.{d}".format(m=wam, c=corpora, d=direction)

def forwardModel(corpora, wam):
   return modelName(corpora, wam, "${L2_GIVEN_L1X}")

def backwardModel(corpora, wam):
   return modelName(corpora, wam, "${L1_GIVEN_L2X}")

with open(".Makefile.deps", "w") as df:
   expectedFiles = set()

   # the meta target for word alignment model depends on word alignment model files.
   # both forward and backward word alignment models require source and target corpora.
   WAMs = "$(filter-out ${IBM4_MODEL_PFX} ${FAST_ALIGN_MODEL_PFX}, ${POSSIBLE_WORD_ALIGNMENT_MODELS})"
   WAMs = set(WAMs.strip().split())
   for wam in WAMs:
      # TODO:  Can we really get mixwam in ALL_WAMS?
      for corpora in set("$(filter-out mixwam, ${ALL_WAMS})".strip().split()):
         forwardName  = forwardModel(corpora, wam)
         backwardName = backwardModel(corpora, wam)
         print("{f}:  {c}${L1X}  {c}${L2X}".format(c=corpora, f=forwardName), file=df)
         print("{b}:  {c}${L1X}  {c}${L2X}".format(c=corpora, b=backwardName), file=df)

      # TODO Why do we create those rules?  These look like the rules for mixwam execpt for more corpora.
      # This seems to be required in tm.
      # Most likely there should be a if statement around this block of code.
      # This mega global wam is used when indicator_cpt & len(TRAIN_TM) > 1
      forwardName  = "{m}.${L2_GIVEN_L1X}".format(m=wam)
      backwardName = "{m}.${L1_GIVEN_L2X}".format(m=wam)
      for corpora in set("${ALL_TMS}".strip().split()):
         print("{f}:  {c}${L1X}  {c}${L2X}".format(c=corpora, f=forwardName), file=df)
         print("{b}:  {c}${L1X}  {c}${L2X}".format(c=corpora, b=backwardName), file=df)

      # How to build a mixwam
      forwardName  = forwardModel("mixwam", wam)
      backwardName = backwardModel("mixwam", wam)
      for corpora in set("${MIXTM} ${MIXTM_TRAIN_MIX}".strip().split()):
         print("{f}:  {c}${L1X}  {c}${L2X}".format(c=corpora, f=forwardName), file=df)
         print("{b}:  {c}${L1X}  {c}${L2X}".format(c=corpora, b=backwardName), file=df)

#   # Note that corpora dependencies for IBM4 models are hardcoded in Makefile.toolkit.
#   for wam in "$(filter ${IBM4_MODEL_PFX}, ${POSSIBLE_WORD_ALIGNMENT_MODELS})".strip().split():
#      # TODO: should we exclude MIXTM from here in case the user asked for a global word alignment model?
#      for corpora in "${ALL_WAMS}".strip().split():
#         forwardName  = forwardModel(corpora, wam)
#         backwardName = backwardModel(corpora, wam)
#         print("{m}_wam:  {f}  {b}".format(m=wam, f=forwardName, b=backwardName), file=df)

   ########################################
   # FAST ALIGN
   for wam in ("${FAST_ALIGN_MODEL_PFX}",):
      for corpora in set("$(filter-out mixwam, ${ALL_WAMS})".strip().split()):
         forwardName  = forwardModel(corpora, wam)
         backwardName = backwardModel(corpora, wam)
         glued = "${FAST_ALIGN_MODEL_PFX}/" + corpora + ".${SRC_LANG}_${TGT_LANG}.glued"
         print("{f}:  {g}".format(f=forwardName, g=glued), file=df)
         print("{b}:  {g}".format(b=backwardName, g=glued), file=df)

      # How to build a mixwam
      forwardName  = forwardModel("mixwam", wam)
      backwardName = backwardModel("mixwam", wam)
      glued = "${FAST_ALIGN_MODEL_PFX}/mixwam.${SRC_LANG}_${TGT_LANG}.glued"
      print("{f}:  {g}".format(f=forwardName, g=glued), file=df)
      print("{b}:  {g}".format(b=backwardName, g=glued), file=df)
      for corpora in set("${MIXTM} ${MIXTM_TRAIN_MIX}".strip().split()):
         print("{g}:  {c}".format(g=glued, c=corpora+"${L1X}"), file=df)
         print("{g}:  {c}".format(g=glued, c=corpora+"${L2X}"), file=df)

      # How to build a global wam.
      forwardName  = "{m}.${L2_GIVEN_L1X}".format(m=wam)
      backwardName = "{m}.${L1_GIVEN_L2X}".format(m=wam)
      glued = "${FAST_ALIGN_MODEL_PFX}/${SRC_LANG}_${TGT_LANG}.glued"
      print("{f}:  {g}".format(f=forwardName, g=glued), file=df)
      print("{b}:  {g}".format(b=backwardName, g=glued), file=df)
      for corpora in set("${ALL_TMS}".strip().split()):
         print("{g}:  {c}".format(g=glued, c=corpora+"${L1X}"), file=df)
         print("{g}:  {c}".format(g=glued, c=corpora+"${L2X}"), file=df)


   #############################################################################
   # META LEVEL TARGETS
   def addModelsToMetaTarget(target, CORPORA, WAMs):
      for corpora in set(CORPORA.strip().split()):
         corpora = which_wam(corpora)  # switch to mixwam if MIXTM_USE_GLOBAL_WORD_ALIGNMENT_MODEL
         for wam in set(WAMs.strip().split()):
            forwardName  = forwardModel(corpora, wam)
            backwardName = backwardModel(corpora, wam)
            print("{target}_wam:  {f}  {b}".format(target=target(wam), f=forwardName, b=backwardName), file=df)
            expectedFiles.add(forwardName)
            expectedFiles.add(backwardName)


   def wamType(*args):
     if len(args):
        return lambda wam: args[0]
     else:
        return lambda wam: wam

   #####################################
   # LEXICALIZED DISTORTION MODELS
   WAMs = "$(sort $(filter ${PT_TYPES:_cpt=}, ${POSSIBLE_WORD_ALIGNMENT_MODELS}) ${EXPECTED_MODEL_TYPES_PFX})"
   addModelsToMetaTarget(wamType("ldm"), "$(sort ${TRAIN_LDM})",  WAMs)


   #####################################
   # HIERARCHICAL LEXICALIZED DISTORTION MODELS
   WAMs = "$(sort $(filter ${PT_TYPES:_cpt=}, ${POSSIBLE_WORD_ALIGNMENT_MODELS}) ${EXPECTED_MODEL_TYPES_PFX})"
   addModelsToMetaTarget(wamType("hldm"), "$(sort ${TRAIN_HLDM})", WAMs)


   #####################################
   # { ibm1, ibm2, ibm4, hmm1, hmm2, hmm3, fast_align }_wam
   WAMs = "${POSSIBLE_WORD_ALIGNMENT_MODELS}"
   addModelsToMetaTarget(wamType(), "$(sort ${TRAIN_TM})", WAMs)


   #####################################
   # MERGED
   addModelsToMetaTarget(wamType("merged"), "$(sort ${TRAIN_TM})", "${EXPECTED_MODEL_TYPES_PFX}")


   #####################################
   # MIXTURE
   mixWAMs = "${EXPECTED_MODEL_TYPES_PFX}"
   addModelsToMetaTarget(wamType("mix"), "$(sort ${MIX_WAMS})", mixWAMs)


   #####################################
   # INDICATOR
   indicatorWAMs = "$(foreach c, ${MERGED_CPT_JPT_TYPES}, ${${c}_MODEL_PFX})"
   addModelsToMetaTarget(wamType("indicator"), "${ALL_TMS}", indicatorWAMs)


   #####################################
   # BILM
   WAMs = "$(foreach c, ${MERGED_CPT_JPT_TYPES}, ${${c}_MODEL_PFX})"
   addModelsToMetaTarget(wamType("bilm"), "${TRAIN_BILM}", indicatorWAMs)


   print("EXPECTED_FILES := {}".format(" ".join(sorted(expectedFiles))), file=df)
endef
#$(info WORD ALIGNMENT: ${DEPS.PYSCRIPT})
$(shell python -c '${DEPS.PYSCRIPT}')
include .Makefile.deps



ifdef MIXTM_USE_GLOBAL_WORD_ALIGNMENT_MODEL
ifneq ($(filter ${IBM4_MODEL_PFX}, ${EXPECTED_MODEL_TYPES_PFX}),)
$(error Using MIXTM_USE_GLOBAL_WORD_ALIGNMENT_MODEL with an IBM4 model is not yet supported.)
endif
endif


################################################################################
# DEBUGGING
.PHONY:  debug
debug:  word_alignment_models


ifdef MIXTM_USE_GLOBAL_WORD_ALIGNMENT_MODEL
$(info ibm module using globbal word alignment model for mixture.)
endif



################################################################################
# TESTSUITE

.PHONY: testsuite

%.testcase:  export TRAIN_TM   := tm-train  TM
%.testcase:  export TRAIN_LDM  := ldm-train
%.testcase:  export TRAIN_HLDM := hldm-train

%.testcase:  export MERGED_CPT_ZN_MODEL := HMM1
%.testcase:  export MERGED_CPT_JPT_TYPES := IBM2 HMM3
%.testcase:  export MERGED_CPT_USE_ALIGNMENT_INDICATORS := 0

%.testcase:  export MIXTM           := subtm1 subtm2
%.testcase:  export MIXTM_TRAIN_MIX := mixtm_train_mix
%.testcase:  export TUNE_MIXTM      := tune_mixtm
%.testcase:  export MIXTM_USE_GLOBAL_WORD_ALIGNMENT_MODEL :=

%.testcase:  export USE_SIGPRUNING=
%.testcase:  export USE_LDM=
%.testcase:  export USE_HLDM=

%.testcase:  export USING_CLUSTER := 1
%.testcase:  export PARALLELISM_LEVEL_TM := 1

%.testcase:
	echo "TESTCASE:  $@"
	${MAKE} clean &> /dev/null
	mkdir -p ${ALL_WAMS}
	${MAKE} -j 11 ${TESTCASE_OPTS} all


testsuite:  ibm4.testcase
ibm4.testcase:  export PT_TYPES := ibm4_cpt

testsuite:  fast_align.testcase
fast_align.testcase:  export PT_TYPES := fast_align_cpt

testsuite:  wams.testcase
wams.testcase:  export PT_TYPES := ibm1_cpt ibm2_cpt  hmm1_cpt hmm2_cpt hmm3_cpt

testsuite:  pretrained.testcase
pretrained.testcase:  export PT_TYPES := pretrained_cpt

testsuite:  merged.testcase
merged.testcase:  export PT_TYPES := merged_cpt

testsuite:  mix.testcase
mix.testcase:  export PT_TYPES := mix_cpt

testsuite:  mixwam.testcase
mixwam.testcase:  export PT_TYPES := mix_cpt
mixwam.testcase:  export MIXTM_USE_GLOBAL_WORD_ALIGNMENT_MODEL := 1

# We haven't implemented how to create the alignment for TUNE_MIXTM, thus there
# is a check that prevents us from performing the following test.  This is why
# there is that weird UNITTESTING variable defined to bypass the check.
testsuite:  mixwam.fa.testcase
mixwam.fa.testcase:  export UNITTESTING := TRUE
mixwam.fa.testcase:  export PT_TYPES := mix_cpt
mixwam.fa.testcase:  export MIXTM_USE_GLOBAL_WORD_ALIGNMENT_MODEL := 1
mixwam.fa.testcase:  export MERGED_CPT_JPT_TYPES := IBM2 HMM3 FAST_ALIGN

testsuite:  indicator.testcase
indicator.testcase:  export PT_TYPES := indicator_cpt

testsuite:  ldm.testcase
ldm.testcase:  export USE_LDM := 1
ldm.testcase:  export USE_HLDM := 1
ldm.testcase:  export PT_TYPES :=  merged_cpt

testsuite:  all.testcase
all.testcase:  export USE_LDM :=
all.testcase:  export USE_HLDM :=
all.testcase:  export MIXTM_USE_GLOBAL_WORD_ALIGNMENT_MODEL := 1
all.testcase:  export PT_TYPES :=  fast_align_cpt  ibm4_cpt ibm1_cpt ibm2_cpt  hmm1_cpt hmm2_cpt hmm3_cpt merged_cpt pretrained_cpt mix_cpt indicator_cpt
