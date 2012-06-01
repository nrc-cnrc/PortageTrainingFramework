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
MERT ?= tune.py

# How may cpus should MERT be using.
# tune.py requires 16GB memory for java.
MERT_CPUS ?= 4
# How may cpus should each decode worker be using when doing MERT.
DECODE_CPUS ?= 1

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
	${RM} -r logs/

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
$(info LDM: ${LDM})
LDM := $(and ${USE_LDM},${LDM}\#L)

# Parameters to use Lexicalized Distortion Models.
LDM_PARAMS  := back-lex\#m\#L:back-lex\#s\#L:back-lex\#d\#L:fwd-lex\#m\#L:fwd-lex\#s\#L:fwd-lex\#d\#L
endif

ifdef USE_HLDM
HLDM ?= $(wildcard models/ldm/hldm.*.${SRC_LANG}2${TGT_LANG}.gz)
ifeq ("","$(or $(strip ${HLDM}),$(findstring clean,${MAKECMDGOALS}))")
$(warning "No HLDMs available. Have you trained at least a distortion model?")
endif
$(info HLDM: ${HLDM})
HLDM := $(and ${USE_HLDM},${HLDM}\#H)

# Parameters to use Hierarchical Lexicalized Distortion Models.
HLDM_PARAMS := back-hlex\#m\#H:back-hlex\#s\#H:back-hlex\#d\#H:fwd-hlex\#m\#H:fwd-hlex\#s\#H:fwd-hlex\#d\#H
endif

# NOTE: We need to keep the checks here AND in the target UNTUNED_DECODING_MODEL.
CPT_SEARCH := models/tm/cpt.*${SRC_LANG}2${TGT_LANG}.gz
CPTS ?= $(wildcard ${CPT_SEARCH})
ifeq ("","$(or $(strip ${CPTS}),$(findstring clean,${MAKECMDGOALS}))")
$(warning No CPTs available. Have you trained at least one translation model?)
endif
$(info CPTs: ${CPTS})

LM_SEARCH := models/lm/*${TGT_LANG}*.binlm.gz models/mixlm/${TUNE_DECODE}.mixlm
LMS  ?= $(wildcard ${LM_SEARCH})
ifeq ("","$(or $(strip ${LMS}),$(findstring clean,${MAKECMDGOALS}))")
$(warning No LMs available. Have you trained at least one language model?)
endif
$(info LMs: ${LMS})

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
	| configtool -p "args:$(and ${USE_LDM}${USE_HLDM}, -no-dist-limit-simple -dist-phrase-swap -dist-limit-ext) -distortion-model WordDisplacement:${LDM_PARAMS}:${HLDM_PARAMS} -lex-dist-model-file :${LDM}:${HLDM} ${CANOE_INI_EXTRAS}" - \
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
	RP_PSUB_OPTS="-${DECODE_CPUS} -N tune.decode.model" \
	filter_models -z -r -soft-limit cpt.${TUNE_DECODE} -ldm < $(filter %${TUNE_DECODE_SRC},$+)
	RP_PSUB_OPTS="-${MERT_CPUS} -N tune.decode.model" \
	${MERT} \
		-v \
		-o $@.FILT \
		-p ${PARALLELISM_LEVEL_TUNE_DECODE} \
		-c ${DECODE_CPUS} \
		-m ${MERT_MAX_ITER} \
		-n 100 \
		-a lmira \
		--workdir=foos \
		${MERT_EXTRAS} \
		-f $<.FILT $(wordlist 2,3,$+) \
		>& log.$@
	_LOCAL=1 configtool -p args:"`configtool weights $@.FILT`" $< > $@
	_LOCAL=1 ${RM} -r foos *.FILT.gz *.FILT.bkoff ${UNTUNED_DECODING_MODEL}.FILT ${UNTUNED_DECODING_MODEL}.FILT.cow

clean.content: clean.tune

.PHONY: clean.tune
clean.tune: SHELL=${GUARD_SHELL}
clean.tune:
	${RM} -r foos canoe-parallel.* run-p.*
	${RM} ${DECODING_MODEL}
	${RM} ${UNTUNED_DECODING_MODEL} ${UNTUNED_DECODING_MODEL}.FILT ${UNTUNED_DECODING_MODEL}.FILT.cow
	${RM} *.FILT.gz *.FILT.bkoff
	${RM} summary summary.wts
	${RM} decode-config



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
.PHONY: testsuite
testsuite:  unittest1
testsuite:  unittest2
testsuite:  unittest3
testsuite:  unittest4

# Create a canoe.ini without any Lexicalized Distortion Models what so ever.
unittest1:
	${MAKE} USE_LDM= USE_HLDM= canoe.ini -B
	grep '^\[lex-dist-model-file\] --$$' canoe.ini
	! egrep 'back-lex' canoe.ini
	! egrep 'fwd-lex' canoe.ini
	! grep '^\[no-dist-limit-simple\]$$' canoe.ini
	! grep '^\[dist-phrase-swap\]$$' canoe.ini
	! grep '^\[dist-limit-ext\]$$' canoe.ini

# Create a canoe.ini that uses Lexicalized Distortion Models.
unittest2:
	${MAKE} USE_LDM=1 USE_HLDM= canoe.ini -B
	grep '[^h]ldm.hmm3+ibm2.en2fr.gz' canoe.ini
	! grep 'hldm.hmm3+ibm2.en2fr.gz' canoe.ini
	egrep 'back-lex' canoe.ini
	! egrep 'back-hlex' canoe.ini
	egrep 'fwd-lex' canoe.ini
	! egrep 'fwd-hlex' canoe.ini
	grep '^\[no-dist-limit-simple\]$$' canoe.ini
	grep '^\[dist-phrase-swap\]$$' canoe.ini
	grep '^\[dist-limit-ext\]$$' canoe.ini

# Create a canoe.ini that uses Hierarchical Lexicalized Distortion Models.
unittest3:
	${MAKE} USE_LDM= USE_HLDM=1 canoe.ini -B
	! grep '[^h]ldm.hmm3+ibm2.en2fr.gz' canoe.ini
	grep 'hldm.hmm3+ibm2.en2fr.gz' canoe.ini
	! egrep 'back-lex' canoe.ini
	egrep 'back-hlex' canoe.ini
	! egrep 'fwd-lex' canoe.ini
	egrep 'fwd-hlex' canoe.ini
	grep '^\[no-dist-limit-simple\]$$' canoe.ini
	grep '^\[dist-phrase-swap\]$$' canoe.ini
	grep '^\[dist-limit-ext\]$$' canoe.ini

# Create a canoe.ini that uses Lexicalized Distortion Models & Hierarchical Lexicalized Distortion Models.
unittest4:
	${MAKE} USE_LDM=1 USE_HLDM=2 canoe.ini -B
	grep '[^h]ldm.hmm3+ibm2.en2fr.gz' canoe.ini
	grep 'hldm.hmm3+ibm2.en2fr.gz' canoe.ini
	egrep 'back-lex' canoe.ini
	egrep 'back-hlex' canoe.ini
	egrep 'fwd-lex' canoe.ini
	egrep 'fwd-hlex' canoe.ini
	grep '^\[no-dist-limit-simple\]$$' canoe.ini
	grep '^\[dist-phrase-swap\]$$' canoe.ini
	grep '^\[dist-limit-ext\]$$' canoe.ini

