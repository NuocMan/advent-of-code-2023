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

  echo ${#result[@]}
}

declare -A bonus_array=([pouetpouet]=toto)
readarray -t LINE_ARRAY < "$1"

function pouet() {
  local index=$1

  [[ -n "${bonus_array[$index]}" ]] && {
    return ${bonus_array[$index]}
  }

  (( $index >= ${#LINE_ARRAY[@]} )) && {
    bonus_array[$index]=0
    return 0
  }
  local score=$(get_game_points "${LINE_ARRAY[$index]}")
  # echo "index=$index" "score=${score}"
  (( score == 0 )) && {
    echo "loosing Card "$(( index + 1 ))" (0)" >&2
    bonus_array[$index]=0
    return 0
  }
  echo "winning Card "$(( index + 1 )) "($score) => "$(seq $(( index + 2 )) $(( index + score + 1))) >&2
  local scratch_card_bonus=0
  for i in $(seq $(( index + 1 )) $(( index + score )) ); do
    (( scratch_card_bonus++ ))
    pouet $i
    (( scratch_card_bonus += $? ))
  done

  bonus_array[$index]=${scratch_card_bonus}

  return ${scratch_card_bonus}
}

scratch_card=0
for i in $(seq $(( ${#LINE_ARRAY[@]} - 1 )) 0); do
  (( scratch_card++ ))
  pouet $i
  (( scratch_card += $? ))
done

echo "Result : $scratch_card"
