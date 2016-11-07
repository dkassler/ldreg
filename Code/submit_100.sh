#!/bin/bash

r_script=$1
sub_or_main=${2:-sub}

if [ $sub_or_main == "sub" ]
then
  regex="^.*\."
  if [[ $r_script =~ $regex ]]
  then
    name=${BASH_REMATCH[1]}
  else
    echo "Could not find name for submitted job!"
    exit 1
  fi
  if [ ! -d "output/$name"]; then
    mkdir "output/$name"
  fi
  bsub -q short -W 12:00 -J "$name[1-100]" -eo "output/$name/bsub_output.%I" \
  "./submit_100.sh $r_script main \$LSB_JOBINDEX"
else
  Rscript $r_script $3
fi
