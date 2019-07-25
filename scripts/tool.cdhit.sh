#! /bin/bash/

if [ "$#" -lt 2 ] ; then
 echo "Usage: \n sh tool.cdhit.sh fastadir pattern [config]"
 exit
fi

path=$1
patt=$2

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
 
   for i in $path/$patt ; do
   
   i_n="$(basename $i)"
   echo $i_n
   if [ ! -f $path/../../2.1.filtered.transcriptomes.$thresh/$i_n.cdhit.fasta ] && [ ! -f $i.cdhit.fasta ]; 
     then
      echo "CDHIT: $CDHIT -i $i -d 0 -o $i.cdhit.fasta -c 0.9 -n 8  -r 0 -G 1 -g 1 -b 20 -s 0.0 -aL 0.0 -aS 0.0 -T 8 -M 32000"
     $CDHIT -i $i -d 0 -o $i.cdhit.fasta -c 0.9 -n 8  -r 0 -G 1 -g 1 -b 20 -s 0.0 -aL 0.0 -aS 0.0 -T 8 -M 32000 >> $path/cdhit.log
   fi
done


