#!/bin/bash

arrayind_upper=100
sub_or_main='sub'
auto_name=1

while getopts ":o:n:mi:" opt; do
  case $opt in
    o)
      out_name=$OPTARG
      auto_name=0
      ;;
    n)
      arrayind_upper=$OPTARG
      ;;
    m)
      sub_or_main='main'
      ;;
    i)
      job_index=$OPTARG
      ;;
    \?)
      echo "Invalid option: -$OPTARG" >&2
      exit 1
      ;;
    :)
      echo "Option -$OPTARG requires an argument." >&2
      exit 1
      ;;
  esac
done

shift $((OPTIND - 1))

r_script=$1

if [ $auto_name == 1 ]
then
  regex="^(.*)\.R$"
  if [[ $r_script =~ $regex ]]
  then
    out_name=${BASH_REMATCH[1]}
    echo "Naming job automatically."
  else
    echo "Could not find name for submitted job!"
    exit 1
  fi
fi

today=`date +%F`
outdir="output/$out_name/$today"

if [ $sub_or_main == 'sub' ]
then
  if [ ! -d "output/$out_name" ]; then
    mkdir "output/$out_name"
  fi
  mkdir $outdir
  mkdir "$outdir/log"
  mkdir "$outdir/out"
  bsub -q short -W 12:00 -J "$out_name[1-$arrayind_upper]" -oo "$outdir/log/%I" \
  "./submit.sh -i \$LSB_JOBINDEX -m -o $out_name $r_script"
else
  Rscript $r_script -d "$outdir/out" -i $job_index
fi

