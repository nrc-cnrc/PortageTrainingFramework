#!/usr/bin/make -f
# vim:noet:ts=3:nowrap
# $Id$

# @file Makefile
# @brief
#
# @author Samuel Larkin
#
# Technologies langagieres interactives / Interactive Language Technologiesm
# Inst. de technologie de l'information / Institute for Information Technology
# Conseil national de recherches Canada / National Research Council Canada
# Copyright 2009, Sa Majeste la Reine du Chef du Canada /
# Copyright 2009, Her Majesty in Right of Canada



-include Makefile.params
include ../../Makefile.params
include Makefile.definition
include Makefile.toolkit


.PHONY: all
all: train


.PHONY: clean
clean: SHELL=${GUARD_SHELL}
clean:
	${RM} canoe.ini.cow ce_model.cem ce-notm.ini models
	${RM} -r ${CE_WORKDIR_PRX}*



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
	ln -s models/decode/${CANOE_MODEL} $@


########################################
# Creating the initial model from the template.
ce-notm.ini: SHELL=${GUARD_SHELL}
ce-notm.ini: ce-notm.template ${CANOE_MODEL}



########################################
# Tuning a confidence model.
.PHONY: train
train: ce_model.cem

ce_model.cem: ce-notm.ini ${TUNE_CE_SRC} ${TUNE_CE_TGT}

