#! /bin/bash/
clear

export PATH=/opt/husar/bin:$PATH
#export PYTHONPATH=/opt/husar/python/Python-2.7/Lib2/lib/python2.7/site-packages/

pipedir='/nfs/ngs/WINKNGS/Villarin/Lupinen/analysis/pipeline/'

buscodir='/nfs/ngs/WINKNGS/Villarin/Lupinen/BUSCODB/'
buscopref='pipeline'

####
# Define global variables, e.g. buscodb, annotation database, thresholds, etc

####
if [ "$#" -lt 4 ] ; then
   echo "Usage: \n sh apply.blast.sh transcdir odir db dbtype"
    echo "Example: \n sh analysis/pipeline/apply.blast.sh /nfs/ngs/WINKNGS/Villarin/Lupinen/PIPELINE/2.1.filtered.transcriptomes.0.05/ /nfs/ngs/WINKNGS/Villarin/Lupinen/PIPELINE/2.3.annotation_targetgenes/ /nfs/ngs/WINKNGS/aura/lupines/biosynthesis_genes/La_alkaloid_biosynthesis_mRNA.fasta nucl" 
   exit
fi


transcdir=$1
anndir=$2
db=$3
dbtype=$4

echo $dbtype

##### Annotate
echo "Beginning Blast"

if [ ! -d $anndir ]; then
  mkdir -p $anndir
fi

for data in $transcdir/*.fasta; 
do 
  data_n=$( basename $data ) ;  
  data_n=${data_n/.filtered.fasta.cdhit.fasta/""};
  echo $data_n
  
  sh $pipedir/1.3.tool.blast.sh $data_n $data $db $dbtype $anndir >> $anndir/3.annotate.log
done
echo "Finished Blast"

##### End Annotate
