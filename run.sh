#! /usr/bin/env bash
set -e
file="${1}"
if [ -z "${file}" ]; then
    echo "missing argument"
    exit 1
fi

ofile=$(basename "${file}" .asm)
dasm "${file}" -o"bin/${ofile}.bin" -l"bin/${ofile}.lst" -s"bin/${ofile}.sym" -f3 -S -R

Stella "bin/${ofile}.bin" 
