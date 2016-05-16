#!/usr/bin/make -f
# vim:noet:ts=3:nowrap

# @file Makefile
# @brief Tune/train a decoding model.
#
# @author Samuel Larkin
#
# Traitement multilingue de textes / Multilingual Text Processing
# Tech. de l'information et des communications / Information and Communications Tech.
# Conseil national de recherches Canada / National Research Council Canada
# Copyright 2008, 2015, Sa Majeste la Reine du Chef du Canada
# Copyright 2008, 2015, Her Majesty in Right of Canada

NNJM_DIR_PFX := $(dir $(lastword ${MAKEFILE_LIST}))
#$(info NNJM_DIR_PFX: ${NNJM_DIR_PFX})

# Mandatory include: master config file.
include ${NNJM_DIR_PFX}../../Makefile.params

# Include and override parameters with user specific config file.
MAKEFILE_PARAMS ?= Makefile.params
-include ${NNJM_DIR_PFX}${MAKEFILE_PARAMS}

# Include the master toolkit.
include ${NNJM_DIR_PFX}../../Makefile.toolkit

# What is this module's name.
MODULE_NAME ?= nnjm

# Where we need to deploy the NNJM models to create a portageLive system.
PORTAGE_LIVE_DEST_DIR ?= ../portageLive/models/nnjm

fix_path = $(strip $(if $(filter /, $(firstword $(subst /,/ ,$(1)))), $(1), $(addprefix ${NNJM_DIR_PFX}../../, $(1))))

NNJM_PRETRAINED_NNJMS_FIXED := $(foreach f, ${NNJM_PRETRAINED_NNJMS}, $(call fix_path, $f))

.DEFAULT_GOAL := help
.SUFFIXES:
.DELETE_ON_ERROR:

.PHONY: help
help: SHELL=${LOCAL_SHELL}
help:
	@echo "Train NNJMs."
	@echo
	@echo "To train your models, type: make all"
	@echo
	@echo "The main targets in this Makefile are:"
	@cat $(firstword $(MAKEFILE_LIST)) | egrep '^.PHONY:' | sed 's#^.PHONY: #   #'


.PHONY:  all
all:


$(info USE_PRETRAINED_NNIMS: ${USE_PRETRAINED_NNIMS})
$(info NNJM_PRETRAINED_NNJMS_FIXED: ${NNJM_PRETRAINED_NNJMS_FIXED})



.PHONY:  clean
clean:  SHELL = ${LOCAL_SHELL}
clean:  clean.content
clean:  clean.logs

.PHONY:  clean.content
clean.content:  SHELL=${LOCAL_SHELL}
clean.content:
	${RM} cpt.delme  pretrained.*

.PHONY:  clean.logs
clean.logs:
	@true






define DEPS.PYSCRIPT
from __future__ import print_function

with open(".Makefile.deps", "w") as df:
   symlinks = []
   for nnjm in set("${NNJM_PRETRAINED_NNJMS_FIXED}".strip().split()):
      parts = nnjm.split("/")
      assert(len(parts) >= 2)
      model  = parts[-1]
      target = "pretrained." + parts[-2]
      symlinks.append(target)
      print("pretrained:  {t}/{m}.pretrained".format(m=model, t=target), file=df)

      print("{t}/{m}.pretrained:  {t}/{m}.validate".format(m=model, t=target), file=df)
      print("{t}/{m}.pretrained:  {t}/{m}.is.memory.mapped".format(m=model, t=target), file=df)

      # It is unfortunate but we need to add a depencency on a temporary cpt to
      # validate the nnjm model.
      print("{t}/{m}.validate:  {t}  cpt.delme".format(t=target, m=model), file=df)
      print("{t}/{m}.is.memory.mapped:  {t}".format(t=target, m=model), file=df)
      print("{t}:  {d}".format(t=target, d="/".join(parts[:-1])), file=df)

      print("portageLive:  {t}/{m}.pretrained".format(m=model, t=target), file=df)
      print("portageLive:  {pl}/{t}".format(pl="${PORTAGE_LIVE_DEST_DIR}", t=target), file=df)
      print("{pl}/{t}:  {t}  | {pl}".format(pl="${PORTAGE_LIVE_DEST_DIR}", t=target), file=df)

   if len(symlinks) > 0:
      print(" ".join(symlinks))
endef
#$(info NNJM dependencies generator: ${DEPS.PYSCRIPT})



ifneq (${USE_PRETRAINED_NNIMS},)
$(info USING PRETRAINED NNJMS)
PRETRAINED_NNJMS_LIST := $(shell python -c '${DEPS.PYSCRIPT}')
$(info PRETRAINED_NNJMS_LIST: ${PRETRAINED_NNJMS_LIST})
include .Makefile.deps

.PHONY:  pretrained
all:  pretrained

${PRETRAINED_NNJMS_LIST}:  SHELL=${LOCAL_SHELL}
${PRETRAINED_NNJMS_LIST}:
	ln -fs $< $@

%.validate:  SHELL=${LOCAL_SHELL}
%.validate:
	configtool "args: -nnjm-file $*" <<< '[lmodel-file] /dev/null [ttable-multi-prob] cpt.delme' | configtool check



# A temporary phrase table to allow us to use configtool check to valid the
# NNJM models.
.INTERMEDIATE:  cpt.delme
cpt.delme:
	echo "a ||| a ||| 1 1" > $@


#.PHONY:  clean.symlinks
#clean.content:  clean.symlinks
#clean.symlinks:
#	${RM} ${PRETRAINED_NNJMS_LIST}



portageLive:  | ${PORTAGE_LIVE_DEST_DIR}
else
$(info NOT USING NNJM)
all:
	@echo "Not using NNJM, nothing to do." >&2

portageLive:
	@echo "Not using NNJM, nothing to do." >&2
endif


.PHONY: pretrained.are.memory.mapped
pretrained.are.memory.mapped:  SHELL=${LOCAL_SHELL}
pretrained.are.memory.mapped:  $(addsuffix .is.memory.mapped, ${NNJM_PRETRAINED_NNJMS_FIXED})

# Validate that the NNJM model is using classes files that are memory mapped.
%.is.memory.mapped:  SHELL=${LOCAL_SHELL}
%.is.memory.mapped:
	grep --quiet "srcclasses\|tgtclasses" $* || ! echo "Error: $* has no class files." >&2
	! grep --quiet srcclasses $* \
	|| grep -m1 "Portage TPMap" $(dir $*)/`grep srcclasses $* | cut --fields=2 --delimiter=' '` \
	|| ! echo "Error: srcclasses should be memory mapped in $*" >&2
	! grep --quiet tgtclasses $* \
	|| grep -m1 "Portage TPMap" $(dir $*)/`grep tgtclasses $* | cut --fields=2 --delimiter=' '` \
	|| ! echo "Error: tgtclasses should be memory mapped in $*" >&2



########################################
# Portage Live
${PORTAGE_LIVE_DEST_DIR}:  SHELL=${LOCAL_SHELL}
${PORTAGE_LIVE_DEST_DIR}:
	mkdir -p ${PORTAGE_LIVE_DEST_DIR}


.PHONY:  portageLive
portageLive:  SHELL=${LOCAL_SHELL}

${PORTAGE_LIVE_DEST_DIR}/%:
	ln -fs ../../../nnjm/$< $@


.PHONY:  clean.portageLive
clean.content:  clean.portageLive
clean.portageLive:
	${RM} -fr ${PORTAGE_LIVE_DEST_DIR}










################################################################################
# TestSuite
.PHONY:  testsuite


testsuite:  one_pretrained_testcase
.PHONY:  one_pretrained_testcase
one_pretrained_testcase:  export USE_PRETRAINED_NNIMS := 1
one_pretrained_testcase:  export NNJM_PRETRAINED_NNJMS := ${PORTAGE}/corpora/bac-lac/filtered/corpora-version-2/portage-framelab.en2fr/models/nnjm/PTGSH-163a/model
one_pretrained_testcase:
	${MAKE} clean
	${MAKE} portageLive
	[[ `\ls -d ${PORTAGE_LIVE_DEST_DIR}/pretrained.* | \wc -l` -eq 1 ]] || ! echo "Error: Expecting 1 NNJM model." >&2
	[[ -L ${PORTAGE_LIVE_DEST_DIR}/pretrained.PTGSH-163a ]] || ! echo "Error: Missing NNJM model symlink." >&2



testsuite:  multiple_pretrained_testcase
.PHONY:  multiple_pretrained_testcase
multiple_pretrained_testcase:  export USE_PRETRAINED_NNIMS := 1
multiple_pretrained_testcase:  export NNJM_PRETRAINED_NNJMS := ${PORTAGE}/corpora/bac-lac/filtered/corpora-version-2/portage-framelab.en2fr/models/nnjm/PTGSH-163a/model ${PORTAGE}/corpora/bac-lac/filtered/corpora-version-2/portage-framelab.en2fr/models/nnjm/PTGSH-163b/model
multiple_pretrained_testcase:
	${MAKE} clean
	${MAKE} portageLive
	[[ `\ls -d ${PORTAGE_LIVE_DEST_DIR}/pretrained.* | \wc -l` -eq 2 ]] || ! echo "Error: Expecting 2 NNJM model." >&2
	[[ -L ${PORTAGE_LIVE_DEST_DIR}/pretrained.PTGSH-163a ]] || ! echo "Error: Missing NNJM model symlink." >&2
	[[ -L ${PORTAGE_LIVE_DEST_DIR}/pretrained.PTGSH-163b ]] || ! echo "Error: Missing NNJM model symlink." >&2
