#!/usr/bin/make -rf
# vim:noet:ts=3:nowrap
#
# $Id$
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

.DEFAULT_GOAL := help
.DELETE_ON_ERROR:
.SUFFIXES:

.PHONY: all
all: tune
ifneq ($(strip ${TEST_SET}),)
all: eval
endif



.PHONY: help
help:
ifeq (${LM_TOOLKIT},IRST)
	@echo "please run the following in order for this framework to run properly:"
	@echo "export PATH=${IRSTLM}/bin:\$$PATH"
	@echo "export IRSTLM=${IRSTLM}"
endif
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
	TEXINPUTS=${PORTAGE}/texmf: pdflatex -interaction=batchmode $<

.PHONY: doc-clean
# Clean auxiliary files from make doc, but not the .pdf itself.
doc-clean:
	${RM} framework-toy.{aux,log,toc}



.PHONY: clean
# Thorough cleaning of everything
clean: SHELL=${GUARD_SHELL}
clean:
	${RM} framework-toy.{aux,log,pdf,toc}



.PHONY: clean.content
clean: clean.content clean.logs
clean.content clean.logs: SHELL=${GUARD_SHELL}
clean.content clean.logs: %:
	${MAKE} -C corpora $@
	${MAKE} -C models $@
	${MAKE} -C translate $@



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
.PHONY: models lm ldm tc tm decode cow rescore rat confidence
tune models lm ldm tc tm decode cow rescore rat confidence: %: corpora
	${MAKE} -C models $@



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
	@echo "from the root of the framework, you now have all that is required for portageLive."
	@echo "rsync -Larz models/portageLive/* <RHOST>:/<DEST_DIR_RHOST>"
	@echo "scp -r models/portageLive/* <RHOST>:/<DEST_DIR_RHOST>"
	@echo "cp -Lr models/portageLive/* /<DEST_DIR>"



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
resource_summary: export PORTAGE_INTERNAL_CALL=1
resource_summary:
	@${MAKE} --no-print-directory -s -C models time-mem
	@${MAKE} --no-print-directory -s -C translate time-mem

.PHONY: time-mem
time-mem: SHELL=/bin/bash
time-mem: export PORTAGE_INTERNAL_CALL=1
time-mem:
	@time-mem -T <(${MAKE} resource_summary) \
	| perl -pe 's/[0-9]+:TIME-MEM/TIME-MEM/' \
	| expand-auto.pl

.PHONY: summary
summary: SHELL=/bin/bash
summary: export PORTAGE_INTERNAL_CALL=1
summary: time-mem
	@du -sch models/ldm models/lm/*lm.gz models/tm/{ibm,hmm,jpt,cpt}* models/tc translate

