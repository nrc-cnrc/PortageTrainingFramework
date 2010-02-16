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

# Big corpora should be gzipped and will be processed with parallelize.pl to speed-up thing.
# BIG_CORPORA defines the prefixes like train or lm-train for example.
BIG_CORPORA ?= $(sort ${TRAIN_SET})  # Using sort to remove duplicates.

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
ALIGN_CORPORA_DIR ?= ./


# Tells make where to find the raw corpora files.
vpath %${ALIGNX} ${ALIGN_CORPORA_DIR}


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

# Where SRC_LANG/TGT_LANG  ~ en/fr
# Where LANGX ~ .tok.al
# Where LANGXZ ~ .tok.al.gz
#.INTERMEDIATE: $(addsuffix _${SRC_LANG}${LANGX}, ${TRAIN_SET})
#.INTERMEDIATE: $(addsuffix _${TGT_LANG}${LANGX}, ${TRAIN_SET})



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

# Defines what corpora we need truecased/tokenized for the truecase model.
.PHONY: tc
TC = $(addsuffix _${TGT_LANG}.tc${GZ}, ${TRAIN_LM})
tc: ${TC}

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


## Tokenizes source corpora without sentence splitting.
#%_${SRC_LANG}${ALIGNX}: %_${SRC_LANG}${RAWX}
#	@${check_utf8}
#	RP_PSUB_OPTS="-1" \
#	utokenize.pl -noss -lang=${SRC_LANG} < $< > $@
#
## Tokenizes target corpora without sentence splitting.
#%_${TGT_LANG}${ALIGNX}: %_${TGT_LANG}${RAWX}
#	@${check_utf8}
#	RP_PSUB_OPTS="-1" \
#	utokenize.pl -noss -lang=${TGT_LANG} < $< > $@
#
## HOW to handle big source language corpora.
#$(addsuffix _${SRC_LANG}${ALIGNX}${GZ}, ${BIG_CORPORA}): %_${SRC_LANG}${ALIGNX}${GZ}: %_${SRC_LANG}${RAWX}${GZ}
#	RP_PSUB_OPTS="-1" \
#	parallelize.pl -psub -1 -n ${PARALLELISM_LEVEL_CORPORA} "utokenize.pl -noss -lang=${SRC_LANG} < $< > $@"
#
## HOW to handle big target language corpora.
#$(addsuffix _${TGT_LANG}${ALIGNX}${GZ}, ${BIG_CORPORA}): %_${TGT_LANG}${ALIGNX}${GZ}: %_${TGT_LANG}${RAWX}${GZ}
#	RP_PSUB_OPTS="-1" \
#	parallelize.pl -psub -1 -n ${PARALLELISM_LEVEL_CORPORA} "utokenize.pl -noss -lang=${TGT_LANG} < $< > $@"



# Prepare truecased file.
%.tc: %${ALIGNX}
	@${check_utf8}
	RP_PSUB_OPTS="-1" \
	cp $< $@

%.tc${GZ}: %${ALIGNX}${GZ}
	@${check_utf8}
	RP_PSUB_OPTS="-1" \
	cp $< $@


# Constructs a lowercased corpora from its aligned version.
%${LANGX}: %${ALIGNX}
	@$(check_utf8)
	RP_PSUB_OPTS="-1" \
	cat $< | ${LOWERCASE} > $@

%${LANGXZ}: %${ALIGNX}${GZ}
	@$(check_utf8)
	RP_PSUB_OPTS="-1" \
	zcat $< | ${LOWERCASE} | gzip > $@


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
	@echo "BIG_CORPORA: ${BIG_CORPORA}"
	@echo "LC: ${LC}"

