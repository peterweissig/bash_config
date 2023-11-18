#!/bin/bash

#***************************[nano]********************************************
# 2023 11 18
function config_nano() { nano_config; }

# 2021 02 06
function nano_config() {

    # print help
    if [ "$1" == "-h" ]; then
        echo "$FUNCNAME [--no-header] [--sudo] <filename> [<subdir>]"

        return
    fi
    if [ "$1" == "--help" ]; then
        echo "$FUNCNAME has 2 options and needs 1-2 parameters"
        echo "    [--no-header] avoids adding header info"
        echo "    [--sudo]      uses always sudo to access the file"
        echo "     #1: full path of original file"
        echo "    [#2:]additional subdirectory for storing backup"
        echo "This function executes nano to modify the given config file."
        echo "Before and after the operation a backup-file will be created."

        return
    fi

    # init variables
    option_no_header=0
    option_sudo=0
    param_file=""
    param_subdir=""

    # check and get parameter
    params_ok=0
    if [ $# -ge 1 ] && [ $# -le 4 ]; then
        params_ok=1
        while true; do
            if [ "$1" == "--no-header" ]; then
                option_no_header=1
                shift
                continue
            elif [ "$1" == "--sudo" ]; then
                option_sudo=1
                shift
            elif [[ "$1" =~ ^-- ]]; then
                echo "$FUNCNAME: Unknown option \"$1\"."
                return -1
            else
                break
            fi
        done
        param_file="$1"
        param_subdir="$2"
        if [ $# -lt 1 ] || [ $# -gt 2 ]; then
            params_ok=0
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
            _config_file_modify_full "$param_file" "$param_subdir" "" \
              "auto" "" "sudo"
        else
            # sudo
            _config_file_modify_full "$param_file" "$param_subdir" "" \
              "auto" "default" "sudo"
        fi
    else
        if [ $option_no_header -eq 1 ]; then
            # no header
            _config_file_modify_full "$param_file" "$param_subdir" "" \
              "auto" ""
        else
            # simple version
            _config_file_modify_full "$param_file" "$param_subdir" ""
        fi
    fi
}

# 2023 11 18
function config_nano_restore() { nano_config_restore; }

# 2020 02 06
function nano_config_restore() {

    # print help
    if [ "$1" == "-h" ]; then
        echo "$FUNCNAME <filename> [<subdir>]"

        return
    fi
    if [ "$1" == "--help" ]; then
        echo "$FUNCNAME needs 1-2 parameters"
        echo "     #1: full path of original file"
        echo "    [#2:]additional subdirectory for storing backup"
        echo "This function restores the formerly modified config file."
        echo "The related backup-files will be removed!"

        return
    fi

    param_file="$1"
    param_subdir="$2"

    # check parameter
    if [ $# -lt 1 ] || [ $# -gt 2 ]; then
        echo "$FUNCNAME: Parameter Error."
        $FUNCNAME --help
        return -1
    fi

    # call the general restore function
    _config_file_restore_full "$param_file" "$param_subdir"
}
