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

# Defines the IRST environment variables.
# Where is IRSTLM located
IRSTLM ?= $(PORTAGE)/pkgs/irstlm
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

# What are the corpora names and extension and what files define these corpora.
CORPORA_NAMES ?= $(addsuffix _${LM_LANG}, ${TRAIN_LM})

# This indicates the corpus extension and looks like .tok.al.gz
CORPUS_EXT  ?= ${LANGXZ}

LM_DESC ?= -kn-${ORDER}g
LM_NAMES ?= $(addsuffix ${LM_DESC}, ${CORPORA_NAMES})

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
FILES_TO_BE_LOCKED = $(addsuffix *, ${LM_NAMES})

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
help: SHELL=${LOCAL_SHELL}
help:
ifeq (${LM_TOOLKIT},IRST)
	@echo "Please run the following in order for this framework to run properly:"
	@echo "   export PATH=${BIN_DIR}:\$$PATH"
	@echo "   export IRSTLM=${IRSTLM}"
	@echo
endif
	@echo "In Makefile.params, define LM_TOOLKIT=SRI, LM_TOOLKIT=MIT" \
	      "or LM_TOOLKIT=IRST to specify the LM toolkit to use."
	@echo
	@echo "To train your language models, type: make all"
	@echo
	@echo "The main targets in this Makefile are:"
	@cat $(firstword $(MAKEFILE_LIST)) | egrep '^.PHONY:' | sed 's#^.PHONY: #   #'
	@echo
	@echo "Note: you can build some other lm by defining TRAIN_LM=<corpora_prefix>."



########################################
.PHONY: all
all: SHELL=${LOCAL_SHELL}
all: ${LM_TYPES} pretrained.${LM_LANG}



########################################
# What the user can expect from this module.
.PHONY: list_final_output
list_final_output: SHELL=${LOCAL_SHELL}
list_final_output:
	@echo "Expected final output(s):"
	@echo "$(addsuffix .binlm.gz, ${LM_NAMES})"



########################################
# Clean up
.PHONY: clean clean.content clean.logs hide.logs
clean: SHELL=${LOCAL_SHELL}
clean: clean.content clean.logs

clean.content: SHELL=${LOCAL_SHELL}

clean.logs: SHELL=${LOCAL_SHELL}
clean.logs:
	${RM} log.*
	${RM} run-parallel-logs-*
	${RM} -r .logs

# Hide logs from user's view into .logs
hide.logs: SHELL=${LOCAL_SHELL}
hide.logs: hide_logs_sub



########################################
# Resources Summary
.PHONY: time-mem
time-mem: SHELL=${LOCAL_SHELL}
time-mem: resource_summary_sub



########################################
# Transform model for PortageLive
PORTAGE_LIVE_DEST_DIR ?= ../portageLive/models/lm
.PHONY: portageLive
portageLive: SHELL=${LOCAL_SHELL}
ifneq ($(strip ${TRAIN_LM} $(notdir ${LM_PRETRAINED_TGT_LMS})),)
portageLive: $(addsuffix .tplm, ${LM_NAMES}) $(notdir ${LM_PRETRAINED_TGT_LMS:.binlm${GZ}=.tplm})
	mkdir -p ${PORTAGE_LIVE_DEST_DIR}
	${RM} -r ${PORTAGE_LIVE_DEST_DIR}/*
	cd ${PORTAGE_LIVE_DEST_DIR} && ln -fs $(addprefix ../../../lm/, $+) .
else
portageLive:
	@echo "No regular LMs defined, nothing to do." >&2
endif



########################################
# Create symbolic links to pre-trained models

LM_PRETRAINED_SRC_LMS ?= $(subst _${TGT_LANG},_${SRC_LANG}, ${LM_PRETRAINED_TGT_LMS})
LM_PRETRAINED_LMS ?= ${LM_PRETRAINED_SRC_LMS} ${LM_PRETRAINED_TGT_LMS}

ifneq ($(filter ${LM_PRETRAINED_TGT_LMS}, ${LM_PRETRAINED_SRC_LMS}),)
$(error Target language specification _${TGT_LANG} missing in pre-trained LM file name(s): \
        $(filter ${LM_PRETRAINED_TGT_LMS}, ${LM_PRETRAINED_SRC_LMS}))
endif

.PHONY: pretrained.${SRC_LANG} pretrained.${TGT_LANG}
.PHONY: $(addprefix pretrained., $(notdir ${LM_PRETRAINED_LMS}))
pretrained.${SRC_LANG}: $(addprefix pretrained., $(notdir ${LM_PRETRAINED_SRC_LMS}))
pretrained.${TGT_LANG}: $(addprefix pretrained., $(notdir ${LM_PRETRAINED_TGT_LMS}))

fix_path = $(strip $(if $(filter /, $(firstword $(subst /,/ ,$(1)))), $(1), $(addprefix ../../, $(1))))

pretrained_lm_paths = $(foreach f, ${LM_PRETRAINED_LMS}, $(call fix_path, $f))

$(foreach f, ${pretrained_lm_paths}, \
	$(eval \
		pretrained.$(notdir $f):  $f) \
)

$(addprefix pretrained., $(notdir ${pretrained_lm_paths})): SHELL=${LOCAL_SHELL}
$(addprefix pretrained., $(notdir ${pretrained_lm_paths})): pretrained.%: 
	@[[ ! -e $* ]] || [[ -L $* ]] || ! echo "ERROR: LM $* already exists as a normal file."
	@$(if $(filter-out %.binlm.gz, $*),! echo "ERROR: Name of pre-trained LM file must end with .binlm.gz: $<")
	ln -sf $< .
	[[ ! -d ${<:.binlm.gz=.tplm} ]] || ln -sf ${<:.binlm.gz=.tplm} .

${pretrained_lm_paths}: SHELL=${LOCAL_SHELL}
${pretrained_lm_paths}: %:
	@! echo "ERROR: Pre-trained LM file $@ does not exist."

########################################
# Adds sentence start and end markers
.PHONY: mark
mark: SHELL=${LOCAL_SHELL}
mark: $(addsuffix .marked.gz, ${CORPORA_NAMES})

#.SECONDARY: $(addsuffix .marked.gz, ${CORPORA_NAMES}
%.marked.gz: SHELL=${FRAMEWORK_SHELL}
%.marked.gz: %${CORPUS_EXT}
	@_LOCAL=1 echo "Marking up $<"
	RP_PSUB_OPTS="-N $@" \
	set -o pipefail; \
	zcat -f $< \
	| add-start-end.sh \
	| gzip -c \
	> $@

clean.content: clean.mark

.PHONY: clean.mark
clean.mark: SHELL=${LOCAL_SHELL}
clean.mark:
	${RM} *.marked.gz



########################################
# iARPA
# Compressed irstlm format
.PHONY: irstlm
irstlm: SHELL=${LOCAL_SHELL}
irstlm: $(addsuffix .ilm.gz, ${LM_NAMES})

# Here we've added LM_DESC to strip it out from the marked corpus file name.
#.SECONDARY: $(addsuffix .ilm.gz, ${LM_NAMES})
%${LM_DESC}.ilm.gz: SHELL=${FRAMEWORK_SHELL}
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
clean.irstlm: SHELL=${LOCAL_SHELL}
clean.irstlm:
	${RM} *.ilm.gz
	${RM} -r stat*



########################################
# arpa text compressed format
.PHONY: arpa
arpa: SHELL=${LOCAL_SHELL}
arpa: $(addsuffix .lm.gz, ${LM_NAMES})

# Here we've added LM_DESC to strip it out from the corpus file name.
#.SECONDARY: $(addsuffix .lm.gz, ${LM_NAMES})
ifeq (${LM_TOOLKIT}, SRI)
%${LM_DESC}.lm.gz: SHELL=${FRAMEWORK_SHELL}
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
%.lm.gz: SHELL=${FRAMEWORK_SHELL}
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

else ifeq (${LM_TOOLKIT}, MIT)
FILTER = perl -ne 'BEGIN{$$M=4095} $$l=$$_; while(length($$l)>$$M and $$i=rindex($$l, " ", $$M) and $$i!= -1) { print substr($$l, 0, $$i), "\n"; $$l = substr($$l, $$i+1); } print $$l;'
# Note that MITLM is finicky about spaces thus we need to collapse several
# spaces into one space and remove any leading or traling spaces.
# The perl regex was proposed by the creators of MITLM.
%${LM_DESC}.lm.gz: SHELL=${FRAMEWORK_SHELL}
%${LM_DESC}.lm.gz: %${CORPUS_EXT}
	@_LOCAL=1 echo "  Creating ARPA text format $@"
	RP_PSUB_OPTS="-${CPUS} -N $@" \
	set -o pipefail; \
	zcat $< \
	| perl -ple 's/^\s*(.*?)\s*$$/$$1/; s/\s+/ /g;' \
	| ${FILTER} \
	| ${TIME_MEM} \
	estimate-ngram \
		-order ${ORDER} \
		-smoothing ModKN \
		-text /dev/stdin \
		-write-lm $@ \
		$(and ${KEEP_COUNTS}, -write-counts ${@:.lm.gz=.counts.gz}) \
	>& log.$(basename $@)

NRC_PRUNING := 1 1 2 3 4
PRUNING = ${NRC_PRUNING}
%.filt.lm.gz:  SHELL=${FRAMEWORK_SHELL}
%.filt.lm.gz:  override KEEP_COUNTS=1
%.filt.lm.gz:  %.lm.gz
	RP_PSUB_OPTS="-1" \
	set -o pipefail; \
	${TIME_MEM} \
	lm-filter.py $< ${<:.lm.gz=.counts.gz} ${PRUNING} \
	2> log.$(@:.gz=) \
	| gzip > $@
else
$(error Invalid value for LM_TOOLKIT: ${LM_TOOLKIT})
endif

clean.content: clean.arpa

.PHONY: clean.arpa
clean.arpa: SHELL=${LOCAL_SHELL}
clean.arpa:
	${RM} *.lm.gz



########################################
# BINARY FORMAT
# arpa bin compressed format
.PHONY: blmt
blmt: SHELL=${LOCAL_SHELL}
blmt: $(addsuffix .blmt, ${LM_NAMES})

#.SECONDARY: $(addsuffix .blmt, ${LM_NAMES})
%.blmt: SHELL=${FRAMEWORK_SHELL}
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
clean.blmt: SHELL=${LOCAL_SHELL}
clean.blmt:
	${RM} *.blmt



########################################
# qARPA format
.PHONY: quantize
quantize: SHELL=${LOCAL_SHELL}
quantize: $(addsuffix .qlm.gz, ${LM_NAMES})

#.SECONDARY: $(addsuffix .qlm.gz, ${LM_NAMES})
%.qlm: SHELL=${FRAMEWORK_SHELL}
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
clean.quantize: SHELL=${LOCAL_SHELL}
clean.quantize:
	${RM} *.qlm.gz



########################################
# Quantize binary
.PHONY: Qblmt
Qblmt: SHELL=${LOCAL_SHELL}
Qblmt: $(addsuffix .Qblmt, ${LM_NAMES})

#.SECONDARY: $(addsuffix .Qblmt, ${LM_NAMES})
%.Qblmt: SHELL=${FRAMEWORK_SHELL}
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
clean.Qblmt: SHELL=${LOCAL_SHELL}
clean.Qblmt:
	${RM} *.Qblmt



########################################
# Sort the arpa format
.PHONY: sort_arpa
sort_arpa: SHELL=${LOCAL_SHELL}
sort_arpa: $(addsuffix .lm.sorted.gz, ${LM_NAMES})

#.SECONDARY: $(addsuffix .lm.sorted.gz, ${LM_NAMES})
%.lm.sorted.gz: SHELL=${FRAMEWORK_SHELL}
%.lm.sorted.gz: %.lm.gz
	${TIME_MEM} \
	lm_sort_filter.sh -lm $< $@ >& log.$(basename $@)

clean.content: clean.sort_arpa

.PHONY: clean.sort_arpa
clean.sort_arpa: SHELL=${LOCAL_SHELL}
clean.sort_arpa:
	${RM} *.lm.sorted.gz



########################################
# Portage's bin lm format
.PHONY: binlm
binlm: SHELL=${LOCAL_SHELL}
binlm: $(addsuffix .binlm.gz, ${LM_NAMES})

#.SECONDARY: $(addsuffix .binlm.gz, ${LM_NAMES})
%.binlm.gz: SHELL=${FRAMEWORK_SHELL}
%.binlm.gz: %.lm.gz
	RP_PSUB_OPTS="-${CPUS} -N $@" \
	${TIME_MEM} \
	arpalm2binlm $< $@ >& log.$(basename $@)

clean.content: clean.binlm

.PHONY: clean.binlm
clean.binlm: SHELL=${LOCAL_SHELL}
clean.binlm:
	${RM} *.binlm.gz



########################################
# Pruning ARPA format => ARPA format
.PHONY: prune
prune: SHELL=${LOCAL_SHELL}
prune: $(addsuffix .plm.gz, ${LM_NAMES})

#.SECONDARY: $(addsuffix .plm.gz, ${LM_NAMES})
%.plm.gz: SHELL=${FRAMEWORK_SHELL}
%.plm.gz: %.lm.gz
	RP_PSUB_OPTS="-${CPUS} -N $@" \
	prune-lm --threshold=1e-6 $< /dev/stdout \
	| gzip \
	> $@



########################################
# Create Tightly Packed Language Model.
.PHONY: tplm
tplm: SHELL=${LOCAL_SHELL}
tplm: $(addsuffix .tplm, ${LM_NAMES})

%.tplm: SHELL=${FRAMEWORK_SHELL}
%.tplm: %.lm.gz
	RP_PSUB_OPTS="-${CPUS} -N $@" \
	${TIME_MEM} \
	arpalm2tplm.sh $< $* 2> log.$@

clean.content: clean.tplm

.PHONY: clean.tplm
clean.tplm: SHELL=${LOCAL_SHELL}
clean.tplm:
	${RM} -r *.tplm



################################################################################
# HELPERS
########################################
# All valid/possible LMs
.PHONY: all_lm
all_lm: SHELL=${LOCAL_SHELL}
all_lm: arpa
all_lm: blmt
all_lm: quantize
all_lm: Qblmt
all_lm: binlm



########################################
# Check if the environment is set
.PHONY: test
test: SHELL=${LOCAL_SHELL}
test:
	env | grep IRSTLM



########################################
# For debugging purpose
.PHONY: check_setup
check_setup: SHELL=${LOCAL_SHELL}
check_setup:
ifeq (${LM_TOOLKIT}, SRI)
	which ngram-count
else ifeq (${LM_TOOLKIT}, MIT)
	which estimate-ngram
else ifeq (${LM_TOOLKIT}, IRST)
	test -n $$IRSTLM
	which build-lm.sh
else
	$(error Invalid type for LM_TOOLKIT: ${LM_TOOLKIT})
endif


################################################################################
# The following targets are unmaintained and were used for initial testing of
# irstlm.
########################################
# PERPLEXITY
.PHONY: ppx
ppx: SHELL=${LOCAL_SHELL}
ppx: $(addprefix ppx., ${LM_NAMES})
ppx.%: SHELL=${FRAMEWORK_SHELL}
ppx.%: %.binlm.gz ${PPX_TEST_SET}
	lm_eval -v -limit $+

.PHONY: ppx.irstlm
ppx.irstlm: SHELL=${LOCAL_SHELL}
ppx.irstlm: $(foreach lm_name, ${LM_NAMES}, $(addprefix ppx.irstlm.${lm_name}, .lm.gz .blmt .qlm.gz .Qblmt))
ppx.irstlm.%: SHELL=${FRAMEWORK_SHELL}
ppx.irstlm.%: ${PPX_TEST_SET} %
	compile-lm $* --eval=$< >& $(basename $@)

