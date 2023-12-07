#! /usr/bin/env bash

if [[ $# != 1 || ! -f "$1" ]] ; then
  exit 1
fi

function get_game_points() {
  local line="$1"
  local numbers=${line##*:}
  local winning_nb=( ${numbers%%|*} )
  local player_nb=( ${numbers##*|} )
  local result=()

  local l1=" ${winning_nb[*]} "
  for nb in "${player_nb[@]}"; do
    if [[ "$l1" =~ " $nb " ]] ; then
      result+=($nb)
    fi
  done

  # echo "${result[@]}" >&2

  if (( ${#result[@]} == 0 )); then
    echo 0
  else
    echo $(( 2**(${#result[@]} - 1) ))
  fi
}

readarray -t LINE_ARRAY < "$1"
for line in "${LINE_ARRAY[@]}"; do
  card_score=$(get_game_points "${line}")
  # echo ${card_score} >&2
  (( sum += card_score ))
done

echo "Result : $sum"
