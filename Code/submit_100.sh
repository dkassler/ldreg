#!/bin/bash

r_script = $1
sub_or_main = ${2:-sub}

if [ $sub_or_main == "sub" ]
then
  bsub -q short -W 12:00 -J "\$r_script[1-100]" -o output/bsub_output.%I \
  "./submit_100.sh \$r_script main \$LSB_JOBINDEX"
else
  Rscript $r_script $3
fi
