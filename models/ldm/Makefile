#!/usr/bin/make -f
# vim:noet:ts=3:nowrap

# @file Makefile.dm
# @brief Dependencies to create Lexicalized Distortion Models.
#
# @author Samuel Larkin
#
# Traitement multilingue de textes / Multilingual Text Processing
# Tech. de l'information et des communications / Information and Communications Tech.
# Conseil national de recherches Canada / National Research Council Canada
# Copyright 2010, 2015, Sa Majeste la Reine du Chef du Canada
# Copyright 2010, 2015, Her Majesty in Right of Canada

LDM_DIR_PFX := $(dir $(lastword ${MAKEFILE_LIST}))

# Mandatory include: master config file.
include ${LDM_DIR_PFX}../../Makefile.params

# Include and override parameters with user specific config file.
MAKEFILE_PARAMS ?= Makefile.params
-include ${LDM_DIR_PFX}${MAKEFILE_PARAMS}

# Include the master toolkit.
include ${LDM_DIR_PFX}../../Makefile.toolkit

# Include the toolkit for building Distortion Models.
include ${LDM_DIR_PFX}Makefile.toolkit

# What is this module's name.
MODULE_NAME ?= ldm

# Sorts the corpora in order to create dependencies in the proper order.
TRAIN_LDM  := $(sort ${TRAIN_LDM})
TRAIN_HLDM := $(sort ${TRAIN_HLDM})

# Function to sort a list of models from arbitrary order to best-first order.
sort_aligners = $(filter $1, ${POSSIBLE_WORD_ALIGNMENT_MODELS})

# Find out what the word alignment models the user asked for are,
# based on the type of conditional phrase tables that was specified.
TMP_AVAILABLE_WORD_ALIGNMENT_MODELS := $(filter-out pretrained merged indicator mix, $(PT_TYPES:_cpt=))
ifneq ($(filter pretrained merged indicator mix, $(PT_TYPES:_cpt=)),)
TMP_AVAILABLE_WORD_ALIGNMENT_MODELS += $(foreach m, ${MERGED_CPT_ZN_MODEL} ${MERGED_CPT_JPT_TYPES}, ${${m}_MODEL_PFX})
else
ifeq (${PT_TYPES},)
TMP_AVAILABLE_WORD_ALIGNMENT_MODELS += $(foreach m, ${MERGED_CPT_ZN_MODEL} ${MERGED_CPT_JPT_TYPES}, ${${m}_MODEL_PFX})
endif
endif
AVAILABLE_WORD_ALIGNMENT_MODELS := $(call sort_aligners,${TMP_AVAILABLE_WORD_ALIGNMENT_MODELS})

# For the lock target, let's specify what file we want to put read-only.
FILES_TO_BE_LOCKED = *${COUNTSX} ${LDM_MODEL_PFX}* ${HLDM_MODEL_PFX}*


# Where we can find the parallel corpora.
CORPORA_DIR ?= ${IBM_DIR_PFX}../../corpora

# Allows to search for alignment files in corpus.
vpath %${L1X} ${CORPORA_DIR}
vpath %${L2X} ${CORPORA_DIR}
vpath %${L1}  ${CORPORA_DIR}
vpath %${L2}  ${CORPORA_DIR}

vpath %/${SRC_LANG}.lc     ${LDM_DIR_PFX}../ibm/
vpath %/${TGT_LANG}.lc     ${LDM_DIR_PFX}../ibm/

# Allows to search for alignment files in corpus.
vpath %.align.gz  ${LDM_DIR_PFX}../wal/


.DEFAULT_GOAL := help
.DELETE_ON_ERROR:
.SUFFIXES:
.SECONDARY:


MAIN_TARGETS :=  all clean help

########################################
.PHONY:  all
all:


########################################
# LEXICALIZED DISTORTION MODEL.
ifdef USE_LDM
$(info Using Lexicalized Distortion Model.)
all: ldm
else
$(info Skipping Lexicalized Distortion Model.)
all:
endif

.PHONY:  ldm
ldm:

# Filtering LDMs.
ifdef LDM_FILTER_SINGLETONS
${LDM_FILE}:  LDM_FILTER_CMD=egrep -v '\|( 0)* 1( 0)* 1( 0)*$$'
endif


########################################
# HIERARCHICAL LEXICALIZED DISTORTION MODEL.
ifdef USE_HLDM
$(info Using Hierarchical Lexicalized Distortion Model.)
all:  hldm
else
$(info Skipping Hierarchical Lexicalized Distortion Model.)
all:
endif

.PHONY:  hldm
hldm:

# Filtering HLDMs.
ifdef HLDM_FILTER_SINGLETONS
${HLDM_FILE}:  LDM_FILTER_CMD=egrep -v '\|( 0)* 1( 0)* 1( 0)*$$'
endif


#################################################################################
# Dependencies
define DEPS.PYSCRIPT
from __future__ import print_function

def corporaNames(corp, wam, sx="${L1X}", tx="${L2X}"):
   if wam == "${IBM4_MODEL_PFX}":
      return {"s" : corp+"/${SRC_LANG}.lc", "t":corp+"/${TGT_LANG}.lc"}
   else:
      return {"s" : corp+sx, "t":corp+tx}

# What will we use for the LDM is description.
ldmDescription = "+".join("$(call sort_aligners,${AVAILABLE_WORD_ALIGNMENT_MODELS})".split())

expectedFiles = set()

# Lexicalized distortion model file name.
ldmFile = "${LDM_MODEL_PFX}.{name}.${L1_2_L2X}".format(name=ldmDescription)

if "${USE_LDM}":
   expectedFiles.add(ldmFile)
   expectedFiles.add(ldmFile[:-2]+"bkoff")

# Hirarchical Lexicalized distortion model file name.
hldmFile = "${HLDM_MODEL_PFX}.{name}.${L1_2_L2X}".format(name=ldmDescription)

if "${USE_HLDM}":
   expectedFiles.add(hldmFile)
   expectedFiles.add(hldmFile[:-2]+"bkoff")

# What is required to build a tpldm.
def tpldmRules(required, ldmFile):
   tpldmFile = ldmFile[:-2]+"tpldm"
   print("{tpldm}:  {ldm}".format(tpldm=tpldmFile, ldm=ldmFile), file=df)
   if required:
      print("tpldm:  {file}".format(file=tpldmFile), file=df)
      print("portageLive:  {file}".format(file=tpldmFile), file=df)

with open(".Makefile.deps", "w") as df:
   print("ldm:   {file}".format(file=ldmFile), file=df)
   print("hldm:  {file}".format(file=hldmFile), file=df)

   tpldmRules("${USE_LDM}", ldmFile)
   tpldmRules("${USE_HLDM}", hldmFile)

   # To generate (h)ldm count files we need alignment files.
   # To generate (h)ldm count files we need the source corpus and the target corpus
   for wam in set("${POSSIBLE_WORD_ALIGNMENT_MODELS}".split()):
      for corp in set("${TRAIN_LDM}".split()):
         countFilename = "${LDM_MODEL_PFX}.{w}${COUNTSX}".format(w=wam)
         alignment = "{c}.{m}.${L1_2_L2}.align.gz".format(c=corp, m=wam)
         print("{counts}:  {s}  {t}".format(counts=countFilename, **corporaNames(corp, wam)), file=df)
         print("{counts}:  {alignment}".format(counts=countFilename, alignment=alignment), file=df)

      for corp in set("${TRAIN_HLDM}".split()):
         countFilename = "${HLDM_MODEL_PFX}.{w}${COUNTSX}".format(w=wam)
         alignment = "{c}.{m}.${L1_2_L2}.align.gz".format(c=corp, m=wam)
         print("{counts}:  {s}  {t}".format(counts=countFilename, **corporaNames(corp, wam)), file=df)
         print("{counts}:  {alignment}".format(counts=countFilename, alignment=alignment), file=df)

   for wam in set("${AVAILABLE_WORD_ALIGNMENT_MODELS}".split()):
      countFilename = "${LDM_MODEL_PFX}.{w}${COUNTSX}".format(w=wam)
      print("ldm.counts:  {counts}".format(counts=countFilename), file=df)
      print("{ldmFile}:  {counts}".format(ldmFile=ldmFile, counts=countFilename), file=df)

      countFilename = "${HLDM_MODEL_PFX}.{w}${COUNTSX}".format(w=wam)
      print("hldm.counts:  {counts}".format(counts=countFilename), file=df)
      print("{hldmFile}:  {counts}".format(hldmFile=hldmFile, counts=countFilename), file=df)
   
   print("EXPECTED_FILES :=", *sorted(expectedFiles), file=df)
endef

#$(info WORD ALIGNMENT: ${DEPS.PYSCRIPT})
$(shell python -c '${DEPS.PYSCRIPT}')
include .Makefile.deps


# Pick up filtered corpora for (h)ldm models based on IBM4.
%.ibm4${COUNTSX}:  L1X := ${SRC_LANG}.lc
%.ibm4${COUNTSX}:  L2X := ${TGT_LANG}.lc


########################################
# TIGHTLY PACKED LEXICALIZED DISTORTION MODEL.
.PHONY:  tpldm

clean.content: clean.tpldm

.PHONY: clean.tpldm
clean.tpldm: SHELL=${LOCAL_SHELL}
clean.tpldm:
	${RM} -r *.tpldm


########################################
# HELP OPTIONS
.PHONY:  help
help: SHELL=${LOCAL_SHELL}
help:
	@echo "Train a (hierarchical) lexicalized distortion model."
	@echo
	@echo "To train the distortion model, type: make all"
	@echo
	@echo "See ./Makefile.params to enable custom settings."
	${HELP_LIST_MAIN_TARGETS}
	${HELP_LIST_EXPECTED_FILES}


########################################
# Clean up
.PHONY:  clean clean.content clean.logs hide.logs
clean: SHELL=${LOCAL_SHELL}
clean: clean.content clean.logs

clean.content: SHELL=${LOCAL_SHELL}
clean.content:
	${RM} *${COUNTSX} *${L1_2_L2X} *.bkoff
	${RM} -r parallelize.pl.*

clean.logs: SHELL=${LOCAL_SHELL}
clean.logs:
	$(RM) run-parallel-log* log.* sort??????
	${RM} -r .logs run-p.*
	${RM} .Makefile*.deps

# Hide logs from user's view into .logs
hide.logs: SHELL=${LOCAL_SHELL}
hide.logs: hide_logs_sub


########################################
# Resources Summary
.PHONY:  time-mem
time-mem: SHELL=${LOCAL_SHELL}
time-mem: resource_summary_sub

MAIN_TARGETS += time-mem


########################################
# What is needed for PortageLive.
PORTAGE_LIVE_DEST_DIR ?= ../portageLive/models/ldm

.PHONY:  portageLive  portagelive  PortageLive
portagelive:  portageLive
PortageLive:  portageLive


ifneq ("", "${USE_LDM}${USE_HLDM}")
portageLive:
	mkdir --parents ${PORTAGE_LIVE_DEST_DIR}
	${RM} -r ${PORTAGE_LIVE_DEST_DIR}/*
	cd ${PORTAGE_LIVE_DEST_DIR} && ln -fs $(addprefix ../../../ldm/, $+) .
else
portageLive:
	@echo "Not using a lexicalized distortion model, so nothing to do for portageLive." >&2
endif

MAIN_TARGETS += portageLive



################################################################################
# UNITTESTS.

########################################
# Creating Lexicalized Distortion Models with IBM4 models require special
# attention to which corpora get picked up.  Make sure we pick up the proper
# filtered corpora and that the count file is properly created.
.PHONY: unittest1
unittest1: export PT_TYPES=ibm4_cpt hmm3_cpt
unittest1: export USE_LDM=1
unittest1: export AVAILABLE_WORD_ALIGNMENT_MODELS=ibm4 hmm3
unittest1: export TRAIN_LDM=tm-train sublm1
unittest1:
	${MAKE} -C ../../corpora all
	${MAKE} -C ../ibm all
	${MAKE} -C ../wal all
	${MAKE} all
	@ [[ `find -name ${LDM_MODEL_PFX}.hmm3${COUNTSX} -size +21c | \wc -l` -eq 1 ]] \
	|| ! echo "ERROR: failed to generate hmm3 count file." >&2
	@ [[ `find -name ${LDM_MODEL_PFX}.ibm4${COUNTSX} -size +21c | \wc -l` -eq 1 ]] \
	|| ! echo "ERROR: failed to generate ibm4 count file." >&2
	@ [[ `find -name ${LDM_MODEL_PFX}.ibm4+hmm3.${L1_2_L2X} -size +21c | \wc -l` -eq 1 ]] \
	|| ! echo "ERROR: failed to generate lexicalized distortion model file." >&2

