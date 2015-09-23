#!/bin/bash

# @file prime.sh
# @brief Load memory map models and software into memory.
#
# @author Samuel Larkin and Darlene Stewart
#
# Technologies langagieres interactives / Interactive Language Technologies
# Inst. de technologie de l'information / Institute for Information Technology
# Conseil national de recherches Canada / National Research Council Canada
# Copyright 2011-2015, Sa Majeste la Reine du Chef du Canada /
# Copyright 2011-2015, Her Majesty in Right of Canada


# Usage:
# prime.sh PrimeMode
#    PrimeMode:
#       - full:    load all tightly packed models in memory.
#       - partial: load a minimal set of tpt in memory.
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

if [[ "$PrimeMode" == "full" ]] || [[ "$PrimeMode" == "partial" ]]; then
   configtool prime_$PrimeMode $CONTEXT/canoe.ini.cow
else
   # This is a unknown prime mode.
   exit 3
fi

#Prime the software.
if [[ -e $CONTEXT/ce_model.cem ]]; then
   # Translating 'a' is a temporray hack while we properly fix translating an
   # empty sentence with a system that has confidence estimation.
   $CONTEXT/soap-translate.sh -with-ce >& /dev/null <<< 'a'
else
   $CONTEXT/soap-translate.sh -decode-only >& /dev/null <<< ''
fi

exit
