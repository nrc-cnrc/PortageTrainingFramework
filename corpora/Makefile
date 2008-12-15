#!/usr/bin/make -f
# vim:noet:ts=3
#
# Technologies langagieres interactives / Interactive Language Technologies
# Inst. de technologie de l'information / Institute for Information Technology
# Conseil national de recherches Canada / National Research Council Canada
# Copyright 2008, Sa Majeste la Reine du Chef du Canada
# Copyright 2008, Her Majesty in Right of Canada


# Mandatory include: master config file.
include ../Makefile.params

# Include the config file.
MAKEFILE_PARAMS ?= Makefile.params
-include ${MAKEFILE_PARAMS}


# Change make's default shell to a distributed one, if working on a cluster.
SHELL = ${GUARD_SHELL}


# What command to use for lowercasing corpora.
ifdef ICU
LOWERCASE ?= utf8_casemap -c l
else
LOWERCASE ?= lc-utf8.pl
endif


export LC_ALL ?= fr_CA.utf8


# Where are the aligned corpora to process.
ALIGN_CORPORA_DIR ?= ./


# Tells make where to find the raw corpora files.
vpath %${ALIGNX} ${ALIGN_CORPORA_DIR}


# Help message
.PHONY: help
help: SHELL=${GUARD_SHELL}
help:
	@echo "This script tokenizes and lowercases all corpora described by CORPORA_SET"
	@echo "Type: make all"
	@echo
	@echo "The following are the main targets in this Makefile:"
	@cat $(firstword $(MAKEFILE_LIST)) | egrep '^.PHONY:' | sed 's#^.PHONY: ##'


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
all: lc
all: rule
ifdef DO_TRUECASING
all: tc
endif

# What the user can expect from this module.
list_final_output: SHELL=${GUARD_SHELL}
list_final_output:
	@echo "Expected final output are:"
	@echo ${LC}
	@echo ${RULE}
	@echo ${TC}

# Defines what corpora we need truecased/tokenized for the truecase model.
.PHONY: tc
TC = $(addsuffix _${TGT_LANG}.tc${GZ}, ${TRAIN_LM})
tc: ${TC}

# Defines what corpora we need in the entire pipeline.
.PHONY: lc
LC += $(addsuffix _${SRC_LANG}${LANGX}, ${HELDOUT_SET})
LC += $(addsuffix _${TGT_LANG}${LANGX}, ${HELDOUT_SET})
# Note that will want to compress the TRAIN_SET for space efficiency.
LC += $(addsuffix _${SRC_LANG}${LANGXZ}, ${TRAIN_TM})
LC += $(addsuffix _${TGT_LANG}${LANGXZ}, ${TRAIN_TM})
LC += $(addsuffix _${TGT_LANG}${LANGXZ}, ${TRAIN_LM})
lc: ${LC}


# Tokenizes source corpora without sentence splitting.
%_${SRC_LANG}.tc: %_${SRC_LANG}${ALIGNX}
	(file -biL $< | egrep -qi 'charset=utf-8') || (echo "Please convert $< to utf-8" && exit 1) \
	&& cat $< | utokenize.pl -noss -lang=${SRC_LANG} > $@

# Tokenizes target corpora without sentence splitting.
%_${TGT_LANG}.tc: %_${TGT_LANG}${ALIGNX}
	(file -biL $< | egrep -qi 'charset=utf-8') || (echo "Please convert $< to utf-8" && exit 1) \
	&& cat $< | utokenize.pl -noss -lang=${TGT_LANG} > $@


# Prepare truecased file.
%.tc: %${ALIGNX}
	${check_utf8}
	cp $< $@

# Constructs a lowercased source corpora.
%_${SRC_LANG}.tc: %_${SRC_LANG}${ALIGNX}
	(file -biL $< | egrep -qi 'charset=utf-8') || (echo "Please convert $< to utf-8" && exit 1); \
	cat $< | utokenize.pl -noss -lang=${SRC_LANG} > $@

%.tc${GZ}: %${ALIGNX}${GZ}
	${check_utf8}
	cp $< $@


# Constructs a lowercased corpora from its aligned version.
%${LANGX}: %${ALIGNX}
	$(check_utf8)
	cat $< | ${LOWERCASE} > $@

%${LANGXZ}: %${ALIGNX}${GZ}
	$(check_utf8)
	zcat $< | ${LOWERCASE} | gzip > $@


# Add some markup to the source HELDOUT_SET.
# If you have special markup, this is where you would write your code.
.PHONY: rule
RULE = $(addsuffix ${RULEX}, ${HELDOUT_SET})
rule: ${RULE}
%${RULEX}: %_${SRC_LANG}${LANGX}
	$(check_utf8)
	canoe-escapes.pl -add $< > $@


# Special target to prepare a new translation set.
translate: $(addprefix $(subst _${SRC_LANG},,$(basename ${TRANSLATE_SET})), ${RULEX} _${SRC_LANG}${LANGX})


# Special targte to prepare the reference.
reference: $(addprefix $(subst _${TGT_LANG},,$(basename ${TRANSLATE_SET})),  _${TGT_LANG}${LANGX})


# Check if the first dependency is a utf8 file.
define check_utf8
(file -Libz $< | egrep -qi 'charset=utf-8|ASCII') || (echo "Please convert $< to utf-8" && exit 1)
endef


# How to clean-up.
.PHONY: clean
clean: SHELL=${GUARD_SHELL}
clean:
	-${RM} *.tc *.tc${GZ} *${RULEX} *${LANGX} *${LANGXZ}
	-${RM} run-parallel-logs-*

