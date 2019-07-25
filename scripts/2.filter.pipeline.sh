#! /bin/bash

if [ "$#" -lt 2 ] ; then
   echo "Usage: \n sh 2.filter.pipeline.sh rel_bamsdir rel_trsdir [config]"
   echo "Example: \n sh 2.filter.pipeline.sh 1.2.bams.transcriptomes 1.1.transcriptomes " 
   exit
fi

if [ "$#" -gt 2 ] ; then
  while IFS='=' read key value; do
    case $key in
    pdir)
      pdir=$value
    ;;
    esac
  done <<<"$(cat $3 |grep "=" )" 
  source $pdir/tool.parse.config.sh
fi

bamsdir=$1
fastadir=$2

$RSCRIPT $pdir/tool.filter.selten.transcripts.R $labs $bamsdir $thresh $fastadir/selten_filtered.$thresh/

sh $pdir/tool.extract.filtered.transcripts.sh $fastadir $fastadir/selten_filtered.$thresh/

sh $pdir/tool.cdhit.sh $fastadir/selten_filtered.$thresh/ "*.filtered.fasta"

odir=$fastadir/../2.1.filtered.transcriptomes.$thresh
mkdir -p $odir

mv $fastadir/selten_filtered.$thresh/*cdhit.fasta $odir 