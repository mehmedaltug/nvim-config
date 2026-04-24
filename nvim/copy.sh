#!/bin/bash

if [ $# -ne 1 ]; then
    path=`realpath $0`
    if [[ $path != "${HOME}/.config/nvim/copy.sh" ]]; then
        path=${path::-13}
        cp -r "${path}/nvim" "$HOME/.config"
        exit
    fi
    echo "script needs 1 argument, provide the destination to copy the files"
    exit
fi

path=$1

rm -rf "${path}/nvim"

cp -r "${HOME}/.config/nvim/" "${path}/nvim"








