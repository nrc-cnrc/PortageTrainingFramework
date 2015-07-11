#!/usr/bin/make -f
# vim:noet:ts=3:nowrap:filetype=make
# @file Makefile
# @brief This file contains dependencies to create Joint Phrase Tables.
#
# @author Samuel Larkin
#
# Traitement multilingue de textes / Multilingual Text Processing
# Technologies de l'information et des communications /
#    Information and Communications Technologies
# Conseil national de recherches Canada / National Research Council Canada
# Copyright 2015, Sa Majeste la Reine du Chef du Canada
# Copyright 2015, Her Majesty in Right of Canada


JPT_DIR_PFX := $(dir $(lastword ${MAKEFILE_LIST}))

# Source file requirements.
# <PREFIX>_<LANGUAGE>.<LANGX>

# Mandatory include: master config file.
include ${JPT_DIR_PFX}../../Makefile.params

# Include and override parameters with user specific config file.
MAKEFILE_PARAMS ?= Makefile.params
-include ${JPT_DIR_PFX}${MAKEFILE_PARAMS}

# This is the Makefile that contains all targets required to build Translation
# Models and some variable's defintion that might be used by the user in its
# Makefile.params.
include ${JPT_DIR_PFX}Makefile.toolkit

# Lastly include the master toolkit
include ${JPT_DIR_PFX}../../Makefile.toolkit

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
vpath %/${SRC_LANG}.lc   ${JPT_DIR_PFX}../ibm/
vpath %/${TGT_LANG}.lc   ${JPT_DIR_PFX}../ibm/

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

MAIN_TARGETS :=  all  clean  help  $(addsuffix _model, ${POSSIBLE_WORD_ALIGNMENT_MODELS} indicator mix merged pretrained)
$(addsuffix _model, ${POSSIBLE_WORD_ALIGNMENT_MODELS} indicator mix merged pretrained):  %_model:  %_jpt


pretrained_jpt:  # There is no dependency for pretrained models.

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

mixWamCorpora = set("${TUNE_MIXTM_FINAL} ${MIXTM} ${MIXTM_TRAIN_MIX}".strip().split())
def which_wam(c):
   if len("${MIXTM_USE_GLOBAL_WORD_ALIGNMENT_MODEL}"):
      if c in mixWamCorpora:
         return "mixwam"
      else:
         return c
   else:
      return c

def corporaNames(corpora, wam, sx="${L1X}", tx="${L2X}"):
   if wam == "${IBM4_MODEL_PFX}":
      return {"s" : corpora+"/${SRC_LANG}.lc", "t":corpora+"/${TGT_LANG}.lc"}
   else:
      return {"s" : corpora+sx, "t":corpora+tx}

with open(".Makefile.deps", "w") as df:
   expectedFiles = set()

   # Definition of the generated makefile rules/targets:
   # the meta target jpt have a dependency on jpt file.
   # jpts require the word alignment models in both directions, this is for the -w1 option.
   # jpts require the alignment file.
   # jpts require the source and target corpora.
   WAMs = "${POSSIBLE_WORD_ALIGNMENT_MODELS}"
   WAMs = set(WAMs.strip().split())
   for corpora in set("${MIXTM_TRAIN_MIX} ${ALL_TMS}".strip().split()):
      w = which_wam(corpora)
      for wam in WAMs:
         jptFileName = "${JPT_MODEL_PFX}.{m}.{c}.${JOINTX}".format(c=corpora, m=wam)
         print("{jptFileName}:  {m}.{c}.${L2_GIVEN_L1X}  {m}.{c}.${L1_GIVEN_L2X}".format(m=wam, c=w, jptFileName=jptFileName), file=df)
         print("{jptFileName}:  {c}.{m}.${L1_2_L2}.align.gz".format(c=corpora, m=wam, jptFileName=jptFileName), file=df)
         print("{jptFileName}:  {s}  {t}".format(c=corpora, jptFileName=jptFileName, **corporaNames(corpora, wam)), file=df)

   WAMs = "${EXPECTED_MODEL_TYPES_PFX}"
   WAMs = set(WAMs.strip().split())
   for corpora in set("${MIXTM_TRAIN_MIX} ${ALL_TMS}".strip().split()):
      mergedFileName = "${JPT_MERGED_PFX}.{c}.${JOINTX}".format(c=corpora)
      for wam in WAMs:
         jptFileName = "${JPT_MODEL_PFX}.{m}.{c}.${JOINTX}".format(c=corpora, m=wam)
         print("{mergedFileName}:  {jptFileName}".format(jptFileName=jptFileName, mergedFileName=mergedFileName), file=df)

   WAMs = "${EXPECTED_MODEL_TYPES_PFX}"
   WAMs = set(WAMs.strip().split())
   for corpora in set("${TUNE_MIXTM_FINAL}".strip().split()):
      mergedFileName = "${JPT_MERGED_PFX}.{c}.${JOINTX}".format(c=corpora)
      for wam in WAMs:
         jptFileName = "${JPT_MODEL_PFX}.{m}.{c}.${JOINTX}".format(c=corpora, m=wam)
         print("{mergedFileName}:  {jptFileName}".format(mergedFileName=mergedFileName, jptFileName=jptFileName), file=df)
         print("{jptFileName}:  {c}.{m}.${L1_2_L2}.align.gz".format(m=wam, c=corpora, jptFileName=jptFileName), file=df)
         print("{jptFileName}:  {s}  {t}".format(jptFileName=jptFileName, **corporaNames(corpora, wam, "${L1}", "${L2}")), file=df)


   #############################################################################
   # META LEVEL TARGETS
   #####################################
   # { ibm1, ibm2, ibm4, hmm1, hmm2, hmm3, fast_align }_jpt
   WAMs = "${POSSIBLE_WORD_ALIGNMENT_MODELS}"
   WAMs = set(WAMs.strip().split())
   for corpora in "$(sort ${TRAIN_TM})".strip().split():
      for wam in WAMs:
         jptFileName = "${JPT_MODEL_PFX}.{m}.{c}.${JOINTX}".format(c=corpora, m=wam)
         print("{m}_jpt:  {jptFileName}".format(m=wam, jptFileName=jptFileName), file=df)
         expectedFiles.add(jptFileName)


   #####################################
   # MERGED
   for corpora in set("${TRAIN_TM}".strip().split()):
      mergedFileName = "${JPT_MERGED_PFX}.{c}.${JOINTX}".format(c=corpora)
      print("merged_jpt:  {mergedFileName}".format(mergedFileName=mergedFileName), file=df)
      expectedFiles.add(mergedFileName)


   #####################################
   # MIXTURE
   for corpora in set("${MIX_WAMS}".strip().strip().split()):
      mergedFileName = "${JPT_MERGED_PFX}.{c}.${JOINTX}".format(c=corpora)
      print("mix_jpt:  {mergedFileName}".format(mergedFileName=mergedFileName), file=df)
      expectedFiles.add(mergedFileName)


   #####################################
   # INDICATOR
   # What is needed when the user calls indicator_wam
   indicatorWAMs = "$(foreach c, ${MERGED_CPT_JPT_TYPES}, ${${c}_MODEL_PFX})"
   indicatorWAMs = set(indicatorWAMs.strip().split())
   for corpora in set("${ALL_TMS}".strip().split()):
      for wam in indicatorWAMs:
         jptFileName = "${JPT_MODEL_PFX}.{m}.{c}.${JOINTX}".format(c=corpora, m=wam)
         print("indicator_jpt:  {jptFileName}".format(jptFileName=jptFileName), file=df)
         expectedFiles.add(jptFileName)


   print("EXPECTED_FILES := {}".format(" ".join(sorted(expectedFiles))), file=df)
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
