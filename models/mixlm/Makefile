#!/usr/bin/make -f
# vim:noet:ts=3:nowrap:filetype=make
# $Id$

# @file Makefile
# @brief Create mixlm files.
#
# @author Samuel Larkin and Darlene Stewart
#
# Technologies langagieres interactives / Interactive Language Technologies
# Inst. de technologie de l'information / Institute for Information Technology
# Conseil national de recherches Canada / National Research Council Canada
# Copyright 2011, Sa Majeste la Reine du Chef du Canada /
# Copyright 2011, Her Majesty in Right of Canada


# Mandatory include: master config file.
include ../../Makefile.params

# Include the config file.
MAKEFILE_PARAMS ?= Makefile.params
-include ${MAKEFILE_PARAMS}

include Makefile.toolkit

# Lastly include the master toolkit
include ../../Makefile.toolkit


# What is this module's name.
MODULE_NAME ?= mixlm

# Resource monitoring.
TIME_MEM ?= time-mem

# Define LM_TOOLKIT=SRI if you want to use SRILM
# Define LM_TOOLKIT=MIT if you want to use MITLM
# Make sure all Makefiles know about it.
export LM_TOOLKIT

export ORDER ?= 5

LM_DIR ?= models/lm

MIXLM_COMPONENTS := $(strip ${MIXLM} $(notdir ${MIXLM_PRETRAINED_TGT_LMS}))

TUNE_SETS = ${TUNE_DECODE} $(addprefix ${TUNE_DECODE}, ${TUNE_DECODE_VARIANTS})

.DEFAULT_GOAL := help
.DELETE_ON_ERROR:
# We don't need to keep %.distances %.weights
#.INTERMEDIATE: components_${SRC_LANG}, components_${TGT_LANG}
.INTERMEDIATE: $(addsuffix .distances, ${TUNE_SETS})
.INTERMEDIATE: $(addsuffix .weights, ${TUNE_SETS})
.SECONDARY:


# Watch out for already trained lms.
vpath %_${SRC_LANG}${LANGX} ../../corpora
vpath %_${TGT_LANG}${LANGX} ../../corpora


.PHONY: help
help: SHELL=${LOCAL_SHELL}
help:
	@echo "To train your mix language models, type: make all"
	@cat $(firstword $(MAKEFILE_LIST)) | egrep '^.PHONY:' | sed 's#^.PHONY: #   #'



.PHONY: all
all: SHELL=${LOCAL_SHELL}
ifdef MIXLM_COMPONENTS
all: mixlm
else
all:
	@echo "No MIXLMs defined, nothing to do."
endif



########################################
# Clean up
.PHONY: clean clean.content clean.logs hide.logs
clean: SHELL=${LOCAL_SHELL}
clean: clean.content clean.logs

clean.content: SHELL=${LOCAL_SHELL}
clean.content:
	${RM} components_* models
	${RM} *.distances *.weights *.mixlm 
	${RM} *.lm.gz *.binlm.gz .*.tstamp

clean.logs: SHELL=${LOCAL_SHELL}
clean.logs:
	${RM} log.*
	${RM} run-parallel-logs-*
	${RM} -r .logs

# Hide logs from user's view into .logs
hide.logs: SHELL=${LOCAL_SHELL}
hide.logs: hide_logs_sub

########################################
# Resources Summary
.PHONY: time-mem
time-mem: SHELL=${LOCAL_SHELL}
time-mem: resource_summary_sub

########################################


# The model files have an order-only dependancy on the models directory.
models:
	ln -fs ../../models

# Trigger updating of the symbolic links to pre-trained models by deleting
# the hidden .tstamp files.
.PHONY: trigger.update.pretrained.links
trigger.update.pretrained.links: SHELL=${LOCAL_SHELL}
trigger.update.pretrained.links:
	${RM} .*.tstamp

MIXLM_SRC_MODELS := $(foreach lm, ${MIXLM}, $(or $(notdir $(wildcard ${lm}_${SRC_LANG}*.binlm${GZ})), \
                                                 $(notdir $(wildcard ${LM_DIR}/${lm}_${SRC_LANG}*.binlm${GZ})), \
                                                 ${lm}_${SRC_LANG}-kn-${ORDER}g.binlm${GZ}))
                                                 
MIXLM_TGT_MODELS := $(foreach lm, ${MIXLM}, $(or $(notdir $(wildcard ${lm}_${TGT_LANG}*.binlm${GZ})), \
                                                 $(notdir $(wildcard ${LM_DIR}/${lm}_${TGT_LANG}*.binlm${GZ})), \
                                                 ${lm}_${TGT_LANG}-kn-${ORDER}g.binlm${GZ}))

MIXLM_PRETRAINED_LMS := ${MIXLM_PRETRAINED_SRC_LMS} ${MIXLM_PRETRAINED_TGT_LMS}

.PHONY: sublm sublm.${SRC_LANG} sublm.${TGT_LANG}
sublm: sublm.${SRC_LANG}
sublm: sublm.${TGT_LANG}
sublm.${SRC_LANG}: ${MIXLM_SRC_MODELS}
sublm.${TGT_LANG}: ${MIXLM_TGT_MODELS}

# Create Language Models.
# If for some reason one of the sublm was already created in models/lm, don't
# recreate it, just link to it; otherwise build it here in the mixlm directory
# (which requires using make -f, not make -C).
${MIXLM_SRC_MODELS} ${MIXLM_TGT_MODELS}: SHELL=${LOCAL_SHELL}
${MIXLM_SRC_MODELS}: LM_LANG=${SRC_LANG}
${MIXLM_TGT_MODELS}: LM_LANG=${TGT_LANG}
${MIXLM_SRC_MODELS} ${MIXLM_TGT_MODELS}: %.binlm${GZ}: | models
	[[ -s "${LM_DIR}/$@" ]] && ln -s "${LM_DIR}/$@" . \
	|| ${MAKE} -f ${LM_DIR}/Makefile LM_LANG=${LM_LANG} TRAIN_LM=$(*:_${LM_LANG}-kn-${ORDER}g=) $@

$(notdir ${MIXLM_PRETRAINED_LMS}): SHELL=${LOCAL_SHELL}
$(notdir ${MIXLM_PRETRAINED_SRC_LMS}): %: | pretrained.${SRC_LANG} ;
$(notdir ${MIXLM_PRETRAINED_TGT_LMS}): %: | pretrained.${TGT_LANG} ;

.PHONY: pretrained.${SRC_LANG} pretrained.${TGT_LANG}
pretrained.${SRC_LANG} pretrained.${TGT_LANG}: SHELL=${LOCAL_SHELL}
pretrained.${SRC_LANG} pretrained.${TGT_LANG}: pretrained.%: | models
	${MAKE} -f ../../${LM_DIR}/Makefile $@ LM_PRETRAINED_TGT_LMS="${MIXLM_PRETRAINED_TGT_LMS}"

.PHONY: mixlm
mixlm: $(addsuffix .mixlm, ${TUNE_SETS})

# We will specify that we need the source side sub language models to be
# present before calculating the distance.
$(addsuffix .distances, ${TUNE_SETS}): %.distances: ${MIXLM_SRC_MODELS} $(notdir ${MIXLM_PRETRAINED_SRC_LMS})
$(addsuffix .distances, ${TUNE_SETS}): %.distances: %_${SRC_LANG}${LANGX}

# We will specify that we need the target side sub language models to be
# present before calculating the final mixlm.
$(addsuffix .mixlm, ${TUNE_SETS}): %.mixlm: ${MIXLM_TGT_MODELS} $(notdir ${MIXLM_PRETRAINED_TGT_LMS})
$(addsuffix .mixlm, ${TUNE_SETS}): %.mixlm: %_${SRC_LANG}${LANGX}

# We need the lm to generate the components files.
components_${SRC_LANG}: ${MIXLM_SRC_MODELS} $(notdir ${MIXLM_PRETRAINED_SRC_LMS})
components_${TGT_LANG}: ${MIXLM_TGT_MODELS} $(notdir ${MIXLM_PRETRAINED_TGT_LMS})


########################################
# Create Tightly Packed Language Models.

${MIXLM_TGT_MODELS:.binlm${GZ}=.tplm}: SHELL=${LOCAL_SHELL}
${MIXLM_TGT_MODELS:.binlm${GZ}=.tplm}: %.tplm:
	[[ -s "${LM_DIR}/$@" ]] && ln -s ${LM_DIR}/$@ || ${MAKE} -f ${LM_DIR}/Makefile $@

clean.content: clean.tplm

.PHONY: clean.tplm
clean.tplm: SHELL=${LOCAL_SHELL}
clean.tplm:
	${RM} -r *.tplm


########################################
# Transform model for PortageLive
PORTAGE_LIVE_DEST_DIR ?= ../portageLive/models/mixlm
.PHONY: portageLive
portageLive: SHELL=${LOCAL_SHELL}
ifdef MIXLM_COMPONENTS
portageLive: ${MIXLM_TGT_MODELS:.binlm${GZ}=.tplm} $(notdir ${MIXLM_PRETRAINED_TGT_LMS:.binlm${GZ}=.tplm})
	mkdir -p ${PORTAGE_LIVE_DEST_DIR}
	${RM} -r ${PORTAGE_LIVE_DEST_DIR}/*
	cd ${PORTAGE_LIVE_DEST_DIR} && ln -fs $(addprefix ../../../mixlm/, $+) .
	sed -e 's/.binlm${GZ}/.tplm/g' ${TUNE_DECODE}${PLIVE_DECODE_VARIANT}.mixlm \
		> ${PORTAGE_LIVE_DEST_DIR}/${TUNE_DECODE}${PLIVE_DECODE_VARIANT}.mixlm	
else
portageLive:
	@echo "No MIXLMs defined, nothing to do." >&2
endif

