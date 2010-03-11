#!/usr/bin/make -f
# vim:noet:ts=3:nowrap
# $Id$

# @file Controls making all models.
# @brief A focal point to train all models.
#
# @author Samuel Larkin
#
# Technologies langagieres interactives / Interactive Language Technologiesm
# Inst. de technologie de l'information / Institute for Information Technology
# Conseil national de recherches Canada / National Research Council Canada
# Copyright 2009, Sa Majeste la Reine du Chef du Canada /
# Copyright 2009, Her Majesty in Right of Canada


MAKEFILE_PARAMS ?= ../Makefile.params
-include ${MAKEFILE_PARAMS}

SHELL = ${GUARD_SHELL}

.DEFAULT_GOAL := help
.SUFFIXES:

.PHONY: all
all: tune



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
	@echo "tune confidence estimation model"
	@echo "Then make all"
	@echo
	@echo "The following are the main targets in this Makefile:"
	@cat $(firstword $(MAKEFILE_LIST)) | egrep '^.PHONY:' | sed 's#^.PHONY: ##'



.PHONY: clean hide clean.logs clean.content
# Thorough cleaning of everything
# Hide logs from user's view into .logs
clean hide clean.logs clean.content: %:
	${MAKE} -C lm $@
	${MAKE} -C tm $@
	${MAKE} -C tc $@
	${MAKE} -C decode $@
	${MAKE} -C rescore $@
	${MAKE} -C confidence $@



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
lm.%:
	${MAKE} -C lm all LM_LANG=$*



.PHONY: confidence
ifdef DO_CE
tune: confidence

portageLive: portageLive_lm_src

PORTAGEsharedLive: portageLive_lm_src

portageLive_lm_src:
	${MAKE} -C lm tplm LM_LANG=${SRC_LANG}

confidence: lm.${SRC_LANG} cow
	${MAKE} -C confidence all
else
confidence:
	@echo "Not training a confidence estimation model." >&2
endif



.PHONY: tc
# Create models for truecasing (TC).
ifdef DO_TRUECASING
tc:
	${MAKE} -C tc all
else
tc:
	@echo "Not training the truecasing models." >&2
endif



.PHONY: tm
# Create the Translation Model (TM).
tm:
	${MAKE} -C tm all



.PHONY: tune
# Tune the required models.
tune: cow
ifdef DO_RESCORING
tune: rat
endif



.PHONY: cow
# Run COW to tune the decoding model.
cow: models
	${MAKE} -C decode all



.PHONY: rat
# Run RAT to tune the rescoring model.
rat: cow
	${MAKE} -C rescore all



########################################
# Prepare portageLive models.
.PHONY: portageLive
portageLive: portageLive_lm
portageLive: portageLive_tc
portageLive: portageLive_decode

portageLive_decode: cow
portageLive_%:
	${MAKE} -C $* portageLive



########################################
# Prepare PORTAGEsharedLive models.
.PHONY: PORTAGEsharedLive
PORTAGEsharedLive: PORTAGEsharedLive_lm
PORTAGEsharedLive: PORTAGEsharedLive_tc
PORTAGEsharedLive: PORTAGEsharedLive_decode

PORTAGEsharedLive_decode: cow
PORTAGEsharedLive_%:
	${MAKE} -C $* PORTAGEsharedLive



########################################
# Resource Summary
.PHONY: summary
summary: SHELL=${GUARD_SHELL}
summary:
	@${MAKE} --no-print-directory -s -C ldm summary
	@${MAKE} --no-print-directory -s -C lm summary
	@${MAKE} --no-print-directory -s -C tm summary
	@${MAKE} --no-print-directory -s -C tc summary
	@${MAKE} --no-print-directory -s -C decode summary
	@${MAKE} --no-print-directory -s -C rescore summary
	@${MAKE} --no-print-directory -s -C confidence summary
