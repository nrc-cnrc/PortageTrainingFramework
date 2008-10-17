#!/usr/bin/make -f
# vim:noet:ts=3

# Include the config file.
MAKEFILE_PARAMS ?= Makefile.params
-include ${MAKEFILE_PARAMS}

# Let's make this usage on the cluster.
#SHELL = run-parallel.sh

# Defines the IRST environment variables.
# Where is IRSTLM located
export IRSTLM ?= /home/larkins/sandboxes/irstlm
# Where are IRSTLM's binaries located
BIN_DIR = ${IRSTLM}/bin

# What is the level of parallelism.
PARALLEL ?= 5

# What is the order of the required lm.
ORDER ?= 5

# Most steps require to load all the lm in memory, how many cpus should those jobs use.
CPUS ?= 2

# What type of lms to build
LM_TYPES ?= binlm

# What is the corpus' name, extension and what file defines this corpus.
CORPUS_NAME ?= gigaword
CORPUS_EXT  ?= .tok.al.gz
CORPUS_FILE ?= ${CORPUS_NAME}${CORPUS_EXT}
LM_NAME ?= ${CORPUS_NAME}-kn-${ORDER}g

# Where to find the corpus' file.
CORPORA_DIR ?= ../../corpora

# Allows to switch between a cluster distributed way of building the irstlm format.
#BUILD_LM_PGM ?= build-lm-qsub.sh
BUILD_LM_PGM ?= build-lm.sh

# This is to test the perplexity of the language models.
PPX_TEST_SET ?= test.txt

# Tells make where to find the corpus' file and the marked file if need be.
vpath %${CORPUS_EXT} ${CORPORA_DIR}
vpath %.marked.gz ${CORPORA_DIR}



.DELETE_ON_ERROR:



.PHONY: help
help: SHELL=bash
help:
	@echo "please run:"
	@echo "export PATH=${BIN_DIR}:$$PATH"
	@echo "export IRSTLM=${IRSTLM}"
	@echo "Then make all"
	@cat $(firstword $(MAKEFILE_LIST)) | egrep '^.PHONY:' | sed 's#^.PHONY: ##'



.PHONY: all
all: ${LM_TYPES}



.PHONY: all_lm
# All valid/possible LMs
all_lm: arpa
all_lm: blmt
all_lm: quantize
all_lm: Qblmt
all_lm: binlm



.PHONY: clean
clean: SHELL=bash



# How to clean the language models.
clean: clean.logs

# Sometimes we only want to get ride of the logs.
.PHONY: clean.logs
clean.logs: SHELL=bash
clean.logs:
	${RM} log.*



# Adds sentence start and end markers
.PHONY: mark
mark: ${CORPUS_NAME}.marked.gz

.SECONDARY: ${CORPUS_NAME}.marked.gz
${CORPUS_NAME}.marked.gz: ${CORPUS_FILE}
	echo "  Marking $<"; \
	zcat -f $< \
	| add-start-end.sh \
	| gzip -c \
	> $@

clean: clean.mark

.PHONY: clean.mark
clean.mark: SHELL=bash
clean.mark:
	${RM} ${CORPUS_NAME}.marked.gz



# iARPA
# Compressed irstlm format
.PHONY: irstlm
irstlm: ${CORPUS_NAME}.ilm.gz

.SECONDARY: ${CORPUS_NAME}.ilm.gz
%.ilm.gz: %.marked.gz
	RP_PSUB_OPTS="-${CPUS} -N $@" \
	echo "  Creating IRSTLM $@"; \
	mkdir -p stat; \
	IRSTLM=${IRSTLM} ${BUILD_LM_PGM} \
		-p \
		-n ${ORDER} \
		-k ${PARALLEL} \
		-s kneser-ney \
		-i "gunzip -c $<" \
		-o $@ \
	&> log.$(basename $@)

clean: clean.irstlm

.PHONY: clean.irstlm
clean.irstlm: SHELL=bash
clean.irstlm:
	${RM} ${CORPUS_NAME}.ilm.gz
	${RM} -r stat



# arpa text compressed format
.PHONY: arpa
arpa: ${CORPUS_NAME}.lm.gz

.SECONDARY: ${CORPUS_NAME}.lm.gz
ifdef LM_TOOLKIT_SRI
%.lm.gz: ${CORPUS_FILE}
	RP_PSUB_OPTS="-${CPUS} -N $@" \
	echo "  Creating ARPA text format $@"; \
	ngram-count \
		-interpolate \
		-kndiscount \
		-order ${ORDER} \
		-text $< \
		-lm $@ \
	>& log.$(basename $@)

else
%.lm.gz: %.ilm.gz
	RP_PSUB_OPTS="-${CPUS} -N $@" \
	echo "  Creating ARPA text format $@"; \
	( compile-lm \
		--text yes \
		$< \
		/dev/stdout \
	| sed -e 's/^\(ngram [0-9]=\) \([0-9][0-9]*\)/\1\2/' -e 's/^\(\\end\\\)/\n\1/' \
	| egrep -v 'Saving in txt format' \
	> $(basename $@) ) \
	&> log.$(basename $@); \
	lm_sort_filter.sh -lm $(basename $@) sorted.$@; \
	rm $(basename $@); \
	mv sorted.$@ $@
endif

clean: clean.arpa

.PHONY: clean.arpa
clean.arpa: SHELL=bash
clean.arpa:
	${RM} ${CORPUS_NAME}.lm.gz



# BINAIRY FORMAT
# arpa bin compressed format
.PHONY: blmt
blmt: ${CORPUS_NAME}.blmt

.SECONDARY: ${CORPUS_NAME}.blmt
%.blmt: %.ilm.gz
	RP_PSUB_OPTS="-${CPUS} -N $@" \
	echo "  Creating bin.ARPA format $@"; \
	compile-lm \
		$< \
		$@ \
	&> log.$@

clean: clean.blmt

.PHONY: clean.blmt
clean.blmt: SHELL=bash
clean.blmt:
	${RM} ${CORPUS_NAME}.blmt



# qARPA format
.PHONY: quantize
quantize: $(CORPUS_NAME).qlm.gz

.SECONDARY: ${CORPUS_NAME}.qlm.gz
%.qlm: %.lm.gz
	RP_PSUB_OPTS="-${CPUS} -N $@" \
	echo "  qARPA $< to $@"; \
	quantize-lm \
		$< \
		$@ \
	&> log.$@

clean: clean.quantize

.PHONY: clean.quantize
clean.quantize: SHELL=bash
clean.quantize:
	${RM} $(CORPUS_NAME).qlm.gz



# Quantinze binairy
.PHONY: Qblmt
Qblmt: ${CORPUS_NAME}.Qblmt

.SECONDARY: ${CORPUS_NAME}.Qblmt
%.Qblmt: %.qlm.gz
	RP_PSUB_OPTS="-${CPUS} -N $@" \
	echo "  bin.qARPA $< to $@"; \
	compile-lm \
		$< \
		$@ \
	&> log.$@

clean: clean.Qblmt

.PHONY: clean.Qblmt
clean.Qblmt: SHELL=bash
clean.Qblmt:
	${RM} ${CORPUS_NAME}.Qblmt



# Sort the arpa format
.PHONY: sort_arpa
sort_arpa: ${CORPUS_NAME}.lm.sorted.gz

.SECONDARY: ${CORPUS_NAME}.lm.sorted.gz
%.lm.sorted.gz: %.lm.gz
	lm_sort_filter.sh -lm $< $@ >& log.$(basename $@)

clean: clean.sort_arpa

.PHONY: clean.sort_arpa
clean.sort_arpa: SHELL=bash
clean.sort_arpa:
	${RM} ${CORPUS_NAME}.lm.sorted.gz



# Portage's bin lm format
.PHONY: binlm
binlm: ${CORPUS_NAME}.binlm.gz

.SECONDARY: %.binlm.gz
%.binlm.gz: %.lm.gz
	RP_PSUB_OPTS="-${CPUS} -N $@" \
	lmtext2binlm $< $@ >& log.$(basename $@)

clean: clean.binlm

.PHONY: clean.binlm
clean.binlm: SHELL=bash
clean.binlm:
	${RM} ${CORPUS_NAME}.binlm.gz



# Pruning ARPA format => ARPA format
.PHONY: prune
prune: ${CORPUS_NAME}.plm.gz

.SECONDARY: %.plm.gz
%.plm.gz: %.lm.gz
	RP_PSUB_OPTS="-${CPUS} -N $@" \
	prune-lm --threshold=1e-6 $< /dev/stdout \
	| gzip \
	> $@



########################################
# HELPERS
# Check if the environment is set
.PHONY: test
test: SHELL=bash
test:
	env | grep IRSTLM



# How to compress a file.
%.gz: %
	echo "  Compressing $< to $@"; \
	cat $< \
	| gzip \
	> $@



# A more general way of creating a marked corpus.
# To keep in case the user calls the scipts with a target that doesn't uses
# CORPUS_NAME/CORPUS_FILE.
%.marked.gz: %.gz
	echo "  Marking $<"; \
	zcat $< \
	| add-start-end.sh \
	| gzip -c \
	> $@



################################################################################
# The following targets are unmaintained and were used for initial testing of
# irstlm.
########################################
# PERPLEXITY
.PHONY: ppx
ppx: $(addprefix ppx.irstlm.${CORPUS_NAME}, .lm.gz .blmt .qlm.gz .Qblmt)
ppx.irstlm.%: ${PPX_TEST_SET} %
	compile-lm $* --eval=$< >& $(basename $@)
