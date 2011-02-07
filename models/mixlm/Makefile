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



$(shell ln -fs ../../models)


.DEFAULT_GOAL := help
.DELETE_ON_ERROR:
# We actually want to get ride off %.distances %.weights
.INTERMEDIATE: components



# Watch out for already trained lms.
#vpath %-kn-5g.binlm${GZ} ../lm
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
sublm.${SRC_LANG}: $(addsuffix _${SRC_LANG}-kn-5g.binlm${GZ}, ${MIXLM})
sublm.${TGT_LANG}: $(addsuffix _${TGT_LANG}-kn-5g.binlm${GZ}, ${MIXLM})

models/mixlm/%-kn-5g.binlm${GZ}: %-kn-5g.binlm${GZ}

# Create Language Models.
%_${SRC_LANG}-kn-5g.binlm${GZ}:
	[[ -s "../lm/$@" ]] \
	&& ln -s ../lm/$@ \
	|| ${MAKE} -f ../lm/Makefile LM_LANG=${SRC_LANG} TRAIN_LM=$* $@
	
%_${TGT_LANG}-kn-5g.binlm${GZ}:
	[[ -s "../lm/$@" ]] \
	&& ln -s ../lm/$@ \
	|| ${MAKE} -f ../lm/Makefile LM_LANG=${TGT_LANG} TRAIN_LM=$* $@



.PHONY: mixlm
mixlm: $(addsuffix .mixlm, ${HELDOUT_SET})

components:
	echo "$(strip ${MIXLM})" | tr " " "\n" > $@

#%.distances: sublm.${SRC_LANG} components %_${SRC_LANG}${LANGX}
%.distances: $(addprefix models/mixlm/, $(addsuffix _${SRC_LANG}-kn-5g.binlm${GZ}, ${MIXLM})) components %_${SRC_LANG}${LANGX}
	mx-calc-distances.sh -v -d models/mixlm/ -e _${SRC_LANG}-kn-5g.binlm.gz em $(filter-out %_${SRC_LANG}-kn-5g.binlm${GZ}, $+) > $@

%.weights: %.distances
	mx-dist2weights -v normalize $< > $@

#%.mixlm: sublm.${TGT_LANG} %.weights components %_${TGT_LANG}${LANGX}
%.mixlm: $(addprefix models/mixlm/, $(addsuffix _${TGT_LANG}-kn-5g.binlm${GZ}, ${MIXLM})) %.weights components %_${TGT_LANG}${LANGX}
	mx-mix-models.sh -d models/mixlm/ -e _${TGT_LANG}-kn-5g.binlm.gz mixlm $(filter-out %_${TGT_LANG}-kn-5g.binlm${GZ}, $+) > $@
