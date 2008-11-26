#!/bin/bash
# Technologies langagieres interactives / Interactive Language Technologies
# Inst. de technologie de l'information / Institute for Information Technology
# Conseil national de recherches Canada / National Research Council Canada
# Copyright 2008, Sa Majeste la Reine du Chef du Canada
# Copyright 2008, Her Majesty in Right of Canada


source=`basename $1`
target=$2

prefix=${1%_*.*}

# Check if the inputs are of the form <stem>_<src_lang>.<langx>
echo "Translating: $prefix"

# Lets make a copy of the source file in corpora
test -f corpora/$1 || cp $1 corpora

# Check if there is a valid decoding_model and if needed a valid rescoring_model

# And decode
#make -nt -C corpora ${prefix}_en.rule ${prefix}_en.lc \
make -nt -C corpora test TRANSLATE_SET=${prefix} \
&& make -n -C translate all TRANSLATE_SET=$prefix

echo "Your file is available in" >&2
