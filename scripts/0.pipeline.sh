#! /bin/bash/


if [ "$#" -lt 1 ] ; then
   echo "Usage: \n sh 0.pipeline.sh 0.config.txt [flag_trinity=[0/1] flag_filter=[0/1] flag_qualitymetrics=[0/1] flag_generate_report=[0,1]] [ann_flag]"
   echo "Example: \n sh 0.pipeline.sh /nfs/ngs/WINKNGS/Villarin/rna_pipeline/init_files/0.config.txt [0 1 0 1]" 
   exit
else
  if [ ! -f $1 ]; then
    echo "$1 is not a valid config file" 
    exit
  else 
    config=$1   
    fi
fi

#### A partir de aqui!!!!
# Flags para quality metrics f1 si hay que mapear, f2 busco, f3 transrate

if [ "$#" -eq 5 ]; then
  ftrinity=$2
  ffilter=$3
  fqualitymetrics=$4
  freport=$5
else
 ftrinity=1
  ffilter=1
  fqualitymetrics=1
  freport=1
fi

blastpid=70

while IFS='=' read key value; do
  case $key in
  pdir)
    pdir=$value
  ;;
  esac
done <<<"$(cat $config |grep "=" )" 
 
## TODO check weather config files exist...
source $pdir/tool.parse.config.sh

if [  $? != 0 ]; then
  echo "Something happened, check error messages, probably unexisting config or labels file"
  exit 
fi  

echo "Ready to start"
if [ $ftrinity == 1 ]; then
  sh $pdir/1.trinity.pipeline.sh 
fi

if [ $ffilter == 1 ]; then
  sh $pdir/2.filter.pipeline.sh $odir/1.2.bams.transcriptomes $odir/1.1.transcriptomes
fi

if [ $fqualitymetrics == 1 ]; then
  sh $pdir/3.quality.metrics.sh $odir/2.1.filtered.transcriptomes.$thresh/ *.fasta $fmap $fbusco
fi

if [ $freport == 1 ]; then
  sh $pdir/4.generate.report.sh
fi 