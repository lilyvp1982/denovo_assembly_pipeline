#! /bin/bash/
 
if [ "$#" -lt 2 ] ; then
 echo "Usage: \n sh extract.fasta.ids.sh path pattern"
 exit
fi

path=$1
 
if [ "$#" -gt 1 ] ; then
  patt=$2
fi

for a in  $path/$patt; do
  echo $a
   if [ -d $a ]; then
     s=${a##*trinity.}  
     echo "Extracting fasta ids "$a;
     awk '/^>/ {print $1}' $a/Trinity*.fasta > $a/trinity.ids.txt
   fi
done     
      