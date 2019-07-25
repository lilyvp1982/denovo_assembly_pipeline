#! /bin/bash/

#if [ "$#" -lt 1 ] ; then
#   echo "Usage: \n sh 1.1.trinity.pipeline.sh  [mapping_flag] [ann_flag] [busco_flag] [0.config.txt]"
#    echo "Example: \n sh analysis/scripts/1.1.trinity.pipeline.sh /nfs/ngs/WINKNGS/Villarin/rna_pipeline/init_files/0.config.txt 1 1 0" 
#   exit
#fi

if [ "$#" -gt 2 ] ; then
  mapping_fl=$1
  ann_fl=$2
  busco_fl=$3
else
    mapping_fl=1; 
    ann_fl=1;
    busco_fl=1;
fi

if [ "$#" -gt 3 ] ; then
  while IFS='=' read key value; do
    case $key in
    pdir)
      pdir=$value
    ;;
    esac
  done <<<"$(cat $4 |grep "=" )" 
  source $pdir/tool.parse.config.sh
fi


##### Processing labels files
eval data=($(awk -F "," '{ if($3 != "File") print $2 $3 }' $labs))
eval species=($(awk -F "," '{ if ($3 != "File") print $4}' $labs))
u_sp=($(echo "${species[@]}" | tr ' ' '\n' | sort -u | tr '\n' ' '))
#eval tissue=($(awk -F "," '{ if ($3 != "File") print $5}' $labs))

# Number of elements of array ${#a[@]}
# All indices of array ${!a[@]}
# Value of $i-th element of an array ${a[$i]}

a_n=()
a=()
k=0

for i in ${u_sp[@]}; 
do 
  if [[ $i != 'Species' ]]; then 
    a_n[$k]=$i
    for j in ${!species[@]}; do 
        if [ "${species[$j]}" == $i ]; then
          if [ "${#a[$k]}" == 0 ]; then
            a[$k]=${data[$j]}
          else 
            a[$k]=${a[$k]}','${data[$j]}
          fi
        fi
    done
    k=$k+1
   fi   
done


#### End of Labels file processing
### a contains comma separated files for each species
### a_n contains name of the species

##### Assembling de novo transcriptomes
transcdir=$odir/1.1.transcriptomes
echo $transcdir
if  [ ! -d $transcdir ]; then 
  mkdir -p $transcdir
fi

echo "Beginning Trinity"

for i in ${!a_n[@]}; do
  echo "Analysing species "${a_n[$i]}
  echo "$transcdir/${a_n[$i]}.fasta"

  if [ ! -e "$transcdir/${a_n[$i]}.fasta" ]; then 
    if [ ! -e  "$odir/${a_n[$i]}/trinity/Trinity.fasta" ]; then
      if [ ! -d $odir/${a_n[$i]} ]; then 
        mkdir -p $odir/${a_n[$i]}  
      fi
      echo "Running Trinity, find Trinity logs in $odir/${a_n[$i]}/trinity.log"
      $TRINITY --seqType fq --output $odir/${a_n[$i]}/trinity --max_memory 8G --CPU 8  --normalize_reads --normalize_max_read_cov 50 --bflyCPU 4 --bflyHeapSpaceMax 1G --single ${a[$i]} >> $odir/${a_n[$i]}/trinity.log
      
      if [ -e  "$odir/${a_n[$i]}/trinity/Trinity.fasta" ]; then
        mv $odir/${a_n[$i]}/trinity/Trinity.fasta $transcdir/${a_n[$i]}.fasta
        mv $odir/${a_n[$i]}/trinity.log $transcdir/${a_n[$i]}.log
        rm -r $odir/${a_n[$i]}
      else
        echo $odir/${a_n[$i]}/trinity/Trinity.fasta does not exist! Check what happened with Trinity.
      fi
    else
        mv $odir/${a_n[$i]}/trinity/Trinity.fasta $transcdir/${a_n[$i]}.fasta
        mv $odir/${a_n[$i]}/trinity.log $transcdir/${a_n[$i]}.log
        rm -r $odir/${a_n[$i]}
    fi
  else
    echo "$transcdir/${a_n[$i]}.fasta exists: skipping Trinity comand"
  fi    
done

echo "Finished Trinity"

##### End assembling de novo transcriptomes


##### Mapping raw reads to de novo transcriptomes
if [ $mapping_fl == 1 ]; then 
  
  echo "Beginning Mapping"
  
  bamdir=$odir/1.2.bams.transcriptomes
  mkdir -p $bamdir
  
  for i in ${!a_n[@]}; 
  do 
    data=${a[$i]}
    data_n=${a_n[$i]}  
    sh $pdir/tool.map_raw_reads_to_trinity.sh $transcdir/$data_n.fasta $data $bamdir >> $odir/1.2.mapping.log #$BWA $SAMTOOLS optional
  done
  
  echo "Finished Mapping"
fi

##### End of Mapping raw reads to de novo transcriptomes


##### Annotate
if [ $ann_fl == 1 ]; then 
  echo "Beginning Blast"
  
  anndir=$odir/1.3.annotation
  
  if [ ! -d $anndir ]; then
    mkdir -p $anndir
  fi
  
  for i in ${!a_n[@]}; 
  do 
    data_n=${a_n[$i]} 
    data=$transcdir/$data_n.fasta
    if [ $blastdbtype == 'nucl' ]; then 
      BLAST=$BLASTN;
    else 
      BLAST=$BLASTX;
    fi 
     sh $pdir/tool.annotate.sh $data_n $data $anndir>> $odir/1.3.annotate.log # $pdir $blastdb $blastdbtype 
  done
  
  echo "Finished Blast"
fi
##### End Annotate

##### BUSCO

if [ $busco_fl == 1 ]; then 

  echo "Beginning BUSCO"
  
  buscodir_o=$odir/1.4.busco
  if [ ! -d $buscodir_o ]; then
    echo $buscodir_o
    mkdir -p $buscodir_o
  fi
  
  for i in ${!a_n[@]}; 
  do 
    data_n=${a_n[$i]}  
    data=$data_n.fasta
    sh $pdir/tool.busco.sh $data_n $transcdir/$data $buscodir_o>> $odir/1.4.busco.log
  done
  
  echo "Finished BUSCO"
fi

##### End of BUSCO