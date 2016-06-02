#!/usr/bin/make -f
# vim:noet:ts=3:nowrap:filetype=make

# @file Makefile
# @brief Dependencies to create Word Alignment files for corpora.
#
# @author Samuel Larkin
#
# Traitement multilingue de textes / Multilingual Text Processing
# Tech. de l'information et des communications / Information and Communications Tech.
# Conseil national de recherches Canada / National Research Council Canada
# Copyright 2015, Sa Majeste la Reine du Chef du Canada
# Copyright 2015, Her Majesty in Right of Canada

WAL_DIR_PFX := $(dir $(lastword ${MAKEFILE_LIST}))

# Mandatory include: master config file.
include ${WAL_DIR_PFX}../../Makefile.params

# Include and override parameters with user specific config file.
MAKEFILE_PARAMS ?= Makefile.params
-include ${WAL_DIR_PFX}${MAKEFILE_PARAMS}

# Include the master toolkit.
include ${WAL_DIR_PFX}../../Makefile.toolkit

# Include the toolkit for building Alignment files.
include ${WAL_DIR_PFX}Makefile.toolkit

# What is this module's name.
MODULE_NAME ?= wal

# Where we can find the parallel corpora.
CORPORA_DIR ?= ${WAL_DIR_PFX}../../corpora

# From which corpora should we use its gizacfg to force align ${FORCE_ALIGN_SET}?
IBM4_FORCE_ALIGN_WAM := $(firstword ${TRAIN_TM})

# This script might produce directory and we want to easily remove them.
RM := rm -rf

# After this Makefile, the following targets/files are precious.
FILES_TO_BE_LOCKED = *.align.gz

# Allows to search for alignment files in corpus.
vpath %${L1X} ${CORPORA_DIR}
vpath %${L2X} ${CORPORA_DIR}
vpath %${L1}  ${CORPORA_DIR}
vpath %${L2}  ${CORPORA_DIR}

vpath %.${L1_GIVEN_L2X}  ${WAL_DIR_PFX}../ibm/
vpath %.${L2_GIVEN_L1X}  ${WAL_DIR_PFX}../ibm/
vpath %/${SRC_LANG}.lc   ${WAL_DIR_PFX}../ibm/
vpath %/${TGT_LANG}.lc   ${WAL_DIR_PFX}../ibm/
vpath %fast_align.gz     ${WAL_DIR_PFX}../ibm/${FAST_ALIGN_MODEL_PFX}
vpath %/${L2_GIVEN_L1}.A3.final.part0  ${WAL_DIR_PFX}../ibm/
vpath %/${L1_GIVEN_L2}.A3.final.part0  ${WAL_DIR_PFX}../ibm/


.DEFAULT_GOAL := help
.DELETE_ON_ERROR:
.SUFFIXES:
.SECONDARY:


########################################
# ALL
# Define all the work to be done.
.PHONY: all
all:  SHELL=${LOCAL_SHELL}
all:  ${PT_TYPES:_cpt=_wal}
all:  $(and ${USE_LDM}, ldm_wal)
all:  $(and ${USE_HLDM}, hldm_wal)
all:  $(and ${USE_BILM}, bilm_wal)


MAIN_TARGETS :=  all  clean  help  $(addsuffix _model, ${POSSIBLE_WORD_ALIGNMENT_MODELS} indicator mix merged pretrained)
$(addsuffix _model, ${POSSIBLE_WORD_ALIGNMENT_MODELS} indicator mix merged pretrained):  %_model:  %_wal


pretrained_wal:

merged_wal:  $(addsuffix _wal, ${EXPECTED_MODEL_TYPES_PFX})

mix_wal:  # Dependencies are defined in the python script.

indicator_wal:  # Dependencies are defined in the python script.

fast_align_wal:  # Dependencies are defined in the python script.


########################################
# HELP OPTIONS
.PHONY: help
help: SHELL=${LOCAL_SHELL}
help:
	@echo "Create Word Alignment Files for the corpora."
	@echo
	@echo "To train your models, type: make all"
	@echo
	@echo "The main targets in this Makefile are:"
	@echo ${MAIN_TARGETS}
	@echo
	@echo "Expected output files are:"
	@sed -e 's/  */\n/g' <<< "${EXPECTED_FILES}"


########################################
# Clean up
.PHONY: clean clean.content clean.logs hide.logs
clean: SHELL=${LOCAL_SHELL}
clean: clean.content clean.logs

clean.content: SHELL=${LOCAL_SHELL}

clean.logs: SHELL=${LOCAL_SHELL}
clean.logs:
	${RM} parallelize.pl.* run-parallel-log* log.* run-p.*
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


########################################
# ALIGNMENT FILES.

clean.content: clean.alignment_files

.PHONY: clean.alignment_files
clean.alignment_files:  SHELL=${LOCAL_SHELL}
clean.alignment_files:
	${RM} *.align.gz
	${RM} -r ${ALL_WAMS}
	$(if ${FORCE_ALIGN_SET},${RM} -r ${FORCE_ALIGN_SET})


.PHONY: alignment_files  $(addsuffix _alignment, ${POSSIBLE_WORD_ALIGNMENT_MODELS})
alignment_files:  $(addsuffix _alignment, ${POSSIBLE_WORD_ALIGNMENT_MODELS})


define DEPS.PYSCRIPT
from __future__ import print_function

mixWamCorpora = set("${TUNE_MIXTM_FINAL} ${MIXTM} ${MIXTM_TRAIN_MIX}".strip().split())
def which_wam(c):
   # Special case where TUNE_MIXTM_FINAL can not have a ibm model thus it needs to use MIXTM_TRAIN_MIX.
   if c in set("${TUNE_MIXTM_FINAL}".strip().split()):
      return which_wam("${MIXTM_TRAIN_MIX}")

   # Special case where TUNE_BILM can not have a ibm model thus it needs to use TRAIN_BILM.
   if c in set("${TUNE_BILM}".strip().split()):
      return which_wam("${TRAIN_BILM}")

   if len("${MIXTM_USE_GLOBAL_WORD_ALIGNMENT_MODEL}"):
      if c in mixWamCorpora:
         return "mixwam"
      else:
         return c
   else:
         return c

def writeDeps(alignmentFileName, source, target, d1, d2):
   print("{alignmentFileName}:  {s}  {t}".format(alignmentFileName=alignmentFileName, s=source, t=target), file=df)
   print("{alignmentFileName}:  {d1}  {d2}".format(alignmentFileName=alignmentFileName, d1=d1, d2=d2), file=df)

def createRules(corpora, wam, source, target):
   alignmentFileName = "{c}.{m}.${L1_2_L2}.align.gz".format(m=wam, c=corpora)
   d1 = "{m}.{c}.${L2_GIVEN_L1X}".format(m=wam, c=which_wam(corpora))
   d2 = "{m}.{c}.${L1_GIVEN_L2X}".format(m=wam, c=which_wam(corpora))
   writeDeps(alignmentFileName, source, target, d1, d2)


with open(".Makefile.deps", "w") as df:
   expectedFiles = set()

   # Default rules except for IBM4 & fast_align that are third-party aligners.
   for corpora in set("${ALL_WAMS}".strip().split()):
      for wam in set("$(filter-out ${IBM4_MODEL_PFX} ${FAST_ALIGN_MODEL_PFX}, ${POSSIBLE_WORD_ALIGNMENT_MODELS})".strip().split()):
         createRules(corpora, wam, corpora+"${L1X}", corpora+"${L2X}")

   # For IBM4.
   for corpora in set("${ALL_WAMS} ${FORCE_ALIGN_SET}".strip().split()):
      for wam in set("$(filter ${IBM4_MODEL_PFX}, ${POSSIBLE_WORD_ALIGNMENT_MODELS})".strip().split()):
         alignmentFileName = "{c}.{m}.${L1_2_L2}.align.gz".format(m=wam, c=corpora)
         source = corpora + "/${SRC_LANG}.lc"
         target = corpora + "/${TGT_LANG}.lc"
         d1 = corpora + "/${L1_2_L2}.${IBM4_MODEL_PFX}.alignment.gz"
         d2 = corpora + "/${L2_2_L1}.${IBM4_MODEL_PFX}.alignment.gz"
         writeDeps(alignmentFileName, source, target, d1, d2)

   # For IBM4.
   # For the devs & tests, we want to use the first TRAIN_TM as IBM4 models.
   for corpora in set("$(filter-out ${TUNE_MIXTM_FINAL}, ${FORCE_ALIGN_SET})".strip().split()):
      for wam in set("$(filter ${IBM4_MODEL_PFX}, ${POSSIBLE_WORD_ALIGNMENT_MODELS})".strip().split()):
         print("{c}/%:  override MIXTM_TRAIN_MIX:={A}".format(c=corpora, A="${IBM4_FORCE_ALIGN_WAM}"), file=df)

   # Special case for mixtm and BiLM tuning.
   for corpora in set("${TUNE_MIXTM_FINAL} ${TUNE_BILM}".strip().split()):
      for wam in set("$(filter-out ${IBM4_MODEL_PFX} ${FAST_ALIGN_MODEL_PFX}, ${POSSIBLE_WORD_ALIGNMENT_MODELS})".strip().split()):
         createRules(corpora, wam, corpora+"${L1}", corpora+"${L2}")

   # FAST ALIGN
   # source and target must be of the form %${L1x} and %${L2X}
   for corpora in set("${ALL_WAMS}".strip().split()):
      for wam in set("$(filter ${FAST_ALIGN_MODEL_PFX}, ${POSSIBLE_WORD_ALIGNMENT_MODELS})".strip().split()):
         alignmentFileName = "{c}.{m}.${L1_2_L2}.align.gz".format(m=wam, c=corpora)
         source = corpora + "${L1X}"
         target = corpora + "${L2X}"
         # How unfortunate that we need to specify the %.fast_align.gz dependencies
         # in the Makefile and cannot to so in Makefile.toolkit.
         fal1 = corpora + ".${L2_2_L1}.fast_align.gz"
         fal2 = corpora + ".${L1_2_L2}.fast_align.gz"
         writeDeps(alignmentFileName, source, target, fal1, fal2)


   #############################################################################
   # META LEVEL TARGETS
   def addModelsToMetaTarget(target, CORPORA, WAMs):
      for corpora in set(CORPORA.strip().split()):
         for wam in set(WAMs.strip().split()):
            alignmentFileName = "{c}.{m}.${L1_2_L2}.align.gz".format(m=wam, c=corpora)
            print("{target}_wal:  {alignment}".format(target=target(wam), alignment=alignmentFileName), file=df)
            expectedFiles.add(alignmentFileName)

   def wamType(*args):
     if len(args):
        return lambda wam: args[0]
     else:
        return lambda wam: wam


   #####################################
   # LEXICALIZED DISTORTION MODELS
   WAMs = "$(sort $(filter ${PT_TYPES:_cpt=}, ${POSSIBLE_WORD_ALIGNMENT_MODELS}) ${EXPECTED_MODEL_TYPES_PFX} ${${MERGED_CPT_ZN_MODEL}_MODEL_PFX})"
   addModelsToMetaTarget(wamType("ldm"), "$(sort ${TRAIN_LDM})", WAMs)


   #####################################
   # HIERARCHICAL LEXICALIZED DISTORTION MODELS
   WAMs = "$(sort $(filter ${PT_TYPES:_cpt=}, ${POSSIBLE_WORD_ALIGNMENT_MODELS}) ${EXPECTED_MODEL_TYPES_PFX} ${${MERGED_CPT_ZN_MODEL}_MODEL_PFX})"
   addModelsToMetaTarget(wamType("hldm"), "$(sort ${TRAIN_HLDM})", WAMs)


   #####################################
   # { ibm1, ibm2, ibm4, hmm1, hmm2, hmm3, fast_align }_wam
   WAMs = "${POSSIBLE_WORD_ALIGNMENT_MODELS}"
   addModelsToMetaTarget(wamType(), "$(sort ${TRAIN_TM})", WAMs)


   #####################################
   # MIXTURE
   WAMs = "${EXPECTED_MODEL_TYPES_PFX}"
   addModelsToMetaTarget(wamType("mix"), "$(sort ${TUNE_MIXTM_FINAL} ${MIX_WAMS})", WAMs)


   #####################################
   # INDICATOR
   WAMs = "$(foreach c, ${MERGED_CPT_JPT_TYPES}, ${${c}_MODEL_PFX})"
   addModelsToMetaTarget(wamType("indicator"), "$(sort ${ALL_TMS})", WAMs)


   #####################################
   # BILM
   WAMs = "$(foreach c, ${MERGED_CPT_JPT_TYPES}, ${${c}_MODEL_PFX})"
   addModelsToMetaTarget(wamType("bilm"), "$(sort ${TRAIN_BILM} ${TUNE_BILM})", WAMs)


   #####################################
   # FORCE ALIGN
   WAMs = "${IBM4_MODEL_PFX}"
   addModelsToMetaTarget(wamType("ibm4_force_align"), "$(sort ${FORCE_ALIGN_SET})", WAMs)


   print("EXPECTED_FILES := {}".format(" ".join(sorted(expectedFiles))), file=df)
endef

#$(info ALIGNMENT: ${DEPS.PYSCRIPT})
$(shell python -c '${DEPS.PYSCRIPT}')
include .Makefile.deps


################################################################################
# DEBUGGING
.PHONY:  debug  debugMin  ${IBM4_MODEL_PFX}_alignment
debugAll:  alignment_files
debug:  $(addsuffix _alignment, $(filter-out ${IBM4_MODEL_PFX}, ${POSSIBLE_WORD_ALIGNMENT_MODELS}))
debugIBM4:  ${IBM4_MODEL_PFX}_alignment

ifdef MIXTM_USE_GLOBAL_WORD_ALIGNMENT_MODEL
$(info ibm module using globbal word alignment model for mixture.)
endif
