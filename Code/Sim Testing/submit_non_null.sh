#!bin/bash

sub_or_main=$1

if [ $sub_or_main == "sub" ]
then
  bsub -q short -W 12:00 -J "test_non_null[1-10]" -o bsub_output.%I \
  "./submit_non_null.sh main \$LSB_JOBINDEX"
else
  echo $2 > test_non_null_output.$2.txt
fi
