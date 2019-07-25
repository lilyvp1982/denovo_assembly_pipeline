#! /bin/bash/

if [ "$#" -lt 3 ]; then
  echo "Usage: sh tool.busco.sh data_n data busco_odir [config]"
  exit
fi


data_n=$1
data=$2
busco_odir=$3

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


buscorun=$buscopref"_"$data_n
echo $buscorun

if [ ! -e "$busco_odir/short_summary_$buscorun.txt" ]; then
      if [ ! -e "$buscodir/run_$buscorun/short_summary_$buscorun.txt" ]; then
        $PYTHON $runBusco -c 10 -i $data -l $buscodb -o $buscorun -f
        if [ -e "$buscodir/run_$buscorun/short_summary_$buscorun.txt" ]; then
          mv $buscodir/run_$buscorun/short_summary_$buscorun.txt $busco_odir/short_summary_$buscorun.txt
          rm -r $buscodir/run_$buscorun/
        else
          echo "BUSCO failed check 4.busco.log"
        fi
      else
        mv $buscodir/run_$buscorun/short_summary_$buscorun.txt $busco_odiro/short_summary_$buscorun.txt
        rm -r $buscodir/run_$buscorun/    
      fi
 fi
      