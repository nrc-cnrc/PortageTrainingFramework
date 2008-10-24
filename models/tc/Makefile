#!/usr/bin/make -f
# vim:noet:ts=3

# Mandatory include: master config file.
include ../../Makefile.params

# Include the config file.
MAKEFILE_PARAMS ?= Makefile.params
-include ${MAKEFILE_PARAMS}

# Let's make this usage on the cluster.
#SHELL = run-parallel.sh

# Where to find the corpus' file.
CORPORA_DIR ?= ../../corpora

# Where can we find the corpora?
vpath %.tc.gz ${CORPORA_DIR}
vpath %${LANGXZ} ${CORPORA_DIR}



.PHONY: all
all: ${TRUECASING_MAP}
all: ${TRUECASING_LM}



# Build the truecased lm model using the convinient Makefile from models/lm.
%-kn-5g.binlm.gz:
	${MAKE} -f ../lm/Makefile $@



# Build a map file.
%.map:  %.tc.gz  %${LANGXZ}
	compile_truecase_map $+ > $@

