#!/bin/bash
# $Id$

# @file prime.sh
# @brief Load memory map models in memory.
#
# @author Samuel Larkin
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
#       - partial: load phrase tables and language models only.
# NOTE:
#   In both cases, we want to load the language models last since it is more
#   crutial to have them in memory then the other models.  By loading them
#   last, they can replace parts of the other models if there is not enough
#   memory to hold all models at once in memory.

CONTEXT=`dirname $0`
# This can either be "full" or "partial".
PrimeMode=$1

if [[ "$PrimeMode" == "full" ]]; then
   # Prime all models in their entirety.
   for f in `find $CONTEXT -name \*.tppt; find $CONTEXT -name \*.tpldm; find $CONTEXT -name \*.tplm`; do
      cat $f/* &> /dev/null
   done
elif [[ "$PrimeMode" == "partial" ]]; then
   # Prime all phrase table models and language models for decoding.
   # TMs
   for d in `find $CONTEXT/models/tm -name \*.tppt`; do
      for f in $d/*; do
         SIZE=$((`du -b $f | cut -f 1` / 4))
         head --byte=$SIZE $f &> /dev/null
      done
   done
   # LMs
   for d in `find $CONTEXT/models/lm -name \*.tplm`; do
      for f in $d/*; do
         #SIZE=$((`du -b $f | cut -f 1` / 4))
         #head --byte=$SIZE $f &> /dev/null
         cat $f &> /dev/null
      done
   done
else
   exit 3
fi

exit
