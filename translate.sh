#!/bin/bash
# $Id$
# @file translate.sh
# @brief Simple end-to-end translation.
#
# @author Darlene Stewart
#
# Technologies langagieres interactives / Interactive Language Technologies
# Inst. de technologie de l'information / Institute for Information Technology
# Conseil national de recherches Canada / National Research Council Canada
# Copyright 2010, Sa Majeste la Reine du Chef du Canada
# Copyright 2010, Her Majesty in Right of Canada

# Include NRC's bash library.
SH_UTILS=`which sh_utils.sh`
if [[ "${SH_UTILS}" == "" ]]; then
   echo "ERROR: Unable to find sh_utils.sh. Is your PATH set correctly for Portage?" >&2
   exit 1
fi
source ${SH_UTILS}

usage() {
   for msg in "$@"; do
      echo $msg >&2
   done
   cat <<==EOF== >&2

Usage: translate.sh [OPTIONS] [SOURCE_FILE]

  Translate input source text from SOURCE_FILE (or STDIN) according to the 
  currently trained models (relative to the current directory). The complete 
  translation pipeline is run: pre-processing, tokenization, translation, 
  truecasing (if models available), detokenization, post-processing.
  
  If SOURCE_FILE is not provided, input is read from STDIN. The input text
  is assumed to contain paragraphs separated by blank lines.
  
  This script must be located in the root directory of the framework
  along with the Makefile.params file from which it obtains settings.

Options:

  -do|-decode-only    translate without rescoring and confidence estimation
  -wr|-with-rescoring translate with rescoring
  -wc|-with-ce        translate with confidence estimation
  -v(erbose)          increment the verbosity level by 1 (may be repeated)
  -q(uiet)            make terminal output as quiet as possible
  -d(ebug)            print debugging information
  -n(otreally)        just print the commands to execute, don't run them.
  -h(elp)             print this help message

==EOF==

   exit 1
}

# Command line processing
VERBOSE=0
while [ $# -gt 0 ]; do
   case "$1" in
   -do|-decode-only)	DECODE_ONLY=1;;
   -wr|-with-rescoring) WITH_RESCORING=1;;
   -wc|-with-ce)        WITH_CE=1;;
   -v|-verbose)         VERBOSE=$(( $VERBOSE + 1 ));;
   -q|-quiet)           QUIET=1;;
   -d|-debug)           DEBUG=1;;
   -n|-notreally)       NOTREALLY=1;;
   -h|-help)            usage;;
   --)                  shift; break;;
   -*)                  error_exit "Unknown option $1.";;
   *)                   break;;
   esac
   shift
done

ROOTDIR=`dirname $0`
MAKEFILE_PARAMS="${ROOTDIR}/Makefile.params"
[[ -e ${MAKEFILE_PARAMS} ]] \
   || error_exit "Makefile.params not found in directory with translate.sh."

if [[ $# -gt 0 ]]; then
   # [[ $# -gt 0 ]] || error_exit "Missing the input file to translate."
   SOURCE_FILE=$1; shift
   [[ $# -eq 0 ]] || error_exit "Unexpected argument(s): $@" >&2
fi

[[ "${DECODE_ONLY}${WITH_RESCORING}${WITH_CE}" -gt "1" ]] \
   && error_exit "Specify only one of -decode-only, -with-rescoring, -with-ce."
MODE="-decode-only"
[[ ${WITH_RESCORING} ]] && MODE="-with-rescoring"
[[ ${WITH_CE} ]] && MODE="-with-ce"

if [[ ${WITH_RESCORING} ]]; then
   # Check if the rescoring model was set to build.
   TEXT=`grep -E '^ *DO_RESCORING *\??=' ${MAKEFILE_PARAMS}`
   [[ ${TEXT} =~ '= *([^ ]*)' ]] && [[ ${BASH_REMATCH[1]} == 1 ]] \
      || warn "DO_RESCORING not enabled; rescoring model may not have been built."
fi

if [[ ${WITH_CE} ]]; then
   # Check if the confidence estimation model was set to build.
   TEXT=`grep -E '^ *DO_CE *\??=' ${MAKEFILE_PARAMS}`
   [[ ${TEXT} =~ '= *([^ ]*)' ]] && [[ ${BASH_REMATCH[1]} == 1 ]] \
      || warn "DO_CE not enabled; confidence estimation model may not have been built."
fi

# Determine the source language.
TEXT=`grep -E '^( *|export +)SRC_LANG *\??=' ${MAKEFILE_PARAMS}`
[[ ${TEXT} =~ '= *([^ ]*)' ]] && SRC_OPT="-src=${BASH_REMATCH[1]}"

# Determine the target language.
TEXT=`grep -E '^( *|export +)TGT_LANG *\??=' ${MAKEFILE_PARAMS}`
[[ ${TEXT} =~ '= *([^ ]*)' ]] && TGT_OPT="-tgt=${BASH_REMATCH[1]}"

# Locate the canoe.ini.cow file.
# We assume that this translate.sh script is at the root of the framework.
CANOE_INI="canoe.ini.cow"
if [[ ! -e ${CANOE_INI} ]]; then
   CANOE_INI="${ROOTDIR}/translate/canoe.ini.cow"
   [[ -e ${CANOE_INI} ]] || ln -s "../models/decode/canoe.ini.cow" ${CANOE_INI}
   CANOE_INI_OPT="-f=\"${CANOE_INI}\""
fi

# Determine if truecasing
TEXT=`grep -E '^ *DO_TRUECASING *\??=' ${MAKEFILE_PARAMS}`
if [[ ${TEXT} =~ '= *([^ ]*)' ]] && [[ ${BASH_REMATCH[1]} == 1 ]]; then
   TPLM_CNT=0
   for NAME in `dirname ${CANOE_INI}`/models/tc/*.tplm; do
      [[ $(basename ${NAME}) =~ '^log.*$' ]] || TPLM_CNT=$(( $TPLM_CNT + 1 ))
   done
   if [[ ${TPLM_CNT} -gt 0 ]]; then
      TC_OPT="-tctp"
      verbose 1 "Using tightly packed truecasing model (-tctp)."
   else
      TC_OPT="-tc"
      verbose 1 "Using text truecasing model (-tc)."
   fi
fi

for (( V=$VERBOSE; $V>0; V=$V-1 )) ; do
   V_OPT="$V_OPT -v"
done

[[ $QUIET ]] && Q_OPT="-quiet"

run_cmd "translate.pl ${MODE} ${SRC_OPT} ${TGT_OPT} ${TC_OPT} ${CANOE_INI_OPT} ${V_OPT} ${Q_OPT} ${SOURCE_FILE}"

exit 0