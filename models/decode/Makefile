#!/usr/bin/make -f
# vim:noet:ts=3:nowrap
#
# @author Samuel Larkin
# @file Makefile
# @brief Tunes/trains a decoding model.
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
MODULE_NAME ?= decode

# Define languages info.
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

# If you need to add any other options to MERT.
MERT_EXTRAS ?=

# Track memory usage.
TIME_MEM ?= time-mem

# After this Makefile, the following targets/files are precious.
FILES_TO_BE_LOCKED = ${DECODING_MODEL}

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



.DEFAULT_GOAL := help
.SECONDARY:
.DELETE_ON_ERROR:

# Threre are two differents vpath for heldout because in the chinese case for example the src_ext != tgt_ext
vpath %${SRCX}   ${CORPORA_DIR}
vpath %${TGTX}   ${CORPORA_DIR}
vpath %${LANGX}  ${CORPORA_DIR}
vpath %${RULES}  ${CORPORA_DIR}
vpath ${DECODING_MODEL_TEMPLATE} ${TEMPLATE_DIR}



.PHONY: all
all: train



.PHONY: help
help: SHELL=${LOCAL_SHELL}
help:
	@echo "Tune a system."
	@echo
	@echo "To tune your models, type: make all"
	@echo
	@echo "The main targets in this Makefile are:"
	@cat $(firstword $(MAKEFILE_LIST)) | egrep '^.PHONY:' | sed 's#^.PHONY: #   #'



# What the user can expect from this module.
.PHONY: list_final_output
list_final_output: SHELL=${LOCAL_SHELL}
list_final_output:
	@echo "Expected final output:"
	@echo "${DECODING_MODEL}"



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
ifeq ("","$(or $(strip ${LDM}),$(findstring clean,${MAKECMDGOALS}))")
$(warning No LDMs available. Have you trained at least a distortion model?)
endif
$(info LDM: ${LDM})
LDM := $(and ${USE_LDM},${LDM}\#L)

# Parameters to use Lexicalized Distortion Models.
LDM_PARAMS  := back-lex\#m\#L:back-lex\#s\#L:back-lex\#d\#L:fwd-lex\#m\#L:fwd-lex\#s\#L:fwd-lex\#d\#L
endif

ifdef USE_HLDM
HLDM ?= $(wildcard models/ldm/hldm.*.${SRC_LANG}2${TGT_LANG}.gz)
ifeq ("","$(or $(strip ${HLDM}),$(findstring clean,${MAKECMDGOALS}))")
$(warning No HLDMs available. Have you trained at least a distortion model?)
endif
$(info HLDM: ${HLDM})
HLDM := $(and ${USE_HLDM},${HLDM}\#H)

# Parameters to use Hierarchical Lexicalized Distortion Models.
HLDM_PARAMS := back-hlex\#m\#H:back-hlex\#s\#H:back-hlex\#d\#H:fwd-hlex\#m\#H:fwd-hlex\#s\#H:fwd-hlex\#d\#H
endif

ifdef USE_SPARSE
SPARSE ?= models/sparse/model
$(info Sparse: ${SPARSE})
endif

# NOTE: We need to keep the checks here AND in the target UNTUNED_DECODING_MODEL.
CPT_SEARCH := models/tm/cpt.*${SRC_LANG}2${TGT_LANG}.gz
CPTS ?= $(wildcard ${CPT_SEARCH})
ifeq ("","$(or $(strip ${CPTS}),$(findstring clean,${MAKECMDGOALS}))")
$(warning No CPTs available. Have you trained at least one translation model?)
endif
$(info CPTs: ${CPTS})

LM_SEARCH := models/lm/*_${TGT_LANG}[-.]*binlm.gz models/mixlm/${TUNE_DECODE}.mixlm
LMS  ?= $(wildcard ${LM_SEARCH})
ifeq ("","$(or $(strip ${LMS}),$(findstring clean,${MAKECMDGOALS}))")
$(warning No LMs available. Have you trained at least one language model?)
endif
$(info LMs: ${LMS})

COARSE_LM_SEARCH ?= models/coarselm/*_${TGT_LANG}-${n}[-.]*binlm.gz
COARSE_LM_SPECS ?= $(foreach n, ${COARSELM_NCLS_LIST}, \
                      $(foreach lm, $(wildcard ${COARSE_LM_SEARCH}), \
                         DynMap;wordClasses-models/wcl/${TGT_LANG}.${n}.classes;${lm} \
                      ) \
                   )
$(info Coarse LMs: ${COARSE_LM_SPECS})

define BILM_SPECS_PYSCRIPT
from __future__ import print_function, unicode_literals, division, absolute_import
import re
import glob

src_lang = "${SRC_LANG}"
tgt_lang = "${TGT_LANG}"
lm_lang = "${SRC_LANG}2${TGT_LANG}"

spec_re = re.compile("(?:-([0-9]+)bi)?(?:-([0-9]+)s)?(?:-([0-9]+)t)?_" + lm_lang)

specs=[]
for bilm in glob.iglob("models/bilm/*_{0}-*.binlm.gz".format(lm_lang)):
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
	      -e 's/^\(\[\(weight-f\|ftm\)\]\)/##mid##\1/' \
	| configtool -p "args: \
	      $(and ${USE_LDM}${USE_HLDM}, -dist-phrase-swap) \
	      -distortion-model WordDisplacement:${LDM_PARAMS}:${HLDM_PARAMS}:${DM_EXTRAS} \
	      -lex-dist-model-file ${LDM}:${HLDM} \
	      $(if ${BILM_SPEC}, -bilm-file ${BILM_SPECS}) \
	      $(and ${USE_SPARSE}, -sparse-model ${SPARSE}) \
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


.PHONY: portageLive_models
portageLive_models_%: SHELL=${LOCAL_SHELL}
portageLive_models_%:
	${MAKE} -C ../$* portageLive


${CANOE_LIVE}: SHELL=${LOCAL_SHELL}
${CANOE_LIVE}: portageLive_models_lm portageLive_models_tm portageLive_models_ldm
${CANOE_LIVE}: ${DECODING_MODEL}
	mkdir -p ${PORTAGE_LIVE_DEST_DIR}
	configtool -p tp $< > $@
	configtool check $@


clean.content: clean.portageLive
.PHONY: clean.portageLive
clean.portageLive: SHELL=${LOCAL_SHELL}
clean.portageLive:
	${RM} ${CANOE_LIVE}

ifdef USE_SPARSE
SPARSE_WTS ?= rmodels_sparse_model.wts.gz
SPARSE_WTS_LIVE ?= ${PORTAGE_LIVE_DEST_DIR}/${SPARSE_WTS}
${CANOE_LIVE}: ${SPARSE_WTS_LIVE} portageLive_models_sparse
${SPARSE_WTS_LIVE}: SHELL=${LOCAL_SHELL}
${SPARSE_WTS_LIVE}:
	mkdir -p ${PORTAGE_LIVE_DEST_DIR}
	ln -s ../decode/${SPARSE_WTS} $@

clean.portageLive: clean.sparseWtsLive
clean.sparseWtsLive: SHELL=${LOCAL_SHELL}
clean.sparseWtsLive:
	${RM} ${SPARSE_WTS_LIVE}
endif


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

