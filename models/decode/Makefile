#!/usr/bin/make -f
# vim:noet:ts=3:nowrap

# @file Makefile
# @brief Tune/train a decoding model.
#
# @author Samuel Larkin
#
# Traitement multilingue de textes / Multilingual Text Processing
# Tech. de l'information et des communications / Information and Communications Tech.
# Conseil national de recherches Canada / National Research Council Canada
# Copyright 2008, 2015, Sa Majeste la Reine du Chef du Canada
# Copyright 2008, 2015, Her Majesty in Right of Canada

# Mandatory include: master config file.
include ../../Makefile.params

# Include and override parameters with user specific config file.
MAKEFILE_PARAMS ?= Makefile.params
-include ${MAKEFILE_PARAMS}

# Include the master toolkit.
include ../../Makefile.toolkit

# What is this module's name.
MODULE_NAME ?= decode

# Define languages info.
# SRC_LANG and TGT_LANG are defined in the master Makefile.params.
#SRC_LANG ?= en
#TGT_LANG ?= fr
SRCX  ?= ${RULEX}
TGTX  ?= ${LANGX}

# Untuned decoding model
UNTUNED_DECODING_MODEL ?= canoe.ini

# Indicates where to find the canoe.ini template
TEMPLATE_DIR            ?= ./
DECODING_MODEL_TEMPLATE ?= ${UNTUNED_DECODING_MODEL}.template

# Tuned decoding model
DECODING_MODEL ?= ${UNTUNED_DECODING_MODEL}.cow

# Will indicate to make where to find the SETs (dev & test & eval)
CORPORA_DIR ?= ../../corpora

# Indicates where to find all models.
MODEL_DIR ?= ../../models

# Indicates what prefix/file to use for training a decoder model
TUNE_DECODE     ?= dev1
# What source file to use for tuning the decoder.
TUNE_DECODE_SRC  := ${TUNE_DECODE}${SRCX}
# What reference files to use for tuning the decoder.
TUNE_DECODE_TGTS  := $(call CREATE_REFERENCE_NAMES, ${TUNE_DECODE})

# Specific PSUB options
PSUB_OPTS ?=

# Extra canoe parameters that a user would want to include in its canoe.ini.
# i.e. -d 1:1:1:1:1:1:1 -load-first
CANOE_INI_EXTRAS ?=

# Extra distortion models to use
DM_EXTRAS ?=

# Indicates the nbest list size.
NBEST_SIZE ?= 1000

# Number of parallel chunks to process.
PARALLELISM_LEVEL_TUNE_DECODE ?= 5

# What program to use to do MERT.
MERT ?= tune.py

# How may cpus should MERT be using.
# tune.py requires 16GB memory for java.
MERT_CPUS ?= 4
# How may cpus should each decode worker be using when doing MERT.
DECODE_CPUS ?= 1

# What is the maximum number of iterations mert should do?
MERT_MAX_ITER ?= 15

# Extra canoe options passed via tune.py's -d option
CANOE_EXTRAS ?= -lattice-source-density

# If you need to add any other options to MERT.
MERT_EXTRAS ?=

# Track memory usage.
TIME_MEM ?= time-mem

# After this Makefile, the following targets/files are precious.
FILES_TO_BE_LOCKED = ${DECODING_MODEL}

########################################
# SETUP
ifneq ($(filter-out help clean clean.content clean.logs time-mem, ${MAKECMDGOALS}),)
$(info ln -fs ${MODEL_DIR})
$(shell ln -fs ${MODEL_DIR})
endif


.DEFAULT_GOAL := help
.SECONDARY:
.SUFFIXES:
.DELETE_ON_ERROR:

# Threre are two differents vpath for heldout because in the chinese case for example the src_ext != tgt_ext
vpath %${SRCX}   ${CORPORA_DIR}
vpath %${TGTX}   ${CORPORA_DIR}
vpath %${LANGX}  ${CORPORA_DIR}
vpath %${RULES}  ${CORPORA_DIR}
vpath ${DECODING_MODEL_TEMPLATE} ${TEMPLATE_DIR}


MAIN_TARGETS :=  all clean help

########################################
.PHONY: all
all: train


########################################
.PHONY: help
help: SHELL=${LOCAL_SHELL}
help:
	@echo "Tune a system."
	@echo
	@echo "To tune the models, type: make all"
	${HELP_LIST_MAIN_TARGETS}
	${HELP_LIST_EXPECTED_FILES}


########################################
# What the user can expect from this module.
.PHONY: list_final_output
list_final_output: SHELL=${LOCAL_SHELL}
list_final_output:
	@echo "Expected final output:"
	@echo "${EXPECTED_FILES}"


########################################
# Clean up
.PHONY: clean clean.content clean.logs hide.logs
clean: SHELL=${LOCAL_SHELL}
clean: clean.content clean.logs

clean.content: SHELL=${LOCAL_SHELL}
clean.content:
	${RM} models

clean.logs: SHELL=${LOCAL_SHELL}
clean.logs:
	${RM} log.* run-parallel-logs*
	${RM} -r logs/

# Hide logs from user's view into .logs
hide.logs: SHELL=${LOCAL_SHELL}
hide.logs: hide_logs_sub


########################################
# Resources Summary
.PHONY: time-mem
time-mem: SHELL=${LOCAL_SHELL}
time-mem: resource_summary_sub

MAIN_TARGETS += time-mem


########################################
# Is the template present?
.PHONY: check_template
check_template: SHELL=${LOCAL_SHELL}
check_template:
	@[[ -f ${TEMPLATE_DIR}/${DECODING_MODEL_TEMPLATE} ]] \
	|| ! echo "ERROR: Cannot find this template: ${DECODING_MODEL_TEMPLATE}" >&2


########################################
# Create canoe.ini from template.
ifdef USE_LDM
LDM ?= $(wildcard models/ldm/ldm.*.${SRC_LANG}2${TGT_LANG}.gz)
ifneq ($(filter-out clean clean.content clean.logs time-mem, ${MAKECMDGOALS}),)
ifeq ($(strip ${LDM}),)
$(warning No LDMs available. Have you trained at least a distortion model?)
endif
endif
$(info LDM: ${LDM})
LDM := $(if ${USE_LDM},${LDM}\#L)

# Parameters to use Lexicalized Distortion Models.
LDM_PARAMS  := back-lex\#m\#L:back-lex\#s\#L:back-lex\#d\#L:fwd-lex\#m\#L:fwd-lex\#s\#L:fwd-lex\#d\#L
endif # USE_LDM

ifdef USE_HLDM
HLDM ?= $(wildcard models/ldm/hldm.*.${SRC_LANG}2${TGT_LANG}.gz)
ifneq ($(filter-out clean clean.content clean.logs time-mem, ${MAKECMDGOALS}),)
ifeq ($(strip ${HLDM}),)
$(warning No HLDMs available. Have you trained at least a distortion model?)
endif
endif
$(info HLDM: ${HLDM})
HLDM := $(and ${USE_HLDM},${HLDM}\#H)

# Parameters to use Hierarchical Lexicalized Distortion Models.
HLDM_PARAMS := back-hlex\#m\#H:back-hlex\#s\#H:back-hlex\#d\#H:fwd-hlex\#m\#H:fwd-hlex\#s\#H:fwd-hlex\#d\#H
endif # USE_HLDM

ifdef USE_SPARSE
SPARSE ?= models/sparse/model
$(info Sparse: ${SPARSE})
endif

# NOTE: We need to keep the checks here AND in the target UNTUNED_DECODING_MODEL.
CPT_SEARCH := models/tm/cpt.*${SRC_LANG}2${TGT_LANG}.gz
CPTS ?= $(wildcard ${CPT_SEARCH})
ifneq ($(filter-out clean clean.content clean.logs time-mem, ${MAKECMDGOALS}),)
ifeq ($(strip ${CPTS}),)
$(warning No CPTs available. Have you trained at least one translation model?)
endif
endif
$(info CPTs: ${CPTS})

LM_SEARCH := models/lm/*_${TGT_LANG}[-.]*.tplm models/mixlm/${TUNE_DECODE}.mixlm
LMS  ?= $(wildcard ${LM_SEARCH})
ifneq ($(filter-out clean clean.content clean.logs time-mem, ${MAKECMDGOALS}),)
ifeq ($(strip ${LMS}),)
$(warning No LMs available. Have you trained at least one language model?)
endif
endif
$(info LMs: ${LMS})

ifdef USE_COARSELM
COARSE_LM_SEARCH ?= models/coarselm/*_${TGT_LANG}-${n}[-.]*tplm
COARSE_LM_SPECS ?= $(foreach n, ${COARSELM_NCLS_LIST}, \
                      $(foreach lm, $(wildcard ${COARSE_LM_SEARCH}), \
                         DynMap;wordClasses-models/wcl/${TGT_LANG}.${n}.classes;${lm} \
                      ) \
                   )
$(info Coarse LMs: $(strip ${COARSE_LM_SPECS}))
endif # USE_COARSELM

ifdef USE_BILM
define BILM_SPECS_PYSCRIPT
from __future__ import print_function
import re
import glob

src_lang = "${SRC_LANG}"
tgt_lang = "${TGT_LANG}"
lm_lang = "${SRC_LANG}2${TGT_LANG}"

spec_re = re.compile("(?:-([0-9]+)bi)?(?:-([0-9]+)s)?(?:-([0-9]+)t)?_" + lm_lang)

specs=[]
for bilm in glob.iglob("models/bilm/*_{0}-*.tplm".format(lm_lang)):
   m = spec_re.search(bilm)
   bit_ncls, src_ncls, tgt_ncls = m.groups()
   src_spec = "-{0}s".format(src_ncls) if src_ncls else ""
   tgt_spec = "-{0}t".format(tgt_ncls) if src_ncls else ""
   spec = bilm
   if bit_ncls:
      spec += ";cls(tgt/src)=models/bilm/bitoks.all{ss}{ts}.{l}.{ncls}.classes".format(
              ss=src_spec, ts=tgt_spec, l=lm_lang, ncls=bit_ncls)
   if src_ncls:
      spec += ";cls(src)=models/wcl/{sl}.{ncls}.classes".format(sl=src_lang, ncls=src_ncls)
   if tgt_ncls:
      spec += ";cls(tgt)=models/wcl/{tl}.{ncls}.classes".format(tl=tgt_lang, ncls=tgt_ncls)
   specs.append(spec)
print(":".join(specs))
endef

BILM_SPECS := $(shell python -c '${BILM_SPECS_PYSCRIPT}')
$(info BiLMs: ${BILM_SPECS})
endif # USE_BILM

ifdef NNJM_PRETRAINED_NNJMS
NNJMS := $(wildcard models/nnjm/*/model)
ifneq ($(filter-out clean clean.content clean.logs time-mem, ${MAKECMDGOALS}),)
ifeq ($(strip ${NNJMS}),)
$(error Could not find pretrained NNJMs)
endif
endif
$(info NNJMs: ${NNJMS})
endif

# This is a helper to be able to use spaces.
SPACE :=
SPACE +=

${UNTUNED_DECODING_MODEL}: SHELL=${LOCAL_SHELL}
${UNTUNED_DECODING_MODEL}: ${DECODING_MODEL_TEMPLATE}
	@ls ${CPT_SEARCH} &> /dev/null \
	|| ! echo "ERROR: No CPTs available. Please train the translation model(s) first!" >&2
	@[[ `ls ${LM_SEARCH} 2> /dev/null | \wc -l` > 0 ]] \
	|| ! echo "ERROR: No LMs available. Please train the language model(s) first!" >&2
	cat $< \
	| sed -e 's/<SL>/${SRC_LANG}/g' \
	      -e 's/<TL>/${TGT_LANG}/g' \
	      -e 's#<CPTS>#${CPTS}#g' \
	      -e 's#<LMS>#${LMS} ${COARSE_LM_SPECS}#g' \
	| configtool -p "args: \
	      $(and ${USE_LDM}${USE_HLDM}, -dist-phrase-swap) \
	      -distortion-model WordDisplacement:${LDM_PARAMS}:${HLDM_PARAMS}:${DM_EXTRAS} \
	      -lex-dist-model-file ${LDM}:${HLDM} \
	      $(if ${BILM_SPEC}, -bilm-file ${BILM_SPECS}) \
	      $(if ${NNJM_PRETRAINED_NNJMS}, -nnjm-file $(subst ${SPACE},:, ${NNJMS})) \
	      $(and ${USE_SPARSE}, -sparse-model ${SPARSE} -force-shift-reduce) \
	      ${CANOE_INI_EXTRAS} \
	  " - \
	> $@
	configtool check $@

clean.content: clean.canoe.ini

.PHONY: clean.canoe.ini
clean.canoe.ini: SHELL=${LOCAL_SHELL}
clean.canoe.ini:
	${RM} ${DECODING_MODEL} tmp.${UNTUNED_DECODING_MODEL} rmodels_sparse*.wts.gz


########################################
# Training a decoding model.

EXPECTED_FILES = ${DECODING_MODEL}

.PHONY: train
train: ${DECODING_MODEL}
${DECODING_MODEL}: SHELL=${FRAMEWORK_SHELL}
${DECODING_MODEL}: ${UNTUNED_DECODING_MODEL} ${TUNE_DECODE_SRC} ${TUNE_DECODE_TGTS}
	_LOCAL=1 mkdir -p foos
	RP_PSUB_OPTS="-${DECODE_CPUS} -N tune.decode.model" \
	time-mem filter_models -z -r -tm-soft-limit cpt.${TUNE_DECODE} $(and ${LDM}${HLDM}, -ldm) < $(filter %${TUNE_DECODE_SRC},$+) >& log.cpt.${TUNE_DECODE}.FILT
	RP_PSUB_OPTS="-${MERT_CPUS} -N tune.decode.model" \
	time-mem \
	${MERT} \
		-v \
		-o $@.FILT \
		-p ${PARALLELISM_LEVEL_TUNE_DECODE} \
		-c ${DECODE_CPUS} \
		-m ${MERT_MAX_ITER} \
		-n 100 \
		-a lmira \
		$(and ${USE_SPARSE},-r) \
		--workdir=foos \
		$(if ${CANOE_EXTRAS},-d '${CANOE_EXTRAS}') \
		${MERT_EXTRAS} \
		-f $<.FILT $(wordlist 2,100,$+) \
		&> log.$@
	_LOCAL=1 configtool -p args:"`configtool weights $@.FILT`" $< > $@
	_LOCAL=1 ${RM} -r foos *.FILT.gz *.FILT.bkoff ${UNTUNED_DECODING_MODEL}.FILT ${UNTUNED_DECODING_MODEL}.cow.FILT

clean.content: clean.tune

.PHONY: clean.tune
clean.tune: SHELL=${LOCAL_SHELL}
clean.tune:
	${RM} -r foos canoe-parallel.* run-p.*
	${RM} ${DECODING_MODEL}
	${RM} ${UNTUNED_DECODING_MODEL} ${UNTUNED_DECODING_MODEL}.FILT ${UNTUNED_DECODING_MODEL}.cow.FILT
	${RM} *.FILT.gz *.FILT.bkoff
	${RM} summary summary.wts
	${RM} decode-config


################################################################################
# Instructions for portageLive
# NOTE: you cannot apply weights if you plan to do some rescoring.

PORTAGE_LIVE_DEST_DIR ?= ../portageLive
CANOE_LIVE            ?= ${PORTAGE_LIVE_DEST_DIR}/${DECODING_MODEL}

.PHONY: portageLive
portageLive: SHELL=${LOCAL_SHELL}
portageLive: ${CANOE_LIVE}

MAIN_TARGETS += portageLive

${PORTAGE_LIVE_DEST_DIR}: SHELL=${LOCAL_SHELL}
${PORTAGE_LIVE_DEST_DIR}:
	mkdir -p $@

.PHONY: portageLive_models
portageLive_models_%: SHELL=${LOCAL_SHELL}
portageLive_models_%:
	${MAKE} -C ../$* portageLive

${CANOE_LIVE}: SHELL=${LOCAL_SHELL}
${CANOE_LIVE}: portageLive_models_lm
${CANOE_LIVE}: portageLive_models_tm
${CANOE_LIVE}: portageLive_models_ldm
${CANOE_LIVE}: | ${PORTAGE_LIVE_DEST_DIR}
${CANOE_LIVE}: ${DECODING_MODEL}
	configtool -p tp $< > $@
	sed -e 's#\(wordClasses-models/wcl/.*\).classes;#\1.mmcls;#' \
	    -e 's#\(;cls(\(src\|tgt\|tgt/src\))=models[^=]*\).classes#\1.mmcls#g' \
	    --in-place $@
	configtool check $@

clean.content: clean.portageLive
.PHONY: clean.portageLive
clean.portageLive: SHELL=${LOCAL_SHELL}
clean.portageLive:
	${RM} ${CANOE_LIVE}

ifdef USE_SPARSE
SPARSE_WTS ?= rmodels_sparse_model.wts.gz
SPARSE_WTS_LIVE ?= ${PORTAGE_LIVE_DEST_DIR}/${SPARSE_WTS}
${CANOE_LIVE}: ${SPARSE_WTS_LIVE}
${CANOE_LIVE}: portageLive_models_sparse
${SPARSE_WTS_LIVE}: SHELL=${LOCAL_SHELL}
${SPARSE_WTS_LIVE}: | ${PORTAGE_LIVE_DEST_DIR}
${SPARSE_WTS_LIVE}:
	ln -s ../decode/${SPARSE_WTS} $@

clean.portageLive: clean.sparseWtsLive
clean.sparseWtsLive: SHELL=${LOCAL_SHELL}
clean.sparseWtsLive:
	${RM} ${SPARSE_WTS_LIVE}
endif

# Output a blank line after listing all models.
$(info )

################################################################################
# HELPERS
.PHONY: testsuite
testsuite:  unittest1
testsuite:  unittest2
testsuite:  unittest3
testsuite:  unittest4
testsuite:  unittest5

# Create a canoe.ini without any Lexicalized Distortion Models what so ever.
.PHONY: unittest1
unittest1:
	${MAKE} USE_LDM= USE_HLDM= canoe.ini -B
	grep '^\[lex-dist-model-file\] --$$' canoe.ini
	! egrep 'back-lex' canoe.ini
	! egrep 'fwd-lex' canoe.ini
	! grep '^\[dist-phrase-swap\]$$' canoe.ini

# Create a canoe.ini that uses Lexicalized Distortion Models.
.PHONY: unittest2
unittest2:
	${MAKE} USE_LDM=1 USE_HLDM= canoe.ini -B
	grep '[^h]ldm.hmm3+ibm2.en2fr.gz' canoe.ini
	! grep 'hldm.hmm3+ibm2.en2fr.gz' canoe.ini
	egrep 'back-lex' canoe.ini
	! egrep 'back-hlex' canoe.ini
	egrep 'fwd-lex' canoe.ini
	! egrep 'fwd-hlex' canoe.ini
	grep '^\[dist-phrase-swap\]$$' canoe.ini

# Create a canoe.ini that uses Hierarchical Lexicalized Distortion Models.
.PHONY: unittest3
unittest3:
	${MAKE} USE_LDM= USE_HLDM=1 canoe.ini -B
	! grep '[^h]ldm.hmm3+ibm2.en2fr.gz' canoe.ini
	grep 'hldm.hmm3+ibm2.en2fr.gz' canoe.ini
	! egrep 'back-lex' canoe.ini
	egrep 'back-hlex' canoe.ini
	! egrep 'fwd-lex' canoe.ini
	egrep 'fwd-hlex' canoe.ini
	grep '^\[dist-phrase-swap\]$$' canoe.ini

# Create a canoe.ini that uses Lexicalized Distortion Models & Hierarchical Lexicalized Distortion Models.
.PHONY: unittest4
unittest4:
	${MAKE} USE_LDM=1 USE_HLDM=2 canoe.ini -B
	grep '[^h]ldm.hmm3+ibm2.en2fr.gz' canoe.ini
	grep 'hldm.hmm3+ibm2.en2fr.gz' canoe.ini
	egrep 'back-lex' canoe.ini
	egrep 'back-hlex' canoe.ini
	egrep 'fwd-lex' canoe.ini
	egrep 'fwd-hlex' canoe.ini
	grep '^\[dist-phrase-swap\]$$' canoe.ini

# Recommended tune algorithm is Lattice Mira.  Let's make sure this is the what
# the framework is using.
.PHONY: unittest5
unittest5:  ${DECODING_MODEL}
	@grep -m1 MiraTrainLattice logs/log.optimize --quiet \
	|| ! echo "Recommended practice is to use Lattice Mira for tuning but the framework is not using it by default" >&2


testsuite:  tune_with_tplms.testcase
tune_with_tplms.testcase:  export TRAIN_LM := lm-train sublm3
tune_with_tplms.testcase:  export MIXLM := sublm1 sublm2 sublm3 lm-train
tune_with_tplms.testcase:  export MIXLM_PRETRAINED_TGT_LMS := /home/models/generic-model/v1.0/dvd_v1.0/lm/generic1.0_fr.tplm
tune_with_tplms.testcase:  export TRAIN_COARSELM := coarselm-train
tune_with_tplms.testcase:  export TRAIN_BILM := bilm-train
tune_with_tplms.testcase:  export COARSELM_NCLS_LIST := 200 800
tune_with_tplms.testcase:  export BILM_SPEC := 400bi-400s-400t
tune_with_tplms.testcase:  export MERT_MAX_ITER := 3
tune_with_tplms.testcase:  SHELL := bash
tune_with_tplms.testcase:
	echo "TESTCASE:  $@"
	${MAKE} clean &> /dev/null
	time ${MAKE} -j 11 -C ../wcl all
	time ${MAKE} -j 11 -C ../ibm all
	time ${MAKE} -j 11 -C ../wal all
	time ${MAKE} -j 11 -C ../lm all
	time ${MAKE} -j 11 -C ../bilm all
	time ${MAKE} -j 11 -C ../coarselm all
	time ${MAKE} -j 11 -C ../mixlm all
	time ${MAKE} -j 11 -C ../jpt all
	time ${MAKE} -j 11 -C ../tm all
	time ${MAKE} -j 11 ${TESTCASE_OPTS} all
	[[ `configtool -l list-lm canoe.ini.cow | grep -c 'models/lm/lm-train'` -eq 1 ]] || ! echo "$@ is missing a LM for lm-train."
	[[ `configtool -l list-lm canoe.ini.cow | grep -c 'models/lm/sublm3'` -eq 1 ]] || ! echo "$@ is missing a LM for sublm3."
	[[ `configtool -l list-lm canoe.ini.cow | grep -c 'models/coarselm/'` -eq 2 ]] || ! echo "$@ failed to use coarselm."
	[[ `configtool -l list-lm canoe.ini.cow | grep -c 'models/mixlm/.*\.mixlm'` -eq 1 ]] || ! echo "$@ failed to use mixlm."
	[[ `configtool -l list-lm canoe.ini.cow | grep 'models/mixlm/.*\.mixlm' | xargs grep -c '.tplm	'` -eq 5 ]] || ! echo "$@'s Mixlm is not built around tplms."
	[[ `configtool list-all-files canoe.ini.cow | grep -c '.tplm$$'` -eq 10 ]] || ! echo "$@ should be using 10 tplm."
	[[ `configtool list-bilm canoe.ini.cow | grep -c bilm-train` -eq 1 ]] || ! echo "$@ failed to use bilm."
	[[ `configtool list-bilm canoe.ini.cow | cut -f 1 -d ';' | grep -c '.tplm$$'` -eq 1 ]] || ! echo "$@ should be using 10 tplm."
