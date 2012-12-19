#!/usr/bin/make -f
# vim:noet:ts=3:nowrap
#
# @author Samuel Larkin
# @file Makefile
# @brief Tunes/trains a rescoring model.
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
MODULE_NAME ?= rescore

# Define languages info.
#SRC_LANG ?= en
#TGT_LANG ?= fr
SRCX  ?= _${SRC_LANG}${LANGX}
TGTX  ?= ${LANGX}

# TODO: This may be obsoliete.
SRC_GIVEN_TGT  = ${TRAIN_TM}.${SRC_LANG}_given_${TGT_LANG}
TGT_GIVEN_SRC  = ${TRAIN_TM}.${TGT_LANG}_given_${SRC_LANG}
SRC_GIVEN_TGTX = ${SRC_GIVEN_TGT}.gz
TGT_GIVEN_SRCX = ${TGT_GIVEN_SRC}.gz

# Indicates where to find all models.
# This is used to create a symbolic link.
MODEL_DIR ?= ../../models

# What will be the name of the rescoring model file.
RESCORING_MODEL ?= rescore-model
RESCORING_MODEL_TEMPLATE ?= ${RESCORING_MODEL}.template
UNTUNED_RESCORING_MODEL ?= ${RESCORING_MODEL}.ini

# Indicates where to find the canoe.ini template
DECODING_MODEL_DIR ?= models/decode
DECODING_MODEL     ?= canoe.ini.cow

# Indicates where to find the IBM models.
IBM_DIR ?= models/tm

# Will indicate to make where to find the SETs (dev & test & eval)
CORPORA_DIR ?= ../../corpora

# Indicates what prefix/file to use for training a rescoring model
TUNE_RESCORE      ?= dev2
TUNE_RESCORE_SRC   = ${TUNE_RESCORE}${SRCX}
TUNE_RESCORE_TGTS := $(call CREATE_REFERENCE_NAMES, ${TUNE_RESCORE})
TUNE_RESCORE_RULE  = ${TUNE_RESCORE}${RULEX}

# Specific PSUB options
PSUB_OPTS ?= 

# Indicates the nbest list size.
NBEST_SIZE ?= 1000

# Number of parallel chunks to process.
PARALLELISM_LEVEL_TUNE_RESCORE ?= 5

# After this Makefile, the following targets/files are precious.
FILES_TO_BE_LOCKED = ${RESCORING_MODEL}

# How many cpus should each worker should be using when translating.
RAT_TRANS_CPUS ?= 1

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
.SUFFIXES:
.DELETE_ON_ERROR:

# Threre are two differents vpath for heldout because in the chinese case for example the src_ext != tgt_ext
vpath %${SRCX}  ${CORPORA_DIR}
vpath %${TGTX}  ${CORPORA_DIR}
vpath %${RULEX} ${CORPORA_DIR}



.PHONY: all
all: train



.PHONY: help
help: SHELL=${LOCAL_SHELL}
help:
	@echo "Train a rescoring model."
	@echo
	@echo "To train rescoring, type: make all"
	@echo
	@echo "The main targets in this Makefile are:"
	@cat $(firstword $(MAKEFILE_LIST)) | egrep '^.PHONY:' | sed 's#^.PHONY: #   #'



# What the user can expect from this module.
.PHONY: list_final_output
list_final_output: SHELL=${LOCAL_SHELL}
list_final_output:
	@echo "Expected final output(s):"
	@echo "${RESCORING_MODEL}"



########################################
# Clean up
.PHONY: clean clean.content clean.logs hide.logs
clean: SHELL=${LOCAL_SHELL}
clean: clean.content clean.logs

clean.content: SHELL=${LOCAL_SHELL}
clean.content:
	${RM} -r canoe-parallel.* run-p.*
	${RM} models

clean.logs: SHELL=${LOCAL_SHELL}
clean.logs:
	${RM} log.* run-parallel-logs*

# Hide logs from user's view into .logs
hide.logs: SHELL=${LOCAL_SHELL}
hide.logs: hide_logs_sub



########################################
# Resources Summary
.PHONY: time-mem
time-mem: SHELL=${LOCAL_SHELL}
time-mem: resource_summary_sub



########################################
# Check if there is a trained decoding model available
# Cannot be phony or it will always trigger remaking all targets.
check_decoding_model: SHELL=${LOCAL_SHELL}
check_decoding_model:
	@[[ -e ${DECODING_MODEL_DIR}/${DECODING_MODEL} ]] \
	|| ! echo "ERROR: No decoding model (${DECODING_MODEL}) available. Please train ${DECODING_MODEL_DIR} first!" >&2



########################################
# CREATE A DEFAULT RESCORE MODEL
# requires: a trained decoding model.
# This provides the default rescore-model.ini.
${UNTUNED_RESCORING_MODEL}: SHELL=${LOCAL_SHELL}
${UNTUNED_RESCORING_MODEL}: ${RESCORING_MODEL_TEMPLATE}
	set -o pipefail; configtool rescore-model:ffvals ${DECODING_MODEL_DIR}/${DECODING_MODEL} | cut -f 1 -d ' ' > $@
	cat $< \
	| sed -e "s#IBM\\(.\\)FWD#${IBM_DIR}/ibm\\1.${TGT_GIVEN_SRCX}#" \
	      -e "s#IBM\\(.\\)BKW#${IBM_DIR}/ibm\\1.${SRC_GIVEN_TGTX}#" \
	      -e "s#HMM\\(.\\)FWD#${IBM_DIR}/hmm\\1.${TGT_GIVEN_SRCX}#" \
	      -e "s#HMM\\(.\\)BKW#${IBM_DIR}/hmm\\1.${SRC_GIVEN_TGTX}#" \
	| egrep -v '^#' \
	>> $@



########################################
# Train a rescoring model
.PHONY: train
train: ${RESCORING_MODEL}

${RESCORING_MODEL}:  SHELL=${FRAMEWORK_SHELL}
${RESCORING_MODEL}:  ${TUNE_RESCORE_RULE} ${DECODING_MODEL}.${TUNE_RESCORE} ${UNTUNED_RESCORING_MODEL} ${TUNE_RESCORE_SRC} ${TUNE_RESCORE_TGTS}
	@_LOCAL=1 echo "Tuning the rescoring model."
	RP_PSUB_OPTS="-4 -N $@" \
	rat.sh \
		-lb \
		-n ${PARALLELISM_LEVEL_TUNE_RESCORE} \
		-psub -${RAT_TRANS_CPUS} \
		train \
		-a mira \
		-v \
		-K ${NBEST_SIZE} \
		-o $@ \
		-msrc $< \
		-f $(wordlist 2,100,$+) \
	>& log.$@
	_LOCAL=1 ${RM} -r workdir-${TUNE_RESCORE_RULE}-${NBEST_SIZE}best

clean.content: clean.rescore_train

.PHONY: clean.rescore_train
clean.rescore_train: SHELL=${LOCAL_SHELL}
clean.rescore_train:
	${RM} ${RESCORING_MODEL} ${RESCORING_MODEL}.ini
	${RM} -r gen-features-parallel-output.* workdir-${TUNE_RESCORE_RULE}-${NBEST_SIZE}best



########################################
# Create a specific canoe.ini per test set.
# You could add some specific target if you need to customize a decoding model
# for a particular testset.
${DECODING_MODEL}.%: SHELL=${LOCAL_SHELL}
${DECODING_MODEL}.%: check_decoding_model
	sed -e 's#${TUNE_DECODE}.mixlm#$*.mixlm#g' ${DECODING_MODEL_DIR}/${DECODING_MODEL} > $@
	configtool check $@
#	cat $< \
#	| perl -pe 's/\[stack\].*/[stack] 600/go; s/\[beam-threshold\].*/[beam-threshold] 0.00001/go;' \
#	| sed "s/dev-text1/$*/" \
#	> $@

clean.content: clean.decoding.model

.PHONY: clean.decoding.model
clean.decoding.model: SHELL=${LOCAL_SHELL}
clean.decoding.model:
	${RM} ${DECODING_MODEL}.*



################################################################################
# HELPERS

#######################################
# Check the decoding model config file.
.PHONY: configtool
configtool: SHELL=${LOCAL_SHELL}
configtool: ${DECODING_MODEL_DIR}/${DECODING_MODEL}
	configtool check $<



########################################
# DEBUGGING
debug: SHELL=${LOCAL_SHELL}
debug:
	echo "<${PARALLELISM_LEVEL_TUNE_RESCORE}>"
