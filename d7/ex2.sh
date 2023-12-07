#! /usr/bin/env bash

if [[ $# != 1 || ! -f "$1" ]] ; then
  exit 1
fi

function get_type() {
  local cards=$1
  local -A count_arr
  local max_count=0
  local max_index=0
  for card_i in {0..4}; do
    local card=${cards:${card_i}:1}
    (( count_arr[$card]++ ))
    local val=${count_arr[$card]}
    (( $max_count < $val )) && [[ $card != 1 ]] && {
      max_count=$val
      max_index=$card
    }
  done

  local count_joker=${count_arr[1]:-0}
  unset count_arr[1]
  (( count_arr[$max_index] += $count_joker ))
  local size_arr=${#count_arr[@]}

  if [[ $size_arr == 1 || $size_arr == 0 ]] ; then
    echo S5
  elif [[ $size_arr == 2 ]]; then
    if [[ ${count_arr[@]} =~ 4 ]]; then
      echo S4
    else
      echo SFH
    fi
  elif [[ $size_arr == 3 ]]; then
    if [[ ${count_arr[@]} =~ 3 ]]; then
      echo S3
    else
      echo S2P
    fi
  elif [[ $size_arr == 4 ]]; then
    echo SP
  else
    echo SH
  fi
}

S5=()
S4=()
SFH=()
S3=()
S2P=()
SP=()
SH=()
bets=()

readarray -t LINE_ARRAY < "$1"
for line_i in "${!LINE_ARRAY[@]}"; do
  line_arr=( ${LINE_ARRAY[$line_i]} )
  bets+=(${line_arr[1]})
  cards=${line_arr[0]}

  cards_value=${cards//T/a}
  cards_value=${cards_value//J/1}
  cards_value=${cards_value//Q/c}
  cards_value=${cards_value//K/d}
  cards_value=${cards_value//A/e}
  type=$(get_type $cards_value)
  declare -n collection=$type
  collection[$(( 0x${cards_value} )) ]=${line_i}
done

res=0
rank=1
for arr_name in SH SP S2P S3 SFH S4 S5; do
  declare -n arr=$arr_name

  for i in ${!arr[@]}; do
    index=${arr[i]}
    (( res += (${bets[$index]} * $rank) ))
    (( rank++ ))
  done
done

echo "Result : ${res}"
