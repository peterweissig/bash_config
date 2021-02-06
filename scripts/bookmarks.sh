#!/bin/bash

#***************************[bookmarks]***************************************
# 2021 02 06

function config_bookmarks_edit() {

    # print help
    if [ "$1" == "-h" ]; then
        echo "$FUNCNAME"

        return
    fi
    if [ "$1" == "--help" ]; then
        echo "$FUNCNAME needs no parameters"
        echo "This function executes nano to modify the current bookmarks."
        echo "Before and after the operation a backup-file will be created."

        return
    fi

    if [ $# -gt 0 ]; then
        echo "$FUNCNAME: Parameter Error."
        $FUNCNAME --help
        return -1
    fi

    FILENAME_CONFIG=~/".config/gtk-3.0/bookmarks"
    if [ ! -e "$FILENAME_CONFIG" ]; then
        echo "file $FILENAME_CONFIG does not exist"
        return -2
    fi

    nano_config --no-header "$FILENAME_CONFIG" "bookmarks"
}
