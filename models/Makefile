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
	@echo "Your corpora are:"
	@echo "   train lm: ${TRAIN_LM}"
ifneq ($(strip ${MIXLM}),)
	@echo "   train mixlm: ${MIXLM}"
endif
ifneq ($(strip ${TRAIN_TC}),)
	@echo "   train tc: ${TRAIN_TC}"
endif
	@echo "   train tm: ${TRAIN_TM}"
ifneq ($(strip ${MIXTM}),)
	@echo "   train mixtm: ${MIXTM}"
endif
ifneq ($(strip ${MIXTM_TRAIN_MIX}),)
	@echo "   tune mixtm mix: ${MIXTM_TRAIN_MIX}"
endif
ifneq ($(strip ${TRAIN_LDM}),)
	@echo "   train ldm: ${TRAIN_LDM}"
endif
ifneq ($(strip ${TRAIN_HLDM}),)
	@echo "   train hldm: ${TRAIN_HLDM}"
endif
ifneq ($(strip ${TRAIN_SPARSE}),)
	@echo "   train sparse: ${TRAIN_SPARSE}"
endif
	@echo "   tune decode: ${TUNE_DECODE}"
ifneq ($(strip ${TUNE_DECODE_VARIANTS}),)
	@echo "   tune decode variants: $(addprefix ${TUNE_DECODE}, ${TUNE_DECODE_VARIANTS})"
endif
	@echo "   tune rescore: ${TUNE_RESCORE}"
ifneq ($(strip ${TUNE_CE}),)
	@echo "   tune ce: ${TUNE_CE}"
endif
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
	${MAKE} -C tm $@
	${MAKE} -C tc $@
	${MAKE} -C decode $@
	${MAKE} -C rescore $@
	${MAKE} -C confidence $@
	${MAKE} -C mixlm $@
	${MAKE} -C sparse $@
ifneq ($(strip ${TUNE_DECODE_VARIANTS}),)
	${RM} -r $(addprefix decode., ${TUNE_DECODE_VARIANTS})
	${RM} -r $(addprefix confidence., ${TUNE_DECODE_VARIANTS})
endif



########################################
# Resource Summary
.PHONY: time-mem
time-mem: SHELL=${LOCAL_SHELL}
time-mem:
	@time-mem-tally.pl `find ldm lm mixlm tm sparse tc decode* rescore confidence* -type f -name log.\* -o -name \*.log` \
	| second-to-hms.pl \
	| expand-auto.pl



################################################################################
# MINIMUM MANDATORY TARGETS.
.PHONY: models
models: SHELL=${LOCAL_SHELL}
models: lm mixlm tm


# NOTE: For lm, mixlm, tm, we first trigger an update of the symbolic links to 
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
ifdef DO_UPDATE_PRETRAINED_LINKS
ifdef MIXLM_PRETRAINED_TGT_LMS
	${MAKE} -C $@ trigger.update.pretrained.links
endif
endif
	${MAKE} -C $@ all


.PHONY: tm
# Create the Translation Model (TM).
tm: SHELL=${LOCAL_SHELL}
tm:
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

ldm: tm
	${MAKE} -C $@ all
else
ldm:
	@echo "Not training a lexicalized distortion model." >&2
endif


.PHONY: sparse
sparse: SHELL=${LOCAL_SHELL}
ifdef USE_SPARSE
models: sparse

sparse: tm
	${MAKE} -C $@ all
else
sparse:
	@echo "Not training a sparse model." >&2
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
portageLive_models_decode${_PLIVE_DECODE_VARIANT}: portageLive_models_lm portageLive_models_mixlm portageLive_models_tm

portageLive_models_%: SHELL=${LOCAL_SHELL}
portageLive_models_%:
	${MAKE} -C $* portageLive

ifneq ("$(wildcard ../plugins)","")
portageLive: portageLive/plugins
portageLive/plugins: SHELL=${LOCAL_SHELL}
portageLive/plugins:
	ln -fs ../../plugins $@
endif

.PHONY: clean.portageLive
clean clean.content: clean.portageLive
clean.portageLive: SHELL=${LOCAL_SHELL}
clean.portageLive:
	${RM} -r portageLive
