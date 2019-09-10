#!/bin/bash

#***************************[all]*********************************************
# 2019 09 10

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
    echo -n "  "; echo "config_help  #no help"
    echo -n "  "; $FUNCNAME -h
    echo ""
    echo "install"
    echo -n "  "; echo "config_update_system  #no help"
    echo -n "  "; _config_install_list -h
    echo ""
    echo "setup config files"
    echo -n "  "; nano_config -h
    echo -n "  "; nano_config_restore -h
    echo -n "  "; echo "config_bash_search(_restore)  #no help"
    echo -n "  "; _config_file_modify -h
    echo -n "  "; _config_file_restore -h
    echo -n "  "; _config_file_return_last -h
    echo ""
}

#***************************[help]********************************************
# 2019 09 10

function config_help() {

    echo ""
    echo "### $FUNCNAME ###"
    echo ""
    echo "help functions"
    echo -n "  "; echo "$FUNCNAME  #no help"
    echo -n "  "; config_help_all -h
    echo ""
    echo "install"
    echo -n "  "; echo "config_update_system  #no help"
    echo ""
    echo "setup config files"
    echo -n "  "; nano_config -h
    echo -n "  "; nano_config_restore -h
    echo -n "  "; echo "config_bash_search(_restore)  #no help"
    echo ""
}
