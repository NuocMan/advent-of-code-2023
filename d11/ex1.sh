#! /usr/bin/env bash

if [[ $# != 1 || ! -f "$1" ]] ; then
  exit 1
fi

declare empty_lines
declare empty_columns
galaxies=()
readarray -t LINE_ARRAY < "$1"

for i in $(seq 0 $(( ${#LINE_ARRAY[@]} - 1 )) ); do
  empty_lines[$i]=true
done

for j in $(seq 0 $(( ${#LINE_ARRAY[0]} - 1 )) ); do
  empty_columns[$j]=true
done

for line_i in "${!LINE_ARRAY[@]}"; do
  line=${LINE_ARRAY[$line_i]}
  while ! [[ ${line} =~ ^\.*$ ]]; do
    empty_lines[$line_i]=false
    prefix_galaxy=${line%%\#*}
    column_j=${#prefix_galaxy}
    empty_columns[$column_j]=false
    galaxies+=("${line_i} ${column_j}")
    line=${line/\#/.}
  done
done

function get_distance() {
  local galaxy_one=($1)
  local galaxy_two=($2)


  local dist_i=$(( ${galaxy_one[0]} - ${galaxy_two[0]} ))
  dist_i=${dist_i#-}
  local dist_j=$(( ${galaxy_one[1]} - ${galaxy_two[1]} ))
  dist_j=${dist_j#-}

  local expension=()
  if (( ${galaxy_one[0]} < ${galaxy_two[0]} )); then
    expension+=( ${empty_lines[@]:${galaxy_one[0]}:$dist_i} )
  else
    expension+=( ${empty_lines[@]:${galaxy_two[0]}:$dist_i} )
  fi

  if (( ${galaxy_one[1]} < ${galaxy_two[1]} )); then
    expension+=( ${empty_columns[@]:${galaxy_one[1]}:$dist_j} )
  else
    expension+=( ${empty_columns[@]:${galaxy_two[1]}:$dist_j} )
  fi

  expension=( ${expension[@]//false/} )

  echo $(( dist_i + dist_j + ${#expension[@]} ))
}

res=0
for galaxy_i in ${!galaxies[@]}; do
  galaxy_one=()
  next_galaxies=( "${galaxies[@]:$galaxy_i}" )
  for galaxy_j in ${!next_galaxies[@]}; do
    dist=$(get_distance "${galaxies[$galaxy_i]}" "${next_galaxies[$galaxy_j]}")
    # echo "${galaxy_i}-$((${galaxy_i} + ${galaxy_j})): ${dist}"
    (( res += dist  ))
  done
done

echo "Result : ${res}"
