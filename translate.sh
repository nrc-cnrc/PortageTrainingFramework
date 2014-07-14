#!/bin/bash
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
   echo "ERROR: Unable to find sh_utils.sh. Is your PATH set correctly for PortageII?" >&2
   exit 1
fi
source ${SH_UTILS}

print_nrc_copyright translate.sh 2010
export PORTAGE_INTERNAL_CALL=1

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
   -nomode)             NOMODE=1;;
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

# get_param PARAM_NAME
# Read the framework's top-level Makefile.params to find the value of PARAM_NAME
get_param() {
   var=$1
   #echo "get_param $var" >&2
   if TEXT=`make -pn --file=${MAKEFILE_PARAMS} 2> /dev/null | grep "^ *$var"`; then
      #echo "Var $var found" >&2
      if [[ ${TEXT} =~ '= *([^ ][^ ]*)' ]]; then
         echo ${BASH_REMATCH[1]}
      else
         warn "Parameter $var found but has no value" >&2
      fi
   #else echo "Var $var NOT found" >&2
   fi
}

[[ "${DECODE_ONLY}${WITH_RESCORING}${WITH_CE}" -gt "1" ]] \
   && error_exit "Specify only one of -decode-only, -with-rescoring, -with-ce."
MODE="-decode-only"
[[ $WITH_RESCORING ]] && MODE="-with-rescoring"
[[ $WITH_CE ]] && MODE="-with-ce"
[[ $NOMODE ]] && MODE=""

if [[ ${WITH_RESCORING} ]]; then
   # Check if the rescoring model was set to build.
   [[ `get_param DO_RESCORING` == 1 ]] \
      || warn "DO_RESCORING not enabled; rescoring model may not have been built."
fi

if [[ ${WITH_CE} ]]; then
   # Check if the confidence estimation model was set to build.
   [[ `get_param DO_CE` == 1 ]] \
      || warn "DO_CE not enabled; confidence estimation model may not have been built."
fi

# Determine the source language.
SRC_LANG=`get_param SRC_LANG`
[[ $SRC_LANG ]] && SRC_OPT="-src=$SRC_LANG"

# Determine the target language.
TGT_LANG=`get_param TGT_LANG`
[[ $TGT_LANG ]] && TGT_OPT="-tgt=$TGT_LANG"

# Determine the TMX source language code
TMX_SRC=`get_param TMX_SRC`
[[ $TMX_SRC ]] && TMX_SRC_OPT="-xsrc=$TMX_SRC"
if [[ ! $TMX_SRC_OPT && $SRC_LANG ]]; then
   TMX_SRC_OPT="-xsrc=`echo -n $SRC_LANG | tr 'a-z' 'A-Z'`-CA"
fi

# Determine the TMX target language code
TMX_TGT=`get_param TMX_TGT`
[[ $TMX_TGT ]] && TMX_TGT_OPT="-xtgt=$TMX_TGT"
if [[ ! $TMX_TGT_OPT && $TGT_LANG ]]; then
   TMX_TGT_OPT="-xtgt=`echo -n $TGT_LANG | tr 'a-z' 'A-Z'`-CA"
fi

# Determine the PortageLive parallelism level
PAR_LEVEL=`get_param PARALLELISM_LEVEL_PORTAGELIVE`
if [[ $PAR_LEVEL && $PAR_LEVEL -gt 1 ]]; then
   PARALLEL_OPT="-w=3 -n=$PAR_LEVEL"
fi

# Locate the canoe.ini.cow file.
# We assume that this translate.sh script is at the root of the framework.
CANOE_INI="canoe.ini.cow"
if [[ ! -e ${CANOE_INI} ]]; then
   CANOE_INI="${ROOTDIR}/translate/canoe.ini.cow"
   [[ -e ${CANOE_INI} ]] || ln -s "../models/decode/canoe.ini.cow" ${CANOE_INI}
   CANOE_INI_OPT="-f=\"${CANOE_INI}\""
fi

# Determine if truecasing
if [[ `get_param DO_TRUECASING` == 1 ]]; then
   TPLM_CNT=0
   TPLM=( `dirname ${CANOE_INI}`/models/tc/*.tplm )
   if [[ ! "${TPLM[*]}" =~ '\*' ]]; then
   	  # found files with .tplm extension - need to exclude any log files.
      for NAME in ${TPLM[*]}; do
         [[ $(basename ${NAME}) =~ '^log.*$' ]] || TPLM_CNT=$(( $TPLM_CNT + 1 ))
      done
   fi
   if [[ ${TPLM_CNT} -gt 0 ]]; then
      TC_OPT="-tctp"
      verbose 1 "Using tightly packed truecasing model (-tctp)."
   else
      TC_OPT="-tc"
      verbose 1 "Using text truecasing model (-tc)."
   fi
else
   verbose 1 "Not truecasing."
fi

for (( V=$VERBOSE; $V>0; V=$V-1 )) ; do
   V_OPT="$V_OPT -v"
done

[[ $QUIET ]] && Q_OPT="-quiet"

# Make sure plugins in the plugins directory in the framework will be used by translate.pl.
export PATH="${ROOTDIR}/plugins:$PATH"

run_cmd "translate.pl $MODE $SRC_OPT $TGT_OPT $TMX_SRC_OPT $TMX_TGT_OPT $PARALLEL_OPT $TC_OPT $CANOE_INI_OPT $V_OPT $Q_OPT $SOURCE_FILE"

exit
