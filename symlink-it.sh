#!/bin/bash

if ! [[ -f $1 ]]; then
	echo "Invalid argument, pass the filename as argument to create a link for it"
    exit 1
fi

file=$1
file_path=$(realpath $file)
filename=$(basename $file_path)
script_path=$(dirname "$(readlink -f "$0")")
origin_path=$(dirname $file_path)
target_path=$script_path/root$origin_path

echo "Target path for file: $target_path"
mkdir -p $target_path
mv $file $target_path
echo "Creating symlink for $file_path"
ln -s "$target_path/$filename" "$origin_path/$filename"
