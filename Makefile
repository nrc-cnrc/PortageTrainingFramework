#!/usr/bin/make -rf
# vim:noet:ts=3
#
# Technologies langagieres interactives / Interactive Language Technologies
# Inst. de technologie de l'information / Institute for Information Technology
# Conseil national de recherches Canada / National Research Council Canada
# Copyright 2008, Sa Majeste la Reine du Chef du Canada
# Copyright 2008, Her Majesty in Right of Canada

MAKEFILE_PARAMS ?= Makefile.params
-include ${MAKEFILE_PARAMS}

.PHONY: all
all: tune
ifneq ($(strip ${TRANSLATE_SET}),)
all: translate
endif



.PHONY: help
help:
	@echo "please run in order for this framework to run properly:"
	@echo "export PATH=${IRSTLM}/bin:$$PATH"
	@echo "export IRSTLM=${IRSTLM}"
	@echo "Your corpora are:"
	@echo "lm: ${TRAIN_LM}"
	@echo "tm: ${TRAIN_TM}"
	@echo "tune decode: ${TUNE_DECODE}"
	@echo "tune rescore: ${TUNE_RESCORE}"
	@echo "translate set: ${TRANSLATE_SET}"
	@echo "Then make all"
	@cat $(firstword $(MAKEFILE_LIST)) | egrep '^.PHONY:' | sed 's#^.PHONY: ##'



.PHONY: doc
doc: framework-toy.pdf

%.pdf: %.tex
	TEXINPUTS=${PORTAGE}/texmf: pdflatex -interaction=batchmode $<
	TEXINPUTS=${PORTAGE}/texmf: pdflatex -interaction=batchmode $<



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



.PHONY: corpora
corpora: check_setup
	${MAKE} -C corpora all



.PHONY: models
models: lms tms
ifdef DO_TRUECASING
models: tc
endif



.PHONY: lms
# Create the Language Model (LM).
lms: lm.${TGT_LANG}
ifdef BIDIRECTIONAL_SYSTEM
lms: lm.${SRC_LANG}
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
	echo "Not training the truecasing models." >&2
endif



.PHONY: tms
# Create the Translation Model (TM).
tms: corpora
	${MAKE} -C models/tm all



.PHONY: tune
# Tune the required models.
ifdef DO_RESCORING
tune: rat
else
tune: cow
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
translate: models tune
	${MAKE} -C translate



.PHONY: check_setup
check_setup:
	${MAKE} -C models/lm check_setup

