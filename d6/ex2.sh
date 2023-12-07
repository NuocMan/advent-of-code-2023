#! /usr/bin/env bash

if [[ $# != 1 || ! -f "$1" ]] ; then
  exit 1
fi

readarray -t LINE_ARRAY < "$1"
temp_times="${LINE_ARRAY[0]##Time:}"
temp_records="${LINE_ARRAY[1]##Distance:}"
times=( ${temp_times// /} )
records=( ${temp_records// /} )

new_records_arr=()


for race in ${!times[@]}; do
  new_records=0
  i=1
  while (( $i < ${times[$race]} )); do
    speed=$i
    time_left=$(( ${times[$race]} - i ))
    distance=$(( speed * time_left ))
    (( distance > ${records[$race]} )) && (( new_records++ ))
    (( i++ ))
  done
  new_records_arr[$race]=$new_records
done

res=1
for i in ${new_records_arr[@]}; do
  (( res *= i ))
done

echo "Result : ${res}"
