#! /usr/bin/env bash

if [[ $# != 1 || ! -f "$1" ]] ; then
  exit 1
fi

readarray -t LINE_ARRAY < "$1"
for line_i in "${!LINE_ARRAY[@]}"; do
  [[ ${LINE_ARRAY[$line_i]} =~ S ]] && {
    start_prefix=${LINE_ARRAY[$line_i]%S*}
    start=($line_i ${#start_prefix})
    break
  }
done

LEFT=L
UP=U
DOWN=D
RIGHT=R

# | is a vertical pipe connecting north and south.
# - is a horizontal pipe connecting east and west.
# L is a 90-degree bend connecting north and east.
# J is a 90-degree bend connecting north and west.
# 7 is a 90-degree bend connecting south and west.
# F is a 90-degree bend connecting south and east.
# . is ground; there is no pipe in this tile.
# S is the starting position of the animal; there is a pipe on this tile, but your sketch doesn't show what shape the pipe has.


# $1 line_i
# $2 column_j
function find_type_pipe() {
  local down_pos=""
  local up_pos=""
  local right_pos=""
  local left_pos=""

  (( $1 < ${#LINE_ARRAY[@]} - 1 )) && down_pos=${LINE_ARRAY[$1 + 1]:$2:1}
  (( $1 != 0 )) && up_pos=${LINE_ARRAY[$1 - 1]:$2:1}
  (( $2 < ${#LINE_ARRAY[0]} - 1 )) && right_pos=${LINE_ARRAY[$1]:$(($2 + 1)):1}
  (( $2 != 0 )) && left_pos=${LINE_ARRAY[$1]:$(($2 - 1)):1}

  down_ok=false
  up_ok=false
  right_ok=false
  left_ok=false

  [[ $down_pos == "|" || $down_pos == "L" || $down_pos == "J" ]] && down_ok=true
  [[ $up_pos == "|" || $up_pos == "F" || $up_pos == "7" ]] && up_ok=true
  [[ $right_pos == "-" || $right_pos == "J" || $right_pos == "7" ]] && right_ok=true
  [[ $left_pos == "-" || $left_pos == "L" || $left_pos == "F" ]] && left_ok=true

  local res=()
  $down_ok && {
    res+=($(($1 + 1)))
    res+=($2)
    res+=($UP)
  }
  $up_ok && {
    res+=($(($1 - 1)))
    res+=($2)
    res+=($DOWN)
  }
  $right_ok && {
    res+=($1)
    res+=($(($2 + 1)))
    res+=($LEFT)
  }
  $left_ok && {
    res+=($1)
    res+=($(($2 - 1)))
    res+=($RIGHT)
  }
  echo ${res[@]}
}


function get_next_pos() {
  local pos=${LINE_ARRAY[$1]:$2:1}
  local i=$1
  local j=$2
  local from=LOL
  case $pos in
    "|")
      if [[ $3 == U ]]; then
        from=U
      else
        from=D
      fi
    ;;
    "-")
      if [[ $3 == R ]]; then
        from=R
      else
        from=L
      fi
    ;;
    "L")
      if [[ $3 == R ]]; then
        from=D
      else
        from=L
      fi
    ;;
    "F")
      if [[ $3 == R ]]; then
        from=U
      else
        from=L
      fi
    ;;
    "J")
      if [[ $3 == L ]]; then
        from=D
      else
        from=R
      fi
    ;;
    "7")
      if [[ $3 == L ]]; then
        from=U
      else
        from=R
      fi
    ;;
    *)
      echo "wrong type $pos">&2
      exit 1
    ;;
  esac
  [[ $from == U ]] && {
    (( i++ ))
  }
  [[ $from == D ]] && {
    (( i-- ))
  }
  [[ $from == L ]] && {
    (( j++ ))
  }
  [[ $from == R ]] && {
    (( j-- ))
  }
  echo $i $j $from
}

start_sides=($(find_type_pipe ${start[@]}))
train_one=(${start_sides[@]:0:3})
train_two=(${start_sides[@]:3:3})
echo start: ${start[@]}
echo "1:" ${train_one[@]:0:2}
echo "2:" ${train_two[@]:0:2}
res=1
declare -A known_pos
while true; do
  train_one=($(get_next_pos ${train_one[@]}))
  train_two=($(get_next_pos ${train_two[@]}))
  train_one_str="${train_one[0]} ${train_one[1]}"
  [[ "${known_pos[$train_one_str]}" == true ]] && break
  known_pos["${train_one[0]} ${train_one[1]}"]=true
  known_pos["${train_two[0]} ${train_two[1]}"]=true
  echo "1:" ${train_one[@]:0:2}
  echo "2:" ${train_two[@]:0:2}
  (( res++ ))
done

echo "Result : ${res}"
