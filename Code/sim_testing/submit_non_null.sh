#!/bin/bash

sub_or_main=$1

if [ $sub_or_main == "sub" ]
then
  bsub -q short -W 12:00 -J "test_non_null[1-100]" -o bsub_output.%I \
  "./submit_non_null.sh main \$LSB_JOBINDEX"
else
  #Rscript test_non_null_cluster.R > test_non_null_output.$2.txt
  Rscript test_non_null_cluster.R $2
fi
