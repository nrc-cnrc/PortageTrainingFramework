#!/usr/bin/make -f
# vim:noet:ts=3

# Mandatory include: master config file.
include ../../Makefile.params

# Include the config file.
MAKEFILE_PARAMS ?= Makefile.params
-include ${MAKEFILE_PARAMS}

# TODO: Make this Makefile work with run-parallel.sh -c
# SHELL = run-parallel.sh

# Define languages info.
#SRC_LANG ?= en
#TGT_LANG ?= fr
SRCX  ?= _${SRC_LANG}${LANGX}
TGTX  ?= _${TGT_LANG}${LANGX}

# Indicates where to find the canoe.ini template
TEMPLATE_DIR       ?= ./
CANOE_INI_TEMPLATE ?= canoe.ini.template

# Indicates where to find the canoe.ini template.
DECODING_MODEL ?= canoe.ini.cow

# Will indicate to make where to find the SETs (dev & test & eval)
CORPORA_DIR ?= ../../corpora

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
vpath ${CANOE_INI_TEMPLATE} ${TEMPLATE_DIR}



.PHONY: all
all: train



.PHONY: help
help: SHELL=bash
help:
	@echo "This script allows to tune a system."
	@echo "Possible targets are:"
	@cat $(firstword $(MAKEFILE_LIST)) | egrep '^.PHONY:' | sed 's#^.PHONY: ##'
	@echo "Most likely you want to do either: make all"



# Clean up
.PHONY: clean
clean: SHELL=bash



########################################
# Clean logs.
clean: clean.logs

.PHONY: clean.logs
clean.logs:
	-rm log.* run-parallel-logs*



########################################
# Create canoe.ini from template.
canoe.ini: SHELL=bash
canoe.ini: ${CANOE_INI_TEMPLATE}
	cat $< \
	| sed -e 's/<SL>/${SRC_LANG}/g' -e 's/<TL>/${TGT_LANG}/g' \
	> $@
	configtool check $@

clean: clean.canoe.ini

.PHONY: clean.canoe.ini
clean.canoe.ini: SHELL=bash
clean.canoe.ini:
	-${RM} -f canoe.ini



########################################
# Training a decoding model.
.PHONY: train
train: ${DECODING_MODEL}
${DECODING_MODEL}: canoe.ini ${TUNE_DECODE_SRC} ${TUNE_DECODE_TGT}
	RP_PSUB_OPTS="-N $@" \
	test -d foos || mkdir foos; \
	cow.sh \
		-v \
		-parallel:"-n ${PARALLELISM_LEVEL}" \
		-maxiter 15 \
		-nbest-list-size 100 \
		-filt \
		-nofloor \
		-workdir foos \
		-f $^ \
		>& log.$@; \
	rm -fr foos

clean: clean.cow

.PHONY: clean.cow
clean.cow: SHELL=bash
clean.cow:
	-${RM} -rf foos canoe-parallel.*
	-${RM} -rf canoe.ini.cow* canoe.ini.FILT* rescore-results*
	-${RM} multi.probs.*
