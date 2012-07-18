#!/usr/bin/make -f
# vim:noet:ts=3:nowrap
# $Id$

# @file Makefile
# @brief Logic/dependencies needed to tune a confidence estimation model.
#
# @author Samuel Larkin
#
# Technologies langagieres interactives / Interactive Language Technologies
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
ifneq (${MAKECMDGOALS},clean)
ifneq (${MAKECMDGOALS},clean.content)
ifneq (${MAKECMDGOALS},clean.logs)
$(info ln -fs ${MODEL_DIR})
$(shell ln -fs ${MODEL_DIR})
endif
endif
endif

# Make sure the user setup this framework to generate proper models for
# Confidence Estimation.
ifndef DO_CE
$(warning You must set DO_CE in Makefile.params, or some required models will not be built automatically.)
endif



.DEFAULT_GOAL := help
.DELETE_ON_ERROR:

.PHONY: all
all: train



.PHONY: help
help: SHELL=${LOCAL_SHELL}
help:
	@echo "Tune a Confidence Estimation Model."
	@echo
	@echo "To tune your CE model, type: make all"
	@echo
	@echo "The main targets in this Makefile are:"
	@cat $(firstword $(MAKEFILE_LIST)) | egrep '^.PHONY:' | sed 's#^.PHONY: #   #'


########################################
# Clean up
.PHONY: clean clean.content clean.logs hide.logs
clean: SHELL=${LOCAL_SHELL}
clean: clean.content clean.logs

clean.content: SHELL=${LOCAL_SHELL}
clean.content:
	${RM} canoe.ini.cow *${CEMX} ce-notm.ini models
	${RM} -r ${CE_WORKDIR_PRX}*

clean.logs: SHELL=${LOCAL_SHELL}
clean.logs:
	${RM} -r run-parallel* log.*

# Hide logs from user's view into .logs
hide.logs: SHELL=${LOCAL_SHELL}
hide.logs: hide_logs_sub



########################################
# Resources Summary
.PHONY: time-mem
time-mem: SHELL=${LOCAL_SHELL}
time-mem: resource_summary_sub



########################################
# DECODING MODEL.
${CANOE_MODEL}: SHELL=${LOCAL_SHELL}
${CANOE_MODEL}:
	@[[ -f "${DECODING_MODEL_DIR}/${CANOE_MODEL}" ]] \
	|| ! echo "ERROR: No decoding model (${CANOE_MODEL}) available. Please train ${DECODING_MODEL_DIR} first!" >&2
	sed -e 's#${TUNE_DECODE}.mixlm#${TUNE_CE}.mixlm#g' ${DECODING_MODEL_DIR}/${CANOE_MODEL} > $@
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
# Prepare what is needed for portageLive
.PHONY: portageLive
ifdef DO_CE
portageLive: SHELL=${LOCAL_SHELL}
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
	$(error Exception this target shouldn't be called.)
endif

