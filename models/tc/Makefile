#!/usr/bin/make -f
# vim:noet:ts=3:nowrap
#
# $Id$
# @author Samuel Larkin with modifications by Darlene Stewart
# @file Makefile
# @brief Trains a truecasing model.
#
# Technologies langagieres interactives / Interactive Language Technologies
# Inst. de technologie de l'information / Institute for Information Technology
# Conseil national de recherches Canada / National Research Council Canada
# Copyright 2008, 2011, Sa Majeste la Reine du Chef du Canada
# Copyright 2008, 2011, Her Majesty in Right of Canada


# Mandatory include: master config file.
include ../../Makefile.params

# Include the config file.
MAKEFILE_PARAMS ?= Makefile.params
-include ${MAKEFILE_PARAMS}

# Lastly include the master toolkit
include ../../Makefile.toolkit


# What is this module's name.
MODULE_NAME ?= tc

# Where to find the corpus' file.
CORPORA_DIR ?= ../../corpora

# Define LM_TOOLKIT=SRI if you want to use SRILM
# Define LM_TOOLKIT=MIT if you want to use MITLM
# Make sure all Makefiles know about it.
export LM_TOOLKIT

# Typical lms for truecasing are 3g.
export ORDER = 3

ENCODING ?= UTF-8
# What commands to use for sentence splitting (using tokenize) and lowercasing.
ifneq ($(findstring ${ENCODING}, UTF-8 UTF8 utf-8 utf8),)
   TOKENIZE ?= utokenize.pl
   LOWERCASE ?= $(if $(findstring $(flavor ICU), undefined), lc-utf8.pl, utf8_casemap -c l)
else
   TOKENIZE ?= tokenize.pl
   LOWERCASE ?= lc-latin.pl
endif

# For truecasing, we are going to use the same train_lm corpus but in its
# truecased form.  This can be done by simply tell lm/Makefile that our corpus
# extension is now .tc.gz.
TCX = .tc${GZ}
#export CORPUS_EXT = ${TCX}

# Source corpora extension
ifneq ($(wildcard ${CORPORA_DIR}/$(TRUECASING_NC1_SRC_LM:.nc1.binlm${GZ}=${ALIGNX}${GZ})),)
SCX = ${ALIGNX}${GZ}
else
SCX = ${ALIGNX}
endif

# After this Makefile, the following targets/files are precious.
FILES_TO_BE_LOCKED = ${TRUECASING_MAP} ${TRUECASING_LM} ${TRUECASING_NC1_SRC_LM} ${TRAIN_LM}*

# Resource monitoring.
TIME_MEM ?= time-mem


# Where can we find the corpora?
vpath %${TCX} ${CORPORA_DIR}
vpath %${LANGXZ} ${CORPORA_DIR}
vpath %${SCX} ${CORPORA_DIR}



.DEFAULT_GOAL := help
.DELETE_ON_ERROR:
#.INTERMEDIATE: ${TRAIN_LM}_${TGT_LANG}.marked.gz
.SECONDARY:



.PHONY: help
help: SHELL=${GUARD_SHELL}
help:
	@echo "Train a language model and a map for truecasing."
	@echo
	@echo "In Makefile.params, define LM_TOOLKIT=SRI, LM_TOOLKIT=MIT" \
	      "or LM_TOOLKIT=IRST to specify the LM toolkit to use."
	@echo "Your truecasing corpus is: ${TRAIN_LM}_${TGT_LANG}${TCX}"
	@echo
	@echo "To train your truecasing model, type: make all"
	@echo
	@echo "The main targets in this Makefile are:"
	@cat $(firstword $(MAKEFILE_LIST)) | egrep '^.PHONY:' | sed 's#^.PHONY: #   #'


.PHONY: all
all: SHELL=${GUARD_SHELL}
ifdef DO_TRUECASING
all: ${TRUECASING_MAP}
all: ${TRUECASING_LM}
ifdef TC_USE_SRC_MODELS
all: ${TRUECASING_NC1_SRC_LM}
endif
else
all:
	@echo "Nothing to do, user asked not to do truecasing." >&2
endif



# What the user can expect from this module.
.PHONY: list_final_output
list_final_output: SHELL=${GUARD_SHELL}
list_final_output:
	@echo "Expected final output(s):"
	@echo "${TRUECASING_LM}"
	@echo "${TRUECASING_MAP}"
	@echo "${TRUECASING_NC1_SRC_LM}"


########################################
# Clean up
.PHONY: clean clean.content clean.map clean.logs hide.logs
clean: SHELL=${GUARD_SHELL}
clean: clean.content clean.logs

clean.content: SHELL=${GUARD_SHELL}
clean.content: lm-clean.content clean.map
	${RM} *.{tokss,revtokss,nc1}${GZ}

clean.map: SHELL=${GUARD_SHELL}
clean.map:
	${RM} -r *.map *.map.tppt vocabMap2tpt.*

lm-clean.content lm-clean.logs: SHELL=${GUARD_SHELL}
lm-clean.content lm-clean.logs: lm-%:
	${MAKE} -f ../lm/Makefile CORPUS_EXT=${TCX} $*

clean.logs: SHELL=${GUARD_SHELL}
clean.logs: lm-clean.logs
	${RM} log.* run-parallel-logs*

# Hide logs from user's view into .logs
hide.logs: SHELL=${GUARD_SHELL}
hide.logs: hide_logs_sub


########################################
# Resources Summary
.PHONY: time-mem
time-mem: SHELL=${GUARD_SHELL}
time-mem: resource_summary_sub


########################################
# portageLive easy target.
PORTAGE_LIVE_DEST_DIR ?= ../portageLive/models/tc
.PHONY: portageLive
portageLive: SHELL=${GUARD_SHELL}
portageLive: ${TRUECASING_MAP}.tppt
portageLive: ${TRAIN_TC}_${TGT_LANG}-kn-3g.tplm
ifdef TC_USE_SRC_MODELS
portageLive: ${TRAIN_TC}_${SRC_LANG}.nc1.tplm
endif
portageLive:
	mkdir -p ${PORTAGE_LIVE_DEST_DIR}
	${RM} -r ${PORTAGE_LIVE_DEST_DIR}/*
	cd ${PORTAGE_LIVE_DEST_DIR} && ln -fs ../../../tc/$(filter %.tppt, $+) tc-map.${TGT_LANG}.tppt
	cd ${PORTAGE_LIVE_DEST_DIR} && ln -fs ../../../tc/$(filter %3g.tplm, $+) tc-lm.${TGT_LANG}.tplm
ifdef TC_USE_SRC_MODELS
	cd ${PORTAGE_LIVE_DEST_DIR} && ln -fs ../../../tc/$(filter %nc1.tplm, $+) nc1-lm.${SRC_LANG}.tplm
endif


########################################
# Build a truecase target language model.
# If running the old truecasing workflow using target language models only,
# then only Step 5 below is done.
# If running the new truecasing workflow using source language information in
# addition to target language models, then Steps 1-5 are done.
# The makefile in models/lm is used for building all language models.
.PHONY: lm
lm: SHELL=${GUARD_SHELL}
lm: ${TRUECASING_LM}

CORPUS_SHELL ?= $(if $(findstring $(flavor BIG_CORPUS), undefined), ${FRAMEWORK_SHELL}, ${GUARD_SHELL})

# Step 1: Filter out all-uppercase sentences and sentence split the target language corpus.
TGT_UC_FILTER ?= perl -ne 'use encoding "${ENCODING}"; s/^[^[:lower:]]+$$/\n/; print $$_ unless /^$$/;'
TGT_TOKENIZE = ${TOKENIZE} -pretok -paraline -ss -p -lang=${TGT_LANG}

%_${TGT_LANG}.tokss${GZ}: SHELL=${CORPUS_SHELL}
%_${TGT_LANG}.tokss${GZ}: %_${TGT_LANG}${TCX}
ifndef BIG_CORPUS
	RP_PSUB_OPTS="-1" \
	set -o pipefail; \
	zcat -f $+ \
	| ${TGT_UC_FILTER} \
	| ${TIME_MEM} \
	${TGT_TOKENIZE} 2> log.$(basename $@) \
	| gzip \
	> $@
else
	parallelize.pl -nolocal -psub -1 \
		-w ${MINIMUM_PARALLEL_CHUNK_SIZE} -n ${PARALLELISM_LEVEL_CORPORA} \
		"(${TGT_UC_FILTER} | ${TGT_TOKENIZE}) < $< > $@  2> log.$(basename $@)"
endif

# Step 2: Reverse the sentences and filter the initial words in the uppercase-filtered target language corpus.
%.revtokss${GZ}: SHELL=${CORPUS_SHELL}
%.revtokss${GZ}: %.tokss${GZ}
ifndef BIG_CORPUS
	RP_PSUB_OPTS="-1" \
	set -o pipefail; \
	zcat -f $+ \
	| filter-nc1.py -enc ${ENCODING}\
	| reverse.pl \
	| gzip \
	> $@
else
	parallelize.pl -nolocal -psub -1 \
		-w ${MINIMUM_PARALLEL_CHUNK_SIZE} -n ${PARALLELISM_LEVEL_CORPORA} \
		"(filter-nc1.py | reverse.pl) < $< > $@"
endif

# Step 3: Build an NC1 target language model to use for normalizing BOS case.
%_${TGT_LANG}.nc1.binlm${GZ}: SHELL=${GUARD_SHELL}
%_${TGT_LANG}.nc1.binlm${GZ}: %_${TGT_LANG}.revtokss${GZ}
	${MAKE} -f ../lm/Makefile CORPUS_EXT=.revtokss${GZ} CORPORA_DIR=../tc LM_DESC=.nc1 $@

# Step 4: Normalize the beginning-of-sentence case in the target language corpus.
NORMC1_OPTS ?= -ignore 1 -extended -notitle
UN_SS_P := perl -pe 's/(.)$$/$$1 /; s/(.)\n/$$1/'

%_${TGT_LANG}.nc1${GZ}: SHELL=${FRAMEWORK_SHELL}
%_${TGT_LANG}.nc1${GZ}: %_${TGT_LANG}.nc1.binlm${GZ} %_${TGT_LANG}.tokss${GZ}
	RP_PSUB_OPTS="-1" \
	set -o pipefail; \
	${TIME_MEM} \
	normc1 ${NORMC1_OPTS} -loc ${TGT_LANG}_CA.${ENCODING} $+ 2> log.$(basename $@) \
	| ${UN_SS_P} \
	| gzip \
	> $@

# Step 5: Build the truecase target language model from the BOS-normalized,
# uppercase-filtered target language corpus (or original target language
# corpus if not using source language info too).
%_${TGT_LANG}-kn-3g.binlm.gz: SHELL=${GUARD_SHELL}
ifdef TC_USE_SRC_MODELS
%_${TGT_LANG}-kn-3g.binlm.gz: %_${TGT_LANG}.nc1${GZ}
	${MAKE} -f ../lm/Makefile CORPUS_EXT=.nc1${GZ} CORPORA_DIR=../tc $@
else
%_${TGT_LANG}-kn-3g.binlm.gz:
	${MAKE} -f ../lm/Makefile CORPUS_EXT=${TCX} $@
endif

%.tplm: SHELL=${GUARD_SHELL}
%.tplm:
	${MAKE} -f ../lm/Makefile CORPUS_EXT=${TCX} $@


########################################
# Build an NC1 source language model for use with the new truecasing workflow.
# An NC1 LM is used for normalizing the beginning-of-sentence (BOS) case.

.PHONY: nc1_lm
nc1_lm: SHELL=${GUARD_SHELL}
nc1_lm: ${TRUECASING_NC1_SRC_LM}

SRC_UC_FILTER ?= perl -pe 'use encoding "${ENCODING}"; s/^[^[:lower:]]+($$|( : ))//;'
SRC_TOKENIZE = ${TOKENIZE} -pretok -paraline -ss -lang=${SRC_LANG}

%_${SRC_LANG}.tokss${GZ}: SHELL=${CORPUS_SHELL}
%_${SRC_LANG}.tokss${GZ}: %_${SRC_LANG}${SCX}
ifndef BIG_CORPUS
	RP_PSUB_OPTS="-1" \
	set -o pipefail; \
	zcat -f $< \
	| ${TIME_MEM} \
	${SRC_TOKENIZE} 2> log.$(basename $@) \
	| ${SRC_UC_FILTER} \
	| gzip \
	> $@
else
	parallelize.pl -nolocal -psub -1 \
		-w ${MINIMUM_PARALLEL_CHUNK_SIZE} -n ${PARALLELISM_LEVEL_CORPORA} \
		"(${SRC_TOKENIZE} | ${SRC_UC_FILTER}) < $< > $@  2> log.$(basename $@)"
endif

%_${SRC_LANG}.nc1.binlm${GZ}: SHELL=${GUARD_SHELL}
%_${SRC_LANG}.nc1.binlm${GZ}: %_${SRC_LANG}.revtokss${GZ}
	${MAKE} -f ../lm/Makefile CORPUS_EXT=.revtokss${GZ} CORPORA_DIR=../tc LM_DESC=.nc1 LM_LANG=${SRC_LANG} $@


########################################
# Build a map file.
.PHONY: map
map: SHELL=${GUARD_SHELL}
map: ${TRUECASING_MAP}

%.map: SHELL=${FRAMEWORK_SHELL}
ifdef TC_USE_SRC_MODELS
%.map: %.nc1${GZ}
	RP_PSUB_OPTS="-1" \
	set -o pipefail; \
	zcat -f $< \
	| ${LOWERCASE} \
	| ${TIME_MEM} compile_truecase_map $< - 2> log.$@ \
	> $@
else
%.map: %${TCX} %${LANGXZ}
	RP_PSUB_OPTS="-1" \
	${TIME_MEM} \
	compile_truecase_map $+ 2> log.$@ \
	> $@
endif

%.map.tppt: SHELL=${FRAMEWORK_SHELL}
%.map.tppt: %.map
	RP_PSUB_OPTS="-1" \
	${TIME_MEM} \
	vocabMap2tpt.sh $< 2> log.$@

