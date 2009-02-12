#!/usr/bin/make -rf
# vim:noet:ts=3
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
	${MAKE} -C models/lm clean
	${MAKE} -C models/tm clean
	${MAKE} -C models/tc clean
	${MAKE} -C models/decode clean
	${MAKE} -C models/rescore clean
	${MAKE} -C translate clean
	${RM} framework-toy.{aux,log,pdf,toc}



.PHONY: corpora
corpora: check_setup
	${MAKE} -C corpora all



.PHONY: models
models: lm tm
ifdef DO_TRUECASING
models: tc
endif



.PHONY: lm
# Create the Language Model (LM).
lm: lm.${TGT_LANG}
ifdef BIDIRECTIONAL_SYSTEM
lm: lm.${SRC_LANG}
endif
lm.%: corpora
	${MAKE} -C models/lm all



.PHONY: tc
# Create models for truecasing (TC).
ifdef DO_TRUECASING
tc: corpora
	${MAKE} -C models/tc all
else
tc:
	@echo "Not training the truecasing models." >&2
endif



.PHONY: tm
# Create the Translation Model (TM).
tm: corpora
	${MAKE} -C models/tm all



.PHONY: tune
# Tune the required models.
tune: cow
ifdef DO_RESCORING
tune: rat
endif



.PHONY: cow
# Run COW to tune the decoding model.
cow: models
	${MAKE} -C models/decode all



.PHONY: rat
# Run RAT to tune the rescoring model.
rat: cow
	${MAKE} -C models/rescore all



.PHONY: translate
# Tune weights and apply them to the test sets
translate: tune
	${MAKE} -C translate



.PHONY: eval
# Get BLEU scores for the test set(s)
eval: translate
	${MAKE} -C translate bleu



.PHONY: check_setup
check_setup:
	${MAKE} -C models/lm check_setup


########################################
# If you need to preprocess your corpora, you can call this target to do the job.
# The end result should be .al files .
PREPARE_CORPORA_MAKEFILE ?= Makefile.prepare.corpora
.PHONY: prepare.corpora
prepare.corpora:
	${MAKE} -C corpora -f ${PREPARE_CORPORA_MAKEFILE}

