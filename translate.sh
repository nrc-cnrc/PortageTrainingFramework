#!/bin/bash

source=$1
target=$2

stem=${1%_*.*}

# Check if the inputs are of the form <stem>_<src_lang>.<langx>
echo "Translating: $stem"

# Check if there is a valid decoding_model and if needed a valid rescoring_model

# Prepare the source corpora for translation.
make -n -C corpora translate TRANSLATE_SET=$source || (echo "Unable to preprocess file." && exit 1)

# Prepare the target corpora to score the translations.
(test -n "$target" && make -n -C corpora reference TRANSLATE_SET=$target) || (echo "Unable to preprocess file." && exit 1)


# And decode
make -n -C translate all PREFIX_TESTSET=$stem || (echo "Unable to translate file." && exit 1)

