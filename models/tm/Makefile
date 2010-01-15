#!/usr/bin/make -f
# vim:noet:ts=3:nowrap
# $Id$
#
# @author Samuel Larkin
# @file Makefile
# @brief Trains ibm models, hmm models, joint frequency counts models and phrase tables.
#
# Technologies langagieres interactives / Interactive Language Technologies
# Inst. de technologie de l'information / Institute for Information Technology
# Conseil national de recherches Canada / National Research Council Canada
# Copyright 2008, Sa Majeste la Reine du Chef du Canada
# Copyright 2008, Her Majesty in Right of Canada


# Source file requirements
# <PREFIX>_<LANGUAGE>.<LANGX>
 
# Variables we use from ../../Makefile.params:
# PT_TYPES indicates what type of phrase table we want to generate.

# Mandatory include: master config file.
include ../../Makefile.params

# Include the config file.
MAKEFILE_PARAMS ?= Makefile.params
-include ${MAKEFILE_PARAMS}

# What is this module's name.
MODULE_NAME ?= tm

# TODO: Make sure this Makefile works for Portage's cluster.
# This will require that run-parallel.sh -c RP_OPTS be functional.
SHELL = ${FRAMEWORK_SHELL}

export LANG   = en_CA.utf8
export LC_ALL = en_CA.utf8

# What program to use to train models
CAT ?= cat.sh

# Where we can find the parallel corpora
CORPORA_DIR ?= ../../corpora

# Maximum phrase length
M ?= 8

# What is the level of parallelism.
PARALLELISM_LEVEL_TM ?= 5

# Already defined in the master config file.
#SRC_LANG ?= en
#TGT_LANG ?= fr
#LANGX    ?= .lc
#LANGXZ   ?= ${langx}.gz

# Map source and target language to shorter variable name.
SRC  ?= ${SRC_LANG}
TGT  ?= ${TGT_LANG}
SRCX ?= _${SRC}${LANGXZ}
TGTX ?= _${TGT}${LANGXZ}

# IBM / HMM models extension
SRC_GIVEN_TGT  = ${SRC}_given_${TGT}
TGT_GIVEN_SRC  = ${TGT}_given_${SRC}
SRC_GIVEN_TGTX = ${SRC_GIVEN_TGT}.gz
TGT_GIVEN_SRCX = ${TGT_GIVEN_SRC}.gz

# conditional phrase table extension
SRC_2_TGT  = ${SRC}2${TGT}
TGT_2_SRC  = ${TGT}2${SRC}
SRC_2_TGTX = ${SRC_2_TGT}.gz
TGT_2_SRCX = ${TGT_2_SRC}.gz

# Joint phrase table extension
JOINT  = ${SRC}-${TGT}
JOINTX = ${JOINT}.gz

# What parallel corpora is to be used for creating the models
TRAIN_TM ?= train

# This should always reflect models in both directions as both direction are required.
MODEL_DIRECTIONS ?= ${TGT_GIVEN_SRC} ${SRC_GIVEN_TGT}

# Define the following variable if you want to create forward and backward phrase tables
ifdef BIDIRECTIONAL_SYSTEM
# To get both directions
CPT_DIRECTION ?= ${SRC_2_TGTX} ${TGT_2_SRCX}
else
# To get SRC to TGT direction
CPT_DIRECTION ?= ${SRC_2_TGTX}
endif

# This script might produce directory and we want to easily remove them.
RM = rm -rf

# After this Makefile, the following targets/files are precious.
FILES_TO_BE_LOCKED = ibm* hmm* jpt* cpt*

# Should we monitor the memory usage of the processes?
MONITOR_MEMORY_USAGE ?=

# Resource monitoring.
P_RES_MON ?= p-res-mon.sh -t

# What program to use to create conditional pt from joint probs.
JOINT2COND_PHRASE_TABLE ?= joint2cond_phrase_tables -reduce-mem



# Allows to search for alignment files in corpus
vpath %${SRCX} ${CORPORA_DIR}
vpath %${TGTX} ${CORPORA_DIR}


.DELETE_ON_ERROR:
.SUFFIXES:
.SECONDARY:


########################################
# HELP OPTIONS
.PHONY: help
help: SHELL=${GUARD_SHELL}
help:
	@echo "Available targets are:"
	@cat $(firstword $(MAKEFILE_LIST)) | egrep '^.PHONY:' | sed 's#^.PHONY: ##'



# Define all the work to be done.
.PHONY: all
all: ${PT_TYPES}



# What the user can expect from this module.
.PHONY: list_final_output
list_final_output: SHELL=${GUARD_SHELL}
list_final_output: $(addsuffix _list,${PT_TYPES})
	@echo "are the expected final output."



########################################
# CLEAN-UP
.PHONY: clean
clean: SHELL=${GUARD_SHELL}
clean:
	$(RM) run-parallel-log* log.* run-p.*



########################################
# Hide logs.
.PHONY: hide
hide: SHELL=${GUARD_SHELL}
hide:
	mkdir -p .logs
	mv log.* run-parallel-logs-* .logs



################################################################################
# MODELS
.PHONY: models
models: ibm1_model
models: ibm2_model
models: hmm1_model
models: hmm2_model
models: hmm3_model



########################################
# TRAINING THE IBM1 MODELS
# requires: source and target corpora.
IBM1_MODEL_PARALLELISM_LEVEL ?= ${PARALLELISM_LEVEL_TM}
IBM1_MODEL_WORKERS ?= ${IBM1_MODEL_PARALLELISM_LEVEL}
IBM1_MODEL_EXTRAS ?=
IBM1_MODEL_CPUS ?= 1

.PHONY:  ibm1_model
ibm1_model: $(foreach t, ${TRAIN_TM}, $(foreach d, ${MODEL_DIRECTIONS}, ibm1.$t.$d.gz))

ibm1.%.${TGT_GIVEN_SRCX}:  %${SRCX} %${TGTX}
	@_LOCAL=1 echo "Generating $@"
	RP_PSUB_OPTS="-${IBM1_MODEL_CPUS} -N $@ ${PSUB_OPTS}" \
	${CAT} -n ${IBM1_MODEL_PARALLELISM_LEVEL} -pn ${IBM1_MODEL_WORKERS} \
		-v \
		-n1 5 -n2 0 \
		-bin \
		${IBM1_MODEL_EXTRAS} \
		$@ \
		$^ \
		>& log.$(basename $@)

ibm1.%.${SRC_GIVEN_TGTX}:  %${SRCX} %${TGTX}
	@_LOCAL=1 echo "Generating $@"
	RP_PSUB_OPTS="-${IBM1_MODEL_CPUS} -N $@ ${PSUB_OPTS}" \
	${CAT} -n ${IBM1_MODEL_PARALLELISM_LEVEL} -pn ${IBM1_MODEL_WORKERS} \
		-v -r \
		-n1 5 -n2 0 \
		-bin \
		${IBM1_MODEL_EXTRAS} \
		$@ \
		$^ \
		>& log.$(basename $@)

clean: clean.ibm1

.PHONY: clean.ibm1
clean.ibm1: SHELL=${GUARD_SHELL}
clean.ibm1:
	$(RM) ibm1.*



########################################
# TRAINING THE IBM2 MODELS
# requires: source and target corpora and ibm1 models.
IBM2_MODEL_PARALLELISM_LEVEL ?= ${PARALLELISM_LEVEL_TM}
IBM2_MODEL_WORKERS ?= ${IBM2_MODEL_PARALLELISM_LEVEL}
IBM2_MODEL_EXTRAS ?=
IBM2_MODEL_CPUS ?= 1

.PHONY:  ibm2_model
ibm2_model: ibm1_model
ibm2_model: $(foreach t, ${TRAIN_TM}, $(foreach d, ${MODEL_DIRECTIONS}, ibm2.$t.$d.gz))

ibm2.%.${TGT_GIVEN_SRCX}:  %${SRCX} %${TGTX} ibm1.%.${TGT_GIVEN_SRCX}
	@_LOCAL=1 echo "Generating $@"
	RP_PSUB_OPTS="-${IBM2_MODEL_CPUS} -N $@ ${PSUB_OPTS}" \
	${CAT} -n ${IBM2_MODEL_PARALLELISM_LEVEL} -pn ${IBM2_MODEL_WORKERS} \
		-v -m \
		-n1 0 -n2 5 \
		-slen 20 -tlen 20 -bksize 20 \
		-bin \
		-i $(word 3, $+) \
		${IBM2_MODEL_EXTRAS} \
		$@ \
		$(wordlist 1, 2, $+) \
		>& log.$(basename $@)

ibm2.%.${SRC_GIVEN_TGTX}:  %${SRCX} %${TGTX} ibm1.%.${SRC_GIVEN_TGTX}
	@_LOCAL=1 echo "Generating $@"
	RP_PSUB_OPTS="-${IBM2_MODEL_CPUS} -N $@ ${PSUB_OPTS}" \
	${CAT} -n ${IBM2_MODEL_PARALLELISM_LEVEL} -pn ${IBM2_MODEL_WORKERS} \
		-v -r \
		-n1 0 -n2 5 \
		-slen 20 -tlen 20 -bksize 20 \
		-bin \
		-i $(word 3, $+) \
		${IBM2_MODEL_EXTRAS} \
		$@ \
		$(wordlist 1, 2, $+) \
		>& log.$(basename $@)

clean: clean.ibm2

.PHONY: clean.ibm2
clean.ibm2: SHELL=${GUARD_SHELL}
clean.ibm2:
	$(RM) ibm2.*



########################################
# TRAINING THE HMM1 MODELS => He-lex
# requires: source and target corpora and ibm1 models.
HMM1_MODEL_PARALLELISM_LEVEL ?= ${PARALLELISM_LEVEL_TM}
HMM1_MODEL_WORKERS ?= ${HMM1_MODEL_PARALLELISM_LEVEL}
HMM1_MODEL_EXTRAS ?=
HMM1_MODEL_CPUS ?= 1

.PHONY:  hmm1_model
hmm1_model: ibm1_model
hmm1_model: $(foreach t, ${TRAIN_TM}, $(foreach d, ${MODEL_DIRECTIONS}, hmm1.$t.$d.gz))

hmm1.%.${TGT_GIVEN_SRCX}:  %${SRCX} %${TGTX} ibm1.%.${TGT_GIVEN_SRCX}
	@_LOCAL=1 echo "Generating $@"
	RP_PSUB_OPTS="-${HMM1_MODEL_CPUS} -N $@ ${PSUB_OPTS}" \
	${CAT} -n ${HMM1_MODEL_PARALLELISM_LEVEL} -pn ${HMM1_MODEL_WORKERS} \
		-v  \
		-n1 0 -n2 5 \
		-mimic he-lex \
		-bin \
		-i $(word 3, $+) \
		${HMM1_MODEL_EXTRAS} \
		$@ \
		$(wordlist 1, 2, $+) \
		>& log.$(basename $@)

hmm1.%.${SRC_GIVEN_TGTX}:  %${SRCX} %${TGTX} ibm1.%.${SRC_GIVEN_TGTX}
	@_LOCAL=1 echo "Generating $@"
	RP_PSUB_OPTS="-${HMM1_MODEL_CPUS} -N $@ ${PSUB_OPTS}" \
	${CAT} -n ${HMM1_MODEL_PARALLELISM_LEVEL} -pn ${HMM1_MODEL_WORKERS} \
		-v -r \
		-n1 0 -n2 5 \
		-mimic he-lex \
		-bin \
		-i $(word 3, $+) \
		${HMM1_MODEL_EXTRAS} \
		$@ \
		$(wordlist 1, 2, $+) \
		>& log.$(basename $@)

clean: clean.hmm1

.PHONY: clean.hmm1
clean.hmm1: SHELL=${GUARD_SHELL}
clean.hmm1:
	$(RM) hmm1.*



########################################
# TRAINING THE HMM2 MODELS => liang variant
# requires: source and target corpora and ibm1 models.
HMM2_MODEL_PARALLELISM_LEVEL ?= ${PARALLELISM_LEVEL_TM}
HMM2_MODEL_WORKERS ?= ${HMM2_MODEL_PARALLELISM_LEVEL}
HMM2_MODEL_EXTRAS ?=
HMM2_MODEL_CPUS ?= 1

.PHONY:  hmm2_model
hmm2_model: ibm1_model
hmm2_model: $(foreach t, ${TRAIN_TM}, $(foreach d, ${MODEL_DIRECTIONS}, hmm2.$t.$d.gz))

hmm2.%.${TGT_GIVEN_SRCX}:  %${SRCX} %${TGTX} ibm1.%.${TGT_GIVEN_SRCX}
	@_LOCAL=1 echo "Generating $@"
	RP_PSUB_OPTS="-${HMM2_MODEL_CPUS} -N $@ ${PSUB_OPTS}" \
	${CAT} -n ${HMM2_MODEL_PARALLELISM_LEVEL} -pn ${HMM2_MODEL_WORKERS} \
		-v \
		-n1 0 -n2 5 \
		-mimic liang \
		-bin \
		-i $(word 3, $+) \
		${HMM2_MODEL_EXTRAS} \
		$@ \
		$(wordlist 1, 2, $+) \
		>& log.$(basename $@)

hmm2.%.${SRC_GIVEN_TGTX}:  %${SRCX} %${TGTX} ibm1.%.${SRC_GIVEN_TGTX}
	@_LOCAL=1 echo "Generating $@"
	RP_PSUB_OPTS="-${HMM2_MODEL_CPUS} -N $@ ${PSUB_OPTS}" \
	${CAT} -n ${HMM2_MODEL_PARALLELISM_LEVEL} -pn ${HMM2_MODEL_WORKERS} \
		-v -r \
		-n1 0 -n2 5 \
		-mimic liang \
		-bin \
		-i $(word 3, $+) \
		${HMM2_MODEL_EXTRAS} \
		$@ \
		$(wordlist 1, 2, $+) \
		>& log.$(basename $@)

clean: clean.hmm2

.PHONY: clean.hmm2
clean.hmm2: SHELL=${GUARD_SHELL}
clean.hmm2:
	$(RM) hmm2.*



########################################
# TRAINING THE HMM3 MODELS => liang variant
# requires: source and target corpora and ibm1 models.
HMM3_MODEL_PARALLELISM_LEVEL ?= ${PARALLELISM_LEVEL_TM}
HMM3_MODEL_WORKERS ?= ${HMM3_MODEL_PARALLELISM_LEVEL}
HMM3_MODEL_EXTRAS ?=
HMM3_MODEL_CPUS ?= 1

.PHONY:  hmm3_model
hmm3_model: ibm1_model
hmm3_model: $(foreach t, ${TRAIN_TM}, $(foreach d, ${MODEL_DIRECTIONS}, hmm3.$t.$d.gz))

hmm3.%.${TGT_GIVEN_SRCX}:  %${SRCX} %${TGTX} ibm1.%.${TGT_GIVEN_SRCX}
	@_LOCAL=1 echo "Generating $@"
	RP_PSUB_OPTS="-${HMM3_MODEL_CPUS} -N $@ ${PSUB_OPTS}" \
	${CAT} -n ${HMM3_MODEL_PARALLELISM_LEVEL} -pn ${HMM3_MODEL_WORKERS} \
		-v \
		-n1 0 -n2 5 \
		-hmm -newhmm -start-dist -final-dist -anchor -max-jump 20 -alpha 0.0 -lambda 1.0 -p0 0.6 -up0 0.5 \
		-bin \
		-i $(word 3, $+) \
		${HMM3_MODEL_EXTRAS} \
		$@ \
		$(wordlist 1, 2, $+) \
		>& log.$(basename $@)

hmm3.%.${SRC_GIVEN_TGTX}:  %${SRCX} %${TGTX} ibm1.%.${SRC_GIVEN_TGTX}
	@_LOCAL=1 echo "Generating $@"
	RP_PSUB_OPTS="-${HMM3_MODEL_CPUS} -N $@ ${PSUB_OPTS}" \
	${CAT} -n ${HMM3_MODEL_PARALLELISM_LEVEL} -pn ${HMM3_MODEL_WORKERS} \
		-v -r \
		-n1 0 -n2 5 \
		-hmm -newhmm -start-dist -final-dist -anchor -max-jump 20 -alpha 0.0 -lambda 1.0 -p0 0.6 -up0 0.5 \
		-bin \
		-i $(word 3, $+) \
		${HMM3_MODEL_EXTRAS} \
		$@ \
		$(wordlist 1, 2, $+) \
		>& log.$(basename $@)

clean: clean.hmm3

.PHONY: clean.hmm3
clean.hmm3: SHELL=${GUARD_SHELL}
clean.hmm3:
	$(RM) hmm3.*



################################################################################
# JOINT PHRASE TABLES
.PHONY: jpts
jpts: ibm2_jpt
jpts: hmm1_jpt
jpts: hmm2_jpt
jpts: hmm3_jpt

clean: clean.jpts

.PHONY: clean.jpts
clean.jpts: SHELL=${GUARD_SHELL}
clean.jpts:
	$(RM) jpt.*
	${RM} -r JPTPAR*


########################################
# IBM2 JOINT PHRASE TABLES
# requires: ibm2 models, source and target corpora.
IBM2_JPT_PARALLELISM_LEVEL ?= ${PARALLELISM_LEVEL_TM}
IBM2_JPT_WORKERS ?= ${IBM2_JPT_PARALLELISM_LEVEL}
IBM2_JPT_PREFIX ?= jpt.ibm2
IBM2_JPT_CPUS ?= 2

.PHONY:  ibm2_jpt
ibm2_jpt: ibm2_model
ibm2_jpt: $(foreach t, ${TRAIN_TM}, ${IBM2_JPT_PREFIX}.$t.${JOINTX})

${IBM2_JPT_PREFIX}.%.${JOINTX}:  ibm2.%.${TGT_GIVEN_SRCX} ibm2.%.${SRC_GIVEN_TGTX}  %${SRCX} %${TGTX}
	@_LOCAL=1 echo "Generating $@"
	RP_PSUB_OPTS="-${IBM2_JPT_CPUS} -N $@ ${PSUB_OPTS}" \
	gen-jpt-parallel.sh \
		-n ${IBM2_JPT_PARALLELISM_LEVEL} \
		-nw ${IBM2_JPT_WORKERS} \
		-o $@ \
		GPT \
		-v -j -w 1 -m $M -ibm 2 \
		-1 ${SRC} -2 ${TGT} \
		${IBM2_JPT_EXTRAS} \
		$+ \
		2> log.$(basename $@)


########################################
# HMM1 JOINT PHRASE TABLES => He's lexical variant
# requires: hmm models, source and target corpora.
HMM1_JPT_PARALLELISM_LEVEL ?= ${PARALLELISM_LEVEL_TM}
HMM1_JPT_WORKERS ?= ${HMM1_JPT_PARALLELISM_LEVEL}
HMM1_JPT_PREFIX ?= jpt.hmm1
HMM1_JPT_CPUS ?= 2

.PHONY:  hmm1_jpt
hmm1_jpt: hmm1_model
hmm1_jpt: $(foreach t, ${TRAIN_TM}, ${HMM1_JPT_PREFIX}.$t.${JOINTX})
${HMM1_JPT_PREFIX}.%.${JOINTX}:  hmm1.%.${TGT_GIVEN_SRCX} hmm1.%.${SRC_GIVEN_TGTX}  %${SRCX} %${TGTX}
	@_LOCAL=1 echo "Generating $@"
	RP_PSUB_OPTS="-${HMM1_JPT_CPUS} -N $@ ${PSUB_OPTS}" \
	gen-jpt-parallel.sh \
		-n ${HMM1_JPT_PARALLELISM_LEVEL} \
		-nw ${HMM1_JPT_WORKERS} \
		-o $@ \
		GPT \
		-v -j -w 1 -m $M -hmm \
		-1 ${SRC} -2 ${TGT} \
		${HMM1_JPT_EXTRAS} \
		$+ \
		2> log.$(basename $@)


########################################
# HMM2 JOINT PHRASE TABLES => Liang's variant
# requires: hmm2 models, source and target corpora.
HMM2_JPT_PARALLELISM_LEVEL ?= ${PARALLELISM_LEVEL_TM}
HMM2_JPT_WORKERS ?= ${HMM2_JPT_PARALLELISM_LEVEL}
HMM2_JPT_PREFIX ?= jpt.hmm2
HMM2_JPT_CPUS ?= 2

.PHONY:  hmm2_jpt
hmm2_jpt: hmm2_model
hmm2_jpt: $(foreach t, ${TRAIN_TM}, ${HMM2_JPT_PREFIX}.$t.${JOINTX})
${HMM2_JPT_PREFIX}.%.${JOINTX}:  hmm2.%.${TGT_GIVEN_SRCX} hmm2.%.${SRC_GIVEN_TGTX}  %${SRCX} %${TGTX}
	@_LOCAL=1 echo "Generating $@"
	RP_PSUB_OPTS="-${HMM2_JPT_CPUS} -N $@ ${PSUB_OPTS}" \
	gen-jpt-parallel.sh \
		-n ${HMM2_JPT_PARALLELISM_LEVEL} \
		-nw ${HMM2_JPT_WORKERS} \
		-o $@ \
		GPT \
		-v -j -w 1 -m $M -hmm \
		-1 ${SRC} -2 ${TGT} \
		${HMM2_JPT_EXTRAS} \
		$+ \
		2> log.$(basename $@)



########################################
# HMM3 JOINT PHRASE TABLES => Liang's variant
# requires: hmm3 models, source and target corpora.
HMM3_JPT_PARALLELISM_LEVEL ?= ${PARALLELISM_LEVEL_TM}
HMM3_JPT_WORKERS ?= ${HMM3_JPT_PARALLELISM_LEVEL}
HMM3_JPT_PREFIX ?= jpt.hmm3
HMM3_JPT_CPUS ?= 2

.PHONY:  hmm3_jpt
hmm3_jpt: hmm3_model
hmm3_jpt: $(foreach t, ${TRAIN_TM}, ${HMM3_JPT_PREFIX}.$t.${JOINTX})
${HMM3_JPT_PREFIX}.%.${JOINTX}:  hmm3.%.${TGT_GIVEN_SRCX} hmm3.%.${SRC_GIVEN_TGTX}  %${SRCX} %${TGTX}
	@_LOCAL=1 echo "Generating $@"
	RP_PSUB_OPTS="-${HMM3_JPT_CPUS} -N $@ ${PSUB_OPTS}" \
	gen-jpt-parallel.sh \
		-n ${HMM3_JPT_PARALLELISM_LEVEL} \
		-nw ${HMM3_JPT_WORKERS} \
		-w 1 \
		-o $@ \
		GPT \
		-v -j -w 1 -m $M -hmm \
		-1 ${SRC} -2 ${TGT} \
		-m 7 -d 6 \
		${HMM3_JPT_EXTRAS} \
		$+ \
		2> log.$(basename $@)



################################################################################
# CONDITIONAL PHRASE TABLES
.PHONY: cpts
cpts: jpts
cpts: ibm2_cpt
cpts: hmm1_cpt
cpts: hmm2_cpt
cpts: hmm3_cpt

clean: clean.cpts

.PHONY: clean.cpts
clean.cpts: SHELL=${GUARD_SHELL}
clean.cpts:
	$(RM) cpt.*

########################################
# IBM CONDITIONAL PHRASE TABLES
# requires: ibm2 models and ibm2 JOINT frequency phrase table.
IBM2_SMOOTHERS ?= -s RFSmoother  -s ZNSmoother  -s "KNSmoother 3"
IBM2_SMOOTHERS_DESCRIPTION ?= -rf-zn-kn3
IBM2_CPT_PREFIX ?= cpt.ibm2${IBM2_SMOOTHERS_DESCRIPTION}
IBM2_CPT_CPUS ?= 2

ibm2_cpt_list = $(foreach t, ${TRAIN_TM}, $(foreach d,${CPT_DIRECTION},${IBM2_CPT_PREFIX}.$t.$d))
ibm2_cpt_list: SHELL=${GUARD_SHELL}
ibm2_cpt_list:
	@echo ${ibm2_cpt_list}

.PHONY:  ibm2_cpt
ibm2_cpt: ibm2_jpt
ibm2_cpt: ${ibm2_cpt_list}

${IBM2_CPT_PREFIX}.%.${SRC_2_TGTX}: ibm2.%.${TGT_GIVEN_SRCX} ibm2.%.${SRC_GIVEN_TGTX} ${IBM2_JPT_PREFIX}.%.${JOINTX}
	@_LOCAL=1 echo "Generating $@"
	RP_PSUB_OPTS="-${IBM2_CPT_CPUS} -N $@ ${PSUB_OPTS}" \
	${P_RES_MON} \
	${JOINT2COND_PHRASE_TABLE} \
		-sort \
		-prune1 100 \
		-ibm 2 \
		-v -i -z \
		-1 ${SRC} -2 ${TGT} \
		${IBM2_SMOOTHERS} \
		-multipr fwd \
		-o $(subst .${SRC_2_TGTX},,$@) \
		-ibm_l2_given_l1  $(filter %${TGT_GIVEN_SRCX}, $+) \
		-ibm_l1_given_l2  $(filter %${SRC_GIVEN_TGTX}, $+) \
		$(filter %${JOINT}.gz, $+) \
		>& log.$(basename $@)

${IBM2_CPT_PREFIX}.%.${TGT_2_SRCX}: ibm2.%.${TGT_GIVEN_SRCX} ibm2.%.${SRC_GIVEN_TGTX} ${IBM2_JPT_PREFIX}.%.${JOINTX}
	@_LOCAL=1 echo "Generating $@"
	RP_PSUB_OPTS="-${IBM2_CPT_CPUS} -N $@ ${PSUB_OPTS}" \
	${P_RES_MON} \
	${JOINT2COND_PHRASE_TABLE} \
		-sort \
		-prune1 100 \
		-ibm 2 \
		-v -i -z \
		-1 ${SRC} -2 ${TGT} \
		${IBM2_SMOOTHERS} \
		-multipr rev \
		-o $(subst .${TGT_2_SRCX},,$@) \
		-ibm_l2_given_l1  $(filter %${TGT_GIVEN_SRCX}, $+) \
		-ibm_l1_given_l2  $(filter %${SRC_GIVEN_TGTX}, $+) \
		$(filter %${JOINT}.gz, $+) \
		>& log.$(basename $@)



########################################
# HMM1 CONDITIONAL PHRASE TABLES => He-lex
# requires: hmm1 models and ibm2 JOINT frequency phrase table.
HMM1_SMOOTHERS ?= -s RFSmoother  -s ZNSmoother  -s "KNSmoother 3"
HMM1_SMOOTHERS_DESCRIPTION ?= -rf-zn-kn3
HMM1_CPT_PREFIX ?= cpt.hmm1${HMM1_SMOOTHERS_DESCRIPTION}
HMM1_CPT_CPUS ?= 2

hmm1_cpt_list = $(foreach t, ${TRAIN_TM}, $(foreach d,${CPT_DIRECTION},${HMM1_CPT_PREFIX}.$t.$d))
hmm1_cpt_list: SHELL=${GUARD_SHELL}
hmm1_cpt_list:
	@echo ${hmm1_cpt_list}

.PHONY:  hmm1_cpt
hmm1_cpt: hmm1_jpt
hmm1_cpt: ${hmm1_cpt_list}

${HMM1_CPT_PREFIX}.%.${SRC_2_TGTX}: hmm1.%.${TGT_GIVEN_SRCX} hmm1.%.${SRC_GIVEN_TGTX} ${HMM1_JPT_PREFIX}.%.${JOINTX}
	@_LOCAL=1 echo "Generating $@"
	RP_PSUB_OPTS="-${HMM1_CPT_CPUS} -N $@ ${PSUB_OPTS}" \
	${P_RES_MON} \
	${JOINT2COND_PHRASE_TABLE} \
		-sort \
		-prune1 100 \
		-hmm \
		-v -i -z \
		-1 ${SRC} -2 ${TGT} \
		${HMM1_SMOOTHERS} \
		-multipr fwd \
		-o $(subst .${SRC_2_TGTX}, , $@) \
		-ibm_l2_given_l1  $(filter %${TGT_GIVEN_SRCX}, $+) \
		-ibm_l1_given_l2  $(filter %${SRC_GIVEN_TGTX}, $+) \
		$(filter %${JOINT}.gz, $+) \
		>& log.$(basename $@)

${HMM1_CPT_PREFIX}.%.${TGT_2_SRCX}: hmm1.%.${TGT_GIVEN_SRCX} hmm1.%.${SRC_GIVEN_TGTX} ${HMM1_JPT_PREFIX}.%.${JOINTX}
	@_LOCAL=1 echo "Generating $@"
	RP_PSUB_OPTS="-${HMM1_CPT_CPUS} -N $@ ${PSUB_OPTS}" \
	${P_RES_MON} \
	${JOINT2COND_PHRASE_TABLE} \
		-sort \
		-prune1 100 \
		-hmm \
		-v -i -z \
		-1 ${SRC} -2 ${TGT} \
		${HMM1_SMOOTHERS} \
		-multipr rev \
		-o $(subst .${TGT_2_SRCX}, , $@) \
		-ibm_l2_given_l1  $(filter %${TGT_GIVEN_SRCX}, $+) \
		-ibm_l1_given_l2  $(filter %${SRC_GIVEN_TGTX}, $+) \
		$(filter %${JOINT}.gz, $+) \
		>& log.$(basename $@)



########################################
# HMM2 CONDITIONAL PHRASE TABLES => liang
# requires: hmm2 models and ibm2 JOINT frequency phrase table.
HMM2_SMOOTHERS ?= -s RFSmoother  -s ZNSmoother  -s "KNSmoother 3"
HMM2_SMOOTHERS_DESCRIPTION ?= -rf-zn-kn3
HMM2_CPT_PREFIX ?= cpt.hmm2${HMM2_SMOOTHERS_DESCRIPTION}
HMM2_CPT_CPUS ?= 2

hmm2_cpt_list = $(foreach t, ${TRAIN_TM}, $(foreach d,${CPT_DIRECTION},${HMM2_CPT_PREFIX}.$t.$d))
hmm2_cpt_list: SHELL=${GUARD_SHELL}
hmm2_cpt_list:
	@echo ${hmm2_cpt_list}

.PHONY:  hmm2_cpt
hmm2_cpt: hmm2_jpt
hmm2_cpt: ${hmm2_cpt_list}

${HMM2_CPT_PREFIX}.%.${SRC_2_TGTX}:  hmm2.%.${TGT_GIVEN_SRCX} hmm2.%.${SRC_GIVEN_TGTX}  ${HMM2_JPT_PREFIX}.%.${JOINTX}
	@_LOCAL=1 echo "Generating $@"
	RP_PSUB_OPTS="-${HMM2_CPT_CPUS} -N $@ ${PSUB_OPTS}" \
	${P_RES_MON} \
	${JOINT2COND_PHRASE_TABLE} \
		-sort \
		-prune1 100 \
		-hmm \
		-v -i -z \
		-1 ${SRC} -2 ${TGT} \
		${HMM2_SMOOTHERS} \
		-multipr fwd \
		-o $(subst .${SRC_2_TGTX}, , $@) \
		-ibm_l2_given_l1  $(filter %${TGT_GIVEN_SRCX}, $+) \
		-ibm_l1_given_l2  $(filter %${SRC_GIVEN_TGTX}, $+) \
		$(filter %${JOINT}.gz, $+) \
		>& log.$(basename $@)

${HMM2_CPT_PREFIX}.%.${TGT_2_SRCX}:  hmm2.%.${TGT_GIVEN_SRCX} hmm2.%.${SRC_GIVEN_TGTX}  ${HMM2_JPT_PREFIX}.%.${JOINTX}
	@_LOCAL=1 echo "Generating $@"
	RP_PSUB_OPTS="-${HMM2_CPT_CPUS} -N $@ ${PSUB_OPTS}" \
	${P_RES_MON} \
	${JOINT2COND_PHRASE_TABLE} \
		-sort \
		-prune1 100 \
		-hmm \
		-v -i -z \
		-1 ${SRC} -2 ${TGT} \
		${HMM2_SMOOTHERS} \
		-multipr rev \
		-o $(subst .${TGT_2_SRCX}, , $@) \
		-ibm_l2_given_l1  $(filter %${TGT_GIVEN_SRCX}, $+) \
		-ibm_l1_given_l2  $(filter %${SRC_GIVEN_TGTX}, $+) \
		$(filter %${JOINT}.gz, $+) \
		>& log.$(basename $@)



########################################
# HMM3 CONDITIONAL PHRASE TABLES => liang
# requires: hmm3 models and ibm2 JOINT frequency phrase table.
HMM3_SMOOTHERS ?= -s RFSmoother  -s ZNSmoother
HMM3_SMOOTHERS_DESCRIPTION ?= -rf-zn
HMM3_CPT_PREFIX ?= cpt.hmm3${HMM3_SMOOTHERS_DESCRIPTION}
HMM3_CPT_CPUS ?= 8

hmm3_cpt_list = $(foreach t, ${TRAIN_TM}, $(foreach d,${CPT_DIRECTION},${HMM3_CPT_PREFIX}.$t.$d))
hmm3_cpt_list: SHELL=${GUARD_SHELL}
hmm3_cpt_list:
	@echo ${hmm3_cpt_list}

.PHONY:  hmm3_cpt
hmm3_cpt: hmm3_jpt
hmm3_cpt: ${hmm3_cpt_list}

${HMM3_CPT_PREFIX}.%.${SRC_2_TGTX}:  hmm3.%.${TGT_GIVEN_SRCX} hmm3.%.${SRC_GIVEN_TGTX}  ${HMM3_JPT_PREFIX}.%.${JOINTX}
	@_LOCAL=1 echo "Generating $@"
	RP_PSUB_OPTS="-${HMM3_CPT_CPUS} -N $@ ${PSUB_OPTS}" \
	${P_RES_MON} \
	${JOINT2COND_PHRASE_TABLE} \
		-sort \
		-prune1 100 \
		-hmm \
		-v -i -z \
		-1 ${SRC} -2 ${TGT} \
		${HMM3_SMOOTHERS} \
		-multipr fwd \
		-o $(subst .${SRC_2_TGTX}, , $@) \
		-ibm_l2_given_l1  $(filter %${TGT_GIVEN_SRCX}, $+) \
		-ibm_l1_given_l2  $(filter %${SRC_GIVEN_TGTX}, $+) \
		$(filter %${JOINT}.gz, $+) \
		>& log.$(basename $@)

${HMM3_CPT_PREFIX}.%.${TGT_2_SRCX}:  hmm3.%.${TGT_GIVEN_SRCX} hmm3.%.${SRC_GIVEN_TGTX}  ${HMM3_JPT_PREFIX}.%.${JOINTX}
	@_LOCAL=1 echo "Generating $@"
	RP_PSUB_OPTS="-${HMM3_CPT_CPUS} -N $@ ${PSUB_OPTS}" \
	${P_RES_MON} \
	${JOINT2COND_PHRASE_TABLE} \
		-sort \
		-prune1 100 \
		-hmm \
		-v -i -z \
		-1 ${SRC} -2 ${TGT} \
		${HMM3_SMOOTHERS} \
		-multipr rev \
		-o $(subst .${TGT_2_SRCX}, , $@) \
		-ibm_l2_given_l1  $(filter %${TGT_GIVEN_SRCX}, $+) \
		-ibm_l1_given_l2  $(filter %${SRC_GIVEN_TGTX}, $+) \
		$(filter %${JOINT}.gz, $+) \
		>& log.$(basename $@)






########################################
# Create Tightly Packed Phrase Table.
%.tppt: %.gz
	${P_RES_MON} \
	textpt2tppt.sh $< \
	2> log.$@




################################################################################
# HELPERS

########################################
# INVERT ANY CONDITIONAL PHRASE TABLE
#%.${TGT_2_SRCX}: %.${SRC_2_TGTX}
#	@echo "Generating $@"
#	zcat $< \
#	| reverse_cond_phr_tab.py \
#	| TMPDIR=. tmtext_sort.sh -1st - \
#	| gzip \
#	> $@



########################################
# INVERT ANY JOINT PHRASE TABLE
%.${TGT}-${SRC}.gz: %.${JOINT}.gz
	@_LOCAL=1 echo "Generating $@"
	RP_PSUB_OPTS="-1 -N $@" \
	zcat $< \
	| reverse_JOINT_phr_tab.py \
	| TMPDIR=. tmtext_sort.sh -1st - \
	| gzip \
	> $@
