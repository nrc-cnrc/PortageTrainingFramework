#!/usr/bin/make -f
# vim:noet:ts=3
#
# @author Samuel Larkin
# @file Makefile
# @brief Translates, rescores, truecases and detokenizes documents.
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

# What is this module's name.
MODULE_NAME ?= translate

# TODO: Make this Makefile work with run-parallel.sh -c
export SHELL = ${FRAMEWORK_SHELL}

# Define languages info.
#SRC_LANG ?= en
#TGT_LANG ?= fr
SRCX  ?= _${SRC_LANG}${LANGX}
TGTX  ?= _${TGT_LANG}${LANGX}
RULEX ?= _${SRC_LANG}.rule

# Define any value to the following variable if you are doing rescoring.
# If you are rescoring, there are some step that can be skipped to save cpu
# power :D.
#DO_RESCORING = 1

# What program to use to detokenize.
DETOKENIZER ?= udetokenize.pl

# This is used to create a symbolic link.
MODEL_DIR ?= ../models

# Indicates where to find the canoe.ini template.
DECODING_MODEL_DIR      ?= models/decode
DECODING_MODEL          ?= canoe.ini.cow
DECODING_MODEL_TEMPLATE ?= ${DECODING_MODEL_DIR}/${DECODING_MODEL}

# Indidcates where to find the rescoring model.
RESCORING_MODEL_DIR ?= models/rescore
RESCORING_MODEL     ?= rescore-model

# Indicates where to find the IBM models.
IBM_DIR ?= models/TM

# Will indicate to make where to find the SETs (dev & test & eval)
CORPORA_DIR ?= ../corpora

# Where to find the truecasing models.
TRUECASING_DIR ?= models/tc

# Indicates what are the test/eval set to be translated after having trained a decoder model and a rescoring model
TEST_SET ?= test1 test2

# Specific PSUB options
PSUB_OPTS ?= 

# Indicates the nbest list size.
NBEST_SIZE ?= 1000

# Number of parallel chunks to process.
PARALLELISM_LEVEL_TRANSLATE ?= 5

# Some ad-hoc post procssing.
POST_PROCESSING ?= cat

# How many cpus to use when translating.
TRANS_CPUS ?= 1


.SECONDARY:
.SUFFIXES:
.DELETE_ON_ERROR:

# Tells make where to find files that we've made in previous scripts/modules.
vpath %${SRCX}  ${CORPORA_DIR}
vpath %${TGTX}  ${CORPORA_DIR}
vpath %${RULEX} ${CORPORA_DIR}

vpath ${DECODING_MODEL}  ${DECODING_MODEL_DIR}  models/decode
vpath ${RESCORING_MODEL} ${RESCORING_MODEL_DIR} models/rescore
vpath ${TRUECASING_LM}   ${TRUECASING_DIR}
vpath ${TRUECASING_MAP}  ${TRUECASING_DIR}



.PHONY: all
all: final_result
	@echo "Your translations are available in translation/" >&2



########################################
# Depending on the user's input,
# - should do or not do truecasing;
# - should do or not rescoring.
ifdef DO_RESCORING
ifdef DO_TRUECASING
FINALX = .rat.tc.detok
else
FINALX = .rat.detok
endif
else
ifdef DO_TRUECASING
FINALX = .out.tc.detok
else
FINALX = .out.detok
endif
endif

# The final translation depends if we are doing rescoring and/or truecasing.
.PHONY: final_result
final_result: SHELL=${GUARD_SHELL}

final_result: $(addsuffix .translation,${TEST_SET})
ifdef TRANSLATE_SET
final_result: $(addsuffix .translation,${TRANSLATE_SET})
endif
%.translation: %${FINALX}
	${POST_PROCESSING} < $< > $@



# What the user can expect from this module.
.PHONY: list_final_output
list_final_output: SHELL=${GUARD_SHELL}
list_final_output:
	@echo "Expected final output(s):"
	@echo "$(addsuffix .translation,${TEST_SET})"



########################################
# What is require to setup this module.
.PHONY: setup
setup: models


# An alias that indicate what/how to translate the translation set without
# rescoring.
.PHONY: translate
translate: out

# An alias to translate and rescore the translation set.
.PHONY: rescore
rescore: rat



# This is where we would document this module's help.
.PHONY: help
help: SHELL=${GUARD_SHELL}
help:
	@echo "Translate the following testsets: $(addsuffix _${SRC_LANG}, ${TEST_SET})"
	@echo "Possible targets are:"
	@cat $(firstword $(MAKEFILE_LIST)) | egrep '^.PHONY:' | sed 's#^.PHONY: ##'
	@echo "Most likely you want to do either: make all or make translate."



########################################
# Clean up
.PHONY: clean
clean: SHELL=${GUARD_SHELL}

.PHONY: clean.content
clean: clean.content
clean.content: SHELL=${GUARD_SHELL}



########################################
# resources summary
.PHONY: summary
summary: resource_summary_sub



########################################
# Hide logs.
.PHONY: hide
hide: SHELL=${GUARD_SHELL}
hide:
	mkdir -p .logs
	mv log.* run-parallel-logs-* .logs



########################################
# Clean the log files.
clean: clean.logs

.PHONY: clean.logs
clean.logs: SHELL=${GUARD_SHELL}
clean.logs:
	${RM} log.* run-parallel-logs*



########################################
# If there is no decoding model available, warn the user since we do not know
# how to make the decoding model in this module.
${DECODING_MODEL}::
	@echo "Unable to make $@ please run make in models/decode." >&2
	false



check_decoding_model: SHELL=${GUARD_SHELL}
check_decoding_model: models
	@if [[ ! -e ${DECODING_MODEL_DIR}/${DECODING_MODEL} ]]; then \
		echo "ERROR: Please train ${DECODING_MODEL_DIR} first!" >&2; \
		false; \
	fi

#@_LOCAL=1 [[ -e ${DECODING_MODEL_DIR}/${DECODING_MODEL} ]] || (echo "Please train ${DECODING_MODEL_DIR} first!" >&2; false)

########################################
# Create a specific canoe.ini per test set.
# You could add some specific target if you need to customize a canoe.ini.cow
# for a particular file.
$(addprefix ${DECODING_MODEL},${TEST_SET}): SHELL=${GUARD_SHELL}
${DECODING_MODEL}.%: check_decoding_model models
	_LOCAL=1 cat ${DECODING_MODEL_DIR}/${DECODING_MODEL} > $@
	_LOCAL=1 configtool check $@
# example: increase the beam threshold and stack size.
#	cat $< \
#	| perl -pe 's/\[stack\].*/[stack] 600/go; s/\[beam-threshold\].*/[beam-threshold] 0.00001/go;' \
#	| sed "s/dev-text1/$*/" \
#	> $@

clean.content: clean.decoding.models

.PHONY: clean.decoding.models
clean.decoding.models: SHELL=${GUARD_SHELL}
clean.decoding.models: $(foreach f, ${TEST_SET}, clean.decoding.models.$f)
clean.decoding.models.%:
	-${RM} ${DECODING_MODEL}.$*



########################################
# Translate translate_set without rescoring.
.PHONY: out
out: $(addsuffix .out, ${TEST_SET})
ifdef DO_RESCORING
# if we are doing rescoring, we can save us some work by going straight to
# rescoring and extracting the 1 best instead of calculating it twice.
$(addsuffix .out, ${TEST_SET}): SHELL=${GUARD_SHELL}
%.out: %.rat
	cp workdir-$*${RULEX}-${NBEST_SIZE}best/1best $@
else
$(addsuffix .out, ${TEST_SET}): SHELL=${FRAMEWORK_SHELL}
%.out: ${DECODING_MODEL}.% %${RULEX}
	@_LOCAL=1 echo "Generating $@"
	RP_PSUB_OPTS="-${TRANS_CPUS}" \
	canoe-parallel.sh \
		-lb \
		-n ${PARALLELISM_LEVEL_TRANSLATE} \
		canoe \
		-f $< \
		< $(word 2, $^) \
		> $@ \
		2> log.$@
endif

OUT_BLEU_DEP = $(addsuffix .out.bleu, ${TEST_SET})
.PHONY: out.bleu
out.bleu: SHELL=${GUARD_SHELL}
out.bleu: ${OUT_BLEU_DEP}
	egrep Human $+

$(addsuffix .out.bleu, ${TEST_SET}): SHELL=${GUARD_SHELL}
%.out.bleu: %.out %${TGTX}
	@echo "Calculating BLEU for $@"
	bleumain $^ > $@

.PHONY: out.detok
out.detok: $(addsuffix .out.detok, ${TEST_SET})
$(addsuffix .out.detok, ${TEST_SET}): SHELL=${GUARD_SHELL}

# Invalid, can't compare the detokenized translation with a tokenized and
# lowercase reference.
#.PHONY: out.detok.bleu
#out.detok.bleu: $(addsuffix .out.detok.bleu, ${TEST_SET})
#$(addsuffix .out.detok.bleu, ${TEST_SET}): SHELL=${GUARD_SHELL}
#%.out.detok.bleu: %.out.detok %${TGTX}
#	@echo "Calculating BLEU for $@"
#	cat $(word 2, $+) \
#	| utf8_casemap -c l \
#	| bleumain $< - > $@

clean.content: clean.translate

.PHONY: clean.translate
clean.translate: SHELL=${GUARD_SHELL}
clean.translate: $(foreach f, ${TEST_SET}, clean.translate.$f)
clean.translate.%:
	${RM} $*.out $*.out.bleu
	${RM} $*.out.detok $*.out.detok.bleu



check_rescoring_model: SHELL=${GUARD_SHELL}
check_rescoring_model:
	@if [[ ! -e ${RESCORING_MODEL_DIR}/${RESCORING_MODEL} ]]; then \
		echo "ERROR: No rescoring model available!" >&2; \
		echo "Please train ${RESCORING_MODEL_DIR} first!" >&2; \
		false; \
	fi

#@_LOCAL=1 [[ -e ${RESCORING_MODEL_DIR}/${RESCORING_MODEL} ]] || (echo "ERROR: No rescoring model available!" >&2; echo "Please train ${RESCORING_MODEL_DIR} first!" >&2; false)

########################################
# Rescore the translate_set
.PHONY: rat
rat: $(addsuffix .rat, ${TEST_SET})
$(addsuffix .rat, ${TEST_SET}): SHELL=${FRAMEWORK_SHELL}
%.rat: ${DECODING_MODEL}.% %${SRCX} %${RULEX} models check_rescoring_model
	@_LOCAL=1 echo "Generating $@"
	RP_PSUB_OPTS="-${TRANS_CPUS}" \
	rat.sh \
		-lb \
		-n ${PARALLELISM_LEVEL_TRANSLATE} \
		trans \
		-v \
		-K ${NBEST_SIZE} \
		-msrc $(word 3, $+) \
		-f $< \
		${RESCORING_MODEL_DIR}/${RESCORING_MODEL} \
		$(word 2,$+) \
	>& log.$@ \
	&& mv $*${RULEX}.rat $@

RAT_BLEU_DEP = $(addsuffix .rat.bleu, ${TEST_SET})
.PHONY: rat.bleu
rat.bleu: SHELL=${GUARD_SHELL}
rat.bleu: ${RAT_BLEU_DEP}
	egrep Human $+

$(addsuffix .rat.bleu, ${TEST_SET}): SHELL=${GUARD_SHELL}
%.rat.bleu: %.rat %${TGTX}
	@echo "Calculating BLEU for $@"
	bleumain $^ > $@

.PHONY: rat.detok
rat.detok: $(addsuffix .rat.detok, ${TEST_SET})
$(addsuffix .rat.detok, ${TEST_SET}): SHELL=${GUARD_SHELL}

# Invalid, can't compare the detokenized translation with a tokenized and
# lowercase reference.
#.PHONY: rat.detok.bleu
#rat.detok.bleu: $(addsuffix .rat.detok.bleu, ${TEST_SET})
#$(addsuffix .rat.detok.bleu, ${TEST_SET}): SHELL=${GUARD_SHELL}
#%.rat.detok.bleu: %.rat.detok %${TGTX}
#	@echo "Calculating BLEU for $@"
#	cat $(word 2, $+) \
#	| utf8_casemap -c l \
#	| bleumain $< - > $@

clean.content: clean.rescore

.PHONY: clean.rescore_trans
clean.rescore: SHELL=${GUARD_SHELL}
clean.rescore: $(foreach f, ${TEST_SET}, clean.rescore.$f)
clean.rescore.%:
	${RM} $*.rat $*.rat.bleu
	${RM} $*.rat.detok $*.rat.detok.bleu
	${RM} -r workdir-$*${RULEX}-${NBEST_SIZE}best



########################################
# TRUECASING
.PHONY: tc
tc: $(addsuffix .out.tc, ${TEST_SET})
ifdef DO_RESCORING
tc: $(addsuffix .rat.tc, ${TEST_SET})
endif
%.tc: % models
	@[[ -f ${TRUECASING_DIR}/${TRUECASING_LM} ]]  || (echo "Can't access truecasing lm ${TRUECASING_DIR}/${TRUECASING_LM}"; false) >&2
	@[[ -f ${TRUECASING_DIR}/${TRUECASING_MAP} ]] || (echo "Can't access truecasing map ${TRUECASING_DIR}/${TRUECASING_MAP}"; false) >&2
	@echo "TrueCasing $@"
	truecase.pl \
		-uppercaseBOS \
		-text=$< \
		-lm=${TRUECASING_DIR}/${TRUECASING_LM} \
		-map=${TRUECASING_DIR}/${TRUECASING_MAP} \
		> $@ 2> log.$@

.PHONY: tc.detok
tc.detok: $(addsuffix .out.tc.detok, ${TEST_SET})
ifdef DO_RESCORING
tc.detok: $(addsuffix .rat.tc.detok, ${TEST_SET})
endif
$(addsuffix .tc.detok, ${TEST_SET}): SHELL=${GUARD_SHELL}

clean.content: clean.truecasing

.PHONY: clean.truecasing
clean.truecasing: SHELL=${GUARD_SHELL}
clean.truecasing: $(foreach f, ${TEST_SET}, clean.truecasing.$f.out.guard)
clean.truecasing: $(foreach f, ${TEST_SET}, clean.truecasing.$f.rat.guard)
clean.truecasing.%.guard:
	${RM} $*.tc
	${RM} $*.tc.detok




################################################################################
# HELPERS

########################################
# General detokenizeer.
%.detok: %
	@echo "Detokenizing $<"
	${DETOKENIZER} -lang=${TGT_LANG} $< $@



########################################
# This is mainly a hack to fix the hierachy tree problem inherent to the
# decoding model content.
models: SHELL=${GUARD_SHELL}
models:
	ln -sf ${MODEL_DIR} $@



########################################
# Check the canoe.ini config file.
.PHONY: configtool
configtool: ${DECODING_MODEL_TEMPLATE}
	configtool check $<



########################################
# LINKS THE IBMX MODELS
# Obsolete
# ibm2.ch_given_en.gz ibm2.ch_given_en.pos.gz
# ibm2.en_given_ch.gz ibm2.en_given_ch.pos.gz
ibm2.%.gz:
	ln -sf ${IBM_DIR}/ibm2.*$*.gz ibm2.$*.gz 
	ln -sf ${IBM_DIR}/ibm2.*$*.pos.gz ibm2.$*.pos.gz

ibm1.%.gz:
	ln -sf ${IBM_DIR}/ibm1.*$*.gz ibm1.$*.gz 



########################################
# Hook to get BLEU scores
.PHONY: bleu
bleu: SHELL=${GUARD_SHELL}
bleu: ${OUT_BLEU_DEP}
ifdef DO_RESCORING
bleu: ${RAT_BLEU_DEP}
endif
bleu:
	grep Human *.bleu



########################################
# Hook to perform detokenization
.PHONY: detok
detok: out.detok
ifdef DO_TRUECASING
detok: tc.detok
endif
ifdef DO_RESCORING
detok: rat.detok
endif



########################################
# Tries to run all targets in this Makefile mainly to check the syntax of all
# targets.
.PHONY: full
full: out.bleu
full: out.detok.bleu
full: rat.bleu
full: rat.detok.bleu
full: configtool
