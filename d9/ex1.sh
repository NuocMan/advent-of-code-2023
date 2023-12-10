#! /usr/bin/env bash

if [[ $# != 1 || ! -f "$1" ]] ; then
  exit 1
fi

function extrapolate() {
  line_arr=( $@ )
  next_line_arr=()
  for i in ${!line_arr[@]}; do
    [[ $(( i + 1 )) == ${#line_arr[@]} ]] && break
    next_line_arr+=( $(( ${line_arr[$i + 1]} - ${line_arr[$i]} )) )
  done
  next_line_arr_str="${next_line_arr[@]}"
  next_line_arr_str=${next_line_arr_str// /}
  if [[ $next_line_arr_str =~ ^0+$ ]]; then
    echo 0
  else
    val=$(extrapolate ${next_line_arr[@]})
    echo $(( ${next_line_arr[-1]} + $val ))
  fi
}
res=0

readarray -t LINE_ARRAY < "$1"
for line in "${LINE_ARRAY[@]}"; do
  val=$(extrapolate $line)
  line_arr=( $line )
  (( res += val + ${line_arr[-1]} ))
done


echo "Result : ${res}"
