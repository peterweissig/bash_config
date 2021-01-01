#!/bin/bash

#***************************[nano]********************************************
# 2020 12 31

alias config_nano="nano_config"
function nano_config() {

    # print help
    if [ "$1" == "-h" ]; then
        echo "$FUNCNAME [--no-header] [--sudo] <filename>"

        return
    fi
    if [ "$1" == "--help" ]; then
        echo "$FUNCNAME has 2 options and needs 1 parameter"
        echo "    [--no-header] avoids adding header info"
        echo "    [--sudo]      uses always sudo to access the file"
        echo "     #1: full path of original file"
        echo "This function executes nano to modify the given config file."
        echo "Before and after the operation a backup-file will be created."

        return
    fi

    # init variables
    option_no_header=0
    option_sudo=0
    param_file=""

    # check and get parameter
    params_ok=0
    if [ $# -ge 1 ] && [ $# -le 3 ]; then
        params_ok=1
        param_file="${@: -1}"
        if [ $# -ge 2 ]; then
            if [ "$1" == "--no-header" ]; then
                option_no_header=1
            elif [ "$1" == "--sudo" ]; then
                option_sudo=1
            else
                params_ok=0
            fi
        fi
        if [ $# -ge 3 ]; then
            if [ "$2" == "--no-header" ]; then
                option_no_header=1
            elif [ "$2" == "--sudo" ]; then
                option_sudo=1
            else
                params_ok=0
            fi
        fi
    fi
    if [ $params_ok -ne 1 ]; then
        echo "$FUNCNAME: Parameter Error."
        $FUNCNAME --help
        return -1
    fi

    # call the modification function
    if [ $option_sudo -eq 1 ]; then
        if [ $option_no_header -eq 1 ]; then
            # sudo and no header
            _config_file_modify_full "$param_file" "" "" "auto" "" "sudo"
        else
            # sudo
            _config_file_modify_full "$param_file" "" "" "auto" \
              "default" "sudo"
        fi
    else
        if [ $option_no_header -eq 1 ]; then
            # no header
            _config_file_modify "$param_file" "" "auto" ""
        else
            # simple version
            _config_file_modify "$param_file"
        fi
    fi
}

alias config_nano_restore="nano_config_restore"
function nano_config_restore() {

    # print help
    if [ "$1" == "-h" ]; then
        echo "$FUNCNAME <filename>"

        return
    fi
    if [ "$1" == "--help" ]; then
        echo "$FUNCNAME needs 1 parameter"
        echo "     #1: full path of original file"
        echo "This function restores the formerly modified config file."
        echo "The related backup-files will be removed!"

        return
    fi

    # check parameter
    if [ $# -ne 1 ]; then
        echo "$FUNCNAME: Parameter Error."
        $FUNCNAME --help
        return -1
    fi

    # call the general modification function
    _config_file_restore "$1"
}
