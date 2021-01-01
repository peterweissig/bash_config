#!/bin/bash

#***************************[parameter]***************************************
# 2019 12 01

function _config_simple_parameter_check() {

    # print help
    if [ "$1" == "-h" ]; then
        echo -n "$FUNCNAME <function_name> <first_parameter> <string1> "
        echo "[<string2>] ..."

        return
    fi
    if [ "$1" == "--help" ]; then
        echo "$FUNCNAME needs 3-.. parameters"
        echo "     #1: displayed function name"
        echo "     #2: first parameter"
        echo "     #3: (first) string of description"
        echo "    [#..:] optional other strings of description"
        echo "This function is a wrapper function for all simple config-"
        echo "functions, which do not take any parameters except for"
        echo "-h and --help."
        echo "Additionally the user will be asked to confirm the execution."

        return
    fi

    # check parameter
    if [ $# -lt 3 ]; then
        echo "$FUNCNAME: Parameter Error."
        $FUNCNAME --help
        return -1
    fi




    # switch to wrapped function
    func_name="$1"
    argument="$2"
    shift
    shift

    # print simple help
    if [ "$argument" == "-h" ]; then
        echo "$func_name"
        return 1
    fi

    # print function description
    echo -n "$func_name "
    for line in "$@"; do
        echo "$line"
    done

    if [ "$argument" == "--help" ]; then
        return 2
    fi

    # check parameter
    if [ "$argument" != "" ]; then
        echo "$func_name: Parameter Error."
        return -1
    fi

    # check for user-intention
    echo -n "  Do you want to continue ? (No/yes) "
    read answer

    if [ "$answer" != "y" ] && [ "$answer" != "Y" ] && \
        [ "$answer" != "yes" ]; then
        echo "$func_name: Aborted."
        return -1
    fi

    return
}
