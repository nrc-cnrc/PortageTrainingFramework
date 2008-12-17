#!/usr/bin/make -f
# vim:noet:ts=3
#
# @author Samuel Larkin
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
TUNE_DECODE_SRC  = ${TUNE_DECODE}${SRCX}
TUNE_DECODE_TGT  = ${TUNE_DECODE}${TGTX}

# Specific PSUB options
PSUB_OPTS ?= 

# Indicates the nbest list size.
NBEST_SIZE ?= 1000

# Number of parallel chunks to process.
PARALLELISM_LEVEL_TUNE_DECODE ?= 5

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



# Clean up
.PHONY: clean
clean: SHELL=${GUARD_SHELL}
clean:
	${RM} models



########################################
# Clean logs.
clean: clean.logs

.PHONY: clean.logs
clean.logs:
	${RM} log.* run-parallel-logs*



########################################
# Is the template present?
.PHONY: check_template
check_template: SHELL=${GUARD_SHELL}
check_template:
	if [[ ! -f ${TEMPLATE_DIR}/${DECODING_MODEL_TEMPLATE} ]]; then \
		echo "Cannot find this template: ${DECODING_MODEL_TEMPLATE}" >&2; \
		false; \
	fi



########################################
# Create canoe.ini from template.
CPTS ?= $(subst /,\/,$(wildcard models/tm/cpt.*${SRC_LANG}2${TGT_LANG}.gz))
LMS  ?= $(subst /,\/,$(wildcard models/lm/*${TGT_LANG}*.binlm.gz))
${UNTUNED_DECODING_MODEL}: SHELL=${GUARD_SHELL}
${UNTUNED_DECODING_MODEL}: ${DECODING_MODEL_TEMPLATE}  models
	cat $< \
	| sed -e 's/<SL>/${SRC_LANG}/g' \
	      -e 's/<TL>/${TGT_LANG}/g' \
	      -e 's/<CPTS>/${CPTS}/g' \
			-e 's/<LMS>/${LMS}/g' \
	      -e 's/^\(\[\(weight-f\|ftm\)\]\)/##mid##\1/' \
	> tmp.$@
	WT=$$(perl -e 'print 1; print ":1" foreach (2..`configtool nt tmp.$@`)'); \
	cat tmp.$@ \
	| sed -e "s/^##mid##//" \
	      -e "s/<ENABLE_FTM>/$$WT/" \
	> $@
	rm tmp.$@
	configtool check $@

clean: clean.canoe.ini

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
	RP_PSUB_OPTS="-N tune.decode.model" \
	cow.sh \
		-v \
		-parallel:"-n ${PARALLELISM_LEVEL_TUNE_DECODE}" \
		-maxiter 15 \
		-nbest-list-size 100 \
		-filt \
		-nofloor \
		-workdir foos \
		-f $^ \
		>& log.$@
	_LOCAL=1 ${RM} -r foos multi.probs.*.FILT.gz ${UNTUNED_DECODING_MODEL}.FILT ${UNTUNED_DECODING_MODEL}.FILT.cow

clean: clean.cow

.PHONY: clean.cow
clean.cow: SHELL=${GUARD_SHELL}
clean.cow:
	-${RM} -r foos canoe-parallel.* run-p.*
	-${RM} ${DECODING_MODEL}
	-${RM} ${UNTUNED_DECODING_MODEL} ${UNTUNED_DECODING_MODEL}.FILT ${UNTUNED_DECODING_MODEL}.FILT.cow
	-${RM} multi.probs.*.FILT.gz rescore-results*



################################################################################
# HELPERS

########################################
# This is mainly a hack to fix the hierachy tree problem inherent to the
# decoding model content.
.PHONY: symlink
symlink: models

models: SHELL=${GUARD_SHELL}
models:
	ln -sf ${MODEL_DIR} $@

