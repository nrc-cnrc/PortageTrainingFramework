#!/usr/bin/make -f
# vim:noet:ts=3

# Include the config file.
MAKEFILE_PARAMS ?= Makefile.params
-include ${MAKEFILE_PARAMS}


# Change default make's shell for a distributed one.
#SHELL = run-parallel.sh


# What command to use for lowercasing corpora.
LOWERCASE ?= "utf8_casemap -c l"


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

# Where src_lang/tgt_lang  ~ en/fr
# Where langx ~ .tok.al
# Where langxz ~ .tok.al.gz
#.INTERMEDIATE: $(addsuffix _${src_lang}${langx}, ${TRAIN_SET})
#.INTERMEDIATE: $(addsuffix _${tgt_lang}${langx}, ${TRAIN_SET})



# Defines all that needs to be done by this makefile.
.PHONY: all
all: tc
all: lc
#all: rule

# Defines what corpora we need truecased/tokenized for the truecase model.
.PHONY: tc
tc: $(addsuffix _${tgt_lang}.tc, ${TRAIN_TM})

# Defines what corpora we need in the entire pipeline.
.PHONY: lc
lc: $(addsuffix _${src_lang}${langx}, ${HELDOUT_SET})
lc: $(addsuffix _${tgt_lang}${langx}, ${HELDOUT_SET})
# Note that will want to compress the TRAIN_SET for space efficiency.
lc: $(addsuffix _${src_lang}${langxz}, ${TRAIN_SET})
lc: $(addsuffix _${tgt_lang}${langxz}, ${TRAIN_SET})


# How to clean-up.
.PHONY: clean
clean: clean.tok clean.al clean.rule clean${langx} clean${langxz}
clean.%:
	-${RM} *.$*


# Prepares a tokenized version of the target lm for the truecasing.
%.tc: %.tok
	cp $< $@


# Constructs a lowercased source corpora.
%_${src_lang}.tok: %_${src_lang}.raw
	(file -i $< | egrep -q 'charset=utf-8') || echo "Please convert $< to utf-8"
	cat $< | utokenize.pl -noss -lang=${src_lang} > $@

# Constructs a lowercased target corpora.
%_${tgt_lang}.tok: %_${tgt_lang}.raw
	(file -i $< | egrep -q 'charset=utf-8') || echo "Please convert $< to utf-8"
	cat $< | utokenize.pl -noss -lang=${tgt_lang} > $@


# Constructs a lowercased corpora from its tokenized version.
%${langx}: %.tok
	cat $< | ${LOWERCASE} > $@


# Add some markup to the source HELDOUT_SET.
.PHONY: rule
rule: $(addsuffix _${src_lang}.rule, ${HELDOUT_SET})
%.rule: %${langx}
	cat $< \
	| perl -pe 's/([<>\\])/\\$$1/g' \
	| perl -pe 's/(__ent_[a-zA-Z0-9_]+)/<STAG target="$$1" prob="1.0">$$1<\/STAG>/g' \
	> $@



########################################
# HELPERS
# How to compress a file.
%.gz: %
	cat $< | gzip > $@
