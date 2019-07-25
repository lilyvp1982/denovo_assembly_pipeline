#! /bin/bash/

if [ "$#" -lt 2 ] ; then
   echo "Usage: sh 2.2.1.quality.metrics.sh fastadir pattern='filtered.fasta.cdhit.fasta' [f1 f2 f3] [config]"
   echo "Example: sh analysis/scripts/3.1.quality.metrics.sh /nfs/ngs/WINKNGS/Villarin/Lupinen RNADATA/ PIPELINE/ PIPELINE/lupinus.labs.shrt" 
   exit
fi

fastadir=$1
pattern=$2

if [ "$#" -gt 3 ]; then
  f1=$3
  f2=$4
else
  f1=1
  f2=1
fi

if [ "$#" -gt 5 ]; then
 while IFS='=' read key value; do
    case $key in
    pdir)
      pdir=$value
    ;;
    esac
  done <<<"$(cat $6 |grep "=" )" 
  source $pdir/tool.parse.config.sh
fi


buscopref=$buscopref"_filtered_"$thresh

source $pdir/tool.parselabels.sh $labs
### a contains comma separated files for each species
### a_n contains name of the species

##### Mapping raw reads to de novo transcriptomes
echo $odir/2.2.bams.filtered.transcriptomes.$thresh

if [ $f1 == 1 ]; then
  echo "Beginning Mapping"
  
  bamdir=$odir/2.2.bams.filtered.transcriptomes.$thresh
  mkdir -p $bamdir
  
  for i in ${!a_n[@]}; 
  do 
  
    data=${a[$i]}
    data_n=${a_n[$i]}  
    echo $data_n
    sh $pdir/tool.map_raw_reads_to_trinity.sh $fastadir/$data_n$pattern $data $bamdir >> $odir/2.2.mapping.log
  done
  
  echo "Finished Mapping"
fi
##### End of Mapping raw reads to de novo transcriptomes


##### BUSCO
if [ $f2 == 1 ]; then
  echo "Beginning BUSCO"
  
  buscodir_o=$odir/2.4.busco
  if [ ! -d $buscodir_o ]; then
    echo $buscodir_o
    mkdir -p $buscodir_o
  fi
  
  for i in ${!a_n[@]}; 
  do 
    data_n=${a_n[$i]}  
    data=$data_n$pattern 
    sh $pdir/tool.busco.sh $data_n $fastadir/$data $buscodir_o>> $odir/2.4.busco.log
  done

  echo "Finished BUSCO"
fi

##### End of BUSCO

#### Transrate

transratedir=$odir/3.transrate
mkdir -p $transratedir
rm -R $transratedir/*
  
sh $pdir/tool.transrate.sh $fastadir $pattern $transratedir $db
sh $pdir/tool.trinity.stats.sh $fastadir $pattern $transratedir

##### End of Transrate

#$RSCRIPT $pdir/tool.summary.RScript $odir $labs $blastdb $buscodb $BLAST $thresh $blastpid
