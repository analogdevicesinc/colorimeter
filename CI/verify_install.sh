#!/bin/bash

output=$1

dirs=($(cat "$output" | grep "install -d .*" | awk '{ print $3 }'))
for d in "${dirs[@]}"; do
    if [ ! -d "$d" ]; then
        echo "Directory $d not found"
        exit 1
    fi
done

files=($(cat "$output" | grep "install ./.*" | awk '{sub(".*/", "", $2); print $3$2}'))
for f in "${files[@]}"; do
    if [ ! -f "$f" ]; then
        echo "File $f not found!"
        exit 1
    fi
done

pip show adi_colorimeter
check_pip=$(pip show adi_colorimeter | grep -i warning)
if [ -z "$check_pip" ]; then
    echo "pip package install failed"
    exit 1
fi

echo "colorimeter installed successfully."