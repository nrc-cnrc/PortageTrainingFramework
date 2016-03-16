#!/usr/bin/make -f
# vim:noet:ts=3:nowrap

# @file Makefile
# @brief Logic/dependencies needed to tune a confidence estimation model.
#
# @author Samuel Larkin
#
# Technologies langagieres interactives / Interactive Language Technologies
# Inst. de technologie de l'information / Institute for Information Technology
# Conseil national de recherches Canada / National Research Council Canada
# Copyright 2010, Sa Majeste la Reine du Chef du Canada /
# Copyright 2010, Her Majesty in Right of Canada

# Mandatory include: master config file.
include ../../Makefile.params

# Include and override parameters with user specific config file.
MAKEFILE_PARAMS ?= Makefile.params
-include ${MAKEFILE_PARAMS}

# Include the master toolkit.
include ../../Makefile.toolkit

# Include variable definitions needed for building the CE model.
include Makefile.definition

# Include the CE toolkit.
include Makefile.toolkit

# What is this module's name.
MODULE_NAME ?= confidence

# Confidence Estimation model's name.
CE_MODEL_NAME ?= ce_model

########################################
# SETUP
ifneq (${MAKECMDGOALS},clean)
ifneq (${MAKECMDGOALS},clean.content)
ifneq (${MAKECMDGOALS},clean.logs)
$(info ln -fs ${MODEL_DIR})
$(shell ln -fs ${MODEL_DIR})
endif
endif
endif

# Make sure the user set up this framework to generate proper models for
# Confidence Estimation.
ifndef DO_CE
$(warning You must set DO_CE in Makefile.params, or some required models will not be built automatically.)
endif


.DEFAULT_GOAL := help
.SECONDARY:
.SUFFIXES:
.DELETE_ON_ERROR:

.PHONY: all
all: train


.PHONY: help
help: SHELL=${LOCAL_SHELL}
help:
	@echo "Tune a Confidence Estimation Model."
	@echo
	@echo "To tune your CE model, type: make all"
	@echo
	@echo "The main targets in this Makefile are:"
	@cat $(firstword $(MAKEFILE_LIST)) | egrep '^.PHONY:' | sed 's#^.PHONY: #   #'


########################################
# Clean up
.PHONY: clean clean.content clean.logs hide.logs
clean: SHELL=${LOCAL_SHELL}
clean: clean.content clean.logs

clean.content: SHELL=${LOCAL_SHELL}
clean.content:
	${RM} canoe.ini.cow *${CEMX} ce-notm.ini models
	${RM} -r ${CE_WORKDIR_PRX}*

clean.logs: SHELL=${LOCAL_SHELL}
clean.logs:
	${RM} -r run-parallel* log.*

# Hide logs from user's view into .logs
hide.logs: SHELL=${LOCAL_SHELL}
hide.logs: hide_logs_sub


########################################
# Resources Summary
.PHONY: time-mem
time-mem: SHELL=${LOCAL_SHELL}
time-mem: resource_summary_sub


########################################
# DECODING MODEL.
VARIANT ?= $(suffix ${DECODING_MODEL_DIR})

${CANOE_MODEL}: SHELL=${LOCAL_SHELL}
${CANOE_MODEL}:
	@[[ -f "${DECODING_MODEL_DIR}/${CANOE_MODEL}" ]] \
	|| ! echo "ERROR: No decoding model (${CANOE_MODEL}) available. Please train ${DECODING_MODEL_DIR} first!" >&2
	#sed -e 's#${TUNE_DECODE}${VARIANT}.mixlm#${TUNE_CE}.mixlm#g' ${DECODING_MODEL_DIR}/${CANOE_MODEL} > $@
	sed -e 's#${TUNE_DECODE}${VARIANT}.mixlm#${TUNE_DECODE}${VARIANT}.mixlm#g' ${DECODING_MODEL_DIR}/${CANOE_MODEL} > $@
	configtool check $@


########################################
# Sparse models need tuned weights
ifdef USE_SPARSE
# Tune sparse weights have to be copied/linked from models/decode
# This is an ugly solution, but it works.
${CANOE_MODEL}: ln_sparse_wts
.INTERMEDIATE: ln_sparse_wts
ln_sparse_wts: SHELL=${LOCAL_SHELL}
ln_sparse_wts:
	ln -fs ${DECODING_MODEL_DIR}/rmodels_sparse*.wts.gz .
endif

clean.content: clean.sparse
clean.sparse: SHELL=${LOCAL_SHELL}
clean.sparse:
	${RM} rmodels_sparse*.wts.gz


########################################
# Creating the initial model from the template.
ce-notm${INIX}: ce-notm${TEMPLATEX} ${CANOE_MODEL}


########################################
# Tuning a confidence model.
.PHONY: train
train: ${CE_MODEL_NAME}${CEMX}

${CE_MODEL_NAME}${CEMX}: ce-notm${INIX} ${TUNE_CE_SRC} ${TUNE_CE_TGT}


########################################
# Prepare what is needed for portageLive
.PHONY: portageLive
ifdef DO_CE
portageLive: SHELL=${LOCAL_SHELL}
portageLive: ${CE_MODEL_NAME}${CEMX}
	mkdir -p ../portageLive
	mkdir -p tmp.live && tar -C tmp.live -zxvf $<
	sed -i -e 's/binlm.gz/tplm/' tmp.live/model
	MODELS=(`egrep -o '[^/]+\.tplm' tmp.live/model | tr "\n" " "`); \
	if [[ $$MODELS ]]; then \
		${MAKE} -C ../../${LM_DIR} -f ../lm/Makefile $${MODELS[@]}; \
		mkdir -p ../portageLive/${LM_DIR}; \
		MODELS=($${MODELS[@]/#/$(subst /,\/,../../../../${LM_DIR}/)}); \
		echo "LM files:" $${MODELS[@]} >&2; \
		cd ../portageLive/${LM_DIR} && ln -fs $${MODELS[@]} .; \
	fi
	MODELS=(`egrep -o '[^/]+.(${TGT_LANG}_given_${SRC_LANG}|${SRC_LANG}_given_${TGT_LANG}).gz' tmp.live/model | tr "\n" " "`); \
	if [[ $$MODELS ]]; then \
		MODELS=($${MODELS[@]/%.gz/*}); \
		MODELS=($${MODELS[@]/#/$(subst /,\/,../../../../${IBM_DIR}/)}); \
		echo "TM files:" $${MODELS[@]} >&2; \
		mkdir -p ../portageLive/${IBM_DIR}; \
		cd ../portageLive/${IBM_DIR} && ln -fs $${MODELS[@]} .; \
	fi
	sed -i -e 's/tm\/mixtm/tm/' tmp.live/model
	cd tmp.live && tar zcf ../../portageLive/$< *
	rm -r tmp.live
else
portageLive:
	$(error ERROR: the portageLive target should not be called when DO_CE is not set.)
endif







################################################################################
# TESTSUITE
.PHONY:  testsuite

################################################################################
# UNITTESTS

.PHONY:  mixtm_1wam_ce_testcase
testsuite:  mixtm_1wam_ce_testcase
mixtm_1wam_ce_testcase:  export SRC_LANG := fr
mixtm_1wam_ce_testcase:  export TGT_LANG := en
mixtm_1wam_ce_testcase:  export MIXTM := tm-train1 tm-train2
mixtm_1wam_ce_testcase:  export TUNE_CE := dev3
mixtm_1wam_ce_testcase:  export DO_CE := 1
mixtm_1wam_ce_testcase:  export MIXTM_USE_GLOBAL_WORD_ALIGNMENT_MODEL := 1
mixtm_1wam_ce_testcase:  export MERGED_CPT_JPT_TYPES := IBM2 HMM3
mixtm_1wam_ce_testcase:  export MERT_MAX_ITER := 3
mixtm_1wam_ce_testcase:  export INIX := .mixtm_1wam_ce_testcase
mixtm_1wam_ce_testcase:
	touch canoe.ini.cow
	${MAKE} ce-notm${INIX}
	[[ -s ce-notm${INIX} ]] || ! echo "ERROR: Was unable to instanciate a CE template." >&2
	[[ `grep -c mixwam ce-notm${INIX}` -eq 8 ]] || ! echo "ERROR: CE model should be using IBM mixwam." >&2

.PHONY:  mixtm_ce_testcase
testsuite:  mixtm_ce_testcase
mixtm_ce_testcase:  export SRC_LANG := fr
mixtm_ce_testcase:  export TGT_LANG := en
mixtm_ce_testcase:  export MIXTM := tm-train1 tm-train2
mixtm_ce_testcase:  export TUNE_CE := dev3
mixtm_ce_testcase:  export DO_CE := 1
mixtm_ce_testcase:  export MIXTM_USE_GLOBAL_WORD_ALIGNMENT_MODEL :=
mixtm_ce_testcase:  export MERGED_CPT_JPT_TYPES := IBM2 HMM3
mixtm_ce_testcase:  export MERT_MAX_ITER := 3
mixtm_ce_testcase:  export INIX := .mixtm_ce_testcase
mixtm_ce_testcase:
	touch canoe.ini.cow
	${MAKE} ce-notm${INIX}
	[[ -s ce-notm${INIX} ]] || ! echo "ERROR: Was unable to instanciate a CE template." >&2
	[[ `grep -c tm-train ce-notm${INIX}` -eq 8 ]] || ! echo "ERROR: CE model should be using IBM tm-train." >&2

.PHONY:  1wam_ce_testcase
testsuite:  1wam_ce_testcase
1wam_ce_testcase:  export SRC_LANG := fr
1wam_ce_testcase:  export TGT_LANG := en
1wam_ce_testcase:  export TRAIN_TM := tm-train1 tm-train2 tm-train3
1wam_ce_testcase:  export MIXTM :=
1wam_ce_testcase:  export TUNE_CE := dev3
1wam_ce_testcase:  export DO_CE := 1
1wam_ce_testcase:  export MIXTM_USE_GLOBAL_WORD_ALIGNMENT_MODEL := 1
1wam_ce_testcase:  export MERGED_CPT_JPT_TYPES := IBM2 HMM3
1wam_ce_testcase:  export INIX := .1wam_ce_testcase
1wam_ce_testcase:
	touch canoe.ini.cow
	${MAKE} ce-notm${INIX}
	[[ -s ce-notm${INIX} ]] || ! echo "ERROR: Was unable to instanciate a CE template." >&2
	[[ `grep -c 'tm-train1' ce-notm${INIX}` -eq 8 ]] || ! echo "ERROR: CE model should be using IBM tm-train1." >&2
