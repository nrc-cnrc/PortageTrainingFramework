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
TEMPLATE_DIR       ?= ../
CANOE_INI_TEMPLATE ?= canoe.ini.template

# Will indicate to make where to find the SETs (dev & test & eval)
CORPORA_DIR ?= ../../corpora

# Indicates what prefix/file to use for training a decoder model
PREFIX_DEV_COW  ?= dev1
DEV_COW_SRC      = ${PREFIX_DEV_COW}${SRCX}
DEV_COW_TGT      = ${PREFIX_DEV_COW}${TGTX}

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
vpath canoe.%.template ${TEMPLATE_DIR}



.PHONY: all
all: train



.PHONY: help
help: SHELL=bash
help:
	@echo "This allows to tune a system."
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
train: canoe.ini.cow
canoe.ini.cow: canoe.ini ${DEV_COW_SRC} ${DEV_COW_TGT}
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
