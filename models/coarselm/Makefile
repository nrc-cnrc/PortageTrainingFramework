#!/usr/bin/make -f
# vim:noet:ts=3:nowrap

# @file Makefile
# @brief Train coarse language model files.
#
# @author Darlene Stewart
#
# Traitement multilingue de textes / Multilingual Text Processing
# Tech. de l'information et des communications / Information and Communications Tech.
# Conseil national de recherches Canada / National Research Council Canada
# Copyright 2015, Sa Majeste la Reine du Chef du Canada
# Copyright 2015, Her Majesty in Right of Canada

# Mandatory include: master config file.
include ../../Makefile.params

# Include and override parameters with user specific config file.
MAKEFILE_PARAMS ?= Makefile.params
-include ${MAKEFILE_PARAMS}

# Include the master toolkit.
include ../../Makefile.toolkit

# Override the default SMOOTHER setting in the LM Makefile.toolkit
# For coarse LMs, we must use unmodified Kneser-Ney smoothing with MITLM or
# Witten-Bell smoothing with SRILM.
ifeq (${LM_TOOLKIT}, MIT)
SMOOTHER ?= ukn
else ifeq (${LM_TOOLKIT}, SRI)
SMOOTHER ?= wb
else
$(error LM Toolkit for building coarse LMs must be MIT or SRI; invalid LM toolkit: ${LM_TOOLKIT})
endif

# Override the default LM ORDER setting in the LM Makefile.toolkit
# What is the order of the coarse LM?
# Typically we use a higher order for coarse LMs than for regular word-based LMs.
ORDER ?= 8

# Include the LM toolkit.
include ../lm/Makefile.toolkit

# What is this module's name?
MODULE_NAME ?= coarselm

# What is the lm language.
LM_LANG ?= ${TGT_LANG}

# What word class granularities should be used for the coarse LM(s)?
# Multiple coarse LMs with different granularites may be trained. For example,
# a typical choice is 200 & 800 for a coarse LM combo.
COARSELM_NCLS_LIST ?=

# What type of LMs to build
# For coarse LMs, valid LM types are:
#    arpa binlm tplm
LM_TYPES ?= binlm

# We must create tplm for tuning.
LM_TYPES := $(sort ${LM_TYPES} tplm)

# What are the corpora names and extension and what files define these corpora.
CORPORA_NAMES ?= $(foreach n, ${COARSELM_NCLS_LIST}, $(addsuffix _${LM_LANG}-$n, ${TRAIN_COARSELM}))

# This indicates the corpus extension and looks like .tok.al.gz
CORPUS_EXT  ?= ${LANGXZ}

LM_DESC ?= -${SMOOTHER}-${ORDER}g
LM_NAMES ?= $(addsuffix ${LM_DESC}, ${CORPORA_NAMES})

# Where to find the corpus' file.
CORPORA_DIR ?= ../../corpora

# After this Makefile, the following targets/files are precious.
FILES_TO_BE_LOCKED = $(addsuffix *, ${LM_NAMES})


# By default, locate corpora files in the corpora directory.
vpath %${CORPUS_EXT} ${CORPORA_DIR}
vpath %${CORPUS_EXT:.gz=} ${CORPORA_DIR}

# Locate the classes files in the wcl module
vpath %.classes ../wcl


.DEFAULT_GOAL := help
.SECONDARY:
.SUFFIXES:
.DELETE_ON_ERROR:


MAIN_TARGETS :=  all clean help

########################################
.PHONY: help
help: SHELL=${LOCAL_SHELL}
help:
	${HELP_LM_TOOLKIT_2}
	@echo "In Makefile.params, define USE_COARSELM to enable coarse LM training."
	@echo "Also, define COARSELM_NCLS_LIST to specify different word class granularities to use."
	@echo
	@echo "To train the coarse language models, type: make all"
	${HELP_LIST_MAIN_TARGETS}
	${HELP_LIST_EXPECTED_FILES}


########################################
.PHONY: all
all: SHELL=${LOCAL_SHELL}

LM_EXTS =
LM_EXTS += $(if $(findstring arpa, ${LM_TYPES}),.lm.gz)
LM_EXTS += $(if $(findstring binlm, ${LM_TYPES}),.binlm.gz)
LM_EXTS += $(if $(findstring tplm, ${LM_TYPES}),.tplm)

VALID_LM_TYPES := arpa binlm tplm

ifneq ($(filter-out ${VALID_LM_TYPES}, ${LM_TYPES}),)
$(error Invalid LM_TYPES: $(filter-out ${VALID_LM_TYPES}, ${LM_TYPES}))
endif

EXPECTED_FILES = $(foreach x, ${LM_EXTS}, $(addsuffix $x, ${LM_NAMES}))

all: ${EXPECTED_FILES}

# Corpus dependencies for Coarse LM files.
$(foreach c, ${CORPORA_NAMES}, \
   $(eval $(call LM_CORP_DEP,${c}${LM_DESC},${c}${CORPUS_EXT})))

# Rules for creating files with corpus text mapped to word classes
$(foreach n, ${COARSELM_NCLS_LIST}, \
	$(foreach c, ${TRAIN_COARSELM}, \
		$(eval \
			${c}_${LM_LANG}-${n}${CORPUS_EXT}: ${c}_${LM_LANG}${CORPUS_EXT} ${LM_LANG}.${n}.classes) \
	) \
)

CORP_FILES = $(foreach c, ${CORPORA_NAMES}, ${c}${CORPUS_EXT})
.INTERMEDIATE: ${CORP_FILES}
${CORP_FILES}: SHELL=${LOCAL_SHELL}
${CORP_FILES}: %${CORPUS_EXT}:
	word2class -no-error $(filter %${CORPUS_EXT}, $+) $(filter %.classes, $+) | gzip > $@

# If tuning the discount parameters, we need to map the dev set to word classes too.
ifeq (${LM_TOOLKIT}, MIT)
ifdef TUNE_COARSELM
$(foreach n, ${COARSELM_NCLS_LIST}, \
	$(eval \
		${TUNE_COARSELM}-${n}_${LM_LANG}${CORPUS_EXT:.gz=}:  ${TUNE_COARSELM}_${LM_LANG}${CORPUS_EXT:.gz=}  ${LM_LANG}.${n}.classes) \
)

TUNE_FILES = $(foreach n, ${COARSELM_NCLS_LIST}, ${TUNE_COARSELM}-${n}_${LM_LANG}${CORPUS_EXT:.gz=})
.INTERMEDIATE: ${TUNE_FILES}
${TUNE_FILES}: SHELL=${LOCAL_SHELL}
${TUNE_FILES}: %${CORPUS_EXT:.gz=}:
	word2class -no-error $(filter %${CORPUS_EXT:.gz=}, $+) $(filter %.classes, $+) > $@

# We also add a dependency on the mapped dev set for tuning the discount parameters.
$(foreach n, ${COARSELM_NCLS_LIST}, \
	$(foreach c, ${TRAIN_COARSELM}, \
		$(eval \
			${c}_${LM_LANG}-${n}${LM_DESC}.lm.gz:  ${TUNE_COARSELM}-${n}_${LM_LANG}${CORPUS_EXT:.gz=}) \
	) \
)
endif
endif


########################################
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

clean.content:
	${RM} *.lm.gz *.binlm.gz
	${RM} $(foreach n, ${COARSELM_NCLS_LIST}, *-${n}${CORPUS_EXT} *-${n}_*${CORPUS_EXT:.gz=})
	${RM} -r *.tplm
	${RM} -r *.tmp.???


clean.logs: SHELL=${LOCAL_SHELL}
clean.logs:
	${RM} log.*
	${RM} run-parallel-logs-*
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


########################################
# Transform the coarse LM model(s) for PortageLive
PORTAGE_LIVE_DEST_DIR ?= ../portageLive/models/coarselm
.PHONY: portageLive
portageLive: SHELL=${LOCAL_SHELL}
ifneq (${TRAIN_COARSELM},)
portageLive: $(addsuffix .tplm, ${LM_NAMES})
	mkdir --parents ${PORTAGE_LIVE_DEST_DIR}
	${RM} -r ${PORTAGE_LIVE_DEST_DIR}/*
	cd ${PORTAGE_LIVE_DEST_DIR} && ln -fs $(addprefix ../../../coarselm/, $+) .
else
portageLive:
	@echo "No coarse LMs defined, so nothing to do for portageLive." >&2
endif

MAIN_TARGETS += portageLive



################################################################################
# TESTSUITE

.PHONY: testsuite

.PHONY:  tplm.testcase
testsuite:  tplm.testcase
tplm.testcase:  export TRAIN_COARSELM := coarselm-train
tplm.testcase:  export COARSELM_NCLS_LIST := 200 800
tplm.testcase:  export SHELL := bash
tplm.testcase:
	echo "TESTCASE:  $@"
	${MAKE} clean &> /dev/null
	${MAKE} -C ../wcl all
	time ${MAKE} -j 11 ${TESTCASE_OPTS} all
	[[ `\ls -d coarselm-train_fr-{200,800}-ukn-8g.tplm | \wc -l` -eq 2 ]] || ! echo "$* should produce 2 tplm [200, 800]" >&2
