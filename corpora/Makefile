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

# Lastly include the master toolkit
include ../Makefile.toolkit

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

UTF8 = $(if $(findstring Darwin, ${OSTYPE}),UTF-8,utf8)
export LC_ALL = en_CA.${UTF8}


# Where are the aligned corpora to process.
ALIGN_CORPORA_DIR ?= .

# If we have untokenized corpora, this is where we would find them.
RAW_CORPORA_DIR ?= .

# Let's allow for different tokenizer for source or target.
# What tokenizer should we use for the source side.
ifdef TOKENIZER_${SRC_LANG}
SRC_TOKENIZER = ${TOKENIZER_${SRC_LANG}}
else
SRC_TOKENIZER = utokenize.pl -noss -lang=${SRC_LANG}
endif

# What tokenizer should we use for the target side.
ifdef TOKENIZER_${TGT_LANG}
TGT_TOKENIZER = ${TOKENIZER_${TGT_LANG}}
else
TGT_TOKENIZER = utokenize.pl -noss -lang=${TGT_LANG}
endif


# We want a minimum of 100,000 lines per jobs that parallelize.pl creates.
MINIMUM_PARALLEL_CHUNK_SIZE ?= 100000



# Tells make where to find the raw corpora files.
vpath %${ALIGNX} ${ALIGN_CORPORA_DIR}
vpath %${RAWX}   ${RAW_CORPORA_DIR}


# This Makefile should display some help message if the user doesn't specify a
# target.
.DEFAULT_GOAL := help


# Help message
.PHONY: help
help: SHELL=${GUARD_SHELL}
help:
	@echo "Tokenize and lowercase all corpora listed in CORPORA_SET."
	@echo "CORPORA_SET: ${CORPORA_SET}"
	@echo
	@echo "To prepare the corpora, type: make all"
	@echo
	@echo "The main targets in this Makefile are:"
	@cat $(firstword $(MAKEFILE_LIST)) | egrep '^.PHONY:' | sed 's#^.PHONY: #   #'


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
	${SRC_TOKENIZER} < $< > $@


## Tokenizes target corpora without sentence splitting.
TGT_RAW_LIST ?= $(notdir $(wildcard ${RAW_CORPORA_DIR}/*_${TGT_LANG}${RAWX}))
TGT_TOK_LIST ?= $(TGT_RAW_LIST:${RAWX}=${ALIGNX})
TOK += ${TGT_TOK_LIST}

${TGT_TOK_LIST}: %${ALIGNX}: %${RAWX}
	@${check_utf8}
	RP_PSUB_OPTS="-1" \
	${TGT_TOKENIZER} < $< > $@


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
		"${SRC_TOKENIZER} < $< > $@"


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
		"${TGT_TOKENIZER} < $< > $@"



.PHONY: tok
tok: ${TOK}



########################################
# TRUECASE.
# Defines what corpora we need truecased/tokenized for the truecase model.
.PHONY: tc
TC := $(addsuffix _${TGT_LANG}${TCX}${GZ}, ${TRAIN_TC})
tc: ${TC}

# Prepare truecased file.
%${TCX}: %${ALIGNX}
	@${check_utf8}
	RP_PSUB_OPTS="-1" \
	ln -fs $< $@

%${TCX}${GZ}: %${ALIGNX}${GZ}
	@${check_utf8}
	RP_PSUB_OPTS="-1" \
	ln -fs $< $@



########################################
# LOWERCASING.
# Defines what corpora we need in the entire pipeline.
.PHONY: lc
LC += $(addsuffix _${SRC_LANG}${LANGX}, ${HELDOUT_SET})
LC += $(addsuffix _${TGT_LANG}${LANGX}, ${HELDOUT_SET})
# Note that will want to compress the TRAIN_SET for space efficiency.
LC += $(addsuffix _${SRC_LANG}${LANGXZ}, ${TRAIN_TM})
LC += $(addsuffix _${TGT_LANG}${LANGXZ}, ${TRAIN_TM})
LC += $(addsuffix _${SRC_LANG}${LANGXZ}, ${MIXLM})
LC += $(addsuffix _${TGT_LANG}${LANGXZ}, ${MIXLM})
LC += $(addsuffix _${TGT_LANG}${LANGXZ}, ${TRAIN_TC})
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
FILE_OPTS = $(if $(findstring Darwin, ${OSTYPE}),-LIbz,-Libz)
define check_utf8
_LOCAL=1 file ${FILE_OPTS} $< | egrep -qi 'charset=utf-8|ASCII' || echo "WARNING: Please convert $< to utf-8" >&2
endef



########################################
# Clean up
.PHONY: clean clean.content clean.logs hide.logs
clean: SHELL=${GUARD_SHELL}
clean: clean.content clean.logs

clean.content: SHELL=${GUARD_SHELL}
clean.content:
	${RM} *.tc *.tc${GZ} *${RULEX} *${LANGX} *${LANGXZ}
	${RM} ${TOK}

clean.logs: SHELL=${GUARD_SHELL}
clean.logs:
	${RM} run-parallel-logs-*
	${RM} log.*
	${RM} .logs

# Hide logs from user's view into .logs
hide.logs: SHELL=${GUARD_SHELL}
hide.logs: hide_logs_sub



################################################################################
# Checking if all required files are present

# Define a function that checks the presence of a required file based on a stem given by the user.
# args $1 file stem
FILE_EXISTS = $(strip $(wildcard ${1}${ALIGNX}) $(wildcard ${1}${ALIGNX}${GZ}) $(wildcard ${1}${RAWX}) $(wildcard ${1}${RAWX}${GZ}))

.PHONY: unittest unittest_no_file unittest.other unittest.raw unittest.raw.gz unittest.al unittest.al.gz
unittest: SHELL=bash
unittest:
	${MAKE} unittest_no_file
	touch unittest.other
	sleep 2; ${MAKE} unittest.other
	rm unittest.other
	touch unittest.raw
	sleep 2; ${MAKE} unittest.raw
	rm unittest.raw

unittest_no_file:
	[[ -z "$(call FILE_EXISTS, $@)" ]] || ! echo "ERROR: Function FILE_EXISTS have detected a file when none exists." >&2

unittest.other:
	[[ -z "$(call FILE_EXISTS, $@)" ]] || ! echo "ERROR: Function FILE_EXISTS have detected a file but was confused by the wrong extension." >&2

unittest.raw:
	test -f "$(call FILE_EXISTS, $@)" || ! echo "ERROR: Function FILE_EXISTS failed to detect .raw file." >&2

unittest.raw.gz:
	test -f $(call FILE_EXISTS, $@) || ! echo "ERROR: Function FILE_EXISTS failed to detect .raw.gz file." >&2

unittest.al:
	test -f $(call FILE_EXISTS, $@) || ! echo "ERROR: Function FILE_EXISTS failed to detect .al file." >&2

unittest.al.gz:
	test -f $(call FILE_EXISTS, $@) || ! echo "ERROR: Function FILE_EXISTS failed to detect .al.gz file." >&2


# Verify the presence of the target language model's corpus file.
$(foreach l, $(addsuffix _${TGT_LANG}, ${TRAIN_LM}), \
	$(if $(call  FILE_EXISTS, $l),, \
		$(error For your language model, you must provide $l)))

# Verify the presence of the truecasing language model's corpus file.
$(foreach l, $(addsuffix _${TGT_LANG}, ${TRAIN_TC}), \
	$(if $(call  FILE_EXISTS, $l),, \
		$(error For your truecasing language model, you must provide $l)))

# Verify the presence of the mixlm's corpora files.
$(foreach l, $(addsuffix _${SRC_LANG}, ${MIXLM}) $(addsuffix _${TGT_LANG}, ${MIXLM}), \
	$(if $(call  FILE_EXISTS, $l),, \
		$(error With mixlm, you must provide $l)))

# Verify the presence of the translation model's corpora files.
$(foreach l, $(addsuffix _${SRC_LANG}, ${TRAIN_TM}) $(addsuffix _${TGT_LANG}, ${TRAIN_TM}), \
	$(if $(call  FILE_EXISTS, $l),, \
		$(error For your translation model, you must provide $l)))

# Verify the presence of decoder's tuning corpora files.
$(foreach l, $(addsuffix _${SRC_LANG}, ${TUNE_DECODE}) $(addsuffix _${TGT_LANG}, ${TUNE_DECODE}), \
	$(if $(call  FILE_EXISTS, $l),, \
		$(error In order to tune the decoder, you must provide $l)))

# Verify the presence of rescoring's tuning corpora files.
$(foreach l, $(addsuffix _${SRC_LANG}, ${TUNE_RESCORE}) $(addsuffix _${TGT_LANG}, ${TUNE_RESCORE}), \
	$(if $(call  FILE_EXISTS, $l),, \
		$(error In order to tune the rescoring module, you must provide $l)))

# Verify the presence of confidence estimation's tuning corpora files.
$(foreach l, $(addsuffix _${SRC_LANG}, ${TUNE_CE}) $(addsuffix _${TGT_LANG}, ${TUNE_CE}), \
	$(if $(call  FILE_EXISTS, $l),, \
		$(error In order to tune the confidence estimation module, you must provide $l)))

# Verify the presence of test set's corpora files.
$(foreach l, $(addsuffix _${SRC_LANG}, ${TEST_SET}) $(addsuffix _${TGT_LANG}, ${TEST_SET}), \
	$(if $(call  FILE_EXISTS, $l),, \
		$(error In order to test the quality of your system, you must provide $l)))

# Verify the presence of translation set's corpora files.
$(foreach l, $(addsuffix _${TGT_LANG}, ${TRANSLATE_SET}), \
	$(if $(call  FILE_EXISTS, $l),, \
		$(error You must provide $l)))

ifdef DO_CE
# Verify the presence of the source language model's corpus file.
$(foreach l, $(addsuffix _${SRC_LANG}, ${TRAIN_LM}), \
	$(if $(call  FILE_EXISTS, $l),, \
		$(error For your language model, you must provide $l)))

endif

ifdef TC_USE_SRC_MODELS
# Verify the presence of the source language model's corpus file.
$(foreach l, $(addsuffix _${SRC_LANG}, ${TRAIN_TC}), \
	$(if $(call  FILE_EXISTS, $l),, \
		$(error For your truecasing language model, you must provide $l)))
endif


################################################################################
# HELPERS
.PHONY: debug
debug: SHELL=${GUARD_SHELL}
debug:
	@echo "LIST_FINAL_OUTPUT: ${LIST_FINAL_OUTPUT}"
	@echo "LC: ${LC}"
	@echo "TRAIN_TC: ${TRAIN_TC}"
	@echo "TC: ${TC}"
	@echo "SRC_RAW_LIST: ${SRC_RAW_LIST}"
	@echo "SRC_TOK_LIST: ${SRC_TOK_LIST}"
	@echo "SRC_RAW_LIST: ${TGT_RAW_LIST}"
	@echo "SRC_TOK_LIST: ${TGT_TOK_LIST}"
	@echo "SRC_RAWZ_LIST: ${SRC_RAWZ_LIST}"
	@echo "SRC_TOKZ_LIST: ${SRC_TOKZ_LIST}"
	@echo "SRC_RAWZ_LIST: ${TGT_RAWZ_LIST}"
	@echo "SRC_TOKZ_LIST: ${TGT_TOKZ_LIST}"
	@echo "TOK: ${TOK}"
