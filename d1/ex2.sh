#! /usr/bin/env bash

if [[ $# != 1 || ! -f $1 ]] ; then
  exit 1
fi

readarray -t LINE_ARRAY < $1

number_strings=(
  zero
  one
  two
  three
  four
  five
  six
  seven
  eight
  nine
)

replace_number_strings=(
  ""
  on1ne
  tw2wo
  thre3hree
  fou4our
  fiv5ive
  si6ix
  seve7even
  eigh8ight
  nin9ine
)

function parse() {
  local line="$1"
  local number_string=
  local number=

  for nb_s_i in "${!number_strings[@]}"; do
    number_string="${number_strings[$nb_s_i]}"
    replace_number_string="${replace_number_strings[$nb_s_i]}"
    line="${line//${number_string}/${replace_number_string}}"
    line="${line//${number_string}/${nb_s_i}}"
  done

  echo "$line"
}

sum=0
for line in "${LINE_ARRAY[@]}"; do
  parsed_l=$(parse "$line")
  numbers="${parsed_l//[^0-9]/}"
  last_i=$(( ${#numbers} - 1 ))
  line_val="${numbers:0:1}${numbers:$last_i:1}"
  (( sum += line_val ))
done

echo "Result: $sum"
