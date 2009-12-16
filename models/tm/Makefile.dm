#!/usr/bin/make -f
# vim:noet:ts=3:nowrap
# $Id$
#
# @author Samuel Larkin
# @file Makefile.dm
# @brief Train Lexicalized Distortion Models.
#
# Technologies langagieres interactives / Interactive Language Technologies
# Inst. de technologie de l'information / Institute for Information Technology
# Conseil national de recherches Canada / National Research Council Canada
# Copyright 2009, Sa Majeste la Reine du Chef du Canada
# Copyright 2009, Her Majesty in Right of Canada

# doing en 2 fr

# dmcount [options] ibm_lang2_given_lang1 ibm_lang1_given_lang2
#                   file1_lang1 file1_lang2 ... fileN_lang1 fileN_lang2
# ibm2.train.en_given_fr.gz

# parallelize.pl \
#    -s src_in \
#    -s tgt_in \
#    -m src_out \
#    -m tgt_out \
#    'filter_training_corpus src_in tgt_in src_out tgt_out 100 9'

include ../../Makefile.params
-include Makefile.params

WTU ?= 5
WTG ?= 5
WT1 ?= 5
WT2 ?= 5

SAMPLE_SIZE ?= 64

SRCX ?= _${SRC_LANG}${LANGX}
TGTX ?= _${TGT_LANG}${LANGX}
SRCXZ ?= ${SRCX}${GZ}
TGTXZ ?= ${TGTX}${GZ}

COUNT_PARALLEL_LEVEL ?= 30

# IBM / HMM models extension
SRC_GIVEN_TGT  = ${SRC_LANG}_given_${TGT_LANG}
TGT_GIVEN_SRC  = ${TGT_LANG}_given_${SRC_LANG}
SRC_GIVEN_TGTX = ${SRC_GIVEN_TGT}.gz
TGT_GIVEN_SRCX = ${TGT_GIVEN_SRC}.gz

# conditional phrase table extension
SRC_2_TGT  = ${SRC_LANG}2${TGT_LANG}
TGT_2_SRC  = ${TGT_LANG}2${SRC_LANG}
SRC_2_TGTX = ${SRC_2_TGT}.gz
TGT_2_SRCX = ${TGT_2_SRC}.gz

TUNE_RESULTS_DIR ?= tune.results
TUNE_SET ?= ${TUNE_DECODE}

CORPORA_DIR ?= ../../corpora

# Number of workers to use in parallel during tuning.
NUMBER_PARALLEL_WORKER ?= `wc -l < $<`
# Number of cpus per worker to use when tuning.
NUMBER_PARALLEL_CPU ?= 4

# Number of cpu to use to create the final model.
ESTIM_CPU ?= 4

# Resource monitoring.
P_RES_MON ?= p-res-mon.sh -t


vpath %${SRCXZ} ${CORPORA_DIR}
vpath %${TGTXZ} ${CORPORA_DIR}
vpath %${SRCX} ${CORPORA_DIR}
vpath %${TGTX} ${CORPORA_DIR}


.PHONY: all
all: dm

# Where % = is the word alignment model type.
counts.%.gz: ${TRAIN_TM}${SRCXZ} ${TRAIN_TM}${TGTXZ}
	parallelize.pl \
		-n ${COUNT_PARALLEL_LEVEL} \
		-s $(word 1, $+) \
		-s $(word 2, $+) \
		'dmcount -v -m 8 $*.${TRAIN_TM}.${TGT_GIVEN_SRCX} $*.${TRAIN_TM}.${SRC_GIVEN_TGTX} $+ > $@'


.PHONY: dm
dm: dm.hmm1+ibm2.${SRC_2_TGTX}
dm.hmm1+ibm2.${SRC_2_TGTX}: SHELL=${FRAMEWORK_SHELL}
dm.hmm1+ibm2.${SRC_2_TGTX}: counts.ibm2.gz counts.hmm1.gz
	RP_PSUB_OPTS="-${ESTIM_CPU}"\
	zcat -f $+ \
	| { ${P_RES_MON} dmestm -s -g $(basename $@).bkoff -wtu ${WTU} -wtg ${WTG} -wt1 ${WT1} -wt2 ${WT2}; } \
	| gzip \
	> $@ 2> log.$(basename $@)



########################################
# TUNE
.PHONY: tune
tune: log.tune-dms
	@egrep -o 'ppx = [0-9\.]+' ${TUNE_RESULTS_DIR}/* \
	| sort -g -k 3,3n \
	| head -n 1

log.tune-dms: tune-dms.cmds
	run-parallel.sh -psub "-${NUMBER_PARALLEL_CPU}" $< ${NUMBER_PARALLEL_WORKER} >& $@

count.tune.hmm1+ibm2.gz: count.tune.hmm1.gz count.tune.ibm2.gz 
	zcat $+ | gzip > $@

count.tune.%.gz: $(addprefix ${TUNE_SET},${SRCX} ${TGTX})
	dmcount -v -m 8 $*.${TRAIN_TM}.${TGT_GIVEN_SRCX} $*.${TRAIN_TM}.${SRC_GIVEN_TGTX} $+ \
	| gzip > $@

tune-dms.cmds: counts.ibm2.gz counts.hmm1.gz count.tune.hmm1+ibm2.gz
	mkdir -p ${TUNE_RESULTS_DIR}
	for wtu in 5 10 15 20; do for wtg in 5 10 15 20; do for wt1 in 5 10 15 20; do for wt2 in 5 10 15 20; do \
		echo -n "test -f ${TUNE_RESULTS_DIR}/res.tune.$$wtu.$$wtg.$$wt1.$$wt2 || "; \
		echo "(zcat -f $(wordlist 1,2,$+) | dmestm -eval $(word 3,$+) -wtu $$wtu  -wtg $$wtg  -wt1 $$wt1  -wt2 $$wt2  > /dev/null ) >& ${TUNE_RESULTS_DIR}/res.tune.$$wtu.$$wtg.$$wt1.$$wt2"; \
	done; done; done; done | shuf | head -${SAMPLE_SIZE} > $@
	echo -n "test -f ${TUNE_RESULTS_DIR}/res.tune.20.20.20.20 || " >> $@
	echo "(zcat -f $(wordlist 1,2,$+) | dmestm -eval $(word 3,$+) -wtu 20  -wtg 20  -wt1 20  -wt2 20  > /dev/null ) >& ${TUNE_RESULTS_DIR}/res.tune.20.20.20.20" >> $@

