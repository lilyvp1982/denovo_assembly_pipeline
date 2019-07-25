#! /bin/bash

eval data=($(awk -F "," '{ if($3 != "File") print $2 $3 }' $1))
eval species=($(awk -F "," '{ if ($3 != "File") print $4}' $1))
u_sp=($(echo "${species[@]}" | tr ' ' '\n' | sort -u | tr '\n' ' '))
#eval tissue=($(awk -F "," '{ if ($3 != "File") print $5}' $labs))

# Number of elements of array ${#a[@]}
# All indices of array ${!a[@]}
# Value of $i-th element of an array ${a[$i]}

a_n=()
a=()
k=0

for i in ${u_sp[@]}; 
do 
  if [[ $i != 'Species' ]]; then 
    a_n[$k]=$i
    for j in ${!species[@]}; do 
        if [ "${species[$j]}" == $i ]; then
          if [ "${#a[$k]}" == 0 ]; then
            a[$k]=${data[$j]}
          else 
            a[$k]=${a[$k]}','${data[$j]}
          fi
        fi
    done
    k=$k+1
   fi   
done


#### End of Labels file processing
### a contains comma separated files for each species
### a_n contains name of the species
export a
export a_n
