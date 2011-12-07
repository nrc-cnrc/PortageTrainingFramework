#!/usr/bin/make -f
# vim:noet:ts=3:nowrap
#
# $Id$
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

# Lastly include the master toolkit
include ../Makefile.toolkit


# What is this module's name.
MODULE_NAME ?= translate

# Define languages info.
#SRC_LANG ?= en
#TGT_LANG ?= fr
SRCX  ?= _${SRC_LANG}${LANGX}
TGTX  ?= _${TGT_LANG}${LANGX}
RULEX ?= _${SRC_LANG}.rule
SRCTCX ?= _${SRC_LANG}${ALIGNX}
TGTTCX ?= _${TGT_LANG}${ALIGNX}

# Define any value to the following variable if you are doing rescoring.
# If you are rescoring, there are some step that can be skipped to save cpu
# power :D.
#DO_RESCORING = 1

# File encoding
ENCODING ?= UTF-8

# What program to use to detokenize.
ifdef DETOKENIZER_${TGT_LANG}
DETOKENIZER = ${DETOKENIZER_${TGT_LANG}}
else
ifneq ($(findstring ${ENCODING}, UTF-8 UTF8 utf-8 utf8),)
DETOKENIZER = udetokenize.pl -lang=${TGT_LANG}
else
DETOKENIZER = detokenize.pl -lang=${TGT_LANG}
endif
endif

# This is used to create a symbolic link.
MODEL_DIR ?= ../models

# Indicates where to find the canoe.ini template.
DECODING_MODEL_DIR      ?= models/decode
DECODING_MODEL          ?= canoe.ini.cow
DECODING_MODEL_TEMPLATE ?= ${DECODING_MODEL_DIR}/${DECODING_MODEL}

# Indidcates where to find the rescoring model.
RESCORING_MODEL_DIR ?= models/rescore
RESCORING_MODEL     ?= rescore-model

# Indidcates where to find the confidence estimation model.
CONFIDENCE_MODEL_DIR ?= models/confidence
CONFIDENCE_MODEL     ?= ce_model.cem

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

# What to use to monitor resources.
TIME_MEM ?= time-mem


# We will create a link towards models this funky way instead of having a
# target to link to models because a target.  This will ensure the presence of
# the symbolic link and also make sure we don't rely on it to be older than any
# targets otherwise as soon as the user modifies a file or add something to
# models/, this would trigger the timestamp of models to be updated thus making
# it a newer target thus forcing remaking everything.
ifneq (${MAKECMDGOALS},clean)
ifneq (${MAKECMDGOALS},clean.content)
ifneq (${MAKECMDGOALS},clean.logs)
$(shell ln -fs ${MODEL_DIR})
endif
endif
endif



.DEFAULT_GOAL := help
.SECONDARY:
.SUFFIXES:
.DELETE_ON_ERROR:

# Tells make where to find files that we've made in previous scripts/modules.
vpath %${SRCX}  ${CORPORA_DIR}
vpath %${TGTX}  ${CORPORA_DIR}
vpath %${RULEX} ${CORPORA_DIR}
vpath %${SRCTCX} ${CORPORA_DIR}
vpath %${TGTTCX} ${CORPORA_DIR}

vpath ${DECODING_MODEL}  ${DECODING_MODEL_DIR}  models/decode
vpath ${RESCORING_MODEL} ${RESCORING_MODEL_DIR} models/rescore
vpath ${TRUECASING_LM}   ${TRUECASING_DIR} models/tc
vpath ${TRUECASING_MAP}  ${TRUECASING_DIR} models/tc



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

FINAL_RESULT += $(addsuffix .translation, ${TEST_SET})
ifdef TRANSLATE_SET
FINAL_RESULT += $(addsuffix .translation, ${TRANSLATE_SET})
endif

final_result: ${FINAL_RESULT}

# The final outputs will be named *.translation.
%.translation: %${FINALX}
	${POST_PROCESSING} < $< > $@



# What the user can expect from this module.
.PHONY: list_final_output
list_final_output: SHELL=${GUARD_SHELL}
list_final_output:
	@echo "Expected final output(s):"
	@echo "${FINAL_RESULT}"



# An alias that indicate what/how to translate the translation set without rescoring.
.PHONY: translate
translate: out

# An alias to translate and rescore the translation set.
.PHONY: rescore
rescore: rat



# This is where we would document this module's help.
.PHONY: help
help: SHELL=${GUARD_SHELL}
help:
	@echo "Translate the following test sets: $(addsuffix _${SRC_LANG}, ${TEST_SET})"
	@echo
	@echo "To translate your test sets, type: make all"
	@echo
	@echo "The main targets in this Makefile are:"
	@cat $(firstword $(MAKEFILE_LIST)) | egrep '^.PHONY:' | sed 's#^.PHONY: #   #'
	@echo "Most likely you want to run either: make all or make translate."



########################################
# Clean up
.PHONY: clean clean.content clean.logs hide.logs
clean: SHELL=${GUARD_SHELL}
clean: clean.content clean.logs

clean.content: SHELL=${GUARD_SHELL}
clean.content:
	${RM} *.translation models canoe.ini.cow

clean.logs: SHELL=${GUARD_SHELL}
clean.logs:
	${RM} log.* run-parallel-logs*

# Hide logs from user's view into .logs
hide.logs: SHELL=${GUARD_SHELL}
hide.logs: hide_logs_sub



########################################
# Resources Summary
.PHONY: time-mem
time-mem: SHELL=${GUARD_SHELL}
time-mem: resource_summary_sub



########################################
# If there is no decoding model available, warn the user since we do not know
# how to make the decoding model in this module.
#.PHONY: check_decoding_model # Cannot be phony or else it will trigger always remaking targets.
check_decoding_model: SHELL=${GUARD_SHELL}
check_decoding_model:
	@[[ -e ${DECODING_MODEL_DIR}/${DECODING_MODEL} ]] \
	|| ! echo "ERROR: No decoding model (${DECODING_MODEL}) available. Please train ${DECODING_MODEL_DIR} first!" >&2

########################################
# Create a specific canoe.ini per test set.
# You could add some specific target if you need to customize a canoe.ini.cow
# for a particular file.
$(addprefix ${DECODING_MODEL}., ${TEST_SET}): SHELL=${GUARD_SHELL}
ifdef MIXLM
include models/mixlm/Makefile.toolkit

.INTERMEDIATE: components
.INTERMEDIATE: $(addsuffix .distances, ${TEST_SET})
.INTERMEDIATE: $(addsuffix .weights, ${TEST_SET})

clean.content: clean.mixlm

.PHONY: clean.mixlm
clean.mixlm: SHELL=${GUARD_SHELL}
clean.mixlm:
	${RM} *.distances components *.weights *.mixlm

$(addprefix ${DECODING_MODEL}., ${TEST_SET}): ${DECODING_MODEL}.%: %.mixlm
endif
$(addprefix ${DECODING_MODEL}., ${TEST_SET}): ${DECODING_MODEL}.%: check_decoding_model
	sed -e 's#models/lm/${TUNE_DECODE}.mixlm#$*.mixlm#g' ${DECODING_MODEL_DIR}/${DECODING_MODEL} > $@
	configtool check $@
# example: increase the beam threshold and stack size.
#	cat $< \
#	| perl -pe 's/\[stack\].*/[stack] 600/go; s/\[beam-threshold\].*/[beam-threshold] 0.00001/go;' \
#	| sed "s/${TUNE_DECODE}/$*/" \
#	> $@

clean.content: clean.decoding.models

.PHONY: clean.decoding.models
clean.decoding.models: SHELL=${GUARD_SHELL}
clean.decoding.models: $(foreach f, ${TEST_SET} ${TRANSLATE_SET}, clean.decoding.models.$f)
clean.decoding.models.%:
	${RM} ${DECODING_MODEL}.$*



################################################################################
# Translate translate_set without rescoring.
.PHONY: out
out: $(addsuffix .out, ${TEST_SET})
ifdef DO_RESCORING
# if we are doing rescoring, we can save us some work by going straight to
# rescoring and extracting the 1 best instead of calculating it twice.
%.out: SHELL=${GUARD_SHELL}
%.out: %.rat
	cp workdir-$*${RULEX}-${NBEST_SIZE}best/1best $@
else
%.out: SHELL=${FRAMEWORK_SHELL}
%.out: ${DECODING_MODEL}.% %${RULEX}
	@_LOCAL=1 echo "Generating $@"
	RP_PSUB_OPTS="-${TRANS_CPUS}" \
	canoe-parallel.sh \
		-lb \
		-n ${PARALLELISM_LEVEL_TRANSLATE} \
		canoe \
		-f $< \
		-palign \
		< $(word 2, $^) \
		2> log.$@ \
	| nbest2rescore.pl -canoe -tagoov -palout=$@.pal  2> log.$@.pal \
	| tee  $@.oov \
	| perl -pe 's/<OOV>(.+?)<\/OOV>/\1/g;' \
	> $@
endif

OUT_BLEU_DEP = $(addsuffix .out.bleu, ${TEST_SET})
.PHONY: out.bleu
out.bleu: SHELL=${GUARD_SHELL}
out.bleu: ${OUT_BLEU_DEP}
	@echo "Lowercase BLEU scores:"
	@egrep Human $+

# Specifing dependencies for calculating BLEU scores for translation coming out
# of the deconder.
${OUT_BLEU_DEP}: %.out.bleu: %.out %${TGTX}

TC_BLEU_DEP = $(addsuffix .tc.bleu, ${TEST_SET})
.PHONY: tc.bleu
tc.bleu: SHELL=${GUARD_SHELL}
tc.bleu: ${TC_BLEU_DEP}
	@echo "Truecase BLEU scores:"
	@egrep Human $+

${TC_BLEU_DEP}: %.tc.bleu: %.out.tc %${TGTTCX}

.PHONY: out.detok
out.detok: $(addsuffix .out.detok, ${TEST_SET})
%.out.detok: SHELL=${GUARD_SHELL}

# Invalid, can't compare the detokenized translation with a tokenized and
# lowercase reference.
#.PHONY: out.detok.bleu
#out.detok.bleu: $(addsuffix .out.detok.bleu, ${TEST_SET})
#$(addsuffix .out.detok.bleu, ${TEST_SET}): SHELL=${GUARD_SHELL}
#%.out.detok.bleu: %.out.detok %${TGTX}
#	@echo "Calculating BLEU for $@"
#	cat $(word 2, $+) \
#	| utf8_casemap -c l \
#	| bleumain -c $< - > $@

clean.content: clean.translate

.PHONY: clean.translate
clean.translate: SHELL=${GUARD_SHELL}
clean.translate: $(foreach f, ${TEST_SET}, clean.translate.$f)
	${RM} -r canoe-parallel.* run-p.*
	${RM} tc_tmp_*

clean.translate.%:
	${RM} $*.out $*.out.oov $*.out.pal $*.out.bleu $*.tc.bleu
	${RM} $*.out.detok $*.out.detok.bleu


#.PHONY: check_rescoring_model # Cannot be phony or else it will trigger always remaking targets.
check_rescoring_model: SHELL=${GUARD_SHELL}
check_rescoring_model:
	@[[ -e ${RESCORING_MODEL_DIR}/${RESCORING_MODEL} ]] \
	|| ! echo "ERROR: No rescoring model (${RESCORING_MODEL}) available. Please train ${RESCORING_MODEL_DIR} first!" >&2



################################################################################
# Rescore the translate_set
.PHONY: rat
rat: $(addsuffix .rat, ${TEST_SET})
%.rat: SHELL=${FRAMEWORK_SHELL}
%.rat: ${DECODING_MODEL}.% %${SRCX} %${RULEX} check_rescoring_model
	@_LOCAL=1 echo "Generating $@"
	RP_PSUB_OPTS="-${TRANS_CPUS}" \
	rat.sh \
		-lb \
		-n ${PARALLELISM_LEVEL_TRANSLATE} \
		trans \
		-v \
		-K ${NBEST_SIZE} \
		-msrc $(filter %${RULEX}, $+) \
		-f $(filter ${DECODING_MODEL}.%, $+) \
		${RESCORING_MODEL_DIR}/${RESCORING_MODEL} \
		$(filter %${SRCX}, $+) \
	>& log.$@ \
	&& mv $*${RULEX}.rat $@

RAT_BLEU_DEP = $(addsuffix .rat.bleu, ${TEST_SET})
.PHONY: rat.bleu
rat.bleu: SHELL=${GUARD_SHELL}
rat.bleu: ${RAT_BLEU_DEP}
	@echo "Rescoring BLEU scores:"
	@egrep Human $+

# Specifing dependencies for calculating BLEU scores for rescored translations.
${RAT_BLEU_DEP}: %.rat.bleu: %.rat %${TGTX}

.PHONY: rat.detok
rat.detok: $(addsuffix .rat.detok, ${TEST_SET})
%.rat.detok: SHELL=${GUARD_SHELL}

# Invalid, can't compare the detokenized translation with a tokenized and
# lowercase reference.
#.PHONY: rat.detok.bleu
#rat.detok.bleu: $(addsuffix .rat.detok.bleu, ${TEST_SET})
#$(addsuffix .rat.detok.bleu, ${TEST_SET}): SHELL=${GUARD_SHELL}
#%.rat.detok.bleu: %.rat.detok %${TGTX}
#	@echo "Calculating BLEU for $@"
#	cat $(word 2, $+) \
#	| utf8_casemap -c l \
#	| bleumain -c $< - > $@

clean.content: clean.rescore

.PHONY: clean.rescore_trans
clean.rescore: SHELL=${GUARD_SHELL}
clean.rescore: $(foreach f, ${TEST_SET} ${TRANSLATE_SET}, clean.rescore.$f)
	${RM} -r canoe-parallel.* run-p.*

clean.rescore.%:
	${RM} $*.rat $*.rat.bleu
	${RM} $*.rat.detok $*.rat.detok.bleu
	${RM} -r workdir-$*${RULEX}-${NBEST_SIZE}best



################################################################################
# Confidence Estimation.
ifdef DO_CE
all: confidence
endif

.PHONY: confidence
confidence: $(addsuffix .ce, ${TEST_SET})
ifdef TRANSLATE_SET
confidence: $(addsuffix .ce, ${TRANSLATE_SET})
endif

# All confidence estimation calculation should be queued on the cluster.
%.ce: SHELL=${FRAMEWORK_SHELL}

%.ce: ${CONFIDENCE_MODEL} %${SRCTCX} ${DECODING_MODEL}.%
	@_LOCAL=1 echo "Generating $@"
	${TIME_MEM} \
	translate.pl -with-ce \
		-n ${PARALLELISM_LEVEL_TRANSLATE} \
		-notok -nl s $(if ${DO_TRUECASING},-tc,) \
		-encoding ${ENCODING} \
		-src ${SRC_LANG} -tgt ${TGT_LANG} \
		-f $(filter ${DECODING_MODEL}%, $+) \
		-model $(filter ${CONFIDENCE_MODEL}, $+) \
		$(filter %${SRCTCX}, $+) \
	> $@ 2> log.$@

${CONFIDENCE_MODEL}: SHELL=${GUARD_SHELL}
${CONFIDENCE_MODEL}:
	ln -fs ${CONFIDENCE_MODEL_DIR}/$@

clean.content: clean.ce

.PHONY: clean.ce
clean.ce: SHELL=${GUARD_SHELL}
clean.ce:
	${RM} -r ce-workdir-* ce_work_*
	${RM} ${CONFIDENCE_MODEL}
	${RM} *.ce



################################################################################
# TRUECASING
.PHONY: tc
tc: $(addsuffix .out.tc, ${TEST_SET})
ifdef DO_RESCORING
tc: $(addsuffix .rat.tc, ${TEST_SET})
endif
ifdef TC_USE_SRC_MODELS
TC_SRC_OPTS = -src ${CORPORA_DIR}/$(*:.out=${SRCTCX}) \
              -pal $*.pal \
              -srclang ${SRC_LANG} \
              -srclm ${TRUECASING_DIR}/${TRUECASING_NC1_SRC_LM}
endif
%.tc: SHELL=${FRAMEWORK_SHELL}
%.tc: %
	@_LOCAL=1; [[ -f ${TRUECASING_DIR}/${TRUECASING_LM} ]] || ! echo "ERROR: Can't access truecasing lm ${TRUECASING_DIR}/${TRUECASING_LM}" >&2
	@_LOCAL=1; [[ -f ${TRUECASING_DIR}/${TRUECASING_MAP} ]] || ! echo "ERROR: Can't access truecasing map ${TRUECASING_DIR}/${TRUECASING_MAP}" >&2
ifdef TC_USE_SRC_MODELS
	@_LOCAL=1; [[ -f ${TRUECASING_DIR}/${TRUECASING_NC1_SRC_LM} ]] || ! echo "ERROR: Can't access truecasing nc1 source lm ${TRUECASING_DIR}/${TRUECASING_NC1_SRC_LM}" >&2
endif
	@_LOCAL=1 echo "Truecasing $@"
	${TIME_MEM} \
	truecase.pl \
		-text $<$(if ${TC_SRC_OPTS},.oov,) \
		-bos -encoding ${ENCODING} \
		-lm ${TRUECASING_DIR}/${TRUECASING_LM} \
		-map ${TRUECASING_DIR}/${TRUECASING_MAP} \
		${TC_SRC_OPTS} \
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
clean.truecasing: $(foreach f, ${TEST_SET} ${TRANSLATE_SET}, clean.truecasing.$f.out.guard)
clean.truecasing: $(foreach f, ${TEST_SET} ${TRANSLATE_SET}, clean.truecasing.$f.rat.guard)
clean.truecasing.%.guard:
	${RM} $*.tc
	${RM} $*.tc.detok
	${RM} canoe_tc_tmp_*.tm




################################################################################
# HELPERS

########################################
# General detokenizeer.
%.detok: SHELL=${GUARD_SHELL}
%.detok: %
	@echo "Detokenizing $<"
	${DETOKENIZER} < $< > $@



########################################
# Check the canoe.ini config file.
.PHONY: configtool
configtool: SHELL=${GUARD_SHELL}
configtool: ${DECODING_MODEL_TEMPLATE}
	configtool check $<



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
# How to calculate BLEU.
# This target expect two files:
#  - a translation file;
#  - a reference file with TGTX as it extension.
%.bleu: SHELL=${GUARD_SHELL}
%.bleu:
	@echo "Calculating BLEU for $@"
	bleumain -c $(filter-out %${TGTX}, $+) $(filter %${TGTX}, $+) > $@



########################################
# Compare BLEU with another system.
.PHONY: bleucompare
bleucompare: $(addsuffix .bleucompare, ${TEST_SET})

COMPARE_TO ?= UNDEFINED/
%.bleucompare:  SHELL = ${GUARD_SHELL}
%.bleucompare:  %.out %${TGTX}
	@bleucompare $(filter %.out, $+) ${COMPARE_TO}/translate/$(filter %.out, $+) REFS $(filter %${TGTX}, $+)



########################################
# Tries to run all targets in this Makefile mainly to check the syntax of all
# targets.
.PHONY: full
full: out.bleu
full: out.detok.bleu
full: rat.bleu
full: rat.detok.bleu
full: configtool



.PHONY: oov
oov: $(addsuffix .woov, ${TEST_SET})
# NOTE: we do not explicitely declare the dependency on %.out.oov since it is a
# side effect of %.out.bleu which requires %.out which also silently generate
# %.out.oov.
# word out-of-vocabulary
%.woov: SHELL=${GUARD_SHELL}
%.woov:  %${RULEX} %.out.bleu
	@echo -e -n "$*\t`egrep Human $(filter %.bleu, $+)`"
	@perl -ne '++$$c while(/<OOV>(.+?)<\/OOV>/g); END{printf "\tOOV: %6.6f%%\n", 100 * $$c / `wc -w < $<`}' < $*.out.oov

