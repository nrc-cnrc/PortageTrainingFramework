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

include ../../Makefile.params
include ../../Makefile.toolkit
include Makefile.definition
include Makefile.toolkit


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
	${RM} canoe.ini.cow ce_model.cem ce-notm.ini models
	${RM} -r ${CE_WORKDIR_PRX}*

clean.logs: SHELL=${GUARD_SHELL}
clean.logs:
	${RM} -r run-parallel* log.*



########################################
# SETTING UP the environment.
#.PHONY: setup
setup: SHELL=${GUARD_SHELL}
setup:
	[[ -e models ]] || ln -s ${MODEL_DIR} models
	[[ -f "models/decode/${CANOE_MODEL}" ]] || ( echo "You must tune a canoe.ini.cow first!" >&2; false )
	[[ -f ${CANOE_MODEL} ]] || ln -s models/decode/${CANOE_MODEL}

models:
	ln -s ${MODEL_DIR} $@

${CANOE_MODEL}: models
	ln -fs models/decode/${CANOE_MODEL} $@


########################################
# Creating the initial model from the template.
ce-notm.ini: SHELL=${GUARD_SHELL}
ce-notm.ini: ce-notm.template ${CANOE_MODEL}



########################################
# Tuning a confidence model.
.PHONY: train
train: ce_model.cem

ce_model.cem: ce-notm.ini ${TUNE_CE_SRC} ${TUNE_CE_TGT}



########################################
# resources summary
.PHONY: summary
summary: resource_summary_sub



########################################
# Prepare what is needed for portageLive
.PHONY: portageLive
ifdef DO_CE
portageLive: train
else
portageLive:
	$(error "Exception this target shouldn't be called.")
endif
