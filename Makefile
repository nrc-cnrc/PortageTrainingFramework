#!/usr/bin/make -rf
# vim:noet:ts=3

MAKEFILE_PARAMS ?= Makefile.params
-include ${MAKEFILE_PARAMS}

.PHONY: all
all: translate



.PHONY: help
help:
	@echo "please run in order for this framework to run properly:"
	@echo "export PATH=${IRSTLM}/bin:$$PATH"
	@echo "export IRSTLM=${IRSTLM}"
	@echo "Then make all"
	@cat $(firstword $(MAKEFILE_LIST)) | egrep '^.PHONY:' | sed 's#^.PHONY: ##'



.PHONY: clean
# Thorough cleaning of everything
clean:
	${MAKE} -C corpora clean
	${MAKE} -C models/lm clean
	${MAKE} -C models/tm clean
	${MAKE} -C models/tc clean
	${MAKE} -C models/decode clean
	${MAKE} -C models/rescore clean
	${MAKE} -C translate clean



.PHONY: corpora
corpora:
	${MAKE} -C corpora all



.PHONY: models
models: lms tms tc



.PHONY: lms
# Create the Language Model (LM).
lms: lm.${TGT_LANG}
ifdef BIDIRECTIONAL_SYSTEM
lms: lm.${SRC_LANG}
endif
lm.%: corpora
	${MAKE} -C models/lm binlm



.PHONY: tc
# Create models for truecasing (TC).
tc: corpora
	${MAKE} -C models/tc



.PHONY: tms
# Create the Translation Model (TM).
tms: corpora
	${MAKE} -C models/tm



.PHONY: tune
# Tune the required models.
tune: models
	${MAKE} -C models/decode
ifdef DO_RESCORING
	${MAKE} -C models/rescore
endif



.PHONY: translate
# Tune weights and apply them to the test sets
translate: models tune
	${MAKE} -C translate
