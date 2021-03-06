#!/usr/bin/make -f
# vim:noet:ts=3:nowrap

# @file Makefile
# @brief Train language model files.
#
# @author Samuel Larkin and Darlene Stewart
#
# Traitement multilingue de textes / Multilingual Text Processing
# Tech. de l'information et des communications / Information and Communications Tech.
# Conseil national de recherches Canada / National Research Council Canada
# Copyright 2008, 2015, Sa Majeste la Reine du Chef du Canada
# Copyright 2008, 2015, Her Majesty in Right of Canada

LM_DIR_PFX := $(dir $(lastword ${MAKEFILE_LIST}))

# Mandatory include: master config file.
include ${LM_DIR_PFX}../../Makefile.params

# Include the config file.
MAKEFILE_PARAMS ?= Makefile.params
-include ${LM_DIR_PFX}${MAKEFILE_PARAMS}

# Include the master toolkit.
include ${LM_DIR_PFX}../../Makefile.toolkit

# Include the LM toolkit.
include ${LM_DIR_PFX}Makefile.toolkit

# What is this module's name.
MODULE_NAME ?= lm

# The following variables are defined in Makefile.toolkit included above:
#    ORDER, IRSTLM
# Their default definitions are repeated below for documentation.

# What is the lm language.
LM_LANG ?= ${TGT_LANG}

# What is the order of the required LM.
ORDER ?= 5

# What type of LMs to build
# Valid LM types are:
#    arpa binlm tplm irstlm blmt quantize Qblmt sort_arpa prune
LM_TYPES ?= binlm

# We must create tplm for tuning.
LM_TYPES := $(sort ${LM_TYPES} tplm)

# What are the corpora names and extension and what files define these corpora.
CORPORA_NAMES ?= $(addsuffix _${LM_LANG}, ${TRAIN_LM})

# This indicates the corpus extension and looks like .tok.al.gz
CORPUS_EXT  ?= ${LANGXZ}

LM_DESC ?= -${SMOOTHER}-${ORDER}g
LM_NAMES ?= $(addsuffix ${LM_DESC}, ${CORPORA_NAMES})

# Where to find the corpus' file.
CORPORA_DIR ?= ../../corpora

ifeq (${LM_TOOLKIT},IRST)
# Defines the IRST environment variables.
# Where is IRSTLM located
IRSTLM ?= $(PORTAGE)/pkgs/irstlm
# Where are IRSTLM's binaries located
IRSTLM_BIN_DIR ?= ${IRSTLM}/bin
endif

# This is to test the perplexity of the language models.
PPX_TEST_SET ?= test.txt

# After this Makefile, the following targets/files are precious.
FILES_TO_BE_LOCKED = $(addsuffix *, ${LM_NAMES})


# By default, locate corpora files in the corpora directory.
vpath %${CORPUS_EXT} ${CORPORA_DIR}
vpath %${CORPUS_EXT:.gz=} ${CORPORA_DIR}
vpath %.marked.gz ${CORPORA_DIR}


.DEFAULT_GOAL := help
.SUFFIXES:
.DELETE_ON_ERROR:


MAIN_TARGETS :=  all clean help

########################################
.PHONY: help
help: SHELL=${LOCAL_SHELL}
help:
	${HELP_IRSTLM}
	${HELP_LM_TOOLKIT}
	@echo "To train the language models, type: make all"
	${HELP_LIST_MAIN_TARGETS}
	${HELP_LIST_EXPECTED_FILES}
	@echo
	@echo "Note: you can build some other LM by defining TRAIN_LM=<corpus_prefix>."


########################################
.PHONY: all
all: SHELL=${LOCAL_SHELL}
all: pretrained.${LM_LANG}

LM_EXTS =
LM_EXTS += $(if $(findstring arpa, ${LM_TYPES}),.lm.gz)
LM_EXTS += $(if $(findstring binlm, ${LM_TYPES}),.binlm.gz)
LM_EXTS += $(if $(findstring tplm, ${LM_TYPES}),.tplm)
LM_EXTS += $(if $(findstring irstlm, ${LM_TYPES}),.ilm.gz)
LM_EXTS += $(if $(findstring blmt, ${LM_TYPES}),.blmt)
LM_EXTS += $(if $(findstring quantize, ${LM_TYPES}),.qlm.gz)
LM_EXTS += $(if $(findstring Qblmt, ${LM_TYPES}),.Qblmt)
LM_EXTS += $(if $(findstring sort_arpa, ${LM_TYPES}),.lm.sorted.gz)
LM_EXTS += $(if $(findstring prune, ${LM_TYPES}),.plm.gz)

VALID_LM_TYPES := arpa binlm tplm irstlm blmt quantize Qblmt sort_arpa prune

ifneq ($(filter-out ${VALID_LM_TYPES}, ${LM_TYPES}),)
$(error Invalid LM_TYPES: $(filter-out ${VALID_LM_TYPES}, ${LM_TYPES}))
endif

EXPECTED_FILES = $(foreach x, ${LM_EXTS}, $(addsuffix $x, ${LM_NAMES}))

all: ${EXPECTED_FILES}


# Corpus dependencies for LM files.
$(foreach c, ${CORPORA_NAMES}, \
   $(eval $(call LM_CORP_DEP,${c}${LM_DESC},${c}${CORPUS_EXT})))

# If tuning the discount parameters, we add a dependency on that file too.
ifeq (${LM_TOOLKIT}, MIT)
ifdef TUNE_LM
$(foreach c, ${TRAIN_LM}, \
	$(eval \
		${c}_${LM_LANG}${LM_DESC}.lm.gz: ${TUNE_LM}_${LM_LANG}${CORPUS_EXT:.gz=}) \
)
endif
endif


########################################
# What the user can expect from this module.
.PHONY: list_final_output
list_final_output: SHELL=${LOCAL_SHELL}
list_final_output:
	@echo "Expected final output(s):"
	@echo "${EXPECTED_FILES}"


########################################
# Clean up
.PHONY: clean clean.content clean.logs hide.logs
clean: SHELL=${LOCAL_SHELL}
clean: clean.content clean.logs

clean.content: SHELL=${LOCAL_SHELL}

clean.content:
	${RM} *.lm.gz *.binlm.gz
	${RM} -r *.tplm
	${RM} *.ilm.gz *.marked.gz *.blmt *.qlm.gz *.Qblmt *.lm.sorted.gz *.plm.gz
	${RM} -r stat*


clean.logs: SHELL=${LOCAL_SHELL}
clean.logs:
	${RM} log.*
	${RM} run-parallel-logs-*
	${RM} -r .logs

# Hide logs from user's view into .logs
hide.logs: SHELL=${LOCAL_SHELL}
hide.logs: hide_logs_sub


########################################
# Resources Summary
.PHONY: time-mem
time-mem: SHELL=${LOCAL_SHELL}
time-mem: resource_summary_sub

MAIN_TARGETS += time-mem


########################################
# Transform the LM model for PortageLive
PORTAGE_LIVE_DEST_DIR ?= ../portageLive/models/lm
.PHONY: portageLive
portageLive: SHELL=${LOCAL_SHELL}
ifneq ($(strip ${TRAIN_LM} $(notdir ${LM_PRETRAINED_TGT_LMS})),)
portageLive: $(addsuffix .tplm, ${LM_NAMES}) $(notdir ${LM_PRETRAINED_TGT_LMS:.binlm${GZ}=.tplm})
	mkdir --parents ${PORTAGE_LIVE_DEST_DIR}
	${RM} -r ${PORTAGE_LIVE_DEST_DIR}/*
	cd ${PORTAGE_LIVE_DEST_DIR} && ln -fs $(addprefix ../../../lm/, $+) .
else
portageLive:
	@echo "No regular LMs defined, so nothing to do for portageLive." >&2
endif

MAIN_TARGETS += portageLive


########################################
# Create symbolic links to pre-trained models

clean.content: clean.pretrained

.PHONY: clean.pretrained
clean.pretrained: SHELL=${LOCAL_SHELL}
clean.pretrained:
	${RM} $(sort $(foreach p, $(notdir ${LM_PRETRAINED_LMS}), $p ${p:.binlm.gz=.tplm} ${p:.tplm=.binlm.gz}) .*.tstamp)

LM_PRETRAINED_SRC_LMS ?= $(subst _${TGT_LANG},_${SRC_LANG}, ${LM_PRETRAINED_TGT_LMS})
LM_PRETRAINED_LMS ?= ${LM_PRETRAINED_SRC_LMS} ${LM_PRETRAINED_TGT_LMS}

ifneq ($(filter ${LM_PRETRAINED_TGT_LMS}, ${LM_PRETRAINED_SRC_LMS}),)
$(error Target language specification _${TGT_LANG} missing in pre-trained LM file name(s): \
        $(filter ${LM_PRETRAINED_TGT_LMS}, ${LM_PRETRAINED_SRC_LMS}))
endif

# Trigger updating of the symbolic links to pre-trained models by deleting
# the hidden .tstamp files.
.PHONY: trigger.update.pretrained.links
trigger.update.pretrained.links: SHELL=${LOCAL_SHELL}
trigger.update.pretrained.links:
ifdef LM_PRETRAINED_LMS
ifeq (${LM_LANG},${TGT_LANG})
	${RM} $(foreach p, $(notdir ${LM_PRETRAINED_TGT_LMS}), .$p.tstamp)
else
	${RM} $(foreach p, $(notdir ${LM_PRETRAINED_SRC_LMS}), .$p.tstamp)
endif
endif

.PHONY: pretrained.${SRC_LANG} pretrained.${TGT_LANG}
pretrained.${SRC_LANG}: $(foreach p, $(notdir ${LM_PRETRAINED_SRC_LMS}), .$p.tstamp)
pretrained.${TGT_LANG}: $(foreach p, $(notdir ${LM_PRETRAINED_TGT_LMS}), .$p.tstamp)

pretrained_lm_paths = $(foreach f, ${LM_PRETRAINED_LMS}, $(call FIX_RELATIVE_PATH, ../../, $f))

$(foreach f, ${pretrained_lm_paths}, \
	$(eval \
		.$(notdir $f).tstamp:  $f) \
)

# The hidden .tstamp files exist to allow us to ensure that symbolic links
# to pre-trained models are recreated once and only once during the build.
$(foreach p, $(notdir ${pretrained_lm_paths}), .$p.tstamp): SHELL=${LOCAL_SHELL}
$(foreach p, $(notdir ${pretrained_lm_paths}), .$p.tstamp): .%.tstamp:
	@[[ ! -e $* ]] || [[ -L $* ]] || ! echo "ERROR: LM $* already exists as a normal file."
	@$(if $(filter-out %.binlm.gz %.tplm, $*),! echo "ERROR: Name of pre-trained LM file must end with .binlm.gz or .tplm: $<")
	ln -sf $< .
	#[[ -L $(notdir $<) ]] || [[ ! -d ${<:.binlm.gz=.tplm} ]] || ln -sf ${<:.binlm.gz=.tplm} .
	touch $@

${pretrained_lm_paths}: SHELL=${LOCAL_SHELL}
${pretrained_lm_paths}: %:
	@! echo "ERROR: Pre-trained LM file $@ does not exist."


################################################################################
# HELPERS
########################################
# All valid/possible LMs
.PHONY: all_lm
all_lm: SHELL=${LOCAL_SHELL}
all_lm:
	${MAKE} all LM_TYPES="${VALID_LM_TYPES}"

################################################################################
# The following targets are unmaintained and were used for initial testing of
# irstlm.
########################################
# PERPLEXITY
.PHONY: ppx
ppx: SHELL=${LOCAL_SHELL}
ppx: $(addprefix ppx., ${LM_NAMES})
ppx.%: SHELL=${FRAMEWORK_SHELL}
ppx.%: %.binlm.gz ${PPX_TEST_SET}
	lm_eval -v -limit $+

.PHONY: ppx.irstlm
ppx.irstlm: SHELL=${LOCAL_SHELL}
ppx.irstlm: $(foreach lm_name, ${LM_NAMES}, $(addprefix ppx.irstlm.${lm_name}, .lm.gz .blmt .qlm.gz .Qblmt))
ppx.irstlm.%: SHELL=${FRAMEWORK_SHELL}
ppx.irstlm.%: ${PPX_TEST_SET} %
	compile-lm $* --eval=$< >& $(basename $@)



################################################################################
# TESTSUITE

.PHONY: testsuite

.PHONY:  tplm.testcase
testsuite:  tplm.testcase
tplm.testcase:  export TRAIN_LM := lm-train sublm3
tplm.testcase:
	echo "TESTCASE:  $@"
	${MAKE} clean &> /dev/null
	time ${MAKE} -j 11 ${TESTCASE_OPTS} all
	[[ `\ls -d {lm-train,sublm3}_fr-kn-5g.tplm | \wc -l` -eq 2 ]] || ! echo "$* should produce 2 tplm [200, 800]" >&2



.PHONY:  ptgsh_295
ptgsh_295:  ptgsh_295_bin
ptgsh_295:  ptgsh_295_tplm

.PHONY:  ptgsh_295_bin
ptgsh_295_bin:  export LM_PRETRAINED_TGT_LMS := ${PORTAGE}/models/generic-model/v1.0/dvd_v1.0/lm/generic1.0_${TGT_LANG}.binlm.gz
ptgsh_295_bin:
	${MAKE} clean.pretrained
	${MAKE} pretrained.${TGT_LANG}
	[[ -L $(notdir ${LM_PRETRAINED_TGT_LMS}) ]] || ! echo "Error: pretrained generic binlm model was not symlinked." >&2
	[[ -f .$(notdir ${LM_PRETRAINED_TGT_LMS}).tstamp ]] || ! echo "Error: pretrained generic model timestamp was not created." >&2

.PHONY:  ptgsh_295_tplm
ptgsh_295_tplm:  export LM_PRETRAINED_TGT_LMS := ${PORTAGE}/models/generic-model/v1.0/dvd_v1.0/lm/generic1.0_${TGT_LANG}.tplm
ptgsh_295_tplm:  ptgsh_295_bin
	${MAKE} clean.pretrained
	${MAKE} pretrained.${TGT_LANG}
	[[ -L $(notdir ${LM_PRETRAINED_TGT_LMS}) ]] || ! echo "Error: pretrained generic tplm model was not symlinked." >&2
	[[ -f .$(notdir ${LM_PRETRAINED_TGT_LMS}).tstamp ]] || ! echo "Error: pretrained generic model timestamp was not created." >&2
