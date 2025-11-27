#
# ccd - customized cd
#
# Supported shells: bash (4.2+), zsh
# Usage: source this file from .bashrc or .zshrc
#
# Usage:
#  ccd path/to/dir/.                 select from subdirs
#  ccd path/to/dir/..                select from subdirs (recursive)
#  ccd path/to/dir/file              cd to /path/to/dir
#  find /path/to/dir/ -type d | ccd  select from stdin
#  ccd ...                           select from parent directories
#  ccd --                            select from histories
#
# Author : yosugi
# License: MIT
# Version: 0.2.0

CCD_FINDER=${CCD_FINDER:-fzf}

function ccd() {
    local dir
    if [[ -p /dev/stdin ]]; then
        local stdin
        stdin=$(cat -)
        dir=$(echo "$stdin" | eval "$CCD_FINDER")
        if [[ ! -d $dir ]]; then
            dir=$(dirname "$dir")
        fi
        eval "\\cd ${dir}" > /dev/null
        return
    elif [[ -z "$1" ]]; then
        dir=$HOME
    elif [[ $1 = '...' ]]; then
        dir=$(pwd | _ccd-parents | eval "$CCD_FINDER")
    elif [[ $1 = '--' ]]; then
        dir=$(dirs | tr ' ' '\n' | awk '!a[$1]++' | eval "$CCD_FINDER")
    elif [[ $1 = *'/..' ]]; then
        dir=$(echo "$1" | _ccd-finddir-rec | eval "$CCD_FINDER")
    elif [[ $1 = *'/.' ]]; then
        dir=$(echo "$1" | _ccd-finddir | eval "$CCD_FINDER")
    elif [[ ! -d $1 ]]; then
        dir=$(dirname "$1")
    else
        dir=$1
        eval "\\cd ${dir}" > /dev/null
        return
    fi

    if [[ -n $dir && -d $dir ]]; then
        eval "\\cd ${dir}" > /dev/null && realpath .
    fi
}

function _ccd-parents() {
    local dir
    dir=$(cat -)

    while [[ $dir != "/" ]]
    do
        echo "$dir"
        dir=$(dirname "$dir")
    done
    echo "$dir"
}

function _ccd-finddir() {
    local dir
    dir=$(cat -)
    find "${dir%??}" -maxdepth 1 -type d
}

function _ccd-finddir-rec() {
    local dir
    dir=$(cat -)
    find "${dir%???}" -type d
}
