#! /bin/bash/

if [ "$#" -lt 3 ] ; then
   echo "Usage: " 
   echo "sh analysis/pipeline/2.map_raw_reads_to_trinity ref data bamsdir [config]"
   echo "  ref is the path to the reference transcriptome"
   echo "  data is a comma separated list of files"
   echo "  bamdir is where the bam files will be stored."
   echo "[config file] optional : project config file"
   echo "  In bamsdir\stats.txt you can find the mapping statistics"
   exit
fi

ref=$1
data=$2
bamdir=$3


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


if [ ! -d $bamdir ]; then 
  mkdir -p $bamdir
fi

if [ -e $ref.sa ]; then
  echo "BWA index for $ref exists"
else
 $BWA index $ref
fi
IFS=',' read -r -a array <<< "$data"

for f1 in ${array[@]};
do
  f=$(basename $f1)
  
  if [ ! -e $bamdir/$f.counts ]; then
    if [ ! -e $bamdir/$f.sorted.bam.bai ]; then
      if [ ! -e $bamdir/$f.sorted.bam ]; then 
        if [ ! -e $bamdir/$f.bam ]; then
          if [ ! -e $bamdir/$f.sam ]; then
            echo "Aligning: $BWA mem -t 4 -v 1 $ref $f1 > $bamdir/$f.sam"
            time $BWA mem -t 4 -v 1 $ref $f1 > $bamdir/$f.sam
          fi
          echo "sam2bam: $SAMTOOLS view-Sbh $bamdir/$f.sam > $bamdir/$f.bam"
          time $SAMTOOLS view -Sbh $bamdir/$f.sam > $bamdir/$f.bam
          rm $bamdir/$f.sam
        fi
        echo "Sorting: $SAMTOOLS sort $bamdir/$f.bam > $bamdir/$f.sorted.bam"
        time $SAMTOOLS sort $bamdir/$f.bam > $bamdir/$f.sorted.bam
        rm $bamdir/$f'.bam'
      fi
      echo "Indexing: $SAMTOOLS index $bamdir/$f.sorted.bam"
      time $SAMTOOLS index $bamdir/$f.sorted.bam 
    fi
    echo "Counting: $SAMTOOLS idxstats $bamdir/$f.sorted.bam > $bamdir/$f.counts"
    time $SAMTOOLS idxstats $bamdir/$f.sorted.bam > $bamdir/$f.counts
  
    echo 'Samtools flagstat: '$f.sorted.bam
    echo $f.sorted.bam >> $bamdir/stats.txt
    $SAMTOOLS flagstat $bamdir/$f.sorted.bam | grep -v '^0 + 0' >> $bamdir/stats.txt 
  fi  
done