#!/usr/bin/make -f
# vim:noet:ts=3:nowrap:filetype=make

# @file Makefile
# @brief Create mixlm files.
#
# @author Samuel Larkin and Darlene Stewart
#
# Traitement multilingue de textes / Multilingual Text Processing
# Tech. de l'information et des communications / Information and Communications Tech.
# Conseil national de recherches Canada / National Research Council Canada
# Copyright 2011, 2015, Sa Majeste la Reine du Chef du Canada /
# Copyright 2011, 2015, Her Majesty in Right of Canada


# Mandatory include: master config file.
include ../../Makefile.params

# Include the config file.
MAKEFILE_PARAMS ?= Makefile.params
-include ${MAKEFILE_PARAMS}

include Makefile.toolkit

# Include the master toolkit
include ../../Makefile.toolkit

# Override the default LM ORDER setting in the LM Makefile.toolkit
ORDER ?= 5

# Include the LM toolkit
include ../lm/Makefile.toolkit


# What is this module's name.
MODULE_NAME ?= mixlm

# Resource monitoring.
TIME_MEM ?= time-mem

# Where to find all models to create a symbolic link
MODEL_DIR ?= ../../models

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
vpath %_${SRC_LANG}${LANGXZ} ../../corpora
vpath %_${TGT_LANG}${LANGX} ../../corpora
vpath %_${TGT_LANG}${LANGXZ} ../../corpora


########################################
# SETUP
ifneq ($(filter-out clean clean.content clean.logs, ${MAKECMDGOALS}),)
$(info ln -fs ${MODEL_DIR})
$(shell ln -fs ${MODEL_DIR})
endif

########################################


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
	${RM} -r *.tplm

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


MIXLM_SRC_MODELS := $(foreach lm, ${MIXLM}, $(or $(notdir $(wildcard ${lm}_${SRC_LANG}*.binlm${GZ})), \
                                                 $(notdir $(wildcard ${LM_DIR}/${lm}_${SRC_LANG}*.binlm${GZ})), \
                                                 ${lm}_${SRC_LANG}-kn-${ORDER}g.binlm${GZ}))

LMDIR_SRC_MODELS := $(foreach lm, ${MIXLM}, $(if $(notdir $(wildcard ${lm}_${SRC_LANG}*.binlm${GZ})),, \
                                                       $(notdir $(wildcard ${LM_DIR}/${lm}_${SRC_LANG}*.binlm${GZ}))))

LOCAL_SRC_MODELS := $(foreach lm, ${MIXLM}, $(or $(notdir $(wildcard ${lm}_${SRC_LANG}*.binlm${GZ})), \
                                                 $(if $(notdir $(wildcard ${LM_DIR}/${lm}_${SRC_LANG}*.binlm${GZ})),, \
                                                      ${lm}_${SRC_LANG}-kn-${ORDER}g.binlm${GZ})))

MIXLM_TGT_MODELS := $(foreach lm, ${MIXLM}, $(or $(notdir $(wildcard ${lm}_${TGT_LANG}*.binlm${GZ})), \
                                                 $(notdir $(wildcard ${LM_DIR}/${lm}_${TGT_LANG}*.binlm${GZ})), \
                                                 ${lm}_${TGT_LANG}-kn-${ORDER}g.binlm${GZ}))

LMDIR_TGT_MODELS := $(foreach lm, ${MIXLM}, $(if $(notdir $(wildcard ${lm}_${TGT_LANG}*.binlm${GZ})),, \
                                                       $(notdir $(wildcard ${LM_DIR}/${lm}_${TGT_LANG}*.binlm${GZ}))))

LOCAL_TGT_MODELS := $(foreach lm, ${MIXLM}, $(or $(notdir $(wildcard ${lm}_${TGT_LANG}*.binlm${GZ})), \
                                                 $(if $(notdir $(wildcard ${LM_DIR}/${lm}_${TGT_LANG}*.binlm${GZ})),, \
                                                      ${lm}_${TGT_LANG}-kn-${ORDER}g.binlm${GZ})))

MIXLM_PRETRAINED_LMS := ${MIXLM_PRETRAINED_SRC_LMS} ${MIXLM_PRETRAINED_TGT_LMS}

.PHONY: sublm sublm.${SRC_LANG} sublm.${TGT_LANG}
sublm: sublm.${SRC_LANG}
sublm: sublm.${TGT_LANG}
sublm.${SRC_LANG}: ${MIXLM_SRC_MODELS}
sublm.${TGT_LANG}: ${MIXLM_TGT_MODELS}

# Create Language Models.
# If for some reason one of the sublm was already created in models/lm, don't
# recreate it, just link to it; otherwise build it here in the mixlm directory.
${LMDIR_SRC_MODELS} ${LMDIR_TGT_MODELS}: %.binlm${GZ}:
	ln -sf "${LM_DIR}/$@" .
	[[ ! -d "${LM_DIR}/${@:.binlm${GZ}=.tplm}" ]] || ln -sf "${LM_DIR}/${@:.binlm${GZ}=.tplm}" .

# Specify corpus dependencies for the component LMs
$(foreach lm, ${MIXLM}, $(if $(filter ${lm}_${SRC_LANG}%, ${LOCAL_SRC_MODELS}), \
	$(eval $(call LM_CORP_DEP,$(filter ${lm}_${SRC_LANG}%, ${LOCAL_SRC_MODELS:.binlm${GZ}=}),${lm}_${SRC_LANG}${LANGX}${GZ}))) \
)

$(foreach lm, ${MIXLM}, $(if $(filter ${lm}_${TGT_LANG}%, ${LOCAL_TGT_MODELS}), \
	$(eval $(call LM_CORP_DEP,$(filter ${lm}_${TGT_LANG}%, ${LOCAL_TGT_MODELS:.binlm${GZ}=}),${lm}_${TGT_LANG}${LANGX}${GZ}))) \
)

$(foreach p, ${MIXLM_PRETRAINED_LMS}, \
	$(eval \
   	$(notdir ${p}): ${p}) \
)

$(notdir ${MIXLM_PRETRAINED_LMS}): SHELL=${LOCAL_SHELL}
$(notdir ${MIXLM_PRETRAINED_LMS}):
	@[[ ! -e $@ ]] || [[ -L $@ ]] || ! echo "ERROR: LM $@ already exists as a normal file."
	@$(if $(filter-out %.binlm${GZ}, $@),! echo "ERROR: Name of pre-trained LM file must end with .binlm${GZ}: $<")
	ln -sf $< .
	[[ ! -d ${<:.binlm${GZ}=.tplm} ]] || ln -sf ${<:.binlm.gz=.tplm} .

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

