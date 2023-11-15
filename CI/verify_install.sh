#!/bin/bash

make_install_output=$1

dirs=($(cat "$make_install_output" | grep "install -d .*" | awk '{ print $3 }'))
for d in "${dirs[@]}"; do
    if [ ! -d "$d" ]; then
        echo "Directory $d not found!"
        exit 1
    fi
done

files=($(cat "$make_install_output" | grep "install ./.*" | awk '{sub(".*/", "", $2); print $3$2}'))
for f in "${files[@]}"; do
    if [ ! -f "$f" ]; then
        echo "File $f not found!"
        exit 1
    fi
done

check_pip=$(pip show adi_colorimeter | grep -i warning)
if [ "$check_pip" ]; then
    echo "Pip package adi_colorimeter install failed!"
    exit 1
fi

echo "Colorimeter installed successfully."
