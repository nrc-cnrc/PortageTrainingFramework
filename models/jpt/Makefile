#!/usr/bin/make -f
# vim:noet:ts=3:nowrap:filetype=make

# @file Makefile
# @brief Dependencies to create Joint Phrase Tables.
#
# @author Samuel Larkin
#
# Traitement multilingue de textes / Multilingual Text Processing
# Tech. de l'information et des communications / Information and Communications Tech.
# Conseil national de recherches Canada / National Research Council Canada
# Copyright 2015, Sa Majeste la Reine du Chef du Canada
# Copyright 2015, Her Majesty in Right of Canada

JPT_DIR_PFX := $(dir $(lastword ${MAKEFILE_LIST}))

# Mandatory include: master config file.
include ${JPT_DIR_PFX}../../Makefile.params

# Include and override parameters with user specific config file.
MAKEFILE_PARAMS ?= Makefile.params
-include ${JPT_DIR_PFX}${MAKEFILE_PARAMS}

# Include the master toolkit.
include ${JPT_DIR_PFX}../../Makefile.toolkit

# Include the toolkit for building JPT models.
include ${JPT_DIR_PFX}Makefile.toolkit

# What is this module's name.
MODULE_NAME ?= jpt

# Where we can find the parallel corpora.
CORPORA_DIR ?= ${JPT_DIR_PFX}../../corpora

# This script might produce directory and we want to easily remove them.
RM := rm -rf

# After this Makefile, the following targets/files are precious.
FILES_TO_BE_LOCKED = jpt*


# Allows to search for alignment files in corpus.
vpath %${L1X} ${CORPORA_DIR}
vpath %${L2X} ${CORPORA_DIR}
vpath %${L1}  ${CORPORA_DIR}
vpath %${L2}  ${CORPORA_DIR}

vpath %.${L1_GIVEN_L2X}  ${JPT_DIR_PFX}../ibm/
vpath %.${L2_GIVEN_L1X}  ${JPT_DIR_PFX}../ibm/
vpath %/${SRC_LANG}.lc   ${JPT_DIR_PFX}../ibm/ ${JPT_DIR_PFX}../wal/
vpath %/${TGT_LANG}.lc   ${JPT_DIR_PFX}../ibm/ ${JPT_DIR_PFX}../wal/

vpath %.align.gz  ${JPT_DIR_PFX}../wal/


.DEFAULT_GOAL := help
.DELETE_ON_ERROR:
.SUFFIXES:
.SECONDARY:


########################################
# ALL
# Define all the work to be done.
.PHONY: all
all:  SHELL=${LOCAL_SHELL}
all:  ${PT_TYPES:_cpt=_model}

MAIN_TARGETS :=  all clean help

$(addsuffix _model, ${POSSIBLE_WORD_ALIGNMENT_MODELS} indicator mix merged pretrained):  %_model:  %_jpt
MODEL_TARGETS := $(sort $(addsuffix _model, ${POSSIBLE_WORD_ALIGNMENT_MODELS}))
MODEL_TARGETS += "\n " $(addsuffix _model, indicator mix merged pretrained)


pretrained_jpt:  # No dependencies for pretrained models.

merged_jpt:

mix_jpt:  ${JPT_MERGED_PFX}.${TUNE_MIXTM_FINAL}.${JOINTX}
mix_jpt:  $(foreach c, ${MIXTM}, ${JPT_MERGED_PFX}.$c.${JOINTX})

indicator_jpt:


########################################
# HELP OPTIONS
.PHONY: help
help: SHELL=${LOCAL_SHELL}
help:
	@echo "Create Joint Frequency Phrase Table Models."
	@echo
	@echo "To train the JPT models, type: make all"
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
# JOINT PHRASE TABLES

clean.content: clean.jpts

.PHONY: clean.jpts
clean.jpts: SHELL=${LOCAL_SHELL}
clean.jpts:
	$(RM) ${JPT_MODEL_PFX}.*
	${RM} -r JPTPAR*

.PHONY: jpts  $(addsuffix _jpt, ${POSSIBLE_WORD_ALIGNMENT_MODELS})
jpts:  SHELL=${LOCAL_SHELL}
jpts:  $(addsuffix _jpt, ${POSSIBLE_WORD_ALIGNMENT_MODELS})
jpts:  merged_jpt

define DEPS.PYSCRIPT
from __future__ import print_function

mixWamCorpora = set("${TUNE_MIXTM_FINAL} ${MIXTM} ${MIXTM_TRAIN_MIX}".split())
def which_wam(c):
   if len("${MIXTM_USE_GLOBAL_WORD_ALIGNMENT_MODEL}") and c in mixWamCorpora:
      return "mixwam"
   return c

def corporaNames(corp, wam, sx="${L1X}", tx="${L2X}"):
   if wam == "${IBM4_MODEL_PFX}":
      return {"s" : corp+"/${SRC_LANG}.lc", "t":corp+"/${TGT_LANG}.lc"}
   else:
      return {"s" : corp+sx, "t":corp+tx}

with open(".Makefile.deps", "w") as df:
   expectedFiles = set()

   # Definition of the generated makefile rules/targets:
   # the meta target jpt have a dependency on jpt file.
   # jpts require the word alignment models in both directions, this is for the -w1 option.
   # jpts require the alignment file.
   # jpts require the source and target corpora.
   wams = set("${POSSIBLE_WORD_ALIGNMENT_MODELS}".split())
   for corp in set("${MIXTM_TRAIN_MIX} ${ALL_TMS}".split()):
      w = which_wam(corp)
      for wam in wams:
         jptFileName = "${JPT_MODEL_PFX}.{m}.{c}.${JOINTX}".format(c=corp, m=wam)
         print("{jptFileName}:  {m}.{c}.${L2_GIVEN_L1X}  {m}.{c}.${L1_GIVEN_L2X}".format(m=wam, c=w, jptFileName=jptFileName), file=df)
         print("{jptFileName}:  {c}.{m}.${L1_2_L2}.align.gz".format(c=corp, m=wam, jptFileName=jptFileName), file=df)
         print("{jptFileName}:  {s}  {t}".format(c=corp, jptFileName=jptFileName, **corporaNames(corp, wam)), file=df)

   wams = set("${EXPECTED_MODEL_TYPES_PFX}".split())
   for corp in set("${MIXTM_TRAIN_MIX} ${ALL_TMS}".split()):
      mergedFileName = "${JPT_MERGED_PFX}.{c}.${JOINTX}".format(c=corp)
      for wam in wams:
         jptFileName = "${JPT_MODEL_PFX}.{m}.{c}.${JOINTX}".format(c=corp, m=wam)
         print("{mergedFileName}:  {jptFileName}".format(jptFileName=jptFileName, mergedFileName=mergedFileName), file=df)

   wams = set("${EXPECTED_MODEL_TYPES_PFX}".split())
   for corp in set("${TUNE_MIXTM_FINAL}".split()):
      mergedFileName = "${JPT_MERGED_PFX}.{c}.${JOINTX}".format(c=corp)
      for wam in wams:
         jptFileName = "${JPT_MODEL_PFX}.{m}.{c}.${JOINTX}".format(c=corp, m=wam)
         print("{mergedFileName}:  {jptFileName}".format(mergedFileName=mergedFileName, jptFileName=jptFileName), file=df)
         print("{jptFileName}:  {c}.{m}.${L1_2_L2}.align.gz".format(m=wam, c=corp, jptFileName=jptFileName), file=df)
         print("{jptFileName}:  {s}  {t}".format(jptFileName=jptFileName, **corporaNames(corp, wam, "${L1}", "${L2}")), file=df)

   jpt_types = "${PT_TYPES:_cpt=_jpt}".split()

   #############################################################################
   # META LEVEL TARGETS
   #####################################
   # { ibm1, ibm2, ibm4, hmm1, hmm2, hmm3, fast_align }_jpt
   wams = set("${POSSIBLE_WORD_ALIGNMENT_MODELS}".split())
   expected_wams = "${EXPECTED_MODEL_TYPES_PFX}".split()
   for corp in set("${TRAIN_TM}".split()):
      for wam in wams:
         jptFileName = "${JPT_MODEL_PFX}.{m}.{c}.${JOINTX}".format(c=corp, m=wam)
         print("{m}_jpt:  {jptFileName}".format(m=wam, jptFileName=jptFileName), file=df)
	 if wam in expected_wams:
	    expectedFiles.add(jptFileName)

   #####################################
   # MERGED
   for corp in set("${TRAIN_TM}".split()):
      mergedFileName = "${JPT_MERGED_PFX}.{c}.${JOINTX}".format(c=corp)
      print("merged_jpt:  {mergedFileName}".format(mergedFileName=mergedFileName), file=df)
      if "merged_jpt" in jpt_types:
         expectedFiles.add(mergedFileName)

   #####################################
   # MIXTURE
   for corp in set("${MIX_WAMS}".split()):
      mergedFileName = "${JPT_MERGED_PFX}.{c}.${JOINTX}".format(c=corp)
      print("mix_jpt:  {mergedFileName}".format(mergedFileName=mergedFileName), file=df)
      if "mix_jpt" in jpt_types:
         expectedFiles.add(mergedFileName)

   expected_wams = "${EXPECTED_MODEL_TYPES_PFX}".split()
   for corp in "${MIX_WAMS}".split():
      for wam in expected_wams:
         jptFileName = "${JPT_MODEL_PFX}.{m}.{c}.${JOINTX}".format(c=corp, m=wam)
         expectedFiles.add(jptFileName)

   #####################################
   # INDICATOR
   # What is needed when the user calls indicator_wam
   indicatorWAMs = "$(foreach c, ${MERGED_CPT_JPT_TYPES}, ${${c}_MODEL_PFX})"
   indicatorWAMs = set(indicatorWAMs.split())
   for corp in set("${ALL_TMS}".split()):
      for wam in indicatorWAMs:
         jptFileName = "${JPT_MODEL_PFX}.{m}.{c}.${JOINTX}".format(c=corp, m=wam)
         print("indicator_jpt:  {jptFileName}".format(jptFileName=jptFileName), file=df)
         if "indicator_jpt" in jpt_types:
            expectedFiles.add(jptFileName)

   print("EXPECTED_FILES :=", *sorted(expectedFiles), file=df)
endef

#$(info JPT: ${DEPS.PYSCRIPT})
$(shell python -c '${DEPS.PYSCRIPT}')
include .Makefile.deps


${JPT_MODEL_PFX}.${IBM4_MODEL_PFX}.%.${JOINTX}:  override L1X = ${SRC_LANG}.lc
${JPT_MODEL_PFX}.${IBM4_MODEL_PFX}.%.${JOINTX}:  override L2X = ${TGT_LANG}.lc

ifdef USE_MIXTM
%.${TUNE_MIXTM_FINAL}.${JOINTX}:  JPT_PARALLELISM_LEVEL = 1
%.${TUNE_MIXTM_FINAL}.${JOINTX}:  GEN_JPT_PARALLEL_OPTIONS =
%.${TUNE_MIXTM_FINAL}.${JOINTX}:  JPT_MODEL_TYPE =
endif  # ifdef USE_MIXTM


################################################################################
# DEBUGGING
.PHONY:  debug
debug:  jpts
