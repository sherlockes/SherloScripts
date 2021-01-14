#!/bin/bash

shopt -s nullglob

for ext in jpg jpeg png gif; do 
  files=( *."$ext" )
  printf 'Número de imágenes %s : %d\n' "$ext" "${#files[@]}"

  # now we can loop over all the files having the current extension
  for f in "${files[@]}"; do
    # anything else you like with these files
    :
  done 

done