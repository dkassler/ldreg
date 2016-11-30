#!/bin/bash

arrayind_upper=100
sub_or_main='sub'
auto_name=1
write_note=0

while getopts ":o:n:Mi:m:" opt; do
  case $opt in
    o)
      outname=$OPTARG
      auto_name=0
      ;;
    n)
      arrayind_upper=$OPTARG
      ;;
    M)
      sub_or_main='main'
      ;;
    i)
      jobindex=$OPTARG
      ;;
    m)
      NOTE=$OPTARG
      write_note=1
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
    outname=${BASH_REMATCH[1]}
    echo "Naming job automatically."
  else
    echo "Could not find name for submitted job!"
    exit 1
  fi
fi

today=`date +%F`
outdir="output/$outname/$today"

if [ $sub_or_main == 'sub' ]
then
  if [ ! -d "output/$outname" ]; then
    mkdir "output/$outname"
  fi
  mkdir $outdir
  mkdir "$outdir/log"
  mkdir "$outdir/out"
  cat $r_script > "$outdir/source.R"
  if [ $write_note == 1 ]; then
    echo $NOTE > "$outdir/NOTE.txt"
  fi
  bsub -q short -W 12:00 -J "$outname[1-$arrayind_upper]" -oo "$outdir/log/%I" \
  "./submit.sh -i \$LSB_JOBINDEX -M -o $outname $r_script"
else
  Rscript $r_script -d "$outdir/out" -i $jobindex
fi

