#!/usr/bin/make -f
# vim:noet:ts=3:nowrap
#
# @author Samuel Larkin and Darlene Stewart
# @file Makefile
# @brief Train language model files.
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

# Include the master toolkit
include ${LM_DIR_PFX}../../Makefile.toolkit

# Include the LM toolkit
include ${LM_DIR_PFX}Makefile.toolkit


# What is this module's name.
MODULE_NAME ?= lm

# The following variables are defined in Makefile.toolkit included above:
#    ORDER, CORPUS_EXT, LM_DESC, IRSTLM
# Their default definitions are repeated below for documentation.

# What is the lm language.
LM_LANG ?= ${TGT_LANG}

# What is the order of the required LM.
ORDER ?= 5

# What type of LMs to build
# Valid LM types are:
#    arpa binlm tplm irstlm mark blmt quantize Qblmt sort_arpa prune
LM_TYPES ?= binlm

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


# Tells make where to find the corpus' file and the marked file if need be.
vpath %${CORPUS_EXT} ${CORPORA_DIR}
vpath %.marked.gz    ${CORPORA_DIR}


.DEFAULT_GOAL := help
.DELETE_ON_ERROR:


########################################
.PHONY: help
help: SHELL=${LOCAL_SHELL}
help:
ifeq (${LM_TOOLKIT},IRST)
	@echo "Please run the following in order for this framework to run properly:"
	@echo "   export PATH=${IRSTLM_BIN_DIR}:\$$PATH"
	@echo "   export IRSTLM=${IRSTLM}"
	@echo
endif
	@echo "In Makefile.params, define LM_TOOLKIT=SRI, LM_TOOLKIT=MIT" \
	      "or LM_TOOLKIT=IRST to specify the LM toolkit to use."
	@echo
	@echo "To train your language models, type: make all"
	@echo
	@echo "The main targets in this Makefile are:"
	@cat $(firstword $(MAKEFILE_LIST)) | egrep '^.PHONY:' | sed 's#^.PHONY: #   #' | sort
	@echo
	@echo "Note: you can build some other LM by defining TRAIN_LM=<corpora_prefix>."


########################################
.PHONY: all
all: SHELL=${LOCAL_SHELL}
all: pretrained.${LM_LANG}

LM_EXTS =
LM_EXTS += $(if $(findstring arpa, ${LM_TYPES}),.lm.gz)
LM_EXTS += $(if $(findstring binlm, ${LM_TYPES}),.binlm.gz)
LM_EXTS += $(if $(findstring tplm, ${LM_TYPES}),.tplm)
LM_EXTS += $(if $(findstring irstlm, ${LM_TYPES}),.ilm.gz)
LM_EXTS += $(if $(findstring mark, ${LM_TYPES}),.marked.gz)
LM_EXTS += $(if $(findstring blmt, ${LM_TYPES}),.blmt)
LM_EXTS += $(if $(findstring quantize, ${LM_TYPES}),.qlm.gz)
LM_EXTS += $(if $(findstring Qblmt, ${LM_TYPES}),.Qblmt)
LM_EXTS += $(if $(findstring sort_arpa, ${LM_TYPES}),.lm.sorted.gz)
LM_EXTS += $(if $(findstring prune, ${LM_TYPES}),.plm.gz)

VALID_LM_TYPES := arpa binlm tplm irstlm mark blmt quantize Qblmt sort_arpa prune

ifneq ($(filter-out ${VALID_LM_TYPES}, ${LM_TYPES}),)
$(error Invalid LM_TYPES: $(filter-out ${VALID_LM_TYPES}, ${LM_TYPES}))
endif

all: $(foreach x, ${LM_EXTS}, $(addsuffix $x, ${LM_NAMES}))

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
	@echo "$(foreach x, ${LM_EXTS}, $(addsuffix $x, ${LM_NAMES}))"


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


########################################
# Transform the LM model for PortageLive
PORTAGE_LIVE_DEST_DIR ?= ../portageLive/models/lm
.PHONY: portageLive
portageLive: SHELL=${LOCAL_SHELL}
ifneq ($(strip ${TRAIN_LM} $(notdir ${LM_PRETRAINED_TGT_LMS})),)
portageLive: $(addsuffix .tplm, ${LM_NAMES}) $(notdir ${LM_PRETRAINED_TGT_LMS:.binlm${GZ}=.tplm})
	mkdir -p ${PORTAGE_LIVE_DEST_DIR}
	${RM} -r ${PORTAGE_LIVE_DEST_DIR}/*
	cd ${PORTAGE_LIVE_DEST_DIR} && ln -fs $(addprefix ../../../lm/, $+) .
else
portageLive:
	@echo "No regular LMs defined, nothing to do." >&2
endif


########################################
# Create symbolic links to pre-trained models

clean.content: clean.pretrained

.PHONY: clean.pretrained
clean.pretrained: SHELL=${LOCAL_SHELL}
clean.pretrained:
	${RM} $(foreach p, $(notdir ${LM_PRETRAINED_LMS}), $p ${p:.binlm.gz=.tplm}) .*.tstamp

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

fix_path = $(strip $(if $(filter /, $(firstword $(subst /,/ ,$(1)))), $(1), $(addprefix ../../, $(1))))

pretrained_lm_paths = $(foreach f, ${LM_PRETRAINED_LMS}, $(call fix_path, $f))

$(foreach f, ${pretrained_lm_paths}, \
	$(eval \
		.$(notdir $f).tstamp:  $f) \
)

# The hidden .tstamp files exist to allow us to ensure that symbolic links
# to pre-trained models are recreated once and only once during the build.
$(foreach p, $(notdir ${pretrained_lm_paths}), .$p.tstamp): SHELL=${LOCAL_SHELL}
$(foreach p, $(notdir ${pretrained_lm_paths}), .$p.tstamp): .%.tstamp:
	@[[ ! -e $* ]] || [[ -L $* ]] || ! echo "ERROR: LM $* already exists as a normal file."
	@$(if $(filter-out %.binlm.gz, $*),! echo "ERROR: Name of pre-trained LM file must end with .binlm.gz: $<")
	ln -sf $< .
	[[ ! -d ${<:.binlm.gz=.tplm} ]] || ln -sf ${<:.binlm.gz=.tplm} .
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
	${MAKE} LM_TYPES="${VALID_LM_TYPES}


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

