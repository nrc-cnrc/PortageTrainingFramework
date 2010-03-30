#!/usr/bin/make -f
# vim:noet:ts=3:nowrap
#
# $Id$
# @author Samuel Larkin
# @file Makefile
# @brief Trains language model files.
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

# Lastly include the master toolkit
include ../../Makefile.toolkit


# What is this module's name.
MODULE_NAME ?= lm

# Let's make this usage on the cluster.
SHELL = ${FRAMEWORK_SHELL}

# Defines the IRST environment variables.
# Where is IRSTLM located
export IRSTLM ?= $(PORTAGE)/pkgs/irstlm
# Where are IRSTLM's binaries located
BIN_DIR ?= ${IRSTLM}/bin

# What is the level of parallelism.
PARALLELISM_LEVEL_LM ?= 5

# What is the order of the required lm.
ORDER ?= 5

# Most steps require to load all the lm in memory, how many cpus should those jobs use.
CPUS ?= 2

# What is the lm language.
LM_LANG ?= ${TGT_LANG}

# What type of lms to build
LM_TYPES ?= binlm

# What is the corpus' name, extension and what file defines this corpus.
# This is the corpus' name and looks like train_fr
CORPUS_NAME ?= ${TRAIN_LM}_${LM_LANG}

# This indicates the corpus extension and looks like .tok.al.gz
CORPUS_EXT  ?= ${LANGXZ}

CORPUS_FILE ?= ${CORPUS_NAME}${CORPUS_EXT}

LM_DESC ?= -kn-${ORDER}g
LM_NAME ?= ${CORPUS_NAME}${LM_DESC}

# Where to find the corpus' file.
CORPORA_DIR ?= ../../corpora

# Allows to switch between a cluster distributed way of building the irstlm format.
ifdef USING_CLUSTER
BUILD_LM_PGM ?= build-lm-qsub.sh
else
BUILD_LM_PGM ?= build-lm.sh
endif

# This is to test the perplexity of the language models.
PPX_TEST_SET ?= test.txt

# After this Makefile, the following targets/files are precious.
FILES_TO_BE_LOCKED = ${LM_NAME}*

# Enable monitoring of memory usage.
MONITOR_MEMORY_USAGE ?=

# If you need to provide ngram-count some extra parameters.
EXTRA_NGRAM_COUNT_OPTIONS ?=

# Resource monitoring.
TIME_MEM ?= time-mem


# Tells make where to find the corpus' file and the marked file if need be.
vpath %${CORPUS_EXT} ${CORPORA_DIR}
vpath %.marked.gz    ${CORPORA_DIR}



.DEFAULT_GOAL := help
.DELETE_ON_ERROR:



########################################
.PHONY: help
help: SHELL=${GUARD_SHELL}
help:
	@echo "please run:"
	@echo "export PATH=${BIN_DIR}:$$PATH"
	@echo "export IRSTLM=${IRSTLM}"
	@echo "Then make all"
	@cat $(firstword $(MAKEFILE_LIST)) | egrep '^.PHONY:' | sed 's#^.PHONY: ##'
	@echo "Define LM_TOOLKIT=SRI or LM_TOOLKIT=MIT or LM_TOOLKIT=IRST to specify the LM toolkit you want to use."
	@echo "Note: you can build some other lm by defining TRAIN_LM=<corpora_prefix>."



########################################
.PHONY: all
all: ${LM_TYPES}



########################################
# What the user can expect from this module.
.PHONY: list_final_output
list_final_output: SHELL=${GUARD_SHELL}
list_final_output:
	@echo "Expected final output(s):"
	@echo "${LM_NAME}.binlm.gz"



########################################
# resources summary
.PHONY: summary
summary: resource_summary_sub



########################################
# CLEANING.
.PHONY: clean
clean: SHELL=${GUARD_SHELL}

.PHONY: clean.content
clean: clean.content
clean.content: SHELL=${GUARD_SHELL}



# How to clean the language models.
clean: clean.logs

# Sometimes we only want to get ride of the logs.
.PHONY: clean.logs
clean.logs: SHELL=${GUARD_SHELL}
clean.logs:
	${RM} log.*
	${RM} run-parallel-logs-*
	${RM} -r .logs



########################################
# Transform model for PortageLive
.PHONY: portageLive
portageLive: tplm



########################################
# Adds sentence start and end markers
.PHONY: mark
mark: ${CORPUS_NAME}.marked.gz

#.SECONDARY: ${CORPUS_NAME}.marked.gz
%.marked.gz: %${CORPUS_EXT}
	@_LOCAL=1 echo "Marking $<"
	RP_PSUB_OPTS="-N $@" \
	set -o pipefail; zcat -f $< \
	| add-start-end.sh \
	| gzip -c \
	> $@

clean.content: clean.mark

.PHONY: clean.mark
clean.mark: SHELL=${GUARD_SHELL}
clean.mark:
	${RM} *.marked.gz



########################################
# iARPA
# Compressed irstlm format
.PHONY: irstlm
irstlm: ${LM_NAME}.ilm.gz

# Here we've added LM_DESC to strip it out from the marked corpus file name.
#.SECONDARY: ${LM_NAME}.ilm.gz
%${LM_DESC}.ilm.gz: %.marked.gz
	@_LOCAL=1 echo "  Creating IRSTLM $@"
	_LOCAL=1 ${RM} $@
	RP_PSUB_OPTS="-${CPUS} -N $@" \
	IRSTLM=${IRSTLM} ${BUILD_LM_PGM} \
		-p \
		-t stat.$$$$ \
		-n ${ORDER} \
		-k ${PARALLELISM_LEVEL_LM} \
		-s kneser-ney \
		-i "gunzip -c $<" \
		-o $@ \
	&> log.$(basename $@)

clean.content: clean.irstlm

.PHONY: clean.irstlm
clean.irstlm: SHELL=${GUARD_SHELL}
clean.irstlm:
	${RM} *.ilm.gz
	${RM} -r stat*



########################################
# arpa text compressed format
.PHONY: arpa
arpa: ${LM_NAME}.lm.gz

# Here we've added LM_DESC to strip it out from the corpus file name.
#.SECONDARY: ${LM_NAME}.lm.gz
ifeq (${LM_TOOLKIT}, SRI)
#	test -n "${MONITOR_MEMORY_USAGE}" && process-memory-usage.pl -s 3 30 $$PPID >& monitor.$(basename $@) & \
#
%${LM_DESC}.lm.gz: %${CORPUS_EXT}
	@_LOCAL=1 echo "  Creating ARPA text format $@"
	RP_PSUB_OPTS="-${CPUS} -N $@" \
	${TIME_MEM} \
	ngram-count \
		-interpolate \
		-kndiscount \
		-order ${ORDER} \
		-text $< \
		-lm $@ \
		${EXTRA_NGRAM_COUNT_OPTIONS} \
	>& log.$(basename $@)

else ifeq (${LM_TOOLKIT}, IRST)
%.lm.gz: %.ilm.gz
	@_LOCAL=1 echo "  Creating ARPA text format $@"
	RP_PSUB_OPTS="-${CPUS} -N $@" \
	set -o pipefail; \
	${TIME_MEM} \
	compile-lm \
		--text yes \
		$< \
		/dev/stdout \
	2> log.$(basename $@) \
	| egrep -v '^Saving in txt format to' \
	| lm_sort.pl \
	| gzip > $@

#	test -n "${MONITOR_MEMORY_USAGE}" && process-memory-usage.pl -s 3 30 $$PPID >& monitor.$(basename $@) & \
#
else ifeq (${LM_TOOLKIT}, MIT)
%${LM_DESC}.lm.gz: %${CORPUS_EXT}
	@_LOCAL=1 echo "  Creating ARPA text format $@"
	RP_PSUB_OPTS="-${CPUS} -N $@" \
	zcat $< \
	| ${TIME_MEM} \
	estimate-ngram \
		-order ${ORDER} \
		-smoothing ModKN \
		-text /dev/stdin \
		-write-lm $@ \
	2> log.$(basename $@)

else
	$(error "Invalid value for LM_TOOLKIT: ${LM_TOOLKIT}")
endif

clean.content: clean.arpa

.PHONY: clean.arpa
clean.arpa: SHELL=${GUARD_SHELL}
clean.arpa:
	${RM} *.lm.gz



########################################
# BINAIRY FORMAT
# arpa bin compressed format
.PHONY: blmt
blmt: ${LM_NAME}.blmt

#.SECONDARY: ${LM_NAME}.blmt
%.blmt: %.ilm.gz
	@_LOCAL=1 echo "  Creating bin.ARPA format $@"
	RP_PSUB_OPTS="-${CPUS} -N $@" \
	${TIME_MEM} \
	compile-lm \
		$< \
		$@ \
	&> log.$@

clean.content: clean.blmt

.PHONY: clean.blmt
clean.blmt: SHELL=${GUARD_SHELL}
clean.blmt:
	${RM} *.blmt



########################################
# qARPA format
.PHONY: quantize
quantize: $(LM_NAME).qlm.gz

#.SECONDARY: ${LM_NAME}.qlm.gz
%.qlm: %.lm.gz
	@_LOCAL=1 echo "  qARPA $< to $@"
	RP_PSUB_OPTS="-${CPUS} -N $@" \
	${TIME_MEM} \
	quantize-lm \
		$< \
		$@ \
	&> log.$@

clean.content: clean.quantize

.PHONY: clean.quantize
clean.quantize: SHELL=${GUARD_SHELL}
clean.quantize:
	${RM} *.qlm.gz



########################################
# Quantinze binairy
.PHONY: Qblmt
Qblmt: ${LM_NAME}.Qblmt

#.SECONDARY: ${LM_NAME}.Qblmt
%.Qblmt: %.qlm.gz
	@_LOCAL=1 echo "  bin.qARPA $< to $@"
	RP_PSUB_OPTS="-${CPUS} -N $@" \
	${TIME_MEM} \
	compile-lm \
		$< \
		$@ \
	&> log.$@

clean.content: clean.Qblmt

.PHONY: clean.Qblmt
clean.Qblmt: SHELL=${GUARD_SHELL}
clean.Qblmt:
	${RM} *.Qblmt



########################################
# Sort the arpa format
.PHONY: sort_arpa
sort_arpa: ${LM_NAME}.lm.sorted.gz

#.SECONDARY: ${LM_NAME}.lm.sorted.gz
%.lm.sorted.gz: %.lm.gz
	${TIME_MEM} \
	lm_sort_filter.sh -lm $< $@ >& log.$(basename $@)

clean.content: clean.sort_arpa

.PHONY: clean.sort_arpa
clean.sort_arpa: SHELL=${GUARD_SHELL}
clean.sort_arpa:
	${RM} *.lm.sorted.gz



########################################
# Portage's bin lm format
.PHONY: binlm
binlm: ${LM_NAME}.binlm.gz

#.SECONDARY: %.binlm.gz
#	test -n "${MONITOR_MEMORY_USAGE}" && process-memory-usage.pl -s 3 30 $$PPID >& monitor.$(basename $@) & \
#
%.binlm.gz: %.lm.gz
	RP_PSUB_OPTS="-${CPUS} -N $@" \
	${TIME_MEM} \
	arpalm2binlm $< $@ >& log.$(basename $@)

clean.content: clean.binlm

.PHONY: clean.binlm
clean.binlm: SHELL=${GUARD_SHELL}
clean.binlm:
	${RM} *.binlm.gz



########################################
# Pruning ARPA format => ARPA format
.PHONY: prune
prune: ${LM_NAME}.plm.gz

#.SECONDARY: %.plm.gz
%.plm.gz: %.lm.gz
	RP_PSUB_OPTS="-${CPUS} -N $@" \
	prune-lm --threshold=1e-6 $< /dev/stdout \
	| gzip \
	> $@



########################################
# Create Tightly Packed Language Model.
.PHONY: tplm
tplm: ${LM_NAME}.tplm

%.tplm: %.lm.gz
	${TIME_MEM} \
	arpalm2tplm.sh $< $* 2> log.$@

clean.content: clean.tplm

.PHONY: clean.tplm
clean.tplm: SHELL=${GUARD_SHELL}
clean.tplm:
	${RM} -r *.tplm



################################################################################
# HELPERS
########################################
# All valid/possible LMs
.PHONY: all_lm
all_lm: arpa
all_lm: blmt
all_lm: quantize
all_lm: Qblmt
all_lm: binlm



########################################
# Check if the environment is set
.PHONY: test
test: SHELL=${GUARD_SHELL}
test:
	env | grep IRSTLM



########################################
# For debugging purpose
.PHONY: check_setup
check_setup: SHELL=${GUARD_SHELL}
check_setup:
ifeq (${LM_TOOLKIT}, SRI)
	which ngram-count
else ifeq (${LM_TOOLKIT}, MIT)
	which estimate-ngram
else ifeq (${LM_TOOLKIT}, IRST)
	test -n $$IRSTLM
	which build-lm.sh
else
	$(error "Invalid type for LM_TOOLKIT: ${LM_TOOLKIT}")
endif


################################################################################
# The following targets are unmaintained and were used for initial testing of
# irstlm.
########################################
# PERPLEXITY
.PHONY: ppx
ppx: ppx.${LM_NAME}
ppx.${LM_NAME}: ${LM_NAME}.binlm.gz ${PPX_TEST_SET}
	lm_eval -v -limit $+

.PHONY: ppx.irstlm
ppx.irstlm: $(addprefix ppx.irstlm.${LM_NAME}, .lm.gz .blmt .qlm.gz .Qblmt)
ppx.irstlm.%: ${PPX_TEST_SET} %
	compile-lm $* --eval=$< >& $(basename $@)
