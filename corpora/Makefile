#!/usr/bin/make -f
# vim:noet:ts=3

# Mandatory include: master config file.
include ../Makefile.params

# Include the config file.
MAKEFILE_PARAMS ?= Makefile.params
-include ${MAKEFILE_PARAMS}


# Change default make's shell for a distributed one.
SHELL = ${FRAMEWORK_SHELL}


# What command to use for lowercasing corpora.
LOWERCASE ?= utf8_casemap -c l


export LC_ALL ?= fr_CA.utf8


# Where are the raw corpora to process.
RAW_CORPORA_DIR ?= ./


# Tells make where to find the raw corpora files.
vpath %${RAWX} ${RAW_CORPORA_DIR}


# Help message
.PHONY: help
help: SHELL=${GUARD_SHELL}
help:
	echo "This script tokenizes and lowercases all corpora described by CORPORA_SET"
	echo "Type: make all"



.DELETE_ON_ERROR:
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
all: rule

# Defines what corpora we need truecased/tokenized for the truecase model.
.PHONY: tc
tc: $(addsuffix _${TGT_LANG}.tc${GZ}, ${TRAIN_TM})

# Defines what corpora we need in the entire pipeline.
.PHONY: lc
lc: $(addsuffix _${SRC_LANG}${LANGX}, ${HELDOUT_SET})
lc: $(addsuffix _${TGT_LANG}${LANGX}, ${HELDOUT_SET})
# Note that will want to compress the TRAIN_SET for space efficiency.
lc: $(addsuffix _${SRC_LANG}${LANGXZ}, ${TRAIN_TM})
lc: $(addsuffix _${TGT_LANG}${LANGXZ}, ${TRAIN_TM})
lc: $(addsuffix _${TGT_LANG}${LANGXZ}, ${TRAIN_LM})


# How to clean-up.
.PHONY: clean
clean:
	-${RM} *.tc *.tc${GZ} *${RULEX} *${LANGX} *${LANGXZ}


# Constructs a lowercased source corpora.
%_${SRC_LANG}.tc: %_${SRC_LANG}${RAWX}
	(file -biL $< | egrep -qi 'charset=utf-8') || (echo "Please convert $< to utf-8" && exit 1)
	cat $< | utokenize.pl -noss -lang=${SRC_LANG} > $@

# Constructs a lowercased target corpora.
%_${TGT_LANG}.tc: %_${TGT_LANG}${RAWX}
	(file -biL $< | egrep -qi 'charset=utf-8') || (echo "Please convert $< to utf-8" && exit 1)
	cat $< | utokenize.pl -noss -lang=${TGT_LANG} > $@


# Constructs a lowercased corpora from its tokenized version.
%${LANGX}: %.tc
	cat $< | ${LOWERCASE} > $@


# Add some markup to the source HELDOUT_SET.
# If you have special markup, this is where you would write your code.
.PHONY: rule
rule: $(addsuffix ${RULEX}, ${HELDOUT_SET})
%${RULEX}: %_${SRC_LANG}${LANGX}
	cat $< \
	| canoe-escapes.pl -add \
	> $@


# Special target to prepare a new translation set.
test: $(addprefix $(subst _${SRC_LANG},,$(basename ${TRANSLATE_SET})), ${RULEX} _${SRC_LANG}${LANGX})


# Special targte to prepare the reference.
reference: $(addprefix $(subst _${TGT_LANG},,$(basename ${TRANSLATE_SET})),  _${TGT_LANG}${LANGX})

