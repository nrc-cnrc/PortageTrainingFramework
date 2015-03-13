#!/usr/bin/make -f
# vim:noet:ts=3:nowrap
#
# @author Darlene Stewart
# @file Makefile
# @brief Train coarse language model files.
#
# Traitement multilingue de textes / Multilingual Text Processing
# Tech. de l'information et des communications / Information and Communications Tech.
# Conseil national de recherches Canada / National Research Council Canada
# Copyright 2015 Sa Majeste la Reine du Chef du Canada
# Copyright 2015 Her Majesty in Right of Canada

# Mandatory include: master config file.
include ../../Makefile.params

# Include the config file.
MAKEFILE_PARAMS ?= Makefile.params
-include ${MAKEFILE_PARAMS}

# Include the master toolkit
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

# Include the LM toolkit
include ../lm/Makefile.toolkit


# What is this module's name?
MODULE_NAME ?= coarselm

# The following variables are defined in Makefile.toolkit included above:
#    LM_LANG, CORPUS_EXT, LM_DESC
# Their default definitions are repeated below for documentation.

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


# Tells make where to find the corpus' file and the marked file if need be.
vpath %${CORPUS_EXT} ${CORPORA_DIR}

# Locate the classes files in the wcl module
vpath %.classes ../wcl


.DEFAULT_GOAL := help
.DELETE_ON_ERROR:


########################################
.PHONY: help
help: SHELL=${LOCAL_SHELL}
help:
	@echo "In Makefile.params, define LM_TOOLKIT=SRI, LM_TOOLKIT=MIT" \
	      "to specify the LM toolkit to use."
	@echo "Also in Makefile.params, define COARSELM_NCLS_LIST to specify" \
	      "the word class granularities to use."
	@echo
	@echo "To train your coarse language models, type: make all"
	@echo
	@echo "The main targets in this Makefile are:"
	@cat $(firstword $(MAKEFILE_LIST)) | egrep '^.PHONY:' | sed 's#^.PHONY: #   #' | sort


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

all: $(foreach x, ${LM_EXTS}, $(addsuffix $x, ${LM_NAMES}))

# Rules for creating files with corpus text mapped to word classes
$(foreach n, ${COARSELM_NCLS_LIST}, \
	$(foreach c, ${TRAIN_COARSELM}, \
		$(eval \
			${c}_${LM_LANG}-${n}${CORPUS_EXT}: ${c}_${LM_LANG}${CORPUS_EXT} ${LM_LANG}.${n}.classes) \
	) \
)

%${CORPUS_EXT}:
	word2class $(filter %${CORPUS_EXT}, $+) $(filter %.classes, $+) | gzip > $@

########################################
# What the user can expect from this module.
.PHONY: list_final_output
list_final_output: SHELL=${LOCAL_SHELL}
list_final_output:
	@echo "Expected final output(s):"
	@echo "$(foreach x, ${LM_EXTS}, $(addsuffix $x, ${LM_NAMES}))"


########################################
# Clean up
.PHONY: clean clean.content clean.logs hide.logs
clean: SHELL=${LOCAL_SHELL}
clean: clean.content clean.logs

clean.content: SHELL=${LOCAL_SHELL}

clean.content:
	${RM} *.lm.gz *.binlm.gz
	${RM} -r *.tplm


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


########################################
# Transform the coarse LM model for PortageLive
PORTAGE_LIVE_DEST_DIR ?= ../portageLive/models/coarselm
.PHONY: portageLive
portageLive: SHELL=${LOCAL_SHELL}
ifneq (${TRAIN_COARSELM},)
portageLive: $(addsuffix .tplm, ${LM_NAMES})
	mkdir -p ${PORTAGE_LIVE_DEST_DIR}
	${RM} -r ${PORTAGE_LIVE_DEST_DIR}/*
	cd ${PORTAGE_LIVE_DEST_DIR} && ln -fs $(addprefix ../../../coarselm/, $+) .
else
portageLive:
	@echo "No coarse LMs defined, nothing to do." >&2
endif
