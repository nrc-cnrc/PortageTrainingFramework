#!/bin/bash
# $Id$

# @file prime.sh
# @brief Load memory map models and software into memory.
#
# @author Samuel Larkin and Darlene Stewart
#
# Technologies langagieres interactives / Interactive Language Technologies
# Inst. de technologie de l'information / Institute for Information Technology
# Conseil national de recherches Canada / National Research Council Canada
# Copyright 2011, Sa Majeste la Reine du Chef du Canada /
# Copyright 2011, Her Majesty in Right of Canada


# Usage:
# prime.sh PrimeMode
#    PrimeMode:
#       - full:    load all tightly packed models in memory.
#       - partial: load phrase tables and language models only; for phrase tables, load 
#                  only 25% of the tppt data file, but the entirety of the other tpt files.
# NOTE:
#   In both cases, we want to load the language models last since it is more
#   crucial to have them in memory then the other models. By loading them
#   last, they can replace parts of the other models if there is not enough
#   memory to hold all models at once in memory.
#
#   As a final step, prime the software by translating an empty string.

CONTEXT=`dirname $0`
# This can either be "full" or "partial".
PrimeMode=$1

if [[ "$PrimeMode" == "full" ]]; then
   # Prime all models in their entirety.
   for f in `find $CONTEXT/ -name \*.tppt; find $CONTEXT/ -name \*.tpldm; find $CONTEXT/ -name \*.tplm`; do
      cat $f/* &> /dev/null
   done
elif [[ "$PrimeMode" == "partial" ]]; then
   # Prime all phrase table models and language models for decoding.
   # Prime only 25% of any model.tppt/tppt file, but 100% of the other model.tppt/* files.
   # TMs
   for d in `find $CONTEXT/models/tm -name \*.tppt`; do
      for f in tppt; do
         SIZE=$((`du -b $d/$f | cut -f 1` / 4))
         head --byte=$SIZE $d/$f &> /dev/null
      done
      for f in cbk src.tdx trg.repos.dat trg.tdx; do
         cat $d/$f &> /dev/null
      done
   done
   # LMs
   for d in `find $CONTEXT/models/*lm -name \*.tplm`; do
      for f in $d/*; do
         cat $f &> /dev/null
      done
   done
else
   exit 3
fi

#Prime the software.
if [[ -e $CONTEXT/ce_model.cem ]]; then
   echo "" | $CONTEXT/soap-translate.sh -with-ce >& /dev/null
else
   echo "" | $CONTEXT/soap-translate.sh -decode-only >& /dev/null
fi

exit
