#!/usr/bin/make -f
# vim:noet:ts=3

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
PARALLELISM_LEVEL ?= 5

.SECONDARY:
.DELETE_ON_ERROR:

# Threre are two differents vpath for heldout because in the chinese case for example the src_ext != tgt_ext
vpath %${SRCX} ${CORPORA_DIR}
vpath %${TGTX} ${CORPORA_DIR}
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



########################################
# Clean logs.
clean: clean.logs

.PHONY: clean.logs
clean.logs:
	${RM} log.* run-parallel-logs*



########################################
# Create canoe.ini from template.
${UNTUNED_DECODING_MODEL}: SHELL=${GUARD_SHELL}
${UNTUNED_DECODING_MODEL}: ${DECODING_MODEL_TEMPLATE}  models
	cat $< \
	| sed -e 's/<SL>/${SRC_LANG}/g' -e 's/<TL>/${TGT_LANG}/g' \
	> $@
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
	RP_PSUB_OPTS="-N tune.decode.model" \
	mkdir -p foos && \
	cow.sh \
		-v \
		-parallel:"-n ${PARALLELISM_LEVEL}" \
		-maxiter 15 \
		-nbest-list-size 100 \
		-filt \
		-nofloor \
		-workdir foos \
		-f $^ \
		>& log.$@ && \
	rm -fr foos multi.probs.*.FILT.gz ${UNTUNED_DECODING_MODEL}.FILT ${UNTUNED_DECODING_MODEL}.FILT.cow

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



########################################
# Check if the template file is present.
.PHONY: template
template: ${DECODING_MODEL_TEMPLATE}

${DECODING_MODEL_TEMPLATE}: SHELL=${GUARD_SHELL}
${DECODING_MODEL_TEMPLATE}:
	echo "We can't find this template: $@"
	false
