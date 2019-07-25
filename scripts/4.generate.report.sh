#! /bin/bash/

#if [ "$#" -lt 2 ] ; then
#   echo "Usage: sh 4.generate.report [config]"
   #echo "Example: sh analysis/scripts/3.quality.metrics.sh /nfs/ngs/WINKNGS/Villarin/Lupinen RNADATA/ PIPELINE/ PIPELINE/lupinus.labs.shrt" 
#   exit
#fi


if [ "$#" == 1 ]; then
  while IFS='=' read key value; do
    case $key in
    pdir)
      pdir=$value
    ;;
    esac
  done <<<"$(cat $1 |grep "=" )" 
  source $pdir/tool.parse.config.sh $1
fi


if [ $blastdbtype == 'nucl' ];
then 
  BLAST=$BLASTN;
else
  BLAST=$BLASTX
fi


$RSCRIPT $pdir/tool.summary.RScript $odir $labs $blastdb $buscodb $BLAST $thresh $pdir/ $blastpid 
##### End of Transrate