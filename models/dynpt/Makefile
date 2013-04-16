#!/usr/bin/make -f
# vim:noet:ts=3:nowrap
# $Id$
#
# @author Eric Joanis
# @file Makefile
# @brief Build files needed for using dynamic phrase tables
#
# Technologies langagieres interactives / Interactive Language Technologies
# Inst. de technologie de l'information / Institute for Information Technology
# Conseil national de recherches Canada / National Research Council Canada
# Copyright 2011, Sa Majeste la Reine du Chef du Canada
# Copyright 2011, Her Majesty in Right of Canada

# Mandatory include: master config file.
include ../../Makefile.params

# TODO: Make sure this Makefile works for Portage's cluster.
# This will require that run-parallel.sh -c RP_OPTS be functional.
SHELL = ${FRAMEWORK_SHELL}

# Where we can find the parallel corpora.
CORPORA_DIR ?= ../../corpora

# Indicates where to find all models.
MODEL_DIR ?= ../../models

# Default language corpora extension.
LANGXZ ?= .gz

# Lets rename the language identifiers for the toolkit.
lang1 = ${SRC_LANG}
lang2 = ${TGT_LANG}

# Language file extension.
L1X ?= _${SRC_LANG}${LANGXZ}
L2X ?= _${TGT_LANG}${LANGXZ}

# IBM / HMM models extension.
L1_GIVEN_L2  ?= ${lang1}_given_${lang2}
L2_GIVEN_L1  ?= ${lang2}_given_${lang1}
L1_GIVEN_L2X ?= ${L1_GIVEN_L2}.gz
L2_GIVEN_L1X ?= ${L2_GIVEN_L1}.gz

# conditional phrase table and directional alignment file extension.
L1_2_L2  ?= ${lang1}2${lang2}
L2_2_L1  ?= ${lang2}2${lang1}
L1_2_L2X ?= ${L1_2_L2}.gz
L2_2_L1X ?= ${L2_2_L1}.gz

# Allows to search for alignment files in corpus.
vpath %${L1X} ${CORPORA_DIR}
vpath %${L2X} ${CORPORA_DIR}
vpath %.align.gz models/tm

.DELETE_ON_ERROR:
.SUFFIXES:
.SECONDARY:

########################################
# SETUP
ifneq (${MAKECMDGOALS},clean)
ifneq (${MAKECMDGOALS},clean.content)
ifneq (${MAKECMDGOALS},clean.logs)
$(shell ln -fs ${MODEL_DIR})
endif
endif
endif

########################################
# Real stuff

all: tpsa tpa

tpsa: ${TRAIN_TM}${L1X}.tpsa ${TRAIN_TM}${L2X}.tpsa

%.tpsa: %
	build-tp-suffix-array.sh $< $@

tpa: ${TRAIN_TM}.${L1_2_L2}.ibm2.tpa ${TRAIN_TM}.${L1_2_L2}.hmm3.tpa

#${TRAIN_TM}.${L1_2_L2}.%.tpa: models/tm/%.${TRAIN_TM}.${L2_GIVEN_L1X} models/tm/%.${TRAIN_TM}.${L1_GIVEN_L2X} ${TRAIN_TM}${L1X} ${TRAIN_TM}${L2X}
#	parallelize.pl -n 4 -stripe \
#	   -s $(word 3,$+) -s $(word 4,$+) \
#	   "align-words -o green $+" | \
#	tp_alignment_build - $@

%.tpa: %.align.gz
	tp_alignment_build $< $@

# the above is equivalent to the following, but parallel:
#	align-words -o green $+ | tp_alignment_build - $@
