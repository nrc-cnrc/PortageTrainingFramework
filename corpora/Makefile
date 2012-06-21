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


# What command to use for lowercasing corpora.
ifdef ICU
LOWERCASE ?= utf8_casemap -c l
else
LOWERCASE ?= lc-utf8.pl
endif

UTF8 := $(if $(findstring Darwin, ${OSTYPE}),UTF-8,utf8)
export LC_ALL = en_CA.${UTF8}


# Where are the aligned corpora to process.
ALIGN_CORPORA_DIR ?= .

# If we have untokenized corpora, this is where we would find them.
RAW_CORPORA_DIR ?= .

# Let's allow for different tokenizer based on language.
TOKENIZER_en ?= utokenize.pl -noss -lang=en
TOKENIZER_fr ?= utokenize.pl -noss -lang=fr
ifdef USE_ICTCLAS
#TOKENIZER_ch ?= ictclas_run.sh 
TOKENIZER_ch := { set -o pipefail; iconv -c -f UTF-8 -t CN-GB \
                | ictclas_preprocessing.pl | ictclas | ictclas_postprocessing.pl \
                | iconv -c -f CN-GB -t UTF-8; }
else
TOKENIZER_ch ?= chinese_segmenter.pl
endif

# Language specific set of command to mark source devs/tests.
MARK_RULE_en ?= canoe-escapes.pl -add
MARK_RULE_fr ?= canoe-escapes.pl -add
# NOTE: chinese_rule_create.pl takes care of escaping "<>\" like canoe-escape.pl does.
MARK_RULE_ch ?= { chinese_rule_markup.pl | chinese_rule_create.pl; }


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
all: SHELL=${GUARD_SHELL}
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


# Arrange to run recipes for processing small files using a local shell;
# otherwise use the FRAMEWORK_SHELL with one CPU for the job.
SMALL_SETS := ${HELDOUT_SET}
IS_SMALL_SET = $(findstring $(basename $@), $(addsuffix _${SRC_LANG}, ${SMALL_SETS}) \
                                            $(addsuffix _${TGT_LANG}, ${SMALL_SETS}))

CORPUS_SHELL = $(if ${IS_SMALL_SET},${GUARD_SHELL},${FRAMEWORK_SHELL})
RP_SHELL_OPTS = $(if  ${IS_SMALL_SET},,RP_PSUB_OPTS="-1")
# Don't run time-mem when processing small files.
TIME_MEM = $(if ${IS_SMALL_SET},,time-mem)
LOG_STDERR = $(if ${IS_SMALL_SET},,2> log.$(@:${GZ}=))

                   
########################################
# TOKENIZATION.
# For the tokenization targets, we automatically detect raw files and if we
# find any, there will be a rule to process them.  If no raw files are found
# then the following targets are automatically disabled.

## Tokenize source corpora without sentence splitting.
SRC_RAW_LIST ?= $(notdir $(wildcard ${RAW_CORPORA_DIR}/*_${SRC_LANG}${RAWX}))
SRC_TOK_LIST ?= $(SRC_RAW_LIST:${RAWX}=${ALIGNX})
TOK += ${SRC_TOK_LIST}

${SRC_TOK_LIST}: SHELL=${CORPUS_SHELL}
${SRC_TOK_LIST}: %${ALIGNX}: %${RAWX}
	@${check_utf8}
	${RP_SHELL_OPTS} ${TIME_MEM} \
	${TOKENIZER_${SRC_LANG}} < $< > $@ ${LOG_STDERR}


## Tokenize target corpora without sentence splitting.
TGT_RAW_LIST ?= $(notdir $(wildcard ${RAW_CORPORA_DIR}/*_${TGT_LANG}${RAWX}))
TGT_TOK_LIST ?= $(TGT_RAW_LIST:${RAWX}=${ALIGNX})
TOK += ${TGT_TOK_LIST}

${TGT_TOK_LIST}: SHELL=${CORPUS_SHELL}
${TGT_TOK_LIST}: %${ALIGNX}: %${RAWX}
	@${check_utf8}
	${RP_SHELL_OPTS} ${TIME_MEM} \
	${TOKENIZER_${TGT_LANG}} < $< > $@ ${LOG_STDERR}


## Compress the source/language corpora if needed.
$(addsuffix ${GZ}, ${SRC_TOK_LIST} ${TGT_TOK_LIST}): SHELL=${CORPUS_SHELL}
$(addsuffix ${GZ}, ${SRC_TOK_LIST} ${TGT_TOK_LIST}): %${GZ}: %
	${RP_SHELL_OPTS} \
	cat $< | ${TIME_MEM} gzip > $@ ${LOG_STDERR}.gzip



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
		"${TOKENIZER_${SRC_LANG}} < $< > $@" ${LOG_STDERR}


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
		"${TOKENIZER_${TGT_LANG}} < $< > $@" ${LOG_STDERR}


TM_TOK    ?= $(foreach t, ${TRAIN_TM}, $(filter $t%, ${TOK}))
LM_TOK    ?= $(foreach t, ${TRAIN_LM}, $(filter $t%, ${TOK}))
TC_TOK    ?= $(foreach t, ${TRAIN_TC}, $(filter $t%, ${TOK}))
MIXLM_TOK ?= $(foreach t, ${MIXLM}, $(filter $t%, ${TOK}))


.PHONY: tok
tok: SHELL=${GUARD_SHELL}
tok: ${TOK}



########################################
# TRUECASE.
# Define what corpora we need truecased/tokenized for the truecase model.
.PHONY: tc
TC := $(addsuffix _${TGT_LANG}${TCX}${GZ}, ${TRAIN_TC})
tc: SHELL=${GUARD_SHELL}
tc: ${TC}

# Prepare truecased file.
%${TCX}: SHELL=${GUARD_SHELL}
%${TCX}: %${ALIGNX}
	@${check_utf8}
	ln -fs $< $@

%${TCX}${GZ}: SHELL=${GUARD_SHELL}
%${TCX}${GZ}: %${ALIGNX}${GZ}
	@${check_utf8}
	ln -fs $< $@



########################################
# LOWERCASING.
# Define what corpora we need in the entire pipeline.
.PHONY: lc
HELDOUT_LC += $(addsuffix _${SRC_LANG}${LANGX}, ${HELDOUT_SET})
HELDOUT_LC += $(addsuffix _${TGT_LANG}${LANGX}, ${HELDOUT_SET})
LC += ${HELDOUT_LC}
# Note that will want to compress the TRAIN_SET for space efficiency.
TM_LC += $(addsuffix _${SRC_LANG}${LANGXZ}, ${TRAIN_TM})
TM_LC += $(addsuffix _${TGT_LANG}${LANGXZ}, ${TRAIN_TM})
TM_LC += $(addsuffix _${SRC_LANG}${LANGXZ}, ${MIXTM})
TM_LC += $(addsuffix _${TGT_LANG}${LANGXZ}, ${MIXTM})
LC += ${TM_LC}
MIXLM_LC += $(addsuffix _${SRC_LANG}${LANGXZ}, ${MIXLM})
MIXLM_LC += $(addsuffix _${TGT_LANG}${LANGXZ}, ${MIXLM})
LC += ${MIXLM_LC}
TC_LC += $(addsuffix _${TGT_LANG}${LANGXZ}, ${TRAIN_TC})
LC += ${TC_LC}
LM_LC += $(addsuffix _${TGT_LANG}${LANGXZ}, ${TRAIN_LM})
ifdef TC_USE_SRC_MODELS
LM_LC += $(addsuffix _${SRC_LANG}${LANGXZ}, ${TRAIN_TC})
endif
ifdef DO_CE
LM_LC += $(addsuffix _${SRC_LANG}${LANGXZ}, ${TRAIN_LM})
endif
LC += ${LM_LC}
lc: SHELL=${GUARD_SHELL}
lc: ${LC}


# Construct a lowercased corpora from its aligned version.
%${LANGX}: SHELL=${CORPUS_SHELL}
%${LANGX}: %${ALIGNX}
	@$(check_utf8)
	${RP_SHELL_OPTS} \
	cat $< | ${TIME_MEM} ${LOWERCASE} ${LOG_STDERR} > $@

%${LANGXZ}: SHELL=${CORPUS_SHELL}
%${LANGXZ}: %${ALIGNX}${GZ}
	@$(check_utf8)
	${RP_SHELL_OPTS} \
	set -o pipefail; \
	zcat $< | ${TIME_MEM} ${LOWERCASE} ${LOG_STDERR} | gzip > $@



########################################
# Shortcut to only create final translation models' corpora.
.PHONY: tm
tm: SHELL=${GUARD_SHELL}
tm: ${TM_LC}



########################################
# RULES.
# Add some markup to the source HELDOUT_SET.
# If you have special markup, this is where you would write your code.
.PHONY: rule
RULE = $(addsuffix ${RULEX}, ${HELDOUT_SET})
rule: SHELL=${GUARD_SHELL}
rule: ${RULE}

%${RULEX}: SHELL=${CORPUS_SHELL}
%${RULEX}: %_${SRC_LANG}${LANGX}
	@$(check_utf8)
	${RP_SHELL_OPTS} ${TIME_MEM} \
	${MARK_RULE_${SRC_LANG}} < $< > $@ ${LOG_STDERR}



# NOTE: here TRANSLATE_SET must contain the prefix only.
# Special target to prepare a new translation set.
TRANSLATE_SET_LIST = $(foreach t,${TRANSLATE_SET}, $t${RULEX} $t_${SRC_LANG}${LANGX})
.PHONY: translate
translate: SHELL=${GUARD_SHELL}
translate: ${TRANSLATE_SET_LIST}


# Special target to prepare the reference.
.PHONY: reference
reference: SHELL=${GUARD_SHELL}
reference: $(foreach t,${TRANSLATE_SET},  $t_${TGT_LANG}${LANGX})


# Check if the first dependency is a utf8 file.
FILE_OPTS = $(if $(findstring Darwin, ${OSTYPE}),-LIbz,-Libz)
define check_utf8
_LOCAL=1 file ${FILE_OPTS} $< | egrep -qi 'charset=utf-8|ASCII' || echo "WARNING: Please convert $< to utf-8" >&2
endef



# HACK ALERT!!!!
SENTENCE_SPLITTER_ch := perl -ple "BEGIN{use encoding \"UTF-8\";} s/(\.\.\.\.\.\.|\.\.\.|\x{2026}|[\x2E]|\x{FF0E}|[\x3F]|\x{FF1F}|[\x21]|\x{FF01}|\x{3002}|\x{FF61})/$$1\\n/g"
ifeq ("${SRC_LANG}","ch")
../models/portageLive/plugins:
	mkdir -p $@
../models/portageLive/plugins/tokenize_plugin:  | ../models/portageLive/plugins
	echo -e '#!/bin/bash\n$(and ${SENTENCE_SPLITTER_${SRC_LANG}}, ${SENTENCE_SPLITTER_${SRC_LANG}} | )${TOKENIZER_${SRC_LANG}}' > $@
	chmod +x $@
../models/portageLive/plugins/predecode_plugin:  | ../models/portageLive/plugins
	echo -e '#!/bin/bash\n${MARK_RULE_${SRC_LANG}}' > $@
	chmod +x $@
portageLive:  ../models/portageLive/plugins/tokenize_plugin
portageLive:  ../models/portageLive/plugins/predecode_plugin
endif
.PHONY: portageLive
portageLive:
	@true



########################################
# Clean up
.PHONY: clean clean.content clean.logs hide.logs
clean: SHELL=${GUARD_SHELL}
clean: clean.content clean.logs

clean.content: SHELL=${GUARD_SHELL}
clean.content:
	${RM} ${TOK}
	${RM} *.tc *.tc${GZ} *${RULEX} *${LANGX} *${LANGXZ}

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
# Look for raw or aligned files.
BASE_FILE_EXISTS = $(strip $(wildcard ${1}${ALIGNX}) $(wildcard ${1}${ALIGNX}${GZ}) $(wildcard ${1}${RAWX}) $(wildcard ${1}${RAWX}${GZ}))
# Look for raw or aligned or lowercase files.
FILE_EXISTS = $(strip $(call BASE_FILE_EXISTS, ${1}) $(wildcard ${1}${LANGX}) $(wildcard ${1}${LANGXZ}))

ifneq (${MAKECMDGOALS},clean)
ifneq (${MAKECMDGOALS},clean.content)
ifneq (${MAKECMDGOALS},clean.logs)

# Verify the presence of the truecasing language model's corpus file.
$(foreach l, $(addsuffix _${TGT_LANG}, ${TRAIN_TC}), \
	$(if $(strip $(call  BASE_FILE_EXISTS, $l) $(wildcard $l${TCX}) $(wildcard $l${TCX}${GZ})),, \
		$(error For your truecasing language model, you must provide $l)))


# Verify the presence of the target language model's corpus file.
$(foreach l, $(addsuffix _${TGT_LANG}, ${TRAIN_LM}), \
	$(if $(call  FILE_EXISTS, $l),, \
		$(error For your language model, you must provide $l)))

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

# The new truecaser requires the aligned source corpora.
$(foreach t, $(addsuffix _${SRC_LANG}, ${TEST_SET} ${TRANSLATE_SET}), \
	$(if $(call  BASE_FILE_EXISTS, $t),, \
		$(error In order to truecase your test set, you must provide the aligned corpus for $t)))
endif

endif	# MAKECMDGOALS check
endif
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
	@echo "TGT_RAW_LIST: ${TGT_RAW_LIST}"
	@echo "TGT_TOK_LIST: ${TGT_TOK_LIST}"
	@echo "SRC_RAWZ_LIST: ${SRC_RAWZ_LIST}"
	@echo "SRC_TOKZ_LIST: ${SRC_TOKZ_LIST}"
	@echo "TGT_RAWZ_LIST: ${TGT_RAWZ_LIST}"
	@echo "TGT_TOKZ_LIST: ${TGT_TOKZ_LIST}"
	@echo "TOK: ${TOK}"
	@echo "TM_TOK: ${TM_TOK}"
	@echo "LM_TOK: ${LM_TOK}"
	@echo "TC_TOK: ${TC_TOK}"
	@echo "MIXLM_TOK: ${MIXLM_TOK}"



########################################
# Generate all corpora version in order to have sufficient corpora to exercice all paths in the framework.
.PHONY: unittest1
unittest1:  export TUNE_DECODE = dev1
unittest1:  export TUNE_RESCORE = dev2
unittest1:  export TUNE_CE = dev3
unittest1:  export TEST_SET = test1 test2
unittest1:  export TRAIN_LM = lm-train
unittest1:  export TRAIN_TC = tc-train lm-ce
unittest1:  export TRAIN_TM = tm-train
unittest1:  export MIXLM = sublm1 sublm2 sublm3
unittest1:
	${MAKE} all

