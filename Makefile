#!/usr/bin/make -rf
# vim:noet:ts=3:nowrap
#
# @author Samuel Larkin
# @file Makefile
# @brief Master makefile for the framework, handles dependencies between modules.
#
# Technologies langagieres interactives / Interactive Language Technologies
# Inst. de technologie de l'information / Institute for Information Technology
# Conseil national de recherches Canada / National Research Council Canada
# Copyright 2008, Sa Majeste la Reine du Chef du Canada
# Copyright 2008, Her Majesty in Right of Canada

MAKEFILE_PARAMS ?= Makefile.params
-include ${MAKEFILE_PARAMS}

.SUFFIXES:

.PHONY: all
all: tune
ifneq ($(strip ${TEST_SET}),)
all: eval
endif



.PHONY: help
help:
	@echo "please run in order for this framework to run properly:"
	@echo "export PATH=${IRSTLM}/bin:\$$PATH"
	@echo "export IRSTLM=${IRSTLM}"
	@echo "Your corpora are:"
	@echo "lm: ${TRAIN_LM}"
	@echo "tm: ${TRAIN_TM}"
	@echo "tune decode: ${TUNE_DECODE}"
	@echo "tune rescore: ${TUNE_RESCORE}"
	@echo "test set: ${TEST_SET}"
	@echo "Then make all"
	@echo
	@echo "The following are the main targets in this Makefile:"
	@cat $(firstword $(MAKEFILE_LIST)) | egrep '^.PHONY:' | sed 's#^.PHONY: ##'



.PHONY: doc
doc: framework-toy.pdf

%.pdf: %.tex
	-TEXINPUTS=${PORTAGE}/texmf: pdflatex -interaction=batchmode $<
	TEXINPUTS=${PORTAGE}/texmf: pdflatex -interaction=batchmode $<

.PHONY: doc-clean
# Clean auxiliary files from make doc, but not the .pdf itself.
doc-clean:
	${RM} framework-toy.{aux,log,toc}



.PHONY: clean
# Thorough cleaning of everything
clean:
	${MAKE} -C corpora clean
	${MAKE} -C models clean
	${MAKE} -C translate clean
	${RM} framework-toy.{aux,log,pdf,toc}



.PHONY: hide
# Hide logs from user's view into .logs
hide:
	${MAKE} -C models hide



.PHONY: corpora
corpora: check_setup
	${MAKE} -C corpora all



# Create the Language Model (LM).
# Create models for truecasing (TC).
# Create the Translation Model (TM).
.PHONY: models lm tc tm cow rat
models lm tc tm cow rat: %: corpora
	${MAKE} -C models $@



.PHONY: tune
# Tune the required models.
tune: cow
ifdef DO_RESCORING
tune: rat
endif



# cow depends on the models.
# Run COW to tune the decoding model.
cow: models



# rat depends on cow.
# Run RAT to tune the rescoring model.
rat: cow



.PHONY: translate
# Tune weights and apply them to the test sets
translate: tune
	${MAKE} -C translate all



.PHONY: eval
# Get BLEU scores for the test set(s)
eval: translate
	${MAKE} -C translate bleu



.PHONY: check_setup
check_setup:
	${MAKE} -C models/lm check_setup



########################################
# Prepare portageLive models.
.PHONY: portageLive
portageLive:
	${MAKE} -C models portageLive



########################################
# Prepare PORTAGEsharedLive models.
.PHONY: PORTAGEsharedLive
PORTAGEsharedLive:
	${MAKE} -C models PORTAGEsharedLive



########################################
# If you need to preprocess your corpora, you can call this target to do the job.
# The end result should be .al files .
PREPARE_CORPORA_MAKEFILE ?= Makefile.prepare.corpora
.PHONY: prepare.corpora
prepare.corpora:
	${MAKE} -C corpora -f ${PREPARE_CORPORA_MAKEFILE} all



########################################
# Resource Summary
.PHONY: resource_summary
resource_summary: SHELL=${GUARD_SHELL}
resource_summary:
	@${MAKE} --no-print-directory -s -C models summary
	@${MAKE} --no-print-directory -s -C translate summary

.PHONY: summary
summary: SHELL=/bin/bash
summary:
	@p-res-mon.sh <(${MAKE} resource_summary)
	@du -sch models/lm/*lm.gz models/tm/{ibm,hmm,jpt,cpt}* models/tc translate
