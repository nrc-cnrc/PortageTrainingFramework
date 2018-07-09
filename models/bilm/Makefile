#!/usr/bin/make -f
# vim:noet:ts=3:nowrap

# @file Makefile
# @brief Train non-coarse/coarse bidirectional language models (BiLM).
#
# @author Darlene Stewart
#
# Traitement multilingue de textes / Multilingual Text Processing
# Tech. de l'information et des communications / Information and Communications Tech.
# Conseil national de recherches Canada / National Research Council Canada
# Copyright 2015, Sa Majeste la Reine du Chef du Canada
# Copyright 2015, Her Majesty in Right of Canada

# Mandatory include: master config file.
include ../../Makefile.params

# Include and override parameters with user specific config file.
MAKEFILE_PARAMS ?= Makefile.params
-include ${MAKEFILE_PARAMS}

# Include the master toolkit.
include ../../Makefile.toolkit

# Override the default SMOOTHER setting in the LM Makefile.toolkit
# For BiLMs (coarse or non-coarse), we use modified Kneser-Ney smoothing with
# MITLM or Witten-Bell smoothing with SRILM.
ifeq (${LM_TOOLKIT}, MIT)
SMOOTHER ?= kn
else ifeq (${LM_TOOLKIT}, SRI)
SMOOTHER ?= wb
else
$(error LM Toolkit for building (coarse) BiLMs must be MIT or SRI; invalid LM toolkit: ${LM_TOOLKIT})
endif

# Override the default LM ORDER setting in the LM Makefile.toolkit
# What is the order of the BiLM?
# Typically we use a higher order for coarse BiLMs than for regular word-based BiLMs.
ORDER ?= 6

# Include the LM toolkit.
include ../lm/Makefile.toolkit

# Include the WCL toolkit.
include ../wcl/Makefile.toolkit

# What is this module's name?
MODULE_NAME ?= bilm

# What is the lm language.
LM_LANG ?= ${SRC_LANG}2${TGT_LANG}

# What specifications should be used for the (coarse) BiLM(s)?
# "word" indicates a word-based BiLM.
# Coarse BiLM specifications take the form: NNNbi-NNNs-NNNt where NNN is the
# word class granularity. Examples: 400bi-400s-400t, 400s-400t, 400bi
# Multiple BiLM specifications are permitted. Each will be applied to each
# corpus listed in TRAIN_BILM.
BILM_SPEC ?=

# What type of LMs to build
# For coarse LMs, valid LM types are:
#    arpa binlm tplm
LM_TYPES ?= binlm

# We must create tplm for tuning.
LM_TYPES := $(sort ${LM_TYPES} tplm)

#$(info TRAIN_BILM: ${TRAIN_BILM})

# What are the corpora names and extension and what files define these corpora.
CORPORA_NAMES ?= $(addprefix bitokens., \
                    $(foreach s, $(filter-out word, ${BILM_SPEC}), $(addsuffix -$s_${LM_LANG}, ${TRAIN_BILM})) \
                    $(if $(filter word, ${BILM_SPEC}), $(addsuffix _${LM_LANG}, ${TRAIN_BILM})) )
#$(info CORPORA_NAMES: ${CORPORA_NAMES})

# This indicates the corpus extension and looks like .tok.al.gz
CORPUS_EXT  ?= ${LANGXZ}

LM_DESC ?= -${SMOOTHER}-${ORDER}g
LM_NAMES ?= $(addsuffix ${LM_DESC}, ${CORPORA_NAMES})

# Where to find the corpus' file.
CORPORA_DIR ?= ../../corpora

# More memory may be needed for very large corpora...
CPUS ?= 1

# After this Makefile, the following targets/files are precious.
FILES_TO_BE_LOCKED = $(addsuffix *, ${LM_NAMES})


# By default, locate corpora files in the corpora directory.
vpath %${CORPUS_EXT} ${CORPORA_DIR}
vpath %${CORPUS_EXT:.gz=} ${CORPORA_DIR}

# Locate corpus directories for IBM4 in subdirectories of the ibm module.
vpath %/${SRC_LANG}.lc ../ibm ../wal
vpath %/${TGT_LANG}.lc ../ibm ../wal

# Locate the classes files in the wcl module
vpath %.classes ../wcl

# Locate the Word Alignment (wal) files in the wal module
vpath %.align.gz ../wal


.DEFAULT_GOAL := help
.DELETE_ON_ERROR:
.SUFFIXES:
.SECONDARY:


MAIN_TARGETS :=  all clean help

########################################
.PHONY: help
help: SHELL=${LOCAL_SHELL}
help:
	${HELP_LM_TOOLKIT_2}
	@echo "In Makefile.params, define USE_BILM to enable BiLM training."
	@echo "Also, define BILM_SPEC to provide different (coarse) BiLM specifications."
	@echo
	@echo "To train the (coarse) BiLM, type: make all"
	${HELP_LIST_MAIN_TARGETS}
	${HELP_LIST_EXPECTED_FILES}


########################################
.PHONY: all
all: SHELL=${LOCAL_SHELL}

LM_EXTS =
LM_EXTS += $(if $(findstring arpa, ${LM_TYPES}),.lm.gz)
LM_EXTS += $(if $(findstring binlm, ${LM_TYPES}),.binlm.gz)
LM_EXTS += $(if $(findstring tplm, ${LM_TYPES}),.tplm)

VALID_LM_TYPES := arpa binlm tplm

ifneq ($(filter-out ${VALID_LM_TYPES}, ${LM_TYPES}),)
$(error Invalid LM_TYPES: $(filter-out ${VALID_LM_TYPES}, ${LM_TYPES}))
endif

EXPECTED_FILES = $(foreach x, ${LM_EXTS}, $(addsuffix $x, ${LM_NAMES}))

all: ${EXPECTED_FILES}

# Corpus dependencies for BiLM files.
$(foreach c, ${CORPORA_NAMES}, \
   $(eval $(call LM_CORP_DEP,${c}${LM_DESC},${c}${CORPUS_EXT})))

define DEPS.PYSCRIPT
from __future__ import print_function
import re

bilm_specs = "${BILM_SPEC}"
train_bilm = "${TRAIN_BILM}"
tune_bilm = "${TUNE_BILM}"
src_lang = "${SRC_LANG}"
tgt_lang = "${TGT_LANG}"
lm_lang = "${SRC_LANG}2${TGT_LANG}"
corpus_ext = "${CORPUS_EXT}"
corpus_ext_nogz = "${CORPUS_EXT:.gz=}"
align = "${MERGED_CPT_JPT_TYPES}"
lm_desc = "${LM_DESC}"

spec_re = re.compile("^(?:([0-9]+)bi)?-?(?:([0-9]+)s)?-?(?:([0-9]+)t)?$$")

alignments = align.lower().split()
cinfo = [("ibm4.", "/")] if "ibm4" in alignments else []
if len(alignments) > 1 or len(cinfo) == 0: cinfo.append(("", "_"))

with open(".Makefile.deps", "w") as df:
   w2c_corp = []
   bit_corp = []
   bit_cmpts = []
   corp_stems = train_bilm.split()
   if tune_bilm:
      corp_stems.append(tune_bilm)
   for spec in bilm_specs.split():
      m = spec_re.match(spec)
      if m is None and spec != "word":
         print("$$(error Invalid BILM_SPEC: {0})".format(spec), file=df)
         continue      
      if m is not None:
         bit_ncls, src_ncls, tgt_ncls = m.groups()
      else:
         bit_ncls = src_ncls = tgt_ncls = None
      src_spec = "-{0}s".format(src_ncls) if src_ncls else ""
      tgt_spec = "-{0}t".format(tgt_ncls) if tgt_ncls else ""
      wcl_corp = []
      bit_cls = "bitoks.all{ss}{ts}.{l}.{ncls}.classes".format(
                   ss=src_spec, ts=tgt_spec, l=lm_lang, ncls=bit_ncls)
      # Bitokens files may need to be created for each training corpus file,
      # and also for the tune_bilm file if used for LM parameter tuning
      # Separate bitokens files are needed for IBM4 alignment matching the
      # training corpora used for IBM4 alignment.
      for c in corp_stems:
         dcext = corpus_ext_nogz if c == tune_bilm else corpus_ext
         for ap, sep in cinfo:
            ocext = ".lc" if ap == "ibm4." else dcext
            # Dependencies for creating bitokens files with corpus text optionally mapped to word classes
            if src_ncls:
               sc = "{ap}{c}{ss}_{sl}{cext}".format(ap=ap, c=c, ss=src_spec, sl=src_lang, cext=dcext)
               print("{sc}: {c}{sep}{sl}{cext} {sl}.{ncls}.classes".format(
                     sc=sc, c=c, sep=sep, sl=src_lang, cext=ocext, ncls=src_ncls), file=df)
               w2c_corp.append(sc)
            if tgt_ncls:
               tc = "{ap}{c}{ts}_{tl}{cext}".format(ap=ap, c=c, ts=tgt_spec, tl=tgt_lang, cext=dcext)
               print("{tc}: {c}{sep}{tl}{cext} {tl}.{ncls}.classes".format(
                     ap=ap, tc=tc, c=c, sep=sep, tl=tgt_lang, cext=ocext, ncls=tgt_ncls), file=df)
               w2c_corp.append(tc)
         # Bitokens files are created for each alignment used
         corp = []
         cx = "{ss}{ts}_{l}{cext}".format(ss=src_spec, ts=tgt_spec, l=lm_lang, cext=dcext)
         for a in alignments:
            ap, sep = cinfo[0 if a == "ibm4" else -1]
            ocext = ".lc" if ap == "ibm4." else dcext
            sap, ssep, scext = (ap, "_", dcext) if src_ncls else ("", sep, ocext)
            sc = "{ap}{c}{ss}{sep}{sl}{cext}".format(ap=sap, c=c, ss=src_spec, sep=ssep, sl=src_lang, cext=scext)
            tap, tsep, tcext = (ap, "_", dcext) if tgt_ncls else ("", sep, ocext)
            tc = "{ap}{c}{ts}{sep}{tl}{cext}".format(ap=tap, c=c, ts=tgt_spec, sep=tsep, tl=tgt_lang, cext=tcext)
            print("bitokens.{a}.{c}{cx}: {sc} {tc} {c}.{a}.{l}.align.gz".format(
                  a=a, c=c, cx=cx, sc=sc, tc=tc, l=lm_lang), file=df)
            corp.append("bitokens.{a}.{c}{cx}".format(a=a, c=c, cx=cx))
         bit_cmpts.extend(corp)
         print("bitokens.{c}{cx}: {deps}".format(c=c, cx=cx, deps=" ".join(corp)), file=df)
         bit_corp.append("bitokens.{c}{cx}".format(c=c, cx=cx))
         # Dependencies for mapping bitokens to word classes of bitokens
         if bit_ncls:
            print("bitokens.{c}-{ncls}bi{cx}: bitokens.{c}{cx} {cls}".format(
                  cls=bit_cls, c=c, cx=cx, ncls=bit_ncls), file=df)
            if c != tune_bilm:
               wcl_corp.append("bitokens.{c}{cx}".format(c=c, cx=cx))
            w2c_corp.append("bitokens.{c}-{ncls}bi{cx}".format(c=c, cx=cx, ncls=bit_ncls))
      # Dependencies for creating word classes of bitokens
      if bit_ncls:
         print("{cls}: WCL_NCLS={ncls}".format(cls=bit_cls, ncls=bit_ncls), file=df)
         print("{cls}: WCL_LANG={l}".format(cls=bit_cls, l=lm_lang), file=df)
         print("{cls}: {bits}".format(cls=bit_cls, bits=" ".join(wcl_corp)), file=df)
         bit_mmcls=bit_cls.rsplit(".", 1)[0] + ".mmcls"
         print("portageLive: {mmcls}".format(mmcls=bit_mmcls), file=df)
         print("EXPECTED_FILES += {cls}".format(cls=bit_cls), file=df)
      # Dependencies for LM parameter tuning
      if tune_bilm:
         # BiLM file depends on the tune bitokens file.
         for c in train_bilm.split():
            s = "-{0}".format(spec) if spec != "word" else ""
            print("bitokens.{c}{s}_{l}{ld}.lm.gz: bitokens.{t}{s}_{l}{cext}".format(
                  c=c, t=tune_bilm, s=s, l=lm_lang, cext=corpus_ext_nogz, ld=lm_desc), file=df)

   print("MAPPED_CORP_FILES ?=", *w2c_corp, file=df)
   print("BITOKENS_CMPTS_FILES ?=", *bit_cmpts, file=df)
   print("BITOKENS_CORP_FILES ?=", *bit_corp, file=df)
endef

$(shell python -c '${DEPS.PYSCRIPT}')
include .Makefile.deps

.INTERMEDIATE: ${MAPPED_CORP_FILES}
$(filter-out %.gz, ${MAPPED_CORP_FILES}): SHELL=${LOCAL_SHELL}
$(filter %.gz, ${MAPPED_CORP_FILES}): SHELL=${FRAMEWORK_SHELL}
${MAPPED_CORP_FILES}: %:
	$(if $(filter %.gz,$@),RP_PSUB_OPTS="-${CPUS} -N $@") \
	${TIME_MEM} \
	word2class -no-error $(filter-out %.classes, $+) $(filter %.classes, $+) $@ 2> log.$(@:.gz=)

${BITOKENS_CMPTS_FILES}: SHELL=${FRAMEWORK_SHELL}
$(filter-out %.gz, ${BITOKENS_CMPTS_FILES}): SHELL=${LOCAL_SHELL}
$(filter %.gz, ${BITOKENS_CMPTS_FILES}): SHELL=${FRAMEWORK_SHELL}
${BITOKENS_CMPTS_FILES}: bitokens.%:
	$(if $(filter %.gz,$@),RP_PSUB_OPTS="-${CPUS} -N $@") \
	${TIME_MEM} \
	word_align_tool -fin sri -fout bilm -t -v $+ $@ 2> log.${@:.gz=}

# Combine component bitokens files for multiple alignments
${BITOKENS_CORP_FILES}: SHELL=${LOCAL_SHELL}
${BITOKENS_CORP_FILES}: bitokens.%:
	cat $+ > $@


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
	${RM} Makefile.deps
	${RM} -r *.tplm
	${RM} bitokens.* 
	${RM} *_${SRC_LANG}${CORPUS_EXT} *_${TGT_LANG}${CORPUS_EXT}
	${RM} *_${SRC_LANG}${CORPUS_EXT:.gz=} *_${TGT_LANG}${CORPUS_EXT:.gz=}
	${RM} *.classes *.classes.cats
	${RM} *.lm.gz *.binlm.gz


clean.logs: SHELL=${LOCAL_SHELL}
clean.logs:
	${RM} log.*
	${RM} run-parallel-logs-*
	${RM} -r .logs
	${RM} .Makefile*.deps

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
# Transform the BiLM model(s) for PortageLive
PORTAGE_LIVE_DEST_DIR ?= ../portageLive/models/bilm

${PORTAGE_LIVE_DEST_DIR}:  SHELL=${LOCAL_SHELL}
${PORTAGE_LIVE_DEST_DIR}:
	mkdir --parents $@

.PHONY: portageLive
portageLive:  SHELL=${LOCAL_SHELL}
ifneq (${TRAIN_BILM},)
portageLive:  $(addsuffix .tplm, ${LM_NAMES})
portageLive:  | ${PORTAGE_LIVE_DEST_DIR}
portageLive:
	${RM} -r ${PORTAGE_LIVE_DEST_DIR}/*
	cd ${PORTAGE_LIVE_DEST_DIR} && ln -fs $(addprefix ../../../bilm/, $+) .
else
portageLive:
	@echo "No BiLMs defined, so nothing to do for portageLive." >&2
endif

MAIN_TARGETS += portageLive


################################################################################
# TestSuite
.PHONY:  testsuite
testsuite:  tplm.testcase

# The default target should build a tplm.
.PHONY:  tplm.testcase
tplm.testcase:  export TRAIN_BILM := bilm-train
tplm.testcase:  export BILM_SPEC := 400bi-400s-400t
tplm.testcase:
	echo "TESTCASE:  $@"
	${MAKE} clean &> /dev/null
	${MAKE} -C ../wcl all
	${MAKE} -C ../ibm all
	${MAKE} -C ../wal all
	time ${MAKE} -j 11 ${TESTCASE_OPTS} all
	\ls -d bitokens.*.tplm || ! echo "Missing tplm." >&2
