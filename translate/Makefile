#!/usr/bin/make -f
# vim:noet:ts=3

# Mandatory include: master config file.
include ../Makefile.params

# Include the config file.
MAKEFILE_PARAMS ?= Makefile.params
-include ${MAKEFILE_PARAMS}

# TODO: Make this Makefile work with run-parallel.sh -c
# SHELL = run-parallel.sh

# Define languages info.
#SRC_LANG ?= en
#TGT_LANG ?= fr
SRCX  ?= _${SRC_LANG}${LANGX}
TGTX  ?= _${TGT_LANG}${LANGX}
RULEX ?= _${SRC_LANG}.rule

# Define any value to the following variable if you are doing rescoring.
# If you are rescoring, there are some step that can be skipped to save cpu
# power :D.
#DO_RESCORING = 1

# What program to use to detokenize.
DETOKENIZER ?= udetokenize.pl

# Indicates where to find the canoe.ini template.
DECODING_MODEL_DIR      ?= ../models/decode
DECODING_MODEL          ?= canoe.ini.cow
DECODING_MODEL_TEMPLATE ?= ${DECODING_MODEL_DIR}/${DECODING_MODEL}

# Indidcates where to find the rescoring model.
RESCORING_MODEL_DIR ?= ../models/rescore
RESCORING_MODEL     ?= rescore-model

# Indicates where to find the IBM models.
IBM_DIR ?= ../../models/TM

# Will indicate to make where to find the SETs (dev & test & eval)
CORPORA_DIR ?= ../corpora

# Where to find the truecasing models.
TRUECASING_DIR ?= ../models/tc

# Indicates what are the test/eval set to be translated after having trained a decoder model and a rescoring model
TRANSLATE_SET ?= test1 test2

# Specific PSUB options
PSUB_OPTS ?= 

# Indicates the nbest list size.
NBEST_SIZE ?= 1000

# Number of parallel chunks to process.
PARALLELISM_LEVEL ?= 5

.SECONDARY:
.SUFFIXES:
.DELETE_ON_ERROR:

# Tells make where to find files that we've made in previous scripts/modules.
vpath %${SRCX} ${CORPORA_DIR}
vpath %${TGTX} ${CORPORA_DIR}
vpath %${RULEX} ${CORPORA_DIR}
vpath ${DECODING_MODEL} ${DECODING_MODEL_DIR}
vpath ${RESCORING_MODEL} ${RESCORING_MODEL_DIR}
vpath ${TRUECASING_LM} ${TRUECASING_DIR}
vpath ${TRUECASING_MAP} ${TRUECASING_DIR}



.PHONY: all
all: tc



# An alias that indicate what/how to translate the test sets.
.PHONY: translate
translate: out

# An alias to rescore testset.
.PHONY: rescore
rescore: rat



.PHONY: help
help: SHELL=bash
help:
	@echo "Translate the following testsets: $(addsuffix _${SRC_LANG}, ${TRANSLATE_SET})"
	@echo "Possible targets are:"
	@cat $(firstword $(MAKEFILE_LIST)) | egrep '^.PHONY:' | sed 's#^.PHONY: ##'
	@echo "Most likely you want to do either: make all or make translate."



# Clean up
.PHONY: clean
clean: SHELL=bash



########################################
# Clean the log files.
clean: clean.logs

.PHONY: clean.logs
clean.logs: SHELL=bash
clean.logs:
	-rm log.* run-parallel-logs*



########################################
# Create a specific canoe.ini per test set.
# You could add some specific target if you need to customize a canoe.ini.cow
# for a particular testset.
${DECODING_MODEL}.%: ${DECODING_MODEL}
	cat $< > $@
	configtool check $@
#	cat $< \
#	| perl -pe 's/\[stack\].*/[stack] 600/go; s/\[beam-threshold\].*/[beam-threshold] 0.00001/go;' \
#	| sed "s/dev-text1/$*/" \
#	> $@



########################################
# Translate testset without rescoring.
.PHONY: out
out: $(addsuffix .out, ${TRANSLATE_SET})
ifdef DO_RESCORING
# if we are doing rescoring, we can save us some work by going straight to
# rescoring and extracting the 1 best instead of calculating it twice.
%.out: %.rat
	cp workdir-$*_${SRC_LANG}.al-${NBEST_SIZE}best/1best $@
else
%.out: ${DECODING_MODEL}.% %${RULEX}
	echo "Generating $@"
	canoe-parallel.sh \
		-lb \
		-n ${PARALLELISM_LEVEL} \
		canoe \
		-f $< \
		< $(word 2, $^) \
		> $@ \
		2> log.$@
endif

.PHONY: out.bleu
out.bleu: $(addsuffix .out.bleu, ${TRANSLATE_SET})
%.out.bleu: %.out %${TGTX}
	@echo "Calculating BLEU for $@"
	bleumain $^ > $@

.PHONY: out.detok
out.detok: $(addsuffix .out.detok, ${TRANSLATE_SET})
%.out.detok: %.out
	@echo "Detokenizing $<"
	${DETOKENIZER} -lang=${TGT_LANG} $< $@

.PHONY: out.detok.bleu
out.detok.bleu: $(addsuffix .out.detok.bleu, ${TRANSLATE_SET})
%.out.detok.bleu: %.out.detok %${TGTX}
	@echo "Calculating BLEU for $@"
	cat $(word 2, $+) \
	| utf8_casemap -c l \
	| bleumain $< - > $@

clean: clean.trans

.PHONY: clean.trans
clean.trans: $(foreach f, ${TRANSLATE_SET}, clean.trans.$f)
clean.trans.%:
	-${RM} -f $*.out $*.out.bleu
	-${RM} -f $*.out.detok $*.out.detok.bleu



########################################
# Rescore the testset
.PHONY: rat
rat: $(addsuffix .rat, ${TRANSLATE_SET})
%.rat: ${DECODING_MODEL}.% ${RESCORING_MODEL} %${SRCX} %${RULEX}
	@echo "Generating $@"
	rat.sh \
		-lb \
		-n ${PARALLELISM_LEVEL} \
		trans \
		-v \
		-K ${NBEST_SIZE} \
		-msrc $(word 3, $+) \
		-f $(wordlist 1,2,$+) \
	>& log.$@
	mv $*${SRC_EXT}.rat $@

.PHONY: rat.bleu
rat.bleu: $(addsuffix .rat.bleu, ${TRANSLATE_SET})
%.rat.bleu: %.rat %${TGTX}
	@echo "Calculating BLEU for $@"
	bleumain $^ > $@

.PHONY: rat.detok
rat.detok: $(addsuffix .rat.detok, ${TRANSLATE_SET})
%.rat.detok: %.rat
	@echo "Detokenizing $<"
	${DETOKENIZER} -lang=${TGT_LANG} $< $@

.PHONY: rat.detok.bleu
rat.detok.bleu: $(addsuffix .rat.detok.bleu, ${TRANSLATE_SET})
%.rat.detok.bleu: %.rat.detok %${TGTX}
	@echo "Calculating BLEU for $@"
	cat $(word 2, $+) \
	| utf8_casemap -c l \
	| bleumain $< - > $@

clean: clean.rescore_trans

.PHONY: clean.rescore_trans
clean.rescore_trans: $(foreach f, ${TRANSLATE_SET}, clean.rescore_trans.$f)
clean.rescore_trans.%:
	${RM} -rf $*.rat $*.rat.bleu
	-${RM} -f $*.rat.detok $*.rat.detok.bleu



########################################
# TRUECASING
.PHONY: tc
tc: $(addsuffix .out.tc, ${TRANSLATE_SET})
ifdef DO_RESCORING
tc: $(addsuffix .rat.tc, ${TRANSLATE_SET})
endif
%.tc: % ${TRUECASING_LM} ${TRUECASING_MAP}
	@echo "TrueCasing $@"
	truecase.pl \
		-text=$(word 1, $^) \
		-lm=$(word 2, $^) \
		-map=$(word 3, $^) \
		> $@ 



########################################
# HELPERS
# Check the canoe.ini config file.
.PHONY: configtool
configtool: ${DECODING_MODEL_TEMPLATE}
	configtool check $<



########################################
# LINKS THE IBMX MODELS
# ibm2.ch_given_en.gz ibm2.ch_given_en.pos.gz
# ibm2.en_given_ch.gz ibm2.en_given_ch.pos.gz
ibm2.%.gz:
	ln -sf ${IBM_DIR}/ibm2.*$*.gz ibm2.$*.gz 
	ln -sf ${IBM_DIR}/ibm2.*$*.pos.gz ibm2.$*.pos.gz

ibm1.%.gz:
	ln -sf ${IBM_DIR}/ibm1.*$*.gz ibm1.$*.gz 



# Tries to run all targets in this Makefile mainly to check the syntax of all
# targets.
.PHONY: full
full: out.bleu
full: out.detok.bleu
full: rat.bleu
full: rat.detok.bleu
full: configtool
