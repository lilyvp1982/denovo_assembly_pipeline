#! /bin/bash/

if [ "$#" -lt 3 ]; then
  echo "Usage: sh 1.3.annotate.sh data_n data anndir [config]"
  exit
fi

data_n=$1
data=$2
anndir=$3

if [ "$#" -gt 3 ]; then
  while IFS='=' read key value; do
    case $key in
    pdir)
      pdir=$value
    ;;
    esac
  done <<<"$(cat $4 |grep "=" )" 
  source $pdir/tool.parse.config.sh
fi

if [ $blastdbtype == 'nucl' ]; then
  BLAST=$BLASTN 
else
  BLAST=$BLASTX
fi

if [ ! -e  $anndir ]; then 
  mkdir $anndir 
fi

echo $BLAST
echo $blastdb

if [ -f $blastdb ]; then 
  echo "File db"
  $makeblastdb -in $blastdb -parse_seqids -dbtype $blastdbtype
   dbname=$(basename $blastdb)
  if [ ! -e $anndir/$data_n.$dbname.blast.txt ]; then
     $BLAST -query $data -db $blastdb -evalue 0.001 -num_alignments 2 -outfmt 6 -out $anndir/$data_n.$dbname.blast.txt -num_descriptions 2
  fi  
else
  if [ -d $blastdb ]; then
    echo "Multiple parts DB"
    for db in $( ls $blastdb/*.ref )
    do
      db=${db/.ref/}
      dbname=$(basename $db)
      if [ ! -e $anndir/$data_n.$dbname.blastx.txt ]; then
        echo "$BLASTX "$data_n;
        echo "prot database $db"
        $BLAST -query $data -db $db -evalue 0.005 -outfmt 6 -out $anndir/$data_n.$dbname.blastx.txt  -num_alignments 2&
      fi
    done 
  else
    echo "Database $db does not exist" 
  fi
fi