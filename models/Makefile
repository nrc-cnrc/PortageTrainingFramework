#!/usr/bin/make -f
# vim:noet:ts=3:nowrap

# @file Controls making all models.
# @brief A focal point to train all models.
#
# @author Samuel Larkin
#
# Technologies langagieres interactives / Interactive Language Technologies
# Inst. de technologie de l'information / Institute for Information Technology
# Conseil national de recherches Canada / National Research Council Canada
# Copyright 2009, 2012 Sa Majeste la Reine du Chef du Canada /
# Copyright 2009, 2012 Her Majesty in Right of Canada

MODEL_DIR_PFX := $(dir $(lastword ${MAKEFILE_LIST}))

# Mandatory include: master config file.
include ../Makefile.params

# Lastly include the master toolkit
include ../Makefile.toolkit

ifeq ("portageLive","$(findstring portageLive,${MAKECMDGOALS})")
   $(info mkdir -p portageLive)
   # Don't do the mkdir on a dryrun (-n).
   ifeq ("","$(findstring n,${MAKEFLAGS})")
      $(shell mkdir -p portageLive)
   endif
endif

_PLIVE_DECODE_VARIANT := $(strip $(if ${PLIVE_DECODE_VARIANT}, .${PLIVE_DECODE_VARIANT}))



.DEFAULT_GOAL := help
.SUFFIXES:

.PHONY: all
all: SHELL=${LOCAL_SHELL}
all: tune



########################################
# HELP MESSAGE.
.PHONY: help
help: SHELL=${LOCAL_SHELL}
help:
ifeq (${LM_TOOLKIT},IRST)
	@echo "Please run the following in order for this framework to run properly:"
	@echo "   export PATH=${IRSTLM}/bin:\$$PATH"
	@echo "   export IRSTLM=${IRSTLM}"
	@echo
endif
	${LIST_ALL_CORPORA}
	@echo
	@echo "To train your models, type: make all"
	@echo
	@echo "The main targets in this Makefile are:"
	@cat $(firstword $(MAKEFILE_LIST)) | egrep '^.PHONY:' | sed 's#^.PHONY: #   #'


########################################
# Clean up
.PHONY: clean clean.content clean.logs hide.logs
clean: SHELL=${LOCAL_SHELL}
clean: clean.content clean.logs

# Thorough cleaning of everything
# hide.logs hides logs from user's view into .logs
clean.content clean.logs hide.logs: SHELL=${LOCAL_SHELL}
clean.content clean.logs hide.logs: %:
	${MAKE} -C ldm $@
	${MAKE} -C lm $@
	${MAKE} -C ibm $@
	${MAKE} -C wal $@
	${MAKE} -C jpt $@
	${MAKE} -C sig $@
	${MAKE} -C tm $@
	${MAKE} -C tc $@
	${MAKE} -C decode $@
	${MAKE} -C rescore $@
	${MAKE} -C confidence $@
	${MAKE} -C mixlm $@
	${MAKE} -C sparse $@
	${MAKE} -C coarselm $@
	${MAKE} -C bilm $@
	${MAKE} -C wcl $@
	${MAKE} -C nnjm $@
ifneq ($(strip ${TUNE_DECODE_VARIANTS}),)
	${RM} -r $(addprefix decode., ${TUNE_DECODE_VARIANTS})
	${RM} -r $(addprefix confidence., ${TUNE_DECODE_VARIANTS})
endif



########################################
# Resource Summary
.PHONY: time-mem
time-mem: SHELL=${LOCAL_SHELL}
time-mem:
	@time-mem-tally.pl `find -type f -name log.\* -o -name \*.log` \
	| second-to-hms.pl \
	| expand-auto.pl



################################################################################
# MINIMUM MANDATORY TARGETS.
.PHONY: models
models: SHELL=${LOCAL_SHELL}
models: lm mixlm tm


# NOTE: For lm, tm, we first trigger an update of the symbolic links to
# pre-trained models, if using pre-trained models. This is done before
# invoking the all target, so that make -j doesn't try to invoke these
# targets in parallel.

ifeq (${MAKELEVEL},0)
DO_UPDATE_PRETRAINED_LINKS ?= 1
endif


.PHONY: lm
# Create the Language Model (LM).
lm: SHELL=${LOCAL_SHELL}
lm: lm.${TGT_LANG}
lm.%: SHELL=${LOCAL_SHELL}
lm.%:
ifdef DO_UPDATE_PRETRAINED_LINKS
ifdef LM_PRETRAINED_TGT_LMS
	${MAKE} -C lm trigger.update.pretrained.links LM_LANG=$*
endif
endif
	${MAKE} -C lm all LM_LANG=$*



.PHONY: mixlm
# Create a mixture language model.
# NOTE: we make mixlm dependent on lm in case the lms inside the mixlm repeat
# some lms built in lm/.
mixlm: SHELL=${LOCAL_SHELL}
mixlm: lm
	${MAKE} -C $@ all


.PHONY: ibm
# Create Word Alignment Models (ibm).
ibm: SHELL=${LOCAL_SHELL}
ibm:
	${MAKE} -C $@ all


.PHONY: wal
# Create Word Alignment File (wal).
wal: SHELL=${LOCAL_SHELL}
wal:  ibm
	${MAKE} -C $@ all


.PHONY: jpt
# Create Joint frequency Phrase Tables (jpt).
jpt: SHELL=${LOCAL_SHELL}
jpt:  wal
	${MAKE} -C $@ all


.PHONY: sig
# Create Significance Pruned Joint frequency Phrase Tables (sig).
sig: SHELL=${LOCAL_SHELL}
sig:  jpt
	${MAKE} -C $@ all


.PHONY: tm
# Create the Translation Model (TM).
tm: SHELL=${LOCAL_SHELL}
tm:  sig
ifdef DO_UPDATE_PRETRAINED_LINKS
ifneq ($(strip ${TM_PRETRAINED_TMS} ${MIXTM_PRETRAINED_TMS}),)
	${MAKE} -C $@ trigger.update.pretrained.links
endif
endif
	${MAKE} -C $@ all



# Tuning targets don't need to depend on models when invoked from main Makefile
# because it first does "make -C models models"
ifeq (${MAKELEVEL},0)
MODELS_DEPENDENCY := models
endif

TUNE_VARIANTS := tune_variant $(addprefix tune_variant., ${TUNE_DECODE_VARIANTS})

.PHONY: tune
# Tune all the required models.
tune: SHELL=${LOCAL_SHELL}
tune: ${TUNE_VARIANTS}



.PHONY: ${TUNE_VARIANTS}
# Tune models for a variant (the main one (i.e. decode) or an alternate (e.g. decode.a).
${TUNE_VARIANTS}: SHELL=${LOCAL_SHELL}
${TUNE_VARIANTS}: tune_variant%: decode%



.PHONY: cow decode
# Run COW to tune the decoding model.
cow decode: SHELL=${LOCAL_SHELL}
cow: decode
decode: ${MODELS_DEPENDENCY}
	${MAKE} -C $@ all

# Tune multiple decoding variants, if necessary.
ifneq ($(strip ${TUNE_DECODE_VARIANTS}),)
.PHONY: $(addprefix cow., ${TUNE_DECODE_VARIANTS})
$(addprefix cow., ${TUNE_DECODE_VARIANTS}): SHELL=${LOCAL_SHELL}
$(addprefix cow., ${TUNE_DECODE_VARIANTS}): cow.% : decode.%

.PHONY: $(addprefix decode., ${TUNE_DECODE_VARIANTS})
$(addprefix decode., ${TUNE_DECODE_VARIANTS}): SHELL=${LOCAL_SHELL}
$(addprefix decode., ${TUNE_DECODE_VARIANTS}): decode.%: ${MODELS_DEPENDENCY}
	if [ ! -e $@ ]; then \
	   mkdir $@; \
	   cp -p decode/Makefile* decode/canoe.ini.template $@; \
	fi
	${MAKE} -C $@ all TUNE_DECODE=${TUNE_DECODE}$*
endif


.PHONY: rat rescore
# Run RAT to tune the rescoring model.
rat rescore: SHELL=${LOCAL_SHELL}
rat: rescore
rescore: decode
	${MAKE} -C $@ all



################################################################################
# Targets based on master Makefile.params
.PHONY: ldm
ldm: SHELL=${LOCAL_SHELL}
ifneq ("","${USE_LDM}${USE_HLDM}")
models: ldm

portageLive: portageLive_models_ldm
portageLive_models_decode${_PLIVE_DECODE_VARIANT}: portageLive_models_ldm

ldm:  ibm  wal
	${MAKE} -C $@ all
else
ldm:
	@echo "Not training a lexicalized distortion model." >&2
endif


.PHONY: sparse
sparse: SHELL=${LOCAL_SHELL}
ifdef USE_SPARSE
models: sparse

sparse: jpt
	${MAKE} -C $@ all
else
sparse:
	@echo "Not training a sparse model." >&2
endif


.PHONY: coarselm
coarselm: SHELL=${LOCAL_SHELL}
ifdef USE_COARSELM
models: coarselm

portageLive: portageLive_models_coarselm
portageLive_models_decode${_PLIVE_DECODE_VARIANT}: portageLive_models_coarselm

coarselm: wcl
	${MAKE} -C $@ all
else
coarselm:
	@echo "Not training coarse language models." >&2
endif


.PHONY:  nnjm
nnjm:  SHELL=${LOCAL_SHELL}
ifdef USE_PRETRAINED_NNIMS
models:  nnjm

PortageLive:  portageLive_models_nnjm
portageLive_models_decode${_PLIVE_DECODE_VARIANT}: portageLive_models_nnjm

nnjm:
	${MAKE} -C $@ all
else
nnjm:
	@echo "Not using pretrained nnjms." >&2
endif


.PHONY: bilm
bilm: SHELL=${LOCAL_SHELL}
ifdef USE_BILM
models: bilm

portageLive: portageLive_models_bilm
portageLive_models_decode${_PLIVE_DECODE_VARIANT}: portageLive_models_bilm

bilm: wcl wal
	${MAKE} -C $@ all
else
bilm:
	@echo "Not training BiLM models." >&2
endif


.PHONY: wcl
wcl: SHELL=${LOCAL_SHELL}
ifdef WCL_NCLS_LIST
models: wcl

portageLive: portageLive_models_wcl
portageLive_models_decode${_PLIVE_DECODE_VARIANT}: portageLive_models_wcl

wcl:
	${MAKE} -C $@ all
else
wcl:
	@echo "Not training word classes." >&2
endif


.PHONY: confidence
confidence: SHELL=${LOCAL_SHELL}
ifdef DO_CE
${TUNE_VARIANTS}: tune_variant%: confidence%
#tune: confidence $(addprefix confidence., ${TUNE_DECODE_VARIANTS})

models: lm.${SRC_LANG}

portageLive: portageLive_models_lm_src
portageLive: portageLive_models_confidence${_PLIVE_DECODE_VARIANT}

portageLive_models_confidence${_PLIVE_DECODE_VARIANT}: portageLive_models_lm_src
portageLive_models_confidence${_PLIVE_DECODE_VARIANT}: portageLive_models_decode${_PLIVE_DECODE_VARIANT}

# Note: The portageLive target in confidence/Makefile makes sure all TPLM files
# needed for confidence estimation are built and linked to the appropriate
# locations in portageLive/models, including the source TPLM.
# Thus, the portageLive_models_lm_src is redundant.
portageLive_models_lm_src: SHELL=${LOCAL_SHELL}
portageLive_models_lm_src:
	${MAKE} -C lm portageLive LM_LANG=${SRC_LANG}

# Note: decode depends on models (or models has been pre-built by the main
# makefile), and models depends on lm.${SRC_LANG} if DO_CE is set in addition
# to mixlm and lm.${TGT_LANG}, so confidence doesn't need to depend on
# any lm targets. It's good enough to depend on just decode.
confidence: decode
	${MAKE} -C $@ all

# Tune multiple confidence variants, if necessary.
ifneq ($(strip ${TUNE_DECODE_VARIANTS}),)
.PHONY: $(addprefix confidence., ${TUNE_DECODE_VARIANTS})
$(addprefix confidence., ${TUNE_DECODE_VARIANTS}): SHELL=${LOCAL_SHELL}
$(addprefix confidence., ${TUNE_DECODE_VARIANTS}): confidence.%: decode.%
	if [ ! -e $@ ]; then \
	   mkdir $@; \
	   cp -p confidence/Makefile* confidence/ce-notm.template $@; \
	fi
	${MAKE} -C $@ all DECODING_MODEL_DIR=models/decode.$*
endif
else
confidence:
	@echo "Not training a confidence estimation model." >&2
endif



.PHONY: tc
# Create models for truecasing (TC).
tc: SHELL=${LOCAL_SHELL}
ifdef DO_TRUECASING
models: tc

portageLive: portageLive_models_tc
portageLive/soap-translate.sh: portageLive_models_tc

tc:
	${MAKE} -C $@ all
else
tc:
	@echo "Not training the truecasing models." >&2
endif



ifdef DO_RESCORING
tune_variant: rescore		# tune_variant is the main variant
endif



########################################
# Prepare portageLive models.
.PHONY: portageLive
portageLive: portageLive_models_lm
portageLive: portageLive_models_mixlm
portageLive: portageLive_models_tm
portageLive: portageLive_models_decode${_PLIVE_DECODE_VARIANT}
portageLive: SHELL=${LOCAL_SHELL}
portageLive:
	ln -sf ../prime.sh $@
	pwd > $@/README
	portage_info >> $@/README

portageLive: portageLive/soap-translate.sh
portageLive/soap-translate.sh: SHELL=${LOCAL_SHELL}
portageLive/soap-translate.sh: portageLive_models_decode${_PLIVE_DECODE_VARIANT}
	mkdir -p $(dir $@)
	echo "#!/bin/bash" > $@
	cd $(dir $@) && echo "`../../translate.sh -n -nomode` -f=\`dirname \$$0\`/canoe.ini.cow" '"$$@"' >> $(notdir $@)
	chmod 755 $@

# We need this dependency since decode will copy the tplms for portageLive.
portageLive_models_decode${_PLIVE_DECODE_VARIANT}:  portageLive_models_lm  portageLive_models_mixlm  portageLive_models_tm

portageLive_models_%: SHELL=${LOCAL_SHELL}
portageLive_models_%:
	${MAKE} -C $* portageLive



.PHONY:  portageLive_fixedTerms
portageLive:  portageLive_fixedTerms
portageLive_fixedTerms:  SHELL=${LOCAL_SHELL}
portageLive_fixedTerms:  portageLive_plugins
portageLive_fixedTerms:
	prep-fixedTerms-layout.sh portageLive



PLUGINS := $(notdir $(wildcard ../plugins/*))
.PHONY:  portageLive_plugins
portageLive_plugins:  $(addprefix portageLive/plugins/, ${PLUGINS})

$(addprefix portageLive/plugins/, ${PLUGINS}):  SHELL=${LOCAL_SHELL}
$(addprefix portageLive/plugins/, ${PLUGINS}):  portageLive/plugins/%:
	mkdir -p $(dir $@)
	cd $(dir $@) && ln -fs ../../../plugins/$*



.PHONY: clean.portageLive
clean clean.content: clean.portageLive
clean.portageLive: SHELL=${LOCAL_SHELL}
clean.portageLive:
	${RM} -r portageLive








################################################################################
# TESTSUITE

.PHONY: testsuite

%.testcase:  export SHELL := bash

%.testcase:  export TRAIN_TM   := tm-train  TM
%.testcase:  export TRAIN_LDM  := ldm-train
%.testcase:  export TRAIN_HLDM := hldm-train

%.testcase:  export MERGED_CPT_ZN_MODEL := HMM1
%.testcase:  export MERGED_CPT_JPT_TYPES := IBM2 HMM3
%.testcase:  export MERGED_CPT_USE_ALIGNMENT_INDICATORS := 0

%.testcase:  export MIXTM           := subtm1 subtm2
%.testcase:  export MIXTM_TRAIN_MIX := mixtm_train_mix
%.testcase:  export TUNE_MIXTM      := tune_mixtm
%.testcase:  export MIXTM_USE_GLOBAL_WORD_ALIGNMENT_MODEL :=

%.testcase:  export USE_SIGPRUNING :=
%.testcase:  export USE_LDM :=
%.testcase:  export USE_HLDM := 1

%.testcase:  export USING_CLUSTER := 1
%.testcase:  export PARALLELISM_LEVEL_TM := 1

# Where MAKE_OPTS could be -t to only touch targets.
%.testcase:
	echo "TESTCASE:  $@"
	${MAKE} clean &> /dev/null
	mkdir -p tm/{mixtm,j2m,j2mr}
	#${MAKE} -j 11 ${TESTCASE_OPTS} ibm
	#${MAKE} -j 11 ${TESTCASE_OPTS} wal
	#${MAKE} -j 11 ${TESTCASE_OPTS} jpt
	#${MAKE} -j 11 ${TESTCASE_OPTS} sig
	time ${MAKE} -j 11 ${TESTCASE_OPTS} tm
	@echo "*******************************************************************"
	time ${MAKE} -j 11 ${TESTCASE_OPTS} ldm


testsuite:  fast_align.testcase
fast_align.testcase:  export PT_TYPES := fast_align_cpt


testsuite:  ibm4.testcase
ibm4.testcase:  export PT_TYPES := ibm4_cpt


testsuite:  ibm2.testcase
ibm2.testcase:  export PT_TYPES := ibm2_cpt

testsuite:  ibm2.sig.testcase
ibm2.sig.testcase:  export PT_TYPES := ibm2_cpt
ibm2.sig.testcase:  export USE_SIGPRUNING := 1


testsuite:  wams.testcase
wams.testcase:  export PT_TYPES := ibm1_cpt ibm2_cpt  hmm1_cpt hmm2_cpt hmm3_cpt

testsuite:  wams.sig.testcase
wams.sig.testcase:  export PT_TYPES := ibm1_cpt ibm2_cpt  hmm1_cpt hmm2_cpt hmm3_cpt
wams.sig.testcase:  export USE_SIGPRUNING := 1


testsuite:  pretrained.testcase
pretrained.testcase:  export PT_TYPES := pretrained_cpt


testsuite:  merged.testcase
merged.testcase:  export PT_TYPES := merged_cpt

testsuite:  merged.fa.testcase
merged.fa.testcase:  export PT_TYPES := merged_cpt
merged.fa.testcase:  export MERGED_CPT_JPT_TYPES := IBM2 HMM3 FAST_ALIGN
merged.fa.testcase:  export USE_MIXTM :=
merged.fa.testcase:  export MIXTM :=

testsuite:  merged.sig.testcase
merged.sig.testcase:  export PT_TYPES := merged_cpt
merged.sig.testcase:  export USE_SIGPRUNING := 1


tm/mixtm:
	mkdir -p $@
mix%testcase:  | tm/mixtm

testsuite:  mix.testcase
mix.testcase:  export PT_TYPES := mix_cpt

testsuite:  mix.sig.testcase
mix.sig.testcase:  export PT_TYPES := mix_cpt
mix.sig.testcase:  export USE_SIGPRUNING := 1

testsuite:  mixwam.testcase
mixwam.testcase:  export PT_TYPES := mix_cpt
mixwam.testcase:  export MIXTM_USE_GLOBAL_WORD_ALIGNMENT_MODEL := 1

testsuite:  mixwam.sig.testcase
mixwam.sig.testcase:  export PT_TYPES := mix_cpt
mixwam.sig.testcase:  export MIXTM_USE_GLOBAL_WORD_ALIGNMENT_MODEL := 1
mixwam.sig.testcase:  export USE_SIGPRUNING := 1


tm/j2m  tm/j2mr:
	mkdir -p $@
indicator%testcase:  | tm/j2m  tm/j2mr

testsuite:  indicator.testcase
indicator.testcase:  export PT_TYPES := indicator_cpt

testsuite:  indicator.sig.testcase
indicator.sig.testcase:  export PT_TYPES := indicator_cpt
indicator.sig.testcase:  export USE_SIGPRUNING := 1


testsuite:  bilm.testcase
bilm.testcase:  export BILM_SPEC := 40bi-40s-40t
bilm.testcase:  export PT_TYPES := merged_cpt
bilm.testcase:  export USE_HLDM :=
bilm.testcase:  export TRAIN_BILM := bilm-train
bilm.testcase:
	echo "TESTCASE:  $@"
	${MAKE} clean &> /dev/null
	mkdir -p tm/{mixtm,j2m,j2mr}
	time ${MAKE} -j 11 ${TESTCASE_OPTS} bilm



testsuite:  tune_with_tplms.testcase
tune_with_tplms.testcase:  export TRAIN_LM := lm-train sublm3
tune_with_tplms.testcase:  export MIXLM := sublm1 sublm2 sublm3 lm-train
tune_with_tplms.testcase:  export MIXLM_PRETRAINED_TGT_LMS := /home/models/generic-model/v1.0/dvd_v1.0/lm/generic1.0_fr.tplm
tune_with_tplms.testcase:  export TRAIN_COARSELM := coarselm-train
tune_with_tplms.testcase:  export TRAIN_BILM := bilm-train
tune_with_tplms.testcase:  export COARSELM_NCLS_LIST := 200 800
tune_with_tplms.testcase:  export BILM_SPEC := 400bi-400s-400t
tune_with_tplms.testcase:  export MERT_MAX_ITER := 3
tune_with_tplms.testcase:  export USE_HLDM :=
tune_with_tplms.testcase:
	echo "TESTCASE:  $@"
	${MAKE} clean &> /dev/null
	mkdir -p tm/{mixtm,j2m,j2mr}
	time ${MAKE} -j 11 ${TESTCASE_OPTS} wcl lm bilm coarselm mixlm ibm wal jpt tm
	time ${MAKE} -j 11 ${TESTCASE_OPTS} decode

