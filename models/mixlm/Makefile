#!/usr/bin/make -f
# vim:noet:ts=3:nowrap:filetype=make
# $Id$

# @file Makefile
# @brief Create mixlm files.
#
# @author Samuel Larkin
#
# Technologies langagieres interactives / Interactive Language Technologies
# Inst. de technologie de l'information / Institute for Information Technology
# Conseil national de recherches Canada / National Research Council Canada
# Copyright 2010, Sa Majeste la Reine du Chef du Canada /
# Copyright 2010, Her Majesty in Right of Canada


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

# Define LM_TOOLKIT=SRI if you want to use SRILM
# Define LM_TOOLKIT=MIT if you want to use MITLM
# Make sure all Makefile knows about it.
export LM_TOOLKIT

# Typical lms for truecasing are 3g.
export ORDER ?= 5

LM_DIR ?= models/lm


$(shell ln -fs ../../models)


.DEFAULT_GOAL := help
.DELETE_ON_ERROR:
# We actually want to get ride off %.distances %.weights
.INTERMEDIATE: components
.INTERMEDIATE: $(addsuffix .distances, ${TUNE_DECODE} ${TUNE_RESCORE} ${TUNE_CE})
.INTERMEDIATE: $(addsuffix .weights, ${TUNE_DECODE} ${TUNE_RESCORE} ${TUNE_CE})



# Watch out for already trained lms.
vpath %_${SRC_LANG}${LANGX} ../../corpora
vpath %_${TGT_LANG}${LANGX} ../../corpora


SHELL = ${GUARD_SHELL}

.PHONY: help
help: SHELL=${GUARD_SHELL}
help:
	@echo "To train your mix language models, type: make all"
	@cat $(firstword $(MAKEFILE_LIST)) | egrep '^.PHONY:' | sed 's#^.PHONY: #   #'



.PHONY: all
ifdef MIXLM
all: sublm
all: mixlm
else
all:
	@echo "Nothing to do, no mixlm were defined."
endif



########################################
# Clean up
.PHONY: clean clean.content clean.logs hide.logs
clean: SHELL=${GUARD_SHELL}
clean: clean.content clean.logs

clean.content: SHELL=${GUARD_SHELL}
clean.content:
	${RM} components models
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



.PHONY: sublm
sublm: sublm.${SRC_LANG}
sublm: sublm.${TGT_LANG}
sublm.${SRC_LANG}: $(addsuffix _${SRC_LANG}-kn-${ORDER}g.binlm${GZ}, ${MIXLM})
sublm.${TGT_LANG}: $(addsuffix _${TGT_LANG}-kn-${ORDER}g.binlm${GZ}, ${MIXLM})

# Create Language Models.
# If for some reason one of the sublm is already create in models/lm, don't
# recreate it, just link to it.
%_${SRC_LANG}-kn-${ORDER}g.binlm${GZ}:
	[[ -s "${LM_DIR}/$(notdir $@)" ]] \
	&& ln -s ${LM_DIR}/$(notdir $@) \
	|| ${MAKE} -f ${LM_DIR}/Makefile LM_LANG=${SRC_LANG} TRAIN_LM=$* $(notdir $@)
	
%_${TGT_LANG}-kn-${ORDER}g.binlm${GZ}:
	[[ -s "${LM_DIR}/$(notdir $@)" ]] \
	&& ln -s ${LM_DIR}/$(notdir $@) \
	|| ${MAKE} -f ${LM_DIR}/Makefile LM_LANG=${TGT_LANG} TRAIN_LM=$* $(notdir $@)



.PHONY: mixlm
mixlm: $(addsuffix .mixlm, ${TUNE_DECODE} ${TUNE_RESCORE} ${TUNE_CE})


# Just in case, we will specify that we need the source side sub language
# models to be present before calculating the distance.
$(addsuffix .distances, ${TUNE_DECODE} ${TUNE_RESCORE} ${TUNE_CE}): %.distances: $(addsuffix _${SRC_LANG}-kn-5g.binlm${GZ}, ${MIXLM})


# Just in case, we will specify that we need the target side sub language
# models to be present before calculating the final mixlm.
$(addsuffix .mixlm, ${TUNE_DECODE} ${TUNE_RESCORE} ${TUNE_CE}): %.mixlm: $(addsuffix _${TGT_LANG}-kn-5g.binlm${GZ}, ${MIXLM})



.PHONY: portageLive
portageLive: SHELL=${GUARD_SHELL}
portageLive:
ifdef MIXLM
	@! echo "ERROR: Not supported yet!" >&2
else
	@echo "No MIXLM define, nothing to do." >&2
endif

