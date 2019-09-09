#!/bin/bash

#***************************[all]*********************************************
# 2019 09 08

function config_help_all() {

    # print help
    if [ "$1" == "-h" ]; then
        echo "$FUNCNAME"

        return
    fi
    if [ "$1" == "--help" ]; then
        echo "$FUNCNAME needs 0 parameters"
        echo "Prints all available functions within repository \"config\"."

        return
    fi

    # check parameter
    if [ $# -gt 0 ]; then
        echo "$FUNCNAME: Parameter Error."
        $FUNCNAME --help
        return -1
    fi

    # print overview of all repositories
    echo ""
    echo "### $FUNCNAME ###"
    echo ""
    echo "help"
    echo -n "  "; echo "config_help"
    echo -n "  "; config_help_all -h
    echo ""
    echo "global functions"
    echo -n "  "; echo "config_update_system"
    echo ""
    echo "setup config files"
    echo -n "  "; echo "config_bash_search"
    echo ""
    echo "internal"
    echo -n "  "; _config_file_modify_awk -h
    echo ""
}

#***************************[help]********************************************
# 2019 09 08

function config_help() {

    echo ""
    echo "### $FUNCNAME ###"
    echo ""
    echo "help functions"
    echo -n "  "; echo "config_help"
    echo -n "  "; config_help_all -h
    echo ""
    echo "global functions"
    echo -n "  "; echo "config_update_system"
    echo ""
    echo "setup config files"
    echo -n "  "; echo "config_bash_search"
    echo ""
}
