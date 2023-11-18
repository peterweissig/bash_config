#!/bin/bash

#***************************[check sources]***********************************
# 2023 11 18

function _config_check_sources_vscode() {
    _config_check_sources "microsoft.com" "vscode"
}
function _config_check_sources_nextcloud() {
    _config_check_sources "nextcloud" "client"
}
function _config_check_sources_ros() {
    _config_check_sources "ros.org"
}

# 2020 12 30
function _config_check_sources() {

    # print help
    if [ "$1" == "-h" ]; then
        echo "$FUNCNAME <filter1> [<filter2> [<filter3>]]]"

        return
    fi
    if [ "$1" == "--help" ]; then
        echo "$FUNCNAME needs 1-3 parameters"
        echo "     #.: each parameter is a pattern (e.g. a simple word)"
        echo "          that must be found in the same line"
        echo "          e.g. \"nextcloud\" & \"client\""
        echo "This function checks the source lists of apt if the given"
        echo "patterns are found in one line."

        return
    fi

    # check parameter
    if [ $# -lt 1 ] || [ $# -gt 3 ]; then
        echo "$FUNCNAME: Parameter Error."
        $FUNCNAME --help
        return -1
    fi


    # check all source files
    FILENAME_CONFIG="/etc/apt/sources.list"
    PATH_CONFIG="/etc/apt/sources.list.d/"

    # find all entries within config path
    readarray -t filelist <<< "$(ls "$PATH_CONFIG" 2>> /dev/null | \
      grep -v -e ".save\$" )"
        # check result
        if [ $? -ne 0 ]; then return -2; fi
    # prepand path to all files
    for i in ${!filelist[@]}; do
        filelist[$i]="${PATH_CONFIG}${filelist[$i]}"
    done
    # add basic file
    filelist+=("$FILENAME_CONFIG")

    # iterate over all files
    for i in ${!filelist[@]}; do
        if [ "${filelist[$i]}" == "" ] || [ ! -f "${filelist[$i]}" ]; then
            continue;
        fi

        str="$(cat "${filelist[$i]}" | grep -v "^#" \
               | grep "$1" | grep "$2" | grep "$3" 2> /dev/null)"
        if [ "$?" -ne 0 ]; then continue; fi
        if [ "$str" != "" ]; then
            echo "${filelist[$i]}"
            return
        fi
    done
}
