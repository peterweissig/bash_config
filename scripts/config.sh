#!/bin/bash

#***************************[apt]*********************************************
# 2019 09 08

function config_update_system() {

    echo "1. sudo apt-get update"
    sudo apt-get update
    if [ $? -ne 0 ]; then return -1; fi

    echo ""
    echo "2. sudo apt-get upgrade --assume-yes"
    sudo apt-get upgrade --assume-yes
    if [ $? -ne 0 ]; then return -2; fi

    echo ""
    echo "3. sudo apt-get dist-upgrade --assume-yes"
    sudo apt-get dist-upgrade --assume-yes
    if [ $? -ne 0 ]; then return -3; fi

    echo ""
    echo "4. sudo apt-get autoremove --assume-yes"
    sudo apt-get autoremove --assume-yes
    if [ $? -ne 0 ]; then return -4; fi

    echo ""
    echo "done :-)"
}


#***************************[nano]********************************************
# 2019 09 09

alias config_nano="nano_config"
function nano_config() {

    # print help
    if [ "$1" == "-h" ]; then
        echo "$FUNCNAME <filename>"

        return
    fi
    if [ "$1" == "--help" ]; then
        echo "$FUNCNAME needs 1 parameter"
        echo "     #1: full path of original file"
        echo "This function executes nano to modify the given config file."
        echo "Before and after the operation a backup-file will be created."

        return
    fi

    # check parameter
    if [ $# -ne 1 ]; then
        echo "$FUNCNAME: Parameter Error."
        $FUNCNAME --help
        return -1
    fi

    # call the general modification function
    _config_file_modify "$1"
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


#***************************[inputrc]*****************************************
# 2019 09 26

function config_bash_search() {

    # print help and check for user agreement
    _config_simple_parameter_check "$FUNCNAME" "$1" \
      "enables searching through the bash-history using" \
      "page-up/page-down keys."
    if [ $? -ne 0 ]; then return -1; fi

    # Do the configuration
    FILENAME_CONFIG="/etc/inputrc"

    AWK_STRING='
        # backward search
        $0 ~ /^# "\\e\[5~": history-search-backward/ {
          print "# [COMMENT]: ",$0
          $0 = "\"\\e[5~\": history-search-backward"
        }
        # forward search
        $0 ~ /^# "\\e\[6~": history-search-forward/ {
          print "# [COMMENT]: ",$0
          $0 = "\"\\e[6~\": history-search-forward"
        }

        { print $0 }
    '

    _config_file_modify "$FILENAME_CONFIG" "$AWK_STRING" "backup-once"
}

function config_bash_search_restore() {

    # print help and check for user agreement
    _config_simple_parameter_check "$FUNCNAME" "$1" \
      "restores the old behaviour for searching through the bash-history."
    if [ $? -ne 0 ]; then return -1; fi

    # Undo the configuration
    FILENAME_CONFIG="/etc/inputrc"

    _config_file_restore "$FILENAME_CONFIG" "backup-once"
}


#***************************[sources.list]************************************
# 2019 09 26

function config_source_list_to_multiverse() {

    FILENAME_CONFIG="/etc/apt/sources.list"

    # print help and check for user agreement
    _config_simple_parameter_check "$FUNCNAME" "$1" \
      "appends restricted, universe and multiverse to all sources." \
      "  (only changing $FILENAME_CONFIG)"
    if [ $? -ne 0 ]; then return -1; fi

    # Do the configuration
    AWK_STRING='
        # append restricted, universe and multiverse to all sources
        $0 ~ /^deb.+main$/ {
          print "# [COMMENT]: ",$0
          $0 = $0" restricted universe multiverse"
        }

        { print $0 }
    '

    _config_file_modify "$FILENAME_CONFIG" "$AWK_STRING" "backup-once"
}

function config_source_list_to_multiverse_restore() {

    # print help and check for user agreement
    _config_simple_parameter_check "$FUNCNAME" "$1" \
      "restores the old behaviour for sources.list."
    if [ $? -ne 0 ]; then return -1; fi

    # Undo the configuration
    FILENAME_CONFIG="/etc/apt/sources.list"

    _config_file_restore "$FILENAME_CONFIG" "backup-once"
}
