#!/bin/bash
# Technologies langagieres interactives / Interactive Language Technologies
# Inst. de technologie de l'information / Institute for Information Technology
# Conseil national de recherches Canada / National Research Council Canada
# Copyright 2008, Sa Majeste la Reine du Chef du Canada
# Copyright 2008, Her Majesty in Right of Canada


usage() {
   for msg in "$@"; do
      echo $msg >&2
   done
   cat <<==EOF== >&2

Usage: translate.sh [options] source_file

  Takes a source text file and translates it according to the current trained
  models.
  source_file must be tokenized and splitted one sentence per line.

Options:

  -l(ang)     language of source_file [en].
  -h(elp)     print this help message
  -v(erbose)  increment the verbosity level by 1 (may be repeated)
  -d(ebug)    print debugging information

==EOF==

   exit 1
}

# error_exit "some error message" "optionnally a second line of error message"
# will exit with an error status, print the specified error message(s) on
# STDERR.
error_exit() {
   for msg in "$@"; do
      echo $msg >&2
   done
   echo "Use -h for help." >&2
   exit 1
}

# Verify that enough args remain on the command line
# syntax: one_arg_check <args needed> $# <arg name>
# Note that this function expects to be in a while/case structure for
# handling parameters, so that $# still includes the option itself.
# exits with error message if the check fails.
arg_check() {
   if [ $2 -le $1 ]; then
      error_exit "Missing argument to $3 option."
   fi
}

# arg_check_int $value $arg_name exits with an error if $value does not
# represent an integer, using $arg_name to provide a meaningful error message.
arg_check_int() {
   expr $1 + 0 &> /dev/null
   RC=$?
   if [ $RC != 0 -a $RC != 1 ]; then
      error_exit "Invalid argument to $2 option: $1; integer expected."
   fi
}

# arg_check_pos_int $value $arg_name exits with an error if $value does not
# represent a positive integer, using $arg_name to provide a meaningful error
# message.
arg_check_pos_int() {
   expr $1 + 0 &> /dev/null
   RC=$?
   if [ $RC != 0 -a $RC != 1 ] || [ $1 -le 0 ]; then
      error_exit "Invalid argument to $2 option: $1; positive integer expected."
   fi
}

# Print a warning message
warn() {
   echo "WARNING: $*" >&2
}

# Print a debug message
debug() {
   test -n "$DEBUG" && echo "<D> $*" >&2
}

# Print a verbose message
verbose() {
   level=$1; shift
   if [[ $level -ge $VERBOSE ]]; then
      echo "$*" >&2
   fi
}


# Command line processing [Remove irrelevant parts of this code when you use
# this template]
VERBOSE=0
LANGUAGE=en
while [ $# -gt 0 ]; do
   case "$1" in
   -l|-lang)            arg_check 1 $# $1; LANGUAGE=$2; shift;;
   -v|-verbose)         VERBOSE=$(( $VERBOSE + 1 ));;
   -d|-debug)           DEBUG=1;;
   -h|-help)            usage;;
   --)                  shift; break;;
   -*)                  error_exit "Unknown option $1.";;
   *)                   break;;
   esac
   shift
done

test $# -eq 0   && error_exit "Missing the input file to translate."
full_source=$1; shift
source=`basename $full_source`

# Make sure that the source has the framework's expected form
# <PREFIX>_<LANGUAGE>.al
source=${source%_${LANGUAGE}.al}_${LANGUAGE}.al

# Are there superfluous arguments
test $# -gt 0   && error_exit "Superfluous arguments $*"

# Extract the prefix of this translation set.
prefix=${source%_${LANGUAGE}.al}

# Check if the inputs are of the form <stem>_<src_lang>.<langx>
verbose 1 "Translating: $prefix"

# Lets make a copy of the source file in corpora
test -f corpora/$source || cp $full_source corpora/$source

# Check if there is a valid decoding_model and if needed a valid rescoring_model
[[ -f "models/decode/canoe.ini.cow" ]] || error_exit "You need to train a decoding model first (models/decode)"

# Preprocess the corpus
make -C corpora translate TRANSLATE_SET=$prefix 1>&2
if [[ $? -ne 0 ]]; then
   error_exit "Problem while preprocessing $source";
fi

# And decode
make -C translate all TEST_SET=$prefix 1>&2
if [[ $? -ne 0 ]]; then
   error_exit "Problem while translating $source";
fi

#echo "Your file is available in" >&2
#cat translate/$prefix.translation

echo "Your translation file is available here: translate/$prefix.translation"
