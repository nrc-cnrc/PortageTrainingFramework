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

# TODO: Make this Makefile work with run-parallel.sh -c
export SHELL = ${FRAMEWORK_SHELL}

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
TUNE_DECODE_SRC  = ${TUNE_DECODE}${SRCX}
# What target file to use for tuning the decoder.
TUNE_DECODE_TGT  = ${TUNE_DECODE}${TGTX}

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

# After this Makefile, the following targets/files are precious.
FILES_TO_BE_LOCKED = ${DECODING_MODEL}

########################################
# SETUP
SETUP_FORCE_MODELS_LINKS := $(shell ln -fs ${MODEL_DIR})



.DEFAULT_GOAL := help
.SECONDARY:
.DELETE_ON_ERROR:

# Threre are two differents vpath for heldout because in the chinese case for example the src_ext != tgt_ext
vpath %${SRCX}  ${CORPORA_DIR}
vpath %${TGTX}  ${CORPORA_DIR}
vpath %${RULES} ${CORPORA_DIR}
vpath ${DECODING_MODEL_TEMPLATE} ${TEMPLATE_DIR}



.PHONY: all
all: train



.PHONY: help
help: SHELL=${GUARD_SHELL}
help:
	@echo "This script allows to tune a system."
	@echo "Possible targets are:"
	@cat $(firstword $(MAKEFILE_LIST)) | egrep '^.PHONY:' | sed 's#^.PHONY: ##'
	@echo "Most likely you want to do either: make all"



# What the user can expect from this module.
.PHONY: list_final_output
list_final_output: SHELL=${GUARD_SHELL}
list_final_output:
	@echo "Expected final output:"
	@echo "${DECODING_MODEL}"



# Clean up
.PHONY: clean
clean: SHELL=${GUARD_SHELL}
clean:
	${RM} models

.PHONY: clean.content
clean: clean.content
clean.content: SHELL=${GUARD_SHELL}



########################################
# resources summary
.PHONY: summary
summary: resource_summary_sub



########################################
# Clean logs.
clean: clean.logs

.PHONY: clean.logs
clean.logs: SHELL=${GUARD_SHELL}
clean.logs:
	${RM} log.* run-parallel-logs*



########################################
# Is the template present?
.PHONY: check_template
check_template: SHELL=${GUARD_SHELL}
check_template:
	@if [[ ! -f ${TEMPLATE_DIR}/${DECODING_MODEL_TEMPLATE} ]]; then \
		echo "Cannot find this template: ${DECODING_MODEL_TEMPLATE}" >&2; \
		false; \
	fi



########################################
# Create canoe.ini from template.
ifdef USE_LDM
LDM ?= $(wildcard models/ldm/ldm.*.${SRC_LANG}2${TGT_LANG}.gz)
ifeq ("$(strip ${LDM})","")
$(warning "No LDMs, Please train some ldm in models/ldm.")
endif

DISTORTION ?= -dist-phrase-swap -dist-limit-ext -lex-dist-model-file ${LDM} -distortion-model WordDisplacement:back-lex\#m:back-lex\#s:back-lex\#d:fwd-lex\#m:fwd-lex\#s:fwd-lex\#d
else
DISTORTION ?= -distortion-model WordDisplacement
endif

CPTS ?= $(wildcard models/tm/cpt.*${SRC_LANG}2${TGT_LANG}.gz)
ifeq ("$(strip ${CPTS})","")
$(warning "No CPTs, Is it possible that you haven't trained at least one translation model?")
endif

LMS  ?= $(wildcard models/lm/*${TGT_LANG}*.binlm.gz)
ifeq ("$(strip ${LMS})","")
$(warning "No LMs, Is it possible that you haven't trained at least one language model?")
endif

${UNTUNED_DECODING_MODEL}: SHELL=${GUARD_SHELL}
${UNTUNED_DECODING_MODEL}: ${DECODING_MODEL_TEMPLATE}
	@ls models/tm/cpt.* &> /dev/null || \
		(echo "ERROR: Is it possible that you haven't trained at least one translation model?" >&2; \
		false;)
	@ls models/lm/*.binlm.gz &> /dev/null || \
		(echo "ERROR: Is it possible that you haven't trained at least one language model?" >&2; \
		false;)
	cat $< \
	| sed -e 's/<SL>/${SRC_LANG}/g' \
	      -e 's/<TL>/${TGT_LANG}/g' \
	      -e 's#<CPTS>#${CPTS}#g' \
	      -e 's#<LMS>#${LMS}#g' \
	      -e 's/^\(\[\(weight-f\|ftm\)\]\)/##mid##\1/' \
	> tmp.$@
	WT=$$(perl -e 'print 1; print ":1" foreach (2..`configtool nt tmp.$@`)'); \
	cat tmp.$@ \
	| sed -e "s/^##mid##//" \
	      -e "s/<ENABLE_FTM>/$$WT/" \
	| configtool -p "args:${DISTORTION} ${CANOE_INI_EXTRAS}" - \
	> $@
	rm tmp.$@
	configtool check $@

clean.content: clean.canoe.ini

.PHONY: clean.canoe.ini
clean.canoe.ini: SHELL=${GUARD_SHELL}
clean.canoe.ini:
	-${RM} ${DECODING_MODEL}



########################################
# Training a decoding model.
.PHONY: train
train: ${DECODING_MODEL}
${DECODING_MODEL}: ${UNTUNED_DECODING_MODEL} ${TUNE_DECODE_SRC} ${TUNE_DECODE_TGT}
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
		-f $^ \
		>& log.$@
	_LOCAL=1 ${RM} -r foos multi.probs.*.FILT.gz ${UNTUNED_DECODING_MODEL}.FILT ${UNTUNED_DECODING_MODEL}.FILT.cow

clean.content: clean.cow

.PHONY: clean.cow
clean.cow: SHELL=${GUARD_SHELL}
clean.cow:
	-${RM} -r foos canoe-parallel.* run-p.*
	-${RM} ${DECODING_MODEL}
	-${RM} ${UNTUNED_DECODING_MODEL} ${UNTUNED_DECODING_MODEL}.FILT ${UNTUNED_DECODING_MODEL}.FILT.cow
	-${RM} multi.probs.*.FILT.gz rescore-results*



########################################
# Instructions for portageLive
# NOTE: you cannot apply weights if you plan to do some rescoring.

PORTAGE_LIVE_DEST_DIR ?= ../portageLive/models
.PHONY: portageLive
portageLive: SHELL=${GUARD_SHELL}
portageLive: canoe.ini.cow.live check_canoe_live
	configtool tp $< \
	| sed -e 's#\(cpt.${SRC_LANG}2${TGT_LANG}.tppt\)#models/tm/\1#' \
	> ../portageLive/canoe.ini.cow
	mkdir -p ${PORTAGE_LIVE_DEST_DIR}/tm
	${RM} -r ${PORTAGE_LIVE_DEST_DIR}/tm/*
	cd ${PORTAGE_LIVE_DEST_DIR}/tm && ln -fs `configtool list-tm ../../../decode/$<` .
	${MAKE} -C ../lm $(shell configtool list-lm $< | sed -e 's#.*/##')
	mkdir -p ${PORTAGE_LIVE_DEST_DIR}/lm
	cd ${PORTAGE_LIVE_DEST_DIR}/lm && ln -fs `configtool list-lm ../../../decode/$<` .
	if [[ `configtool list-ldm $<` ]]; then \
		${MAKE} -C ../ldm $(shell configtool list-ldm $< | sed -e 's#.*/##'); \
		mkdir -p ${PORTAGE_LIVE_DEST_DIR}/ldm; \
		${RM} -r ${PORTAGE_LIVE_DEST_DIR}/ldm/*; \
		cd ${PORTAGE_LIVE_DEST_DIR}/ldm && ln -fs `configtool list-ldm ../../../decode/$<` .; \
	fi

ONE_CPT ?= one.cpt.en2fr.gz

# Make a single phrase table from all the phraase tables.
${ONE_CPT}: SHELL=${FRAMEWORK_SHELL}
${ONE_CPT}: canoe.ini.cow
	RP_PSUB_OPTS="-1 -N vm.join -nodes bigtmp" \
	join_phrasetables -v `configtool list-multi-probs $<` \
	| gzip \
	> $@

# fix the canoe.ini.cow to reflect the usage of a single phrase table.
canoe.ini.cow.hardFilter: ${GUARD_SHELL}
canoe.ini.cow.hardFilter: ${ONE_CPT} canoe.ini.cow
	configtool rep-multi-prob:$< canoe.ini.cow > $@


# When using Portage, the default behavior should be to create tppt models.
APPLY_WEIGHTS_OPTIONS ?= -tppt
# Hard filter & tpptize the single phrase table.
canoe.ini.cow.live: SHELL=${FRAMEWORK_SHELL}
cpt.${SRC_LANG}2${TGT_LANG}.tppt: SHELL=${FRAMEWORK_SHELL}
cpt.${SRC_LANG}2${TGT_LANG}.tppt canoe.ini.cow.live: canoe.ini.cow.hardFilter
	RP_PSUB_OPTS="-8 -N vm.tppt" \
	tmtext-apply-weights.pl \
		-hf ${APPLY_WEIGHTS_OPTIONS} \
		-src ${SRC_LANG} -tgt ${TGT_LANG} \
		-f $< -c canoe.ini.cow.live \
		-o cpt

# We need to output a new canoe.ini.cow that reflects the single tppt and applied weights.
.PHONY: check_canoe_live
check_canoe_live: SHELL=${GUARD_SHELL}
check_canoe_live: canoe.ini.cow.live
	configtool check $<

clean: clean.portageLive
.PHONY: clean.portageLive
clean.portageLive: SHELL=${GUARD_SHELL}
clean.portageLive:
	-${RM} -r canoe.ini.cow.hardFilter canoe.ini.cow.live cpt.fr2en.gz cpt.fr2en.tppt one.cpt.en2fr.gz
	-${RM} -r portageLive



########################################
# How to prepare PORTAGEsharedLive.
# Same thing as portageLive except tptizing is not supported.
# NOTE: since hard filtering a model will append FILT to the name, it is safe
# reuse ${ONE_CPT} as the hard-filtered model's name.
.PHONY: PORTAGEsharedLive
PORTAGEsharedLive: APPLY_WEIGHTS_OPTIONS=
PORTAGEsharedLive: portageLive
	@true



################################################################################
# HELPERS
