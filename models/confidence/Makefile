#!/usr/bin/make -f
# vim:noet:ts=3:nowrap
# $Id$

# @file Makefile
# @brief
#
# @author Samuel Larkin
#
# Technologies langagieres interactives / Interactive Language Technologiesm
# Inst. de technologie de l'information / Institute for Information Technology
# Conseil national de recherches Canada / National Research Council Canada
# Copyright 2009, Sa Majeste la Reine du Chef du Canada /
# Copyright 2009, Her Majesty in Right of Canada



-include Makefile.params
include ../../Makefile.params
include Makefile.definition
include Makefile.toolkit


.PHONY: all
all: train


.PHONY: clean
clean: SHELL=${GUARD_SHELL}
clean:
	${RM} canoe.ini.cow ce_model.cem ce-notm.ini models



########################################
# SETTING UP the environment.
.PHONY: setup
setup: ${CANOE_MODEL}

models:
	ln -s ${MODEL_DIR}

${CANOE_MODEL}: models
	ln -s $</decode/$@



########################################
# Creating the initial model from the template.
# TODO:
# - inacceptable hardcoded substitution for LMs.
# - idea is to have a Makefile.definition in models/lm?
ce-notm.ini: SHELL=${GUARD_SHELL}
ce-notm.ini: ce-notm.template



########################################
# Tuning a confidence model.
.PHONY: train
train: ce_model.cem

ce_model.cem: ${CANOE_MODEL} ce-notm.ini ${TUNE_CE_SRC} ${TUNE_CE_TGT}



########################################
# Translating with CE a test set.
.PHONY: trans
trans: test1.ce

# Remove -dir=* debugging makefile.
test1.ce: ce_model.cem
	ce_translate.pl \
		-notok -nolc -test=../../corpora/test1_fr.lc \
		-dir=test2 \
		-out=$@ \
		canoe.ini.cow \
		ce_model \
		../../corpora/test1_en.lc
