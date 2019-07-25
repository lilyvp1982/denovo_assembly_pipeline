#! /bin/bash/

transratedir="$NGSUTILDIR/transrate-1.0.3-linux-x86_64/"

if [ "$#" -lt 3 ]; then
  echo "Usage: sh 2.2.1.transrate.sh fastadir pattern odir [ref]"
  exit
fi

fastadir=$1
pattern=$2
odir=$3
if [ "$#" -gt 3 ]; then
  ref=$4
fi

echo "Transrate"
  
a=$(ls $fastadir/$pattern)
b="${a//$'\n'/,}"
mkdir -p $odir
echo $b

$transratedir/transrate --assembly $b,$ref --output $odir
cat $odir/assemblies.csv >> $odir/assembies.stats.csv
rm  $odir/assemblies.csv 
echo "DONE"