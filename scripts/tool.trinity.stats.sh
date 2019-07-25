#! /bin/bash/

TRINITY="/gcg/husar.gcg10.2-centos-husar3/gcgsource/library/trinitylib/trinityrnaseq-Trinity-v2.6.5/"

if [ "$#" -lt 3 ]; then
  echo "Usage: sh 2.2.2.trinity.stats.sh fastadir pattern odir [ref]"
  exit
fi

fastadir=$1
pattern=$2
odir=$3
if [ "$#" -gt 3 ]; then
  ref=$4
fi

echo "Trinitystats"
  
a=$(ls $fastadir/$pattern)

mkdir -p $odir


for tr in ${a[@]}; 
do 
  for j in  $tr; do 
    echo $j
    echo $j >> $odir/trinity.statistics.txt
    $TRINITY/util/TrinityStats.pl $j >> $odir/trinity.statistics.txt
  done
done



echo "DONE"