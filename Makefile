#!/usr/bin/make -rf
# vim:noet:ts=3:nowrap
#
# @author Samuel Larkin
# @file Makefile
# @brief Master makefile for the framework, handles dependencies between modules.
#
# Traitement multilingue de textes / Multilingual Text Processing
# Technologies de l'information et des communications /
#    Information and Communications Technologies
# Conseil national de recherches Canada / National Research Council Canada
# Copyright 2008, 2012, Sa Majeste la Reine du Chef du Canada
# Copyright 2008, 2012 Her Majesty in Right of Canada

# Mandatory include: master config file.
include Makefile.params

# Lastly include the master toolkit
include Makefile.toolkit

.DEFAULT_GOAL := help
.DELETE_ON_ERROR:
.SUFFIXES:

.PHONY: all
all: SHELL=${LOCAL_SHELL}
all: tune_main
ifneq ($(strip ${TEST_SET}),)
all: eval
endif
all:
	@echo "Training, tuning and translating using the framework are all done."


.PHONY: help
help: SHELL=${LOCAL_SHELL}
help:
ifeq (${LM_TOOLKIT},IRST)
	@echo "Please run the following in order for this framework to run properly:"
	@echo "   export PATH=${IRSTLM}/bin:\$$PATH"
	@echo "   export IRSTLM=${IRSTLM}"
	@echo
endif
	@echo "Your corpora are:"
	@echo "   train lm: ${TRAIN_LM}"
ifneq ($(strip ${MIXLM}),)
	@echo "   train mixlm: ${MIXLM}"
endif
ifneq ($(strip ${TRAIN_TC}),)
	@echo "   train tc: ${TRAIN_TC}"
endif
	@echo "   train tm: ${TRAIN_TM}"
ifneq ($(strip ${MIXTM}),)
	@echo "   train mixtm: ${MIXTM}"
endif
ifneq ($(strip ${MIXTM_TRAIN_MIX}),)
	@echo "   tune mixtm mix: ${MIXTM_TRAIN_MIX}"
endif
ifneq ($(strip ${TRAIN_LDM}),)
	@echo "   train ldm: ${TRAIN_LDM}"
endif
ifneq ($(strip ${TRAIN_HLDM}),)
	@echo "   train hldm: ${TRAIN_HLDM}"
endif
	@echo "   tune decode: ${TUNE_DECODE}"
ifneq ($(strip ${TUNE_DECODE_VARIANTS}),)
	@echo "   tune decode variants: $(addprefix ${TUNE_DECODE}, ${TUNE_DECODE_VARIANTS})"
endif
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
doc: SHELL=${LOCAL_SHELL}
doc: tutorial.pdf

%.pdf: SHELL=${LOCAL_SHELL}
%.pdf: %.tex
# latex actually needs to be run three times for the table of contents to be
# generated correctly (a trivial change on one line has a significant ripple
# effect to paging between the 1st and 2nd pass, so that several entries in the
# TOC are changed between the 2nd and 3rd pass).
	TEXINPUTS=${PORTAGE}/texmf: pdflatex -interaction=batchmode $<
	TEXINPUTS=${PORTAGE}/texmf: pdflatex -interaction=batchmode $<
	TEXINPUTS=${PORTAGE}/texmf: pdflatex -interaction=batchmode $<

########################################
# Clean up
.PHONY: clean clean.content clean.doc clean.logs hide.logs
# Thorough cleaning of everything, including their old names
clean: SHELL=${LOCAL_SHELL}
clean: clean.content clean.logs clean.doc
	${RM} tutorial.pdf
	${RM} log.INSTALL_SUMMARY

# hide.logs hides logs from user's view into .logs
clean.content clean.logs hide.logs: SHELL=${LOCAL_SHELL}
clean.content clean.logs hide.logs: %:
	${MAKE} -C corpora $@
	${MAKE} -C models $@
	${MAKE} -C translate $@
ifneq ($(strip ${TUNE_DECODE_VARIANTS}),)
	${RM} -r $(addprefix translate., ${TUNE_DECODE_VARIANTS})
endif

# Clean auxiliary files from make doc, but not the .pdf itself.
clean.doc: SHELL=${LOCAL_SHELL}
clean.doc:
	${RM} tutorial.{aux,log,toc,out}



########################################
# Prepare the corpora.
.PHONY: corpora
corpora: SHELL=${LOCAL_SHELL}
corpora: check_setup
	${MAKE} -C corpora all



# Create the Language Models (LM, MIXLM).
# Create the Lexicalized Distortion Models (LDM).
# Create models for truecasing (TC).
# Create the Translation Model (TM).
.PHONY: models lm mixlm ldm tc tm
models lm mixlm ldm tc tm: SHELL=${LOCAL_SHELL}
models lm mixlm ldm tc tm: %: corpora
	${MAKE} -C models $@ DO_UPDATE_PRETRAINED_LINKS=1



.PHONY: tune_main
tune_main: SHELL=${LOCAL_SHELL}
tune_main: tune_variant		# tune_variant tunes the main variant



# Tune and test using multiple alternate tuning variants, if necessary.
ifneq ($(strip ${TUNE_DECODE_VARIANTS}),)

all: $(addprefix tune_variant., ${TUNE_DECODE_VARIANTS})

ifneq ($(strip ${TEST_SET}),)
all: $(addprefix eval., ${TUNE_DECODE_VARIANTS})
endif
endif



TUNE_VARIANT_LIST := tune_variant $(addprefix tune_variant., ${TUNE_DECODE_VARIANTS})
DECODE_LIST := decode $(addprefix decode., ${TUNE_DECODE_VARIANTS})
COW_LIST := cow $(addprefix cow., ${TUNE_DECODE_VARIANTS})
CONFIDENCE_LIST := confidence $(addprefix confidence., ${TUNE_DECODE_VARIANTS})
TUNE_LIST := tune ${TUNE_VARIANT_LIST} ${DECODE_LIST} ${COW_LIST} rescore rat ${CONFIDENCE_LIST}

.PHONY: ${TUNE_LIST}
# Tune weights
${TUNE_LIST}: SHELL=${LOCAL_SHELL}
${TUNE_LIST}: %: models
	${MAKE} -C models $@



.PHONY: translate $(addprefix translate., ${TUNE_DECODE_VARIANTS})
# Apply tuned weights to the test sets
translate $(addprefix translate., ${TUNE_DECODE_VARIANTS}): SHELL=${LOCAL_SHELL}
translate $(addprefix translate., ${TUNE_DECODE_VARIANTS}): translate%: tune_variant%
	if [ ! -e $@ ]; then \
	   mkdir $@; \
	   cp -p translate/Makefile* $@; \
	fi
	${MAKE} -C translate$* all TUNE_VARIANT_TAG=$*



.PHONY: eval $(addprefix eval., ${TUNE_DECODE_VARIANTS})
# Get BLEU scores for the test set(s)
eval $(addprefix eval., ${TUNE_DECODE_VARIANTS}): SHELL=${LOCAL_SHELL}
eval $(addprefix eval., ${TUNE_DECODE_VARIANTS}): eval%: translate%
	${MAKE} -C translate$* bleu TUNE_VARIANT_TAG=$*



.PHONY: check_setup
check_setup: SHELL=${LOCAL_SHELL}
check_setup:
	${MAKE} -C models/lm check_setup


########################################
# Copy the bin/INSTALL_SUMMARY file, if it exists.
ifneq ($(wildcard $(dir $(shell which train_ibm))/INSTALL_SUMMARY),)
check_setup: log.INSTALL_SUMMARY
endif

log.INSTALL_SUMMARY: SHELL=${LOCAL_SHELL}
log.INSTALL_SUMMARY:
	cat `dirname $$(which train_ibm)`/INSTALL_SUMMARY >log.INSTALL_SUMMARY



########################################
# Prepare portageLive models.
# NOTE: In order to able to execute portageLive we should at the very least
# have tuned the system.  To do so, we will rely on the all target.
.PHONY: portageLive
portageLive: SHELL=${LOCAL_SHELL}
portageLive: all
	${MAKE} -C corpora portageLive
	${MAKE} -C models portageLive
ifdef DO_RESCORING
	@echo ""
	@echo "WARNING: the portageLive target does not install rescoring models."
	@echo "You will have to install them manually before you continue."
	@echo "Note that not all rescoring features are compatible with PortageLive."
	@echo ""
endif
	@echo "You now have all that is needed for PortageLive."
	@echo "From the framework root, run one of the following commands to"
	@echo "transfer the PortageLive models to your server:"
	@echo "rsync -Larz models/portageLive/* <REMOTE_HOST>:<DEST_DIR_ON_REMOTE_HOST>"
	@echo "scp -r models/portageLive/* <REMOTE_HOST>:<DEST_DIR_ON_REMOTE_HOST>"
	@echo "cp -Lr models/portageLive/* <DEST_DIR_ON_LOCAL_HOST>"

# convenient synonyms
portagelive: portageLive
PortageLive: portageLive

########################################
# If you need to preprocess your corpora, you can call this target to do the job.
# The end result should be .al files .
PREPARE_CORPORA_MAKEFILE ?= Makefile.prepare.corpora
.PHONY: prepare.corpora
prepare.corpora: SHELL=${LOCAL_SHELL}
prepare.corpora:
	${MAKE} -C corpora -f ${PREPARE_CORPORA_MAKEFILE} all



########################################
# Resource Summary
.PHONY: resource_summary
resource_summary: SHELL=${LOCAL_SHELL}
resource_summary: export PORTAGE_INTERNAL_CALL=1
resource_summary:
	@${MAKE} --no-print-directory -s -C models time-mem
	@${MAKE} --no-print-directory -s -C translate time-mem

.PHONY: time-mem
time-mem: SHELL=${LOCAL_SHELL}
time-mem: export PORTAGE_INTERNAL_CALL=1
time-mem:
	@echo "Resource summary for `pwd`:"
	@time-mem-tally.pl `find models translate translate.* -type f -name log.\* -o -name \*.log | sort` \
	| second-to-hms.pl \
	| expand-auto.pl



DU_DIRS = models/tm/{ibm,hmm,jpt,cpt}* models/*lm/*lm* models/decode* translate translate.*
ifdef DO_CE
DU_DIRS += models/confidence*/*.cem
endif
ifdef DO_TRUECASING
DU_DIRS += models/tc
endif
ifdef USE_LDM
DU_DIRS += models/ldm
endif


.PHONY: summary
summary: SHELL=${LOCAL_SHELL}
summary: export PORTAGE_INTERNAL_CALL=1
summary: time-mem
	@echo
	@echo "Disk usage for all models:"
	@( GLOBIGNORE="*/log.*:translate.sh"; du -sch ${DU_DIRS} 2> /dev/null || true)
	@if [[ -e models/portageLive ]]; then \
	   echo; \
	   echo "Disk usage for portageLive models:"; \
	   du -hL models/portageLive; \
	fi








################################################################################
# UNITTESTS

########################################
# Confidence Estimation & no Rescoring
.PHONY: unittest1
unittest1:  export TUNE_CE = dev3
unittest1:  export DO_CE = 1
unittest1:  export DO_RESCORING =
unittest1:
	${MAKE} all


########################################
# Unittest MixLM & LDMS.
.PHONY: unittest2
unittest2:  export MIXLM = sublm1 sublm2 sublm3
unittest2:  export USE_LDM = 1
unittest2:  export USE_HLDM = 1
unittest2:
	${MAKE} all
	[[ `find models/mixlm/ -maxdepth 1 -size +21c -name sublm\*.lm.gz | \wc -l` -eq 6 ]] || ! echo "Missing some Language Model files." >&2
	[[ `find models/mixlm/ -maxdepth 1 -size +1c -name dev1.mixlm | \wc -l` -eq 1 ]] || ! echo "Missing some the Mix Language Model file." >&2


########################################
# Unittest LDM & HLDM with more than one corpora.
.PHONY: unittest3
unittest3:  export TRAIN_TM = sublm1 sublm2 sublm3
unittest3:  export USE_LDM = 1
unittest3:  export USE_HLDM = 1
unittest3:
	${MAKE} ldm
	[[ `find models/tm -maxdepth 1 -size +21c -name \*sublm\* | \wc -l` -eq 48 ]] || ! echo "Missing some translation model files." >&2
	[[ `find models/ldm -maxdepth 1  -name ldm.* -size +21c | \wc -l` -eq 4 ]] || ! echo "Missing some Lexicalized Distortion Model files." >&2
	[[ `find models/ldm -maxdepth 1  -name hldm.* -size +21c | \wc -l` -eq 4 ]] || ! echo "Missing some Hierarchical Lexicalized Distortion Model files." >&2

