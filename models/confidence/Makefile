#!/usr/bin/make -f
# vim:noet:ts=3:nowrap
# $Id$

# @file Makefile
# @brief Logic/dependencies needed to tune a confidence estimation model.
#
# @author Samuel Larkin
#
# Technologies langagieres interactives / Interactive Language Technologiesm
# Inst. de technologie de l'information / Institute for Information Technology
# Conseil national de recherches Canada / National Research Council Canada
# Copyright 2010, Sa Majeste la Reine du Chef du Canada /
# Copyright 2010, Her Majesty in Right of Canada



# Include the config file.
MAKEFILE_PARAMS ?= Makefile.params
-include ${MAKEFILE_PARAMS}

# What is this module's name.
MODULE_NAME ?= confidence

include ../../Makefile.params
include ../../Makefile.toolkit
include Makefile.definition
include Makefile.toolkit

# Confidence Estimation model's name.
CE_MODEL_NAME ?= ce_model

########################################
# SETUP
SETUP_FORCE_MODELS_LINKS := $(shell ln -fs ${MODEL_DIR})

# Make sure the user setup this framework to generate proper models for
# Confidence Estimation.
ifndef DO_CE
$(warning "If you don't setup DO_CE in Makefile.params, you won't get all the required models built automatically in the framework.")
endif



.DEFAULT_GOAL := help
.DELETE_ON_ERROR:

.PHONY: all
all: train



.PHONY: help
help: SHELL=${GUARD_SHELL}
help:
	@echo "Tuning a Confidence Estimation Model."
	@echo "Valid target are: clean & all"


########################################
# Cleaning up!
.PHONY: clean
clean: SHELL=${GUARD_SHELL}
clean: clean.content clean.logs

clean.content: SHELL=${GUARD_SHELL}
clean.content:
	${RM} canoe.ini.cow *${CEMX} ce-notm.ini models
	${RM} -r ${CE_WORKDIR_PRX}*

clean.logs: SHELL=${GUARD_SHELL}
clean.logs:
	${RM} -r run-parallel* log.*



########################################
# DECODING MODEL.
${CANOE_MODEL}: SHELL=${GUARD_SHELL}
${CANOE_MODEL}:
	[[ -f "models/decode/${CANOE_MODEL}" ]] || ( echo "You must tune a canoe.ini.cow first!" >&2; false )
	ln -fs models/decode/${CANOE_MODEL} $@
	configtool check $@



########################################
# Creating the initial model from the template.
ce-notm${INIX}: ce-notm${TEMPLATEX} ${CANOE_MODEL}



########################################
# Tuning a confidence model.
.PHONY: train
train: ${CE_MODEL_NAME}${CEMX}

${CE_MODEL_NAME}${CEMX}: ce-notm${INIX} ${TUNE_CE_SRC} ${TUNE_CE_TGT}



########################################
# Resources Summary
.PHONY: time-mem
time-mem: SHELL=${GUARD_SHELL}
time-mem: resource_summary_sub



########################################
# Prepare what is needed for portageLive
.PHONY: portageLive
ifdef DO_CE
portageLive: SHELL=${GUARD_SHELL}
portageLive: ${CE_MODEL_NAME}${CEMX}
	mkdir -p ../portageLive
	mkdir -p tmp.live && tar -C tmp.live -zxvf $<
	sed -i -e 's/binlm.gz/tplm/' tmp.live/model
	cd tmp.live && tar zcf ../../portageLive/$< *
	rm -r tmp.live
	MODELS=(`test -e ../portageLive/ce_model.cem && tar zxOf ../portageLive/$< model | egrep -o '[^/]+\.tplm' | tr "\n" " "`); \
	if [[ $$MODELS ]]; then \
		${MAKE} -C ../lm $${MODELS[@]}; \
		mkdir -p ../portageLive/models/lm; \
		MODELS=($${MODELS[@]/#/..\/..\/..\/lm\/}); \
		echo $${MODELS[@]} >&2; \
		cd ../portageLive/models/lm && ln -fs $${MODELS[@]} .; \
	fi
	MODELS=(`test -e ../portageLive/ce_model.cem && tar zxOf ../portageLive/$< model | egrep -o '[^/]+.(${TGT_LANG}_given_${SRC_LANG}|${SRC_LANG}_given_${TGT_LANG}).gz' | tr "\n" " "`); \
	if [[ $$MODELS ]]; then \
		MODELS=($${MODELS[@]/%.gz/*}); \
		MODELS=($${MODELS[@]/#/..\/..\/..\/tm\/}); \
		echo $${MODELS[@]} >&2; \
		mkdir -p ../portageLive/models/tm; \
		cd ../portageLive/models/tm && ln -fs $${MODELS[@]} .; \
	fi
else
portageLive:
	$(error "Exception this target shouldn't be called.")
endif

