#!/usr/bin/make -f
# vim:noet:ts=3

# Include the config file.
MAKEFILE_PARAMS ?= Makefile.params
-include ${MAKEFILE_PARAMS}

# Let's make this usage on the cluster
#SHELL = run-parallel.sh

# Defines the IRST environment variables.
export IRSTLM ?= /home/larkins/exp/presentation.portage.pipeline/irstlm
BIN_DIR        = ${IRSTLM}/bin

# What is the level of parallelism.
PARALLEL ?= 5

# What is the order of the required lm.
ORDER ?= 5

# What is the corpus' name, extension and what file defines this corpus.
CORPUS_NAME ?= gigaword
CORPUS_EXT  ?= .tok.al.gz
CORPUS_FILE ?= ${CORPUS_NAME}${CORPUS_EXT}

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
help:
	@echo "please run:"
	@echo "export PATH=${BIN_DIR}:$$PATH"
	@echo "export IRSTLM=${IRSTLM}"
	@echo "Then make all"
	@cat $(firstword $(MAKEFILE_LIST)) | egrep '^.PHONY:' | sed 's#^.PHONY: ##'



.PHONY: all
# All valid/possible LMs
#all: arpa
#all: blmt
#all: quantize
#all: Qblmt
all: binlm



# How to clean the language models.
.PHONY: clean
clean: clean.logs

# Sometimes we only want to get ride of the logs.
.PHONY: clean.logs
clean.logs:
	${RM} log.*



# Adds sentence start and end markers
.PHONY: mark
mark: ${CORPUS_NAME}.marked.gz

.SECONDARY: ${CORPUS_NAME}.marked.gz
${CORPUS_NAME}.marked.gz: ${CORPUS_FILE}
	echo "  Marking $<"; \
	zcat $< \
	| add-start-end.sh \
	| gzip -c \
	> $@

clean: clean.mark

.PHONY: clean.mark
clean.mark:
	${RM} ${CORPUS_NAME}.marked.gz



# iARPA
# Compressed irstlm format
.PHONY: irstlm
irstlm: ${CORPUS_NAME}.ilm.gz

.SECONDARY: ${CORPUS_NAME}.ilm.gz
%.ilm.gz: %.marked.gz
	@echo "  Creating IRSTLM $@"; \
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
clean.irstlm:
	${RM} ${CORPUS_NAME}.ilm.gz
	${RM} -r stat



# arpa text compressed format
.PHONY: arpa
arpa: ${CORPUS_NAME}.arpalm.gz

.SECONDARY: ${CORPUS_NAME}.arpalm.gz
%.arpalm.gz: %.ilm.gz
	@echo "  Creating ARPA text format $@"; \
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

clean: clean.arpa

.PHONY: clean.arpa
clean.arpa:
	${RM} ${CORPUS_NAME}.arpalm.gz



# BINAIRY FORMAT
# arpa bin compressed format
.PHONY: blmt
blmt: ${CORPUS_NAME}.blmt

.SECONDARY: ${CORPUS_NAME}.blmt
%.blmt: %.ilm.gz
	echo "  Creating bin.ARPA format $@"; \
	compile-lm \
		$< \
		$@ \
	&> log.$@

clean: clean.blmt

.PHONY: clean.blmt
clean.blmt:
	${RM} ${CORPUS_NAME}.blmt



# qARPA format
.PHONY: quantize
quantize: $(CORPUS_NAME).qlm.gz

.SECONDARY: ${CORPUS_NAME}.qlm.gz
%.qlm: %.arpalm.gz
	@echo "  qARPA $< to $@"; \
	quantize-lm \
		$< \
		$@ \
	&> log.$@

clean: clean.quantize

.PHONY: clean.quantize
clean.quantize:
	${RM} $(CORPUS_NAME).qlm.gz



# Quantinze binairy
.PHONY: Qblmt
Qblmt: ${CORPUS_NAME}.Qblmt

.SECONDARY: ${CORPUS_NAME}.Qblmt
%.Qblmt: %.qlm.gz
	@echo "  bin.qARPA $< to $@"; \
	compile-lm \
		$< \
		$@ \
	&> log.$@

clean: clean.Qblmt

.PHONY: clean.Qblmt
clean.Qblmt:
	${RM} ${CORPUS_NAME}.Qblmt



# Sort the arpa format
.PHONY: sort_arpa
sort_arpa: ${CORPUS_NAME}.lm.sorted.gz

.SECONDARY: ${CORPUS_NAME}.lm.sorted.gz
%.lm.sorted.gz: %.arpalm.gz
	lm_sort_filter.sh -lm $< $@ &> log.$(basename $@)

clean: clean.sort_arpa

.PHONY: clean.sort_arpa
clean.sort_arpa:
	${RM} ${CORPUS_NAME}.lm.sorted.gz



# Portage's bin lm format
.PHONY: binlm
binlm: ${CORPUS_NAME}.binlm.gz

.SECONDARY: %.binlm.gz
%.binlm.gz: %.arpalm.gz
	lmtext2binlm $< $@ &> log.$(basename $@)

clean: clean.binlm

.PHONY: clean.binlm
clean.binlm:
	${RM} ${CORPUS_NAME}.binlm.gz



########################################
# HELPERS
# Check if the environment is set
.PHONY: test
test:
	env | grep IRSTLM



# How to compress a file.
%.gz: %
	echo "  Compressing $< to $@"
	cat $< \
	| gzip \
	> $@



# A more general way of creating a marked corpus.
# To keep in case the user calls the scipts with a target that doesn't uses
# CORPUS_NAME/CORPUS_FILE.
%.marked.gz: %.gz
	echo "  Marking $<"
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
	compile-lm $* --eval=$< &> $(basename $@)
