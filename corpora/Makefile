#!/usr/bin/make -f
# vim:noet:ts=3:nowrap

# @file Makefile
# @brief Simple preprocessing of corpora, mainly lowercasing.
#
# @author Samuel Larkin
#
# Traitement multilingue de textes / Multilingual Text Processing
# Tech. de l'information et des communications / Information and Communications Tech.
# Conseil national de recherches Canada / National Research Council Canada
# Copyright 2008, 2015, Sa Majeste la Reine du Chef du Canada
# Copyright 2008, 2015, Her Majesty in Right of Canada

# Mandatory include: master config file.
include ../Makefile.params

# Include and override parameters with user specific config file.
MAKEFILE_PARAMS ?= Makefile.params
-include ${MAKEFILE_PARAMS}

# Include the master toolkit.
include ../Makefile.toolkit

# If your files are not tokenize, they should have the RAWX extentsion.
RAWX ?= .raw

# What is the truecase corpus extension.
TCX ?= .tc


# Define the corpora.
TRAIN_SET    := $(sort ${TRAIN_LM} ${TRAIN_TM} ${TRAIN_TC} ${TRAIN_LDM} ${TRAIN_HLDM} \
                       ${TRAIN_COARSELM} ${TRAIN_BILM} ${TRAIN_WCL} ${TRAIN_SPARSE} \
                       ${NNJM_TRAIN_CORPORA} ${NNJM_FINE_TUNING_TRAIN_CORPORA})
# NOTE: heldout are stem that are for a source corpus and one or more references.
HELDOUT_SET  := $(sort ${TUNE_DECODE} ${TUNE_RESCORE} ${TUNE_CE} ${TEST_SET} \
                       ${TUNE_MIXTM} ${TUNE_LM} ${TUNE_COARSELM} \
                       ${NNJM_DEV_CORPORA} ${NNJM_FINE_TUNING_DEV_CORPORA} \
                       ${NNJM_TEST_CORPORA} ${NNJM_FINE_TUNING_TEST_CORPORA} \
                       $(addprefix ${TUNE_DECODE}, ${TUNE_DECODE_VARIANTS}))
CORPORA_SET  := $(sort ${TRAIN_SET} ${HELDOUT_SET})


# What command to use for lowercasing corpora.
ifdef ICU
LOWERCASE ?= utf8_casemap -c l
else
LOWERCASE ?= lc-utf8.pl
endif

# If you don't want to have the source side of your corpora be lowercased
# define DONT_LOWERCASE_SRC in ./Makefile.params
#DONT_LOWERCASE_SRC = 1


# Where are the aligned corpora to process.
ALIGN_CORPORA_DIR ?= .

# If we have untokenized corpora, this is where we would find them.
RAW_CORPORA_DIR ?= .

# Let's allow for different tokenizer based on language.
TOKENIZER_en ?= { set -o pipefail; fix-slashes.pl | utokenize.pl -noss -lang=en; }
TOKENIZER_fr ?= { set -o pipefail; fix-slashes.pl | utokenize.pl -noss -lang=fr; }
TOKENIZER_da ?= { set -o pipefail; fix-slashes.pl | utokenize.pl -noss -lang=da; }
TOKENIZER_es ?= { set -o pipefail; fix-slashes.pl | utokenize.pl -noss -lang=es; }
#TOKENIZER_en ?= utokenize.pl -noss -lang=en
#TOKENIZER_fr ?= utokenize.pl -noss -lang=fr
#TOKENIZER_da ?= utokenize.pl -noss -lang=da
#TOKENIZER_es ?= utokenize.pl -noss -lang=es
TOKENIZER_ar ?= tokenize_plugin ar
ifdef USE_ICTCLAS
#TOKENIZER_ch ?= ictclas_run.sh
#TODO This cannot possibly work correctly, for the same reason the fix-slashes.pl pipe is broken above!
TOKENIZER_ch := { set -o pipefail; iconv -c -f UTF-8 -t CN-GB \
                | ictclas_preprocessing.pl | ictclas | ictclas_postprocessing.pl \
                | iconv -c -f CN-GB -t UTF-8; }
else
TOKENIZER_ch ?= chinese_segmenter.pl
endif

# Language specific set of command to mark source devs/tests.
MARK_RULE_DEFAULT := canoe-escapes.pl -add
MARK_RULE_en ?= ${MARK_RULE_DEFAULT}
MARK_RULE_fr ?= ${MARK_RULE_DEFAULT}
# NOTE: chinese_rule_create.pl takes care of escaping "<>\" like canoe-escape.pl does.
MARK_RULE_ch ?= { chinese_rule_markup.pl | chinese_rule_create.pl; }


# We want a minimum of 100,000 lines per jobs that parallelize.pl creates.
MINIMUM_PARALLEL_CHUNK_SIZE ?= 100000



# Tells make where to find the raw corpora files.
vpath %${ALIGNX} ${ALIGN_CORPORA_DIR}
vpath %${RAWX}   ${RAW_CORPORA_DIR}


.DEFAULT_GOAL := help
# .SECONDARY is required when train_??.al is not gzipped
.SECONDARY:
.SUFFIXES:
.DELETE_ON_ERROR:


MAIN_TARGETS :=  all clean help

########################################
# Help message
.PHONY: help
help: SHELL=${LOCAL_SHELL}
help:
	@echo "Tokenize and lowercase all corpora listed in CORPORA_SET."
	@echo "CORPORA_SET: ${CORPORA_SET}"
	@echo
	@echo "To prepare the corpora, type: make all"
	@echo
	@echo "The main targets in this Makefile are:"
	@echo ${MAIN_TARGETS}
	@echo
	@echo "Expected output files are:"
	@sed -e 's/  */\n/g' <<< "$(strip ${EXPECTED_FILES})"


# What are the final ouptut so we can manipulate them as a whole?
EXPECTED_FILES += ${LC} ${RULE}

# After this Makefile, the following targets/files are precious.
FILES_TO_BE_LOCKED = ${EXPECTED_FILES}

# Defines all that needs to be done by this makefile.
.PHONY: all
all: SHELL=${LOCAL_SHELL}
all: lc
all: rule
ifdef DO_TRUECASING
all: tc
EXPECTED_FILES += ${TC}
endif
ifdef TRANSLATE_SET
all: translate
EXPECTED_FILES += ${TRANSLATE_SET_LIST}
endif

# What the user can expect from this module.
.PHONY: list_final_output
list_final_output: SHELL=${LOCAL_SHELL}
list_final_output:
	@echo "Expected final output(s):"
	@echo ${LC}
	@echo ${RULE}
	@echo ${TC}
	@echo ${TRANSLATE_SET_LIST}


# Arrange to run recipes for processing small files using a local shell;
# otherwise use the FRAMEWORK_SHELL with one CPU for the job.
SMALL_SETS := ${HELDOUT_SET} ${TUNE_MIXTM} ${TUNE_MIXTM_MULTIPLE_REFERENCES}
IS_SMALL_SET = $(findstring $(basename $@), $(addsuffix _${SRC_LANG}, ${SMALL_SETS}) \
                                            $(addsuffix _${TGT_LANG}, ${SMALL_SETS}))

# CORPUS_SHELL always uses minimal resources per worker when submitting to the cluster
CORPUS_SHELL = $(if ${IS_SMALL_SET},${LOCAL_SHELL},$(if ${USING_CLUSTER},${FRAMEWORK_SHELL} -psub "-cpus 1 -mem 4",${FRAMEWORK_SHELL}))
# Don't run time-mem when processing small files.
TIME_MEM = $(if ${IS_SMALL_SET},,time-mem)
LOG_STDERR = $(if ${IS_SMALL_SET},,2> log.$(@:${GZ}=))

########################################
# Create 90% sample subsets of the TUNE_DECODE set for the TUNE_DECODE_VARIANTS

CORPX := $(strip $(if $(wildcard ${TUNE_DECODE}_${SRC_LANG}${RAWX}), ${RAWX}, ${ALIGNX}))

TUNE_VARIANTS_SRC := $(addsuffix _${SRC_LANG}${CORPX}, $(addprefix ${TUNE_DECODE}, ${TUNE_DECODE_VARIANTS}))
TUNE_VARIANTS_TGT := $(addsuffix _${TGT_LANG}${CORPX}, $(addprefix ${TUNE_DECODE}, ${TUNE_DECODE_VARIANTS}))

ifdef TUNE_DECODE_VARIANTS
ifneq ($(filter $(lastword ${TUNE_DECODE_VARIANTS}), $(join ${TUNE_DECODE_VARIANTS}, $(addprefix ^,1 2 3 4 5 6 7 8 9 0))),)
$(warning Warning: Only the first 10 generated 90% sample subsets will be unique.)
endif
endif

seed = $(strip $(subst $(strip $1)^,,$(filter $(strip $1)^%, $(join ${TUNE_DECODE_VARIANTS}, $(addprefix ^,1 2 3 4 5 6 7 8 9 0)))))

${TUNE_VARIANTS_SRC}: ${TUNE_DECODE}%_${SRC_LANG}${CORPX}: ${TUNE_DECODE}_${SRC_LANG}${CORPX} ${TUNE_DECODE}_${TGT_LANG}${CORPX}
	sample_parallel_text -c -p 90 -seed 2012$(call seed, $*) -s .sample.$* $+
	mv ${TUNE_DECODE}_${SRC_LANG}${CORPX}.sample.$* ${TUNE_DECODE}$*_${SRC_LANG}${CORPX}
	mv ${TUNE_DECODE}_${TGT_LANG}${CORPX}.sample.$* ${TUNE_DECODE}$*_${TGT_LANG}${CORPX}

${TUNE_VARIANTS_TGT}: ${TUNE_DECODE}%_${TGT_LANG}${CORPX}: | ${TUNE_DECODE}%_${SRC_LANG}${CORPX} ;
                   
########################################
# TOKENIZATION.
# For the tokenization targets, we automatically detect raw files and if we
# find any, there will be a rule to process them.  If no raw files are found
# then the following targets are automatically disabled.

## Tokenize source corpora without sentence splitting.
SRC_RAW_LIST ?= $(notdir $(wildcard ${RAW_CORPORA_DIR}/*_${SRC_LANG}${RAWX}))
ifdef TUNE_DECODE_VARIANTS
ifeq (${CORPX},${RAWX})
SRC_RAW_LIST := $(filter-out ${TUNE_VARIANTS_SRC}, ${SRC_RAW_LIST})
SRC_RAW_LIST += ${TUNE_VARIANTS_SRC}
endif
endif
SRC_TOK_LIST ?= $(SRC_RAW_LIST:${RAWX}=${ALIGNX})
TOK += ${SRC_TOK_LIST}

${SRC_TOK_LIST}: SHELL=${CORPUS_SHELL}
${SRC_TOK_LIST}: %${ALIGNX}: %${RAWX}
	@${check_utf8}
	${TOKENIZER_${SRC_LANG}} < $< > $@ ${LOG_STDERR}


## Tokenize target corpora without sentence splitting.
TGT_RAW_LIST ?= $(notdir $(wildcard ${RAW_CORPORA_DIR}/*_${TGT_LANG}${RAWX}))
ifdef TUNE_DECODE_VARIANTS
ifeq (${CORPX},${RAWX})
TGT_RAW_LIST := $(filter-out ${TUNE_VARIANTS_TGT}, ${TGT_RAW_LIST})
TGT_RAW_LIST += ${TUNE_VARIANTS_TGT}
endif
endif
TGT_TOK_LIST ?= $(TGT_RAW_LIST:${RAWX}=${ALIGNX})
TOK += ${TGT_TOK_LIST}

${TGT_TOK_LIST}: SHELL=${CORPUS_SHELL}
${TGT_TOK_LIST}: %${ALIGNX}: %${RAWX}
	@${check_utf8}
	${TOKENIZER_${TGT_LANG}} < $< > $@ ${LOG_STDERR}


## Compress the source/language corpora if needed.
$(addsuffix ${GZ}, ${SRC_TOK_LIST} ${TGT_TOK_LIST}): SHELL=${CORPUS_SHELL}
$(addsuffix ${GZ}, ${SRC_TOK_LIST} ${TGT_TOK_LIST}): %${GZ}: %
	cat $< | ${TIME_MEM} gzip > $@ ${LOG_STDERR}.gzip



## HOW to handle big source language corpora.
SRC_RAWZ_LIST ?= $(notdir $(wildcard ${RAW_CORPORA_DIR}/*_${SRC_LANG}${RAWX}${GZ}))
SRC_TOKZ_LIST ?= $(SRC_RAWZ_LIST:${RAWX}${GZ}=${ALIGNX}${GZ})
TOK += ${SRC_TOKZ_LIST}

${SRC_TOKZ_LIST}: SHELL=${LOCAL_SHELL}
${SRC_TOKZ_LIST}: %${ALIGNX}${GZ}: %${RAWX}${GZ}
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

${TGT_TOKZ_LIST}: SHELL=${LOCAL_SHELL}
${TGT_TOKZ_LIST}: %${ALIGNX}${GZ}: %${RAWX}${GZ}
	parallelize.pl \
		-nolocal \
		-psub -1 \
		-w ${MINIMUM_PARALLEL_CHUNK_SIZE} \
		-n ${PARALLELISM_LEVEL_CORPORA} \
		"${TOKENIZER_${TGT_LANG}} < $< > $@" ${LOG_STDERR}


TM_TOK    ?= $(filter $(addsuffix %, ${TRAIN_TM}), ${TOK})
LM_TOK    ?= $(filter $(addsuffix %, ${TRAIN_LM}), ${TOK})
TC_TOK    ?= $(filter $(addsuffix %, ${TRAIN_TC}), ${TOK})
MIXLM_TOK ?= $(filter $(addsuffix %, ${MIXLM}), ${TOK})


.PHONY: tok
tok: SHELL=${LOCAL_SHELL}
tok: ${TOK}

.PHONY:  tok.src tok.${SRC_LANG}
tok.src:  tok.${SRC_LANG}
tok.${SRC_LANG}:  $(filter %_${SRC_LANG}${ALIGNX}${GZ} %_${SRC_LANG}${ALIGNX}, ${TOK})

.PHONY:  tok.tgt tok.${TGT_LANG}
tok.tgt:  tok.${TGT_LANG}
tok.${TGT_LANG}:  $(filter %_${TGT_LANG}${ALIGNX}${GZ} %_${TGT_LANG}${ALIGNX}, ${TOK})


########################################
# TRUECASE.
# Define what corpora we need truecased/tokenized for the truecase model.
.PHONY: tc
TC := $(addsuffix _${TGT_LANG}${TCX}${GZ}, ${TRAIN_TC})
tc: SHELL=${LOCAL_SHELL}
tc: ${TC}

# Prepare truecased file.
%${TCX}: SHELL=${LOCAL_SHELL}
%${TCX}: %${ALIGNX}
	@${check_utf8}
	ln -fs $< $@

%${TCX}${GZ}: SHELL=${LOCAL_SHELL}
%${TCX}${GZ}: %${ALIGNX}${GZ}
	@${check_utf8}
	ln -fs $< $@


########################################
# TUNING MIXTM WITH MULTIPLE REFERENCES
ifdef TUNE_MIXTM_MULTIPLE_REFERENCES
MIXTM_LC := ${TUNE_MIXTM_MULTIPLE_REFERENCES}_${SRC_LANG}${LANGX} ${TUNE_MIXTM_MULTIPLE_REFERENCES}_${TGT_LANG}${LANGX}
LC += ${MIXTM_LC}

${TUNE_MIXTM_MULTIPLE_REFERENCES}_${TGT_LANG}${LANGX}:  SHELL=${LOCAL_SHELL}
${TUNE_MIXTM_MULTIPLE_REFERENCES}_${TGT_LANG}${LANGX}:  ${TUNE_MIXTM_MULTIPLE_REFERENCES}_${SRC_LANG}${LANGX}
	test -s $@ && sleep 1 && touch $@

${TUNE_MIXTM_MULTIPLE_REFERENCES}_${SRC_LANG}${LANGX}:  $(foreach i, ${REFERENCE_INDICES}, ${TUNE_MIXTM}_${SRC_LANG}${LANGX})
${TUNE_MIXTM_MULTIPLE_REFERENCES}_${SRC_LANG}${LANGX}:  $(call CREATE_REFERENCE_NAMES, ${TUNE_MIXTM})
	paste --delimiters= \
		<(zcat -f $(filter %_${SRC_LANG}${LANGX},$+)) \
		<(zcat -f $(filter-out %_${SRC_LANG}${LANGX},$+)) \
	| sort --unique \
	| tee >(cut -f1 --delimiter= > $@) \
	| cut -f2 --delimiter= > $(@:_${SRC_LANG}${LANGX}=_${TGT_LANG}${LANGX})
endif


########################################
# LOWERCASING.
# Define what corpora we need in the entire pipeline.
HELDOUT_LC += $(addsuffix _${SRC_LANG}${LANGX}, ${HELDOUT_SET})
HELDOUT_REFS = $(foreach r,${HELDOUT_SET},$(call CREATE_REFERENCE_NAMES, $r))
HELDOUT_LC += ${HELDOUT_REFS}
$(info HELDOUT_SET refs: ${HELDOUT_LC})
LC += ${HELDOUT_LC}
# Note that will want to compress the TRAIN_SET for space efficiency.
TM_LC += $(addsuffix _${SRC_LANG}${LANGXZ}, ${TRAIN_TM})
TM_LC += $(addsuffix _${TGT_LANG}${LANGXZ}, ${TRAIN_TM})
TM_LC += $(addsuffix _${SRC_LANG}${LANGXZ}, ${MIXTM})
TM_LC += $(addsuffix _${TGT_LANG}${LANGXZ}, ${MIXTM})
TM_LC += $(addsuffix _${SRC_LANG}${LANGXZ}, ${MIXTM_TRAIN_MIX})
TM_LC += $(addsuffix _${TGT_LANG}${LANGXZ}, ${MIXTM_TRAIN_MIX})
TM_LC += $(addsuffix _${SRC_LANG}${LANGXZ}, ${TRAIN_LDM})
TM_LC += $(addsuffix _${TGT_LANG}${LANGXZ}, ${TRAIN_LDM})
TM_LC += $(addsuffix _${SRC_LANG}${LANGXZ}, ${TRAIN_HLDM})
TM_LC += $(addsuffix _${TGT_LANG}${LANGXZ}, ${TRAIN_HLDM})
TM_LC += $(addsuffix _${SRC_LANG}${LANGXZ}, ${TRAIN_SPARSE})
TM_LC += $(addsuffix _${TGT_LANG}${LANGXZ}, ${TRAIN_SPARSE})
LC += ${TM_LC}
MIXLM_LC += $(addsuffix _${SRC_LANG}${LANGXZ}, ${MIXLM})
MIXLM_LC += $(addsuffix _${TGT_LANG}${LANGXZ}, ${MIXLM})
LC += ${MIXLM_LC}
COARSE_LM += $(addsuffix _${TGT_LANG}${LANGXZ}, ${TRAIN_COARSELM})
LC += ${COARSE_LM}
BILM_LC += $(addsuffix _${SRC_LANG}${LANGXZ}, ${TRAIN_BILM})
BILM_LC += $(addsuffix _${TGT_LANG}${LANGXZ}, ${TRAIN_BILM})
LC += ${BILM_LC}
TC_LC += $(addsuffix _${TGT_LANG}${LANGXZ}, ${TRAIN_TC})
LC += ${TC_LC}
WCL_LC += $(addsuffix _${TGT_LANG}${LANGXZ}, ${TRAIN_WCL})
WCL_LC += $(addsuffix _${SRC_LANG}${LANGXZ}, ${TRAIN_WCL})
LC += ${WCL_LC}
NNJM_LC += $(addsuffix _${TGT_LANG}${LANGXZ}, ${NNJM_TRAIN_CORPORA})
NNJM_LC += $(addsuffix _${SRC_LANG}${LANGXZ}, ${NNJM_TRAIN_CORPORA})
NNJM_LC += $(addsuffix _${TGT_LANG}${LANGXZ}, ${NNJM_FINE_TUNING_TRAIN_CORPORA})
NNJM_LC += $(addsuffix _${SRC_LANG}${LANGXZ}, ${NNJM_FINE_TUNING_TRAIN_CORPORA})
LC += ${NNJM_LC}
LM_LC += $(addsuffix _${TGT_LANG}${LANGXZ}, ${TRAIN_LM})
ifdef TC_USE_SRC_MODELS
LM_LC += $(addsuffix _${SRC_LANG}${LANGXZ}, ${TRAIN_TC})
endif
ifdef DO_CE
LM_LC += $(addsuffix _${SRC_LANG}${LANGXZ}, ${TRAIN_LM})
endif
LC += ${LM_LC}
LC := $(sort ${LC})

.PHONY: lc
lc: SHELL=${LOCAL_SHELL}
lc: ${LC}

.PHONY: lc.heldout
lc.heldout: SHELL=${LOCAL_SHELL}
lc.heldout: ${HELDOUT_LC}

.PHONY: lc.tm
lc.tm: SHELL=${LOCAL_SHELL}
lc.tm: ${TM_LC}

# Construct a lowercased corpora from its aligned version.
ifdef DONT_LOWERCASE_SRC
%${SRC_LANG}${LANGX}: SHELL=${CORPUS_SHELL}
%${SRC_LANG}${LANGX}: %${SRC_LANG}${ALIGNX}
	@$(check_utf8)
	ln -fs $< $@

%${SRC_LANG}${LANGXZ}: SHELL=${CORPUS_SHELL}
%${SRC_LANG}${LANGXZ}: %${SRC_LANG}${ALIGNX}${GZ}
	@$(check_utf8)
	ln -fs $< $@

else
%${SRC_LANG}${LANGX}: SHELL=${CORPUS_SHELL}
%${SRC_LANG}${LANGX}: %${SRC_LANG}${ALIGNX}
	@$(check_utf8)
	cat $< | ${TIME_MEM} $(or ${LOWERCASE_${SRC_LANG}}, ${LOWERCASE}) ${LOG_STDERR} > $@

%${SRC_LANG}${LANGXZ}: SHELL=${CORPUS_SHELL}
%${SRC_LANG}${LANGXZ}: %${SRC_LANG}${ALIGNX}${GZ}
	@$(check_utf8)
	set -o pipefail; zcat $< | ${TIME_MEM} $(or ${LOWERCASE_${SRC_LANG}}, ${LOWERCASE}) ${LOG_STDERR} | gzip > $@

endif

%${TGT_LANG}${LANGX}: SHELL=${CORPUS_SHELL}
%${TGT_LANG}${LANGX}: %${TGT_LANG}${ALIGNX}
	@$(check_utf8)
	cat $< | ${TIME_MEM} $(or ${LOWERCASE_${TGT_LANG}}, ${LOWERCASE}) ${LOG_STDERR} > $@

%${TGT_LANG}${LANGXZ}: SHELL=${CORPUS_SHELL}
%${TGT_LANG}${LANGXZ}: %${TGT_LANG}${ALIGNX}${GZ}
	@$(check_utf8)
	set -o pipefail; zcat $< | ${TIME_MEM} $(or ${LOWERCASE_${TGT_LANG}}, ${LOWERCASE}) ${LOG_STDERR} | gzip > $@


########################################
# Shortcut to only create final translation models' corpora.
.PHONY: tm
tm: SHELL=${LOCAL_SHELL}
tm: ${TM_LC}


########################################
# RULES.
# Add some markup to the source HELDOUT_SET.
# If you have special markup, this is where you would write your code.
.PHONY: rule
RULE = $(addsuffix ${RULEX}, ${HELDOUT_SET})
rule: SHELL=${LOCAL_SHELL}
rule: ${RULE}

%${RULEX}: SHELL=${CORPUS_SHELL}
%${RULEX}: %_${SRC_LANG}${LANGX}
	@$(check_utf8)
	${TIME_MEM} $(or ${MARK_RULE_${SRC_LANG}}, ${MARK_RULE_DEFAULT}) < $< > $@ ${LOG_STDERR}


# NOTE: here TRANSLATE_SET must contain the prefix only.
# Special target to prepare a new translation set.
TRANSLATE_SET_LIST = $(foreach t,${TRANSLATE_SET}, $t${RULEX} $t_${SRC_LANG}${LANGX})
.PHONY: translate
translate: SHELL=${LOCAL_SHELL}
translate: ${TRANSLATE_SET_LIST}


# Special target to prepare the reference.
.PHONY: reference
reference: SHELL=${LOCAL_SHELL}
reference: $(foreach t,${TRANSLATE_SET},  $t_${TGT_LANG}${LANGX})


# Check if the first dependency is a utf8 file.
FILE_OPTS = $(if $(findstring Darwin, ${OSTYPE}),-LIbz,-Libz)
define check_utf8
_LOCAL=1 file ${FILE_OPTS} $< | egrep -qi 'charset=utf-8|ASCII' || echo "WARNING: Please convert $< to utf-8" >&2
endef


########################################
ifeq ("${SRC_LANG}","ch")
../models/portageLive/plugins:
	mkdir -p $@
../models/portageLive/plugins/predecode_plugin:  | ../models/portageLive/plugins
	echo -e '#!/bin/bash\n$(or ${MARK_RULE_${SRC_LANG}}, ${MARK_RULE_DEFAULT})' > $@
	chmod +x $@
portageLive:  ../models/portageLive/plugins/predecode_plugin
endif

.PHONY: portageLive
portageLive:
	@true

MAIN_TARGETS += portageLive


########################################
# Clean up
.PHONY: clean clean.content clean.logs hide.logs
clean: SHELL=${LOCAL_SHELL}
clean: clean.content clean.logs

clean.content: SHELL=${LOCAL_SHELL}
clean.content:
	${RM} ${TOK:=*}
	${RM} *.tc *.tc${GZ} *${RULEX} *${LANGX} *${LANGXZ}

clean.logs: SHELL=${LOCAL_SHELL}
clean.logs:
	${RM} run-parallel-logs-*
	${RM} log.*
	${RM} -r .logs

# Hide logs from user's view into .logs
hide.logs: SHELL=${LOCAL_SHELL}
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

# Let's make sure the tokenizers are defined if we need to tokenize.
ifneq (${SRC_TOK_LIST}${SRC_TOKZ_LIST},)
ifndef TOKENIZER_${SRC_LANG}
$(error You must define TOKENIZER_${SRC_LANG})
endif
endif

ifneq (${TGT_TOK_LIST}${TGT_TOKZ_LIST},)
ifndef TOKENIZER_${TGT_LANG}
$(error You must define TOKENIZER_${TGT_LANG})
endif
endif


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

# Verify the presence of the mixtm's corpora files.
$(foreach l, $(addsuffix _${SRC_LANG}, ${MIXTM}) $(addsuffix _${TGT_LANG}, ${MIXTM}) \
             $(addsuffix _${SRC_LANG}, ${MIXTM_TRAIN_MIX}) $(addsuffix _${TGT_LANG}, ${MIXTM_TRAIN_MIX}), \
	$(if $(call  FILE_EXISTS, $l),, \
		$(error With mixtm, you must provide $l)))

# Verify the presence of the LDM's corpora files.
$(foreach l, $(addsuffix _${SRC_LANG}, ${TRAIN_LDM}) $(addsuffix _${TGT_LANG}, ${TRAIN_LDM}), \
	$(if $(call  FILE_EXISTS, $l),, \
		$(error To train the LDM, you must provide $l)))

# Verify the presence of the HLDM's corpora files.
$(foreach l, $(addsuffix _${SRC_LANG}, ${TRAIN_HLDM}) $(addsuffix _${TGT_LANG}, ${TRAIN_HLDM}), \
	$(if $(call  FILE_EXISTS, $l),, \
		$(error To train the HLDM, you must provide $l)))

# Verify the presence of sparse's corpora files.
$(foreach l, $(addsuffix _${SRC_LANG}, ${TRAIN_SPARSE}) $(addsuffix _${TGT_LANG}, ${TRAIN_SPARSE}), \
	$(if $(call  FILE_EXISTS, $l),, \
		$(error To train sparse models, you must provide $l)))

# Verify the presence of the truecasing language model's corpus file.
$(foreach l, $(addsuffix _${TGT_LANG}, ${TRAIN_TC}), \
	$(if $(strip $(call  BASE_FILE_EXISTS, $l) $(wildcard $l${TCX}) $(wildcard $l${TCX}${GZ})),, \
		$(error For your truecasing language model, you must provide $l)))

# Verify the presence of the coarse LM corpora files.
$(foreach l, $(addsuffix _${TGT_LANG}, ${TRAIN_COARSELM}), \
	$(if $(call  FILE_EXISTS, $l),, \
		$(error For your coarse language models, you must provide $l)))

# Verify the presence of the (coarse) BiLM corpora files.
$(foreach l, $(addsuffix _${SRC_LANG}, ${TRAIN_BILM}) $(addsuffix _${TGT_LANG}, ${TRAIN_BILM}), \
	$(if $(call  FILE_EXISTS, $l),, \
		$(error For your (coarse) BiLMs, you must provide $l)))

# Verify the presence of the WCL corpora files.
$(foreach l, $(addsuffix _${SRC_LANG}, ${TRAIN_WCL}) $(addsuffix _${TGT_LANG}, ${TRAIN_WCL}), \
	$(if $(call  FILE_EXISTS, $l),, \
		$(error For training word classes, you must provide $l)))

# Verify the presence of decoder's tuning corpora files.
$(foreach l, $(addsuffix _${SRC_LANG}, ${TUNE_DECODE}) $(subst ${LANGX},,$(call CREATE_REFERENCE_NAMES, ${TUNE_DECODE})), \
	$(if $(call  FILE_EXISTS, $l),, \
		$(error In order to tune the decoder, you must provide $l)))

# Verify the presence of rescoring's tuning corpora files.
$(foreach l, $(addsuffix _${SRC_LANG}, ${TUNE_RESCORE}) $(subst ${LANGX},,$(call CREATE_REFERENCE_NAMES, ${TUNE_RESCORE})), \
	$(if $(call  FILE_EXISTS, $l),, \
		$(error In order to tune the rescoring module, you must provide $l)))

# Verify the presence of confidence estimation's tuning corpora files.
$(foreach l, $(addsuffix _${SRC_LANG}, ${TUNE_CE}) $(subst ${LANGX},,$(call CREATE_REFERENCE_NAMES, ${TUNE_CE})), \
	$(if $(call  FILE_EXISTS, $l),, \
		$(error In order to tune the confidence estimation module, you must provide $l)))

# Verify the presence of test set's corpora files.
$(foreach l, $(addsuffix _${SRC_LANG}, ${TEST_SET}) $(subst ${LANGX},,$(foreach t,${TEST_SET},$(call CREATE_REFERENCE_NAMES, $t))), \
	$(if $(call  FILE_EXISTS, $l),, \
		$(error In order to test the quality of your system, you must provide $l)))

# Verify the presence of translation set's corpora files.
$(foreach l, $(addsuffix _${SRC_LANG}, ${TRANSLATE_SET}), \
	$(if $(call  FILE_EXISTS, $l),, \
		$(error You must provide $l)))

ifdef DO_CE
# Verify the presence of the source language model's corpus file.
$(foreach l, $(addsuffix _${SRC_LANG}, ${TRAIN_LM}), \
	$(if $(call  FILE_EXISTS, $l),, \
		$(error For your language model, you must provide $l)))

endif

ifdef DO_TRUECASING
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
endif

endif	# MAKECMDGOALS check
endif
endif


################################################################################
# HELPERS

# Auto compress files.
%.gz:  %
	cat $< | gzip > $@


.PHONY: debug
debug: SHELL=${LOCAL_SHELL}
debug:
	@echo "EXPECTED_FILES: ${EXPECTED_FILES}"
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
	@echo "HELDOUT_SET: ${HELDOUT_SET}"



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
unittest1:  export DO_CE = 1
unittest1:  export TC_USE_SRC_MODELS = 1
unittest1:  export PRIMARY_LM =
unittest1:
	${MAKE} all
