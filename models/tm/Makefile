#!/usr/bin/make -f
# vim:noet:ts=3
#
# Technologies langagieres interactives / Interactive Language Technologies
# Inst. de technologie de l'information / Institute for Information Technology
# Conseil national de recherches Canada / National Research Council Canada
# Copyright 2008, Sa Majeste la Reine du Chef du Canada
# Copyright 2008, Her Majesty in Right of Canada


# Source file requirements
# <PREFIX>_<LANGUAGE>.<LANGX>
 
# Mandatory include: master config file.
include ../../Makefile.params

# Include the config file.
MAKEFILE_PARAMS ?= Makefile.params
-include ${MAKEFILE_PARAMS}

# TODO: Make sure this Makefile works for Portage's cluster.
# This will require that run-parallel.sh -c RP_OPTS be functional.
SHELL = ${FRAMEWORK_SHELL}

export LANG   = en_CA.utf8
export LC_ALL = en_CA.utf8

# Define what type of phrase table we want to generate.
PT_TYPE ?= ibm2_cpt

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
all: ${PT_TYPE}



########################################
# CLEAN-UP
.PHONY: clean
clean: SHELL=${GUARD_SHELL}
clean:
	$(RM) run-parallel-log* log.* run-p.*



################################################################################
# MODELS
.PHONY: models
models: ibm1_model
models: ibm2_model
models: hmm_model
models: liang_model

########################################
# TRAINING THE IBM1 MODELS
# requires: source and target corpora.
IBM1_MODEL_EXTRAS ?=
.PHONY:  ibm1_model
ibm1_model: $(foreach t, ${TRAIN_TM}, $(foreach d, ${MODEL_DIRECTIONS}, ibm1.$t.$d.gz))
ibm1.%.${TGT_GIVEN_SRCX}:  %${SRCX} %${TGTX}
	_LOCAL=1 echo "Generating $@"
	RP_PSUB_OPTS="-1 -N $@ ${PSUB_OPTS}" \
	${CAT} -n ${PARALLELISM_LEVEL_TM} -pn ${PARALLELISM_LEVEL_TM} \
		-v \
		-n1 5 -n2 0 \
		${IBM1_MODEL_EXTRAS} \
		$@ \
		$^ \
		>& log.$(basename $@)

ibm1.%.${SRC_GIVEN_TGTX}:  %${SRCX} %${TGTX}
	_LOCAL=1 echo "Generating $@"
	RP_PSUB_OPTS="-1 -N $@ ${PSUB_OPTS}" \
	${CAT} -n ${PARALLELISM_LEVEL_TM} -pn ${PARALLELISM_LEVEL_TM} \
		-v -r \
		-n1 5 -n2 0 \
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
IBM2_MODEL_EXTRAS ?=
.PHONY:  ibm2_model
ibm2_model: $(foreach t, ${TRAIN_TM}, $(foreach d, ${MODEL_DIRECTIONS}, ibm2.$t.$d.gz))
ibm2.%.${TGT_GIVEN_SRCX}:  %${SRCX} %${TGTX} ibm1.%.${TGT_GIVEN_SRCX}
	_LOCAL=1 echo "Generating $@"
	RP_PSUB_OPTS="-1 -N $@ ${PSUB_OPTS}" \
	${CAT} -n ${PARALLELISM_LEVEL_TM} -pn ${PARALLELISM_LEVEL_TM} \
		-v -m \
		-n1 0 -n2 5 \
		-slen 20 -tlen 20 -bksize 20 \
		-i $(word 3, $+) \
		${IBM2_MODEL_EXTRAS} \
		$@ \
		$(wordlist 1, 2, $+) \
		>& log.$(basename $@)

ibm2.%.${SRC_GIVEN_TGTX}:  %${SRCX} %${TGTX} ibm1.%.${SRC_GIVEN_TGTX}
	_LOCAL=1 echo "Generating $@"
	RP_PSUB_OPTS="-1 -N $@ ${PSUB_OPTS}" \
	${CAT} -n ${PARALLELISM_LEVEL_TM} -pn ${PARALLELISM_LEVEL_TM} \
		-v -r \
		-n1 0 -n2 5 \
		-slen 20 -tlen 20 -bksize 20 \
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
# TRAINING THE HMM MODELS
# requires: source and target corpora and ibm1 models.
HMM_MODEL_EXTRAS ?=
.PHONY:  hmm_model
hmm_model: $(foreach t, ${TRAIN_TM}, $(foreach d, ${MODEL_DIRECTIONS}, hmm.$t.$d.gz))
hmm.%.${TGT_GIVEN_SRCX}:  %${SRCX} %${TGTX} ibm1.%.${TGT_GIVEN_SRCX}
	_LOCAL=1 echo "Generating $@"
	RP_PSUB_OPTS="-1 -N $@ ${PSUB_OPTS}" \
	${CAT} -n ${PARALLELISM_LEVEL_TM} -pn ${PARALLELISM_LEVEL_TM} \
		-v  \
		-n1 0 -n2 5 \
		-mimic default \
		-i $(word 3, $+) \
		${HMM_MODEL_EXTRAS} \
		$@ \
		$(wordlist 1, 2, $+) \
		>& log.$(basename $@)

hmm.%.${SRC_GIVEN_TGTX}:  %${SRCX} %${TGTX} ibm1.%.${SRC_GIVEN_TGTX}
	_LOCAL=1 echo "Generating $@"
	RP_PSUB_OPTS="-1 -N $@ ${PSUB_OPTS}" \
	${CAT} -n ${PARALLELISM_LEVEL_TM} -pn ${PARALLELISM_LEVEL_TM} \
		-v -r \
		-n1 0 -n2 5 \
		-mimic default \
		-i $(word 3, $+) \
		${HMM_MODEL_EXTRAS} \
		$@ \
		$(wordlist 1, 2, $+) \
		>& log.$(basename $@)

clean: clean.hmm

.PHONY: clean.hmm
clean.hmm: SHELL=${GUARD_SHELL}
clean.hmm:
	$(RM) hmm.*



########################################
# TRAINING THE LIANG MODELS
# requires: source and target corpora and ibm1 models.
LIANG_MODEL_EXTRAS ?=
.PHONY:  liang_model
liang_model: $(foreach t, ${TRAIN_TM}, $(foreach d, ${MODEL_DIRECTIONS}, liang.$t.$d.gz))
liang.%.${TGT_GIVEN_SRCX}:  %${SRCX} %${TGTX} ibm1.%.${TGT_GIVEN_SRCX}
	_LOCAL=1 echo "Generating $@"
	RP_PSUB_OPTS="-1 -N $@ ${PSUB_OPTS}" \
	${CAT} -n ${PARALLELISM_LEVEL_TM} -pn ${PARALLELISM_LEVEL_TM} \
		-v \
		-n1 0 -n2 5 \
		-mimic liang \
		-i $(word 3, $+) \
		${LIANG_MODEL_EXTRAS} \
		$@ \
		$(wordlist 1, 2, $+) \
		>& log.$(basename $@)

liang.%.${SRC_GIVEN_TGTX}:  %${SRCX} %${TGTX} ibm1.%.${SRC_GIVEN_TGTX}
	_LOCAL=1 echo "Generating $@"
	RP_PSUB_OPTS="-1 -N $@ ${PSUB_OPTS}" \
	${CAT} -n ${PARALLELISM_LEVEL_TM} -pn ${PARALLELISM_LEVEL_TM} \
		-v -r \
		-n1 0 -n2 5 \
		-mimic liang \
		-i $(word 3, $+) \
		${LIANG_MODEL_EXTRAS} \
		$@ \
		$(wordlist 1, 2, $+) \
		>& log.$(basename $@)

clean: clean.liang

.PHONY: clean.liang
clean.liang: SHELL=${GUARD_SHELL}
clean.liang:
	$(RM) liang.*



################################################################################
# JOINT PHRASE TABLES
.PHONY: jpts
jpts: ibm2_jpt
jpts: hmm_jpt
jpts: liang_jpt

clean: clean.jpts

.PHONY: clean.jpts
clean.jpts: SHELL=${GUARD_SHELL}
clean.jpts:
	$(RM) jpt.*
	${RM} -r JPTPAR*

########################################
# IBM2 JOINT PHRASE TABLES
# requires: ibm2 models, source and target corpora.
IBM2_JPT_PREFIX = jpt.ibm2

.PHONY:  ibm2_jpt
ibm2_jpt: $(foreach t, ${TRAIN_TM}, ${IBM2_JPT_PREFIX}.$t.${JOINTX})
${IBM2_JPT_PREFIX}.%.${JOINTX}:  ibm2.%.${TGT_GIVEN_SRCX} ibm2.%.${SRC_GIVEN_TGTX}  %${SRCX} %${TGTX}
	_LOCAL=1 echo "Generating $@"
	RP_PSUB_OPTS="-2 -N $@ ${PSUB_OPTS}" \
	gen-jpt-parallel.sh \
		-n ${PARALLELISM_LEVEL_TM} \
		-o $@ \
		GPT \
		-v -j -w 1 -m $M -ibm 2 \
		-1 ${SRC} -2 ${TGT} \
		$+ \
		2> log.$(basename $@)


########################################
# HMM JOINT PHRASE TABLES
# requires: hmm models, source and target corpora.
HMM_JPT_PREFIX=jpt.hmm

.PHONY:  hmm_jpt
hmm_jpt: $(foreach t, ${TRAIN_TM}, ${HMM_JPT_PREFIX}.$t.${JOINTX})
${HMM_JPT_PREFIX}.%.${JOINTX}:  hmm.%.${TGT_GIVEN_SRCX} hmm.%.${SRC_GIVEN_TGTX}  %${SRCX} %${TGTX}
	_LOCAL=1 echo "Generating $@"
	RP_PSUB_OPTS="-2 -N $@ ${PSUB_OPTS}" \
	gen-jpt-parallel.sh \
		-n ${PARALLELISM_LEVEL_TM} \
		-o $@ \
		GPT \
		-v -j -w 1 -m $M -hmm \
		-1 ${SRC} -2 ${TGT} \
		$+ \
		2> log.$(basename $@)


########################################
# LIANG JOINT PHRASE TABLES
# requires: liang models, source and target corpora.
LIANG_JPT_PREFIX=jpt.liang

.PHONY:  liang_jpt
liang_jpt: $(foreach t, ${TRAIN_TM}, ${LIANG_JPT_PREFIX}.$t.${JOINTX})
${LIANG_JPT_PREFIX}.%.${JOINTX}:  liang.%.${TGT_GIVEN_SRCX} liang.%.${SRC_GIVEN_TGTX}  %${SRCX} %${TGTX}
	_LOCAL=1 echo "Generating $@"
	RP_PSUB_OPTS="-2 -N $@ ${PSUB_OPTS}" \
	gen-jpt-parallel.sh \
		-n ${PARALLELISM_LEVEL_TM} \
		-o $@ \
		GPT \
		-v -j -w 1 -m $M -hmm \
		-1 ${SRC} -2 ${TGT} \
		$+ \
		2> log.$(basename $@)



################################################################################
# CONDITIONAL PHRASE TABLES
.PHONY: cpts
cpts: ibm2_cpt
cpts: hmm_cpt
cpts: liang_cpt

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
IBM2_CPT_PREFIX=cpt.ibm2${IBM2_SMOOTHERS_DESCRIPTION}

.PHONY:  ibm2_cpt
ibm2_cpt: $(foreach t, ${TRAIN_TM}, $(foreach d,${CPT_DIRECTION},${IBM2_CPT_PREFIX}.$t.$d))

${IBM2_CPT_PREFIX}.%.${SRC_2_TGTX}: ibm2.%.${TGT_GIVEN_SRCX} ibm2.%.${SRC_GIVEN_TGTX} ${IBM2_JPT_PREFIX}.%.${JOINTX}
	_LOCAL=1 echo "Generating $@"
	RP_PSUB_OPTS="-2 -N $@ ${PSUB_OPTS}" \
	joint2cond_phrase_tables \
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
	_LOCAL=1 echo "Generating $@"
	RP_PSUB_OPTS="-2 -N $@ ${PSUB_OPTS}" \
	joint2cond_phrase_tables \
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
# HMM CONDITIONAL PHRASE TABLES
# requires: hmm models and ibm2 JOINT frequency phrase table.
HMM_SMOOTHERS ?= -s RFSmoother  -s ZNSmoother  -s "KNSmoother 3"
HMM_SMOOTHERS_DESCRIPTION ?= -rf-zn-kn3
HMM_CPT_PREFIX=cpt.hmm${HMM_SMOOTHERS_DESCRIPTION}

.PHONY:  hmm_cpt
hmm_cpt: $(foreach t, ${TRAIN_TM}, $(foreach d,${CPT_DIRECTION},${HMM_CPT_PREFIX}.$t.$d))

${HMM_CPT_PREFIX}.%.${SRC_2_TGTX}: hmm.%.${TGT_GIVEN_SRCX} hmm.%.${SRC_GIVEN_TGTX} ${HMM_JPT_PREFIX}.%.${JOINTX}
	_LOCAL=1 echo "Generating $@"
	RP_PSUB_OPTS="-2 -N $@ ${PSUB_OPTS}" \
	joint2cond_phrase_tables \
		-sort \
		-prune1 100 \
		-hmm \
		-v -i -z \
		-1 ${SRC} -2 ${TGT} \
		${HMM_SMOOTHERS} \
		-multipr fwd \
		-o $(subst .${SRC_2_TGTX}, , $@) \
		-ibm_l2_given_l1  $(filter %${TGT_GIVEN_SRCX}, $+) \
		-ibm_l1_given_l2  $(filter %${SRC_GIVEN_TGTX}, $+) \
		$(filter %${JOINT}.gz, $+) \
		>& log.$(basename $@)

${HMM_CPT_PREFIX}.%.${TGT_2_SRCX}: hmm.%.${TGT_GIVEN_SRCX} hmm.%.${SRC_GIVEN_TGTX} ${HMM_JPT_PREFIX}.%.${JOINTX}
	_LOCAL=1 echo "Generating $@"
	RP_PSUB_OPTS="-2 -N $@ ${PSUB_OPTS}" \
	joint2cond_phrase_tables \
		-sort \
		-prune1 100 \
		-hmm \
		-v -i -z \
		-1 ${SRC} -2 ${TGT} \
		${HMM_SMOOTHERS} \
		-multipr rev \
		-o $(subst .${TGT_2_SRCX}, , $@) \
		-ibm_l2_given_l1  $(filter %${TGT_GIVEN_SRCX}, $+) \
		-ibm_l1_given_l2  $(filter %${SRC_GIVEN_TGTX}, $+) \
		$(filter %${JOINT}.gz, $+) \
		>& log.$(basename $@)



########################################
# LIANG CONDITIONAL PHRASE TABLES
# requires: liang models and ibm2 JOINT frequency phrase table.
LIANG_SMOOTHERS ?= -s RFSmoother  -s ZNSmoother  -s "KNSmoother 3"
LIANG_SMOOTHERS_DESCRIPTION ?= -rf-zn-kn3
LIANG_CPT_PREFIX=cpt.liang${LIANG_SMOOTHERS_DESCRIPTION}

.PHONY:  liang_cpt
liang_cpt: $(foreach t, ${TRAIN_TM}, $(foreach d,${CPT_DIRECTION},${LIANG_CPT_PREFIX}.$t.$d))

${LIANG_CPT_PREFIX}.%.${SRC_2_TGTX}:  liang.%.${TGT_GIVEN_SRCX} liang.%.${SRC_GIVEN_TGTX}  ${LIANG_JPT_PREFIX}.%.${JOINTX}
	_LOCAL=1 echo "Generating $@"
	RP_PSUB_OPTS="-2 -N $@ ${PSUB_OPTS}" \
	joint2cond_phrase_tables \
		-sort \
		-prune1 100 \
		-hmm \
		-v -i -z \
		-1 ${SRC} -2 ${TGT} \
		${LIANG_SMOOTHERS} \
		-multipr fwd \
		-o $(subst .${SRC_2_TGTX}, , $@) \
		-ibm_l2_given_l1  $(filter %${TGT_GIVEN_SRCX}, $+) \
		-ibm_l1_given_l2  $(filter %${SRC_GIVEN_TGTX}, $+) \
		$(filter %${JOINT}.gz, $+) \
		>& log.$(basename $@)

${LIANG_CPT_PREFIX}.%.${TGT_2_SRCX}:  liang.%.${TGT_GIVEN_SRCX} liang.%.${SRC_GIVEN_TGTX}  ${LIANG_JPT_PREFIX}.%.${JOINTX}
	_LOCAL=1 echo "Generating $@"
	RP_PSUB_OPTS="-2 -N $@ ${PSUB_OPTS}" \
	joint2cond_phrase_tables \
		-sort \
		-prune1 100 \
		-hmm \
		-v -i -z \
		-1 ${SRC} -2 ${TGT} \
		${LIANG_SMOOTHERS} \
		-multipr rev \
		-o $(subst .${TGT_2_SRCX}, , $@) \
		-ibm_l2_given_l1  $(filter %${TGT_GIVEN_SRCX}, $+) \
		-ibm_l1_given_l2  $(filter %${SRC_GIVEN_TGTX}, $+) \
		$(filter %${JOINT}.gz, $+) \
		>& log.$(basename $@)






################################################################################
# HELPERS

########################################
# INVERT ANY CONDITIONAL PHRASE TABLE
#%.${TGT_2_SRCX}: %.${SRC_2_TGTX}
#	echo "Generating $@"
#	zcat $< \
#	| reverse_cond_phr_tab.py \
#	| TMPDIR=. tmtext_sort.sh -1st - \
#	| gzip \
#	> $@



########################################
# INVERT ANY JOINT PHRASE TABLE
%.${TGT}-${SRC}.gz: %.${JOINT}.gz
	_LOCAL=1 echo "Generating $@"
	RP_PSUB_OPTS="-1 -N $@" \
	zcat $< \
	| reverse_JOINT_phr_tab.py \
	| TMPDIR=. tmtext_sort.sh -1st - \
	| gzip \
	> $@
