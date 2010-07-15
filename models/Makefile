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

# Mandatory include: master config file.
include ../Makefile.params

# Lastly include the master toolkit
include ../Makefile.toolkit

SHELL = ${GUARD_SHELL}

ifeq ("portageLive","$(findstring portageLive,${MAKECMDGOALS})")
   $(info mkdir -p portageLive)
   # Don't do the mkdir on a dryrun (-n).
   ifeq ("","$(findstring n,${MAKEFLAGS})")
      $(shell mkdir -p portageLive)
   endif
endif

.DEFAULT_GOAL := help
.SUFFIXES:

.PHONY: all
all: tune



########################################
# HELP MESSAGE.
.PHONY: help
help:
ifeq (${LM_TOOLKIT},IRST)
	@echo "Please run the following in order for this framework to run properly:"
	@echo "   export PATH=${IRSTLM}/bin:\$$PATH"
	@echo "   export IRSTLM=${IRSTLM}"
	@echo
endif
	@echo "Your corpora are:"
	@echo "   train lm: ${TRAIN_LM}"
	@echo "   train tm: ${TRAIN_TM}"
	@echo "   tune decode: ${TUNE_DECODE}"
	@echo "   tune rescore: ${TUNE_RESCORE}"
ifneq ($(strip ${TUNE_CE}),)
	@echo "   tune ce: ${TUNE_CE}"
endif
	@echo
	@echo "To train your models, type: make all"
	@echo
	@echo "The main targets in this Makefile are:"
	@cat $(firstword $(MAKEFILE_LIST)) | egrep '^.PHONY:' | sed 's#^.PHONY: #   #'


########################################
# Clean up
.PHONY: clean clean.content clean.logs hide.logs
clean: SHELL=${GUARD_SHELL}
clean: clean.content clean.logs

# Thorough cleaning of everything
# hide.logs hides logs from user's view into .logs
clean.content clean.logs hide.logs: SHELL=${GUARD_SHELL}
clean.content clean.logs hide.logs: %:
	${MAKE} -C ldm $@
	${MAKE} -C lm $@
	${MAKE} -C tm $@
	${MAKE} -C tc $@
	${MAKE} -C decode $@
	${MAKE} -C rescore $@
	${MAKE} -C confidence $@



########################################
# Resource Summary
.PHONY: time-mem
time-mem: SHELL=${GUARD_SHELL}
time-mem:
	@${MAKE} --no-print-directory -s -C ldm time-mem
	@${MAKE} --no-print-directory -s -C lm time-mem
	@${MAKE} --no-print-directory -s -C tm time-mem
	@${MAKE} --no-print-directory -s -C tc time-mem
	@${MAKE} --no-print-directory -s -C decode time-mem
	@${MAKE} --no-print-directory -s -C rescore time-mem
	@${MAKE} --no-print-directory -s -C confidence time-mem



################################################################################
# MINIMUM MANDATORY TARGETS.
.PHONY: models
models: lm tm



.PHONY: lm
# Create the Language Model (LM).
lm: lm.${TGT_LANG}
lm.%:
	${MAKE} -C lm all LM_LANG=$*



.PHONY: tm
# Create the Translation Model (TM).
tm:
	${MAKE} -C tm all



.PHONY: tune
# Tune the required models.
tune: decode



.PHONY: cow decode
# Run COW to tune the decoding model.
cow: decode
decode: models
	${MAKE} -C decode all



.PHONY: rat rescore
# Run RAT to tune the rescoring model.
rat: rescore
rescore: decode
	${MAKE} -C rescore all



################################################################################
# Targets based on master Makefile.params
.PHONY: ldm
ifdef USE_LDM
models: ldm

portageLive: portageLive_models_ldm
portageLive_models_decode: portageLive_models_ldm

ldm: tm
	${MAKE} -C ldm all
else
ldm:
	@echo "Not training a lexicalized distortion model." >&2
endif



.PHONY: confidence
ifdef DO_CE
tune: confidence

portageLive: portageLive_models_lm_src
portageLive: portageLive_models_confidence

portageLive_models_confidence: portageLive_models_lm_src
portageLive_models_confidence: portageLive_models_decode

portageLive_models_lm_src:
	${MAKE} -C lm portageLive LM_LANG=${SRC_LANG}

confidence: lm.${SRC_LANG} decode
	${MAKE} -C confidence all
else
confidence:
	@echo "Not training a confidence estimation model." >&2
endif



.PHONY: tc
# Create models for truecasing (TC).
ifdef DO_TRUECASING
models: tc

portageLive: portageLive_models_tc

tc:
	${MAKE} -C tc all
else
tc:
	@echo "Not training the truecasing models." >&2
endif



ifdef DO_RESCORING
tune: rescore
endif



########################################
# Prepare portageLive models.
.PHONY: portageLive
portageLive: portageLive_models_lm
portageLive: portageLive_models_tm
portageLive: portageLive_models_decode
portageLive:
	pwd > $@/README
	portage_info >> $@/README

portageLive: portageLive/soap-translate.sh
portageLive/soap-translate.sh: portageLive_models_decode
	mkdir -p $(dir $@)
	echo "#!/bin/bash" > $@
	cd $(dir $@) && echo "`../../translate.sh -n $(and ${DO_RESCORING}, -with-rescoring)` -f=\`dirname \$$0\`/canoe.ini.cow" >> $(notdir $@)
	chmod 755 $@

# We need this dependency since decode will copy the tplms for portageLive.
portageLive_models_decode: portageLive_models_lm portageLive_models_tm
portageLive_models_%:
	${MAKE} -C $* portageLive

ifneq ("$(wildcard ../plugins)","")
portageLive: portageLive/plugins
portageLive/plugins:
	ln -fs ../../plugins $@
endif

.PHONY: clean.portageLive
clean clean.content: clean.portageLive
clean.portageLive: SHELL=${GUARD_SHELL}
clean.portageLive:
	${RM} -r portageLive
