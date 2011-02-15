#!/usr/bin/make -rf
# vim:noet:ts=3:nowrap
#
# $Id$
# @author Samuel Larkin
# @file Makefile
# @brief Master makefile for the framework, handles dependencies between modules.
#
# Technologies langagieres interactives / Interactive Language Technologies
# Inst. de technologie de l'information / Institute for Information Technology
# Conseil national de recherches Canada / National Research Council Canada
# Copyright 2008, Sa Majeste la Reine du Chef du Canada
# Copyright 2008, Her Majesty in Right of Canada

# Mandatory include: master config file.
include Makefile.params

# Lastly include the master toolkit
include Makefile.toolkit

.DEFAULT_GOAL := help
.DELETE_ON_ERROR:
.SUFFIXES:

.PHONY: all
all: tune
ifneq ($(strip ${TEST_SET}),)
all: eval
endif



.PHONY: help
help:
ifeq (${LM_TOOLKIT},IRST)
	@echo "Please run the following in order for this framework to run properly:"
	@echo "   export PATH=${IRSTLM}/bin:\$$PATH"
	@echo "   export IRSTLM=${IRSTLM}"
	@echo
endif
	@echo "Your corpora are:"
	@echo "   train lm: ${TRAIN_LM}"
	@echo "   train tm: ${TRAIN_TM}"
	@echo "   tune decode: ${TUNE_DECODE}"
	@echo "   tune rescore: ${TUNE_RESCORE}"
ifneq ($(strip ${TUNE_CE}),)
	@echo "   tune ce: ${TUNE_CE}"
endif
	@echo "   test set: ${TEST_SET}"
ifneq ($(strip ${TRANSLATE_SET}),)
	@echo "   translate set: ${TRANSLATE_SET}"
endif
	@echo
	@echo "To run the framework, type: make all"
	@echo
	@echo "The main targets in this Makefile are:"
	@cat $(firstword $(MAKEFILE_LIST)) | egrep '^.PHONY:' | sed 's#^.PHONY: #   #'



.PHONY: doc
doc: tutorial.pdf

%.pdf: %.tex
# latex is run twice so a correct table of contents is generated.
	TEXINPUTS=${PORTAGE}/texmf: pdflatex -interaction=batchmode $<
	TEXINPUTS=${PORTAGE}/texmf: pdflatex -interaction=batchmode $<

########################################
# Clean up
.PHONY: clean clean.content clean.doc clean.logs hide.logs
# Thorough cleaning of everything, including their old names
clean: SHELL=${GUARD_SHELL}
clean: clean.content clean.logs clean.doc
	${RM} tutorial.pdf framework-toy.pdf
	${RM} log.INSTALL_SUMMARY

# hide.logs hides logs from user's view into .logs
clean.content clean.logs hide.logs: SHELL=${GUARD_SHELL}
clean.content clean.logs hide.logs: %:
	${MAKE} -C corpora $@
	${MAKE} -C models $@
	${MAKE} -C translate $@

# Clean auxiliary files from make doc, but not the .pdf itself.
clean.doc: SHELL=${GUARD_SHELL}
clean.doc:
	${RM} tutorial.{aux,log,toc} framework-toy.{aux,log,toc}



########################################
# Prepare the corpora.
.PHONY: corpora
corpora: check_setup
	${MAKE} -C corpora all



# Create the Language Model (LM).
# Create models for truecasing (TC).
# Create the Translation Model (TM).
.PHONY: models lm ldm tc tm decode cow rescore rat confidence
tune models lm mixlm ldm tc tm decode cow rescore rat confidence: %: corpora
	${MAKE} -C models $@



.PHONY: translate
# Tune weights and apply them to the test sets
translate: tune
	${MAKE} -C translate all



.PHONY: eval
# Get BLEU scores for the test set(s)
eval: translate
	${MAKE} -C translate bleu



.PHONY: check_setup
check_setup:
	${MAKE} -C models/lm check_setup


########################################
# Copy the bin/INSTALL_SUMMARY file, if it exists.
ifneq ($(wildcard $(dir $(shell which train_ibm))/INSTALL_SUMMARY),)
check_setup: log.INSTALL_SUMMARY
endif

log.INSTALL_SUMMARY:
	cat `dirname $$(which train_ibm)`/INSTALL_SUMMARY >log.INSTALL_SUMMARY



########################################
# Prepare portageLive models.
# NOTE: In order to able to execute portageLive we should at the very least
# have tuned the system.  To do so, we will rely on the all target.
.PHONY: portageLive
portageLive: all
	${MAKE} -C models portageLive
ifdef DO_RESCORING
	@echo ""
	@echo "WARNING: the portageLive target does not install rescoring models."
	@echo "You will have to install them manually before you continue."
	@echo "Note that not all rescoring features are compatible with PortageLive."
	@echo ""
endif
	@echo "You now have all that is needed for PortageLive."
	@echo "From the framework root, run one of the following to"
	@echo "transfer your PortageLive models:"
	@echo "rsync -Larz models/portageLive/* <RHOST>:/<DEST_DIR_RHOST>"
	@echo "scp -r models/portageLive/* <RHOST>:/<DEST_DIR_RHOST>"
	@echo "cp -Lr models/portageLive/* /<DEST_DIR>"



########################################
# If you need to preprocess your corpora, you can call this target to do the job.
# The end result should be .al files .
PREPARE_CORPORA_MAKEFILE ?= Makefile.prepare.corpora
.PHONY: prepare.corpora
prepare.corpora:
	${MAKE} -C corpora -f ${PREPARE_CORPORA_MAKEFILE} all



########################################
# Resource Summary
.PHONY: resource_summary
resource_summary: SHELL=${GUARD_SHELL}
resource_summary: export PORTAGE_INTERNAL_CALL=1
resource_summary:
	@${MAKE} --no-print-directory -s -C models time-mem
	@${MAKE} --no-print-directory -s -C translate time-mem

.PHONY: time-mem
time-mem: SHELL=/bin/bash
time-mem: export PORTAGE_INTERNAL_CALL=1
time-mem:
	@echo "Resource summary for `pwd`:"
	@time-mem-tally.pl `find models translate -type f -name log.\* | sort` \
	| second-to-hms.pl \
	| expand-auto.pl

.PHONY: summary
summary: SHELL=/bin/bash
summary: export PORTAGE_INTERNAL_CALL=1
summary: time-mem
	@echo
	@echo "Disk usage for all models:"
	@if [[ ! -e models/portageLive ]]; then \
	   GLOBIGNORE=*/log.*; \
	      du -sch models/confidence/*.cem models/ldm models/*lm/*lm* \
	      models/tm/{ibm,hmm,jpt,cpt}* models/tc translate;\
	else \
	   GLOBIGNORE=*/log.*; \
	      du -sch models/confidence/*.cem models/ldm models/*lm/*lm* \
	      models/tm/{ibm,hmm,jpt,cpt}* models/tc models/decode/*.{tppt,gz} \
	      translate; \
	   echo; \
	   echo "Disk usage for portageLive models:"; \
	   du -hL models/portageLive; \
	fi

