#!/usr/bin/make -f
# vim:noet:ts=3:nowrap:filetype=make
# $Id$

# @file Makefile
# @brief Create mixlm files.
#
# @author Samuel Larkin
#
# Technologies langagieres interactives / Interactive Language Technologiesm
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
.INTERMEDIATE: components $(addsuffix .distances, ${TUNE_DECODE} ${TUNE_RESCORE} ${TUNE_CE})



# Watch out for already trained lms.
vpath %_${SRC_LANG}${LANGX} ../../corpora
vpath %_${TGT_LANG}${LANGX} ../../corpora


SHELL = ${GUARD_SHELL}

.PHONY: help
help: SHELL=${GUARD_SHELL}
help:
	@echo "To train your language models, type: make all"
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
sublm: _sublm.${SRC_LANG}
sublm: _sublm.${TGT_LANG}
_sublm.${SRC_LANG}: $(addsuffix _${SRC_LANG}-kn-5g.binlm${GZ}, ${MIXLM})
_sublm.${TGT_LANG}: $(addsuffix _${TGT_LANG}-kn-5g.binlm${GZ}, ${MIXLM})

# Create Language Models.
%_${SRC_LANG}-kn-5g.binlm${GZ}:
	[[ -s "${LM_DIR}/$@" ]] \
	&& ln -s ${LM_DIR}/$@ \
	|| ${MAKE} -f ${LM_DIR}/Makefile LM_LANG=${SRC_LANG} TRAIN_LM=$* $@
	
%_${TGT_LANG}-kn-5g.binlm${GZ}:
	[[ -s "${LM_DIR}/$(notdir $@)" ]] \
	&& ln -s ${LM_DIR}/$(notdir $@) \
	|| ${MAKE} -f ${LM_DIR}/Makefile LM_LANG=${TGT_LANG} TRAIN_LM=$* $(notdir $@)



.PHONY: mixlm
mixlm: $(addsuffix .mixlm, ${TUNE_DECODE} ${TUNE_RESCORE} ${TUNE_CE})


#$(addsuffix .distances, ${TUNE_DECODE} ${TUNE_RESCORE} ${TUNE_CE}): %.distances: $(addsuffix _${SRC_LANG}-kn-5g.binlm${GZ}, ${MIXLM})
$(addsuffix .distances, ${TUNE_DECODE} ${TUNE_RESCORE} ${TUNE_CE}): %.distances: _sublm.${SRC_LANG}


#$(addsuffix .mixlm, ${TUNE_DECODE} ${TUNE_RESCORE} ${TUNE_CE}): %.mixlm: $(addsuffix _${TGT_LANG}-kn-5g.binlm${GZ}, ${MIXLM})
$(addsuffix .mixlm, ${TUNE_DECODE} ${TUNE_RESCORE} ${TUNE_CE}): %.mixlm: _sublm.${TGT_LANG}
