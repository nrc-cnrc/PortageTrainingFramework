#!/usr/bin/make -f
# vim:noet:ts=3:nowrap
#
# @file Makefile
# @brief Train word classes for use by other modules
#
# @author Darlene Stewart
#
# Word classes are used by coarse LMs, coarse BiLMs, coarse TMs, and others.
#
# Traitement multilingue de textes / Multilingual Text Processing
# Tech. de l'information et des communications / Information and Communications Tech.
# Conseil national de recherches Canada / National Research Council Canada
# Copyright 2015, Sa Majeste la Reine du Chef du Canada
# Copyright 2015, Her Majesty in Right of Canada


# Mandatory include: master config file.
include ../../Makefile.params

# Include the config file.
MAKEFILE_PARAMS ?= Makefile.params
-include ${MAKEFILE_PARAMS}

# Include the master toolkit
include ../../Makefile.toolkit

# Include the wcl toolkit
include Makefile.toolkit


# What is this module's name?
MODULE_NAME ?= wcl

# What granularities should be trained?
# Multiple granularites may be trained. For example, typical choices are
# 200 & 800 for a coarse LM combo, or 400 for a single coarse LM or coarse BiLM.
WCL_NCLS_LIST ?=

# This indicates the corpus extension and looks like .tok.al.gz
CORPUS_EXT  ?= ${LANGXZ}

# Where to find the corpus' file.
CORPORA_DIR ?= ../../corpora

# After this Makefile, the following targets/files are precious.
FILES_TO_BE_LOCKED = $(addsuffix *, ${LM_NAMES})

# Where can we find the corpus' file?
vpath %${CORPUS_EXT} ${CORPORA_DIR}


.DEFAULT_GOAL := help
.DELETE_ON_ERROR:


########################################
.PHONY: help
help: SHELL=${LOCAL_SHELL}
help:
	@echo "To train word classes, type: make all"
	@echo
	@echo "The main targets in this Makefile are:"
	@cat $(firstword $(MAKEFILE_LIST)) | egrep '^.PHONY:' | sed 's#^.PHONY: #   #' | sort


########################################
.PHONY: all
all: SHELL=${LOCAL_SHELL}

# Validate that the WCL_NCLS_LIST contains numeric values
ifneq ($(shell echo ${WCL_NCLS_LIST} | egrep -v "^[0-9 ]+$$"),)
$(error Non-integer value found in WCL_NCLS_LIST: ${WCL_NCLS_LIST})
endif

# Validate that TRAIN_WCL is defined
ifeq ($(filter all, ${MAKECMDGOALS}),all)
ifeq ($(and ${TRAIN_WCL},${WCL_NCLS_LIST}),)
$(error TRAIN_WCL and WCL_NCLS_LIST must both be defined to train word classes)
endif
endif

all: $(foreach n, ${WCL_NCLS_LIST}, ${SRC_LANG}.$n.classes ${TGT_LANG}.$n.classes)

$(foreach n, ${WCL_NCLS_LIST}, \
   $(foreach l, ${SRC_LANG} ${TGT_LANG},  \
		$(eval \
			$l.$n.classes: WCL_NCLS=$n) \
		$(eval \
			$l.$n.classes: WCL_LANG=$l) \
		$(eval \
			$l.$n.classes: $(addsuffix _$l${CORPUS_EXT}, ${TRAIN_WCL})) \
	) \
)

########################################
# What the user can expect from this module.
.PHONY: list_final_output
list_final_output: SHELL=${LOCAL_SHELL}
list_final_output:
	@echo "Expected final output(s):"
	@echo -e -n "" $(foreach n, ${WCL_NCLS_LIST}, "${SRC_LANG}.$n.classes ${TGT_LANG}.$n.classes\n")


########################################
# Clean up
.PHONY: clean clean.content clean.logs hide.logs
clean: SHELL=${LOCAL_SHELL}
clean: clean.content clean.logs

clean.content: SHELL=${LOCAL_SHELL}

clean.content:
	${RM} *.classes *.classes.cats


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
# Transform the WCL model for PortageLive
PORTAGE_LIVE_DEST_DIR ?= ../portageLive/models/wcl
.PHONY: portageLive
portageLive: SHELL=${LOCAL_SHELL}
ifneq (${TRAIN_WCL},)
portageLive: $(foreach n, ${WCL_NCLS_LIST}, ${SRC_LANG}.$n.classes ${TGT_LANG}.$n.classes)
	mkdir -p ${PORTAGE_LIVE_DEST_DIR}
	${RM} -r ${PORTAGE_LIVE_DEST_DIR}/*
	cd ${PORTAGE_LIVE_DEST_DIR} && ln -fs $(addprefix ../../../wcl/, $+) .
else
portageLive:
	@echo "No word classes defined, nothing to do." >&2
endif

