#! /usr/bin/env bash

if [[ $# != 1 || ! -f "$1" ]] ; then
  exit 1
fi

#parsing
readarray -t LINE_ARRAY < "$1"
times=( ${LINE_ARRAY[0]##Time:} )
records=( ${LINE_ARRAY[1]##Distance:} )

#execution
start=$(gdate "+%s%N")
new_records_arr=()

for race in ${!times[@]}; do
  new_records=0

  for i in $(seq ${times[$race]} ); do
    speed=$i
    time_left=$(( ${times[$race]} - i ))
    distance=$(( speed * time_left ))
    (( distance > ${records[$race]} )) && (( new_records++ ))
  done
  new_records_arr[$race]=$new_records
done

res=1
for i in ${new_records_arr[@]}; do
  (( res *= i ))
done
end=$(gdate "+%s%N")

echo "Result : ${res} (time:"$(echo "$end - $start" | bc -l)"ns)"
