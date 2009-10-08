#!/usr/bin/make -f
# vim:noet:ts=3

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

-include Makefile.params

WTU ?= 10
WTG ?= 10
WT1 ?= 10
WT2 ?= 10

SAMPLE_SIZE ?= 64

all: dm

# Where % = is the word alignment model type.
counts.%.gz:
	parallelize.pl \
		-n 50 \
		-s ../../corpora/train_en.lc.gz \
		-s ../../corpora/train_fr.lc.gz \
		'dmcount -v -m 8 $*.train.fr_given_en.gz $*.train.en_given_fr.gz ../../corpora/train_en.lc.gz ../../corpora/train_fr.lc.gz > $@'

.PHONY: dm
dm: dm.hmm1+ibm2.en2fr.gz
dm.hmm1+ibm2.en2fr.gz: SHELL=run-parallel.sh
dm.hmm1+ibm2.en2fr.gz: counts.ibm2.gz counts.hmm1.gz
	RP_PSUB_OPTS="-4"\
	zcat -f $+ \
	| dmestm -s -g $(basename $@).bkoff -wtu ${WTU} -wtg ${WTG} -wt1 ${WT1} -wt2 ${WT2} \
	| gzip \
	> $@



########################################
# TUNE
TUNE_RESULTS_DIR ?= tune.results
TUNE_SET ?= dev1
vpath %_en.lc ../../corpora
vpath %_fr.lc ../../corpora

.PHONY: tune
tune: log.tune-dms
	@egrep -o 'ppx = [0-9\.]+' ${TUNE_RESULTS_DIR}/* | sort -g -k 3,3n | head -n 1

log.tune-dms: tune-dms.cmds
	run-parallel.sh -psub "-2" $< `wc -l < $<` >& log.tune-dms

count.tune.hmm1+ibm2.gz: count.tune.hmm1.gz count.tune.ibm2.gz 
	zcat $+ | gzip > $@

count.tune.%.gz: $(addprefix ${TUNE_SET},_en.lc _fr.lc)
	dmcount -v -m 8 $*.train.fr_given_en.gz $*.train.en_given_fr.gz $+ \
	| gzip > $@

tune-dms.cmds: counts.ibm2.gz counts.hmm1.gz count.tune.hmm1+ibm2.gz
	mkdir -p ${TUNE_RESULTS_DIR}
	for wtu in 5 10 15 20; do for wtg in 5 10 15 20; do for wt1 in 5 10 15 20; do for wt2 in 5 10 15 20; do \
		echo -n "test -f ${TUNE_RESULTS_DIR}/res.tune.$$wtu.$$wtg.$$wt1.$$wt2 || "; \
		echo "(zcat -f $(wordlist 1,2,$+) | dmestm -eval $(word 3,$+) -wtu $$wtu  -wtg $$wtg  -wt1 $$wt1  -wt2 $$wt2  > /dev/null ) >& ${TUNE_RESULTS_DIR}/res.tune.$$wtu.$$wtg.$$wt1.$$wt2"; \
	done; done; done; done | shuf | head -${SAMPLE_SIZE} > $@
	echo -n "test -f ${TUNE_RESULTS_DIR}/res.tune.20.20.20.20 || " >> $@
	echo "(zcat -f $(wordlist 1,2,$+) | dmestm -eval $(word 3,$+) -wtu 20  -wtg 20  -wt1 20  -wt2 20  > /dev/null ) >& ${TUNE_RESULTS_DIR}/res.tune.20.20.20.20" >> $@
