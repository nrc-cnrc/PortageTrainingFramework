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


$(info PT_TYPES: ${PT_TYPES})
########################################
# ALL
# Define all the work to be done.
.PHONY: all
all:  SHELL=${LOCAL_SHELL}
all:  ${PT_TYPES:_cpt=_wal}
all:  $(and ${USE_LDM}, ldm_wal)
all:  $(and ${USE_HLDM}, hldm_wal)
all:  $(and ${USE_BILM}, bilm_wal)
all:  $(and ${NNJM_TRAIN_CORPUS}, nnjm_wal)
all:  $(and ${NNJM_FINE_TUNING_TRAIN_CORPUS}, nnjm_wal)


MAIN_TARGETS :=  all clean help

$(addsuffix _model, ${POSSIBLE_WORD_ALIGNMENT_MODELS} indicator mix merged pretrained):  %_model:  %_wal
MODEL_TARGETS := $(sort $(addsuffix _model, ${POSSIBLE_WORD_ALIGNMENT_MODELS}))
MODEL_TARGETS += "\n " $(addsuffix _model, indicator mix merged pretrained)


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
	@echo "To create the word alignment files, type: make all"
	${HELP_LIST_MAIN_TARGETS}
	@echo -e " " ${MODEL_TARGETS}
	${HELP_LIST_EXPECTED_FILES}


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

MAIN_TARGETS += time-mem


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

$(info ALL_WAMS: ${ALL_WAMS})


define DEPS.PYSCRIPT
from __future__ import print_function

mixWamCorpora = set("${TUNE_MIXTM_FINAL} ${MIXTM} ${MIXTM_TRAIN_MIX}".split())
def which_wam(c):
   # Special case where TUNE_MIXTM_FINAL can not have a ibm model thus it needs to use MIXTM_TRAIN_MIX.
   if c in set("${TUNE_MIXTM_FINAL}".split()):
      return which_wam("${MIXTM_TRAIN_MIX}")

   # Special case where TUNE_BILM can not have a ibm model thus it needs to use TRAIN_BILM.
   if c in set("${TUNE_BILM}".split()):
      return which_wam("${TRAIN_BILM}")

   if len("${MIXTM_USE_GLOBAL_WORD_ALIGNMENT_MODEL}") and c in mixWamCorpora:
      return "mixwam"
   return c

def writeDeps(alignmentFileName, source, target, d1, d2):
   print("{alignmentFileName}:  {s}  {t}".format(alignmentFileName=alignmentFileName, s=source, t=target), file=df)
   print("{alignmentFileName}:  {d1}  {d2}".format(alignmentFileName=alignmentFileName, d1=d1, d2=d2), file=df)

def createRules(corp, wam, source, target):
   alignmentFileName = "{c}.{m}.${L1_2_L2}.align.gz".format(m=wam, c=corp)
   d1 = "{m}.{c}.${L2_GIVEN_L1X}".format(m=wam, c=which_wam(corp))
   d2 = "{m}.{c}.${L1_GIVEN_L2X}".format(m=wam, c=which_wam(corp))
   writeDeps(alignmentFileName, source, target, d1, d2)

with open(".Makefile.deps", "w") as df:
   expectedFiles = set()

   print("# FORCE_ALIGN_SET: {}".format(set("${FORCE_ALIGN_SET}".split())), file=df)
   print("# ALL_WAMS: {}".format(set("${ALL_WAMS}".split())), file=df)

   ########################################
   # Default rules except for IBM4 & fast_align that are third-party aligners.
   print("# Default rules except for IBM4 & fast_align that are third-party aligners.", file=df)
   for corp in set("${ALL_WAMS}".split()):
      for wam in set("$(filter-out ${IBM4_MODEL_PFX} ${FAST_ALIGN_MODEL_PFX}, ${POSSIBLE_WORD_ALIGNMENT_MODELS})".split()):
         createRules(corp, wam, corp+"${L1X}", corp+"${L2X}")

   # Special case for mixtm and BiLM tuning.
   # TODO: do we really need to align TUNE_MIXTM_FINAL and TUNE_BILM?
   # If so should not we be using tm-train WAM like the NNJM?
   print("# mixtm, NNJM and BiLM tuning", file=df)
   for corp in set("${TUNE_MIXTM_FINAL} ${TUNE_BILM} ${NNJM_DEV_CORPUS} ${NNJM_TEST_CORPUS} ${NNJM_FINE_TUNING_DEV_CORPUS} ${NNJM_FINE_TUNING_TEST_CORPUS}".split()):
      for wam in set("$(filter-out ${IBM4_MODEL_PFX} ${FAST_ALIGN_MODEL_PFX}, ${POSSIBLE_WORD_ALIGNMENT_MODELS})".split()):
         createRules(corp, wam, corp+"${L1}", corp+"${L2}")

   ########################################
   # For IBM4.
   print("# IBM4", file=df)
   print("# IBM4: {}".format(set("${ALL_WAMS} ${FORCE_ALIGN_SET}".split())), file=df)
   for corp in set("${ALL_WAMS} ${FORCE_ALIGN_SET}".split()):
      for wam in set("$(filter ${IBM4_MODEL_PFX}, ${POSSIBLE_WORD_ALIGNMENT_MODELS})".split()):
         alignmentFileName = "{c}.{m}.${L1_2_L2}.align.gz".format(m=wam, c=corp)
         source = corp + "/${SRC_LANG}.lc"
         target = corp + "/${TGT_LANG}.lc"
         d1 = corp + "/${L1_2_L2}.${IBM4_MODEL_PFX}.alignment.gz"
         d2 = corp + "/${L2_2_L1}.${IBM4_MODEL_PFX}.alignment.gz"
         writeDeps(alignmentFileName, source, target, d1, d2)

   # For IBM4.
   # For the devs & tests, we want to use the first TRAIN_TM (aka IBM4_FORCE_ALIGN_WAM) as IBM4 model.
   print("# IBM4 devs & tests", file=df)
   for corp in set("$(filter-out ${TUNE_MIXTM_FINAL} ${ALL_WAMS}, ${FORCE_ALIGN_SET})".split()):
      for wam in set("$(filter ${IBM4_MODEL_PFX}, ${POSSIBLE_WORD_ALIGNMENT_MODELS})".split()):
         print("{c}/%:  override MIXTM_TRAIN_MIX:={A}".format(c=corp, A="${IBM4_FORCE_ALIGN_WAM}"), file=df)


   ########################################
   # FAST ALIGN
   # source and target must be of the form %${L1X} and %${L2X}
   print("# FAST ALIGN", file=df)
   for corp in set("${ALL_WAMS} ${NNJM_TRAIN_CORPUS} ${NNJM_FINE_TUNING_TRAIN_CORPUS}".split()):
      for wam in set("$(filter ${FAST_ALIGN_MODEL_PFX}, ${POSSIBLE_WORD_ALIGNMENT_MODELS})".split()):
         alignmentFileName = "{c}.{m}.${L1_2_L2}.align.gz".format(m=wam, c=corp)
         source = corp + "${L1X}"
         target = corp + "${L2X}"
         # How unfortunate that we need to specify the %.fast_align.gz dependencies
         # in the Makefile and cannot to so in Makefile.toolkit.
         fal1 = corp + ".${L2_2_L1}.fast_align.gz"
         fal2 = corp + ".${L1_2_L2}.fast_align.gz"
         writeDeps(alignmentFileName, source, target, fal1, fal2)


   #############################################################################
   # META LEVEL TARGETS
   def addModelsToMetaTarget(target, corpora, wams, expected=True):
      for corp in sorted(set(corpora.split())):
         for wam in set(wams.split()):
            alignmentFileName = "{c}.{m}.${L1_2_L2}.align.gz".format(m=wam, c=corp)
            print("{target}_wal:  {alignment}".format(target=target(wam), alignment=alignmentFileName), file=df)
            if expected:
               expectedFiles.add(alignmentFileName)

   def wamType(wam_type=None):
      return (lambda wam: wam) if wam_type is None else (lambda wam: wam_type)

   pt_types = "${PT_TYPES:_cpt=}".split()

   #####################################
   # LEXICALIZED DISTORTION MODELS
   print("# LEXICALIZED DISTORTION MODELS", file=df)
   wams = "$(sort $(filter ${PT_TYPES:_cpt=}, ${POSSIBLE_WORD_ALIGNMENT_MODELS}) ${EXPECTED_MODEL_TYPES_PFX} ${${MERGED_CPT_ZN_MODEL}_MODEL_PFX})"
   addModelsToMetaTarget(wamType("ldm"), "${TRAIN_LDM}", wams)

   #####################################
   # HIERARCHICAL LEXICALIZED DISTORTION MODELS
   print("# HIERARCHICAL LEXICALIZED DISTORTION MODELS", file=df)
   wams = "$(sort $(filter ${PT_TYPES:_cpt=}, ${POSSIBLE_WORD_ALIGNMENT_MODELS}) ${EXPECTED_MODEL_TYPES_PFX} ${${MERGED_CPT_ZN_MODEL}_MODEL_PFX})"
   addModelsToMetaTarget(wamType("hldm"), "${TRAIN_HLDM}", wams)

   #####################################
   # Expected: { ibm1, ibm2, ibm4, hmm1, hmm2, hmm3, fast_align }_wal
   print("# { ibm1, ibm2, ibm4, hmm1, hmm2, hmm3, fast_align }_wal", file=df)
   wams = "$(filter ${PT_TYPES:_cpt=}, ${POSSIBLE_WORD_ALIGNMENT_MODELS})"
   addModelsToMetaTarget(wamType(), "${TRAIN_TM}", wams)

   #####################################
   # { ibm1, ibm2, ibm4, hmm1, hmm2, hmm3, fast_align }_wal
   print("# NNJM { ibm1, ibm2, ibm4, hmm1, hmm2, hmm3, fast_align }_wal", file=df)
   #wams = "$(filter ${NNJM_WAM_TYPE}, ${POSSIBLE_WORD_ALIGNMENT_MODELS})"
   wams = "${NNJM_WAM_TYPE}"
   addModelsToMetaTarget(wamType(), "${NNJM_DEV_CORPUS} ${NNJM_TEST_CORPUS} ${NNJM_TRAIN_CORPUS} ${NNJM_FINE_TUNING_DEV_CORPUS} ${NNJM_FINE_TUNING_TEST_CORPUS} ${NNJM_FINE_TUNING_TRAIN_CORPUS}", wams)

   print("# Not Expected { ibm1, ibm2, ibm4, hmm1, hmm2, hmm3, fast_align }_wal", file=df)
   wams = "$(filter-out ${PT_TYPES:_cpt=}, ${POSSIBLE_WORD_ALIGNMENT_MODELS})"
   addModelsToMetaTarget(wamType(), "${TRAIN_TM}", wams, expected=False)

   #####################################
   # MIXTURE
   print("# MIXTURE", file=df)
   wams = "${EXPECTED_MODEL_TYPES_PFX}"
   expected = "mix" in pt_types
   addModelsToMetaTarget(wamType("mix"), "${TUNE_MIXTM_FINAL} ${MIX_WAMS}", wams, expected)

   #####################################
   # INDICATOR
   print("# INDICATOR", file=df)
   wams = "$(foreach c, ${MERGED_CPT_JPT_TYPES}, ${${c}_MODEL_PFX})"
   expected = "indicator" in pt_types
   addModelsToMetaTarget(wamType("indicator"), "${ALL_TMS}", wams, expected)

   #####################################
   # BILM
   print("# BILM", file=df)
   wams = "$(foreach c, ${MERGED_CPT_JPT_TYPES}, ${${c}_MODEL_PFX})"
   addModelsToMetaTarget(wamType("bilm"), "${TRAIN_BILM} ${TUNE_BILM}", wams)

   #####################################
   # FORCE ALIGN
   print("# FORCE ALIGN", file=df)
   wams = "${IBM4_MODEL_PFX}"
   addModelsToMetaTarget(wamType("ibm4_force_align"), "${FORCE_ALIGN_SET}", wams)

   #####################################
   # NNJM
   print("# NNJM", file=df)
   wams = "${NNJM_WAM_TYPE}"
   if "${NNJM_TRAIN_CORPUS}".strip():
      addModelsToMetaTarget(wamType("nnjm"), "${NNJM_TRAIN_CORPUS} ${NNJM_DEV_CORPUS} ${NNJM_TEST_CORPUS}", wams)
   if "${NNJM_FINE_TUNING_TRAIN_CORPUS}".strip():
      addModelsToMetaTarget(wamType("nnjm"), "${NNJM_FINE_TUNING_TRAIN_CORPUS} ${NNJM_FINE_TUNING_DEV_CORPUS} ${NNJM_FINE_TUNING_TEST_CORPUS}", wams)

   print("EXPECTED_FILES :=", *sorted(expectedFiles), file=df)
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
