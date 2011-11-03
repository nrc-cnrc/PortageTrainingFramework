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



CONTEXT=`dirname $0`
# This can either be "full" or "partial".
PrimeMode=$1

# Prime all models in their entirety.
if [[ "$PrimeMode" == "full" ]]; then
   for f in `find $CONTEXT -name \*.tppt; find $CONTEXT -name \*.tpldm; find $CONTEXT -name \*.tplm`; do
      cat $f/* &> /dev/null
   done
elif [[ "$PrimeMode" == "partial" ]]; then
   for f in `find $CONTEXT/models/tm -name \*.tppt; find $CONTEXT/models/lm -name \*.tplm`; do
      SIZE=$((`cat $f/* | \wc -c` / 4))
      cat $f/* | head --byte=$SIZE &> /dev/null
   done
else
   exit 3
fi

exit
