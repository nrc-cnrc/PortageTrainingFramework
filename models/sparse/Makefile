#!/usr/bin/make -f
# vim:noet:ts=3:nowrap

# @file Makefile
# @brief Trains sparse models, building the required data files.
#
# @author Eric Joanis
#
# Traitement multilingue de textes / Multilingual Text Processing
# Tech. de l'information et des communications / Information and Communications Tech.
# Conseil national de recherches Canada / National Research Council Canada
# Copyright 2014, Sa Majeste la Reine du Chef du Canada
# Copyright 2014, Her Majesty in Right of Canada

# Mandatory include: master config file.
include ../../Makefile.params

# Include and override parameters with user specific config file.
MAKEFILE_PARAMS ?= Makefile.params
-include ${MAKEFILE_PARAMS}

# Include the master toolkit.
include ../../Makefile.toolkit

# What is this module's name.
MODULE_NAME ?= sparse


.DEFAULT_GOAL := help
#.SECONDARY:
.SUFFIXES:
.DELETE_ON_ERROR:

########################################
# ALL
# Define all the work to be done here.
.PHONY: all
all: SHELL=${LOCAL_SHELL}
all: model.templates

########################################
# Clean up
.PHONY: clean
clean: clean.content clean.logs

clean.content: SHELL=${LOCAL_SHELL}
clean.content:
	${RM} data* *build-model.cmds* model*

clean.logs: SHELL=${LOCAL_SHELL}
clean.logs:
	${RM} run-parallel-log* log.* run-p.*
	${RM} -r .logs

# Hide logs from user's view into .logs
hide.logs: SHELL=${LOCAL_SHELL}
hide.logs: hide_logs_sub

########################################
# Sparse features

# Define what sparse features to use (see documentation in Makefile.params)
SPARSE_FEATURES ?= fastdhdm hopmay

model.specs: $(foreach F,$(SPARSE_FEATURES),sparse-specs-$F)
	cat $+ > $@

model: model.specs
	${RM} data.* build-model.cmds model
	build-sparse-model.sh -cmdfile build-model.cmds -model model -config $< \
	   -corp ../../corpora/${TRAIN_SPARSE} \
	   -srclang ${SRC_LANG} -tgtlang ${TGT_LANG} \
	   -srcext $(patsubst .%,%,${LANGXZ}) -tgtext $(patsubst .%,%,${LANGXZ})

data: model
	run-parallel.sh build-model.cmds ${PARALLELISM_LEVEL_SPARSE} >& log.$@
	echo "This file exists just so make dependencies work." > $@

model.templates: model data
	palminer -v -pop -m model >& log.$@


########################################
# Transform models for PortageLive
# Note: portageLive dependencies are defined in Makefile (or Makefile.zn-adapt)
PORTAGE_LIVE_DEST_DIR ?= ../portageLive/models/sparse
.PHONY: portageLive
portageLive: SHELL=${LOCAL_SHELL}


portageLive:  clean.${PORTAGE_LIVE_DEST_DIR}

portageLive:  portageLive_model_data
.PHONY:  portageLive_model_data
portageLive_model_data:  SHELL=${LOCAL_SHELL}
portageLive_model_data:  ${PORTAGE_LIVE_DEST_DIR}/model
portageLive_model_data:  ${PORTAGE_LIVE_DEST_DIR}/model.templates
portageLive_model_data:  portageLive_mmcls
portageLive_model_data:  | ${PORTAGE_LIVE_DEST_DIR}
	cd ${PORTAGE_LIVE_DEST_DIR} && ln -fs ../../../sparse/data.* .
	for f in ${PORTAGE_LIVE_DEST_DIR}/*.mmcls; do g=$${f%%.mmcls}; [[ -L $$g ]] && rm $$g; done


portageLive:  portageLive_mmcls
.PHONY: portageLive_mmcls
portageLive_mmcls:  SHELL=${LOCAL_SHELL}
portageLive_mmcls:  model
	for f in data.mkcls*; do  [[ $$f =~ .cats$$ ]] || [[ $$f =~ .mmcls$$ ]] || [[ -s $$f.mmcls ]] || wordClasses2MMmap $$f $$f.mmcls; done

${PORTAGE_LIVE_DEST_DIR}:  SHELL=${LOCAL_SHELL}
${PORTAGE_LIVE_DEST_DIR}:
	mkdir -p $@

clean.${PORTAGE_LIVE_DEST_DIR}:  SHELL=${LOCAL_SHELL}
clean.${PORTAGE_LIVE_DEST_DIR}:  clean.%:  | %
	${RM} -r $*/*

portageLive:  ${PORTAGE_LIVE_DEST_DIR}/model
${PORTAGE_LIVE_DEST_DIR}/model:  SHELL=${LOCAL_SHELL}
${PORTAGE_LIVE_DEST_DIR}/model:  model  | ${PORTAGE_LIVE_DEST_DIR}
	sed '/^data.mkcls/ s/.mmcls$$//;  /^data.mkcls/ s/$$/.mmcls/' < $< > $@

portageLive:  ${PORTAGE_LIVE_DEST_DIR}/model.templates
${PORTAGE_LIVE_DEST_DIR}/model.templates:  SHELL=${LOCAL_SHELL}
${PORTAGE_LIVE_DEST_DIR}/model.templates:  model.templates  | ${PORTAGE_LIVE_DEST_DIR}
	sed '/data.mkcls/ s/.mmcls$$//;  /data.mkcls/ s/$$/.mmcls/' < $< > $@

portageLive:   $(addprefix ${PORTAGE_LIVE_DEST_DIR}/, model.feats.gz  model.freqs.gz  model.numex  model.specs  model.voc.gz  model.wts.gz  model.wtsums.gz)
${PORTAGE_LIVE_DEST_DIR}/model.%:
	cd ${PORTAGE_LIVE_DEST_DIR} && ln -s ../../../sparse/model.$*


.PHONY:  clean.portageLive
clean.content:  clean.portageLive
clean.portageLive:  SHELL=${LOCAL_SHELL}
clean.portageLive:
	${RM} *.mmcls
