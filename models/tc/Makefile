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

# Define LM_TOOLKIT_SRI if you want to use SRILM
#LM_TOOLKIT_SRI=1
# Make sure all Makefile knows about it.
export LM_TOOLKIT_SRI

# Typical lms for truecasing are 3g.
export ORDER = 3

# Where can we find the corpora?
vpath %.tc.gz ${CORPORA_DIR}
vpath %${LANGXZ} ${CORPORA_DIR}



#.INTERMEDIATE: ${TRAIN_LM}_${TGT_LANG}.marked.gz



.PHONY:
help: SHELL=bash
help:
	@echo "This script build a language model and a map for truecasing."
	@echo "Define LM_TOOLKIT_SRI=1 if you have and want to use SRILM instead of IRSTLM."
	@echo "type: make all"


.PHONY: all
all: ${TRUECASING_MAP}
all: ${TRUECASING_LM}



.PHONY: clean
clean: SHELL=bash
clean:
	-${RM} ${TRUECASING_MAP}
	${MAKE} -f ../lm/Makefile clean



# Build the truecased lm model using the convinient Makefile from models/lm.
%-kn-3g.binlm.gz:
	${MAKE} -f ../lm/Makefile $@



# Build a map file.
%.map:  %.tc.gz  %${LANGXZ}
	compile_truecase_map $+ > $@

