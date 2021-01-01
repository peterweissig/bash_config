#!/bin/bash

#***************************[apt]*********************************************
# 2019 09 08

function config_update_system() {

    echo "1. sudo apt update"
    sudo apt update
    if [ $? -ne 0 ]; then return -1; fi

    echo ""
    echo "2. sudo apt upgrade --assume-yes"
    sudo apt upgrade --assume-yes
    if [ $? -ne 0 ]; then return -2; fi

    echo ""
    echo "3. sudo apt dist-upgrade --assume-yes"
    sudo apt dist-upgrade --assume-yes
    if [ $? -ne 0 ]; then return -3; fi

    echo ""
    echo "4. sudo apt autoremove --assume-yes"
    sudo apt autoremove --assume-yes
    if [ $? -ne 0 ]; then return -4; fi

    echo ""
    echo "done :-)"
}



#***************************[sources.list]************************************
# 2019 11 20

function config_source_list_add_multiverse() {

    FILENAME_CONFIG="/etc/apt/sources.list"

    # print help and check for user agreement
    _config_simple_parameter_check "$FUNCNAME" "$1" \
      "appends restricted, universe and multiverse to all sources." \
      "  (only changing $FILENAME_CONFIG)"
    if [ $? -ne 0 ]; then return -1; fi

    # check if already set
    temp="$(cat "$FILENAME_CONFIG" | grep --extended-regexp "^deb" | \
      grep --extended-regexp "(multiverse|universe|restricted)")"
    if [ "$(echo "$temp" | wc -w)" -gt 0 ]; then
        echo -n "$FILENAME_CONFIG: multiverse, universe or restricted "
        echo "is already set!"
        echo ""
        echo "$temp"
        return -2
    fi

    # do the configuration
    AWK_STRING='
        # append restricted, universe and multiverse to all sources
        $0 ~ /^deb.+main$/ {
          print "# [EDIT]: ",$0
          $0 = $0" restricted universe multiverse"
        }

        { print $0 }
    '

    _config_file_modify "$FILENAME_CONFIG" "$AWK_STRING" "backup-once"
}

function config_source_list_add_multiverse_restore() {

    # print help and check for user agreement
    _config_simple_parameter_check "$FUNCNAME" "$1" \
      "restores the old behaviour for sources.list."
    if [ $? -ne 0 ]; then return -1; fi

    # Undo the configuration
    FILENAME_CONFIG="/etc/apt/sources.list"

    _config_file_restore "$FILENAME_CONFIG" "backup-once"
}



#***************************[aptcacher]***************************************

# 2020 12 31
function config_source_list_aptcacher_set() {

    # print help
    if [ "$1" == "-h" ]; then
        echo "$FUNCNAME <ip-address>"

        return
    fi
    if [ "$1" == "--help" ]; then
        echo "$FUNCNAME has 1 option and needs 1 parameter"
        echo "    [--https2http] downgrades https connections"
        echo "     #1: ip-address of apt-cacher-ng server"
        echo "This function changes all source-list files to use the"
        echo "apt-cacher server. If a server is already set, the source will"
        echo "not be changed, even if the ip-address is not matching."

        return
    fi

    # init variables
    option_https=0
    param_ip=""

    # check and get parameter
    params_ok=0
    if [ $# -ge 1 ] && [ $# -le 2 ]; then
        params_ok=1
        param_ip="${@: -1}"
        if [ $# -ge 2 ]; then
            if [ "$1" == "--https2http" ]; then
                option_https=1
                echo -n "$FUNCNAME: Option Warning - "
                echo "downgrading https is enabled."
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

    if [ "$param_ip" != "localhost" ] && \
      ! [[ "$param_ip" =~ ((([0-9]{1,3})\.){3})([0-9]{1,3}) ]]; then

        echo "$FUNCNAME: ip-address ($param_ip) is not valid."
        return -2
    fi

    FILENAME_CONFIG="/etc/apt/sources.list"
    PATH_CONFIG="/etc/apt/sources.list.d/"

    AWK_STRING="
        # update url of repositories

        # update http
        \$0 ~ /^deb/ && \$0 !~ /:3142/ {
          sub( /http:\/\// , \"&${param_ip}:3142/\" )
        }
    "
    # add https-part, if option is set
    if [ $option_https -eq 1 ]; then
        AWK_STRING+="
            # update https
            \$0 ~ /^deb/ && \$0 !~ /:3142/ && \$0 !~ /HTTPS\/\/\// {
            sub( /https:\/\// , \"http://${param_ip}:3142/HTTPS///\" )
            }
        "
    fi
    AWK_STRING+="
        { print \$0 }
    "

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
        echo "modifying file ${filelist[$i]}"

        # do the configuration
        _config_file_modify_full "${filelist[$i]}" "apt_cacher" \
          "$AWK_STRING" "normal" ""
        if [ $? -ne 0 ]; then return -3; fi
        echo ""
    done
}

# 2020 12 31
function config_source_list_aptcacher_check() {

    # print help
    if [ "$1" == "-h" ]; then
        echo "$FUNCNAME"

        return
    fi
    if [ "$1" == "--help" ]; then
        echo "$FUNCNAME needs no parameter"
        echo "This function checks if config_source_list_aptcacher_set"
        echo "needs to be called."

        return
    fi

    # check parameter
    if [ $# -gt 1 ]; then
        echo "$FUNCNAME: Parameter Error."
        $FUNCNAME --help
        return -1
    fi


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

    flag_https=0
    # iterate over all files
    for i in ${!filelist[@]}; do
        if [ "${filelist[$i]}" == "" ] || [ ! -f "${filelist[$i]}" ]; then
            continue;
        fi
        echo "checking file ${filelist[$i]}"

        # check if already set
        temp="$(cat "${filelist[$i]}" | grep --extended-regexp "^deb" | \
        grep --extended-regexp -v ":[0-9]+")"

        # check for https
        if [ "$(echo "$temp" | grep "https" | wc -w)" -gt 0 ]; then
            echo "  ... https debs need to be downgraded"
            flag_https=1
        fi

        if [ "$(echo "$temp" | grep -v "https" | wc -w)" -gt 0 ]; then
            echo ""
            echo "$FUNCNAME: sources in \"${filelist[$i]}\" can be updated"
            echo "call \$ config_source_list_aptcacher_set"
            return
        fi
    done

    if [ "${flag_https}" -eq 1 ]; then
        echo ""
        echo "$FUNCNAME: https debs can be updated by downgrading to http"
        echo "call \$ config_source_list_aptcacher_set --https2http"
        return
    fi

    echo "nothing to do :-)"
}

# 2020 12 31
function config_source_list_aptcacher_unset() {

    # print help and check for user agreement
    _config_simple_parameter_check "$FUNCNAME" "$1" \
      "changes all source-list files to NOT use the apt-cacher server."

    FILENAME_CONFIG="/etc/apt/sources.list"
    PATH_CONFIG="/etc/apt/sources.list.d/"

    AWK_STRING='
        # update url of repositories
        $0 ~ /^deb/ && $0 ~ /:3142/ {
          sub( /\S+:3142\// , "http://" )

          # check for HTTPS
          sub( /http:\/\/HTTPS\/\/\// , "https://" )
        }

        { print $0 }
    '

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
        echo "reverting file ${filelist[$i]}"

        # do the configuration
        _config_file_modify_full "${filelist[$i]}" "apt_cacher" \
          "$AWK_STRING" "normal" ""
        if [ $? -ne 0 ]; then return -3; fi
        echo ""
    done
}
