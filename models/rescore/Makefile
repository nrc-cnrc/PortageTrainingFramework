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

# TODO: may be this is to deleted.
SRC_GIVEN_TGT  = ${SRC_LANG}_given_${TGT_LANG}
TGT_GIVEN_SRC  = ${TGT_LANG}_given_${SRC_LANG}
SRC_GIVEN_TGTX = ${SRC_GIVEN_TGT}.gz
TGT_GIVEN_SRCX = ${TGT_GIVEN_SRC}.gz

# Indicates where to find the canoe.ini template
DECODING_MODEL_DIR ?= ../decode
DECODING_MODEL     ?= canoe.ini.cow

# Indicates where to find the IBM models.
IBM_DIR ?= ../TM

# Will indicate to make where to find the SETs (dev & test & eval)
CORPORA_DIR ?= ../../corpora

# Indicates what prefix/file to use for training a rescoring model
PREFIX_DEV_RAT  ?= dev2
DEV_RAT_SRC      = ${PREFIX_DEV_RAT}${SRCX}
DEV_RAT_TGT      = ${PREFIX_DEV_RAT}${TGTX}

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
vpath ${DECODING_MODEL} ${DECODING_MODEL_DIR}



.PHONY: all
all: train



.PHONY: help
help: SHELL=bash
help:
	@echo "Train a rescoring model."
	@echo "Possible targets are:"
	@cat $(firstword $(MAKEFILE_LIST)) | egrep '^.PHONY:' | sed 's#^.PHONY: ##'
	@echo "Most likely you want to do either: make all"



# Clean up
.PHONY: clean
clean: SHELL=bash



########################################
# Clean logs
clean: clean.logs

.PHONY: clean.logs
clean.logs: SHELL=bash
clean.logs:
	-${RM} log.* run-parallel-logs*



########################################
# CREATE A RESCORE MODEL
# requires: a trained canoe.ini model.
rescore-model.ini: SHELL=bash
#rescore-model.ini: ibm1.${SRC_GIVEN_TGTX} ibm1.${TGT_GIVEN_SRCX}
#rescore-model.ini: ibm2.${SRC_GIVEN_TGTX} ibm2.${TGT_GIVEN_SRCX}
rescore-model.ini: ${DECODING_MODEL}
	configtool rescore-model:ffvals $< | cut -f 1 -d ' ' > $@
	echo "IBM2TgtGivenSrc:${IBM_DIR}/ibm2.${TGT_GIVEN_SRCX}" >> $@
	echo "IBM2SrcGivenTgt:${IBM_DIR}/ibm2.${SRC_GIVEN_TGTX}" >> $@
	echo "IBM1WTransTgtGivenSrc:${IBM_DIR}/ibm1.${TGT_GIVEN_SRCX}" >> $@
	echo "IBM1WTransSrcGivenTgt:${IBM_DIR}/ibm1.${SRC_GIVEN_TGTX}" >> $@
	echo "LengthFF" >> $@
	echo "nbestPhrasePostSrc:1#<ffval-wts>#<pfx>" >> $@
	echo "nbestSentLenPost:1#<ffval-wts>#<pfx>" >> $@
	echo "nbestWordPostTrg:1#<ffval-wts>#<pfx>" >> $@
	echo "nbestNgramPost:1#1#<ffval-wts>#<pfx>" >> $@
	echo "nbestNgramPost:2#1#<ffval-wts>#<pfx>" >> $@
	


########################################
# Train a rescoring model
.PHONY: train
train: rescore-model
rescore-model:  ${DECODING_MODEL}.${PREFIX_DEV_RAT} rescore-model.ini ${DEV_RAT_SRC} ${DEV_RAT_TGT}
	RP_PSUB_OPTS="-N $@" \
	echo "Generating $@"; \
	rat.sh \
		-lb \
		-n ${PARALLELISM_LEVEL} \
		train \
		-v \
		-K ${NBEST_SIZE} \
		-o $@ \
		-f $+ \
	>& log.$@

.PHONY: clean.rescore_train
clean.rescore_train: SHELL=bash
clean.rescore_train:
	${RM} -f rescore-model.rat rescore-model



################################################################################
# HELPERS

#######################################
# Check the decoding model config file.
.PHONY: configtool
configtool: SHELL=bash
configtool: ${DECODING_MODEL}
	configtool check $<



########################################
# Create a specific canoe.ini per test set.
# You could add some specific target if you need to customize a canoe.ini.cow
# for a particular testset.
${DECODING_MODEL}.%: SHELL=bash
${DECODING_MODEL}.%: ${DECODING_MODEL}
	cat $< > $@
	configtool check $@
#	cat $< \
#	| perl -pe 's/\[stack\].*/[stack] 600/go; s/\[beam-threshold\].*/[beam-threshold] 0.00001/go;' \
#	| sed "s/dev-text1/$*/" \
#	> $@



########################################
# LINKS THE IBMX MODELS
# ibm2.ch_given_en.gz ibm2.ch_given_en.pos.gz
# ibm2.en_given_ch.gz ibm2.en_given_ch.pos.gz
ibm2.%.gz: SHELL=bash
ibm2.%.gz:
	ln -sf ${IBM_DIR}/ibm2.*$*.gz ibm2.$*.gz 
	ln -sf ${IBM_DIR}/ibm2.*$*.pos.gz ibm2.$*.pos.gz

ibm1.%.gz: SHELL=bash
ibm1.%.gz:
	ln -sf ${IBM_DIR}/ibm1.*$*.gz ibm1.$*.gz 
