#! /usr/bin/env bash


if [[ $# != 1 || ! -f "$1" ]] ; then
  exit 1
fi

function is_adjacent() {
  local c1
  local c2
  readarray -td';' c1< <(printf '%s' "$1")
  readarray -td';' c2< <(printf '%s' "$2")

  local diff_line=$(( ${c1[0]} - ${c2[0]} ))
  if (( diff_line < -1 || diff_line > 1 )); then
    return 1
  fi

  local c11=$(( ${c1[1]} - ${c2[1]} ))
  local c12=$(( ${c1[2]} - ${c2[1]} ))
  if (( ( ${c1[1]} <= ${c2[1]} ) && ( ${c2[1]} <= ${c1[2]} )
    || ( ( ${c11} >= -1 ) && ( ${c11} <= 1 ) )
    || ( ( ${c12} >= -1 ) && ( ${c12} <= 1 ) ) )); then
    return 0
  fi
  return 1
}

readarray -t LINE_ARRAY < "$1"

declare -A matrix
declare -A matrix_things

sum=0
line_i=0
for line in "${LINE_ARRAY[@]}"; do

  readarray -td'.' splitted_line < <(printf '%s' "${line}")

  j=0
  for word in "${splitted_line[@]}"; do
    if [[ $word == "" ]]; then
      (( j += 1 ))
      continue
    fi

    size=${#word}
    if [[ "$word" =~ ^[0-9]+$ ]]; then
      matrix["${line_i};${j};$(( j + size - 1 ))"]="$word"
      (( j += size + 1 ))
    elif [[ "$word" =~ ^[^0-9]$ ]]; then
      matrix_things["${line_i};${j}"]="${word}"
      (( j += size + 1))
    else
      nb="${word%%[^0-9]*}"
      if [[ -n "$nb" ]]; then
        matrix["${line_i};${j};$(( j + ${#nb} - 1 ))"]="${nb}"
        (( j += ${#nb} ))
      fi

      matrix_things["${line_i};${j}"]="${word:${#nb}:1}"
      (( j += 1 ))

      nb="${word#*[^0-9]}"
      if [[ -n "$nb" ]]; then
        matrix["${line_i};${j};$(( j + ${#nb} - 1 ))"]="${nb}"
        (( j += ${#nb} ))
      fi
      (( j++ ))
    fi
  done
  (( line_i++ ))
done

# declare -p matrix
# declare -p matrix_things
line_size=${#LINE_ARRAY[0]}
for number_i in "${!matrix[@]}"; do
  readarray -td';' number_i_a < <(printf '%s' "$number_i")

  lineminus=$(( ${number_i_a[0]} - 1 ))
  lineplus=$(( ${number_i_a[0]} + 1 ))
  xminus=$(( ${number_i_a[1]} - 1 ))
  xplus=$(( ${number_i_a[2]} + 1))
  # echo $number_i
  # echo "--------"
  for thing_i in $(seq -f "${lineminus};%g" $xminus $xplus; echo "${number_i_a[0]};$xminus" "${number_i_a[0]};$xplus" ; seq -f "${lineplus};%g"  $xminus $xplus ) ; do
    # echo $thing_i
    if [[ -z ${matrix_things[$thing_i]} ]]; then
      continue
    fi
    if is_adjacent "$number_i" "$thing_i"; then
      # echo ${thing_i} ${number_i} ${matrix[${number_i}]}
      (( sum += matrix[$number_i] ))
    fi
  done
  # echo "======"
done

echo "Result : $sum"
