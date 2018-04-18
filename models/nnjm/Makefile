#!/usr/bin/make -f
# vim:noet:ts=3:nowrap

# @file Makefile
# @brief Tune/train an NNJM model.
#
# @author Samuel Larkin
#
# Traitement multilingue de textes / Multilingual Text Processing
# Tech. de l'information et des communications / Information and Communications Tech.
# Conseil national de recherches Canada / National Research Council Canada
# Copyright 2017, Sa Majeste la Reine du Chef du Canada
# Copyright 2017, Her Majesty in Right of Canada

NNJM_DIR_PFX := $(dir $(lastword ${MAKEFILE_LIST}))
#$(info NNJM_DIR_PFX: ${NNJM_DIR_PFX})

# Mandatory include: master config file.
include ${NNJM_DIR_PFX}../../Makefile.params

# Include and override parameters with user specific config file.
MAKEFILE_PARAMS ?= Makefile.params
-include ${NNJM_DIR_PFX}${MAKEFILE_PARAMS}

# We assume the top level Makefile.params has already been included.
include ${NNJM_DIR_PFX}../Makefile.definition

# Include the master toolkit.
include ${NNJM_DIR_PFX}../../Makefile.toolkit

# What is this module's name.
MODULE_NAME ?= nnjm

# Where we need to deploy the NNJM models to create a portageLive system.
PORTAGE_LIVE_DEST_DIR ?= ../portageLive/models/nnjm

NNJM_PRETRAINED_NNJM_FIXED := $(foreach f, ${NNJM_PRETRAINED_NNJM}, $(call FIX_RELATIVE_PATH, ${NNJM_DIR_PFX}../../, $f))

NNJM_NCLS ?= 400

# NNJM trained model
NNJM_DEV_CORPUS ?= ${TUNE_DECODE}
NNJM_TEST_CORPUS ?=
#NNJM_TRAIN_CORPUS ?= ${TRAIN_TM}

# NNJM fine tuning
NNJM_FINE_TUNING_DEV_CORPUS ?= ${NNJM_DEV_CORPUS}
NNJM_FINE_TUNING_TEST_CORPUS ?= ${NNJM_TEST_CORPUS}
NNJM_FINE_TUNING_TRAIN_CORPUS ?=
NNJM_FINE_TUNING_PRETRAINED_MODEL ?= trained/nnjm

# If no NNJM_WAM_TYPE is provided will automatically get the best model that
# was provided in MERGED_CPT_JPT_TYPES.
$(info Using wam_type: ${NNJM_WAM_TYPE})

NNJM_TRAIN_NNJM_OPTS ?=
NNJM_TRAIN_NNJM_OPTS := $(and ${NNJM_TRAIN_NNJM_OPTS}, -train-nnjm-opts "${NNJM_TRAIN_NNJM_OPTS}")
NNJM_GENEX_OPTS ?=
NNJM_GENEX_OPTS := $(and ${NNJM_GENEX_OPTS}, -nnjm-genex-opts "${NNJM_GENEX_OPTS}")


CORPORA_DIR := ${NNJM_DIR_PFX}/../../corpora
WAL_DIR := ${NNJM_DIR_PFX}/../wal
WCL_DIR := ${NNJM_DIR_PFX}/../wcl

CLS_X := .mmcls

vpath %${L1}  ${CORPORA_DIR}
vpath %${L2}  ${CORPORA_DIR}
vpath %${L1X}  ${CORPORA_DIR}
vpath %${L2X}  ${CORPORA_DIR}
vpath %.classes  ${WCL_DIR}
vpath %.mmcls  ${WCL_DIR}
vpath %.align  ${WAL_DIR}
vpath %.align.gz  ${WAL_DIR}
vpath %/${SRC_LANG}.lc    ${WAL_DIR_PFX}../ibm/  ${WAL_DIR_PFX}../wal/
vpath %/${TGT_LANG}.lc    ${WAL_DIR_PFX}../ibm/  ${WAL_DIR_PFX}../wal/


.DEFAULT_GOAL := help
.SUFFIXES:
.DELETE_ON_ERROR:


MAIN_TARGETS :=  all clean help

########################################
.PHONY: help
help: SHELL=${LOCAL_SHELL}
help:
	@echo "Use pre-trained NNJMs."
	@echo
	@echo "To configure the models, type: make all"
	${HELP_LIST_MAIN_TARGETS}


########################################
.PHONY:  all
all: SHELL=${LOCAL_SHELL}
all:

#$(info NNJM_PRETRAINED_NNJM_FIXED: ${NNJM_PRETRAINED_NNJM_FIXED})


########################################
# Clean up
.PHONY:  clean
clean:  SHELL = ${LOCAL_SHELL}
clean:  clean.content
clean:  clean.logs

.PHONY:  clean.content
clean.content:  SHELL=${LOCAL_SHELL}
clean.content:
	${RM} -r cpt.delme  pretrained.* trained fine_tuned train-nnjm.workdir-*

.PHONY:  clean.logs
clean.logs: SHELL=${LOCAL_SHELL}
clean.logs:
	${RM} .Makefile*.deps log.train-nnjm*


define DEPS.PYSCRIPT
from __future__ import print_function

def add_nnjm_corpra_dependencies(model_name, corpora_prefixes, ext=".gz"):
   for corpora in set(corpora_prefixes.split()):
      if "${NNJM_WAM_TYPE}".lower()  == "ibm4":
         s = "{c}/${SRC_LANG}.lc".format(c=corpora, e=ext)
         t = "{c}/${TGT_LANG}.lc".format(c=corpora, e=ext)
      else:
         s = "{c}${L1}{e}".format(c=corpora, e=ext)
         t = "{c}${L2}{e}".format(c=corpora, e=ext)
      wal = "{c}.{w}.${L1_2_L2}.align.gz".format(c=corpora, w="${NNJM_WAM_TYPE}".lower(), e=ext)
      print("{mn}:  {s}  {t}  {wal}".format(mn=model_name, s=s, t=t, wal=wal), file=df)

with open(".Makefile.deps", "w") as df:
   if "${NNJM_WAM_TYPE}".lower() not in set("${MERGED_CPT_JPT_TYPES}".lower().split()):
      print("$$(error You must use a NNJM_WAM_TYPE(${NNJM_WAM_TYPE}) that is in (${MERGED_CPT_JPT_TYPES}))", file=df)

   print("# Pretrain model:", file=df)
   symlinks = []
   for nnjm in set("${NNJM_PRETRAINED_NNJM_FIXED}".split()):
      parts = nnjm.split("/")
      assert(len(parts) >= 2)
      model  = parts[-1]
      target = "pretrained." + parts[-2]
      symlinks.append(target)
      print("pretrained:  {t}/{m}.pretrained".format(m=model, t=target), file=df)

      print("{t}/{m}.pretrained:  {t}/{m}.validate".format(m=model, t=target), file=df)
      print("{t}/{m}.pretrained:  {t}/{m}.is.memory.mapped".format(m=model, t=target), file=df)

      # It is unfortunate but we need to add a depencency on a temporary cpt to
      # validate the nnjm model.
      print("{t}/{m}.validate:  {t}  cpt.delme".format(t=target, m=model), file=df)
      print("{t}/{m}.is.memory.mapped:  {t}".format(t=target, m=model), file=df)
      print("{t}:  {d}".format(t=target, d="/".join(parts[:-1])), file=df)

      #print("portageLive:  {t}/{m}.pretrained".format(m=model, t=target), file=df)
      #print("portageLive:  {pl}/{t}".format(pl="${PORTAGE_LIVE_DEST_DIR}", t=target), file=df)
      #print("{pl}/{t}:  {t}  | {pl}".format(pl="${PORTAGE_LIVE_DEST_DIR}", t=target), file=df)

   print("PRETRAINED_NNJMS_LIST :=", *symlinks, file=df)

   print("", file=df)

   print("# Training:", file=df)

   # TODO: What should be the wal_ext?
   wal_ext = ".${NNJM_NCLS}${CLS_X}"

   # TODO: if we are using a pretrained model, we need to be using the same classes files as the pretrained model.
   print("trained/nnjm.bin:  {s}  {t}".format(s="${SRC_LANG}"+wal_ext, t="${TGT_LANG}"+wal_ext), file=df)
   add_nnjm_corpra_dependencies("trained/nnjm.bin", "${NNJM_DEV_CORPUS} ${NNJM_TEST_CORPUS}", ext="")
   add_nnjm_corpra_dependencies("trained/nnjm.bin", "${NNJM_TRAIN_CORPUS}", ext=".gz")

   if "${NNJM_TRAIN_CORPUS}".strip() != "":
      print("fine_tuned/nnjm.bin:  {s}  {t}".format(s="${SRC_LANG}"+wal_ext, t="${TGT_LANG}"+wal_ext), file=df)
   add_nnjm_corpra_dependencies("fine_tuned/nnjm.bin", "${NNJM_FINE_TUNING_DEV_CORPUS} ${NNJM_FINE_TUNING_TEST_CORPUS}", ext="")
   add_nnjm_corpra_dependencies("fine_tuned/nnjm.bin", "${NNJM_FINE_TUNING_TRAIN_CORPUS}", ext=".gz")
endef
#$(info NNJM dependencies generator: ${DEPS.PYSCRIPT})


$(shell python -c '${DEPS.PYSCRIPT}')
include .Makefile.deps

ifdef NNJM_PRETRAINED_NNJM
$(info Using pre-trained NNJMS)
$(info PRETRAINED_NNJMS_LIST: ${PRETRAINED_NNJMS_LIST})

all:  pretrained
.PHONY:  pretrained
pretrained: SHELL=${LOCAL_SHELL}

# If we were to fine tune a NNJM, since no training corpora was provided by the
# user, we will fine tune the pretrained model.
NNJM_FINE_TUNING_PRETRAINED_MODEL := $(firstword ${PRETRAINED_NNJMS_LIST})/nnjm
$(firstword ${PRETRAINED_NNJMS_LIST})/nnjm.pkl:  $(firstword ${PRETRAINED_NNJMS_LIST})

${PRETRAINED_NNJMS_LIST}:  SHELL=${LOCAL_SHELL}
${PRETRAINED_NNJMS_LIST}:
	ln -fs $< $@

%.validate:  SHELL=${LOCAL_SHELL}
%.validate:
	configtool "args: -nnjm-file $*" <<< '[lmodel-file] /dev/null [ttable-multi-prob] cpt.delme' | configtool check

# A temporary phrase table to allow us to use configtool check to valid the
# NNJM models.
.INTERMEDIATE:  cpt.delme
cpt.delme: SHELL=${LOCAL_SHELL}
cpt.delme:
	echo "a ||| a ||| 1 1" > $@

#.PHONY:  clean.symlinks
#clean.content:  clean.symlinks
#clean.symlinks:
#	${RM} ${PRETRAINED_NNJMS_LIST}


${NNJM_FINE_TUNING_PRETRAINED_MODEL}.bin:  %.bin:  $(dir $*)
	true


${NNJM_FINE_TUNING_PRETRAINED_MODEL}.pkl:  %.pkl:  $(dir $*)
	true
else ifneq ($(strip ${NNJM_TRAIN_CORPUS}),)
$(info Training a NNJM model using ${NNJM_TRAIN_CORPUS})
all:  trained/nnjm.bin
else
$(info Not using NNJMs)
all:
	@echo "Not using NNJMs, so nothing to do." >&2
endif



ifneq ($(strip ${NNJM_FINE_TUNING_TRAIN_CORPUS}),)
$(info Performing fine tuning on ${NNJM_FINE_TUNING_PRETRAINED_MODEL} using ${NNJM_FINE_TUNING_TRAIN_CORPUS})
all:  fine_tuned/nnjm.bin
endif




.PHONY: pretrained.are.memory.mapped
pretrained.are.memory.mapped:  SHELL=${LOCAL_SHELL}
pretrained.are.memory.mapped:  $(addsuffix .is.memory.mapped, ${NNJM_PRETRAINED_NNJM_FIXED})

# Validate that the NNJM model is using classes files that are memory mapped.
%.is.memory.mapped:  SHELL=${LOCAL_SHELL}
%.is.memory.mapped:
	grep --quiet "srcclasses\|tgtclasses" $* || ! echo "Error: $* has no class files." >&2
	! grep --quiet srcclasses $* \
	|| grep -m1 "Portage TPMap" $(dir $*)/`grep srcclasses $* | cut --fields=2 --delimiter=' '` \
	|| ! echo "Error: srcclasses should be memory mapped in $*" >&2
	! grep --quiet tgtclasses $* \
	|| grep -m1 "Portage TPMap" $(dir $*)/`grep tgtclasses $* | cut --fields=2 --delimiter=' '` \
	|| ! echo "Error: tgtclasses should be memory mapped in $*" >&2


########################################
# Portage Live
${PORTAGE_LIVE_DEST_DIR}:  SHELL=${LOCAL_SHELL}
${PORTAGE_LIVE_DEST_DIR}:
	mkdir -p ${PORTAGE_LIVE_DEST_DIR}

.PHONY:  portageLive
portageLive:  SHELL=${LOCAL_SHELL}
ifdef NNJM_FINE_TUNING_TRAIN_CORPUS
portageLive:  ${PORTAGE_LIVE_DEST_DIR}/fine_tuned
${PORTAGE_LIVE_DEST_DIR}/fine_tuned:  fine_tuned/nnjm.bin  | ${PORTAGE_LIVE_DEST_DIR}
else ifdef NNJM_TRAIN_CORPUS
portageLive:  ${PORTAGE_LIVE_DEST_DIR}/trained
${PORTAGE_LIVE_DEST_DIR}/trained:  trained/nnjm.bin  | ${PORTAGE_LIVE_DEST_DIR}
else ifdef NNJM_PRETRAINED_NNJM
portageLive:  $(firstword ${PRETRAINED_NNJMS_LIST})/model.pretrained
portageLive:  ${PORTAGE_LIVE_DEST_DIR}/$(firstword ${PRETRAINED_NNJMS_LIST})
${PORTAGE_LIVE_DEST_DIR}/$(firstword ${PRETRAINED_NNJMS_LIST}):  $(firstword ${PRETRAINED_NNJMS_LIST})  | ${PORTAGE_LIVE_DEST_DIR}
else
portageLive:
	@echo "Not using NNJMs, so nothing to do for portageLive." >&2
endif

${PORTAGE_LIVE_DEST_DIR}/%: SHELL=${LOCAL_SHELL}
${PORTAGE_LIVE_DEST_DIR}/%:
	ln -fs ../../../nnjm/$* $(dir $@)

MAIN_TARGETS += portageLive

.PHONY:  clean.portageLive
clean.content:  clean.portageLive
clean.portageLive: SHELL=${LOCAL_SHELL}
clean.portageLive:
	${RM} -fr ${PORTAGE_LIVE_DEST_DIR}




################################################################################
# TODO:  these rules are quick hacky and specific, yark!
remove_corpora = $(or $(and $(strip $1), $(filter-out \
				%$(strip $1)${L1} \
				%$(strip $1)${L2} \
				%$(strip $1)/${SRC_LANG}.lc \
				%$(strip $1)/${TGT_LANG}.lc \
				%$(strip $1).${NNJM_WAM_TYPE}.${L1_2_L2}.align.gz \
				, $2)), $2)
get_corpora = $(filter-out %.pkl, \
					$(filter \
					%$(strip $1)${L1} \
					%$(strip $1)${L2} \
					%$(strip $1)/${SRC_LANG}.lc \
					%$(strip $1)/${TGT_LANG}.lc \
					%$(strip $1).${NNJM_WAM_TYPE}.${L1_2_L2}.align.gz \
					, $2))

remove_dev = $(call remove_corpora, ${NNJM_DEV_CORPUS}, \
					 $(call remove_corpora, ${NNJM_FINE_TUNING_DEV_CORPUS}, $1))

remove_test = $(call remove_corpora, ${NNJM_TEST_CORPUS}, \
					 $(call remove_corpora, ${NNJM_FINE_TUNING_TEST_CORPUS}, $1))

get_train = $(filter-out %.bin %.pkl, $(call remove_test, $(call remove_dev, $1)))

trained/nnjm.bin:
	train-nnjm.sh \
		-out trained \
		-cls-s $(filter %/${SRC_LANG}.${NNJM_NCLS}${CLS_X}, $^) \
		-cls-t $(filter %/${TGT_LANG}.${NNJM_NCLS}${CLS_X}, $^) \
		${NNJM_TRAIN_NNJM_OPTS} \
		${NNJM_GENEX_OPTS} \
		$(and $(strip ${NNJM_TEST_CORPUS}), $(call get_corpora, ${NNJM_TEST_CORPUS}, $^), -test $(call get_corpora, ${NNJM_TEST_CORPUS}, $^)) \
		-dev $(call get_corpora, ${NNJM_DEV_CORPUS}, $^) \
		$(call get_train, $(filter-out %${CLS_X}, $^)) \
	&> log.train-nnjm



fine_tuned/nnjm.bin:  ${NNJM_FINE_TUNING_PRETRAINED_MODEL}.bin
	train-nnjm.sh \
		-out fine_tuned \
		-pre-trained-nnjm  $(or $(dir $(filter %.bin, $^)), $(error You need to define a pretrained nnjm model.)) \
		${NNJM_TRAIN_NNJM_OPTS} \
		${NNJM_GENEX_OPTS} \
		$(and $(strip ${NNJM_FINE_TUNING_TEST_CORPUS}), $(call get_corpora, ${NNJM_FINE_TUNING_TEST_CORPUS}, $^), -test $(call get_corpora, ${NNJM_FINE_TUNING_TEST_CORPUS}, $^)) \
		-dev $(call get_corpora, ${NNJM_FINE_TUNING_DEV_CORPUS}, $^) \
		$(or $(call get_train, $(filter-out %${CLS_X}, $^)), $(error You need to define NNJM_FINE_TUNING_TRAIN_CORPUS)) \
	&> log.train-nnjm.fine_tuning


%.bin:  %.pkl
	unpickle.py $< $@




################################################################################
# Validation
ifneq ($(strip ${NNJM_PRETRAINED_NNJM_FIXED}),)
ifneq ($(strip ${NNJM_TRAIN_CORPUS}),)
$(error You cannot use pretrained nnjm and also ask to train a NNJM.  Maybe you want to fine tune a pretrained model instead?)
endif   # NNJM_TRAIN_CORPUS

else  # NNJM_PRETRAINED_NNJM_FIXED
ifneq ($(strip ${NNJM_FINE_TUNING_TRAIN_CORPUS}),)
ifeq ($(strip ${NNJM_TRAIN_CORPUS}),)
$(error you need to use either a pretrained model or train a base model if you want to use fine tuning.)
endif   # NNJM_TRAIN_CORPUS
endif   # NNJM_FINE_TUNING_TRAIN_CORPUS
endif   # NNJM_PRETRAINED_NNJM_FIXED





################################################################################
# TestSuite
.PHONY:  testsuite

testsuite:  one_pretrained_testcase
.PHONY:  one_pretrained_testcase
one_pretrained_testcase:  export NNJM_PRETRAINED_NNJM := ${PORTAGE_GENERIC_MODEL}/generic-2.0/nnjm/nnjm.generic-2.0.en2fr.mm/model
one_pretrained_testcase:
	${MAKE} clean
	${MAKE} portageLive
	[[ `\ls -d ${PORTAGE_LIVE_DEST_DIR}/pretrained* | \wc -l` -eq 1 ]] || ! echo "Error: Expecting 1 NNJM model." >&2
	[[ -L ${PORTAGE_LIVE_DEST_DIR}/pretrained.nnjm.generic-2.0.en2fr.mm ]] || ! echo "Error: Missing NNJM model symlink." >&2


testsuite:  multiple_pretrained_testcase
.PHONY:  multiple_pretrained_testcase
multiple_pretrained_testcase:  export NNJM_PRETRAINED_NNJM := ${PORTAGE_GENERIC_MODEL}/generic-2.0/nnjm/nnjm.generic-2.0.en2fr.mm/model  ${PORTAGE_GENERIC_MODEL}/nnjm/nnjm.generic-2.0.fr2en.mm/model
multiple_pretrained_testcase:
	${MAKE} clean
	${MAKE} portageLive
	[[ `\ls -d ${PORTAGE_LIVE_DEST_DIR}/pretrained* | \wc -l` -eq 2 ]] || ! echo "Error: Expecting 2 NNJM model." >&2
	[[ -L ${PORTAGE_LIVE_DEST_DIR}/pretrained.nnjm.generic-2.0.en2fr.mm ]] || ! echo "Error: Missing NNJM model symlink." >&2
	[[ -L ${PORTAGE_LIVE_DEST_DIR}/pretrained.nnjm.generic-2.0.fr2en.mm ]] || ! echo "Error: Missing NNJM model symlink." >&2


########################################
# Training scenarios
.PHONY:  testsuite_scenarios
NNJM_TRAIN_NNJM_OPTS_QUICK := -embed_size 3  -n_hidden_layers 1  -batch_size 64  -slice_size 64  -print_interval 1  -hidden_layer_sizes 12  -n_epochs 6  -self_norm_alpha 0.1  -eta_0 0.3  -rnd_elide_max 3  -rnd_elide_prob 0.1  -val_batch_size 10  -batches_per_epoch 20

# ERROR
# We are not allowed to ask for pretrained and try to train a NNJM.
.PHONY: testcase_pretrained_trained
testsuite_scenarios:  testcase_pretrained_trained
testcase_pretrained_trained:  export NNJM_WAM_TYPE := hmm3
testcase_pretrained_trained:  export NNJM_DEV_CORPUS := ${TUNE_DECODE}
testcase_pretrained_trained:  export NNJM_TEST_CORPUS := $(firstword ${TEST_SET})
testcase_pretrained_trained:  export NNJM_TRAIN_CORPUS := ${TRAIN_TM}
testcase_pretrained_trained:  export NNJM_FINE_TUNING_DEV_CORPUS :=
testcase_pretrained_trained:  export NNJM_FINE_TUNING_TEST_CORPUS :=
testcase_pretrained_trained:  export NNJM_FINE_TUNING_TRAIN_CORPUS :=
testcase_pretrained_trained:  export NNJM_PRETRAINED_NNJM := ${PORTAGE_GENERIC_MODEL}/generic-2.0/nnjm/nnjm.generic-2.0.${SRC_LANG}2${TGT_LANG}.mm/model
testcase_pretrained_trained:
	echo -e "################################################\nTESTCASE: $@"
	! ${MAKE} all


# ERROR
# It is not allowed to try to only fine tuned since a pretrained NNJM or a
# freshly build NNJM is required.
.PHONY: testcase_fine_tuned_only
testsuite_scenarios:  testcase_fine_tuned_only
testcase_fine_tuned_only:  export NNJM_WAM_TYPE := hmm3
testcase_fine_tuned_only:  export NNJM_DEV_CORPUS :=
testcase_fine_tuned_only:  export NNJM_TEST_CORPUS :=
testcase_fine_tuned_only:  export NNJM_TRAIN_CORPUS :=
testcase_fine_tuned_only:  export NNJM_FINE_TUNING_DEV_CORPUS := ${TUNE_DECODE}
testcase_fine_tuned_only:  export NNJM_FINE_TUNING_TEST_CORPUS := $(firstword ${TEST_SET})
testcase_fine_tuned_only:  export NNJM_FINE_TUNING_TRAIN_CORPUS := ${TRAIN_TM}
testcase_fine_tuned_only:  export NNJM_PRETRAINED_NNJM :=
testcase_fine_tuned_only:
	echo -e "################################################\nTESTCASE: $@"
	! ${MAKE} all


# We should be able to use a pretrained NNJM model only.
.PHONY: testcase_pretrained
testsuite_scenarios:  testcase_pretrained
testcase_pretrained:  export NNJM_WAM_TYPE := hmm3
testcase_pretrained:  export NNJM_DEV_CORPUS :=
testcase_pretrained:  export NNJM_TEST_CORPUS :=
testcase_pretrained:  export NNJM_TRAIN_CORPUS :=
testcase_pretrained:  export NNJM_FINE_TUNING_DEV_CORPUS :=
testcase_pretrained:  export NNJM_FINE_TUNING_TEST_CORPUS :=
testcase_pretrained:  export NNJM_FINE_TUNING_TRAIN_CORPUS :=
testcase_pretrained:  export NNJM_PRETRAINED_NNJM := ${PORTAGE_GENERIC_MODEL}/generic-2.0/nnjm/nnjm.generic-2.0.${SRC_LANG}2${TGT_LANG}.mm/model
testcase_pretrained:  export NNJM_TRAIN_NNJM_OPTS := -batch_size 64  -slice_size 64  -print_interval 1  -n_epochs 6
testcase_pretrained:
	echo -e "################################################\nTESTCASE: $@"
	${MAKE} portageLive


# We should be able to fine tune a pretrained NNJM model.
.PHONY: testcase_pretrained_fine_tuned
testsuite_scenarios:  testcase_pretrained_fine_tuned
testcase_pretrained_fine_tuned:  export NNJM_WAM_TYPE := hmm3
testcase_pretrained_fine_tuned:  export NNJM_DEV_CORPUS :=
testcase_pretrained_fine_tuned:  export NNJM_TEST_CORPUS :=
testcase_pretrained_fine_tuned:  export NNJM_TRAIN_CORPUS :=
testcase_pretrained_fine_tuned:  export NNJM_FINE_TUNING_DEV_CORPUS := ${TUNE_DECODE}
testcase_pretrained_fine_tuned:  export NNJM_FINE_TUNING_TEST_CORPUS := $(firstword ${TEST_SET})
testcase_pretrained_fine_tuned:  export NNJM_FINE_TUNING_TRAIN_CORPUS := ${TRAIN_TM}
#testcase_pretrained_fine_tuned:  export NNJM_PRETRAINED_NNJM := ${PORTAGE_GENERIC_MODEL}/generic-2.0/nnjm/nnjm.generic-2.0.${SRC_LANG}2${TGT_LANG}.mm/model
testcase_pretrained_fine_tuned:  export NNJM_PRETRAINED_NNJM := /home/models/HANSARD-2017/Hansard-2017.${SRC_LANG}2${TGT_LANG}/models/nnjm/pretrained.baseline.10M/model
testcase_pretrained_fine_tuned:  export NNJM_TRAIN_NNJM_OPTS := -batch_size 64  -slice_size 64  -print_interval 1  -n_epochs 6
testcase_pretrained_fine_tuned:
	echo -e "################################################\nTESTCASE: $@"
	${MAKE} portageLive


# We should be able to train a NNJM model from user provided data.
.PHONY: testcase_trained
testsuite_scenarios:  testcase_trained
testcase_trained:  export NNJM_WAM_TYPE := hmm3
testcase_trained:  export NNJM_DEV_CORPUS := ${TUNE_DECODE}
testcase_trained:  export NNJM_TEST_CORPUS := $(firstword ${TEST_SET})
testcase_trained:  export NNJM_TRAIN_CORPUS := ${TRAIN_TM}
testcase_trained:  export NNJM_FINE_TUNING_DEV_CORPUS :=
testcase_trained:  export NNJM_FINE_TUNING_TEST_CORPUS :=
testcase_trained:  export NNJM_FINE_TUNING_TRAIN_CORPUS :=
testcase_trained:  export NNJM_PRETRAINED_NNJM :=
testcase_trained:  export NNJM_TRAIN_NNJM_OPTS := ${NNJM_TRAIN_NNJM_OPTS_QUICK}
testcase_trained:
	echo -e "################################################\nTESTCASE: $@"
	${MAKE} portageLive


# We should be able to fine tune a trained NNJM model built from user provided
# data.
.PHONY: testcase_trained_fine_tuned
testsuite_scenarios:  testcase_trained_fine_tuned
testcase_trained_fine_tuned:  export NNJM_WAM_TYPE := hmm3
testcase_trained_fine_tuned:  export NNJM_DEV_CORPUS := ${TUNE_DECODE}
testcase_trained_fine_tuned:  export NNJM_TEST_CORPUS := $(firstword ${TEST_SET})
testcase_trained_fine_tuned:  export NNJM_TRAIN_CORPUS := ${TRAIN_TM}
testcase_trained_fine_tuned:  export NNJM_FINE_TUNING_DEV_CORPUS := ${TUNE_DECODE}
testcase_trained_fine_tuned:  export NNJM_FINE_TUNING_TEST_CORPUS := $(firstword ${TEST_SET})
testcase_trained_fine_tuned:  export NNJM_FINE_TUNING_TRAIN_CORPUS := ${TRAIN_TM}
testcase_trained_fine_tuned:  export NNJM_PRETRAINED_NNJM :=
testcase_trained_fine_tuned:  export NNJM_TRAIN_NNJM_OPTS := ${NNJM_TRAIN_NNJM_OPTS_QUICK}
testcase_trained_fine_tuned:
	echo -e "################################################\nTESTCASE: $@"
	${MAKE} portageLive
