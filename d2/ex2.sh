#! /usr/bin/env bash


if [[ $# != 1 || ! -f $1 ]] ; then
  exit 1
fi

readarray -t LINE_ARRAY < $1

sum=0
id=0
declare -A rgb

for line in "${LINE_ARRAY[@]}"; do
  (( id++ ))
  rgb=([red]=0 [green]=0 [blue]=0)

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
        rgb[$color]=$nb_ball
      fi
    done

  done

  (( sum += ${rgb[red]} * ${rgb[green]} * ${rgb[blue]}))

done

echo "Result : $sum"
