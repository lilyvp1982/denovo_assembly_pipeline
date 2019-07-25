#! /bin/bash/

if [ "$#" -lt 2 ] ; then
 echo "Usage: \n sh 2.2.extract.filtered.transcripts.sh fastadir seltranscdir [config]"
 echo "Example: sh ../../analysis/pipeline/2.2.extract.filtered.transcripts.sh 'EXAMPLE_PIPELINE/results/1.transcriptome/' 'EXAMPLE_PIPELINE/results/1.transcriptome/selten.filtered.0.01'"
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
 
path=$1
seltransc=$2

for i in $path/*.fasta ; do
  i1="${i/.fasta/}"
  i1="$(basename $i1)"
  if [ -e $seltransc/$i1.selected.trs.txt ]; then 
    $PERL $pdir/tool.extract.fasta.seq.pl $seltransc/$i1.selected.trs.txt $i $seltransc/$i1.filtered.fasta
  else 
    if [ -e $path/$seltransc/$i1.selected.trs.txt ]; then
         $PERL $pdir/tool.extract.fasta.seq.pl $path/$seltransc/$i1.selected.trs.txt $i $path/$seltransc/$i1.filtered.fasta
    fi
  fi
done
