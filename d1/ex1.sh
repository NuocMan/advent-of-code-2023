#! /usr/bin/env bash

if [[ $# != 1 || ! -f $1 ]] ; then
  exit 1
fi

readarray -t LINE_ARRAY < $1

sum=0
for l in "${LINE_ARRAY[@]}"; do
  numbers="${l//[^0-9]/}"
  last_i=$(( ${#numbers} - 1 ))

  (( sum += "${numbers:0:1}${numbers:$last_i:1}" ))
done

echo "Result: $sum"
