#!/usr/bin/make -rf
# vim:noet:ts=3

MAKEFILE_PARAMS ?= Makefile.params
-include ${MAKEFILE_PARAMS}

.PHONY: all
all: expts



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
	${MAKE} -C models/LM clean
	${MAKE} -C models/TM clean
	${MAKE} -C models/TC clean
	${MAKE} -C decode clean
	${MAKE} -C rescore clean
	${MAKE} -C translate clean



.PHONY: corpora
corpora:
	${MAKE} -C corpora all



.PHONY: models
models: lms tms



.PHONY: lms
# Create the Language Model (LM)
lms: lm.${tgt_lang}
lm.%: corpora
	${MAKE} -C models/LM binlm



.PHONY: tms
# Create the Translation Model (TM}
tms: corpora
	${MAKE} -C models/TM



.PHONY: translate
# Tune weights and apply them to the test sets
translate: tms lms
	${MAKE} -C translate
