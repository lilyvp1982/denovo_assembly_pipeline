#! /bin/bash/

while IFS='=' read key value; do
  case $key in
  pdir)
    export pdir=$value
  ;;
  odir)
    export odir=$value
  ;;
  labs)
    if [ ! -f $value ]; 
    then 
      echo "$value is not a valid labels file: put the correct (existing) one in your config file";
      return 1 
    fi  
    export labs=$value
  ;;
  blastdb)
    export blastdb=$value
  ;;
  blastdbtype)
    export blastdbtype=$value
  ;;
  blastpid)
    export blastpid=$value
  ;;
  buscodb)
    export buscodb=$value
  ;;
  buscodir)
    export buscodir=$value
  ;;
  buscoconfig)
    export BUSCO_CONFIG_FILE=$value
  ;;
  buscopref)
    export buscopref=$value
  ;;
  thresh)
    export thresh=$value
  ;;
   *)
  ;;
esac
done <<<"$(cat $1 |grep "=" )"
while IFS='=' read key value; do
  case $key in
  spath)
    export PATH=$value:$PATH
   ;;
  TRINITY)
    export TRINITY=$value
   ;; 
  SAMTOOLS)
    export SAMTOOLS=$value
   ;;
  BLASTN)
    export BLASTN=$value
  ;; 
  BLASTX)
    export BLASTX=$value
  ;; 
  CDHIT)
    export CDHIT=$value
  ;;
  RSCRIPT)
    export RSCRIPT=$value
  ;;
  augustoconfig)
    export AUGUSTUS_CONFIG_PATH=$value
  ;;
  PYTHON)
    export PYTHON=$value
  ;;
  runBusco)
    export runBusco=$value
  ;;
  makeblastdb)
    export makeblastdb=$value
  ;;
  BWA)
    export BWA=$value
   ;;
  perl)
    export PERL=$value
   ;;
  *)
  ;;
esac
done <<<"$(cat $pdir/sft.config.txt |grep "=" )"