#! /usr/bin/env bash

if [[ $# != 1 || ! -f "$1" ]] ; then
  exit 1
fi

seeds=()

declare -A seed_to_soil
declare -A soil_to_fertilizer
declare -A fertilizer_to_water
declare -A water_to_light
declare -A light_to_temperature
declare -A temperature_to_humidity
declare -A humidity_to_location

map_to_set=none

readarray -t LINE_ARRAY < "$1"
for line in "${LINE_ARRAY[@]}"; do
  if [[ -z $line ]]; then
    continue
  elif [[ $line =~ seeds: ]]; then
    seeds_line=( ${line##seeds: } )
    i=0
    while (( i < ${#seeds_line[@]} )); do
      seeds+=( $(seq ${seeds_lines[${i}]} $(( ${seeds_lines[${i}]} + ${seeds_lines[$(( i + 1 ))]} - 1 )) ) )
    done
  elif [[ $line =~ seed-to-soil ]]; then
    map_to_set=seed-to-soil
  elif [[ $line =~ soil-to-fertilizer ]]; then
    map_to_set=soil-to-fertilizer
  elif [[ $line =~ fertilizer-to-water ]]; then
    map_to_set=fertilizer-to-water
  elif [[ $line =~ water-to-light ]]; then
    map_to_set=water-to-light
  elif [[ $line =~ light-to-temperature ]]; then
    map_to_set=light-to-temperature
  elif [[ $line =~ temperature-to-humidity ]]; then
    map_to_set=temperature-to-humidity
  elif [[ $line =~ humidity-to-location ]]; then
    map_to_set=humidity-to-location
  else
    vals=( $line )
    range="${vals[1]}-"$(( ${vals[1]} + ${vals[2]} - 1 ))
    diff=$(( ${vals[0]} - ${vals[1]} ))
    case $map_to_set in
      seed-to-soil)
        seed_to_soil[$range]=$diff
        ;;
      soil-to-fertilizer)
        soil_to_fertilizer[$range]=$diff
        ;;
      fertilizer-to-water)
        fertilizer_to_water[$range]=$diff
        ;;
      water-to-light)
        water_to_light[$range]=$diff
        ;;
      light-to-temperature)
        light_to_temperature[$range]=$diff
        ;;
      temperature-to-humidity)
        temperature_to_humidity[$range]=$diff
        ;;
      humidity-to-location)
        humidity_to_location[$range]=$diff
        ;;
      *)
        echo "no map to set" >&2
        exit 1
    esac
  fi
done

function map() {
  local input=$1
  local -n range_array=$2

  for range in ${!range_array[@]}; do
    local range_start=${range%%-*}
    local range_end=${range##*-}
    if (( range_start <= input  &&  input <= range_end )); then
      echo $(( $input + ${range_array[$range]} ))
      return
    fi
  done

  echo $input
}

echo ${#seeds[@]}

min_location=-1
for seed in ${seeds[@]}; do

  soil=$(map $seed seed_to_soil)
  fertilizer=$(map $soil soil_to_fertilizer)
  water=$(map $fertilizer fertilizer_to_water)
  light=$(map $water water_to_light)
  temperature=$(map $light light_to_temperature)
  humidity=$(map $temperature temperature_to_humidity)
  location=$(map $humidity humidity_to_location)

  if (( location < min_location || min_location == -1 )); then
    min_location=$location
  fi
done


echo "Result : ${min_location}"
