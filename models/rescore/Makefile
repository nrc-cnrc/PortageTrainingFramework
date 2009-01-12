#!/usr/bin/make -f
# vim:noet:ts=3
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

# TODO: Make this Makefile work with run-parallel.sh -c
export SHELL = ${FRAMEWORK_SHELL}

# Define languages info.
#SRC_LANG ?= en
#TGT_LANG ?= fr
SRCX  ?= _${SRC_LANG}${LANGX}
TGTX  ?= _${TGT_LANG}${LANGX}

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
TUNE_RESCORE_TGT   = ${TUNE_RESCORE}${TGTX}
TUNE_RESCORE_RULE  = ${TUNE_RESCORE}${RULEX}

# Specific PSUB options
PSUB_OPTS ?= 

# Indicates the nbest list size.
NBEST_SIZE ?= 1000

# Number of parallel chunks to process.
PARALLELISM_LEVEL_TUNE_RESCORE ?= 5

.SECONDARY:
.SUFFIXES:
.DELETE_ON_ERROR:

# Threre are two differents vpath for heldout because in the chinese case for example the src_ext != tgt_ext
vpath %${SRCX}  ${CORPORA_DIR}
vpath %${TGTX}  ${CORPORA_DIR}
vpath %${RULEX} ${CORPORA_DIR}
vpath ${DECODING_MODEL} ${DECODING_MODEL_DIR} ../decode



.PHONY: all
all: train



.PHONY: help
help: SHELL=${GUARD_SHELL}
help:
	@echo "Train a rescoring model."
	@echo "Possible targets are:"
	@cat $(firstword $(MAKEFILE_LIST)) | egrep '^.PHONY:' | sed 's#^.PHONY: ##'
	@echo "Most likely you want to do either: make all"



# What the user can expect from this module.
.PHONY: list_final_output
list_final_output: SHELL=${GUARD_SHELL}
list_final_output:
	@echo "Expected final output(s):"
	@echo "${RESCORING_MODEL}"



# Unfortunately, this script requires setup.
.PHONY: setup
setup: SHELL=${GUARD_SHELL}
setup: symlink



# Clean up
.PHONY: clean
clean: SHELL=${GUARD_SHELL}
clean:
	${RM} -r canoe-parallel.* run-p.*
	${RM} models



########################################
# Clean logs
clean: clean.logs

.PHONY: clean.logs
clean.logs: SHELL=${GUARD_SHELL}
clean.logs:
	-${RM} log.* run-parallel-logs*



########################################
# Check if there is a trained decoding model available
.PHONY: check_decoding_model
check_decoding_model: SHELL=${GUARD_SHELL}
check_decoding_model: setup
	@if [[ ! -e ${DECODING_MODEL_DIR}/${DECODING_MODEL} ]]; then \
		echo "Please run ${DECODING_MODEL_DIR} first!"; \
		false; \
	fi



########################################
# CREATE A DEFAULT RESCORE MODEL
# requires: a trained decoding model.
# This provides the default rescore-model.ini.
${UNTUNED_RESCORING_MODEL}: SHELL=${GUARD_SHELL}
${UNTUNED_RESCORING_MODEL}: ${DECODING_MODEL} models ${RESCORING_MODEL_TEMPLATE}
	set -o pipefail; configtool rescore-model:ffvals $< | cut -f 1 -d ' ' > $@
	cat ${lastword $+} \
	| sed -e "s#IBM1FWD#${IBM_DIR}/ibm1.${TGT_GIVEN_SRCX}#" \
	      -e "s#IBM1BKW#${IBM_DIR}/ibm1.${SRC_GIVEN_TGTX}#" \
	      -e "s#IBM2FWD#${IBM_DIR}/ibm2.${TGT_GIVEN_SRCX}#" \
	      -e "s#IBM2BKW#${IBM_DIR}/ibm2.${SRC_GIVEN_TGTX}#" \
	      -e "s#HMM1FWD#${IBM_DIR}/hmm1.${TGT_GIVEN_SRCX}#" \
	      -e "s#HMM1BKW#${IBM_DIR}/hmm1.${SRC_GIVEN_TGTX}#" \
	      -e "s#HMM2FWD#${IBM_DIR}/hmm2.${TGT_GIVEN_SRCX}#" \
	      -e "s#HMM2BKW#${IBM_DIR}/hmm2.${SRC_GIVEN_TGTX}#" \
	>> $@



########################################
# Train a rescoring model
.PHONY: train
train: ${RESCORING_MODEL}

${RESCORING_MODEL}:  ${TUNE_RESCORE_RULE} ${DECODING_MODEL}.${TUNE_RESCORE} ${UNTUNED_RESCORING_MODEL} ${TUNE_RESCORE_SRC} ${TUNE_RESCORE_TGT}
	@_LOCAL=1 echo "Tuning the rescoring model."
	RP_PSUB_OPTS="-N $@" \
	rat.sh \
		-lb \
		-n ${PARALLELISM_LEVEL_TUNE_RESCORE} \
		train \
		-v \
		-K ${NBEST_SIZE} \
		-o $@ \
		-msrc $< \
		-f $(wordlist 2,5,$+) \
	>& log.$@

clean: clean.rescore_train

.PHONY: clean.rescore_train
clean.rescore_train: SHELL=${GUARD_SHELL}
clean.rescore_train:
	${RM} ${RESCORING_MODEL} ${RESCORING_MODEL}.ini
	${RM} -r gen-features-parallel-output.* workdir-${TUNE_RESCORE_RULE}-${NBEST_SIZE}best



########################################
# Create a specific canoe.ini per test set.
# You could add some specific target if you need to customize a decoding model
# for a particular testset.
${DECODING_MODEL}.%: SHELL=${GUARD_SHELL}
${DECODING_MODEL}.%: ${DECODING_MODEL} models
	cat $< > $@
	configtool check $@
#	cat $< \
#	| perl -pe 's/\[stack\].*/[stack] 600/go; s/\[beam-threshold\].*/[beam-threshold] 0.00001/go;' \
#	| sed "s/dev-text1/$*/" \
#	> $@

clean: clean.decoding.model

.PHONY: clean.decoding.model
clean.decoding.model: SHELL=${GUARD_SHELL}
clean.decoding.model:
	${RM} ${DECODING_MODEL}.*



################################################################################
# HELPERS

#######################################
# Check the decoding model config file.
.PHONY: configtool
configtool: SHELL=${GUARD_SHELL}
configtool: ${DECODING_MODEL} models
	configtool check $<



########################################
# This is mainly a hack to fix the hierachy tree problem inherent to the
# decoding model content.
.PHONY: symlink
symlink: models

models: SHELL=${GUARD_SHELL}
models:
	ln -sf ${MODEL_DIR} $@
	@if [[ ! -e ${DECODING_MODEL_DIR}/${DECODING_MODEL} ]]; then \
		echo "Please run ${DECODING_MODEL_DIR} first!"; \
		rm $@; \
		false; \
	fi

