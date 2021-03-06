#!/bin/bash

arrayind_upper=100
sub_or_main='sub'
auto_name=1
write_note=0
clobber=0
exists_arrayname=0
memlimit=''
memflag=''

while getopts ":o:N:Ai:m:cj:M:d:" opt; do
  case $opt in
    o)
      outname=$OPTARG
      auto_name=0
      ;;
    N)
      arrayind_upper=$OPTARG
      ;;
    A)
      sub_or_main='main'
      ;;
    i)
      jobindex=$OPTARG
      ;;
    m)
      NOTE=$OPTARG
      write_note=1
      ;;
    c)
      clobber=1
      ;;
    j)
      arrayname=$OPTARG
      exists_arrayname=1
      ;;
    M)
      memlimit="rusage[mem=$OPTARG]"
      memflag=-R
      ;;
    d)
      outdir=$OPTARG
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
if [ $exists_arrayname == 0 ]; then
  arrayname=$outname
fi

if [ $sub_or_main == 'sub' ]
then
  if [ ! -d "output/$outname" ]; then
    mkdir "output/$outname"
  fi
  if [ -d "output/$outname/$today" ]
  then
    if [ $clobber == 1 ]
    then
      rm -r "output/$outname/$today"
      outdir="output/$outname/$today"
      echo "Overwriting $outdir."
    else
      tag=0
      chars=( {a..z} )
      while [ -d "output/$outname/$today${chars[tag]}" ]; do
        let tag=tag+1
      done
      outdir="output/$outname/$today${chars[tag]}"
      echo "Previous runs exist. Output will be in $outdir."
    fi
  else
    outdir="output/$outname/$today"
  fi
  mkdir $outdir
  mkdir "$outdir/log"
  mkdir "$outdir/out"
  cat $r_script > "$outdir/source.R"
  #Rscript -e 'devtools::session_info()' > "$outdir/session_info.txt"
  if [ $write_note == 1 ]; then
    echo $NOTE > "$outdir/NOTE.txt"
  fi
  bsub -q short -W 12:00 -J "$arrayname[1-$arrayind_upper]" $memflag $memlimit -oo "$outdir/log/%I" \
  "./submit.sh -i \$LSB_JOBINDEX -A -o $outname -d $outdir $r_script"
else
  Rscript $r_script -d "$outdir/out" -i $jobindex
fi

