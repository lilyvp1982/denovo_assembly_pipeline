#! /bin/bash/

if [ "$#" -lt 4 ]; then
  echo "Usage: sh tool.blastx.protdb.sh data_n data dbd odir [blastx]"
  exit
fi


data_n=$1
data=$2
dbd=$3
odir=$4
if [ "$#" -gt 4 ]; then
  BLASTX=$5
else
  BLASTX='/gcg/husar/add_ons/blastx250plus.org'
fi  
  
for db in $( ls $dbd/*.ref )
do
  db=${db/.ref/}
  dbname=$(basename $db)
  echo $db
  echo $dbname
 # makeblastdb -in $db -parse_seqids -dbtype $dbtype
  
  if [ ! -e  $odir ]; then 
    mkdir $odir   
  fi

  if [ ! -e $odir/$data_n.$dbname.blastx.txt ]; then
    echo "$BLASTX "$data_n;
    echo "prot database"
     $BLASTX -query $data -db $db -evalue 0.005 -outfmt 6 -out $odir/$data_n.$dbname.blastx.txt -num_descriptions 2 -num_alignments 2&
  fi
done