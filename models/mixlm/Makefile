#!/usr/bin/make -f
# vim:noet:ts=3:nowrap:filetype=make
# $Id$

# @file Makefile
# @brief Create mixlm files.
#
# @author Samuel Larkin and Darlene Stewart
#
# Technologies langagieres interactives / Interactive Language Technologies
# Inst. de technologie de l'information / Institute for Information Technology
# Conseil national de recherches Canada / National Research Council Canada
# Copyright 2011, Sa Majeste la Reine du Chef du Canada /
# Copyright 2011, Her Majesty in Right of Canada


# Mandatory include: master config file.
include ../../Makefile.params

# Include the config file.
MAKEFILE_PARAMS ?= Makefile.params
-include ${MAKEFILE_PARAMS}

include Makefile.toolkit

# Lastly include the master toolkit
include ../../Makefile.toolkit


# What is this module's name.
MODULE_NAME ?= mixlm

# Resource monitoring.
TIME_MEM ?= time-mem

# Define LM_TOOLKIT=SRI if you want to use SRILM
# Define LM_TOOLKIT=MIT if you want to use MITLM
# Make sure all Makefiles know about it.
export LM_TOOLKIT

export ORDER ?= 5

LM_DIR ?= models/lm


$(info ln -fs ../../models)
$(shell ln -fs ../../models)

TUNE_SETS = ${TUNE_DECODE} $(addprefix ${TUNE_DECODE}, ${TUNE_DECODE_VARIANTS}) ${TUNE_RESCORE} ${TUNE_CE}

.DEFAULT_GOAL := help
.DELETE_ON_ERROR:
# We don't need to keep %.distances %.weights
#.INTERMEDIATE: components_${SRC_LANG}, components_${TGT_LANG}
.INTERMEDIATE: $(addsuffix .distances, ${TUNE_SETS})
.INTERMEDIATE: $(addsuffix .weights, ${TUNE_SETS})


# Watch out for already trained lms.
vpath %_${SRC_LANG}${LANGX} ../../corpora
vpath %_${TGT_LANG}${LANGX} ../../corpora


.PHONY: help
help: SHELL=${GUARD_SHELL}
help:
	@echo "To train your mix language models, type: make all"
	@cat $(firstword $(MAKEFILE_LIST)) | egrep '^.PHONY:' | sed 's#^.PHONY: #   #'



.PHONY: all
all: SHELL=${GUARD_SHELL}
ifdef MIXLM
all: mixlm
else
all:
	@echo "No MIXLMs defined, nothing to do."
endif



########################################
# Clean up
.PHONY: clean clean.content clean.logs hide.logs
clean: SHELL=${GUARD_SHELL}
clean: clean.content clean.logs

clean.content: SHELL=${GUARD_SHELL}
clean.content:
	${RM} components_* models
	${RM} *.distances *.weights *.mixlm 
	${RM} *.lm.gz *.binlm.gz

clean.logs: SHELL=${GUARD_SHELL}
clean.logs:
	${RM} log.*
	${RM} run-parallel-logs-*
	${RM} -r .logs

# Hide logs from user's view into .logs
hide.logs: SHELL=${GUARD_SHELL}
hide.logs: hide_logs_sub

########################################
# Resources Summary
.PHONY: time-mem
time-mem: SHELL=${GUARD_SHELL}
time-mem: resource_summary_sub

########################################


MIXLM_SRC_MODELS := $(foreach lm, ${MIXLM}, $(or $(notdir $(wildcard ${lm}_${SRC_LANG}*.binlm${GZ})), \
                                                 $(notdir $(wildcard ${LM_DIR}/${lm}_${SRC_LANG}*.binlm${GZ})), \
                                                 ${lm}_${SRC_LANG}-kn-${ORDER}g.binlm${GZ}))
                                                 
MIXLM_TGT_MODELS := $(foreach lm, ${MIXLM}, $(or $(notdir $(wildcard ${lm}_${TGT_LANG}*.binlm${GZ})), \
                                                 $(notdir $(wildcard ${LM_DIR}/${lm}_${TGT_LANG}*.binlm${GZ})), \
                                                 ${lm}_${TGT_LANG}-kn-${ORDER}g.binlm${GZ}))


.PHONY: sublm sublm.${SRC_LANG} sublm.${TGT_LANG}
sublm: sublm.${SRC_LANG}
sublm: sublm.${TGT_LANG}
sublm.${SRC_LANG}: ${MIXLM_SRC_MODELS}
sublm.${TGT_LANG}: ${MIXLM_TGT_MODELS}

# Create Language Models.
# If for some reason one of the sublm was already created in models/lm, don't
# recreate it, just link to it; otherwise build it here in the mixlm directory
# (which requires using make -f, not make -C).
${MIXLM_SRC_MODELS}: SHELL=${GUARD_SHELL}
${MIXLM_SRC_MODELS}: %.binlm${GZ}:
	[[ -s "${LM_DIR}/$@" ]] && ln -s ${LM_DIR}/$@ \
	|| ${MAKE} -f ${LM_DIR}/Makefile LM_LANG=${SRC_LANG} TRAIN_LM=$(*:_${SRC_LANG}-kn-${ORDER}g=) $@
	
${MIXLM_TGT_MODELS}: SHELL=${GUARD_SHELL}
${MIXLM_TGT_MODELS}: %.binlm${GZ}:
	[[ -s "${LM_DIR}/$@" ]] && ln -s ${LM_DIR}/$@ \
	|| ${MAKE} -f ${LM_DIR}/Makefile LM_LANG=${TGT_LANG} TRAIN_LM=$(*:_${TGT_LANG}-kn-${ORDER}g=) $@


.PHONY: mixlm
mixlm: $(addsuffix .mixlm, ${TUNE_SETS})

# Just in case, we will specify that we need the source side sub language
# models to be present before calculating the distance.
$(addsuffix .distances, ${TUNE_SETS}): %.distances: ${MIXLM_SRC_MODELS}

# Just in case, we will specify that we need the target side sub language
# models to be present before calculating the final mixlm.
$(addsuffix .mixlm, ${TUNE_SETS}): %.mixlm: ${MIXLM_TGT_MODELS}



.PHONY: portageLive
portageLive: SHELL=${GUARD_SHELL}
portageLive:
ifdef MIXLM
	@! echo "ERROR: Not supported yet!" >&2
else
	@echo "No MIXLMs defined, nothing to do." >&2
endif

