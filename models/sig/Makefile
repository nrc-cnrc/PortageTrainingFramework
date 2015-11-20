#!/usr/bin/make -f
# vim:noet:ts=3:nowrap:filetype=make

# @file Makefile
# @brief Dependencies to create Significance Pruned Joint Phrase Tables.
#
# @author Samuel Larkin
#
# Traitement multilingue de textes / Multilingual Text Processing
# Tech. de l'information et des communications / Information and Communications Tech.
# Conseil national de recherches Canada / National Research Council Canada
# Copyright 2015, Sa Majeste la Reine du Chef du Canada /
# Copyright 2015, Her Majesty in Right of Canada

SIG_DIR_PFX := $(dir $(lastword ${MAKEFILE_LIST}))

# Mandatory include: master config file.
include ${SIG_DIR_PFX}../../Makefile.params

# Include and override parameters with user specific config file.
MAKEFILE_PARAMS ?= Makefile.params
-include ${SIG_DIR_PFX}${MAKEFILE_PARAMS}

# Include the master toolkit.
include ${SIG_DIR_PFX}../../Makefile.toolkit

# Include the toolkit for building Significance Pruned JPTs.
include ${SIG_DIR_PFX}Makefile.toolkit

# What is this module's name.
MODULE_NAME ?= sig

# Where we can find the parallel corpora.
CORPORA_DIR ?= ${SIG_DIR_PFX}../../corpora

# This script might produce directory and we want to easily remove them.
RM := rm -rf

# After this Makefile, the following targets/files are precious.
FILES_TO_BE_LOCKED = sig*

# Allows to search for alignment files in corpus.
vpath %${L1X} ${CORPORA_DIR}
vpath %${L2X} ${CORPORA_DIR}
vpath %${L1}  ${CORPORA_DIR}
vpath %${L2}  ${CORPORA_DIR}

vpath %/${SRC_LANG}.lc   ${SIG_DIR_PFX}../ibm/
vpath %/${TGT_LANG}.lc   ${SIG_DIR_PFX}../ibm/

vpath ${JPT_MODEL_PFX}%  ${SIG_DIR_PFX}../jpt/


.DEFAULT_GOAL := help
.DELETE_ON_ERROR:
.SUFFIXES:
.SECONDARY:


########################################
# ALL
# Define all the work to be done.
.PHONY: all
all:  SHELL=${LOCAL_SHELL}
ifdef USE_SIGPRUNING
$(info Using Significance Pruning.)
all:  ${PT_TYPES:_cpt=_sig}
else
$(info Skipping Significance Pruning.)
all:
endif


MAIN_TARGETS :=  all clean help

$(addsuffix _model, ${POSSIBLE_WORD_ALIGNMENT_MODELS} indicator mix merged pretrained):  %_model:  %_sig
MODEL_TARGETS := $(sort $(addsuffix _model, ${POSSIBLE_WORD_ALIGNMENT_MODELS}))
MODEL_TARGETS += "\n " $(addsuffix _model, indicator mix merged pretrained)


# Nothing to be done for pretrained models.
pretrained_sig:

merged_sig:

# Dependencies are defined in the python code.
mix_sig:

# Dependencies for sub cpt are defined in the python code.
indicator_sig:


########################################
# HELP OPTIONS
.PHONY: help
help: SHELL=${LOCAL_SHELL}
help:
	@echo "Create Significance Pruned Joint Frequency Phrase Table models."
	@echo
	@echo "To train the significance pruned models, type: make all"
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
# SIGNIFICANCE PRUNING JOINT PHRASE TABLES

clean.content: clean.sig

.PHONY: clean.sig
clean.sig: SHELL=${LOCAL_SHELL}
clean.sig:
	$(RM) ${SIG_MODEL_PFX}.*  sig.cnts.${JPT_MODEL_PFX}.*
	${RM} -r JPTPAR*
	${RM} -r work_directory
	${RM} -r sigprune.sh.???

.PHONY: sigs  $(addsuffix _sig, ${POSSIBLE_WORD_ALIGNMENT_MODELS})
sigs:  SHELL=${LOCAL_SHELL}
sigs:  $(addsuffix _sig, ${POSSIBLE_WORD_ALIGNMENT_MODELS})
sigs:  merged_sig


define DEPS.PYSCRIPT
from __future__ import print_function

def corporaNames(corpora, wam, sx="${L1X}", tx="${L2X}"):
   if wam == "${IBM4_MODEL_PFX}":
      return {"s" : corpora+"/${SRC_LANG}.lc", "t":corpora+"/${TGT_LANG}.lc"}
   else:
      return {"s" : corpora+sx, "t":corpora+tx}

# To create a sigpruned jpt we need an original jpt.
# To create a sigpruned jpt we need the source and target corpora.
with open(".Makefile.deps", "w") as df:
   expectedFiles = set()

   WAMs = "${POSSIBLE_WORD_ALIGNMENT_MODELS}"
   WAMs = set(WAMs.strip().split())
   for corpora in set("${MIXTM_TRAIN_MIX} ${ALL_TMS}".strip().split()):
      for wam in WAMs:
         sigFileName = "${SIG_MODEL_PFX}.{m}.{c}.${JOINTX}".format(c=corpora, m=wam)
         print("{sigFileName}:  ${JPT_MODEL_PFX}.{m}.{c}.${JOINTX}".format(m=wam, c=corpora, sigFileName=sigFileName), file=df)
         print("{sigFileName}:  {s}  {t}".format(sigFileName=sigFileName, **corporaNames(corpora, wam)), file=df)

   WAMs = "${EXPECTED_MODEL_TYPES_PFX}"
   WAMs = set(WAMs.strip().split())
   for corpora in set("${TUNE_MIXTM_FINAL} ${MIXTM_TRAIN_MIX} ${ALL_TMS}".strip().split()):
      mergedModelFileName = "${SIG_MERGED_PFX}.{c}.${JOINTX}".format(c=corpora)
      for wam in WAMs:
         sigFileName = "${SIG_MODEL_PFX}.{m}.{c}.${JOINTX}".format(c=corpora, m=wam)
         print("{mergedModelFileName}:  {sigFileName}".format(mergedModelFileName=mergedModelFileName, sigFileName=sigFileName), file=df)

   sig_types = "${PT_TYPES:_cpt=_sig}".split()
   
   #############################################################################
   # META LEVEL TARGETS
   #####################################
   # { ibm1, ibm2, ibm4, hmm1, hmm2, hmm3, fast_align }_siq
   WAMs = "${POSSIBLE_WORD_ALIGNMENT_MODELS}"
   WAMs = set(WAMs.strip().split())
   expected_wams = "${EXPECTED_MODEL_TYPES_PFX}".split()
   for corpora in set("${TRAIN_TM}".strip().split()):
      for wam in WAMs:
         sigFileName = "${SIG_MODEL_PFX}.{m}.{c}.${JOINTX}".format(c=corpora, m=wam)
         print("{m}_sig:  {sigFileName}".format(m=wam, sigFileName=sigFileName), file=df)
	 if wam in expected_wams:
            expectedFiles.add(sigFileName)

   #####################################
   # MERGED
   for corpora in "${TRAIN_TM}".strip().split():
      mergedFileName = "${SIG_MERGED_PFX}.{c}.${JOINTX}".format(c=corpora)
      print("merged_sig:  {mergedFileName}".format(mergedFileName=mergedFileName), file=df)
      if "merged_sig" in sig_types:
         expectedFiles.add(mergedFileName)

   #####################################
   # MIXTURE
   # We build mix cpt with merged cpt thus we need merged Joint Frequency Counts.
   for corpora in "${MIX_WAMS}".strip().split():
      mergedFileName = "${SIG_MERGED_PFX}.{c}.${JOINTX}".format(c=corpora)
      print("mix_sig:  {mergedFileName}".format(mergedFileName=mergedFileName), file=df)
      if "mix_sig" in sig_types:
         expectedFiles.add(mergedFileName)

   expected_wams = "${EXPECTED_MODEL_TYPES_PFX}".split()
   for corpora in "${MIX_WAMS}".split():
      for wam in expected_wams:
         sigFileName = "${SIG_MODEL_PFX}.{m}.{c}.${JOINTX}".format(c=corpora, m=wam)
         expectedFiles.add(sigFileName)

   #####################################
   # INDICATOR
   # What is needed when the user calls indicator_wam
   indicatorWAMs = "$(foreach c, ${MERGED_CPT_JPT_TYPES}, ${${c}_MODEL_PFX})"
   indicatorWAMs = set(indicatorWAMs.strip().split())
   for corpora in "${ALL_TMS}".strip().split():
      for wam in indicatorWAMs:
         sigFileName = "${SIG_MODEL_PFX}.{m}.{c}.${JOINTX}".format(c=corpora, m=wam)
         print("indicator_sig:  {sigFileName}".format(sigFileName=sigFileName), file=df)
         if "indicator_sig" in sig_types:
            expectedFiles.add(sigFileName)

   print("EXPECTED_FILES := {}".format(" ".join(sorted(expectedFiles))), file=df)
endef

#$(info SIG: ${DEPS.PYSCRIPT})
$(shell python -c '${DEPS.PYSCRIPT}')
include .Makefile.deps

# IBM4 sigpruning
# % should match a corpora-stem
${SIG_MODEL_PFX}.${IBM4_MODEL_PFX}.%.${JOINTX}:  override L1X = ${SRC_LANG}.lc
${SIG_MODEL_PFX}.${IBM4_MODEL_PFX}.%.${JOINTX}:  override L2X = ${TGT_LANG}.lc


################################################################################
# DEBUGGING
.PHONY:  debug
debug:  sigs
