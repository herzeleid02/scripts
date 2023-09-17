#!/bin/bash
# second version (i believeit wont be over-engineered as this thing)
shopt -u nullglob dotglob
#$IFS=" "
for file in $HOME/*; do echo "$file"; done

