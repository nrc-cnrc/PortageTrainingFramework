#!/usr/bin/make -f
# vim:noet:ts=3:nowrap
#
# $Id$
# @author Samuel Larkin
# @file Makefile
# @brief Tunes/trains a decoding model.
#
# Technologies langagieres interactives / Interactive Language Technologies
# Inst. de technologie de l'information / Institute for Information Technology
# Conseil national de recherches Canada / National Research Council Canada
# Copyright 2008, Sa Majeste la Reine du Chef du Canada
# Copyright 2008, Her Majesty in Right of Canada


# Mandatory include: master config file.
include ../../Makefile.params

# Include the config file.
MAKEFILE_PARAMS ?= Makefile.params
-include ${MAKEFILE_PARAMS}

# Lastly include the master toolkit
include ../../Makefile.toolkit


# What is this module's name.
MODULE_NAME ?= decode

# Define languages info.
#SRC_LANG ?= en
#TGT_LANG ?= fr
SRCX  ?= ${RULEX}
TGTX  ?= _${TGT_LANG}${LANGX}

# Untuned decoding model
UNTUNED_DECODING_MODEL ?= canoe.ini

# Indicates where to find the canoe.ini template
TEMPLATE_DIR            ?= ./
DECODING_MODEL_TEMPLATE ?= ${UNTUNED_DECODING_MODEL}.template

# Tuned decoding model
DECODING_MODEL ?= ${UNTUNED_DECODING_MODEL}.cow

# Will indicate to make where to find the SETs (dev & test & eval)
CORPORA_DIR ?= ../../corpora

# Indicates where to find all models.
MODEL_DIR ?= ../../models

# Indicates what prefix/file to use for training a decoder model
TUNE_DECODE     ?= dev1
# What source file to use for tuning the decoder.
TUNE_DECODE_SRC  := ${TUNE_DECODE}${SRCX}
# What reference files to use for tuning the decoder.
TUNE_DECODE_TGTS  := $(notdir $(wildcard ${CORPORA_DIR}/${TUNE_DECODE}_${TGT_LANG}*${LANGX}))

# Specific PSUB options
PSUB_OPTS ?= 

# Extra canoe parameters that a user would want to include in its canoe.ini.
# i.e. -d 1:1:1:1:1:1:1 -load-first
CANOE_INI_EXTRAS ?=

# Indicates the nbest list size.
NBEST_SIZE ?= 1000

# Number of parallel chunks to process.
PARALLELISM_LEVEL_TUNE_DECODE ?= 5

# What program to use to do MERT.
MERT ?= cow.sh

# How may cpus should each worker be using when doing MERT.
MERT_CPUS ?= 1

# What is the maximum number of iterations mert should do?
MERT_MAX_ITER ?= 15

# If you need to add any other options to MERT.
MERT_EXTRAS ?=

# Track memory usage.
TIME_MEM ?= time-mem

# After this Makefile, the following targets/files are precious.
FILES_TO_BE_LOCKED = ${DECODING_MODEL}

########################################
# SETUP
ifneq (${MAKECMDGOALS},clean)
ifneq (${MAKECMDGOALS},clean.content)
ifneq (${MAKECMDGOALS},clean.logs)
$(shell ln -fs ${MODEL_DIR})
endif
endif
endif



.DEFAULT_GOAL := help
.SECONDARY:
.DELETE_ON_ERROR:

# Threre are two differents vpath for heldout because in the chinese case for example the src_ext != tgt_ext
vpath %${SRCX}  ${CORPORA_DIR}
vpath %${TGTX}  ${CORPORA_DIR}
vpath %${LANGX}  ${CORPORA_DIR}
vpath %${RULES} ${CORPORA_DIR}
vpath ${DECODING_MODEL_TEMPLATE} ${TEMPLATE_DIR}



.PHONY: all
all: train



.PHONY: help
help: SHELL=${GUARD_SHELL}
help:
	@echo "Tune a system."
	@echo
	@echo "To tune your models, type: make all"
	@echo
	@echo "The main targets in this Makefile are:"
	@cat $(firstword $(MAKEFILE_LIST)) | egrep '^.PHONY:' | sed 's#^.PHONY: #   #'



# What the user can expect from this module.
.PHONY: list_final_output
list_final_output: SHELL=${GUARD_SHELL}
list_final_output:
	@echo "Expected final output:"
	@echo "${DECODING_MODEL}"



########################################
# Clean up
.PHONY: clean clean.content clean.logs hide.logs
clean: SHELL=${GUARD_SHELL}
clean: clean.content clean.logs

clean.content: SHELL=${GUARD_SHELL}
clean.content:
	${RM} models

clean.logs: SHELL=${GUARD_SHELL}
clean.logs:
	${RM} log.* run-parallel-logs*

# Hide logs from user's view into .logs
hide.logs: SHELL=${GUARD_SHELL}
hide.logs: hide_logs_sub



########################################
# Resources Summary
.PHONY: time-mem
time-mem: SHELL=${GUARD_SHELL}
time-mem: resource_summary_sub



########################################
# Is the template present?
.PHONY: check_template
check_template: SHELL=${GUARD_SHELL}
check_template:
	@[[ -f ${TEMPLATE_DIR}/${DECODING_MODEL_TEMPLATE} ]] \
	|| ! echo "ERROR: Cannot find this template: ${DECODING_MODEL_TEMPLATE}" >&2



########################################
# Create canoe.ini from template.
ifdef USE_LDM
LDM ?= $(wildcard models/ldm/ldm.*.${SRC_LANG}2${TGT_LANG}.gz)
ifeq ("","$(or $(strip ${LDM}),$(findstring clean,${MAKECMDGOALS}))")
$(warning "No LDMs available. Have you trained at least a distortion model?")
endif

DISTORTION ?= -dist-phrase-swap -dist-limit-ext -lex-dist-model-file ${LDM} -distortion-model WordDisplacement:back-lex\#m:back-lex\#s:back-lex\#d:fwd-lex\#m:fwd-lex\#s:fwd-lex\#d
else
DISTORTION ?= -distortion-model WordDisplacement
endif

# NOTE: We need to keep the checks here AND in the target UNTUNED_DECODING_MODEL.
CPT_SEARCH := models/tm/cpt.*${SRC_LANG}2${TGT_LANG}.gz
CPTS ?= $(wildcard ${CPT_SEARCH})
ifeq ("","$(or $(strip ${CPTS}),$(findstring clean,${MAKECMDGOALS}))")
$(warning No CPTs available. Have you trained at least one translation model?)
endif

LM_SEARCH := models/lm/*${TGT_LANG}*.binlm.gz models/mixlm/${TUNE_DECODE}.mixlm
LMS  ?= $(wildcard ${LM_SEARCH})
ifeq ("","$(or $(strip ${LMS}),$(findstring clean,${MAKECMDGOALS}))")
$(warning No LMs available. Have you trained at least one language model?)
endif

${UNTUNED_DECODING_MODEL}: SHELL=${GUARD_SHELL}
${UNTUNED_DECODING_MODEL}: ${DECODING_MODEL_TEMPLATE}
	@ls ${CPT_SEARCH} &> /dev/null \
	|| ! echo "ERROR: No CPTs available. Please train the translation model(s) first!" >&2
	@[[ `ls ${LM_SEARCH} 2> /dev/null | \wc -l` > 0 ]] \
	|| ! echo "ERROR: No LMs available. Please train the language model(s) first!" >&2
	cat $< \
	| sed -e 's/<SL>/${SRC_LANG}/g' \
	      -e 's/<TL>/${TGT_LANG}/g' \
	      -e 's#<CPTS>#${CPTS}#g' \
	      -e 's#<LMS>#${LMS}#g' \
	      -e 's/^\(\[\(weight-f\|ftm\)\]\)/##mid##\1/' \
	| configtool -p "args:${DISTORTION} ${CANOE_INI_EXTRAS}" - \
	> $@
	configtool check $@

clean.content: clean.canoe.ini

.PHONY: clean.canoe.ini
clean.canoe.ini: SHELL=${GUARD_SHELL}
clean.canoe.ini:
	${RM} ${DECODING_MODEL} tmp.${UNTUNED_DECODING_MODEL}



########################################
# Training a decoding model.
.PHONY: train
train: ${DECODING_MODEL}
${DECODING_MODEL}: SHELL=${FRAMEWORK_SHELL}
${DECODING_MODEL}: ${UNTUNED_DECODING_MODEL} ${TUNE_DECODE_SRC} ${TUNE_DECODE_TGTS}
	_LOCAL=1 mkdir -p foos
	RP_PSUB_OPTS="-${MERT_CPUS} -N tune.decode.model" \
	${MERT} \
		-v \
		-parallel:"-n ${PARALLELISM_LEVEL_TUNE_DECODE}" \
		-maxiter ${MERT_MAX_ITER} \
		-nbest-list-size 100 \
		-filt \
		-nofloor \
		-workdir foos \
		${MERT_EXTRAS} \
		-f $^ \
		>& log.$@
	_LOCAL=1 ${RM} -r foos *.FILT.gz *.FILT.bkoff ${UNTUNED_DECODING_MODEL}.FILT ${UNTUNED_DECODING_MODEL}.FILT.cow

clean.content: clean.cow

.PHONY: clean.cow
clean.cow: SHELL=${GUARD_SHELL}
clean.cow:
	${RM} -r foos canoe-parallel.* run-p.*
	${RM} ${DECODING_MODEL}
	${RM} ${UNTUNED_DECODING_MODEL} ${UNTUNED_DECODING_MODEL}.FILT ${UNTUNED_DECODING_MODEL}.FILT.cow
	${RM} *.FILT.gz *.FILT.bkoff rescore-results*



################################################################################
# Instructions for portageLive
# NOTE: you cannot apply weights if you plan to do some rescoring.

PORTAGE_LIVE_DEST_DIR ?= ../portageLive
CANOE_LIVE            ?= ${PORTAGE_LIVE_DEST_DIR}/${DECODING_MODEL}

.PHONY: portageLive
portageLive: SHELL=${GUARD_SHELL}
portageLive: ${CANOE_LIVE}


.PHONY: portageLive_models
portageLive_models_%: SHELL=${GUARD_SHELL}
portageLive_models_%:
	${MAKE} -C ../$* portageLive


${CANOE_LIVE}: SHELL=${GUARD_SHELL}
${CANOE_LIVE}: portageLive_models_lm portageLive_models_tm portageLive_models_ldm
${CANOE_LIVE}: ${DECODING_MODEL}
	mkdir -p ${PORTAGE_LIVE_DEST_DIR}
	configtool -p tp $< > $@
	configtool check $@


clean.content: clean.portageLive
.PHONY: clean.portageLive
clean.portageLive: SHELL=${GUARD_SHELL}
clean.portageLive:
	${RM} ${CANOE_LIVE}



################################################################################
# HELPERS
