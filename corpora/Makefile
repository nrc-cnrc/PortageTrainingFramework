#!/usr/bin/make -f
# vim:noet:ts=3:nowrap
#
# $Id$
# @author Samuel Larkin
# @file Makefile
# @brief Simple preprocessing of corpora, mainly lowercasing.
#
# Technologies langagieres interactives / Interactive Language Technologies
# Inst. de technologie de l'information / Institute for Information Technology
# Conseil national de recherches Canada / National Research Council Canada
# Copyright 2008, Sa Majeste la Reine du Chef du Canada
# Copyright 2008, Her Majesty in Right of Canada


# Mandatory include: master config file.
include ../Makefile.params

# Include the config file.
MAKEFILE_PARAMS ?= Makefile.params
-include ${MAKEFILE_PARAMS}

# If your files are not tokenize, they should have the RAWX extentsion.
RAWX ?= .raw

# What is the truecase corpus extension.
TCX ?= .tc

# Change make's default shell to a distributed one, if working on a cluster.
SHELL = ${FRAMEWORK_SHELL}


# What command to use for lowercasing corpora.
ifdef ICU
LOWERCASE ?= utf8_casemap -c l
else
LOWERCASE ?= lc-utf8.pl
endif


export LC_ALL ?= fr_CA.utf8


# Where are the aligned corpora to process.
ALIGN_CORPORA_DIR ?= .

# If we have untokenized corpora, this is where we would find them.
RAW_CORPORA_DIR ?= .

# What tokenizer should we use.
TOKENIZER ?= utokenize.pl -noss

# We want a minimum of 100,000 lines per jobs that parallelize.pl creates.
MINIMUM_PARALLEL_CHUNK_SIZE ?= 100000



# Tells make where to find the raw corpora files.
vpath %${ALIGNX} ${ALIGN_CORPORA_DIR}
vpath %${RAWX}   ${RAW_CORPORA_DIR}


# This Makefile should display some help message if the user doesn't specify a
# target.
.DEFAULT_GOAL: help


# Help message
.PHONY: help
help: SHELL=${GUARD_SHELL}
help:
	@echo "This script tokenizes and lowercases all corpora described by CORPORA_SET"
	@echo "Type: make all"
	@echo
	@echo "The following are the main targets in this Makefile:"
	@cat $(firstword $(MAKEFILE_LIST)) | egrep '^.PHONY:' | sed 's#^.PHONY: ##'


.DELETE_ON_ERROR:
.SUFFIXES:
#.SECONDARY:



# What are the final ouptut so we can manipulate them as a whole.
LIST_FINAL_OUTPUT += ${LC} ${RULE}

# After this Makefile, the following targets/files are precious.
FILES_TO_BE_LOCKED = ${LIST_FINAL_OUTPUT}

# Defines all that needs to be done by this makefile.
.PHONY: all
all: lc
all: rule
ifdef DO_TRUECASING
all: tc
LIST_FINAL_OUTPUT += ${TC}
endif
ifdef TRANSLATE_SET
all: translate
LIST_FINAL_OUTPUT += ${TRANSLATE_SET_LIST}
endif

# What the user can expect from this module.
.PHONY: list_final_output
list_final_output: SHELL=${GUARD_SHELL}
list_final_output:
	@echo "Expected final output are:"
	@echo ${LC}
	@echo ${RULE}
	@echo ${TC}



########################################
# TOKENIZATION.
# For the tokenization targets, we automatically detect raw files and if we
# find any, there will be a rule to process them.  If no raw files are found
# then the following targets are automatically disabled.

## Tokenizes source corpora without sentence splitting.
SRC_RAW_LIST ?= $(notdir $(wildcard ${RAW_CORPORA_DIR}/*_${SRC_LANG}${RAWX}))
SRC_TOK_LIST ?= $(SRC_RAW_LIST:${RAWX}=${ALIGNX})
TOK += ${SRC_TOK_LIST}

${SRC_TOK_LIST}: %${ALIGNX}: %${RAWX}
	@${check_utf8}
	RP_PSUB_OPTS="-1" \
	${TOKENIZER} -lang=${SRC_LANG} < $< > $@


## Tokenizes target corpora without sentence splitting.
TGT_RAW_LIST ?= $(notdir $(wildcard ${RAW_CORPORA_DIR}/*_${TGT_LANG}${RAWX}))
TGT_TOK_LIST ?= $(TGT_RAW_LIST:${RAWX}=${ALIGNX})
TOK += ${TGT_TOK_LIST}

${TGT_TOK_LIST}: %${ALIGNX}: %${RAWX}
	@${check_utf8}
	RP_PSUB_OPTS="-1" \
	utokenize.pl -noss -lang=${TGT_LANG} < $< > $@


## HOW to handle big source language corpora.
SRC_RAWZ_LIST ?= $(notdir $(wildcard ${RAW_CORPORA_DIR}/*_${SRC_LANG}${RAWX}${GZ}))
SRC_TOKZ_LIST ?= $(SRC_RAWZ_LIST:${RAWX}${GZ}=${ALIGNX}${GZ})
TOK += ${SRC_TOKZ_LIST}

${SRC_TOKZ_LIST}: SHELL=${GUARD_SHELL}
${SRC_TOKZ_LIST}: %${ALIGNX}${GZ}: %${RAWX}${GZ}
	RP_PSUB_OPTS="-1" \
	parallelize.pl \
		-nolocal \
		-psub -1 \
		-w ${MINIMUM_PARALLEL_CHUNK_SIZE} \
		-n ${PARALLELISM_LEVEL_CORPORA} \
		"utokenize.pl -noss -lang=${SRC_LANG} < $< > $@"


## HOW to handle big target language corpora.
TGT_RAWZ_LIST ?= $(notdir $(wildcard ${RAW_CORPORA_DIR}/*_${TGT_LANG}${RAWX}${GZ}))
TGT_TOKZ_LIST ?= $(TGT_RAWZ_LIST:${RAWX}${GZ}=${ALIGNX}${GZ})
TOK += ${TGT_TOKZ_LIST}

${TGT_TOKZ_LIST}: SHELL=${GUARD_SHELL}
${TGT_TOKZ_LIST}: %${ALIGNX}${GZ}: %${RAWX}${GZ}
	RP_PSUB_OPTS="-1" \
	parallelize.pl \
		-nolocal \
		-psub -1 \
		-w ${MINIMUM_PARALLEL_CHUNK_SIZE} \
		-n ${PARALLELISM_LEVEL_CORPORA} \
		"utokenize.pl -noss -lang=${TGT_LANG} < $< > $@"



.PHONY: tok
tok: ${TOK}



########################################
# TRUECASE.
# Defines what corpora we need truecased/tokenized for the truecase model.
.PHONY: tc
TC = $(addsuffix _${TGT_LANG}.tc${GZ}, ${TRAIN_LM})
tc: ${TC}

# Prepare truecased file.
%${TCX}: %${ALIGNX}
	@${check_utf8}
	RP_PSUB_OPTS="-1" \
	cp $< $@

%${TCX}${GZ}: %${ALIGNX}${GZ}
	@${check_utf8}
	RP_PSUB_OPTS="-1" \
	cp $< $@



########################################
# LOWERCASING.
# Defines what corpora we need in the entire pipeline.
.PHONY: lc
LC += $(addsuffix _${SRC_LANG}${LANGX}, ${HELDOUT_SET})
LC += $(addsuffix _${TGT_LANG}${LANGX}, ${HELDOUT_SET})
# Note that will want to compress the TRAIN_SET for space efficiency.
LC += $(addsuffix _${SRC_LANG}${LANGXZ}, ${TRAIN_TM})
LC += $(addsuffix _${TGT_LANG}${LANGXZ}, ${TRAIN_TM})
LC += $(addsuffix _${TGT_LANG}${LANGXZ}, ${TRAIN_LM})
ifdef DO_CE
LC += $(addsuffix _${SRC_LANG}${LANGXZ}, ${TRAIN_LM})
endif
lc: ${LC}


# Constructs a lowercased corpora from its aligned version.
%${LANGX}: %${ALIGNX}
	@$(check_utf8)
	RP_PSUB_OPTS="-1" \
	cat $< | ${LOWERCASE} > $@

%${LANGXZ}: %${ALIGNX}${GZ}
	@$(check_utf8)
	RP_PSUB_OPTS="-1" \
	zcat $< | ${LOWERCASE} | gzip > $@



########################################
# RULES.
# Add some markup to the source HELDOUT_SET.
# If you have special markup, this is where you would write your code.
.PHONY: rule
RULE = $(addsuffix ${RULEX}, ${HELDOUT_SET})
rule: ${RULE}
%${RULEX}: %_${SRC_LANG}${LANGX}
	@$(check_utf8)
	RP_PSUB_OPTS="-1" \
	canoe-escapes.pl -add $< > $@



# NOTE: here TRANSLATE_SET must contain the prefix only.
# Special target to prepare a new translation set.
TRANSLATE_SET_LIST = $(foreach t,${TRANSLATE_SET}, $t${RULEX} $t_${SRC_LANG}${LANGX})
.PHONY: translate
translate: ${TRANSLATE_SET_LIST}


# Special targte to prepare the reference.
reference: $(foreach t,${TRANSLATE_SET},  $t_${TGT_LANG}${LANGX})


# Check if the first dependency is a utf8 file.
define check_utf8
_LOCAL=1 file -Libz $< | egrep -qi 'charset=utf-8|ASCII' || echo "WARNING: Please convert $< to utf-8" 
endef



########################################
# How to clean-up.
.PHONY: clean
clean: SHELL=${GUARD_SHELL}
clean: clean.content clean.logs

.PHONY: clean.content
clean.content: SHELL=${GUARD_SHELL}
clean.content:
	-${RM} *.tc *.tc${GZ} *${RULEX} *${LANGX} *${LANGXZ}
	-${RM} ${TOK}

.PHONY: clean.logs
clean.logs: SHELL=${GUARD_SHELL}
clean.logs:
	-${RM} run-parallel-logs-*
	-${RM} log.*
	-${RM} .logs




################################################################################
# HELPERS
.PHONY: debug
debug: SHELL=${GUARD_SHELL}
debug:
	@echo "LIST_FINAL_OUTPUT: ${LIST_FINAL_OUTPUT}"
	@echo "LC: ${LC}"
	@echo "SRC_RAW_LIST: ${SRC_RAW_LIST}"
	@echo "SRC_TOK_LIST: ${SRC_TOK_LIST}"
	@echo "SRC_RAW_LIST: ${TGT_RAW_LIST}"
	@echo "SRC_TOK_LIST: ${TGT_TOK_LIST}"
	@echo "SRC_RAWZ_LIST: ${SRC_RAWZ_LIST}"
	@echo "SRC_TOKZ_LIST: ${SRC_TOKZ_LIST}"
	@echo "SRC_RAWZ_LIST: ${TGT_RAWZ_LIST}"
	@echo "SRC_TOKZ_LIST: ${TGT_TOKZ_LIST}"
	@echo "TOK: ${TOK}"


# Lastly include the master toolkit
include ../Makefile.toolkit
