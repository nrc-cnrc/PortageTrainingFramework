#!/usr/bin/make -f
# vim:noet:ts=3:nowrap
#
# @author Darlene Stewart
# @file Makefile
# @brief Train non-coarse/coarse bidirectional language models (BiLM).
#
# Traitement multilingue de textes / Multilingual Text Processing
# Tech. de l'information et des communications / Information and Communications Tech.
# Conseil national de recherches Canada / National Research Council Canada
# Copyright 2015, Sa Majeste la Reine du Chef du Canada
# Copyright 2015, Her Majesty in Right of Canada

# Mandatory include: master config file.
include ../../Makefile.params

# Include the config file.
MAKEFILE_PARAMS ?= Makefile.params
-include ${MAKEFILE_PARAMS}

# Include the master toolkit
include ../../Makefile.toolkit

# Override the default SMOOTHER setting in the LM Makefile.toolkit
# For BiLMs (coarse or non-coarse), we use modified Kneser-Ney smoothing with
# MITLM or Witten-Bell smoothing with SRILM.
ifeq (${LM_TOOLKIT}, MIT)
SMOOTHER ?= kn
else ifeq (${LM_TOOLKIT}, SRI)
SMOOTHER ?= wb
else
$(error LM Toolkit for building coarse LMs must be MIT or SRI; invalid LM toolkit: ${LM_TOOLKIT})
endif

# Override the default LM ORDER setting in the LM Makefile.toolkit
# What is the order of the BiLM?
# Typically we use a higher order for coarse BiLMs than for regular word-based BiLMs.
ORDER ?= 6

# Include the LM toolkit
include ../lm/Makefile.toolkit

# Include the WCL toolkit
include ../wcl/Makefile.toolkit


# What is this module's name?
MODULE_NAME ?= bilm

# What is the lm language.
LM_LANG ?= ${SRC_LANG}2${TGT_LANG}

# What word class granularities should be used for the coarse LM(s)?
# Multiple coarse LMs with different granularites may be trained. For example,
# a typical choice is 200 & 800 for a coarse LM combo.
COARSELM_NCLS_LIST ?=

# What type of LMs to build
# For coarse LMs, valid LM types are:
#    arpa binlm tplm
LM_TYPES ?= binlm

# What are the corpora names and extension and what files define these corpora.
CORPORA_NAMES ?= $(addprefix bitokens., \
                    $(foreach s, $(filter-out word, ${BILM_SPEC}), $(addsuffix -$s_${LM_LANG}, ${TRAIN_BILM})) \
                    $(if $(filter word, ${BILM_SPEC}), $(addsuffix _${LM_LANG}, ${TRAIN_BILM})) )

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

# Locate the classes files in the wcl module
vpath %.classes ../wcl

# Locate the Word Alignment (wal) files in the tm directory
vpath %.align.gz ../tm


.DEFAULT_GOAL := help
.DELETE_ON_ERROR:


########################################
.PHONY: help
help: SHELL=${LOCAL_SHELL}
help:
	@echo "In Makefile.params, define LM_TOOLKIT=SRI, LM_TOOLKIT=MIT" \
	      "to specify the LM toolkit to use."
	@echo "Also in Makefile.params, define COARSELM_NCLS_LIST to specify" \
	      "the word class granularities to use."
	@echo
	@echo "To train your coarse language models, type: make all"
	@echo
	@echo "The main targets in this Makefile are:"
	@cat $(firstword $(MAKEFILE_LIST)) | egrep '^.PHONY:' | sed 's#^.PHONY: #   #' | sort


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

all: $(foreach x, ${LM_EXTS}, $(addsuffix $x, ${LM_NAMES}))

.SECONDARY: $(addsuffix .lm.gz, ${LM_NAMES})

# Corpus dependencies for BiLM files.
$(foreach c, ${CORPORA_NAMES}, \
   $(eval $(call LM_CORP_DEP,${c}${LM_DESC},${c}${CORPUS_EXT})))

define DEPS_PYSCRIPT
from __future__ import print_function, unicode_literals, division, absolute_import
import re

bilm_specs = "${BILM_SPEC}"
train_bilm = "${TRAIN_BILM}"
tune_bilm = "${TUNE_BILM}"
src_lang = "${SRC_LANG}"
tgt_lang = "${TGT_LANG}"
lm_lang = "${SRC_LANG}2${TGT_LANG}"
corpus_ext = "${CORPUS_EXT}"
align = "${MERGED_CPT_JPT_TYPES}"
lm_desc = "${LM_DESC}"
corpus_ext_nogz = corpus_ext[:-3] if corpus_ext.endswith(".gz") else corpus_ext

spec_re = re.compile("^(?:([0-9]+)bi)?-?(?:([0-9]+)s)?-?(?:([0-9]+)t)?$$")

with open("Makefile.deps", "w") as df:
   w2c_corp = []
   bit_corp = []
   bit_cmpts = []
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
      tgt_spec = "-{0}t".format(tgt_ncls) if src_ncls else ""
      cx = "{ss}{ts}_{l}{cext}".format(ss=src_spec, ts=tgt_spec, l=lm_lang, cext=corpus_ext)
      wcl_corp = []
      bit_cls = "bitoks.all{ss}{ts}.{l}.{ncls}.classes".format(
                ss=src_spec, ts=tgt_spec, l=lm_lang, ncls=bit_ncls)
      for c in train_bilm.split():
         # Dependencies for creating bitokens files with corpus text optionally mapped to word classes
         sc = "{c}{ss}_{sl}{cext}".format(c=c, ss=src_spec, sl=src_lang, cext=corpus_ext)
         tc = "{c}{ts}_{tl}{cext}".format(c=c, ts=tgt_spec, tl=tgt_lang, cext=corpus_ext)
         if src_ncls:
            print("{sc}: {c}_{sl}{cext} {sl}.{ncls}.classes".format(
                  sc=sc, c=c, sl=src_lang, cext=corpus_ext, ncls=src_ncls), file=df)
            w2c_corp.append(sc)
         if tgt_ncls:
            print("{tc}: {c}_{tl}{cext} {tl}.{ncls}.classes".format(
                  tc=tc, c=c, tl=tgt_lang, cext=corpus_ext, ncls=tgt_ncls), file=df)
            w2c_corp.append(tc)
         # Bitokens files are created for each alignment used
         corp = []
         for a in align.lower().split():
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
            wcl_corp.append("bitokens.{c}{cx}".format(c=c, cx=cx))
            w2c_corp.append("bitokens.{c}-{ncls}bi{cx}".format(c=c, cx=cx, ncls=bit_ncls))
      # Dependencies for creating word classes of bitokens
      if bit_ncls:
         print("{cls}: WCL_NCLS={ncls}".format(cls=bit_cls, ncls=bit_ncls), file=df)
         print("{cls}: WCL_LANG={l}".format(cls=bit_cls, l=lm_lang), file=df)
         print("{cls}: {bits}".format(cls=bit_cls, bits=" ".join(wcl_corp)), file=df)
         print("portageLive: {cls}".format(cls=bit_cls), file=df)
      # Dependencies for LM parameter tuning
      if tune_bilm:
         # Dependencies for creating bitokens files for LM parameter tuning with text optionally mapped to word classes
         sc = "{c}{ss}_{sl}{cext}".format(c=tune_bilm, ss=src_spec, sl=src_lang,
                                          cext=corpus_ext if src_ncls else corpus_ext_nogz)
         tc = "{c}{ts}_{tl}{cext}".format(c=tune_bilm, ts=tgt_spec, tl=tgt_lang,
                                          cext=corpus_ext if tgt_ncls else corpus_ext_nogz)
         if src_ncls:
            print("{sc}: {c}_{sl}{cext} {sl}.{ncls}.classes".format(
                  sc=sc, c=tune_bilm, sl=src_lang, cext=corpus_ext_nogz, ncls=src_ncls), file=df)
            w2c_corp.append(sc)
         if tgt_ncls:
            print("{tc}: {c}_{tl}{cext} {tl}.{ncls}.classes".format(
                  tc=tc, c=tune_bilm, tl=tgt_lang, cext=corpus_ext_nogz, ncls=tgt_ncls), file=df)
            w2c_corp.append(tc)
         # Bitokens files are created for each alignment used
         corp = []
         for a in align.lower().split():
            print("bitokens.{a}.{c}{cx}: {sc} {tc} {c}.{a}.{l}.align.gz".format(
                  a=a, c=tune_bilm, cx=cx, sc=sc, tc=tc, l=lm_lang), file=df)
            corp.append("bitokens.{a}.{c}{cx}".format(a=a, c=tune_bilm, cx=cx))
         bit_cmpts.extend(corp)
         print("bitokens.{c}{cx}: {deps}".format(c=tune_bilm, cx=cx, deps=" ".join(corp)), file=df)
         bit_corp.append("bitokens.{c}{cx}".format(c=tune_bilm, cx=cx))
         # Dependencies for mapping bitokens files for LM parameter tuning to word classes of bitokens
         if bit_ncls:
            print("bitokens.{c}-{ncls}bi{cx}: bitokens.{c}{cx} {cls}".format(
                  cls=bit_cls, c=tune_bilm, cx=cx, ncls=bit_ncls), file=df)
            w2c_corp.append("bitokens.{c}-{ncls}bi{cx}".format(c=tune_bilm, cx=cx, ncls=bit_ncls))
         # BiLM file depends on the tune bitokens file.
         for c in train_bilm.split():
            s = "-{0}".format(spec) if spec != "word" else ""
            print("{c}{s}_{l}{ld}.lm.gz: bitokens.{c}{s}_{l}{cext}".format(
                  c=tune_bilm, s=s, l=lm_lang, cext=corpus_ext, ld=lm_desc), file=df)

   print("MAPPED_CORP_FILES ?= {0}".format(" ".join(w2c_corp)), file=df)
   print("BITOKENS_CMPTS_FILES ?= {0}".format(" ".join(bit_cmpts)), file=df)
   print("BITOKENS_CORP_FILES ?= {0}".format(" ".join(bit_corp)), file=df)
endef

$(shell python -c '${DEPS_PYSCRIPT}')

include Makefile.deps

#.INTERMEDIATE: ${MAPPED_CORP_FILES}
${MAPPED_CORP_FILES}: SHELL=${LOCAL_SHELL}
${MAPPED_CORP_FILES}: %${CORPUS_EXT}:
	word2class -no-error $(filter %${CORPUS_EXT}, $+) $(filter %.classes, $+) | gzip > $@

${BITOKENS_CMPTS_FILES}: SHELL=${FRAMEWORK_SHELL}
${BITOKENS_CMPTS_FILES}: bitokens.%.gz:
	RP_PSUB_OPTS="-${CPUS} -N $@" \
	${TIME_MEM} \
	word_align_tool -fin sri -fout bilm -t -v $+ $@

# Combine component bitokens files for multiple alignments
${BITOKENS_CORP_FILES}: SHELL=${LOCAL_SHELL}
${BITOKENS_CORP_FILES}: bitokens.%.gz:
	cat $+ > $@


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
	${RM} Makefile.deps
	${RM} bitokens.*.gz *_${SRC_LANG}${CORPUS_EXT} *_${TGT_LANG}${CORPUS_EXT}
	${RM} *.classes *.classes.cats
	${RM} *.lm.gz *.binlm.gz
	${RM} -r *.tplm


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
# Transform the BiLM models for PortageLive
PORTAGE_LIVE_DEST_DIR ?= ../portageLive/models/bilm
.PHONY: portageLive
portageLive: SHELL=${LOCAL_SHELL}
ifneq (${TRAIN_BILM},)
portageLive: $(addsuffix .tplm, ${LM_NAMES})
portageLive:
	mkdir -p ${PORTAGE_LIVE_DEST_DIR}
	${RM} -r ${PORTAGE_LIVE_DEST_DIR}/*
	cd ${PORTAGE_LIVE_DEST_DIR} && ln -fs $(addprefix ../../../bilm/, $+) .
else
portageLive:
	@echo "No BiLMs defined, nothing to do." >&2
endif
