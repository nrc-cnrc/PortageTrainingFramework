#!/usr/bin/make -f
# vim:noet:ts=3

# Source file requirements
# <prefix>_<language>.<langx>
 
# Include the config file.
MAKEFILE_PARAMS ?= Makefile.params
-include ${MAKEFILE_PARAMS}

# TODO: Make sure this Makefile works for Portage's cluster.
# This will require that run-parallel.sh -c RP_OPTS be functional.
#SHELL = run-parallel.sh

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

# l1 and l2 must be in lexicographical order
src_lang ?= en
tgt_lang ?= fr
langx    ?= .tok.al
langxz   ?= ${langx}.gz

# Map source and target language to shorter variable name.
l1  ?= ${src_lang}
l2  ?= ${tgt_lang}
l1x ?= _${l1}${langxz}
l2x ?= _${l2}${langxz}

# IBM / HMM models extension
l1_given_l2  = ${l1}_given_${l2}
l2_given_l1  = ${l2}_given_${l1}
l1_given_l2x = ${l1_given_l2}.gz
l2_given_l1x = ${l2_given_l1}.gz

# conditional phrase table extension
l1_2_l2  = ${l1}2${l2}
l2_2_l1  = ${l2}2${l1}
l1_2_l2x = ${l1_2_l2}.gz
l2_2_l1x = ${l2_2_l1}.gz

# Joint phrase table extension
joint  = ${l1}-${l2}
jointx = ${joint}.gz

# What parallel corpora is to be used for creating the models
TRAIN_TM ?= train

# This should always reflect models in both directions as both direction are required.
MODEL_DIRECTIONS ?= ${l2_given_l1} ${l1_given_l2}

# Define the following variable if you want to create forward and backward phrase tables
ifdef CPT_BIDIRECTIONAL
# To get both directions
CPT_DIRECTION ?= ${l2_2_l1x}
else
# To get l1 to l2 direction
CPT_DIRECTION ?= ${l1_2_l2x}
endif

# Allows to search for alignment files in corpus
vpath %${l1x} ${CORPORA_DIR}
vpath %${l2x} ${CORPORA_DIR}


.SUFFIXES:
.SECONDARY:


.PHONY: all
all: ${PT_TYPE}


########################################
# HELP OPTIONS
.PHONY: help
help: SHELL=bash
help:
	@echo "Available targets are:"
	@cat $(firstword $(MAKEFILE_LIST)) | egrep '^.PHONY:' | sed 's#^.PHONY: ##'



########################################
# CLEAN-UP
.PHONY: clean
clean: SHELL=bash
clean:
	$(RM) run-parallel-log* log.* cpt.* ibm?.* jpt.* liang.* hmm.*



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
.PHONY:  ibm1_model
ibm1_model: $(foreach t, ${TRAIN_TM}, $(foreach d, ${MODEL_DIRECTIONS}, ibm1.$t.$d.gz))
ibm1.%.${l2_given_l1x}:  %${l1x} %${l2x}
	RP_PSUB_OPTS="-1 -N $@ ${PSUB_OPTS}" \
	echo "Generating $@"; \
	${CAT} -n 5 -pn 5 \
		-v -m \
		-n1 5 -n2 0 \
		$@ \
		$^ \
		>& log.$(basename $@)

ibm1.%.${l1_given_l2x}:  %${l1x} %${l2x}
	RP_PSUB_OPTS="-1 -N $@ ${PSUB_OPTS}" \
	echo "Generating $@"; \
	${CAT} -n 5 -pn 5 \
		-v -r -m \
		-n1 5 -n2 0 \
		$@ \
		$^ \
		>& log.$(basename $@)



########################################
# TRAINING THE IBM2 MODELS
# requires: source and target corpora and ibm1 models.
.PHONY:  ibm2_model
ibm2_model: $(foreach t, ${TRAIN_TM}, $(foreach d, ${MODEL_DIRECTIONS}, ibm2.$t.$d.gz))
ibm2.%.${l2_given_l1x}:  %${l1x} %${l2x} ibm1.%.${l2_given_l1x}
	RP_PSUB_OPTS="-1 -N $@ ${PSUB_OPTS}" \
	echo "Generating $@"; \
	${CAT} -n 5 -pn 5 \
		-v -m \
		-n1 0 -n2 5 \
		-slen 20 -tlen 20 -bksize 20 \
		-i $(word 3, $+) \
		$@ \
		$(wordlist 1, 2, $+) \
		>& log.$(basename $@)

ibm2.%.${l1_given_l2x}:  %${l1x} %${l2x} ibm1.%.${l1_given_l2x}
	RP_PSUB_OPTS="-1 -N $@ ${PSUB_OPTS}" \
	echo "Generating $@"; \
	${CAT} -n 5 -pn 5 \
		-v -r -m \
		-n1 0 -n2 5 \
		-slen 20 -tlen 20 -bksize 20 \
		-i $(word 3, $+) \
		$@ \
		$(wordlist 1, 2, $+) \
		>& log.$(basename $@)



########################################
# TRAINING THE HMM MODELS
# requires: source and target corpora and ibm1 models.
.PHONY:  hmm_model
hmm_model: $(foreach t, ${TRAIN_TM}, $(foreach d, ${MODEL_DIRECTIONS}, hmm.$t.$d.gz))
hmm.%.${l2_given_l1x}:  %${l1x} %${l2x} ibm1.%.${l2_given_l1x}
	RP_PSUB_OPTS="-1 -N $@ ${PSUB_OPTS}" \
	echo "Generating $@"; \
	${CAT} -n 5 -pn 5 \
		-v -m \
		-n1 0 -n2 5 \
		-mimic default \
		-i $(word 3, $+) \
		$@ \
		$(wordlist 1, 2, $+) \
		>& log.$(basename $@)

hmm.%.${l1_given_l2x}:  %${l1x} %${l2x} ibm1.%.${l1_given_l2x}
	RP_PSUB_OPTS="-1 -N $@ ${PSUB_OPTS}" \
	echo "Generating $@"; \
	${CAT} -n 5 -pn 5 \
		-v -r -m \
		-n1 0 -n2 5 \
		-mimic default \
		-i $(word 3, $+) \
		$@ \
		$(wordlist 1, 2, $+) \
		>& log.$(basename $@)



########################################
# TRAINING THE LIANG MODELS
# requires: source and target corpora and ibm1 models.
.PHONY:  liang_model
liang_model: $(foreach t, ${TRAIN_TM}, $(foreach d, ${MODEL_DIRECTIONS}, liang.$t.$d.gz))
liang.%.${l2_given_l1x}:  %${l1x} %${l2x} ibm1.%.${l2_given_l1x}
	RP_PSUB_OPTS="-1 -N $@ ${PSUB_OPTS}" \
	echo "Generating $@"; \
	${CAT} -n 5 -pn 5 \
		-v -m \
		-n1 0 -n2 5 \
		-mimic liang \
		-i $(word 3, $+) \
		$@ \
		$(wordlist 1, 2, $+) \
		>& log.$(basename $@)

liang.%.${l1_given_l2x}:  %${l1x} %${l2x} ibm1.%.${l1_given_l2x}
	RP_PSUB_OPTS="-1 -N $@ ${PSUB_OPTS}" \
	echo "Generating $@"; \
	${CAT} -n 5 -pn 5 \
		-v -r -m \
		-n1 0 -n2 5 \
		-mimic liang \
		-i $(word 3, $+) \
		$@ \
		$(wordlist 1, 2, $+) \
		>& log.$(basename $@)



################################################################################
# JOINT PHRASE TABLES
.PHONY: jpts
jpts: ibm2_jpt
jpts: hmm_jpt
jpts: liang_jpt

########################################
# IBM2 JOINT PHRASE TABLES
# requires: ibm2 models, source and target corpora.
IBM2_JPT_PREFIX = jpt.ibm2

#gen-jpt-parallel.sh -n 5 -o $@ GPT \
.PHONY:  ibm2_jpt
ibm2_jpt: $(foreach t, ${TRAIN_TM}, ${IBM2_JPT_PREFIX}.$t.${jointx})
${IBM2_JPT_PREFIX}.%.${jointx}:  ibm2.%.${l2_given_l1x} ibm2.%.${l1_given_l2x}  %${l1x} %${l2x}
	RP_PSUB_OPTS="-2 -N $@ ${PSUB_OPTS}" \
	echo "Generating $@"; \
	gen-jpt-parallel.sh \
		-n 5 \
		-o $@ \
		GPT \
		-v -j -w 1 -m $M -ibm 2 \
		-1 ${l1} -2 ${l2} \
		$+ \
		2> log.$(basename $@)


########################################
# HMM JOINT PHRASE TABLES
# requires: hmm models, source and target corpora.
HMM_JPT_PREFIX=jpt.hmm

.PHONY:  hmm_jpt
hmm_jpt: $(foreach t, ${TRAIN_TM}, ${HMM_JPT_PREFIX}.$t.${jointx})
${HMM_JPT_PREFIX}.%.${jointx}:  hmm.%.${l2_given_l1x} hmm.%.${l1_given_l2x}  %${l1x} %${l2x}
	RP_PSUB_OPTS="-2 -N $@ ${PSUB_OPTS}" \
	echo "Generating $@"; \
	gen-jpt-parallel.sh \
		-n 5 \
		-o $@ \
		GPT \
		-v -j -w 1 -m $M -hmm \
		-1 ${l1} -2 ${l2} \
		$+ \
		2> log.$(basename $@)


########################################
# LIANG JOINT PHRASE TABLES
# requires: liang models, source and target corpora.
LIANG_JPT_PREFIX=jpt.liang

.PHONY:  liang_jpt
liang_jpt: $(foreach t, ${TRAIN_TM}, ${LIANG_JPT_PREFIX}.$t.${jointx})
${LIANG_JPT_PREFIX}.%.${jointx}:  liang.%.${l2_given_l1x} liang.%.${l1_given_l2x}  %${l1x} %${l2x}
	RP_PSUB_OPTS="-2 -N $@ ${PSUB_OPTS}" \
	echo "Generating $@"; \
	gen-jpt-parallel.sh \
		-n 5 \
		-o $@ \
		GPT \
		-v -j -w 1 -m $M -hmm \
		-1 ${l1} -2 ${l2} \
		$+ \
		2> log.$(basename $@)



################################################################################
# JOINT PHRASE TABLES
.PHONY: cpts
cpts: ibm2_cpt
cpts: hmm_cpt
cpts: liang_cpt

########################################
# IBM CONDITIONAL PHRASE TABLES
# requires: ibm2 models and ibm2 joint frequency phrase table.
IBM2_SMOOTHERS ?= -s RFSmoother  -s ZNSmoother  -s "KNSmoother 3"
IBM2_SMOOTHERS_DESCRIPTION ?= -rf-zn-kn3
IBM2_CPT_PREFIX=cpt.ibm2${IBM2_SMOOTHERS_DESCRIPTION}

.PHONY:  ibm2_cpt
ibm2_cpt: $(foreach t, ${TRAIN_TM}, $(foreach d,${CPT_DIRECTION},${IBM2_CPT_PREFIX}.$t.$d))
${IBM2_CPT_PREFIX}.%.${l1_2_l2x}: ibm2.%.${l2_given_l1x} ibm2.%.${l1_given_l2x} ${IBM2_JPT_PREFIX}.%.${jointx}
	RP_PSUB_OPTS="-2 -N $@ ${PSUB_OPTS}" \
	echo "Generating $@"; \
	joint2cond_phrase_tables \
		-sort \
		-prune1 100 \
		-ibm 2 \
		-v -i -z \
		-1 ${l1} -2 ${l2} \
		${IBM2_SMOOTHERS} \
		-multipr fwd \
		-o tmp.$(subst .${l1_2_l2x},,$@) \
		-ibm_l2_given_l1  $(filter %${l2_given_l1x}, $+) \
		-ibm_l1_given_l2  $(filter %${l1_given_l2x}, $+) \
		$(filter %${joint}.gz, $+) \
		>& log.$(basename $@)



########################################
# HMM CONDITIONAL PHRASE TABLES
# requires: hmm models and ibm2 joint frequency phrase table.
HMM_SMOOTHERS ?= -s RFSmoother  -s ZNSmoother  -s "KNSmoother 3"
HMM_SMOOTHERS_DESCRIPTION ?= -rf-zn-kn3
HMM_CPT_PREFIX=cpt.hmm${HMM_SMOOTHERS_DESCRIPTION}

.PHONY:  hmm_cpt
hmm_cpt: $(foreach t, ${TRAIN_TM}, $(foreach d,${CPT_DIRECTION},${HMM_CPT_PREFIX}.$t.$d))
${HMM_CPT_PREFIX}.%.${l1_2_l2x}: hmm.%.${l2_given_l1x} hmm.%.${l1_given_l2x} ${HMM_JPT_PREFIX}.%.${jointx}
	RP_PSUB_OPTS="-2 -N $@ ${PSUB_OPTS}" \
	echo "Generating $@"; \
	joint2cond_phrase_tables \
		-sort \
		-prune1 100 \
		-hmm \
		-v -i -z \
		-1 ${l1} -2 ${l2} \
		${HMM_SMOOTHERS} \
		-multipr fwd \
		-o $(subst .${l1_2_l2x}, , $@) \
		-ibm_l2_given_l1  $(filter %${l2_given_l1x}, $+) \
		-ibm_l1_given_l2  $(filter %${l1_given_l2x}, $+) \
		$(filter %${joint}.gz, $+) \
		>& log.$(basename $@)



########################################
# LIANG CONDITIONAL PHRASE TABLES
# requires: liang models and ibm2 joint frequency phrase table.
LIANG_SMOOTHERS ?= -s RFSmoother  -s ZNSmoother  -s "KNSmoother 3"
LIANG_SMOOTHERS_DESCRIPTION ?= -rf-zn-kn3
LIANG_CPT_PREFIX=cpt.liang${LIANG_SMOOTHERS_DESCRIPTION}

.PHONY:  liang_cpt
liang_cpt: $(foreach t, ${TRAIN_TM}, $(foreach d,${CPT_DIRECTION},${LIANG_CPT_PREFIX}.$t.$d))
${LIANG_CPT_PREFIX}.%.${l1_2_l2x}:  liang.%.${l2_given_l1x} liang.%.${l1_given_l2x}  ${LIANG_JPT_PREFIX}.%.${jointx}
	RP_PSUB_OPTS="-2 -N $@ ${PSUB_OPTS}" \
	echo "Generating $@"; \
	joint2cond_phrase_tables \
		-sort \
		-prune1 100 \
		-hmm \
		-v -i -z \
		-1 ${l1} -2 ${l2} \
		${LIANG_SMOOTHERS} \
		-multipr fwd \
		-o $(subst .${l1_2_l2x}, , $@) \
		-ibm_l2_given_l1  $(filter %${l2_given_l1x}, $+) \
		-ibm_l1_given_l2  $(filter %${l1_given_l2x}, $+) \
		$(filter %${joint}.gz, $+) \
		>& log.$(basename $@)






################################################################################
# HELPERS

########################################
# INVERT ANY CONDITIONAL PHRASE TABLE
#%.${l2_2_l1x}: %.${l1_2_l2x}
#	echo "Generating $@"
#	zcat $< \
#	| reverse_cond_phr_tab.py \
#	| TMPDIR=. tmtext_sort.sh -1st - \
#	| gzip \
#	> $@



########################################
# INVERT ANY JOINT PHRASE TABLE
%.${l2}-${l1}.gz: %.${joint}.gz
	echo "Generating $@"
	zcat $< \
	| reverse_joint_phr_tab.py \
	| TMPDIR=. tmtext_sort.sh -1st - \
	| gzip \
	> $@
