#! /usr/bin/env bash


if [[ $# != 1 || ! -f $1 ]] ; then
  exit 1
fi

readarray -t LINE_ARRAY < $1

sum=0
id=0
declare -A rgb
rgb=([red]=12 [green]=13 [blue]=14)

for line in "${LINE_ARRAY[@]}"; do
  fail=0
  (( id++ ))

  game_balls="${line#*: }"

  readarray -td';' round_balls_array < <(printf '%s' "$game_balls")

  for round_balls in "${round_balls_array[@]}"; do

    readarray -td',' round_balls_color < <(printf '%s' "$round_balls")

    for color_balls in "${round_balls_color[@]}"; do
      color="${color_balls##* }"
      color="${color_balls##* }"
      nb_ball="${color_balls% *}"
      nb_ball="${nb_ball//[[:space:]]/}"

      if (( $nb_ball > ${rgb[$color]} )); then
        echo "Not possible for Game ${id}. ${color}=${nb_ball}" >&2
        fail=1
        break
      fi
    done
    if [[ $fail == 1 ]]; then
      break
    fi
  done
  if [[ $fail == 0 ]]; then
    (( sum += id ))
  fi
done

echo "Result : $sum"
