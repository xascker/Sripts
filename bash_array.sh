#!/bin/bash

array=(a b c d)

for  value in ${array[@]};do
echo "$value -> index: ${!array[*]}"
done

echo "#######################"

for index in ${!array[*]}; do
echo "${array[$index]} -> index: $index "
done

echo "totat: ${#array[@]}" 
