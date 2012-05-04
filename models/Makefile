#!/usr/bin/make -f
# vim:noet:ts=3:nowrap
# $Id$

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
all: SHELL=${GUARD_SHELL}
all: tune



########################################
# HELP MESSAGE.
.PHONY: help
help: SHELL=${GUARD_SHELL}
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
	@echo "   train tm: ${TRAIN_TM}"
	@echo "   tune decode: ${TUNE_DECODE}"
ifneq ($(strip ${TUNE_DECODE_VARIANTS}),)
	@echo "   tune decode variants: (addprefix ${TUNE_DECODE}, ${TUNE_DECODE_VARIANTS})"
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
clean: SHELL=${GUARD_SHELL}
clean: clean.content clean.logs

# Thorough cleaning of everything
# hide.logs hides logs from user's view into .logs
clean.content clean.logs hide.logs: SHELL=${GUARD_SHELL}
clean.content clean.logs hide.logs: %:
	${MAKE} -C ldm $@
	${MAKE} -C lm $@
	${MAKE} -C tm $@
	${MAKE} -C tc $@
	${MAKE} -C decode $@
	${MAKE} -C rescore $@
	${MAKE} -C confidence $@
	${MAKE} -C mixlm $@
ifneq ($(strip ${TUNE_DECODE_VARIANTS}),)
	${RM} -r $(addprefix decode., ${TUNE_DECODE_VARIANTS})
	${RM} -r $(addprefix confidence., ${TUNE_DECODE_VARIANTS})
endif



########################################
# Resource Summary
.PHONY: time-mem
time-mem: SHELL=${GUARD_SHELL}
time-mem:
	@time-mem-tally.pl `find ldm lm mixlm tm tc decode* rescore confidence* -type f -name log.\*` \
	| second-to-hms.pl \
	| expand-auto.pl



################################################################################
# MINIMUM MANDATORY TARGETS.
.PHONY: models
models: SHELL=${GUARD_SHELL}
models: lm mixlm tm



.PHONY: lm
# Create the Language Model (LM).
lm: SHELL=${GUARD_SHELL}
lm: lm.${TGT_LANG}
lm.%: SHELL=${GUARD_SHELL}
lm.%:
	${MAKE} -C lm all LM_LANG=$*



.PHONY: mixlm
# Create mixture language model.
# NOTE: we make mixlm dependent on lm in case the lms inside the mixlm repeat
# some lms built in lm/.
mixlm: SHELL=${GUARD_SHELL}
mixlm: lm
	${MAKE} -C $@ all



.PHONY: tm
# Create the Translation Model (TM).
tm: SHELL=${GUARD_SHELL}
tm:
	${MAKE} -C $@ all



# Tuning targets don't need to depend on models when invoked from main Makefile
# because it first does "make -C models models"
ifeq (${MAKELEVEL},0)
MODELS_DEPENDENCY := models
endif

TUNE_VARIANTS := tune_variant $(addprefix tune_variant., ${TUNE_DECODE_VARIANTS})

.PHONY: tune
# Tune all the required models.
tune: SHELL=${GUARD_SHELL}
tune: ${TUNE_VARIANTS}



.PHONY: ${TUNE_VARIANTS}
# Tune models for a variant (the main one (i.e. decode) or an alternate (e.g. decode.a).
${TUNE_VARIANTS}: SHELL=${GUARD_SHELL}
${TUNE_VARIANTS}: tune_variant%: decode%



.PHONY: cow decode
# Run COW to tune the decoding model.
cow decode: SHELL=${GUARD_SHELL}
cow: decode
decode: ${MODELS_DEPENDENCY}
	${MAKE} -C $@ all

# Tune multiple decoding variants, if necessary.
ifneq ($(strip ${TUNE_DECODE_VARIANTS}),)
.PHONY: $(addprefix cow., ${TUNE_DECODE_VARIANTS})
$(addprefix cow., ${TUNE_DECODE_VARIANTS}): SHELL=${GUARD_SHELL}
$(addprefix cow., ${TUNE_DECODE_VARIANTS}): cow.% : decode.%

.PHONY: $(addprefix decode., ${TUNE_DECODE_VARIANTS})
$(addprefix decode., ${TUNE_DECODE_VARIANTS}): SHELL=${GUARD_SHELL}
$(addprefix decode., ${TUNE_DECODE_VARIANTS}): decode.%: ${MODELS_DEPENDENCY}
	if [ ! -e $@ ]; then \
	   mkdir $@; \
	   cp -p decode/Makefile* decode/canoe.ini.template $@; \
	fi
	${MAKE} -C $@ all TUNE_DECODE=${TUNE_DECODE}$*
endif


.PHONY: rat rescore
# Run RAT to tune the rescoring model.
rat rescore: SHELL=${GUARD_SHELL}
rat: rescore
rescore: decode
	${MAKE} -C $@ all



################################################################################
# Targets based on master Makefile.params
.PHONY: ldm
ldm: SHELL=${GUARD_SHELL}
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



.PHONY: confidence
confidence: SHELL=${GUARD_SHELL}
ifdef DO_CE
${TUNE_VARIANTS}: tune_variant%: confidence%
#tune: confidence $(addprefix confidence., ${TUNE_DECODE_VARIANTS})

models: lm.${SRC_LANG}

portageLive: portageLive_models_lm_src
portageLive: portageLive_models_confidence${_PLIVE_DECODE_VARIANT}

portageLive_models_confidence${_PLIVE_DECODE_VARIANT}: portageLive_models_lm_src
portageLive_models_confidence${_PLIVE_DECODE_VARIANT}: portageLive_models_decode${_PLIVE_DECODE_VARIANT}

portageLive_models_lm_src: SHELL=${GUARD_SHELL}
portageLive_models_lm_src:
	${MAKE} -C lm portageLive LM_LANG=${SRC_LANG}

confidence: lm.${SRC_LANG} decode
	${MAKE} -C $@ all

# Tune multiple confidence variants, if necessary.
ifneq ($(strip ${TUNE_DECODE_VARIANTS}),)
.PHONY: $(addprefix confidence., ${TUNE_DECODE_VARIANTS})
$(addprefix confidence., ${TUNE_DECODE_VARIANTS}): SHELL=${GUARD_SHELL}
$(addprefix confidence., ${TUNE_DECODE_VARIANTS}): confidence.%: lm.${SRC_LANG} decode.%
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
tc: SHELL=${GUARD_SHELL}
ifdef DO_TRUECASING
models: tc

portageLive: portageLive_models_tc

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
portageLive: SHELL=${GUARD_SHELL}
portageLive:
	ln -sf ../prime.sh $@
	pwd > $@/README
	portage_info >> $@/README

portageLive: portageLive/soap-translate.sh
portageLive/soap-translate.sh: SHELL=${GUARD_SHELL}
portageLive/soap-translate.sh: portageLive_models_decode${_PLIVE_DECODE_VARIANT}
	mkdir -p $(dir $@)
	echo "#!/bin/bash" > $@
	cd $(dir $@) && echo "`../../translate.sh -n $(and ${DO_RESCORING}, -with-rescoring)` -f=\`dirname \$$0\`/canoe.ini.cow" >> $(notdir $@)
	chmod 755 $@

# We need this dependency since decode will copy the tplms for portageLive.
portageLive_models_decode${_PLIVE_DECODE_VARIANT}: portageLive_models_lm portageLive_models_tm

portageLive_models_%: SHELL=${GUARD_SHELL}
portageLive_models_%:
	${MAKE} -C $* portageLive

ifneq ("$(wildcard ../plugins)","")
portageLive: portageLive/plugins
portageLive/plugins: SHELL=${GUARD_SHELL}
portageLive/plugins:
	ln -fs ../../plugins $@
endif

.PHONY: clean.portageLive
clean clean.content: clean.portageLive
clean.portageLive: SHELL=${GUARD_SHELL}
clean.portageLive:
	${RM} -r portageLive
