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
	@echo "Some help message not yet defined."



.PHONY: all
ifdef MIXLM
all: mixlm
else
all:
	@echo "Nothing to do, no mixlm were defined."
endif



.PHONY: clean
clean: SHELL=${GUARD_SHELL}
clean:
	${RM} components
	${RM} *.distances *.weights *.mixlm 


$(shell ln -fs ../../models)

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
	for f in ${MIXLM}; do echo $$f; done > $@

%.distances: $(addsuffix _${SRC_LANG}-kn-5g.binlm${GZ}, ${MIXLM}) components %_${SRC_LANG}${LANGX}
	mx-calc-distances.sh -v -d models/mixlm/ -e _${SRC_LANG}-kn-5g.binlm.gz em $(filter-out %_${SRC_LANG}-kn-5g.binlm${GZ}, $+) > $@

%.weights: %.distances
	mx-dist2weights -v normalize $< > $@

%.mixlm: $(addsuffix _${TGT_LANG}-kn-5g.binlm${GZ}, ${MIXLM}) %.weights components %_${TGT_LANG}${LANGX}
	mx-mix-models.sh -d models/mixlm/ -e _${TGT_LANG}-kn-5g.binlm.gz mixlm $(filter-out %_${TGT_LANG}-kn-5g.binlm${GZ}, $+) > $@

