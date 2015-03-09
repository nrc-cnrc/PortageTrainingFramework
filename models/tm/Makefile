#!/usr/bin/make -f
# vim:noet:ts=3:nowrap
#
# @author Samuel Larkin
# @file Makefile
# @brief Trains ibm models, hmm models, joint frequency counts models and phrase tables.
#
# Technologies langagieres interactives / Interactive Language Technologies
# Inst. de technologie de l'information / Institute for Information Technology
# Conseil national de recherches Canada / National Research Council Canada
# Copyright 2008, 2012, Sa Majeste la Reine du Chef du Canada
# Copyright 2008, 2012, Her Majesty in Right of Canada

TM_DIR_PFX := $(dir $(lastword ${MAKEFILE_LIST}))

# Source file requirements.
# <PREFIX>_<LANGUAGE>.<LANGX>
 
# Variables we use from ../../Makefile.params:
# PT_TYPES indicates what type of phrase table we want to generate.

# Mandatory include: master config file.
include ${TM_DIR_PFX}../../Makefile.params

# Include and override parameters with user specific config file.
MAKEFILE_PARAMS ?= Makefile.params
-include ${TM_DIR_PFX}${MAKEFILE_PARAMS}

# This is the Makefile that contains all targets required to build Translation
# Models and some variable's defintion that might be used by the user in its
# Makefile.params.
include ${TM_DIR_PFX}Makefile.toolkit

# Lastly include the master toolkit
include ${TM_DIR_PFX}../../Makefile.toolkit

# GNU Make Standard Library
include ${TM_DIR_PFX}../../gmsl/gmsl   # functions: uc

# What is this module's name.
MODULE_NAME ?= tm

# Where we can find the parallel corpora.
CORPORA_DIR ?= ${TM_DIR_PFX}../../corpora

# We need a dev set for tuning the mixture weights in a mixtm.
#TUNE_MIXTM ?= ${TUNE_DECODE}

# This script might produce directory and we want to easily remove them.
RM := rm -rf

# After this Makefile, the following targets/files are precious.
FILES_TO_BE_LOCKED = ibm* hmm* jpt* cpt*

# Global alignment symmetrization options.
ALIGNMENT_SYMMETRIZATION_OPTIONS ?= -a "IBMOchAligner 3"


# Allows to search for alignment files in corpus.
vpath %${L1X} ${CORPORA_DIR}
vpath %${L2X} ${CORPORA_DIR}
vpath %${L1} ${CORPORA_DIR}
vpath %${L2} ${CORPORA_DIR}

# Where to look for built CPTs (cpts used for mixing are moved to mixtm).
vpath ${CPT_MODEL_PFX}%${L1_2_L2X} ${TM_DIR_PFX} ${TM_DIR_PFX}mixtm
vpath %.gz ${TM_DIR_PFX} ${TM_DIR_PFX}mixtm


.DEFAULT_GOAL := help
.DELETE_ON_ERROR:
.SUFFIXES:
.SECONDARY:


########################################
# ALL
# Define all the work to be done.
.PHONY: all
all: SHELL=${LOCAL_SHELL}
all: pretrained_cpt ${PT_TYPES}



########################################
# HELP OPTIONS
.PHONY: help
help: SHELL=${LOCAL_SHELL}
help:
	@echo "Train translation models."
	@echo
	@echo "To train your models, type: make all"
	@echo
	@echo "The main targets in this Makefile are:"
	@cat $(firstword $(MAKEFILE_LIST)) | egrep '^.PHONY:' | sed 's#^.PHONY: #   #'



# What the user can expect from this module.
.PHONY: list_final_output
list_final_output: SHELL=${LOCAL_SHELL}
list_final_output: $(addsuffix _list,${PT_TYPES})
	@echo "are the expected final outputs."



########################################
# Clean up
.PHONY: clean clean.content clean.logs hide.logs
clean: SHELL=${LOCAL_SHELL}
clean: clean.content clean.logs

clean.content: SHELL=${LOCAL_SHELL}

clean.logs: SHELL=${LOCAL_SHELL}
clean.logs:
	${RM} run-parallel-log* log.* run-p.*
	${RM} -r .logs

# Hide logs from user's view into .logs
hide.logs: SHELL=${LOCAL_SHELL}
hide.logs: hide_logs_sub



########################################
# Resources Summary
.PHONY: time-mem
time-mem: SHELL=${LOCAL_SHELL}
time-mem: resource_summary_sub



################################################################################
# WORD ALIGNMENT MODELS.

clean.content: clean.word_alignment_models

.PHONY: clean.word_alignment_models
clean.word_alignment_models:  SHELL=${LOCAL_SHELL}
clean.word_alignment_models:
	${RM} $(addsuffix .*, ${POSSIBLE_WORD_ALIGNMENT_MODELS})

.PHONY: word_alignment_models  $(addsuffix _model, ${POSSIBLE_WORD_ALIGNMENT_MODELS})
word_alignment_models:  $(addsuffix _model, ${POSSIBLE_WORD_ALIGNMENT_MODELS})

define PYSCRIPT
from __future__ import print_function, unicode_literals, division, absolute_import

with open("Makefile.word_alignment.deps", "w") as df:
   # All word alignment models depend on ibm1 word alignment models except, of
   # course, for ibm1 word alignment models, and also ibm4 since we use external
   # software to create it.
   for wal in "$(filter-out ${IBM1_MODEL_PFX} ${IBM4_MODEL_PFX}, ${POSSIBLE_WORD_ALIGNMENT_MODELS})".split(" "):
      print("{m}_model:  ${IBM1_MODEL_PFX}_model".format(m=wal), file=df)

   # the meta target for word alignment model depends on word alignment model files.
   # both forward and backward word alignment models require source and target corpora.
   for wal in "$(filter-out ${IBM4_MODEL_PFX}, ${POSSIBLE_WORD_ALIGNMENT_MODELS})".split(" "):
      for corpora in "$(filter-out 1wam, ${ALL_WAMS})".split(" "):
         print("{m}_model:  {m}.{c}.${L2_GIVEN_L1X}  {m}.{c}.${L1_GIVEN_L2X}".format(m=wal, c=corpora), file=df)
         print("{m}.{c}.${L2_GIVEN_L1X}:  {c}${L1X}  {c}${L2X}".format(c=corpora, m=wal), file=df)
         print("{m}.{c}.${L1_GIVEN_L2X}:  {c}${L1X}  {c}${L2X}".format(c=corpora, m=wal), file=df)

      for corpora in "${ALL_TMS}".split(" "):
         print("{m}.${L1_GIVEN_L2X}:  {c}${L1X}  {c}${L2X}".format(c=corpora, m=wal), file=df)
         print("{m}.${L2_GIVEN_L1X}:  {c}${L1X}  {c}${L2X}".format(c=corpora, m=wal), file=df)

   # Note that corpora dependencies for IBM4 models are hardcoded in Makefile.toolkit.
   for corpora in "${ALL_WAMS}".split(" "):
      print("${IBM4_MODEL_PFX}_model:  ${IBM4_MODEL_PFX}.{c}.${L2_GIVEN_L1X}  ${IBM4_MODEL_PFX}.{c}.${L1_GIVEN_L2X}".format(c=corpora), file=df)

   # For 1wam we want only the MIXTM corpora.  We also deliberately exclude ibm4 models.
   if "${MIXTM_USE_GLOBAL_WORD_ALIGNMENT_MODEL}" != "":
      print("#Using MIXTM Global Word Alignment Model", file=df)
      for wal in "$(filter-out ${IBM4_MODEL_PFX}, ${POSSIBLE_WORD_ALIGNMENT_MODELS})".split(" "):
         for corpora in "${MIXTM}".split(" "):
            print("{m}.1wam.${L1_GIVEN_L2X}:  {c}${L1X}  {c}${L2X}".format(c=corpora, m=wal), file=df)
            print("{m}.1wam.${L2_GIVEN_L1X}:  {c}${L1X}  {c}${L2X}".format(c=corpora, m=wal), file=df)
endef
$(info WORD ALIGNMENT: ${PYSCRIPT})
RET := $(shell python -c '${PYSCRIPT}')
include Makefile.word_alignment.deps



########################################
# ALIGNMENT FILES.

clean.content: clean.alignment_files

.PHONY: clean.alignment_files
clean.alignment_files:  SHELL=${LOCAL_SHELL}
clean.alignment_files:
	${RM} *.${L1_2_L2}.align.gz  *.${L2_2_L1}.align.gz

.PHONY: alignment_files  $(addsuffix _alignment, ${POSSIBLE_WORD_ALIGNMENT_MODELS})
alignment_files:  $(addsuffix _alignment, ${POSSIBLE_WORD_ALIGNMENT_MODELS})


define PYSCRIPT
from __future__ import print_function, unicode_literals, division, absolute_import

def which_wam(c):
   if "${MIXTM_USE_GLOBAL_WORD_ALIGNMENT_MODEL}" != "":
      if len(filter(lambda x: x == c, "$(strip ${MIXTM} ${MIXTM_TRAIN_MIX})".split(" "))) != 0:
         return "1wam"
      else:
         return c
   else:
      return c

with open("Makefile.alignment.deps", "w") as df:
   for corpora in "${ALL_WAMS}".split(" "):
      w = which_wam(corpora)
      print("#c:{c} w:{w}".format(c=corpora, w=w), file=df)
      for wal in "$(filter-out ${IBM4_MODEL_PFX}, ${POSSIBLE_WORD_ALIGNMENT_MODELS})".split(" "):
         print("{m}_alignment:  {m}_model".format(m=wal), file=df)
         alignmentFileName = "{c}.{m}.${L1_2_L2}.align.gz".format(c=corpora, m=wal)
         print("{m}_alignment:  {alignmentFileName}".format(m=wal, alignmentFileName=alignmentFileName), file=df)
         print("{alignmentFileName}:  {c}${L1X}  {c}${L2X}".format(c=corpora, alignmentFileName=alignmentFileName), file=df)
         print("{alignmentFileName}:  {m}.{w}.${L2_GIVEN_L1X}  {m}.{w}.${L1_GIVEN_L2X}".format(m=wal, w=w, alignmentFileName=alignmentFileName), file=df)

   # For IBM4.
   for corpora in "${ALL_WAMS}".split(" "):
      alignmentFileName = "{c}.{m}.${L1_2_L2}.align.gz".format(c=corpora, m="${IBM4_MODEL_PFX}")
      print("ibm4_alignment:  {alignmentFileName}".format(alignmentFileName=alignmentFileName), file=df)
      print("{alignmentFileName}:  {c}/${SRC_LANG}.lc  {c}/${TGT_LANG}.lc".format(c=corpora, alignmentFileName=alignmentFileName), file=df)
      print("{alignmentFileName}:  {c}/${L1_2_L2}.${IBM4_MODEL_PFX}.alignment.gz  {c}/${L2_2_L1}.${IBM4_MODEL_PFX}.alignment.gz".format(c=corpora, alignmentFileName=alignmentFileName), file=df)
endef
$(info ALIGNMENT: ${PYSCRIPT})
RET := $(shell python -c '${PYSCRIPT}')
include Makefile.alignment.deps



################################################################################
# JOINT PHRASE TABLES

clean.content: clean.jpts

.PHONY: clean.jpts
clean.jpts: SHELL=${LOCAL_SHELL}
clean.jpts:
	$(RM) ${JPT_MODEL_PFX}.*
	${RM} -r JPTPAR*

.PHONY: jpts  $(addsuffix _jpt, ${POSSIBLE_WORD_ALIGNMENT_MODELS})
jpts: SHELL=${LOCAL_SHELL}
jpts: $(addsuffix _jpt, ${POSSIBLE_WORD_ALIGNMENT_MODELS})

define PYSCRIPT
from __future__ import print_function, unicode_literals, division, absolute_import

def which_wam(c):
   if "${MIXTM_USE_GLOBAL_WORD_ALIGNMENT_MODEL}" != "":
      if len(filter(lambda x: x == c, "$(strip ${MIXTM} ${MIXTM_TRAIN_MIX})".split(" "))) != 0:
         return "1wam"
      else:
         return c
   else:
      return c

with open("Makefile.jpt.deps", "w") as df:
   # Definition of the generated makefile rules/targets:
   # the meta target jpt have meta-dependency on a word alignment model,
   # the meta target jpt have meta-dependency on a alignment file,
   # the meta target jpt have a dependency on jpt file.
   # jpts require the word alignment models in both directions.
   # jpts require the alignment file.
   # jpts require the source and target corpora.
   for corpora in "${ALL_TMS}".split(" "):
      w = which_wam(corpora)
      for wal in "$(filter-out ${IBM4_MODEL_PFX}, ${POSSIBLE_WORD_ALIGNMENT_MODELS})".split(" "):
         jptFileName = "${JPT_MODEL_PFX}.{m}.{c}.${JOINTX}".format(c=corpora, m=wal)
         print("{m}_jpt:  {m}_model  {m}_alignment".format(m=wal), file=df)
         print("{m}_jpt:  {jptFileName}".format(m=wal, jptFileName=jptFileName), file=df)
         print("{jptFileName}:  {m}.{w}.${L2_GIVEN_L1X}  {m}.{w}.${L1_GIVEN_L2X}".format(m=wal, w=w, jptFileName=jptFileName), file=df)
         print("{jptFileName}:  {c}.{m}.${L1_2_L2}.align.gz".format(c=corpora, m=wal, jptFileName=jptFileName), file=df)
         print("{jptFileName}:  {c}${L1X}  {c}${L2X}".format(c=corpora, jptFileName=jptFileName), file=df)

   # IBM4 depends on special corpora.
   for corpora in "${ALL_TMS}".split(" "):
      w = which_wam(corpora)
      wal = "${IBM4_MODEL_PFX}"
      jptFileName = "${JPT_MODEL_PFX}.{m}.{c}.${JOINTX}".format(c=corpora, m=wal)
      print("{m}_jpt:  {m}_model  {m}_alignment".format(m=wal), file=df)
      print("{m}_jpt:  {jptFileName}".format(m=wal, jptFileName=jptFileName), file=df)
      print("{jptFileName}:  {m}.{w}.${L2_GIVEN_L1X}  {m}.{w}.${L1_GIVEN_L2X}".format(m=wal, w=w, jptFileName=jptFileName), file=df)
      print("{jptFileName}:  {c}.{m}.${L1_2_L2}.align.gz".format(c=corpora, m=wal, jptFileName=jptFileName), file=df)
      print("{jptFileName}:  {c}/${SRC_LANG}.lc  {c}/${TGT_LANG}.lc".format(c=corpora, jptFileName=jptFileName), file=df)
endef
$(info JPT: ${PYSCRIPT})
RET := $(shell python -c '${PYSCRIPT}')
include Makefile.jpt.deps

${JPT_IBM4_MODEL_PFX}.%.${JOINTX}:  override L1X = ${SRC_LANG}.lc
${JPT_IBM4_MODEL_PFX}.%.${JOINTX}:  override L2X = ${TGT_LANG}.lc



################################################################################
# SIGNIFICANCE PRUNING JOINT PHRASE TABLES

clean.content: clean.sig

.PHONY: clean.sig
clean.sig: SHELL=${LOCAL_SHELL}
clean.sig:
	$(RM) ${SIG_MODEL_PFX}.*  sig.cnts.${JPT_MODEL_PFX}.*
	${RM} -r JPTPAR*
	${RM} -r work_directory

.PHONY: sigs  $(addsuffix _sig, ${POSSIBLE_WORD_ALIGNMENT_MODELS})
sigs: SHELL=${LOCAL_SHELL}
sigs: $(addsuffix _sig, ${POSSIBLE_WORD_ALIGNMENT_MODELS})

define PYSCRIPT
from __future__ import print_function, unicode_literals, division, absolute_import

# To create a sigpruned jpt we need an original jpt.
# To create a sigpruned jpt we need the source and target corpora.
with open("Makefile.sigprune.deps", "w") as df:
   for corpora in "${ALL_TMS}".split(" "):
      for wal in  "$(filter-out ${IBM4_MODEL_PFX}, ${POSSIBLE_WORD_ALIGNMENT_MODELS})".split(" "):
         print("{m}_sig:  {m}_jpt".format(m=wal), file=df)
         modelFileName = "${SIG_MODEL_PFX}.{m}.{c}.${JOINTX}".format(m=wal, c=corpora)
         print("{m}_sig:  {modelFileName}".format(m=wal, modelFileName=modelFileName), file=df)
         print("{modelFileName}:  ${JPT_MODEL_PFX}.{m}.{c}.${JOINTX}".format(m=wal, c=corpora, modelFileName=modelFileName), file=df)
         print("{modelFileName}:  {c}${L1X}  {c}${L2X}".format(c=corpora, modelFileName=modelFileName), file=df)

         # TODO: Why do we do reverse?
         modelFileName = "${SIG_MODEL_PFX}.{m}.{c}.${RJOINTX}".format(m=wal, c=corpora)
         print("{modelFileName}:  ${JPT_MODEL_PFX}.{m}.{c}.${RJOINTX}".format(m=wal, c=corpora, modelFileName=modelFileName), file=df)
         print("{modelFileName}:  {c}${L1X}  {c}${L2X}".format(c=corpora, modelFileName=modelFileName), file=df)

   # IBM4 sigpruning
   for corpora in "${ALL_TMS}".split(" "):
      wal = "${IBM4_MODEL_PFX}"
      print("{m}_sig:  {m}_jpt".format(m=wal), file=df)
      modelFileName = "${SIG_MODEL_PFX}.{m}.{c}.${JOINTX}".format(m=wal, c=corpora)
      print("{m}_sig:  {modelFileName}".format(m=wal, modelFileName=modelFileName), file=df)
      print("{modelFileName}:  ${JPT_MODEL_PFX}.{m}.{c}.${JOINTX}".format(m=wal, c=corpora, modelFileName=modelFileName), file=df)
      print("{modelFileName}:  {c}/${SRC_LANG}.lc  {c}/${TGT_LANG}.lc".format(c=corpora, modelFileName=modelFileName), file=df)

      #modelFileName = "${SIG_MODEL_PFX}.{m}.{c}.${RJOINTX}".format(m=wal, c=corpora)
      #print("{modelFileName}:  ${JPT_MODEL_PFX}.{m}.{c}.${RJOINTX}".format(m=wal, c=corpora, modelFileName=modelFileName), file=df)
      #print("{modelFileName}:  {c}/${SRC_LANG}.lc  {c}/${TGT_LANG}.lc".format(c=corpora, modelFileName=modelFileName), file=df)
endef
$(info SIG: ${PYSCRIPT})
RET := $(shell python -c '${PYSCRIPT}')
include Makefile.sigprune.deps

# IBM4 sigpruning
# % should match a corpora-stem
${SIG_IBM4_MODEL_PFX}.%.${JOINTX}:  override L1X = ${SRC_LANG}.lc
${SIG_IBM4_MODEL_PFX}.%.${JOINTX}:  override L2X = ${TGT_LANG}.lc



################################################################################
# CONDITIONAL PHRASE TABLES
# HMM1 => He-lex
# HMM2 => liang
# HMM3 => liang

clean.content: clean.cpts

.PHONY: clean.cpts
clean.cpts: SHELL=${LOCAL_SHELL}
clean.cpts:
	$(RM) ${CPT_MODEL_PFX}.*

.PHONY: cpts  $(addsuffix _cpt, ${POSSIBLE_WORD_ALIGNMENT_MODELS})
cpts: SHELL=${LOCAL_SHELL}
cpts: jpts
cpts: ibm2_cpt
cpts: hmm1_cpt
cpts: hmm2_cpt
cpts: hmm3_cpt
cpts: ibm4_cpt
cpts: pretrained_cpt
cpts: merged_cpt
cpts: mix_cpt


# Let's define a couple of variables.
IBM1_SMOOTHERS_DESCRIPTION ?= ${SMOOTHERS_DESCRIPTION}
IBM1_CPT_PREFIX ?= ${CPT_MODEL_PFX}.${IBM1_MODEL_PFX}${IBM1_SMOOTHERS_DESCRIPTION}

IBM2_SMOOTHERS_DESCRIPTION ?= ${SMOOTHERS_DESCRIPTION}
IBM2_CPT_PREFIX ?= ${CPT_MODEL_PFX}.${IBM2_MODEL_PFX}${IBM2_SMOOTHERS_DESCRIPTION}

HMM1_SMOOTHERS_DESCRIPTION ?= ${SMOOTHERS_DESCRIPTION}
HMM1_CPT_PREFIX ?= ${CPT_MODEL_PFX}.${HMM1_MODEL_PFX}${HMM1_SMOOTHERS_DESCRIPTION}

HMM2_SMOOTHERS_DESCRIPTION ?= ${SMOOTHERS_DESCRIPTION}
HMM2_CPT_PREFIX ?= ${CPT_MODEL_PFX}.${HMM2_MODEL_PFX}${HMM2_SMOOTHERS_DESCRIPTION}

HMM3_SMOOTHERS_DESCRIPTION ?= ${SMOOTHERS_DESCRIPTION}
HMM3_CPT_PREFIX ?= ${CPT_MODEL_PFX}.${HMM3_MODEL_PFX}${HMM3_SMOOTHERS_DESCRIPTION}

IBM4_SMOOTHERS_DESCRIPTION ?= ${SMOOTHERS_DESCRIPTION}
IBM4_CPT_PREFIX ?= ${CPT_MODEL_PFX}.${IBM4_MODEL_PFX}${IBM4_SMOOTHERS_DESCRIPTION}

define PYSCRIPT
from __future__ import print_function, unicode_literals, division, absolute_import

with open("Makefile.cpt.deps", "w") as df:
   dependencyType = "sig" if "${USE_SIGPRUNING}" != "" else "${JPT_MODEL_PFX}"
   dependencyPrefix = "${SIG_MODEL_PFX}" if "${USE_SIGPRUNING}" != "" else "${JPT_MODEL_PFX}"
   for corpora in "${ALL_TMS}".split(" "):
      for wal in "${POSSIBLE_WORD_ALIGNMENT_MODELS}".split(" "):
         fileName = "${CPT_MODEL_PFX}.{m}${SMOOTHERS_DESCRIPTION}.{c}.${L1_2_L2X}".format(c=corpora, m=wal)
         # Create meta-level dependencies between cpts and their jpts or sigs.
         print("{m}_cpt:  {m}_{t}".format(m=wal, t=dependencyType), file=df)
         print("{m}_cpt:  {fileName}".format(m=wal, fileName=fileName), file=df)
         print("{m}_cpt_list:  {fileName}".format(m=wal, fileName=fileName), file=df)

         # Conditional Phrase Tables depend on a word alignment model for Zens-Neys smoother.
         print("{fileName}:  {m}.{c}.${L2_GIVEN_L1X}  {m}.{c}.${L1_GIVEN_L2X}".format(c=corpora, m=wal, fileName=fileName), file=df)
         # Conditional Phrase Tables depend on a joint frequency phrase table which can be raw or significance pruned.
         print("{fileName}:  {dependencyPrefix}.{m}.{c}.${JOINTX}".format(c=corpora, m=wal, fileName=fileName, dependencyPrefix=dependencyPrefix), file=df)

         # Reversed conditional phrase table.
         fileName = "${CPT_MODEL_PFX}.{m}${SMOOTHERS_DESCRIPTION}.{c}.${L2_2_L1X}".format(c=corpora, m=wal)
         # Conditional Phrase Tables depend on a word alignment model for Zens-Neys smoother.
         print("{fileName}:  {m}.{c}.${L2_GIVEN_L1X}  {m}.{c}.${L1_GIVEN_L2X}".format(c=corpora, m=wal, fileName=fileName), file=df)
         # Conditional Phrase Tables depend on a joint frequency phrase table which can be raw or significance pruned.
         print("{fileName}:  {dependencyPrefix}.{m}.{c}.${RJOINTX}".format(c=corpora, m=wal, fileName=fileName, dependencyPrefix=dependencyPrefix), file=df)
endef
$(info CPT: ${PYSCRIPT})
RET := $(shell python -c '${PYSCRIPT}')
include Makefile.cpt.deps



########################################
# PRETRAINED CONDITIONAL PHRASE TABLES

clean.content: clean.pretrained

.PHONY: clean.pretrained
clean.pretrained: SHELL=${LOCAL_SHELL}
clean.pretrained:
	${RM} ${pretrained_cpt_list} .*.tstamp mixtm/.*.tstamp

# Trigger updating of the symbolic links to pre-trained models by deleting
# the hidden .tstamp files.
.PHONY: trigger.update.pretrained.links
trigger.update.pretrained.links: SHELL=${LOCAL_SHELL}
trigger.update.pretrained.links:
	${RM} .*.tstamp mixtm/.*.tstamp

pretrained_cpt_list = $(notdir ${TM_PRETRAINED_TMS})

# Target to create symbolic links to pre-trained conditional phrase tables.
.PHONY: pretrained_cpt
pretrained_cpt: $(foreach p, ${pretrained_cpt_list}, .$p.tstamp)

fix_path = $(strip $(if $(filter /, $(firstword $(subst /,/ ,$(1)))), $(1), $(addprefix ${TM_DIR_PFX}../../, $(1))))

pretrained_cpt_paths = $(foreach f, ${TM_PRETRAINED_TMS}, $(call fix_path, $f))

$(foreach f, ${pretrained_cpt_paths}, \
	$(eval \
		.$(notdir $f).tstamp:  $f) \
)

# The hidden .tstamp files exist to allow us to ensure that symbolic links
# to pre-trained models are recreated once and only once during the build.
$(foreach p, ${pretrained_cpt_list}, .$p.tstamp): SHELL=${LOCAL_SHELL}
$(foreach p, ${pretrained_cpt_list}, .$p.tstamp): .%.tstamp:
	@[[ ! -e $* ]] || [[ -L $* ]] || ! echo "ERROR: TM $* already exists as a normal file."
	@$(if $(filter-out cpt.%, $*),! echo "ERROR: Name of pre-trained TM file must start with cpt.: $<")
	ln -sf $< .
	[[ ! -d ${<:.gz=.tppt} ]] || ln -sf ${<:.gz=.tppt} .
	touch $@

${pretrained_cpt_paths}: SHELL=${LOCAL_SHELL}
${pretrained_cpt_paths}: %:
	@! echo "ERROR: Pre-trained TM file $@ does not exist."



########################################
# MERGED CONDITIONAL PHRASE TABLES
# requires: MERGED_CPT_ZN_MODEL & MERGED_CPT_JPT_TYPES to be properly defined.
MERGED_CPT_SMOOTHERS_DESCRIPTION ?= ${SMOOTHERS_DESCRIPTION}
MERGED_CPT_PREFIX ?= ${CPT_MODEL_PFX}.merged.${${MERGED_CPT_ZN_MODEL}_MODEL_PFX}${MERGED_CPT_SMOOTHERS_DESCRIPTION}
MERGED_CPT_ZN_MODEL ?= HMM3
MERGED_CPT_JPT_TYPES ?= IBM2 HMM3

# We need to specify what's the type of the models for Zen-Ney's smoother.
${CPT_MODEL_PFX}.merged.${IBM1_MODEL_PFX}%:  WORD_MODEL_TYPE=-ibm 1
${CPT_MODEL_PFX}.merged.${IBM2_MODEL_PFX}%:  WORD_MODEL_TYPE=-ibm 2
${CPT_MODEL_PFX}.merged.hmm%:  WORD_MODEL_TYPE=-hmm
${CPT_MODEL_PFX}.merged.${IBM4_MODEL_PFX}%:  WORD_MODEL_TYPE=-ibm 1

# Let's define what are the merged cpt file names.
merged_cpt_list = $(foreach c, ${TRAIN_TM}, ${MERGED_CPT_PREFIX}.$c.${L1_2_L2X})

# Meta target that will create the merged conditional phrase tables.
.PHONY: merged_cpt
merged_cpt: ${merged_cpt_list}

SIG_MERGED_PFX := ${SIG_MODEL_PFX}.merged
JPT_MERGED_PFX := ${JPT_MODEL_PFX}.merged


define PYSCRIPT
from __future__ import print_function, unicode_literals, division, absolute_import

def which_wam(c):
   if "${MIXTM_USE_GLOBAL_WORD_ALIGNMENT_MODEL}" != "":
      if len(filter(lambda x: x == c, "$(strip ${MIXTM} ${MIXTM_TRAIN_MIX})".split(" "))) != 0:
         return "1wam"
      else:
         return c
   else:
      return c

with open("Makefile.merged_cpt.deps", "w") as df:
   dependencyType = "${SIG_MODEL_PFX}" if "${USE_SIGPRUNING}" != "" else "${JPT_MODEL_PFX}"
   for corpora in "${ALL_TMS}".split(" "):
      w = which_wam(corpora)
      fileName = "${CPT_MODEL_PFX}.merged.${${MERGED_CPT_ZN_MODEL}_MODEL_PFX}${MERGED_CPT_SMOOTHERS_DESCRIPTION}.{c}.${L2_2_L1X}".format(c=corpora)
      print("{fileName}:  ${${MERGED_CPT_ZN_MODEL}_MODEL_PFX}.{w}.${L2_GIVEN_L1X}  ${${MERGED_CPT_ZN_MODEL}_MODEL_PFX}.{w}.${L1_GIVEN_L2X}".format(w=w, fileName=fileName), file=df)
      print("{fileName}:  ${${CPT_DEP_TAG}_MERGED_PFX}.{c}.${RJOINTX}".format(c=corpora, fileName=fileName), file=df)

      fileName = "${CPT_MODEL_PFX}.merged.${${MERGED_CPT_ZN_MODEL}_MODEL_PFX}${MERGED_CPT_SMOOTHERS_DESCRIPTION}.{c}.${L1_2_L2X}".format(c=corpora)
      print("{fileName}:  ${${MERGED_CPT_ZN_MODEL}_MODEL_PFX}.{w}.${L2_GIVEN_L1X}  ${${MERGED_CPT_ZN_MODEL}_MODEL_PFX}.{w}.${L1_GIVEN_L2X}".format(w=w, fileName=fileName), file=df)
      print("{fileName}:  ${${CPT_DEP_TAG}_MERGED_PFX}.{c}.${JOINTX}".format(c=corpora, fileName=fileName), file=df)

   for corpora in "${ALL_TMS}".split(" "):
      for wal in "${MERGED_CPT_JPT_TYPES}".lower().split(" "):
         filename = "${JPT_MERGED_PFX}.{c}.${RJOINTX}".format(c=corpora)
         print("{filename}:  ${JPT_MODEL_PFX}.{m}.{c}.${RJOINTX}".format(c=corpora, m=wal, filename=filename), file=df)
         filename = "${JPT_MERGED_PFX}.{c}.${JOINTX}".format(c=corpora)
         print("{filename}:  ${JPT_MODEL_PFX}.{m}.{c}.${JOINTX}".format(c=corpora, m=wal, filename=filename), file=df)
         filename = "${SIG_MERGED_PFX}.{c}.${RJOINTX}".format(c=corpora)
         print("{filename}:  ${SIG_MODEL_PFX}.{m}.{c}.${RJOINTX}".format(c=corpora, m=wal, filename=filename), file=df)
         filename = "${SIG_MERGED_PFX}.{c}.${JOINTX}".format(c=corpora)
         print("{filename}:  ${SIG_MODEL_PFX}.{m}.{c}.${JOINTX}".format(c=corpora, m=wal, filename=filename), file=df)
endef
$(info MERGED CPT: ${PYSCRIPT})
RET := $(shell python -c '${PYSCRIPT}')
include Makefile.merged_cpt.deps

# Merged conditional phrase tables depends on a word model alignment for Zens-Ney's smoother.
# Merged conditional phrase tables depends on either a merged jpt (normal scenario) or a merged sig (when using significance pruning).

# A merged jpt depends on user define type of joint frequency count file.

.INTERMEDIATE: $(foreach c, ${ALL_TMS}, ${JPT_MERGED_PFX}.$c.${RJOINTX} ${JPT_MERGED_PFX}.$c.${JOINTX})



########################################
# MIXTURE CONDITIONAL PHRASE TABLE
# Linear combination of MERGED CONDITIONAL PHRASE TABLES
# requires: MERGED_CPT_JPT_TYPES to be properly defined.

clean.content: clean.mix

.PHONY: clean.mix
clean.mix: SHELL=${LOCAL_SHELL}
clean.mix:
	$(RM) ${CPT_MIX_PFX}.*
	${RM} -r mixtm

mix_cpt_list = ${CPT_MIX_PFX}.${L1_2_L2X}

# Meta target to create the mixture conditional phrase table in mixtm/.
.PHONY: mix_cpt
mix_cpt: SHELL=${LOCAL_SHELL}
ifdef USE_MIXTM
mix_cpt:  | $(filter-out mix_cpt, ${PT_TYPES})
	mkdir -p mixtm
	cd mixtm && ${MAKE} -f ../Makefile pretrained_cpt TM_PRETRAINED_TMS="${MIXTM_PRETRAINED_TMS}"
	cd mixtm && ${MAKE} -f ../Makefile ${mix_cpt_list}
	ln -sf $(addprefix mixtm/, ${mix_cpt_list}) .

# Let's define which merged cpt files we need to mix and the dev jpt file we need
# for calculating the weights for the mix.
MIX_OTHER_CPTS := $(foreach c, $(addsuffix _list, $(filter-out mix_cpt,${PT_TYPES})), ${$c})
${CPT_MIX_PFX}.${L1_2_L2X}:  | ${MIX_OTHER_CPTS}
${CPT_MIX_PFX}.${L1_2_L2X}:  $(foreach c, ${MIXTM}, ${MERGED_CPT_PREFIX}.$c.${L1_2_L2X}) \
                             $(foreach c, $(notdir ${MIXTM_PRETRAINED_TMS}), $c)
${CPT_MIX_PFX}.${L1_2_L2X}:  ${JPT_MERGED_PFX}.${TUNE_MIXTM_FINAL}.${JOINTX}

${CPT_MIX_PFX}.${L2_2_L1X}:  | ${MIX_OTHER_CPTS}
${CPT_MIX_PFX}.${L2_2_L1X}:  $(foreach c, ${MIXTM}, ${MERGED_CPT_PREFIX}.$c.${L2_2_L1X}) \
                             $(foreach c, $(notdir ${MIXTM_PRETRAINED_TMS}), $c)
${CPT_MIX_PFX}.${L2_2_L1X}:  ${JPT_MERGED_PFX}.${TUNE_MIXTM_FINAL}.${JOINTX}

%.${TUNE_MIXTM_FINAL}.${JOINTX}: JPT_PARALLELISM_LEVEL=1
%.${TUNE_MIXTM_FINAL}.${JOINTX}: GEN_JPT_PARALLEL_OPTIONS=
%.${TUNE_MIXTM_FINAL}.${JOINTX}: JPT_MODEL_TYPE=

define PYSCRIPT
from __future__ import print_function, unicode_literals, division, absolute_import

def which_wam(c):
   if "${MIXTM_USE_GLOBAL_WORD_ALIGNMENT_MODEL}" != "":
      if len(filter(lambda x: x == c, "$(strip ${MIXTM} ${MIXTM_TRAIN_MIX})".split(" "))) != 0:
         return "1wam"
      else:
         return c
   else:
      return c

with open("Makefile.mix_cpt.deps", "w") as df:
   for j in "${MERGED_CPT_JPT_TYPES}".lower().split(" "):
      print("${JPT_MERGED_PFX}.${TUNE_MIXTM_FINAL}.${JOINTX}:  ${JPT_MODEL_PFX}.{j}.${TUNE_MIXTM_FINAL}.${JOINTX}".format(j=j), file=df)
      print("${JPT_MODEL_PFX}.{j}.${TUNE_MIXTM_FINAL}.${JOINTX}:  ${TUNE_MIXTM_FINAL}.{j}.${L1_2_L2}.align.gz".format(j=j), file=df)

   w = which_wam("${MIXTM_TRAIN_MIX}")
   for j in "$(filter-out IBM4, ${MERGED_CPT_JPT_TYPES})".lower().split(" "):
      print("${JPT_MODEL_PFX}.{j}.${TUNE_MIXTM_FINAL}.${JOINTX}:  ${TUNE_MIXTM_FINAL}${L1}  ${TUNE_MIXTM_FINAL}${L2}".format(j=j), file=df)
      filename = "${TUNE_MIXTM_FINAL}.{j}.${L1_2_L2}.align.gz".format(j=j)
      print("{filename}:  {j}.{w}.${L2_GIVEN_L1X}  {j}.{w}.${L1_GIVEN_L2X}".format(j=j, w=w, filename=filename), file=df)
      print("{filename}:  ${TUNE_MIXTM_FINAL}${L1}  ${TUNE_MIXTM_FINAL}${L2}".format(filename=filename), file=df)
endef
$(info MIXED CPT: ${PYSCRIPT})
RET := $(shell python -c '${PYSCRIPT}')
include Makefile.mix_cpt.deps

# FORCED ALIGNING tune mixtm with IBM4 models.
${JPT_IBM4_MODEL_PFX}.${TUNE_MIXTM_FINAL}.${JOINTX}:  ${TUNE_MIXTM_FINAL}/${SRC_LANG}.lc  ${TUNE_MIXTM_FINAL}/${TGT_LANG}.lc
${TUNE_MIXTM_FINAL}.${IBM4_MODEL_PFX}.${L1_2_L2}.align.gz:  ${TUNE_MIXTM_FINAL}/${SRC_LANG}.lc  ${TUNE_MIXTM_FINAL}/${TGT_LANG}.lc
${TUNE_MIXTM_FINAL}.${IBM4_MODEL_PFX}.${L1_2_L2}.align.gz:  ${TUNE_MIXTM_FINAL}/${L1_2_L2}.${IBM4_MODEL_PFX}.alignment.gz  ${TUNE_MIXTM_FINAL}/${L2_2_L1}.${IBM4_MODEL_PFX}.alignment.gz

endif  # ifdef USE_MIXTM



########################################
clean.content: clean.ibm4

.PHONY: clean.ibm4
clean.ibm4: SHELL=${LOCAL_SHELL}
clean.ibm4:
	${RM} ${IBM4_MODEL_PFX}.*
	${RM} ${TRAIN_TM}



########################################
# INDICATOR FEATURE CONDITIONAL PHRASE TABLE
# Create JPT groups based on their word alignment type.
j2m/%: SHELL=${LOCAL_SHELL}
j2m/%:  $(foreach c, ${ALL_TMS}, ${${CPT_DEP_TAG}_MODEL_PFX}.%.$c.${JOINTX})
	mkdir -p $@
	cd $@ && for f in $+; do ln -fs ../../$$f ${JPT_MODEL_PFX}.$${f##${${CPT_DEP_TAG}_MODEL_PFX}.}; done

j2mr/%: SHELL=${LOCAL_SHELL}
j2mr/%:  $(foreach c, ${ALL_TMS}, ${${CPT_DEP_TAG}_MODEL_PFX}.%.$c.${RJOINTX})
	mkdir -p $@
	cd $@ && for f in $+; do ln -fs ../../$$f ${JPT_MODEL_PFX}.$${f##${${CPT_DEP_TAG}_MODEL_PFX}.}; done

INDICATOR_MODEL_PFX = ${CPT_INDICATOR_PFX}${PI_SMOOTHERS_DESCRIPTION}.${${MERGED_CPT_ZN_MODEL}_MODEL_PFX}
INDICATOR_WORD_ALIGNMENT_MODELS ?= $(foreach c,${MERGED_CPT_JPT_TYPES},${$c_MODEL_PFX})
#INDICATOR_WORD_ALIGNMENT_MODELS ?= ${IBM4_MODEL_PFX} ${HMM3_MODEL_PFX} ${IBM2_MODEL_PFX}

# We need to group JPTs, for this we create a directory called j2m containing the proper grouping of JPTs.
${INDICATOR_MODEL_PFX}.${L1_2_L2X}:  | $(addprefix j2m/,  ${INDICATOR_WORD_ALIGNMENT_MODELS})
${INDICATOR_MODEL_PFX}.${L2_2_L1X}:  | $(addprefix j2mr/, ${INDICATOR_WORD_ALIGNMENT_MODELS})

ifeq ($(words ${TRAIN_TM}), 1)
# Don't create a global word alignment model using all corpora pairs if there is only one pair.
# Don't duplicate work already been done.
${INDICATOR_MODEL_PFX}.${L1_2_L2X}:  ${${MERGED_CPT_ZN_MODEL}_MODEL_PFX}.${TRAIN_TM}.${L2_GIVEN_L1X}  ${${MERGED_CPT_ZN_MODEL}_MODEL_PFX}.${TRAIN_TM}.${L1_GIVEN_L2X}
${INDICATOR_MODEL_PFX}.${L2_2_L1X}:  ${${MERGED_CPT_ZN_MODEL}_MODEL_PFX}.${TRAIN_TM}.${L2_GIVEN_L1X}  ${${MERGED_CPT_ZN_MODEL}_MODEL_PFX}.${TRAIN_TM}.${L1_GIVEN_L2X}
else
${INDICATOR_MODEL_PFX}.${L1_2_L2X}:  ${${MERGED_CPT_ZN_MODEL}_MODEL_PFX}.${L2_GIVEN_L1X}  ${${MERGED_CPT_ZN_MODEL}_MODEL_PFX}.${L1_GIVEN_L2X}
${INDICATOR_MODEL_PFX}.${L2_2_L1X}:  ${${MERGED_CPT_ZN_MODEL}_MODEL_PFX}.${L2_GIVEN_L1X}  ${${MERGED_CPT_ZN_MODEL}_MODEL_PFX}.${L1_GIVEN_L2X}
endif

# Let's define what are the indicator cpt file names.
indicator_cpt_list = ${INDICATOR_MODEL_PFX}.${L1_2_L2X}

.PHONY: indicator_cpt
indicator_cpt:  ${indicator_cpt_list}


clean.content: clean.indicator

.PHONY: clean.indicator
clean.indicator: SHELL=${LOCAL_SHELL}
clean.indicator:
	${RM} -r j2m j2mr



########################################
# Let's do some validation when the user wants a merged_cpt.
ifeq ($(filter merged_cpt, ${PT_TYPES}),merged_cpt)
# Make sure there is only one MERGED_CPT_ZN_MODEL.
ifneq ($(words ${MERGED_CPT_ZN_MODEL}), 1)
$(error You must specify one and only one MERGED_CPT_ZN_MODEL!)
endif

# Make sure MERGED_CPT_ZN_MODEL is valid.
ifneq ($(filter-out IBM4 HMM3 HMM2 HMM1 IBM2 IBM1, ${MERGED_CPT_ZN_MODEL}),)
$(error MERGED_CPT_ZN_MODEL must be one of IBM4, HMM3, HMM2, HMM1, IBM2 or IBM1 instead of ${MERGED_CPT_ZN_MODEL})
endif

# Make sure MERGED_CPT_JPT_TYPES are valid.
ifneq ($(filter-out IBM4 HMM3 HMM2 HMM1 IBM2 IBM1, ${MERGED_CPT_JPT_TYPES}),)
$(error MERGED_CPT_JPT_TYPES must be one of IBM4, HMM3, HMM2, HMM1, IBM2 or IBM1 instead of ${MERGED_CPT_JPT_TYPES})
endif
endif


################################################################################
# HELPERS

# Let's have a target to print out the variables that contain the conditional phrase table file's name.
%_cpt_list: SHELL=${LOCAL_SHELL}
%_cpt_list: ; @echo ${$@}



################################################################################
# Tightly Packed Phrase Tables.
# We need the full file names to be able to trigger all tppt.
# PT_TYPES is what the user asked for so we need to change ibm2_cpt =>
# ibm2_cpt_list and evaluate its content which will be the text phrase table
# file name.  Then we only need to change the text file name to tightly packed
# file name.
tppt_list := $(addsuffix .tppt, $(basename $(foreach a, $(PT_TYPES:=_list) pretrained_cpt_list, ${$a})))

.PHONY: tppt
tppt portageLive: SHELL=${LOCAL_SHELL}
tppt portageLive: ${tppt_list}




# Add the unittest targets.
-include Makefile.unittests

