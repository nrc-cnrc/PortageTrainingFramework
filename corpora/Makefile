#!/usr/bin/make -f
# vim:noet:ts=3

# Mandatory include: master config file.
include ../Makefile.params

# Include the config file.
MAKEFILE_PARAMS ?= Makefile.params
-include ${MAKEFILE_PARAMS}


# Change default make's shell for a distributed one.
#SHELL = run-parallel.sh


# What command to use for lowercasing corpora.
LOWERCASE ?= utf8_casemap -c l


export LC_ALL ?= fr_CA.utf8


# Where are the raw corpora to process.
RAW_CORPORA_DIR ?= ./


# Tells make where to find the raw corpora.
vpath %.raw ${RAW_CORPORA_DIR}


# Help message
.PHONY: help
help:
	echo "This script tokenizes and lowercases all corpora described by CORPORA_SET"
	echo "Type: make all"



.SUFFIXES:
#.SECONDARY:

# Where SRC_LANG/TGT_LANG  ~ en/fr
# Where LANGX ~ .tok.al
# Where LANGXZ ~ .tok.al.gz
#.INTERMEDIATE: $(addsuffix _${SRC_LANG}${LANGX}, ${TRAIN_SET})
#.INTERMEDIATE: $(addsuffix _${TGT_LANG}${LANGX}, ${TRAIN_SET})



# Defines all that needs to be done by this makefile.
.PHONY: all
all: tc
all: lc
#all: rule

# Defines what corpora we need truecased/tokenized for the truecase model.
.PHONY: tc
tc: $(addsuffix _${TGT_LANG}.tc, ${TRAIN_TM})

# Defines what corpora we need in the entire pipeline.
.PHONY: lc
lc: $(addsuffix _${SRC_LANG}${LANGX}, ${HELDOUT_SET})
lc: $(addsuffix _${TGT_LANG}${LANGX}, ${HELDOUT_SET})
# Note that will want to compress the TRAIN_SET for space efficiency.
lc: $(addsuffix _${SRC_LANG}${LANGXZ}, ${TRAIN_SET})
lc: $(addsuffix _${TGT_LANG}${LANGXZ}, ${TRAIN_SET})


# How to clean-up.
.PHONY: clean
clean: clean.tok clean.al clean.rule clean${LANGX} clean${LANGXZ}
clean.%:
	-${RM} *.$*


# Prepares a tokenized version of the target lm for the truecasing.
%.tc: %.tok
	cp $< $@


# Constructs a lowercased source corpora.
%_${SRC_LANG}.tok: %_${SRC_LANG}.raw
	(file -i $< | egrep -q 'charset=utf-8') || echo "Please convert $< to utf-8"
	cat $< | utokenize.pl -noss -lang=${SRC_LANG} > $@

# Constructs a lowercased target corpora.
%_${TGT_LANG}.tok: %_${TGT_LANG}.raw
	(file -i $< | egrep -q 'charset=utf-8') || echo "Please convert $< to utf-8"
	cat $< | utokenize.pl -noss -lang=${TGT_LANG} > $@


# Constructs a lowercased corpora from its tokenized version.
%${LANGX}: %.tok
	cat $< | ${LOWERCASE} > $@


# Add some markup to the source HELDOUT_SET.
.PHONY: rule
rule: $(addsuffix _${SRC_LANG}.rule, ${HELDOUT_SET})
%.rule: %${LANGX}
	cat $< \
	| perl -pe 's/([<>\\])/\\$$1/g' \
	| perl -pe 's/(__ent_[a-zA-Z0-9_]+)/<STAG target="$$1" prob="1.0">$$1<\/STAG>/g' \
	> $@



########################################
# HELPERS
# How to compress a file.
%.gz: %
	cat $< | gzip > $@
