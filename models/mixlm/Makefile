#!/usr/bin/make -f
# vim:noet:ts=3:nowrap:filetype=make
# $Id$

# @file
# @brief
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
MODULE_NAME ?= tc

# Define LM_TOOLKIT=SRI if you want to use SRILM
# Define LM_TOOLKIT=MIT if you want to use MITLM
# Make sure all Makefile knows about it.
export LM_TOOLKIT

# Typical lms for truecasing are 3g.
export ORDER ?= 5



.DEFAULT_GOAL := help
.DELETE_ON_ERROR:
.SECONDARY:

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


$(shell mkdir -p cmpts.src cmpts.tgt)

vpath %-kn-5g.binlm${GZ} ../lm
vpath %-kn-5g.binlm${GZ} cmpts.src
vpath %_${SRC_LANG}${LANGX} ../../corpora
vpath %_${TGT_LANG}${LANGX} ../../corpora

#TODO: watch out for duplicate lm in lm/ & mixlm/
#lm-train_en-kn-5g.binlm.gz
#cmpts.src/%_${SRC_LANG}-kn-5g.binlm${GZ}: %_${SRC_LANG}-kn-5g.binlm${GZ}
#	ln -s $< $@

%_${SRC_LANG}-kn-5g.binlm${GZ}:
	${MAKE} -f ../lm/Makefile LM_LANG=${SRC_LANG} TRAIN_LM=$* $@
	
%_${TGT_LANG}-kn-5g.binlm${GZ}:
	${MAKE} -f ../lm/Makefile LM_LANG=${TGT_LANG} TRAIN_LM=$* $@
	
.PHONY: mixlm
mixlm: test1.distances
mixlm: test1.weights
mixlm: test1.mixlm
#mixlm: $(addsuffix .mixlm, ${HELDOUT_SET})

components:
	for f in ${MIXLM}; do echo $$f; done > $@

#test1_en.lc
#mx-calc-distances.sh -v -d cmpts.src/ -e -kn-5g_${SRC_LANG}.binlm.gz em components srcfile > $@
%.distances: $(addsuffix _${SRC_LANG}-kn-5g.binlm${GZ}, ${MIXLM}) components %_${SRC_LANG}${LANGX}
	mx-calc-distances.sh -v -e _${SRC_LANG}-kn-5g.binlm.gz em $(filter-out %_${SRC_LANG}-kn-5g.binlm${GZ}, $+) > $@

%.weights: %.distances
	mx-dist2weights -v normalize $< > $@

#mx-mix-models.sh -d cmpts.tgt/ -e .binlm.gz mixlm $*.weights components srcfile > $@
%.mixlm: $(addsuffix _${TGT_LANG}-kn-5g.binlm${GZ}, ${MIXLM}) %.weights components %_${TGT_LANG}${LANGX}
	mx-mix-models.sh -e _${TGT_LANG}-kn-5g.binlm.gz mixlm $(filter-out %_${TGT_LANG}-kn-5g.binlm${GZ}, $+) > $@

