#! /bin/bash/

echo "YUJUUUUUUUUUUUUUUUUUUUUUUUUUUUUUUUUUUUUUUUUUUUuu"
 
pipedir="/nfs/ngs/WINKNGS/Villarin/Lupinen/analysis/pipeline/"

if [ "$#" -eq 0 ] ; then
 echo "Usage:"
 echo "   sh 1.3.tool.blast.sh data_n data db dbtype odir"
 echo "    data_n: name of the data"
 echo "    data: path to fasta file"
 echo "    path to database/db name,if global"
 echo "    dbtype: db type, one of [nucl/prot]"
 echo "    odir: where to save the results"
 exit
fi
# E.G. sh $pipedir/1.3.tool.blast.sh 'L.albus' '/nfs/ngs/WINKNGS/Villarin/Lupinen/EXAMPLE_RNADATA/1.transcriptome/L.albus.fasta' '/nfs/ngs/WINKNGS/Villarin/Lupinen/Transcriptome/Lupinus_angustifolius_cds_v1.0.fa' 'nucl' '/nfs/ngs/WINKNGS/Villarin/Lupinen/EXAMPLE_RNADATA/3.annotation'  

 #sh /nfs/ngs/WINKNGS/Villarin/Lupinen/analysis/pipeline/1.3.tool.blast.sh 'Ophiorriza.saito' '/nfs/ngs/WINKNGS/Villarin/Ophiorriza/2.1.filtered.transcriptomes.0.05/Ophiorriza.filtered.fasta.cdhit.fasta' '/nfs/ngs/WINKNGS/Villarin/Ophiorriza/organisms/opu_unigene.fa' 'nucl' '/nfs/ngs/WINKNGS/Villarin/Ophiorriza/2.3.annotation/'  


data_n=$1
data=$2
db=$3
dbtype=$4
odir=$5

echo "makeblastdb -in $db -parse_seqids -dbtype $dbtype"

makeblastdb -in $db -parse_seqids -dbtype $dbtype
makeblastdb -in $data -parse_seqids -dbtype 'nucl'
 
if [ ! -e  $odir ]; then 
  mkdir $odir 
fi


if [ ! -e $odir/$data_n.blast.txt ]; then
  echo "Blastn "$data_n;
  if [ $dbtype = 'prot' ]; then
    echo "prot database"
    /gcg/husar/add_ons/blastx223plus.org -query $data -db $db -evalue 0.001 -num_alignments 3 -outfmt 6 -out $odir/$data_n.blast.txt -num_descriptions 2
  else
    echo "nucleotyde database"
    /gcg/husar/add_ons/blastn223plus.org -query $data -db $db -evalue 0.01 -num_alignments 4 -outfmt 6 -out $odir/$data_n.blast.txt -num_descriptions 2 
    /gcg/husar/add_ons/blastn223plus.org -query $db -db $data -evalue 0.01 -num_alignments 4 -outfmt 6 -out $odir/$data_n.blast.inverse.txt -num_descriptions 2
  fi
    
fi

echo $odir/$data_n.blastn.fasta
awk '{print $1","$2}' < $odir/$data_n.blast.txt > $odir/$data_n.blast.ids.txt
perl $pipedir/tool.extract.fasta.seq.pl $odir/$data_n.blastn.ids.txt $data $odir/$data_n.blast.fasta
  



#cat *.blastxplus > novel_genes_oenanthe_2016_swissprot.blast_result

#perl blast_annotate_swissprot.pl novel_genes_oenanthe_2016_swissprot.blast_result 50 > novel_genes_oenanthe_2016_swissprot.blast_result.annotated.tsv &

#awk '{print $1}' < novel_genes_oenanthe_2016_swissprot.blast_result.annotated.tsv | sort -u | wc
#     14      14     412
     
     
      